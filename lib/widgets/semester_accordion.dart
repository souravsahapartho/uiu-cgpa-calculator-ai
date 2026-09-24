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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SemesterAccordion({
    super.key,
    required this.semester,
    this.isInitiallyExpanded = false,
    this.onEdit,
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

  Color _getSGPAColor(double sgpa) {
    if (sgpa >= 3.67) return AppColors.success;
    if (sgpa >= 3.00) return AppColors.primary;
    if (sgpa >= 2.50) return AppColors.accent;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final sgpaColor = _getSGPAColor(widget.semester.sgpa);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: _isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
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
                      color: AppColors.primary.withValues(alpha: 0.08),
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
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.semester.courses.length} Courses • ${widget.semester.creditsEarned.toStringAsFixed(1)} Credits',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SGPA Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: sgpaColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(color: sgpaColor.withValues(alpha: 0.25), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SGPA ${widget.semester.sgpa.toStringAsFixed(2)}',
                          style: AppTypography.labelLarge.copyWith(
                            color: sgpaColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'CGPA ${widget.semester.cgpa.toStringAsFixed(2)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  // Animated Chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.textSecondary,
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
                  const Divider(color: AppColors.border, height: 16),
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
