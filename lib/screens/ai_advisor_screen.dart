import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/course.dart';
import '../models/ai_recommendation.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../core/providers/user_profile_provider.dart';
import '../core/services/academic_advisor_engine.dart';
import '../core/utils/ai_prompt_constants.dart';
import 'main_navigation_screen.dart';
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

    // Identify ongoing courses across all semesters
    final ongoingCourses = <Course>[];
    for (final sem in provider.semesters) {
      for (final course in sem.courses) {
        if (course.isOngoing || sem.isOngoing) {
          ongoingCourses.add(course);
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
    for (final course in latestBestAttempts.values) {
      // Skip if course is currently enrolled in ongoing trimester (matching by code or title)
      if (ongoingCourses.any((o) => AcademicAdvisorEngine.isCourseMatch(o.code, o.title, course.code, course.title))) {
        continue;
      }

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

              // ── Estimated Recommendations Alert (When based on profile credits without transcript) ──
              if (!hasTranscript && report.isEstimatedFromProfileCredits)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF332008) : const Color(0xFFFFF7ED),
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: const Color(0xFFF97316).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA580C),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Course Recommendations',
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? const Color(0xFFFED7AA) : const Color(0xFF9A3412),
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Projected for Trimester ${report.estimatedTrimester} • Based on ${completedCredits.toInt()} Completed Credits',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                        color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'You have entered ${completedCredits.toInt()} completed credits in your profile without importing course history. These courses are projected for Trimester ${report.estimatedTrimester}. To get 100% accurate prerequisite verification, automated retake detection, and clash-free scheduling, please add your transcript in the Transcript tab.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              color: isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => MainNavigationScreen.switchTab(context, 2),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                              ),
                              icon: const Icon(Icons.upload_file_rounded, size: 15),
                              label: const Text(
                                'Add Transcript for 100% Exact Advising',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── AI Prompt Helper for New Users (shown when no transcript courses added) ──
              if (!hasTranscript)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 4, AppSpacing.s16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Prompt: Convert UCAM Result in Seconds',
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: textPri,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Use AI to generate your CSV transcript instantly!',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Copy text or take a screenshot of Grade History from UIU UCAM.\n'
                            '2. Copy prompt below and paste into ChatGPT or Claude with your result.\n'
                            '3. Import the output CSV or text in the Transcript tab!',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSec,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: borderClr),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AIPromptConstants.ucamToCsvPrompt,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      height: 1.3,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(const ClipboardData(text: AIPromptConstants.ucamToCsvPrompt));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'AI Prompt copied! Paste into ChatGPT / Claude with your UCAM result.',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                  ),
                                  icon: const Icon(Icons.copy_rounded, size: 15),
                                  label: const Text(
                                    'Copy AI Prompt',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => MainNavigationScreen.switchTab(context, 2),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                  ),
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primary),
                                  label: const Text(
                                    'Transcript Tab',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Recommended Next Courses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s4),
                  child: Text(
                    report.isEstimatedFromProfileCredits
                        ? 'AI RECOMMENDED NEXT TRIMESTER COURSES (PROJECTED TRIMESTER ${report.estimatedTrimester})'
                        : 'AI RECOMMENDED NEXT TRIMESTER COURSES',
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
                                  if (rec.trackName != null || rec.isChoiceOption) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: rec.isGed
                                            ? const Color(0xFF0284C7).withValues(alpha: 0.12)
                                            : const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: rec.isGed
                                              ? const Color(0xFF0284C7).withValues(alpha: 0.35)
                                              : const Color(0xFF7C3AED).withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            rec.isGed ? Icons.menu_book_rounded : Icons.track_changes_rounded,
                                            size: 11,
                                            color: rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              rec.trackName ?? (rec.isGed ? 'GED Optional Choice' : 'Major Track Choice'),
                                              style: TextStyle(
                                                color: rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 9.5,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rec.course.code,
                                          style: AppTypography.labelLarge.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: textPri,
                                            fontSize: rec.isChoiceOption ? 12.5 : 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: sectionBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          rec.isChoiceOption ? '3 Cr (Pick 1)' : '${rec.course.credit.toInt()} Credits',
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
                                  if (rec.isChoiceOption && rec.choiceDetails.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED)).withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                rec.isGed ? Icons.menu_book_rounded : Icons.track_changes_rounded,
                                                size: 12,
                                                color: rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'CHOOSE 1 OF ${rec.choiceDetails.length} OPTIONS:',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.4,
                                                  color: rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ...rec.choiceDetails.map((opt) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 5),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: (rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED)).withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      opt.code,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w800,
                                                        color: rec.isGed ? const Color(0xFF0284C7) : const Color(0xFF7C3AED),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          opt.title,
                                                          style: AppTypography.bodySmall.copyWith(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 11,
                                                            color: textPri,
                                                          ),
                                                        ),
                                                        if (opt.examDay != 'N/A' && opt.examDay != '----')
                                                          Text(
                                                            'Exam: ${opt.examDay} • Slot ${opt.examSlot}',
                                                            style: TextStyle(
                                                              fontSize: 9.5,
                                                              fontWeight: FontWeight.w600,
                                                              color: textSec,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 5),
                                  ],
                                  // Exam schedule badge & project/lab badges
                                  if (!rec.isChoiceOption && rec.isProject && !rec.course.isLab) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.rocket_launch_rounded, size: 11, color: Color(0xFF8B5CF6)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Capstone Project (Defense • No Written Exam)',
                                            style: TextStyle(
                                              color: Color(0xFF8B5CF6),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ] else if (rec.isProject && rec.course.isLab) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D9488).withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.terminal_rounded, size: 11, color: Color(0xFF0D9488)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Term Project Lab (Continuous • No Written Exam)',
                                            style: TextStyle(
                                              color: Color(0xFF0D9488),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ] else if (!rec.isChoiceOption && rec.hasSameDayExam) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF332008) : const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.5)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFEA580C)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${rec.examDay} • Slot ${rec.examSlot} (2 Exams on this Day!)',
                                                style: const TextStyle(
                                                  color: Color(0xFFEA580C),
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (rec.sameDayWithCourse != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Shares date with: ${rec.sameDayWithCourse}',
                                              style: TextStyle(
                                                color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ] else if (!rec.isChoiceOption && rec.examDay != 'N/A' && rec.examDay != '----') ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.event_available_rounded, size: 11, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Exam: ${rec.examDay} • Slot ${rec.examSlot}',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ] else if (rec.course.isLab) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.science_outlined, size: 11, color: AppColors.secondary),
                                          SizedBox(width: 4),
                                          Text(
                                            'Lab Assessment (No Written Exam)',
                                            style: TextStyle(
                                              color: AppColors.secondaryDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
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

              // Course Conflict & Exam Schedule Warning Section
              if (report.conflictWarnings.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                    child: Column(
                      children: report.conflictWarnings.map((warning) {
                        final isCritical = warning.severity == 'Critical';
                        final isHigh = warning.severity == 'High';
                        
                        final cardBg = isCritical
                            ? (isDark ? const Color(0xFF2D1616) : AppColors.dangerLight)
                            : (isHigh
                                ? (isDark ? const Color(0xFF2E1C0A) : const Color(0xFFFFF7ED))
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)));

                        final alertBorderClr = isCritical
                            ? AppColors.danger.withValues(alpha: isDark ? 0.4 : 0.3)
                            : (isHigh
                                ? const Color(0xFFF97316).withValues(alpha: isDark ? 0.4 : 0.3)
                                : borderClr);

                        final iconClr = isCritical
                            ? AppColors.danger
                            : (isHigh ? const Color(0xFFEA580C) : AppColors.primary);

                        final titleClr = isCritical
                            ? (isDark ? const Color(0xFFFCA5A5) : AppColors.dangerDark)
                            : (isHigh
                                ? (isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C))
                                : textPri);

                        final textClr = isCritical
                            ? (isDark ? const Color(0xFFFCA5A5).withValues(alpha: 0.9) : AppColors.dangerDark)
                            : (isHigh
                                ? (isDark ? const Color(0xFFFED7AA) : const Color(0xFF9A3412))
                                : textSec);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(color: alertBorderClr),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCritical
                                        ? Icons.block_rounded
                                        : (isHigh ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
                                    color: iconClr,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      warning.title,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: titleClr,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                warning.explanation,
                                style: AppTypography.bodySmall.copyWith(
                                  color: textClr,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                              if (warning.recommendation.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  '💡 Advisor Advice: ${warning.recommendation}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: textClr,
                                    fontSize: 10.5,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
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

              // Workload Balancer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s4, AppSpacing.s16, 40),
                  child: WorkloadIndicator(
                    cgpa: displayCGPA,
                    theoryCredits: theoryCredits,
                    labCredits: labCredits,
                    totalCredits: theoryCredits + labCredits,
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
      final isIndented = line.startsWith('  ') || line.startsWith('\t');
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      final isBullet = trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*');
      var contentText = isBullet ? trimmed.substring(1).trim() : trimmed;

      // Match ***bold italic***, **bold**, *italic*, or _italic_
      final spans = <InlineSpan>[];
      final regex = RegExp(r'(\*\*\*(.*?)\*\*\*|\*\*(.*?)\*\*|\*(.*?)\*|_(.*?)_)');
      int lastMatchEnd = 0;

      for (final match in regex.allMatches(contentText)) {
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(
            text: contentText.substring(lastMatchEnd, match.start),
            style: TextStyle(
              color: textPri,
              fontSize: isIndented ? 11.2 : 11.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ));
        }

        final boldItalic = match.group(2);
        final bold = match.group(3);
        final italic = match.group(4) ?? match.group(5);

        if (boldItalic != null) {
          spans.add(TextSpan(
            text: boldItalic,
            style: TextStyle(
              color: textPri,
              fontSize: isIndented ? 11.2 : 11.5,
              height: 1.45,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ));
        } else if (bold != null) {
          spans.add(TextSpan(
            text: bold,
            style: TextStyle(
              color: textPri,
              fontSize: isIndented ? 11.2 : 11.5,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ));
        } else if (italic != null) {
          spans.add(TextSpan(
            text: italic,
            style: TextStyle(
              color: textPri,
              fontSize: isIndented ? 11.2 : 11.5,
              height: 1.45,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ));
        }
        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < contentText.length) {
        spans.add(TextSpan(
          text: contentText.substring(lastMatchEnd),
          style: TextStyle(
            color: textPri,
            fontSize: isIndented ? 11.2 : 11.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ));
      }

      if (isBullet) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              left: isIndented ? 16.0 : 0.0,
              bottom: 4.5,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: isIndented ? 6.0 : 5.5, right: 6),
                  width: isIndented ? 4 : 5,
                  height: isIndented ? 4 : 5,
                  decoration: BoxDecoration(
                    color: isIndented
                        ? AppColors.primary.withValues(alpha: 0.65)
                        : AppColors.primary,
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
            padding: EdgeInsets.only(
              left: isIndented ? 16.0 : 0.0,
              bottom: 4.5,
            ),
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

    final bool isFinalYear = completedCredits >= 85.0 ||
        report.estimatedTrimester >= 10;
    final bool isHighCGPA = displayCGPA >= 3.50;
    final bool isProbationRisk = !isNewStudent && displayCGPA < 2.20;

    // 1. RETAKE ROADMAP (Prioritized if candidate retakes exist)
    if (candidateRetakes.isNotEmpty && !isNewStudent) {
      final retakeLines = candidateRetakes.take(4).map((c) {
        final gp = c.gradePoint ?? 0.0;
        final grade = c.grade ?? 'D';
        return '• **${c.code}** (${c.title}): Current Grade **$grade** (${gp.toStringAsFixed(2)} GP). Retaking and scoring A (3.67) adds **+${((3.67 - gp) * c.credit).toStringAsFixed(2)} net points**!';
      }).join('\n');

      items.add(_buildAdvisorExpandableCard(
        icon: Icons.replay_circle_filled_rounded,
        accentColor: const Color(0xFFDC2626),
        question: 'Should I retake any course? (${candidateRetakes.length} High-Impact Candidates Detected)',
        summary: 'Yes! Retaking ${candidateRetakes.first.code} (${candidateRetakes.first.grade ?? 'low grade'}) will immediately boost your cumulative CGPA.',
        detailedAnswer:
            'UIU Academic Advisor Retake Analysis:\n\n'
            'We analyzed your transcript and detected **${candidateRetakes.length} course(s)** with grades below B- (2.67 GP):\n\n'
            '$retakeLines\n\n'
            '• **Why Retake Now**: Under UIU cumulative CGPA policy, your highest grade completely replaces the previous grade in the calculation. Retaking provides the fastest mathematical leap in CGPA.\n'
            '• **50% Tuition Discount**: You qualify for a **50% tuition reduction** on credit fees for your 1st retake attempt.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
      items.add(const SizedBox(height: 8));
    }

    // 2. FINAL YEAR DESIGN PROJECT (FYDP) CARD (Dedicated for 4th Year / 9+ Trimesters Completed)
    if (isFinalYear) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.rocket_launch_rounded,
        accentColor: const Color(0xFF8B5CF6),
        question: 'When & How do I complete my Final Year Design Project (FYDP)?',
        summary: 'Compulsory 3-part capstone (CSE 4000A, 4000B, 4000C) spread across Trimesters 10, 11 & 12.',
        detailedAnswer:
            'Final Year Design Project (FYDP) Pathway:\n\n'
            '• **Eligibility**: You have completed 85+ credits / 9 trimesters and are in your final year! Enrolling in **CSE 4000A (FYDP-1)** is now mandatory.\n'
            '• **Group Formation**: Form an approved group of 3–4 members with complementary development or research skillsets.\n'
            '• **Faculty Supervisor**: Consult faculty members in week 1 to finalize your supervisor and project proposal defense.\n'
            '• **Zero Written Final Exam**: FYDP grading is entirely based on continuous milestone reviews, progress presentations, and external defense with no conflicting written final exam.\n'
            '• **⚠️ Scholarship Rule**: Project & thesis courses (FYDP) are excluded from the Top 10% merit tuition waiver calculation, so maintain at least 9–12 credits of regular fresh theory courses.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
      items.add(const SizedBox(height: 8));

      // Graduation Degree Clearance
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.school_rounded,
        accentColor: const Color(0xFF059669),
        question: 'Degree Completion & Graduation Clearance: Am I on track to graduate?',
        summary: '${completedCredits.toInt()} credits completed; only ${remainingCredits.toInt()} credits remaining to graduate.',
        detailedAnswer:
            'UIU Degree Clearance Checklist:\n\n'
            '• **Total Degree Requirement**: Minimum ${totalCredits.toInt()} credits required for graduation with CGPA ≥ 2.00.\n'
            '• **5 Specialized Electives**: Ensure you fulfill your 5 elective courses (15 credits) across your chosen major track or open departmental electives.\n'
            '• **3 GED Optional Courses**: Confirm at least 3 GED optional courses (Economics, IPE, AI Literacy, Entrepreneurship) are completed.\n'
            '• **Provisional Clearance**: Submit your graduation clearance request to the Controller of Examinations after defending FYDP-3.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
      items.add(const SizedBox(height: 8));
    }

    // 3. TARGET GOAL & MATHEMATICAL PACE
    if (isNewStudent) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.trending_up_rounded,
        accentColor: const Color(0xFF0284C7),
        question: 'How do I secure an immediate 3.80+ CGPA starting from Trimester 1?',
        summary: 'Focus on continuous assessments: scoring 26+ in Midterms locks your course pace.',
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
      items.add(const SizedBox(height: 8));
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
      items.add(const SizedBox(height: 8));
    }

    // 4. MERIT SCHOLARSHIPS & DEAN'S LIST (Highlighted for High CGPA or Freshmen)
    if (isHighCGPA || isNewStudent) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.military_tech_rounded,
        accentColor: const Color(0xFFEAB308),
        question: 'UIU Tuition Waiver vs Trimester Merit Scholarship: How do they work?',
        summary: 'Waiver maintenance requires CGPA ≥ 3.50; Trimester Merit Scholarship is awarded to the Top 10% students each trimester.',
        detailedAnswer:
            'UIU Tuition Waiver & Scholarship Policies:\n\n'
            '• **Tuition Waiver Maintenance**:\n'
            '  - If you hold an admission/freedom fighter/sibling/special tuition waiver, you must maintain a cumulative **CGPA ≥ 3.50** to retain it each trimester.\n\n'
            '• **Trimester Merit Scholarship (Top 10% Students)**:\n'
            '  - Awarded dynamically each trimester to the highest-performing students in the department:\n'
            '  - **Top 2%**: 100% Tuition Waiver\n'
            '  - **Next 4%**: 50% Tuition Waiver\n'
            '  - **Next 4%**: 25% Tuition Waiver\n'
            '  - **Eligibility**: Minimum **3.50 SGPA** and regular credit completion (12+ fresh credits in undergraduate).\n\n'
            '• **⚠️ Exclusion Rule**: Retake, Repeat, Project (FYDP), Internship, and Thesis courses are EXCLUDED from the merit calculation. Maintain at least 9–12 credits of regular fresh courses to preserve your merit scholarship eligibility!\n\n'
            '• **Convocation Honors**:\n'
            '  - **Summa Cum Laude**: CGPA 3.90 – 4.00\n'
            '  - **Magna Cum Laude**: CGPA 3.80 – 3.89\n'
            '  - **Cum Laude**: CGPA 3.65 – 3.79',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
      items.add(const SizedBox(height: 8));
    } else if (isProbationRisk) {
      items.add(_buildAdvisorExpandableCard(
        icon: Icons.shield_rounded,
        accentColor: const Color(0xFFE65100),
        question: 'How do I avoid academic probation and rebuild my standing?',
        summary: 'Keep cumulative CGPA strictly above 2.00 to avoid probation; balance course load to 9-10 credits.',
        detailedAnswer:
            'UIU Academic Standing Rules:\n\n'
            '• **Academic Probation Warning**: At UIU, if a student\'s CGPA falls below **2.00**, they are placed on Academic Probation. You must bring it back above 2.00 within two trimesters.\n'
            '• **Key Recovery Strategy**: Balance your schedule by registering for 9–10 credits including at least 1 manageable General Education course to guarantee high term GPAs and rebuild your standing.\n'
            '• **Target Retakes**: Prioritize retaking F and D grades to completely replace lower marks with high grade points.',
        surface: surface,
        borderClr: borderClr,
        textPri: textPri,
        textSec: textSec,
      ));
      items.add(const SizedBox(height: 8));
    }

    // 5. WORKLOAD & 2-LAB RULE
    items.add(_buildAdvisorExpandableCard(
      icon: Icons.device_hub_rounded,
      accentColor: const Color(0xFF7C3AED),
      question: 'What is the optimal course & lab combination for this trimester?',
      summary: 'Take maximum 1-2 heavy labs per trimester paired with balanced theory subjects.',
      detailedAnswer:
          'To protect your trimester GPA from excessive assignment and project burnout:\n\n'
          '• **The 2-Lab Golden Rule**: Never take more than two heavy laboratory courses in the same trimester.\n'
          '• **Recommended Course Structure**: Take **3 Theory** courses + **1-2 Labs** (or FYDP for 4th year). This maintains 11 to 14 credits without exhausting your weekly submission deadlines.\n'
          '• **Prerequisite Sequence Integrity**: Always clear prerequisites (e.g. SPL before DSA, DSA before OOP & Algorithms II) so you never get blocked from registering higher-level major courses.',
      surface: surface,
      borderClr: borderClr,
      textPri: textPri,
      textSec: textSec,
    ));
    items.add(const SizedBox(height: 8));

    // 6. EMERGENCY WITHDRAWAL (W) vs INCOMPLETE (I)
    items.add(_buildAdvisorExpandableCard(
      icon: Icons.warning_amber_rounded,
      accentColor: const Color(0xFFD97706),
      question: 'What if an emergency happens? Course Withdrawal (W) vs Incomplete (I)',
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
