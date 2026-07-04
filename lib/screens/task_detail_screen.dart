import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _task;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _task = ModalRoute.of(context)!.settings.arguments as TaskModel;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final TaskRepository taskRepository = TaskRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Tugas',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Header Section
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    label: _task.category,
                    backgroundColor: _task.category == 'Kampus'
                        ? AppColors.secondaryFixed
                        : _task.category == 'Pribadi'
                            ? AppColors.tertiaryFixed
                            : _task.category == 'Kerja'
                                ? AppColors.primaryFixed
                                : AppColors.secondaryFixedDim,
                    textColor: _task.category == 'Kampus'
                        ? AppColors.onSecondaryFixed
                        : _task.category == 'Pribadi'
                            ? AppColors.onTertiaryFixed
                            : _task.category == 'Kerja'
                                ? AppColors.onPrimaryFixed
                                : AppColors.onSecondaryFixedVariant,
                  ),
                  _buildChip(
                    label: '${_task.priority} Priority',
                    backgroundColor: _task.priority == 'High'
                        ? AppColors.errorContainer
                        : _task.priority == 'Medium'
                            ? Colors.amber[100]!
                            : AppColors.tertiaryContainer,
                    textColor: _task.priority == 'High'
                        ? AppColors.onErrorContainer
                        : _task.priority == 'Medium'
                            ? Colors.amber[900]!
                            : AppColors.onTertiaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _task.title,
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, size: 20, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Deadline: ${_task.deadline != null ? DateFormat('dd MMM yyyy, HH:mm').format(_task.deadline!) : 'Tanpa tenggat'}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: 24),

              // Task Description Section
              Text(
                'Deskripsi Tugas',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.outline),
              ),
              const SizedBox(height: 8),
              Text(
                _task.description.isEmpty
                    ? 'Tidak ada deskripsi.'
                    : _task.description,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Action Buttons
              if (!_task.isCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await taskRepository.updateTaskCompletion(_task.id, true);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tugas berhasil diselesaikan!'),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'Urungkan',
                                textColor: AppColors.primaryFixedDim,
                                onPressed: () async {
                                  try {
                                    await taskRepository.updateTaskCompletion(_task.id, false);
                                  } catch (e) {
                                    debugPrint('Gagal mengurungkan tugas: $e');
                                  }
                                },
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyelesaikan tugas: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: Text(
                      'Tugas Selesai',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_task.isCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await taskRepository.updateTaskCompletion(_task.id, false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tugas berhasil diaktifkan kembali ke dashboard!')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengaktifkan kembali tugas: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.restore, size: 24),
                    label: Text(
                      'Kembalikan ke Dashboard',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/edit_task',
                            arguments: _task,
                          );
                          if (result != null && result is TaskModel) {
                            setState(() {
                              _task = result;
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 20),
                        label: Text(
                          'Edit Tugas',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    width: 56,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Tugas'),
                            content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await taskRepository.deleteTask(_task.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tugas berhasil dihapus!')),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menghapus tugas: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.errorContainer),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.delete, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
