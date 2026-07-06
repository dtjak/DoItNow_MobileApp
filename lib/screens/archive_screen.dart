import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../utils/snackbar_helper.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Kampus',
    'Kerja',
    'Organisasi',
    'Pribadi',
  ];
  final TaskRepository _taskRepository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          'Arsip Tugas',
          style: AppTextStyles.headlineMdMobile.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Silakan login terlebih dahulu.'))
          : StreamBuilder<List<TaskModel>>(
              stream: _taskRepository.getTasksStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allTasks = snapshot.data ?? [];

                // Filter only completed tasks
                var completedTasks = allTasks
                    .where((t) => t.isCompleted)
                    .toList();

                // Apply selected category filter
                if (_selectedFilter != 'Semua') {
                  completedTasks = completedTasks
                      .where((t) => t.category == _selectedFilter)
                      .toList();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterRow(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tugas Selesai',
                              style: AppTextStyles.titleLg.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${completedTasks.length} item ditemukan',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      completedTasks.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48.0,
                                ),
                                child: Text(
                                  'Tidak ada tugas selesai.',
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: completedTasks.map((task) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: _buildArchivedTaskCard(task),
                                  );
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentRoute: '/archive'),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.labelLg.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArchivedTaskCard(TaskModel task) {
    Color priorityBg;
    Color priorityColor;
    String priorityLabel;

    switch (task.priority) {
      case 'Low':
        priorityLabel = 'LOW';
        priorityBg = AppColors.tertiaryFixed;
        priorityColor = AppColors.onTertiaryFixedVariant;
        break;
      case 'Medium':
        priorityLabel = 'MED';
        priorityBg = Colors.amber.shade100;
        priorityColor = Colors.amber.shade900;
        break;
      case 'High':
      default:
        priorityLabel = 'HIGH';
        priorityBg = AppColors.errorContainer;
        priorityColor = AppColors.error;
        break;
    }

    final formattedTime = task.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(task.deadline!)
        : 'Tanpa tenggat';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
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
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await _taskRepository.updateTaskCompletion(task.id, false);
                if (context.mounted) {
                  showAutoDismissSnackBar(
                    context,
                    message: 'Tugas dikembalikan ke daftar aktif!',
                    actionLabel: 'Urungkan',
                    onActionPressed: () async {
                      try {
                        await _taskRepository.updateTaskCompletion(
                          task.id,
                          true,
                        );
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal menyelesaikan kembali: $e',
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Gagal memulihkan tugas: $e')),
                );
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
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
                        color: priorityBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priorityLabel,
                        style: AppTextStyles.labelSm.copyWith(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.category,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.onSurfaceVariant.withOpacity(0.6),
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                      formattedTime,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppColors.outline),
            onPressed: () {
              Navigator.pushNamed(context, '/task_detail', arguments: task);
            },
          ),
        ],
      ),
    );
  }
}
