import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/task_list_card.dart';

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
  // Sorting for the "Daftar Tugas" list: null = default (newest), or by
  // priority / deadline.
  String _sortMode = 'default';

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
                  _applySort(generalTasks);

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
      floatingActionButton: Hero(
        tag: 'add_button',
        createRectTween: (begin, end) =>
            MaterialRectArcTween(begin: begin, end: end),
        child: FloatingActionButton(
          // heroTag null so the FAB doesn't create its own Hero; the wrapping
          // Hero above controls the (arc) flight between screens.
          heroTag: null,
          onPressed: () {
            Navigator.pushNamed(context, '/add_task');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomNavBar(currentRoute: '/dashboard'),
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
              Icon(Icons.task_alt, color: AppColors.primary, size: 24),
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
                        child: Icon(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.push_pin, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Tugas Penting',
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontally scrollable row of compact pinned cards. Swipe/drag
        // sideways to see the rest.
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pinnedTasks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 190,
                child: _buildSmallPinnedTaskCard(task: pinnedTasks[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmallPinnedTaskCard({required TaskModel task}) {
    final labelBgColor = categoryBgFor(task.category);
    final labelTextColor = categoryTextFor(task.category);
    final borderColor = priorityColorFor(task.priority);

    final subtitle = task.deadline != null
        ? DateFormat('dd MMM, HH:mm').format(task.deadline!)
        : 'Tanpa tenggat';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/task_detail', arguments: task);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
            Row(
              children: [
                Icon(Icons.event, size: 12, color: AppColors.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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

  // Sorts the task list in-place according to [_sortMode].
  void _applySort(List<TaskModel> tasks) {
    switch (_sortMode) {
      case 'priority':
        const rank = {'High': 0, 'Medium': 1, 'Low': 2};
        tasks.sort((a, b) =>
            (rank[a.priority] ?? 3).compareTo(rank[b.priority] ?? 3));
        break;
      case 'deadline':
        tasks.sort((a, b) {
          // Tasks without a deadline go to the end.
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      default:
        break;
    }
  }

  Widget _buildTaskListSection(List<TaskModel> generalTasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Tugas',
                style:
                    AppTextStyles.titleLg.copyWith(color: AppColors.onSurface),
              ),
              PopupMenuButton<String>(
                initialValue: _sortMode,
                tooltip: 'Urutkan tugas',
                onSelected: (value) {
                  setState(() {
                    _sortMode = value;
                  });
                },
                color: AppColors.surfaceContainerLowest,
                icon: Icon(Icons.filter_list, color: AppColors.primary),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'default',
                    child: Text(
                      'Bawaan (terbaru)',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'priority',
                    child: Text(
                      'Urutkan prioritas',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'deadline',
                    child: Text(
                      'Urutkan deadline terdekat',
                      style: TextStyle(color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ],
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
                return TaskListCard(
                  task: generalTasks[index],
                  repository: _taskRepository,
                );
              },
            ),
        ],
      ),
    );
  }
}
