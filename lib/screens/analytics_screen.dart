import 'package:flutter/material.dart';
import '../main.dart';
import '../core/providers/user_profile_provider.dart';
import '../models/semester_transcript.dart';
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
    final provider = ProfileProviderScope.of(context);
    final profile = provider.profile;
    final semesters = provider.semesters;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final sectionBg = isDark ? AppColors.darkSection : AppColors.section;

    final transcriptMetrics = provider.getTranscriptCumulativeMetrics();
    final hasTranscript = semesters.isNotEmpty && transcriptMetrics['credits']! > 0;

    final completedCredits = hasTranscript
        ? transcriptMetrics['credits']!
        : profile.completedCredits;
    final totalCredits = profile.totalDegreeCredits > 0 ? profile.totalDegreeCredits : 138.0;
    final progress = totalCredits > 0 ? (completedCredits / totalCredits).clamp(0.0, 1.0) : 0.0;

    final gradeCounts = <String, int>{
      'A': 0,
      'A-': 0,
      'B+': 0,
      'B': 0,
      'B-': 0,
      'C+': 0,
      'C': 0,
      'D': 0,
      'F': 0,
    };

    int totalCourses = 0;
    double maxCgpa = hasTranscript ? transcriptMetrics['cgpa']! : profile.currentCGPA;

    for (final s in semesters) {
      if (s.cgpa > maxCgpa) {
        maxCgpa = s.cgpa;
      }
      for (final c in s.courses) {
        final g = (c.grade ?? '').trim().toUpperCase();
        if (gradeCounts.containsKey(g)) {
          gradeCounts[g] = (gradeCounts[g] ?? 0) + 1;
          totalCourses++;
        }
      }
    }

    // Chronological order for trend chart
    final chronoSemesters = List<SemesterTranscript>.from(semesters);
    chronoSemesters.sort((a, b) =>
        UserProfileProvider.getTrimesterWeight(a.semesterName)
            .compareTo(UserProfileProvider.getTrimesterWeight(b.semesterName)));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffold,
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

              if (semesters.isEmpty && completedCredits == 0) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Academic Data Yet',
                            style: AppTypography.headlineSmall.copyWith(
                              color: textPri,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload a transcript (PDF, CSV, or Image) or update your profile to generate real-time performance analytics.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: textSec,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
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
                                color: textSec,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Peak: ${maxCgpa.toStringAsFixed(2)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        chronoSemesters.isNotEmpty
                            ? GPATrendLineChart(semesters: chronoSemesters, height: 190)
                            : Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: AppRadius.borderLg,
                                  border: Border.all(color: border),
                                ),
                                child: Center(
                                  child: Text(
                                    'CGPA: ${profile.currentCGPA.toStringAsFixed(2)} (Direct Profile Entry)',
                                    style: AppTypography.bodyMedium.copyWith(color: textSec, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
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
                                color: textSec,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '$totalCourses Courses Recorded',
                              style: AppTypography.labelSmall.copyWith(
                                color: textSec,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        totalCourses > 0
                            ? GradeDistributionChart(distribution: gradeCounts, height: 170)
                            : Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: AppRadius.borderLg,
                                  border: Border.all(color: border),
                                ),
                                child: Center(
                                  child: Text(
                                    'Import transcript to populate grade breakdown',
                                    style: AppTypography.bodySmall.copyWith(color: textSec),
                                  ),
                                ),
                              ),
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
                        color: surface,
                        borderRadius: AppRadius.borderXl,
                        border: Border.all(color: border),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEGREE COMPLETION PACE',
                            style: AppTypography.labelSmall.copyWith(
                              color: textSec,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${completedCredits.toStringAsFixed(1)} / ${totalCredits.toInt()} Credits',
                                style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: textPri,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(1)}%',
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
                              value: progress,
                              minHeight: 10,
                              backgroundColor: sectionBg,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Remaining: ${(totalCredits - completedCredits).clamp(0.0, totalCredits).toStringAsFixed(1)} credits to degree completion.',
                            style: AppTypography.bodySmall.copyWith(
                              color: textSec,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
