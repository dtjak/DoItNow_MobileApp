import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'Tentang DoItNow',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandIdentitySection(),
            const SizedBox(height: 32),
            _buildFeaturesSection(),
            const SizedBox(height: 32),
            _buildVisualAssetSection(),
            const SizedBox(height: 32),
            _buildContactSection(),
            const SizedBox(height: 32),
            _buildFooterInfo(),
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

  Widget _buildBrandIdentitySection() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.check_circle, color: Colors.white, size: 64),
        ),
        const SizedBox(height: 16),
        Text(
          'DoItNow',
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'Versi 2.4.0',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.outline),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Asisten produktivitas cerdas yang dirancang khusus untuk membantu mahasiswa mengelola waktu, tugas, dan target akademik dengan presisi.',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur Utama',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.task_alt,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryContainer.withOpacity(0.1),
          title: 'Manajemen Tugas',
          description:
              'Sistem prioritas pintar untuk tugas kuliah harian Anda.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.calendar_month,
          iconColor: AppColors.tertiary,
          iconBgColor: AppColors.tertiaryContainer.withOpacity(0.1),
          title: 'Kalender Akademik',
          description: 'Sinkronisasi jadwal ujian dan tenggat waktu praktikum.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.archive,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.secondaryContainer.withOpacity(0.1),
          title: 'Arsip Pintar',
          description:
              'Simpan dan cari kembali materi kuliah yang telah selesai.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualAssetSection() {
    return Container(
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCdjnkdDbWmoiPWMuLfqanAiu4N2V-zhduTDwrzt_gcToAKv1DV1UINWFNIhwQCtfGZb7SFPbByvXu1fprR3pEAIzcHmxi1Ehcqqe7uVz_CkL4HKiM0a8l2mcOzHhzYuOuQ91I2ayXQmvdlWPSUTiYR2pgDwQHI-a7dSut8AL-B3oVaqPqQIIGRfxlqT8zoo3Cz4PWlZtTuS5Xl3KTmu0IXA1Kj4k77PDcoA_ERqGT_Uea3a1mUDA7VebnE-7LJAU1QzgoiRaB_tw',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Text(
          '"Dibuat untuk Ambisi Mahasiswa Modern"',
          style: AppTextStyles.labelLg.copyWith(
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hubungi Kami',
          style: AppTextStyles.titleLg.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildContactChip(icon: Icons.mail, label: 'Email'),
            _buildContactChip(icon: Icons.language, label: 'Website'),
            _buildContactChip(icon: Icons.share, label: 'Instagram'),
          ],
        ),
      ],
    );
  }

  Widget _buildContactChip({required IconData icon, required String label}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Text(
          '© 2024 DoItNow Productivity Labs',
          style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Privacy Policy',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Text(
              'Terms of Service',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
            ),
          ],
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
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              color: isActive
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
