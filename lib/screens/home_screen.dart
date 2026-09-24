import 'package:flutter/material.dart';
import '../data/uiu_mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/stat_card.dart';
import '../widgets/course_card.dart';
import '../widgets/uiu_bottom_sheet.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _quickCurrentCGPA = 3.78;
  double _quickTargetCGPA = 3.85;
  double _quickCompletedCredits = 76.0;
  double _quickRemainingCredits = 62.0;

  double get _quickRequiredSGPA {
    final total = _quickCompletedCredits + _quickRemainingCredits;
    final reqPoints = (_quickTargetCGPA * total) - (_quickCurrentCGPA * _quickCompletedCredits);
    return _quickRemainingCredits > 0 ? (reqPoints / _quickRemainingCredits) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final student = UIUMockData.student;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // TOP GREETING BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '👋 Welcome back, ',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Thursday, Sep 24',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student.name,
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Policy / Scale Info Button
                          IconButton(
                            onPressed: () => UIUBottomSheet.showGradingScale(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Analytics Shortcut Button
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // QUICK STATS (4 compact cards height around 110, responsive 2 col mobile / 4 col tablet)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    mainAxisSpacing: AppSpacing.s12,
                    crossAxisSpacing: AppSpacing.s12,
                    mainAxisExtent: 108,
                  ),
                  delegate: SliverChildListDelegate([
                    StatCard(
                      title: 'Current CGPA',
                      value: student.currentCGPA.toStringAsFixed(2),
                      subtitle: 'UIU Scale: 4.00 Max',
                      icon: Icons.school_rounded,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Credits Done',
                      value: '${student.completedCredits.toInt()} / ${student.totalDegreeCredits.toInt()}',
                      subtitle: '${((student.completedCredits / student.totalDegreeCredits) * 100).toInt()}% Degree Progress',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                    ),
                    StatCard(
                      title: 'Target CGPA',
                      value: student.targetCGPA.toStringAsFixed(2),
                      subtitle: 'Req SGPA: ${_quickRequiredSGPA.toStringAsFixed(2)}',
                      icon: Icons.track_changes_rounded,
                      iconColor: AppColors.accent,
                    ),
                    StatCard(
                      title: 'Trimester Streak',
                      value: '7 Semesters',
                      subtitle: 'Honors List Standing',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFEA580C),
                    ),
                  ]),
                ),
              ),

              // TODAY'S SCHEDULE & STUDY GOALS SECTION
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TODAY AT UIU',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active Day',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTodayItem(
                                icon: Icons.schedule_rounded,
                                title: 'Next Class',
                                value: 'CSE 4325 • 2:00 PM',
                                iconColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTodayItem(
                                icon: Icons.timer_rounded,
                                title: 'Focus Time',
                                value: '140 Min Goal',
                                iconColor: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // QUICK GPA PREDICTOR WIDGET
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'QUICK GPA TARGET PREDICTOR',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Icon(Icons.auto_graph_rounded, color: AppColors.accent, size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.section,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Required SGPA / Trimester',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _quickRequiredSGPA.toStringAsFixed(2),
                                    style: AppTypography.displayMedium.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: _quickRequiredSGPA <= 4.0 ? AppColors.primary : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (_quickRequiredSGPA <= 4.0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                                  borderRadius: AppRadius.borderMd,
                                ),
                                child: Text(
                                  _quickRequiredSGPA <= 3.30
                                      ? 'Easily Attainable'
                                      : _quickRequiredSGPA <= 3.75
                                          ? 'Challenging'
                                          : _quickRequiredSGPA <= 4.0
                                              ? 'Extremely Demanding'
                                              : 'Impossible (>4.00)',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: _quickRequiredSGPA <= 4.0 ? AppColors.success : AppColors.danger,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
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

              // RECENT TRANSCRIPT COURSES
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECENT TRIMESTER COURSES',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Fall 2023',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Course Cards List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final latestSemester = UIUMockData.transcriptSemesters.last;
                      final course = latestSemester.courses[index];
                      return CourseCard(course: course);
                    },
                    childCount: UIUMockData.transcriptSemesters.last.courses.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.section,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
