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
    if (effectiveTotalCredits <= 12) return 'Balanced Load';
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
                      ? '${theoryCredits!.toInt()} Theory Cr + ${labCredits!.toInt()} Lab Cr'
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
                'UIU Cap: 15.0 Cr',
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
