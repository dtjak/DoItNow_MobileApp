import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../widgets/task_list_card.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  /// Membuat state yang dapat diubah untuk widget stateful ini.
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TaskModel _task;
  bool _isInitialized = false;

  late String _selectedCategory;
  late String _selectedPriority;
  late bool _isPinned;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final TaskRepository _taskRepository = TaskRepository();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Kampus', 'icon': Icons.school},
    {'name': 'Kerja', 'icon': Icons.work},
    {'name': 'Organisasi', 'icon': Icons.groups},
    {'name': 'Pribadi', 'icon': Icons.person},
  ];

  /// Memuat tugas yang dikirim lewat argumen rute dan menginisialisasi field form sekali saja.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _task = ModalRoute.of(context)!.settings.arguments as TaskModel;
      _selectedCategory = _task.category;
      _selectedPriority = _task.priority;
      _isPinned = _task.isPinned;
      _titleController = TextEditingController(text: _task.title);
      _descController = TextEditingController(text: _task.description);
      if (_task.deadline != null) {
        _selectedDate = _task.deadline;
        _selectedTime = TimeOfDay.fromDateTime(_task.deadline!);
      }
      _isInitialized = true;
    }
  }

  /// Membuang text controller untuk membebaskan resource saat layar ditutup.
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Membuka pemilih tanggal dan memperbarui tanggal tenggat yang dipilih.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Membuka pemilih waktu dan memperbarui waktu tenggat yang dipilih.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Memvalidasi form, membuat TaskModel yang telah diperbarui, menyimpannya ke repository, lalu menutup layar.
  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      DateTime? deadline;
      if (_selectedDate != null) {
        final time = _selectedTime ?? const TimeOfDay(hour: 23, minute: 59);
        deadline = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          time.hour,
          time.minute,
        );
      }

      final updatedTask = TaskModel(
        id: _task.id,
        userId: _task.userId,
        title: title,
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        deadline: deadline,
        isPinned: _isPinned,
        isCompleted: _task.isCompleted,
        createdAt: _task.createdAt,
      );

      await _taskRepository.updateTask(updatedTask);

      if (!mounted) return;
      Navigator.pop(context, updatedTask);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui tugas: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Membangun UI layar edit tugas termasuk field form dan tombol simpan.
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Tugas',
          style: AppTextStyles.headlineMdMobile.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 24.0,
              bottom: 120.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Judul Tugas'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Masukkan judul tugas...',
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Deskripsi'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descController,
                  hint: 'Tambahkan catatan detail tugas di sini...',
                  maxLines: 4,
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Kategori'),
                const SizedBox(height: 8),
                _buildCategoryChips(),

                const SizedBox(height: 24),
                _buildSectionTitle('Prioritas'),
                const SizedBox(height: 8),
                _buildPrioritySegmentedControl(),

                const SizedBox(height: 24),
                _buildSectionTitle('Deadline'),
                const SizedBox(height: 8),
                _buildDeadlinePickers(),

                const SizedBox(height: 32),
                _buildPinTaskSection(),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        'Simpan Perubahan',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun label bagian kecil yang digunakan di atas tiap kelompok field form.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
      ),
    );
  }

  /// Membangun field form teks bergaya dengan controller dan teks hint yang diberikan.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLg.copyWith(
          color: AppColors.outlineVariant,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  /// Membangun baris chip filter kategori yang dapat dipilih.
  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat['name'];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['icon'],
                  size: 18,
                  color: isSelected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  cat['name'],
                  style: AppTextStyles.labelLg.copyWith(
                    color: isSelected
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Membangun kontrol tersegmentasi untuk memilih prioritas tugas (Rendah/Sedang/Tinggi).
  Widget _buildPrioritySegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildPriorityOption('Low', AppColors.tertiary, AppColors.tertiary),
          _buildPriorityOption(
            'Medium',
            Colors.amber[600]!,
            Colors.amber[500]!,
          ),
          _buildPriorityOption('High', AppColors.error, AppColors.error),
        ],
      ),
    );
  }

  /// Membangun satu segmen opsi prioritas yang dapat dipilih dalam kontrol prioritas.
  Widget _buildPriorityOption(
    String label,
    Color textColor,
    Color indicatorColor,
  ) {
    final isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
            border: isSelected
                ? Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                priorityLabelId(label),
                style: AppTextStyles.labelLg.copyWith(
                  color: isSelected ? textColor : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun baris pemilih tanggal dan waktu untuk mengatur tenggat tugas.
  Widget _buildDeadlinePickers() {
    final dateStr = _selectedDate != null
        ? DateFormat('dd MMM yyyy').format(_selectedDate!)
        : 'Pilih Tanggal';
    final timeStr = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Pilih Waktu';

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: AppColors.outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      timeStr,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun bagian toggle yang memungkinkan pengguna menyematkan tugas ke atas daftar.
  Widget _buildPinTaskSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.push_pin, color: AppColors.tertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sematkan Tugas',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Simpan tugas ini di bagian atas daftar',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPinned,
            onChanged: (value) {
              setState(() {
                _isPinned = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
