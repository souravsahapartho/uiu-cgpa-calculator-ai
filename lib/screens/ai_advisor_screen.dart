import 'package:flutter/material.dart';
import '../main.dart';
import '../models/course.dart';
import '../models/ai_recommendation.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../core/providers/user_profile_provider.dart';
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

    final isNewStudent = completedCredits == 0;
    final standingText = isNewStudent
        ? 'New Student Track'
        : displayCGPA >= 3.80
            ? 'Top 5% Standing'
            : displayCGPA >= 3.50
                ? 'Dean\'s Honor Pace'
                : displayCGPA >= 3.00
                    ? 'Strong Academic Standing'
                    : 'Target Improvement Track';

    // Identify ongoing course keys across all semesters
    final ongoingCourseKeys = <String>{};
    for (final sem in provider.semesters) {
      for (final course in sem.courses) {
        if (course.isOngoing || sem.isOngoing) {
          ongoingCourseKeys.add(UserProfileProvider.getCourseKey(course));
        }
      }
    }

    // Identify retake candidate courses from transcript (excluding ongoing courses, tracking best attempt)
    final latestBestAttempts = <String, Course>{};
    for (final sem in provider.semesters) {
      for (final course in sem.courses) {
        if (course.isOngoing || sem.isOngoing) continue;
        final key = UserProfileProvider.getCourseKey(course);
        final gp = course.gradePoint ?? (course.grade != null ? UIUGradingScale.getGradePoint(course.grade!) : 0.0);
        if (!latestBestAttempts.containsKey(key) || gp > (latestBestAttempts[key]!.gradePoint ?? 0.0)) {
          latestBestAttempts[key] = course;
        }
      }
    }

    final candidateRetakes = <Course>[];
    for (final entry in latestBestAttempts.entries) {
      final key = entry.key;
      final course = entry.value;
      // Skip if course is currently enrolled in ongoing trimester
      if (ongoingCourseKeys.contains(key)) continue;

      final gp = course.gradePoint ?? (course.grade != null ? UIUGradingScale.getGradePoint(course.grade!) : 0.0);
      final grade = (course.grade ?? '').toUpperCase().trim();
      if (grade.isNotEmpty && grade != 'W' && (gp < 2.67 || grade == 'F' || grade == 'D' || grade == 'D+' || grade == 'C-')) {
        candidateRetakes.add(course);
      }
    }

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
              // Fixed Top Navigation Header
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
                          isNewStudent
                              ? 'Welcome to UIU! As a 1st trimester student, focus on building a solid academic foundation. Attending all quizzes and securing 26+ out of 30 in Midterms will lock in an immediate Dean\'s Honor pace.'
                              : 'Student Summary: Based on your completed ${completedCredits.toStringAsFixed(1)} credits and current CGPA of ${displayCGPA.toStringAsFixed(2)}, to reach your goal of ${targetCGPA.toStringAsFixed(2)} CGPA across your remaining ${remainingCredits.toInt()} credits, you need an average SGPA of ${requiredPace.toStringAsFixed(2)} per trimester.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 3 Hero Metrics with strict equal height
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildHeroMetricCard(
                                  label: 'Current CGPA',
                                  value: isNewStudent ? 'New Student' : '${displayCGPA.toStringAsFixed(2)} CGPA',
                                  icon: Icons.trending_up_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildHeroMetricCard(
                                  label: 'Target Goal',
                                  value: '${targetCGPA.toStringAsFixed(2)} CGPA',
                                  icon: Icons.flag_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildHeroMetricCard(
                                  label: 'Rec. Load',
                                  value: '${report.suggestedCreditLoad.toInt()} Credits',
                                  icon: Icons.balance_rounded,
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

              // UIU AI Strategic Advisor Consultations (Deep interactive scenarios & actionable Q&A)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s8),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_rounded, size: 18, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'AI ACADEMIC ADVISOR CONSULTATION',
                          style: AppTypography.labelSmall.copyWith(
                            color: textSec,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          isNewStudent ? 'Newbie Track' : 'Personalized',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Consultation Q&A Panels (100% Dynamic & Personalized)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 6),
                  child: Column(
                    children: _buildDynamicConsultationItems(
                      isNewStudent: isNewStudent,
                      displayCGPA: displayCGPA,
                      targetCGPA: targetCGPA,
                      completedCredits: completedCredits,
                      remainingCredits: remainingCredits,
                      totalCredits: totalCredits,
                      requiredPace: requiredPace,
                      candidateRetakes: candidateRetakes,
                      surface: surface,
                      borderClr: borderClr,
                      textPri: textPri,
                      textSec: textSec,
                      report: report,
                    ),
                  ),
                ),
              ),

              // Subject Domain Strength Breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DOMAIN STRENGTH & APTITUDE',
                        style: AppTypography.labelSmall.copyWith(
                          color: textSec,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (report.domainAnalyses.isNotEmpty)
                        Text(
                          '${report.domainAnalyses.length} Domains Evaluated',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (report.domainAnalyses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(14),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderMd,
                            ),
                            child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Awaiting Course Grade History',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                    color: textPri,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'No completed courses found in your transcript yet. Once you add or import your courses in the Transcript tab, your real domain strengths (Programming, Mathematics, Hardware & Systems) will dynamically generate here without any dummy data.',
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
                    ),
                  ),
                )
              else
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

              // Course Conflict Warning Section (Only shown if conflicts exist)
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
                    cgpa: displayCGPA,
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.95)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
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

  Widget _buildAdvisorExpandableCard({
    required IconData icon,
    required Color accentColor,
    required String question,
    required String summary,
    required String detailedAnswer,
    required Color surface,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderClr),
        boxShadow: AppShadows.soft,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          title: Text(
            question,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: textPri,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              summary,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: textSec,
                height: 1.3,
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: accentColor.withValues(alpha: 0.18)),
              ),
              child: _buildFormattedAdvisorContent(detailedAnswer, textPri, textSec),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedAdvisorContent(String rawText, Color textPri, Color textSec) {
    final lines = rawText.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      final isBullet = trimmed.startsWith('•') || trimmed.startsWith('-');
      final contentText = isBullet ? trimmed.substring(1).trim() : trimmed;

      final spans = <InlineSpan>[];
      final regex = RegExp(r'\*\*(.*?)\*\*');
      int lastMatchEnd = 0;

      for (final match in regex.allMatches(contentText)) {
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(
            text: contentText.substring(lastMatchEnd, match.start),
            style: TextStyle(
              color: textPri,
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: textPri,
            fontSize: 11.5,
            height: 1.45,
            fontWeight: FontWeight.w800,
          ),
        ));
        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < contentText.length) {
        spans.add(TextSpan(
          text: contentText.substring(lastMatchEnd),
          style: TextStyle(
            color: textPri,
            fontSize: 11.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ));
      }

      if (isBullet) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5.5, right: 6),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: spans),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: RichText(
              text: TextSpan(children: spans),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _buildDynamicConsultationItems({
    required bool isNewStudent,
    required double displayCGPA,
    required double targetCGPA,
    required double completedCredits,
    required double remainingCredits,
    required double totalCredits,
    required double requiredPace,
    required List<Course> candidateRetakes,
    required Color surface,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
    required AIAdvisorReport report,
  }) {
    final items = <Widget>[];

    // Card 1: Target Goal & Mathematical Pathway (Personalized for every student)
    if (isNewStudent) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.trending_up_rounded,
        accentColor: const Color(0xFF0284C7),
        question: 'How do I secure an immediate 3.80+ CGPA starting from Trimester 1?',
        summary: 'Focus on continuous assessment: scoring 26+ in Midterms locks your course pace.',
        detailedAnswer:
            'Welcome to UIU! As a 1st trimester student:\n\n'
            '• **Continuous Marks are King**: 30% Midterm + 30% Class Tests/Quizzes/Assignments = 60% of your total grade is finalized before the Final Exam (40%).\n'
            '• **Target 26+ out of 30 in Midterms**: Securing high Midterm scores completely removes stressful cutoff anxiety before finals.\n'
            '• **Never Skip a Quiz**: Even a 0.5 difference in continuous assessments can push a grade from B+ to A-.\n'
            '• **Foundation Prerequisites**: Trimester 1 courses like Fundamental Calculus (MATH 1151) and Intro to CS (CSE 1110) unlock essential 2nd and 3rd trimester sequences.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    } else {
      final achievable = requiredPace <= 4.0;
      final pointsEarned = completedCredits * displayCGPA;
      final pointsNeeded = totalCredits * targetCGPA;
      final pointsRemaining = (pointsNeeded - pointsEarned).clamp(0.0, 999.0);

      items.add(_buildAdvisorExpandableCard(
        icon: Icons.trending_up_rounded,
        accentColor: const Color(0xFF0284C7),
        question: 'How can I mathematically reach my goal of ${targetCGPA.toStringAsFixed(2)} CGPA?',
        summary: achievable
            ? 'Maintain an average SGPA of ${requiredPace.toStringAsFixed(2)} over your remaining ${remainingCredits.toInt()} credits.'
            : 'Goal requires SGPA > 4.00. Consider strategic course retakes to unlock cumulative grade points!',
        detailedAnswer:
            'Based on your official UIU Academic Transcript:\n\n'
            '• **Current Completed**: ${completedCredits.toStringAsFixed(1)} credits at ${displayCGPA.toStringAsFixed(2)} CGPA (${pointsEarned.toStringAsFixed(1)} earned Grade Points).\n'
            '• **Target Goal**: ${targetCGPA.toStringAsFixed(2)} CGPA across ${totalCredits.toInt()} total degree credits requires ${pointsNeeded.toStringAsFixed(1)} total points (${pointsRemaining.toStringAsFixed(1)} points remaining).\n'
            '• **Mathematical Requirement**: Over your remaining ${remainingCredits.toInt()} credits, you need an average SGPA of **${requiredPace.toStringAsFixed(2)}**.\n'
            '• **Advisor Recommendation**: ' +
            (achievable
                ? 'Register for ${(report.suggestedCreditLoad).toInt()} credits per trimester. Focus on 3-credit core theory courses where you have strong domain foundations to consistently secure A (3.67) and A (4.00) grades.'
                : 'Since the remaining credits alone cannot bridge the gap to ${targetCGPA.toStringAsFixed(2)}, retaking low-grade courses (such as D or C) is your best mathematical option, as replacing a low grade adds instant net grade points without needing extra credits!'),
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    }

    items.add(const SizedBox(height: 8));

    // Card 2: Deeply Personalized Retake Advice
    if (isNewStudent) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.replay_rounded,
        accentColor: const Color(0xFF10B981),
        question: 'How does UIU handle retakes, and do I need to worry about retakes now?',
        summary: 'As a new student, you have 0 retakes! Focus on passing all courses on your first attempt.',
        detailedAnswer:
            'UIU Retake Policy Overview for New Students:\n\n'
            '• **Current Status**: You are in your 1st Trimester with no previous grades on your transcript. No retakes needed!\n'
            '• **50% Retake Tuition Discount**: UIU offers a 50% flat credit tuition reduction if a student ever needs to retake an attempted course for the first time.\n'
            '• **Grade Replacement Rule**: UIU completely replaces lower grades with the highest achieved grade in your cumulative CGPA. However, clearing all subjects with A/A- on your first try saves both time and tuition costs!',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    } else if (candidateRetakes.isNotEmpty) {
      final retakeLines = candidateRetakes.take(4).map((c) {
        final gp = c.gradePoint ?? 0.0;
        final grade = c.grade ?? 'D';
        return '• **${c.code}** (${c.title}): Current Grade **$grade** (${gp.toStringAsFixed(2)} GP). Retaking and scoring A (3.67) adds **+${((3.67 - gp) * c.credit).toStringAsFixed(2)} net points**!';
      }).join('\n');

      items.add(_buildAdvisorExpandableCard(
        icon: Icons.warning_amber_rounded,
        accentColor: const Color(0xFFDC2626),
        question: 'Should I retake any course? (Recommended: ${candidateRetakes.length} Courses Found)',
        summary: 'Yes! Retaking ${candidateRetakes.first.code} (${candidateRetakes.first.grade ?? 'low grade'}) will immediately boost your CGPA.',
        detailedAnswer:
            'UIU Academic Advisor Retake Analysis:\n\n'
            'We analyzed your transcript and detected **${candidateRetakes.length} course(s)** with low grades (below B- / 2.67 GP):\n\n'
            '$retakeLines\n\n'
            '• **Why Retake Now**: In UIU cumulative CGPA, your highest grade completely replaces the previous grade. Retaking these gives you the fastest mathematical boost to your CGPA.\n'
            '• **Tuition Benefit**: You qualify for a **50% tuition reduction** on credit rates for your 1st retake attempt.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    } else {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.check_circle_outline_rounded,
        accentColor: const Color(0xFF10B981),
        question: 'Should I retake any course? (Transcript Status: Clean)',
        summary: 'No retakes required! All your completed courses maintain high academic standing (≥ B-).',
        detailedAnswer:
            'Excellent academic record:\n\n'
            '• **No Low Grades Detected**: None of your completed courses have D or F grades. Your entire transcript is clean with solid passing grades.\n'
            '• **Advisor Recommendation**: Do NOT spend credits or tuition on retakes. Focus 100% of your energy on enrolling in regular curriculum progression and higher-level electives.\n'
            '• **UIU Policy Note**: If you ever choose to improve a B- grade in the future, remember that UIU allows retakes with a 50% discount on credit tuition, but given your current trajectory, advancing forward is the best choice.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    }

    items.add(const SizedBox(height: 8));

    // Card 3: Workload & Theory vs Lab Coupling
    items.add(_buildAdvisorExpandableCard(
      icon: Icons.device_hub_rounded,
      accentColor: const Color(0xFF7C3AED),
      question: 'What is the optimal course & lab combination for this trimester?',
      summary: 'Take maximum 1-2 heavy labs per trimester paired with balanced theory subjects.',
      detailedAnswer:
          'To protect your trimester GPA from excessive assignment and project burnout:\n\n'
          '• **The 2-Lab Golden Rule**: Never take more than two heavy 1.0-credit laboratory courses (such as OS Lab, Microprocessors Lab, or Computer Networks Lab) in the same trimester.\n'
          '• **Recommended Course Structure**: Take **2 Heavy Core Theory** courses + **1 Heavy/Medium Lab** + **1 General Education (GED) / Math** course. This maintains 10 to 13 credits without exhausting your weekly submission deadlines.\n'
          '• **Prerequisite Sequence Integrity**: Always clear prerequisites (e.g. SPL before DSA, DSA before OOP & Algorithms II) so you never get blocked from registering higher-level major courses.',
      surface: surface,
      borderClr: borderClr,
      textPri: textPri,
      textSec: textSec,
    ));

    items.add(const SizedBox(height: 8));

    // Card 4: Honors, Dean\'s List & Scholarships (Dynamic by student CGPA)
    if (displayCGPA >= 3.50 || isNewStudent) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.military_tech_rounded,
        accentColor: const Color(0xFFEAB308),
        question: 'What are the criteria for Dean\'s List, Distinction & Tuition Waivers?',
        summary: 'Minimum 9 completed credits in trimester + SGPA ≥ 3.50 with no incomplete or F grades.',
        detailedAnswer:
            'Official UIU Academic Distinction & Honor requirements:\n\n'
            '• **Dean\'s List Eligibility**: Requires completing at least 9 or more regular credits in the trimester with an SGPA of **3.50 or higher** with no grade below B- and no Incomplete (I) or Fail (F).\n'
            '• **Academic Distinction at Convocation**:\n'
            '   - *Summa Cum Laude*: CGPA 3.90 – 4.00\n'
            '   - *Magna Cum Laude*: CGPA 3.80 – 3.89\n'
            '   - *Cum Laude*: CGPA 3.65 – 3.79\n'
            '• **Tuition Fee Waivers**: UIU awards merit waivers (25% to 100%) to top performers based on trimester SGPA provided the minimum registered credit threshold (usually 9–12 credits) is maintained without retakes in that session.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    } else {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.shield_rounded,
        accentColor: const Color(0xFFE65100),
        question: 'How do I avoid academic probation and qualify for Dean\'s List?',
        summary: 'Keep cumulative CGPA strictly above 2.00 to avoid probation; aim for SGPA ≥ 3.50 for honors.',
        detailedAnswer:
            'UIU Academic Standing Rules:\n\n'
            '• **Academic Probation Warning**: At UIU, if a student\'s CGPA falls below **2.00**, they are placed on Academic Probation. You must bring it back above 2.00 within two trimesters.\n'
            '• **Dean\'s List Recovery Pathway**: To qualify for Dean\'s List in upcoming trimesters, you need at least 9 registered credits with an SGPA of **3.50 or higher** and zero F/I grades.\n'
            '• **Key Recovery Strategy**: Balance your schedule by registering for 9–10 credits including at least 1 manageable General Education course to guarantee high term GPAs and rebuild your standing.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
    }

    items.add(const SizedBox(height: 8));

    // Card 5: Withdrawal (W) vs Incomplete (I) Deadlines
    items.add(_buildAdvisorExpandableCard(
      icon: Icons.warning_amber_rounded,
      accentColor: const Color(0xFFD97706),
      question: 'What if an emergency happens? Withdrawal (W) vs Incomplete (I)',
      summary: 'Withdraw before Week 10 with zero GPA impact. Avoid unapproved Incompletes.',
      detailedAnswer:
          'Understanding the safety mechanisms when emergencies or illness occur:\n\n'
          '• **Course Withdrawal (W)**: If you face unavoidable medical or personal issues, apply for formal Course Withdrawal (W) through UCAM before the Week 10 deadline. A "W" has **ZERO effect** on your SGPA or CGPA.\n'
          '• **Incomplete (I)**: An Incomplete requires formal departmental chair approval for extreme medical emergencies right before finals. You must sit for the exam in the subsequent trimester, or the system defaults the course grade to an **F (0.00)**.\n'
          '• **Always Consult Your Departmental Advisor**: If you fall sick before midterms or finals, notify your advisor immediately with medical documentation to avoid unauthorized dropouts.',
      surface: surface,
      borderClr: borderClr,
      textPri: textPri,
      textSec: textSec,
    ));

    return items;
  }
}
