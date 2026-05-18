import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;

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
          'Profil & Pengaturan',
          style: AppTextStyles.headlineMdMobile.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: 100.0, // Space for custom bottom nav
        ),
        child: Column(
          children: [
            _buildUserSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(context),
            const SizedBox(height: 32),
            _buildLogoutSection(),
          ],
        ),
      ),
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

  Widget _buildUserSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainer, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAnPK5sf3toF6jRhlHSSSJ_5GE2LPH3b1yijfOIp5i6TEEeUP5KSRXfev9SofWZKeFXP1bE8otSGeILKlzwrBu4-XkGQHZn80FrAVch-DUJ_X0rEF-UVNTEl5_G4Um4_DfIAV_k6f8Z49xKl7hLHBhCM5Y1pmJ1H8z1r8mDeN2GUgP6qh_Vq-LiywgTT_V3NBLpxDyn9qON4ng6LqKA6J3dTviPgP-PVRXfJorEgyLH3LTaYxL6AXiXYD9zzkSmVVFi1CpC7GbxvQ',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Alex Johnson',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'alex.j@kampus.id',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.person,
            title: 'Edit Profil',
            trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
            onTap: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          _buildSettingsItem(
            icon: Icons.info,
            title: 'Tentang DoItNow',
            trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          _buildSettingsItem(
            icon: Icons.notifications,
            title: 'Notifikasi',
            trailing: Switch(
              value: _isNotificationEnabled,
              onChanged: (val) {
                setState(() {
                  _isNotificationEnabled = val;
                });
              },
              activeColor: AppColors.primary,
            ),
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          _buildSettingsItem(
            icon: Icons.dark_mode,
            title: 'Mode Gelap',
            trailing: Switch(
              value: _isDarkModeEnabled,
              onChanged: (val) {
                setState(() {
                  _isDarkModeEnabled = val;
                });
              },
              activeColor: AppColors.primary,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // Handle logout
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, size: 24),
            label: Text(
              'LogOut',
              style: AppTextStyles.titleLg.copyWith(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Versi 2.4.0 (Academic Build)',
          style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
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
              onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            _buildNavItem(
              icon: Icons.calendar_month,
              label: 'Calendar',
              isActive: false,
              onTap: () => Navigator.pushReplacementNamed(context, '/calendar'),
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              icon: Icons.inventory_2,
              label: 'Archive',
              isActive: false,
              onTap: () => Navigator.pushReplacementNamed(context, '/archive'),
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isActive: true,
              onTap: () {},
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
              color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
