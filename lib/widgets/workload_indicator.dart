import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';

class WorkloadIndicator extends StatelessWidget {
  final double? totalCredits;
  final int? courseCount;
  final int? labCount;
  final double? theoryCredits;
  final double? labCredits;
  final String? workloadIndex;
  final double? cgpa;

  const WorkloadIndicator({
    super.key,
    this.totalCredits,
    this.courseCount,
    this.labCount,
    this.theoryCredits,
    this.labCredits,
    this.workloadIndex,
    this.cgpa,
  });

  /// Official UIU Credit Capacity by CGPA Policy:
  /// - 3.00 to 4.00: 16 Credits max
  /// - 2.50 to 3.00: 14 Credits max
  /// - 2.00 to 2.49: 12 Credits max
  /// - Below 2.00: 10 Credits max
  static double getUIUCreditCap(double currentCGPA) {
    if (currentCGPA >= 3.00) return 16.0;
    if (currentCGPA >= 2.50) return 14.0;
    if (currentCGPA >= 2.00) return 12.0;
    return 10.0;
  }

  static String getUIUCapTier(double currentCGPA) {
    if (currentCGPA >= 3.00) return '3.00 - 4.00 (Max 16 Cr)';
    if (currentCGPA >= 2.50) return '2.50 - 2.99 (Max 14 Cr)';
    if (currentCGPA >= 2.00) return '2.00 - 2.49 (Max 12 Cr)';
    return '< 2.00 (Max 10 Cr)';
  }

  double get maxAllowedCap => getUIUCreditCap(cgpa ?? 3.50);

  double get effectiveTotalCredits =>
      totalCredits ?? ((theoryCredits ?? 9.0) + (labCredits ?? 2.0));

  String get workloadLevel {
    if (workloadIndex != null) return workloadIndex!;
    final cap = maxAllowedCap;
    if (effectiveTotalCredits > cap) return 'Exceeds UIU Cap (Approval Needed)';
    if (effectiveTotalCredits == cap) return 'Maximum Capacity Utilized';
    if (effectiveTotalCredits >= 12.0 && (cgpa ?? 0.0) >= 3.50) return 'Optimal Scholarship Load';
    if (effectiveTotalCredits >= 12.0) return 'Regular Full Load';
    if (effectiveTotalCredits >= 10.0) return 'Balanced Load';
    if (effectiveTotalCredits >= 7.0) return 'Moderate Load';
    return 'Light Workload';
  }

  Color get workloadColor {
    final cap = maxAllowedCap;
    if (effectiveTotalCredits > cap) return AppColors.danger;
    if (effectiveTotalCredits == cap) return const Color(0xFF0284C7);
    if (effectiveTotalCredits >= 12.0 && (cgpa ?? 0.0) >= 3.50) return const Color(0xFF10B981);
    if (effectiveTotalCredits >= 10.0) return AppColors.success;
    if (effectiveTotalCredits >= 7.0) return AppColors.warning;
    return AppColors.info;
  }

  double get progressRatio => (effectiveTotalCredits / maxAllowedCap).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final trackColor = isDark ? AppColors.darkSection : AppColors.section;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: workloadColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  Icons.speed_rounded,
                  size: 18,
                  color: workloadColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workloadLevel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: workloadColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      'AI Recommended Distribution',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSec,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: workloadColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: workloadColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '${effectiveTotalCredits.toStringAsFixed(1)} Cr',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: workloadColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadius.borderFull,
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(workloadColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  theoryCredits != null && labCredits != null
                      ? '${theoryCredits!.toStringAsFixed(theoryCredits! % 1 == 0 ? 0 : 1)} Theory Cr + ${labCredits!.toStringAsFixed(labCredits! % 1 == 0 ? 0 : 1)} Lab Cr'
                      : '${courseCount ?? 4} Courses (${labCount ?? 1} Labs)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textSec,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'UIU Cap: ${maxAllowedCap.toInt()}.0 Cr',
                style: AppTypography.bodySmall.copyWith(
                  color: textSec.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
