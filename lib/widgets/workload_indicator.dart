import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WorkloadIndicator extends StatelessWidget {
  final double totalCredits;
  final int courseCount;
  final int labCount;

  const WorkloadIndicator({
    super.key,
    required this.totalCredits,
    required this.courseCount,
    required this.labCount,
  });

  String get workloadLevel {
    if (totalCredits <= 9) return 'Light Load';
    if (totalCredits <= 12) return 'Balanced Load (Recommended)';
    if (totalCredits <= 14) return 'Heavy Workload';
    return 'Overloaded (Requires Approval)';
  }

  Color get workloadColor {
    if (totalCredits <= 9) return AppColors.info;
    if (totalCredits <= 12) return AppColors.success;
    if (totalCredits <= 14) return AppColors.warning;
    return AppColors.error;
  }

  double get progressRatio => (totalCredits / 16.0).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: workloadColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: workloadColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.speed_rounded,
                    size: 20,
                    color: workloadColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    workloadLevel,
                    style: AppTypography.labelLarge.copyWith(
                      color: workloadColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${totalCredits.toStringAsFixed(1)} Credits',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(workloadColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$courseCount Courses ($labCount Practical Labs)',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'UIU Trimester Limit: 15.0 Cr',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

