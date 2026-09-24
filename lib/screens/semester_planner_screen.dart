import 'package:flutter/material.dart';
import '../data/uiu_mock_data.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/subtle_background.dart';
import '../widgets/course_card.dart';
import '../widgets/uiu_header.dart';
import '../widgets/workload_indicator.dart';

class SemesterPlannerScreen extends StatefulWidget {
  const SemesterPlannerScreen({super.key});

  @override
  State<SemesterPlannerScreen> createState() => _SemesterPlannerScreenState();
}

class _SemesterPlannerScreenState extends State<SemesterPlannerScreen> {
  final List<Course> _plannedCourses = [
    const Course(code: 'CSE 4325', title: 'Microprocessors & Microcontrollers', credit: 3.0, category: CourseCategory.core, difficulty: CourseDifficulty.hard),
    const Course(code: 'CSE 4326', title: 'Microprocessors Lab', credit: 1.0, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
    const Course(code: 'CSE 4889', title: 'Machine Learning', credit: 3.0, category: CourseCategory.elective, difficulty: CourseDifficulty.hard),
    const Course(code: 'CSE 4890', title: 'Machine Learning Lab', credit: 1.0, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
    const Course(code: 'ENG 1013', title: 'English Language Skills II', credit: 3.0, category: CourseCategory.ged, difficulty: CourseDifficulty.easy),
  ];

  double get _totalPlannedCredits => _plannedCourses.fold(0.0, (sum, c) => sum + c.credit);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SubtleBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: UIUHeader(
                  title: 'Semester Planner',
                  subtitle: 'Spring 2024 Planning • ${_totalPlannedCredits.toStringAsFixed(1)} Credits',
                  showBack: true,
                ),
              ),

              // Workload Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: WorkloadIndicator(
                    theoryCredits: 9.0,
                    labCredits: 2.0,
                    workloadIndex: 'Balanced & Recommended',
                  ),
                ),
              ),

              // Planned Courses List Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PLANNED COURSES (${_plannedCourses.length})',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Total: ${_totalPlannedCredits.toInt()} Cr',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Planned Course Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = _plannedCourses[index];
                      return CourseCard(course: course);
                    },
                    childCount: _plannedCourses.length,
                  ),
                ),
              ),

              // Available Upcoming Electives
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    'AVAILABLE UPCOMING ELECTIVES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = UIUMockData.availableUpcomingCourses[index];
                      return CourseCard(course: course);
                    },
                    childCount: UIUMockData.availableUpcomingCourses.length,
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
