import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/task_list_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  /// Membuat state yang dapat diubah untuk widget layar kalender ini.
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();
  final TaskRepository _taskRepository = TaskRepository();

  /// Memperbarui bulan yang dipilih dan mengatur ulang tanggal terpilih sesuai itu.
  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
      // Atur ulang tanggal terpilih ke hari ini jika bulan sama, jika tidak ke tanggal 1
      final today = DateTime.now();
      if (today.month == newMonth.month && today.year == newMonth.year) {
        _selectedDate = today;
      } else {
        _selectedDate = DateTime(newMonth.year, newMonth.month, 1);
      }
    });
  }

  /// Membangun scaffold layar kalender dengan bagian kalender dan jadwal tugas.
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kalender',
          style: AppTextStyles.headlineMdMobile.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskRepository.getTasksStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];
          final activeTasks = tasks.where((t) => !t.isCompleted).toList();

          // Filter tugas aktif untuk tanggal yang dipilih
          final activeTasksForSelectedDate = activeTasks.where((t) {
            if (t.deadline == null || _selectedDate == null) return false;
            return t.deadline!.day == _selectedDate!.day &&
                t.deadline!.month == _selectedDate!.month &&
                t.deadline!.year == _selectedDate!.year;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 100.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarSection(tasks),
                const SizedBox(height: 24),
                _buildTaskScheduleSection(context, activeTasksForSelectedDate),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentRoute: '/calendar'),
    );
  }

  /// Membangun kartu kalender yang menampilkan grid bulan dengan indikator tugas.
  Widget _buildCalendarSection(List<TaskModel> tasks) {
    final monthYearStr = DateFormat('MMMM yyyy').format(_selectedMonth);

    // Ambil hari-hari pada bulan terpilih yang memiliki tugas aktif
    final daysWithTasks = tasks
        .where(
          (t) =>
              t.deadline != null &&
              t.deadline!.month == _selectedMonth.month &&
              t.deadline!.year == _selectedMonth.year &&
              !t.isCompleted,
        )
        .map((t) => t.deadline!.day)
        .toSet();

    final now = DateTime.now();
    final isCurrentMonth =
        now.month == _selectedMonth.month && now.year == _selectedMonth.year;

    // Hitung hari-hari untuk grid
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    // Pada UI kita, grid dimulai dengan Senin (S, S, R, K, J, S, M)
    // Weekday Dart: 1 = Senin, 7 = Minggu
    int offset = firstDay.weekday - 1;
    final prevMonthLastDay = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      0,
    ).day;

    List<Widget> dayWidgets = [];

    // Hari-hari bulan sebelumnya (memudar)
    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    for (int i = prevMonthLastDay - offset + 1; i <= prevMonthLastDay; i++) {
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.day == i &&
          _selectedDate!.month == prevMonth.month &&
          _selectedDate!.year == prevMonth.year;
      dayWidgets.add(
        _buildCalendarDay(
          i.toString(),
          isFaded: true,
          isSelected: isSelected,
          onTap: () {
            _onMonthChanged(prevMonth);
          },
        ),
      );
    }

    // Hari-hari bulan saat ini
    for (int i = 1; i <= lastDay.day; i++) {
      final isToday = isCurrentMonth && (i == now.day);
      final hasTask = daysWithTasks.contains(i);
      final dayDateTime = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        i,
      );
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.day == i &&
          _selectedDate!.month == _selectedMonth.month &&
          _selectedDate!.year == _selectedMonth.year;

      dayWidgets.add(
        _buildCalendarDay(
          i.toString(),
          isCurrent: isToday,
          isSelected: isSelected,
          hasDot: hasTask,
          onTap: () {
            setState(() {
              _selectedDate = dayDateTime;
            });
          },
        ),
      );
    }

    // Hari-hari bulan berikutnya untuk mengisi hingga kelipatan 7
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    int totalCells = dayWidgets.length;
    int nextMonthDays = (7 - (totalCells % 7)) % 7;
    if (totalCells + nextMonthDays < 35) {
      nextMonthDays += 7;
    }
    for (int i = 1; i <= nextMonthDays; i++) {
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.day == i &&
          _selectedDate!.month == nextMonth.month &&
          _selectedDate!.year == nextMonth.year;

      dayWidgets.add(
        _buildCalendarDay(
          i.toString(),
          isFaded: true,
          isSelected: isSelected,
          onTap: () {
            _onMonthChanged(nextMonth);
          },
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showMonthYearPicker(context),
                child: Row(
                  children: [
                    Text(
                      monthYearStr,
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      final newMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                      _onMonthChanged(newMonth);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      final newMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                      _onMonthChanged(newMonth);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Label hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: dayWidgets,
          ),
        ],
      ),
    );
  }

  /// Membangun satu sel hari dalam grid kalender dengan gaya seleksi/tugas.
  Widget _buildCalendarDay(
    String day, {
    bool isFaded = false,
    bool isCurrent = false,
    bool isSelected = false,
    bool hasDot = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                day,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isCurrent)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                day,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              day,
              style: AppTextStyles.bodyMd.copyWith(
                color: isFaded
                    ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                    : AppColors.onSurface,
              ),
            ),
          if (hasDot)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.onPrimary : AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Membangun daftar tugas aktif yang dijadwalkan untuk tanggal yang dipilih.
  Widget _buildTaskScheduleSection(
    BuildContext context,
    List<TaskModel> activeTasks,
  ) {
    String formattedDate = '';
    if (_selectedDate != null) {
      formattedDate = DateFormat('dd MMMM yyyy').format(_selectedDate!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Tugas',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceContainerHigh),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 48,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada tugas berjalan untuk tanggal ini.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: activeTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TaskListCard(task: task, repository: _taskRepository),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Menampilkan dialog yang memungkinkan pengguna memilih bulan dan tahun untuk dilompati.
  void _showMonthYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'Mei',
              'Jun',
              'Jul',
              'Agu',
              'Sep',
              'Okt',
              'Nov',
              'Des',
            ];

            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.primary),
                    onPressed: () {
                      setDialogState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year - 1,
                          _selectedMonth.month,
                        );
                      });
                    },
                  ),
                  Text(
                    '${_selectedMonth.year}',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppColors.primary),
                    onPressed: () {
                      setDialogState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year + 1,
                          _selectedMonth.month,
                        );
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                height: 200,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isCurrentMonth = _selectedMonth.month == index + 1;
                    return GestureDetector(
                      onTap: () {
                        final newMonth = DateTime(
                          _selectedMonth.year,
                          index + 1,
                        );
                        Navigator.pop(context);
                        _onMonthChanged(newMonth);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentMonth
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentMonth
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: AppTextStyles.labelLg.copyWith(
                            color: isCurrentMonth
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                            fontWeight: isCurrentMonth
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
