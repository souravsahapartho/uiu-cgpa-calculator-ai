import 'package:flutter/material.dart';
import '../data/uiu_mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/uiu_header.dart';
import '../widgets/workload_indicator.dart';

class AIAdvisorScreen extends StatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  State<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends State<AIAdvisorScreen> {
  bool _isRefreshing = false;

  void _triggerAIAnalysis() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Advisor Analysis updated with latest UIU dataset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = UIUMockData.aiReport;

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
                  title: 'AI Academic Advisor',
                  subtitle: 'Intelligent Course Pathways & Performance Insights',
                  trailing: IconButton(
                    onPressed: _triggerAIAnalysis,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  ),
                ),
              ),

              // Hero Overview Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: AppSpacing.edgeInsetsCard,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.borderXl,
                      boxShadow: AppShadows.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ACADEMIC PROFILE ANALYSIS',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Top 5% Batch Standing',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          report.overallSummary,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeroMetric('Current Pace', '${report.currentPaceCGPA.toStringAsFixed(2)} CGPA'),
                            _buildHeroMetric('Projected Final', '${report.projectedFinalCGPA.toStringAsFixed(2)} CGPA'),
                            _buildHeroMetric('Optimal Load', '${report.suggestedCreditLoad.toInt()} Credits'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Subject Domain Strength Breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    'DOMAIN STRENGTH & APTITUDE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Domain Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final domain = report.domainAnalyses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      domain.isStrength ? Icons.check_circle_rounded : Icons.info_rounded,
                                      size: 16,
                                      color: domain.isStrength ? AppColors.success : AppColors.accent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      domain.domain,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (domain.isStrength ? AppColors.success : AppColors.accent).withValues(alpha: 0.1),
                                    borderRadius: AppRadius.borderFull,
                                  ),
                                  child: Text(
                                    domain.status,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: domain.isStrength ? AppColors.successDark : AppColors.accentDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: AppRadius.borderFull,
                              child: LinearProgressIndicator(
                                value: domain.scorePercent / 100.0,
                                minHeight: 6,
                                backgroundColor: AppColors.section,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  domain.isStrength ? AppColors.primary : AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              domain.insight,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: report.domainAnalyses.length,
                  ),
                ),
              ),

              // Recommended Next Courses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    'AI RECOMMENDED NEXT TRIMESTER COURSES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final rec = report.recommendedCourses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '#${rec.priorityRank}',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rec.course.code,
                                        style: AppTypography.labelLarge.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        '${rec.course.credit.toInt()} Credits',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textTertiary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    rec.course.title,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rec.reason,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: report.recommendedCourses.length,
                  ),
                ),
              ),

              // Course Conflict Warning Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Courses to Avoid Taking Together',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.dangerDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...report.conflictWarnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${warning.conflictingCourses.join(" + ")}: ${warning.explanation}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.dangerDark,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),

              // Workload Balancer
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s4, AppSpacing.s16, 90),
                  child: WorkloadIndicator(
                    theoryCredits: 8.0,
                    labCredits: 3.0,
                    workloadIndex: 'Optimal Balanced Workload',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
