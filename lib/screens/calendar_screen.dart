import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 100.0, // Space for custom bottom nav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarSection(),
            const SizedBox(height: 24),
            _buildTaskScheduleSection(context),
            const SizedBox(height: 24),
            _buildBentoCards(),
          ],
        ),
      ),
      // We are using a custom bottom navigation bar that includes a center FAB
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_task'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCalendarSection() {
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
                'Oktober 2023',
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
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((day) {
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
          // Calendar Grid (Static representation as per HTML)
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              // Previous month
              for (int i = 24; i <= 30; i++)
                _buildCalendarDay(i.toString(), isFaded: true),
              // Current month
              _buildCalendarDay('1'),
              _buildCalendarDay('2', hasDot: true),
              _buildCalendarDay('3'),
              _buildCalendarDay('4', hasDot: true),
              _buildCalendarDay('5'),
              _buildCalendarDay('6'),
              _buildCalendarDay('7'),
              _buildCalendarDay('8'),
              _buildCalendarDay('9'),
              _buildCalendarDay('10'),
              _buildCalendarDay('11'),
              _buildCalendarDay('12', isCurrent: true, hasDot: true),
              _buildCalendarDay('13'),
              _buildCalendarDay('14'),
              _buildCalendarDay('15', hasDot: true),
              _buildCalendarDay('16'),
              _buildCalendarDay('17'),
              _buildCalendarDay('18', hasDot: true),
              _buildCalendarDay('19'),
              _buildCalendarDay('20'),
              _buildCalendarDay('21'),
              _buildCalendarDay('22'),
              _buildCalendarDay('23'),
              _buildCalendarDay('24'),
              _buildCalendarDay('25'),
              _buildCalendarDay('26', hasDot: true),
              _buildCalendarDay('27'),
              _buildCalendarDay('28'),
              _buildCalendarDay('29'),
              _buildCalendarDay('30'),
              _buildCalendarDay('31'),
              // Next month
              for (int i = 1; i <= 4; i++)
                _buildCalendarDay(i.toString(), isFaded: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
    String day, {
    bool isFaded = false,
    bool isCurrent = false,
    bool hasDot = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isCurrent)
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
        else
          Text(
            day,
            style: AppTextStyles.bodyMd.copyWith(
              color:
                  isFaded
                      ? AppColors.onSurfaceVariant.withOpacity(0.3)
                      : AppColors.onSurface,
            ),
          ),
        if (hasDot)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 8), // Placeholder to keep alignment
      ],
    );
  }

  Widget _buildTaskScheduleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Tugas',
          style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        _buildTaskCard(
          context: context,
          priorityLabel: 'HIGH',
          priorityColor: AppColors.error,
          priorityBg: AppColors.errorContainer,
          category: 'Kampus',
          title: 'Matematika Diskrit',
          time: '09:00 - 11:30',
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          context: context,
          priorityLabel: 'MED',
          priorityColor: AppColors.secondary,
          priorityBg: AppColors.secondaryFixed,
          category: 'Kerja',
          title: 'Daily Sync UI Design',
          time: '14:00 - 15:00',
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          context: context,
          priorityLabel: 'HIGH',
          priorityColor: AppColors.error,
          priorityBg: AppColors.errorContainer,
          category: 'Kampus',
          title: 'Deadline Project Web',
          time: '23:59',
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
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/task_detail');
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant, width: 2),
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

  Widget _buildBentoCards() {
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
                    const Text(
                      '12',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Selesai bulan ini',
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

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surfaceContainerLowest,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isActive: false,
              onTap:
                  () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            _buildNavItem(
              icon: Icons.calendar_month,
              label: 'Calendar',
              isActive: true,
              onTap: () {},
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              icon: Icons.archive,
              label: 'Archive',
              isActive: false,
              onTap: () => Navigator.pushReplacementNamed(context, '/archive'),
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isActive: false,
              onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
            ),
          ],
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
              color: isActive ? AppColors.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color:
                  isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
