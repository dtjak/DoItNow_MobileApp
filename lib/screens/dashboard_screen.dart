import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Kampus',
    'Kerja',
    'Organisasi',
    'Pribadi',
  ];
  final TaskRepository _taskRepository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: StreamBuilder<List<TaskModel>>(
                stream: _taskRepository.getTasksStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'),
                    );
                  }

                  final allTasks = snapshot.data ?? [];

                  // Filter by selected category locally
                  final filteredTasks = _selectedCategory == 'Semua'
                      ? allTasks
                      : allTasks
                            .where((task) => task.category == _selectedCategory)
                            .toList();

                  // Separate active pinned vs active general tasks
                  final pinnedTasks = filteredTasks
                      .where((task) => task.isPinned && !task.isCompleted)
                      .toList();
                  final generalTasks = filteredTasks
                      .where((task) => !task.isPinned && !task.isCompleted)
                      .toList();

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildPinnedTasksSection(pinnedTasks),
                          const SizedBox(height: 24),
                          _buildCategoryFilter(),
                          const SizedBox(height: 24),
                          _buildTaskListSection(generalTasks),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'DoItNow',
                style: AppTextStyles.headlineMdMobile.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, '/profile');
                  setState(() {});
                },
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: user != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    String? photoUrl;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      photoUrl = snapshot.data!.data()?['photo_url'];
                    }

                    if (photoUrl != null && photoUrl.isNotEmpty) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outlineVariant),
                          image: DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.outline,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedTasksSection(List<TaskModel> pinnedTasks) {
    if (pinnedTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final largeTask = pinnedTasks[0];
    List<Widget> smallCardsRow = [];
    if (pinnedTasks.length > 1) {
      final task1 = pinnedTasks[1];
      smallCardsRow.add(
        Expanded(child: _buildSmallPinnedTaskCard(task: task1)),
      );
      if (pinnedTasks.length > 2) {
        final task2 = pinnedTasks[2];
        smallCardsRow.add(const SizedBox(width: 12));
        smallCardsRow.add(
          Expanded(child: _buildSmallPinnedTaskCard(task: task2)),
        );
      } else {
        smallCardsRow.add(const SizedBox(width: 12));
        smallCardsRow.add(const Expanded(child: SizedBox.shrink()));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Tugas Penting',
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildPinnedTaskCard(task: largeTask),
              if (smallCardsRow.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: smallCardsRow,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedTaskCard({required TaskModel task}) {
    Color labelBgColor;
    Color labelTextColor;
    switch (task.category) {
      case 'Kampus':
        labelBgColor = AppColors.secondaryFixed;
        labelTextColor = AppColors.onSecondaryFixed;
        break;
      case 'Pribadi':
        labelBgColor = AppColors.tertiaryFixed;
        labelTextColor = AppColors.onTertiaryFixed;
        break;
      case 'Kerja':
        labelBgColor = AppColors.primaryFixed;
        labelTextColor = AppColors.onPrimaryFixed;
        break;
      case 'Organisasi':
      default:
        labelBgColor = AppColors.secondaryFixedDim;
        labelTextColor = AppColors.onSecondaryFixedVariant;
        break;
    }

    Color borderColor;
    IconData rightIcon;
    Color rightIconColor;
    switch (task.priority) {
      case 'Low':
        borderColor = AppColors.tertiary;
        rightIcon = Icons.arrow_downward;
        rightIconColor = AppColors.tertiary;
        break;
      case 'Medium':
        borderColor = Colors.amber[600]!;
        rightIcon = Icons.priority_high;
        rightIconColor = Colors.amber[600]!;
        break;
      case 'High':
      default:
        borderColor = AppColors.error;
        rightIcon = Icons.priority_high;
        rightIconColor = AppColors.error;
        break;
    }

    final subtitle = task.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(task.deadline!)
        : 'Tanpa tenggat';

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
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: labelBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      task.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ).copyWith(color: labelTextColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.title,
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(rightIcon, color: rightIconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPinnedTaskCard({required TaskModel task}) {
    Color labelBgColor;
    Color labelTextColor;
    switch (task.category) {
      case 'Kampus':
        labelBgColor = AppColors.secondaryFixed;
        labelTextColor = AppColors.onSecondaryFixed;
        break;
      case 'Pribadi':
        labelBgColor = AppColors.tertiaryFixed;
        labelTextColor = AppColors.onTertiaryFixed;
        break;
      case 'Kerja':
        labelBgColor = AppColors.primaryFixed;
        labelTextColor = AppColors.onPrimaryFixed;
        break;
      case 'Organisasi':
      default:
        labelBgColor = AppColors.secondaryFixedDim;
        labelTextColor = AppColors.onSecondaryFixedVariant;
        break;
    }

    Color borderColor;
    switch (task.priority) {
      case 'Low':
        borderColor = AppColors.tertiary;
        break;
      case 'Medium':
        borderColor = Colors.amber[600]!;
        break;
      case 'High':
      default:
        borderColor = AppColors.error;
        break;
    }

    final subtitle = task.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(task.deadline!)
        : 'Tanpa tenggat';

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
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: labelBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                task.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(color: labelTextColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.onSurface,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.outline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
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
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
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

  Widget _buildTaskListSection(List<TaskModel> generalTasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Tugas',
            style: AppTextStyles.titleLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 16),
          if (generalTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tidak ada tugas.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: generalTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildTaskCard(
                  context: context,
                  task: generalTasks[index],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required TaskModel task,
  }) {
    final time = task.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(task.deadline!)
        : 'Tanpa tenggat';

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
              onTap: () async {
                try {
                  await _taskRepository.updateTaskCompletion(task.id, true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tugas berhasil diselesaikan!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyelesaikan tugas: $e')),
                    );
                  }
                }
              },
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.calendar_month,
                label: 'Calendar',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/calendar'),
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                icon: Icons.archive,
                label: 'Archive',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/archive'),
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: 'Settings',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryFixedDim : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? AppColors.onPrimaryFixed
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: isActive
                  ? AppColors.onPrimaryFixed
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
