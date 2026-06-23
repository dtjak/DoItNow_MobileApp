import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;

  String _name = 'Loading...';
  String _email = 'Loading...';
  String? _photoUrl;
  String _phone = '';
  String _bio = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            setState(() {
              _name = data['name'] ?? '';
              _email = data['email'] ?? '';
              _photoUrl = data['photo_url'];
              _phone = data['phone'] ?? '';
              _bio = data['bio'] ?? '';
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  border: Border.all(
                    color: AppColors.surfaceContainer,
                    width: 4,
                  ),
                  color: AppColors.surfaceContainerHighest,
                ),
                child: _photoUrl != null && _photoUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          _photoUrl!,
                          fit: BoxFit.cover,
                          width: 96,
                          height: 96,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.outline,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(context, '/edit_profile');
                    _loadUserProfile();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (_phone.isNotEmpty || _bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            if (_phone.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.outline),
                  const SizedBox(width: 8),
                  Text(
                    _phone,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            if (_phone.isNotEmpty && _bio.isNotEmpty) const SizedBox(height: 8),
            if (_bio.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _bio,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
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
            onTap: () async {
              await Navigator.pushNamed(context, '/edit_profile');
              _loadUserProfile();
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
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurface,
                ),
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
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
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
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
              ),
              _buildNavItem(
                icon: Icons.calendar_month,
                label: 'Calendar',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/calendar'),
              ),
              _buildAddNavItem(context),
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
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNavItem(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/add_task'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
