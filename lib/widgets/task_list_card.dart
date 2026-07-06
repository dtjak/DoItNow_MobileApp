import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../utils/snackbar_helper.dart';

/// Resolves the accent color for a task priority.
/// Green = Low, Amber = Medium, Red = High. Kept in one place so every
/// screen shows the exact same color for the same priority.
Color priorityColorFor(String priority) {
  switch (priority.toLowerCase()) {
    case 'low':
      return AppColors.tertiary;
    case 'medium':
    case 'med':
      return Colors.amber.shade700;
    case 'high':
    default:
      return AppColors.error;
  }
}

Color priorityBgFor(String priority) {
  switch (priority.toLowerCase()) {
    case 'low':
      return AppColors.tertiaryFixed;
    case 'medium':
    case 'med':
      return Colors.amber.shade100;
    case 'high':
    default:
      return AppColors.errorContainer;
  }
}

/// Indonesian display label for a stored priority value.
String priorityLabelId(String priority) {
  switch (priority.toLowerCase()) {
    case 'low':
      return 'Rendah';
    case 'medium':
    case 'med':
      return 'Sedang';
    case 'high':
    default:
      return 'Tinggi';
  }
}

/// Category chip background/text colors, shared by dashboard, pinned cards,
/// and the task list so categories look identical everywhere.
Color categoryBgFor(String category) {
  switch (category) {
    case 'Kampus':
      return AppColors.secondaryFixed;
    case 'Pribadi':
      return AppColors.tertiaryFixed;
    case 'Kerja':
      return AppColors.primaryFixed;
    case 'Organisasi':
    default:
      return AppColors.secondaryFixedDim;
  }
}

Color categoryTextFor(String category) {
  switch (category) {
    case 'Kampus':
      return AppColors.onSecondaryFixed;
    case 'Pribadi':
      return AppColors.onTertiaryFixed;
    case 'Kerja':
      return AppColors.onPrimaryFixed;
    case 'Organisasi':
    default:
      return AppColors.onSecondaryFixedVariant;
  }
}

/// A swipeable task card shared by the dashboard and calendar task lists.
///
/// - Swipe right  → mark completed (moves to archive), with undo.
/// - Swipe left   → delete task, with undo.
/// - Tap          → open task detail.
class TaskListCard extends StatelessWidget {
  final TaskModel task;
  final TaskRepository repository;

  const TaskListCard({
    super.key,
    required this.task,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final time = task.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(task.deadline!)
        : 'Tanpa tenggat';
    final priorityColor = priorityColorFor(task.priority);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.check_circle, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: complete -> archive.
          try {
            await repository.updateTaskCompletion(task.id, true);
            // Use the pre-captured messenger; the card's own context may
            // already be deactivated by the time the list rebuilds.
            showAutoDismissSnackBar(
              null,
              messenger: scaffoldMessenger,
              message: 'Tugas berhasil diselesaikan!',
              actionLabel: 'Urungkan',
              onActionPressed: () async {
                try {
                  await repository.updateTaskCompletion(task.id, false);
                } catch (e) {
                  debugPrint('Gagal mengurungkan tugas: $e');
                }
              },
            );
            return true;
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Gagal menyelesaikan tugas: $e')),
            );
            return false;
          }
        } else {
          // Swipe left: delete (with undo).
          try {
            await repository.deleteTask(task.id);
            showAutoDismissSnackBar(
              null,
              messenger: scaffoldMessenger,
              message: 'Tugas berhasil dihapus!',
              duration: const Duration(seconds: 4),
              actionLabel: 'Urungkan',
              onActionPressed: () async {
                try {
                  await repository.restoreTask(task);
                } catch (e) {
                  debugPrint('Gagal mengurungkan penghapusan tugas: $e');
                }
              },
            );
            return true;
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Gagal menghapus tugas: $e')),
            );
            return false;
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/task_detail', arguments: task);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: priorityColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityBgFor(task.priority),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            priorityLabelId(task.priority).toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryBgFor(task.category),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.category.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: categoryTextFor(task.category),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
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
              Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
