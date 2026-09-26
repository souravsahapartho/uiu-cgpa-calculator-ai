import 'package:flutter/material.dart';
import '../models/semester_transcript.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import 'course_card.dart';

class SemesterAccordion extends StatefulWidget {
  final SemesterTranscript semester;
  final bool isInitiallyExpanded;
  final VoidCallback? onDelete;

  const SemesterAccordion({
    super.key,
    required this.semester,
    this.isInitiallyExpanded = false,
    this.onDelete,
  });

  @override
  State<SemesterAccordion> createState() => _SemesterAccordionState();
}

class _SemesterAccordionState extends State<SemesterAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.67) return AppColors.success;
    if (gpa >= 3.00) return AppColors.primary;
    if (gpa >= 2.50) return AppColors.accent;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final gpaColor = _getGPAColor(widget.semester.gpa);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: _isExpanded ? AppColors.primary.withValues(alpha: 0.4) : borderColor,
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: _isExpanded ? AppShadows.card : AppShadows.soft,
      ),
      child: Column(
        children: [
          // Header Tile
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: AppRadius.borderLg,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  // Trimester Icon Indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  // Semester Title & Credits
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semester.semesterName,
                          style: AppTypography.titleLarge.copyWith(
                            color: textPri,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.semester.courses.length} Courses • ${widget.semester.creditsEarned.toStringAsFixed(1)} Credits',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSec,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trimester GPA Badge (UIU calls it GPA, cumulative is CGPA)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: gpaColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(color: gpaColor.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'GPA ${widget.semester.gpa.toStringAsFixed(2)}',
                          style: AppTypography.labelLarge.copyWith(
                            color: gpaColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'CGPA ${widget.semester.cgpa.toStringAsFixed(2)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSec,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onDelete != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete Trimester',
                    ),
                  ],
                  const SizedBox(width: AppSpacing.s4),
                  // Animated Chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: textSec,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Course List
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s12),
              child: Column(
                children: [
                  Divider(color: borderColor, height: 16),
                  ...widget.semester.courses.map((course) => CourseCard(
                    course: course,
                    compact: true,
                  )),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
