import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool showCategory;
  final bool compact;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showCategory = true,
    this.compact = false,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isPressed = false;

  Color _getGradeColor(String? grade) {
    if (grade == null) return AppColors.textSecondary;
    if (grade.startsWith('A')) return AppColors.success;
    if (grade.startsWith('B')) return AppColors.secondary;
    if (grade.startsWith('C')) return AppColors.accent;
    if (grade.startsWith('D')) return const Color(0xFFEA580C);
    return AppColors.danger;
  }

  Color _getCategoryColor(CourseCategory category) {
    switch (category) {
      case CourseCategory.core:
        return AppColors.primary;
      case CourseCategory.lab:
        return AppColors.secondary;
      case CourseCategory.math:
        return const Color(0xFF7C3AED);
      case CourseCategory.ged:
        return const Color(0xFF0D9488);
      case CourseCategory.elective:
        return AppColors.accent;
      case CourseCategory.physics:
        return const Color(0xFFDB2777);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor(widget.course.grade);
    final catColor = _getCategoryColor(widget.course.category);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s8),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderBase,
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              // Course Code Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: catColor.withValues(alpha: 0.15), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.course.code,
                      style: AppTypography.labelLarge.copyWith(
                        color: catColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.course.credit.toStringAsFixed(1)} Cr',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              // Course Title & Category Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.showCategory) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.section,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.course.category.name.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (widget.course.gradePoint != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '•  Point: ${widget.course.gradePoint!.toStringAsFixed(2)}',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              // Letter Grade Chip
              if (widget.course.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: gradeColor.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Text(
                    widget.course.grade!,
                    style: AppTypography.titleLarge.copyWith(
                      color: gradeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
