import 'package:flutter/material.dart';
import '../data/uiu_mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/uiu_header.dart';
import '../widgets/uiu_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = UIUMockData.student;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              const SliverToBoxAdapter(
                child: UIUHeader(
                  title: 'Student Profile',
                  subtitle: 'Academic Identity & Local Settings',
                ),
              ),

              // Large Avatar & Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.primary,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          student.name,
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${student.studentId} • Batch ${student.batch}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.section,
                            borderRadius: AppRadius.borderFull,
                          ),
                          child: Text(
                            student.department,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mini stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProfileStat('Current CGPA', student.currentCGPA.toStringAsFixed(2), AppColors.primary),
                            Container(width: 1, height: 24, color: AppColors.border),
                            _buildProfileStat('Credits Done', '${student.completedCredits.toInt()} Cr', AppColors.success),
                            Container(width: 1, height: 24, color: AppColors.border),
                            _buildProfileStat('Target CGPA', student.targetCGPA.toStringAsFixed(2), AppColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Achievement Badges
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    'ACADEMIC ACHIEVEMENTS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBadgeCard(
                          icon: Icons.emoji_events_rounded,
                          title: "Dean's List",
                          subtitle: '4 Trimesters',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildBadgeCard(
                          icon: Icons.code_rounded,
                          title: 'Code Master',
                          subtitle: '4.00 in all labs',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildBadgeCard(
                          icon: Icons.speed_rounded,
                          title: 'Fast Track',
                          subtitle: 'Top 5% batch',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Settings & Shortcuts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    'SETTINGS & PREFERENCES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 90),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSettingItem(
                      icon: Icons.policy_rounded,
                      title: 'UIU Official Grading Scale',
                      subtitle: 'View letter grades, marks, and grade points',
                      onTap: () => UIUBottomSheet.showGradingScale(context),
                    ),
                    _buildSettingItem(
                      icon: Icons.sync_rounded,
                      title: 'Data Storage Status',
                      subtitle: 'Progress is saved locally on your device',
                      trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    ),
                    _buildSettingItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About UIU CGPA Calculator AI',
                      subtitle: 'Version 1.0.0 • United International University',
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 9,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.section,
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
      ),
    );
  }
}
