import 'package:flutter/material.dart';
import '../main.dart';
import '../core/services/academic_advisor_engine.dart';
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
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('AI Advisor updated with your official UIU curriculum & transcript metrics.'),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ProfileProviderScope.of(context);
    final profile = provider.profile;
    final report = AcademicAdvisorEngine.generateReport(
      profile: profile,
      semesters: provider.semesters,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionBg = isDark ? AppColors.darkSection : AppColors.section;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final transcriptMetrics = provider.getTranscriptCumulativeMetrics();
    final hasTranscript = provider.semesters.isNotEmpty && transcriptMetrics['credits']! > 0;

    final displayCGPA = hasTranscript ? transcriptMetrics['cgpa']! : profile.currentCGPA;
    final completedCredits = hasTranscript ? transcriptMetrics['credits']! : profile.completedCredits;
    final targetCGPA = profile.targetCGPA > 0 ? profile.targetCGPA : 3.75;
    final totalCredits = profile.totalDegreeCredits > 0 ? profile.totalDegreeCredits : 138.0;
    final remainingCredits = (totalCredits - completedCredits).clamp(0.0, totalCredits);

    // Calculate required GPA for remaining credits to reach target
    double requiredPace = 3.75;
    if (remainingCredits > 0 && totalCredits > 0) {
      final totalTargetPoints = targetCGPA * totalCredits;
      final currentPoints = displayCGPA * completedCredits;
      requiredPace = ((totalTargetPoints - currentPoints) / remainingCredits).clamp(2.0, 4.0);
    }

    final standingText = displayCGPA >= 3.80
        ? 'Top 5% Standing'
        : displayCGPA >= 3.50
            ? 'Dean\'s Honor Pace'
            : displayCGPA >= 3.00
                ? 'Strong Academic Standing'
                : 'Target Improvement Track';

    double theoryCredits = 0.0;
    double labCredits = 0.0;
    for (final rec in report.recommendedCourses) {
      if (rec.course.isLab) {
        labCredits += rec.course.credit;
      } else {
        theoryCredits += rec.course.credit;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Pinned Top Header / Navbar
              UIUHeader(
                title: 'AI Academic Advisor',
                subtitle: 'Intelligent Course Pathways & Performance Insights',
                trailing: IconButton(
                  onPressed: _triggerAIAnalysis,
                  tooltip: 'Refresh AI Insights',
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.refresh_rounded, color: AppColors.primary),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Hero Overview Card (Responsive, dynamic gradients and metrics)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          Color(0xFFE65100),
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
                        // Responsive Header Row: Wrapped to guarantee no overflow on narrow screens
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 5),
                                  Text(
                                    'ACADEMIC PROFILE ANALYSIS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.5,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: AppRadius.borderFull,
                              ),
                              child: Text(
                                standingText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Student Summary: Showing strong consistency across Core Requirements & Systems. To reach your goal of ${targetCGPA.toStringAsFixed(2)} CGPA across your remaining ${remainingCredits.toInt()} credits, you need an average SGPA of ${requiredPace.toStringAsFixed(2)} per trimester with an optimal balance of theory and lab credits.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 3 Hero Metrics
                        Row(
                          children: [
                            Expanded(
                              child: _buildHeroMetricCard(
                                label: 'Current Pace',
                                value: '${displayCGPA.toStringAsFixed(2)} CGPA',
                                icon: Icons.trending_up_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildHeroMetricCard(
                                label: 'Target / Pace',
                                value: '${targetCGPA.toStringAsFixed(2)} CGPA',
                                icon: Icons.flag_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildHeroMetricCard(
                                label: 'Recommended',
                                value: '${report.suggestedCreditLoad.toInt()} Credits',
                                icon: Icons.balance_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // UIU AI Strategic Success Playbook (Actionable Student-friendly Rules)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s4),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'AI STRATEGIC ADVICE FOR UIU STUDENTS',
                        style: AppTypography.labelSmall.copyWith(
                          color: textSec,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Strategic Guidance Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 6),
                  child: Column(
                    children: [
                      _buildAdviceCard(
                        icon: Icons.quiz_rounded,
                        accentColor: const Color(0xFF0284C7),
                        title: '1. UIU Midterm & Continuous Assessment Formula',
                        description:
                            'Under UIU marks distribution, Midterm accounts for 30%, Class Tests/Quizzes/Assignments account for 20-30%, and Final exam is 40%. Always secure 26+ out of 30 in Midterms and attend all quizzes. This locks in an A/A- trajectory well before final exam pressure.',
                        surface: surface,
                        borderClr: borderClr,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const SizedBox(height: 8),
                      _buildAdviceCard(
                        icon: Icons.replay_rounded,
                        accentColor: const Color(0xFF10B981),
                        title: '2. Retake Discount & Grade Replacement Benefit',
                        description:
                            'Retaking any previously taken course costs 50% tuition on your 1st retake (or with applicable waiver). More importantly, in UIU cumulative CGPA calculation, your highest grade replaces the old grade entirely. Retaking a D or F is the quickest mathematical lever to boost your overall CGPA.',
                        surface: surface,
                        borderClr: borderClr,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const SizedBox(height: 8),
                      _buildAdviceCard(
                        icon: Icons.device_hub_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        title: '3. Lab Coupling & Workload Balancing',
                        description:
                            'Never take more than two heavy 1.0-credit labs (such as OS Lab, Microprocessors Lab, or Networks Lab) in a single trimester. Pair 2 hard theory courses with 1 lab and 1 light General Education (GED) course to safeguard your trimester GPA from burning out.',
                        surface: surface,
                        borderClr: borderClr,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const SizedBox(height: 8),
                      _buildAdviceCard(
                        icon: Icons.warning_amber_rounded,
                        accentColor: const Color(0xFFD97706),
                        title: '4. Withdrawal (W) vs Incomplete (I) Policy',
                        description:
                            'If unavoidable circumstances arise before Week 10, officially apply for Withdrawal (W) — it will not impact your GPA, CGPA, or credit tally. Do NOT leave a course Incomplete (I) unless pre-approved, as UIU calculates uncompleted courses as 0.00 grade point (Fail).',
                        surface: surface,
                        borderClr: borderClr,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                    ],
                  ),
                ),
              ),

              // Subject Domain Strength Breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    'DOMAIN STRENGTH & APTITUDE',
                    style: AppTypography.labelSmall.copyWith(
                      color: textSec,
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
                          color: surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: borderClr),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        domain.isStrength ? Icons.check_circle_rounded : Icons.info_rounded,
                                        size: 16,
                                        color: domain.isStrength ? AppColors.success : AppColors.accent,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          domain.domain,
                                          style: AppTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.5,
                                            color: textPri,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: (domain.isStrength ? AppColors.success : AppColors.accent).withValues(alpha: 0.12),
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
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: AppRadius.borderFull,
                              child: LinearProgressIndicator(
                                value: domain.scorePercent / 100.0,
                                minHeight: 6,
                                backgroundColor: sectionBg,
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
                                color: textSec,
                                height: 1.35,
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
                      color: textSec,
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
                          color: surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: borderClr),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
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
                                          color: textPri,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: sectionBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${rec.course.credit.toInt()} Credits',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: textSec,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rec.course.title,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: textPri,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    rec.reason,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 10.5,
                                      color: textSec,
                                      height: 1.35,
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

              // Course Conflict Warning Section (Only display if conflicts actually exist)
              if (report.conflictWarnings.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D1616) : AppColors.dangerLight,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: AppColors.danger.withValues(alpha: isDark ? 0.4 : 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Courses to Avoid Taking Together',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: isDark ? const Color(0xFFFCA5A5) : AppColors.dangerDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
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
                                color: isDark ? const Color(0xFFFCA5A5).withValues(alpha: 0.9) : AppColors.dangerDark,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s4, AppSpacing.s16, 40),
                  child: WorkloadIndicator(
                    theoryCredits: theoryCredits > 0 ? theoryCredits : 8.0,
                    labCredits: labCredits > 0 ? labCredits : 2.0,
                    totalCredits: report.suggestedCreditLoad > 0 ? report.suggestedCreditLoad : (theoryCredits + labCredits),
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
);
  }

  Widget _buildHeroMetricCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
    required Color surface,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderClr),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: textSec,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
