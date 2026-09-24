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

  const WorkloadIndicator({
    super.key,
    this.totalCredits,
    this.courseCount,
    this.labCount,
    this.theoryCredits,
    this.labCredits,
    this.workloadIndex,
  });

  double get effectiveTotalCredits =>
      totalCredits ?? ((theoryCredits ?? 9.0) + (labCredits ?? 2.0));

  String get workloadLevel {
    if (workloadIndex != null) return workloadIndex!;
    if (effectiveTotalCredits <= 9) return 'Light Workload';
    if (effectiveTotalCredits <= 12) return 'Balanced Load (Recommended)';
    if (effectiveTotalCredits <= 14) return 'Heavy Workload';
    return 'Overloaded (Requires Approval)';
  }

  Color get workloadColor {
    if (effectiveTotalCredits <= 9) return AppColors.info;
    if (effectiveTotalCredits <= 12) return AppColors.success;
    if (effectiveTotalCredits <= 14) return AppColors.warning;
    return AppColors.danger;
  }

  double get progressRatio => (effectiveTotalCredits / 15.0).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: workloadColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Icon(
                      Icons.speed_rounded,
                      size: 18,
                      color: workloadColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    workloadLevel,
                    style: AppTypography.titleMedium.copyWith(
                      color: workloadColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                '${effectiveTotalCredits.toStringAsFixed(1)} Credits',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: AppRadius.borderFull,
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: AppColors.section,
              valueColor: AlwaysStoppedAnimation<Color>(workloadColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                theoryCredits != null && labCredits != null
                    ? '${theoryCredits!.toInt()} Theory Cr + ${labCredits!.toInt()} Lab Cr'
                    : '${courseCount ?? 4} Courses (${labCount ?? 1} Labs)',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'UIU Limit: 15.0 Cr',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
