import 'package:flutter/material.dart';
import '../data/uiu_mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/custom_charts.dart';
import '../widgets/uiu_header.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semesters = UIUMockData.transcriptSemesters;
    final student = UIUMockData.student;

    final gradeCounts = <String, int>{
      'A': 18,
      'A-': 8,
      'B+': 5,
      'B': 2,
      'B-': 0,
      'C+': 0,
      'F': 0,
    };

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SubtleBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: UIUHeader(
                  title: 'Academic Analytics',
                  subtitle: 'Historical Performance & Trajectory',
                  showBack: true,
                ),
              ),

              // CGPA Progression Trend Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CGPA PROGRESSION TREND',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Highest: 3.83',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GPATrendLineChart(semesters: semesters, height: 190),
                    ],
                  ),
                ),
              ),

              // Grade Distribution Bar Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LETTER GRADE DISTRIBUTION',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '33 Total Courses',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GradeDistributionChart(distribution: gradeCounts, height: 170),
                    ],
                  ),
                ),
              ),

              // Degree Credit Completion Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 40),
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
                          'DEGREE COMPLETION PACE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${student.completedCredits.toInt()} / ${student.totalDegreeCredits.toInt()} Credits',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${((student.completedCredits / student.totalDegreeCredits) * 100).toStringAsFixed(1)}%',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: AppRadius.borderFull,
                          child: LinearProgressIndicator(
                            value: student.completedCredits / student.totalDegreeCredits,
                            minHeight: 10,
                            backgroundColor: AppColors.section,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'On track for graduation in Summer 2025 at current pace of ~11.0 credits/trimester.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
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
