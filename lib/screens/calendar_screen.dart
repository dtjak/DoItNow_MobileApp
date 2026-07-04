import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();
  final TaskRepository _taskRepository = TaskRepository();

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
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
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
          final completedCount = tasks.where((t) => t.isCompleted).length;

          // Filter active tasks for the selected date
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
                const SizedBox(height: 24),
                _buildBentoCards(completedCount),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentRoute: '/calendar'),
    );
  }

  Widget _buildCalendarSection(List<TaskModel> tasks) {
    final monthYearStr = DateFormat('MMMM yyyy').format(_selectedMonth);

    // Get days of the selected month that have active tasks
    final daysWithTasks = tasks
        .where((t) =>
            t.deadline != null &&
            t.deadline!.month == _selectedMonth.month &&
            t.deadline!.year == _selectedMonth.year &&
            !t.isCompleted)
        .map((t) => t.deadline!.day)
        .toSet();

    final now = DateTime.now();
    final isCurrentMonth =
        now.month == _selectedMonth.month && now.year == _selectedMonth.year;

    // Calculate days for grid
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    // In our UI, grid starts with Monday (S, S, R, K, J, S, M)
    // Dart weekday: 1 = Monday, 7 = Sunday
    int offset = firstDay.weekday - 1;
    final prevMonthLastDay =
        DateTime(_selectedMonth.year, _selectedMonth.month, 0).day;

    List<Widget> dayWidgets = [];

    // Previous month days (faded)
    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    for (int i = prevMonthLastDay - offset + 1; i <= prevMonthLastDay; i++) {
      final dayDateTime = DateTime(prevMonth.year, prevMonth.month, i);
      final isSelected = _selectedDate != null &&
          _selectedDate!.day == i &&
          _selectedDate!.month == prevMonth.month &&
          _selectedDate!.year == prevMonth.year;
      dayWidgets.add(_buildCalendarDay(
        i.toString(),
        isFaded: true,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedMonth = prevMonth;
            _selectedDate = dayDateTime;
          });
        },
      ));
    }

    // Current month days
    for (int i = 1; i <= lastDay.day; i++) {
      final isToday = isCurrentMonth && (i == now.day);
      final hasTask = daysWithTasks.contains(i);
      final dayDateTime = DateTime(_selectedMonth.year, _selectedMonth.month, i);
      final isSelected = _selectedDate != null &&
          _selectedDate!.day == i &&
          _selectedDate!.month == _selectedMonth.month &&
          _selectedDate!.year == _selectedMonth.year;

      dayWidgets.add(_buildCalendarDay(
        i.toString(),
        isCurrent: isToday,
        isSelected: isSelected,
        hasDot: hasTask,
        onTap: () {
          setState(() {
            _selectedDate = dayDateTime;
          });
        },
      ));
    }

    // Next month days to pad to multiples of 7
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    int totalCells = dayWidgets.length;
    int nextMonthDays = (7 - (totalCells % 7)) % 7;
    if (totalCells + nextMonthDays < 35) {
      nextMonthDays += 7;
    }
    for (int i = 1; i <= nextMonthDays; i++) {
      final dayDateTime = DateTime(nextMonth.year, nextMonth.month, i);
      final isSelected = _selectedDate != null &&
          _selectedDate!.day == i &&
          _selectedDate!.month == nextMonth.month &&
          _selectedDate!.year == nextMonth.year;

      dayWidgets.add(_buildCalendarDay(
        i.toString(),
        isFaded: true,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedMonth = nextMonth;
            _selectedDate = dayDateTime;
          });
        },
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Text(
                monthYearStr,
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day labels
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
              decoration: const BoxDecoration(
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
                    ? AppColors.onSurfaceVariant.withOpacity(0.3)
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
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface),
            ),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: AppTextStyles.labelLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
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
              border: Border.all(
                color: AppColors.surfaceContainerHigh,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 48,
                  color: AppColors.onSurfaceVariant.withOpacity(0.3),
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
              Color priorityColor;
              Color priorityBg;
              if (task.priority.toLowerCase() == 'high') {
                priorityColor = AppColors.error;
                priorityBg = AppColors.errorContainer;
              } else if (task.priority.toLowerCase() == 'medium' ||
                  task.priority.toLowerCase() == 'med') {
                priorityColor = AppColors.secondary;
                priorityBg = AppColors.secondaryFixed;
              } else {
                priorityColor = AppColors.tertiary;
                priorityBg = AppColors.tertiaryFixed;
              }

              String timeStr = 'Tanpa tenggat';
              if (task.deadline != null) {
                timeStr = DateFormat('HH:mm').format(task.deadline!);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildTaskCard(
                  context: context,
                  priorityLabel: task.priority.toUpperCase(),
                  priorityColor: priorityColor,
                  priorityBg: priorityBg,
                  category: task.category,
                  title: task.title,
                  time: timeStr,
                  task: task,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required String priorityLabel,
    required Color priorityColor,
    required Color priorityBg,
    required String category,
    required String title,
    required String time,
    required TaskModel task,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/task_detail', arguments: task);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await _taskRepository.updateTaskCompletion(task.id, true);
                  scaffoldMessenger.clearSnackBars();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Tugas berhasil diselesaikan!'),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Urungkan',
                        textColor: AppColors.primaryFixedDim,
                        onPressed: () async {
                          try {
                            await _taskRepository.updateTaskCompletion(task.id, false);
                          } catch (e) {
                            debugPrint('Gagal mengurungkan tugas: $e');
                          }
                        },
                      ),
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Gagal menyelesaikan tugas: $e')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outlineVariant, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          priorityLabel,
                          style: AppTextStyles.labelSm.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCards(int completedCount) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.onPrimaryContainer),
                    Text(
                      'Total Tugas',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedCount',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Tugas Selesai',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      'Tips Produktif',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Istirahat 5 menit setiap 25 menit belajar.',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Icon(
                    Icons.lightbulb,
                    size: 80,
                    color: AppColors.onSurfaceVariant.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
