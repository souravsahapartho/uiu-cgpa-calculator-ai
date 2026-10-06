import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../models/course.dart';

class UIUBottomSheet {
  static void showGradingScale(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.radiusXl),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: AppRadius.borderFull,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UIU Grading Policy',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Official grading scale for undergraduate programs',
                            style: AppTypography.bodySmall.copyWith(
                              color: textSec,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: textPri),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primarySubtle,
                      borderRadius: AppRadius.borderBase,
                      border: Border.all(color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '4.00 Scale. Passing grade is D (1.00). Repeat & retake policies per UIU regulations.',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? Colors.white : AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: UIUGradingScale.scale.length,
                      separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
                      itemBuilder: (context, index) {
                        final item = UIUGradingScale.scale[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: AppRadius.borderMd,
                                ),
                                child: Text(
                                  item.letterGrade,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: item.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Grade Point: ${item.gradePoint.toStringAsFixed(2)}',
                                      style: AppTypography.labelLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: textPri,
                                      ),
                                    ),
                                    Text(
                                      'Marks: ${item.marksRange}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: textSec,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: Text(
                                  item.remarks,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: item.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D1616) : const Color(0xFFFEF2F2),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.4 : 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACADEMIC PROBATION POLICY (UIU REGULATION)',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'A student whose Term GPA is less than 2.00 for two consecutive trimesters/semesters or whose cumulative CGPA falls below 2.00 will be placed on Academic Probation. A maximum of 3 probations are permitted before dismissal under UIU Academic Regulations.',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : const Color(0xFF7F1D1D),
                                  fontSize: 11,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showCourseDetails(BuildContext context, Course course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.radiusXl),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    course.code,
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w900, color: textPri),
                  ),
                  if (course.grade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Text(
                        'Grade ${course.grade}',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.success),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                course.title,
                style: AppTypography.titleLarge.copyWith(color: textPri),
              ),
              const SizedBox(height: 12),
              Text(
                'Credits: ${course.credit.toStringAsFixed(1)} • Category: ${course.category.name.toUpperCase()}',
                style: AppTypography.bodyMedium.copyWith(color: textSec),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static void showConvocationHonors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.radiusXl),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: AppRadius.borderFull,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'UIU Academic Honors',
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: textPri,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Convocation Academic Honors & Eligibility Criteria',
                              style: AppTypography.bodySmall.copyWith(color: textSec),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: textSec),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildHonorTile(
                          icon: Icons.military_tech_rounded,
                          title: 'Chancellor\'s Gold Medal',
                          subtitle: 'Top Academic Distinction',
                          cgpa: 'Batch Topper • Highest CGPA',
                          rule: 'Awarded to the student with the highest graduating CGPA in Undergraduate program (and separate for Graduate). Having a 4.00 does not guarantee it unless you are batch topper.',
                          badge: 'Batch Topper',
                          badgeColor: const Color(0xFFD97706),
                          surface: surface,
                          borderColor: borderColor,
                          textPri: textPri,
                          textSec: textSec,
                        ),
                        const SizedBox(height: 12),
                        _buildHonorTile(
                          icon: Icons.stars_rounded,
                          title: 'Summa Cum Laude',
                          subtitle: 'Highest Academic Honor',
                          cgpa: 'CGPA 3.95 – 4.00',
                          rule: 'Mandatory Condition: Strictly NO course retake allowed. Any course retake automatically disqualifies from Summa Cum Laude.',
                          badge: 'Strictly No Retake',
                          badgeColor: const Color(0xFF8B5CF6),
                          surface: surface,
                          borderColor: borderColor,
                          textPri: textPri,
                          textSec: textSec,
                          highlightCondition: true,
                        ),
                        const SizedBox(height: 12),
                        _buildHonorTile(
                          icon: Icons.verified_rounded,
                          title: 'Magna Cum Laude',
                          subtitle: 'Great Academic Honor',
                          cgpa: 'CGPA 3.85 – 3.94',
                          rule: 'Eligible even with course retakes as long as the CGPA criterion is satisfied.',
                          badge: 'Retake Allowed',
                          badgeColor: const Color(0xFF2563EB),
                          surface: surface,
                          borderColor: borderColor,
                          textPri: textPri,
                          textSec: textSec,
                        ),
                        const SizedBox(height: 12),
                        _buildHonorTile(
                          icon: Icons.emoji_events_rounded,
                          title: 'Cum Laude',
                          subtitle: 'Academic Distinction',
                          cgpa: 'CGPA 3.75 – 3.84',
                          rule: 'Eligible even with course retakes as long as the CGPA criterion is satisfied.',
                          badge: 'Retake Allowed',
                          badgeColor: const Color(0xFF059669),
                          surface: surface,
                          borderColor: borderColor,
                          textPri: textPri,
                          textSec: textSec,
                        ),
                        const SizedBox(height: 12),
                        _buildHonorTile(
                          icon: Icons.campaign_rounded,
                          title: 'Valedictorian (Convocation Speaker)',
                          subtitle: 'Convocation Distinction',
                          cgpa: 'Top Graduating Academic Rank',
                          rule: 'Delivers the farewell address at official convocation. Selected among top graduates based on academic excellence, co-curricular profile, and committee recommendation. (Official criterion could not be verified: no isolated CGPA formula published).',
                          badge: 'Official criterion could not be verified',
                          badgeColor: const Color(0xFF64748B),
                          surface: surface,
                          borderColor: borderColor,
                          textPri: textPri,
                          textSec: textSec,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primarySubtle,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Official UIU Academic Distinction Rules',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: isDark ? Colors.white : AppColors.primaryDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _noteBullet('Verification Status: Gold Medal, Summa Cum Laude, Magna Cum Laude, and Cum Laude are officially verified UIU convocation criteria.', isDark),
                              _noteBullet('Precedence hierarchy: Gold Medal > Summa Cum Laude > Magna Cum Laude > Cum Laude.', isDark),
                              _noteBullet('Under UIU regulations, retaking any course strictly disqualifies a student from Summa Cum Laude, but Magna Cum Laude and Cum Laude remain achievable.', isDark),
                              _noteBullet('Academic Probation Regulation: Two consecutive terms with GPA < 2.00 or cumulative CGPA < 2.00 places student on Academic Probation.', isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _noteBullet(String text, [bool isDark = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHonorTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String cgpa,
    required String rule,
    required String badge,
    required Color badgeColor,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    bool highlightCondition = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(icon, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textPri,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: textSec,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              cgpa,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rule,
            style: AppTypography.bodySmall.copyWith(
              color: highlightCondition ? AppColors.danger : textSec,
              fontWeight: highlightCondition ? FontWeight.w700 : FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

typedef UIUBottomSheets = UIUBottomSheet;
