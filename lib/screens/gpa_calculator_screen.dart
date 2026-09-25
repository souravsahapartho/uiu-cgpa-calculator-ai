import 'package:flutter/material.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/gpa_progress_ring.dart';
import '../widgets/uiu_header.dart';
import '../widgets/uiu_bottom_sheet.dart';

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  State<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  // Target Planner state
  double _currentCGPA = 3.78;
  double _completedCredits = 76.0;
  double _targetCGPA = 3.85;
  double _remainingCredits = 62.0;

  // Trimester Simulator state
  final List<Course> _currentSemesterCourses = [
    const Course(code: 'CSE 4325', title: 'Microprocessors', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core),
    const Course(code: 'CSE 4326', title: 'Microprocessors Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab),
    const Course(code: 'CSE 4889', title: 'Machine Learning', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.elective),
    const Course(code: 'ENG 1013', title: 'Professional English', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.ged),
  ];

  double get _calculatedTrimesterSGPA {
    double totalPoints = 0;
    double totalCredits = 0;
    for (final c in _currentSemesterCourses) {
      if (c.gradePoint != null) {
        totalPoints += (c.gradePoint! * c.credit);
        totalCredits += c.credit;
      }
    }
    return totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
  }

  double get _requiredSGPAForTarget {
    final totalCredits = _completedCredits + _remainingCredits;
    final reqPoints = (_targetCGPA * totalCredits) - (_currentCGPA * _completedCredits);
    return _remainingCredits > 0 ? (reqPoints / _remainingCredits) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: UIUHeader(
                  title: 'GPA Intelligence',
                  subtitle: 'Target Planner & Trimester Simulator',
                  trailing: IconButton(
                    onPressed: () => UIUBottomSheet.showGradingScale(context),
                    icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  ),
                ),
              ),

              // Hero Circular Progress Ring Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      children: [
                        GPAProgressRing(
                          currentGPA: _currentCGPA,
                          maxGPA: 4.00,
                          targetGPA: _targetCGPA,
                          size: 175,
                          label: 'Current Standing',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniSummary(
                              title: 'Completed',
                              value: '${_completedCredits.toInt()} Cr',
                              color: AppColors.primary,
                            ),
                            Container(width: 1, height: 28, color: AppColors.border),
                            _buildMiniSummary(
                              title: 'Target CGPA',
                              value: _targetCGPA.toStringAsFixed(2),
                              color: AppColors.accent,
                            ),
                            Container(width: 1, height: 28, color: AppColors.border),
                            _buildMiniSummary(
                              title: 'Remaining',
                              value: '${_remainingCredits.toInt()} Cr',
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Required GPA Highlight Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: AppSpacing.edgeInsetsCard,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primarySubtle,
                          AppColors.secondarySubtle,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.borderMd,
                            boxShadow: AppShadows.primary,
                          ),
                          child: const Icon(Icons.stars_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Required Average GPA',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _requiredSGPAForTarget.toStringAsFixed(2),
                                style: AppTypography.displayLarge.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: _requiredSGPAForTarget <= 4.0 ? AppColors.primary : AppColors.danger,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                _requiredSGPAForTarget <= 3.30
                                    ? 'Easily Attainable • Maintain B+ Average'
                                    : _requiredSGPAForTarget <= 3.75
                                        ? 'Challenging • Aim for A- & A Grades'
                                        : _requiredSGPAForTarget <= 4.00
                                            ? 'Demanding • Near Straight 4.00s'
                                            : 'Impossible (>4.00 Max Limit)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: _requiredSGPAForTarget <= 4.0 ? AppColors.success : AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Interactive Target Sliders Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: AppSpacing.edgeInsetsCard,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADJUST TARGET PARAMETERS',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSlider(
                          label: 'Target CGPA',
                          value: _targetCGPA,
                          min: 2.0,
                          max: 4.0,
                          divisions: 200,
                          onChanged: (val) => setState(() => _targetCGPA = val),
                        ),
                        const SizedBox(height: 8),
                        _buildSlider(
                          label: 'Remaining Credits',
                          value: _remainingCredits,
                          min: 3.0,
                          max: 138.0,
                          divisions: 135,
                          isInteger: true,
                          onChanged: (val) => setState(() => _remainingCredits = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Trimester Simulator Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURRENT TRIMESTER SIMULATOR',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Text(
                          'Estimated Trimester GPA: ${_calculatedTrimesterSGPA.toStringAsFixed(2)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Current Semester Simulated Courses
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = _currentSemesterCourses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.section,
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Center(
                                child: Text(
                                  '${course.credit.toInt()} Cr',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.code,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    course.title,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Grade Selector Dropdown
                            DropdownButton<String>(
                              value: course.grade,
                              underline: const SizedBox(),
                              borderRadius: AppRadius.borderLg,
                              items: UIUGradingScale.scale.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item.letterGrade,
                                  child: Text(
                                    '${item.letterGrade} (${item.gradePoint.toStringAsFixed(2)})',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: item.color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newGrade) {
                                if (newGrade != null) {
                                  final match = UIUGradingScale.scale.firstWhere((e) => e.letterGrade == newGrade);
                                  setState(() {
                                    _currentSemesterCourses[index] = course.copyWith(
                                      grade: match.letterGrade,
                                      gradePoint: match.gradePoint,
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _currentSemesterCourses.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniSummary({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    bool isInteger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.section,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                isInteger ? '${value.toInt()} Credits' : value.toStringAsFixed(2),
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
