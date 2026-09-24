import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../models/course.dart';

class UIUBottomSheet {
  static void showGradingScale(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
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
                        color: AppColors.border,
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
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Official grading scale for undergraduate programs',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: AppRadius.borderBase,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.primaryDark, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '4.00 Scale. Passing grade is D (1.00). Retake allowed for grades <= B.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primaryDark,
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
                      separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
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
                                  color: item.color.withValues(alpha: 0.12),
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
                                      ),
                                    ),
                                    Text(
                                      'Marks: ${item.marksRange}',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.1),
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showCourseDetails(BuildContext context, Course course) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w900),
                  ),
                  if (course.grade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
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
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Credits: ${course.credit.toStringAsFixed(1)} • Category: ${course.category.name.toUpperCase()}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

typedef UIUBottomSheets = UIUBottomSheet;
