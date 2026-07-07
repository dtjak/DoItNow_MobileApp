import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const CustomBottomNavBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    // Listen to the theme controller directly so the footer repaints the
    // instant dark mode is toggled, even though this widget may be `const`
    // and otherwise skipped when its ancestor rebuilds.
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) => _buildBar(context),
    );
  }

  Widget _buildBar(BuildContext context) {
    final isDashboard = currentRoute == '/dashboard';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard,
                  label: 'Beranda',
                  targetRoute: '/dashboard',
                  isActive: currentRoute == '/dashboard',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.calendar_month,
                  label: 'Kalender',
                  targetRoute: '/calendar',
                  isActive: currentRoute == '/calendar',
                ),

                // Animating/entering "+" button in the middle when not on Dashboard
                if (!isDashboard) _buildCenterAddButton(context),

                _buildNavItem(
                  context: context,
                  icon: Icons.archive,
                  label: 'Arsip',
                  targetRoute: '/archive',
                  isActive: currentRoute == '/archive',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.settings,
                  label: 'Pengaturan',
                  targetRoute: '/profile',
                  isActive: currentRoute == '/profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    return Hero(
      tag: 'add_button',
      // Arc motion + curved timing makes the button glide between the
      // dashboard FAB (bottom-right) and the centre of the nav bar.
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder: (context, animation, direction, fromCtx, toCtx) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: toCtx.widget,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/add_task');
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.add, color: AppColors.onPrimary, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String targetRoute,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: isActive
          ? null
          : () {
              Navigator.pushReplacementNamed(context, targetRoute);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryFixedDim.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
