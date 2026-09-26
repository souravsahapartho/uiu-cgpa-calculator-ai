import 'package:flutter/material.dart';
import '../models/semester_transcript.dart';
import '../theme/app_colors.dart';
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

class _SemesterAccordionState extends State<SemesterAccordion> with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.67) return const Color(0xFF10B981);
    if (gpa >= 3.00) return const Color(0xFF2563EB);
    if (gpa >= 2.50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  (Color, Color, IconData) _getSeasonTheme(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('spring')) {
      return (const Color(0xFF059669), const Color(0xFF10B981), Icons.spa_rounded);
    } else if (lower.contains('summer')) {
      return (const Color(0xFFD97706), const Color(0xFFF59E0B), Icons.wb_sunny_rounded);
    } else if (lower.contains('fall')) {
      return (const Color(0xFF7C3AED), const Color(0xFF8B5CF6), Icons.auto_stories_rounded);
    }
    return (const Color(0xFF2563EB), const Color(0xFF3B82F6), Icons.school_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionBg = isDark ? AppColors.darkSection : AppColors.section;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final gpaColor = _getGPAColor(widget.semester.gpa);
    final (themeStart, themeEnd, seasonIcon) = _getSeasonTheme(widget.semester.semesterName);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? themeStart.withValues(alpha: 0.5) : borderColor,
          width: _isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: themeStart.withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Top Accent Bar (Glows with season color when expanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 3.5 : 0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeStart, themeEnd],
                ),
              ),
            ),

            // Header Tile
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Animated Season Icon Box
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeStart.withValues(alpha: _isExpanded ? 0.25 : 0.12),
                              themeEnd.withValues(alpha: _isExpanded ? 0.15 : 0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeStart.withValues(alpha: _isExpanded ? 0.4 : 0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          seasonIcon,
                          color: themeStart,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Trimester Name & Course / Credit Pills
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.semester.semesterName,
                              style: AppTypography.titleLarge.copyWith(
                                color: textPri,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sectionBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${widget.semester.courses.length} Courses',
                                    style: TextStyle(
                                      color: textSec,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sectionBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${widget.semester.creditsEarned.toStringAsFixed(1)} Cr',
                                    style: TextStyle(
                                      color: textSec,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // GPA & CGPA Column Badges
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: gpaColor.withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: gpaColor.withValues(alpha: 0.35), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'GPA ',
                                  style: TextStyle(
                                    color: gpaColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9.5,
                                  ),
                                ),
                                Text(
                                  widget.semester.gpa.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: gpaColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'CGPA ${widget.semester.cgpa.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: textSec,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.danger),
                          onPressed: widget.onDelete,
                          tooltip: 'Delete Trimester',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],

                      // Animated Expand Chevron
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: textSec,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Expanded Section
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  // Term Summary Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sectionBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem('TERM SGPA', widget.semester.gpa.toStringAsFixed(2), gpaColor, textSec),
                        Container(width: 1, height: 22, color: borderColor),
                        _metricItem('CUMULATIVE CGPA', widget.semester.cgpa.toStringAsFixed(2), textPri, textSec),
                        Container(width: 1, height: 22, color: borderColor),
                        _metricItem('CREDITS', '${widget.semester.creditsEarned.toStringAsFixed(1)} Cr', textPri, textSec),
                      ],
                    ),
                  ),

                  // Courses List
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                    child: Column(
                      children: [
                        ...widget.semester.courses.map(
                          (course) => CourseCard(
                            course: course,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricItem(String label, String value, Color valColor, Color labelColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: valColor,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: labelColor,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
