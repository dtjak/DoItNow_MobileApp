import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
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
                    label: 'Kampus',
                    backgroundColor: AppColors.primaryFixedDim,
                    textColor: AppColors.onPrimaryFixedVariant,
                  ),
                  _buildChip(
                    label: 'High Priority',
                    backgroundColor: AppColors.errorContainer,
                    textColor: AppColors.onErrorContainer,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Revisi Jurnal Metodologi',
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
                    'Deadline: 25 Okt, 12:00',
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
                'Melakukan revisi pada bagian metodologi penelitian berdasarkan masukan dari dosen pembimbing. Perhatikan detail instrumen pengumpulan data dan validitas sampling yang sebelumnya dianggap kurang kuat.',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Action Complete Task
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
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Action Edit Task
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
                      onPressed: () {
                        // Action Delete Task
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
