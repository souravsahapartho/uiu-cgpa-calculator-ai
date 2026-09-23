import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../core/constants/uiu_grading_scale.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDraggable;
  final bool showGrade;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.trailing,
    this.isDraggable = false,
    this.showGrade = true,
  });

  Color _getCategoryColor(CourseCategory category) {
    switch (category) {
      case CourseCategory.core:
        return AppColors.navy;
      case CourseCategory.lab:
        return AppColors.primary;
      case CourseCategory.ged:
        return Color(0xFF0284C7);
      case CourseCategory.elective:
        return Color(0xFF8B5CF6);
      case CourseCategory.math:
        return Color(0xFFD97706);
      case CourseCategory.physics:
        return Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = course.grade != null
        ? UIUGradingScale.getGradeColor(course.grade!)
        : AppColors.textTertiary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (isDraggable) ...[
                  const Icon(
                    Icons.drag_indicator_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                // Course Code Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(course.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        course.code,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _getCategoryColor(course.category),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.credit.toStringAsFixed(1)} Cr',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Title and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildMiniBadge(
                            course.categoryName,
                            _getCategoryColor(course.category),
                          ),
                          _buildMiniBadge(
                            course.difficultyName,
                            _getDifficultyColor(course.difficulty),
                          ),
                          if (course.prerequisite != null)
                            _buildMiniBadge(
                              'Pre: ${course.prerequisite!}',
                              AppColors.navyMuted,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (trailing != null)
                  trailing!
                else if (showGrade && course.grade != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gradeColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.grade!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: gradeColor,
                          ),
                        ),
                        Text(
                          course.gradePoint?.toStringAsFixed(2) ?? '0.00',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: gradeColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getDifficultyColor(CourseDifficulty difficulty) {
    switch (difficulty) {
      case CourseDifficulty.easy:
        return AppColors.success;
      case CourseDifficulty.medium:
        return AppColors.secondary;
      case CourseDifficulty.hard:
        return Color(0xFFEA580C);
      case CourseDifficulty.veryHard:
        return AppColors.error;
    }
  }
}

