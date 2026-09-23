import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../data/uiu_mock_data.dart';
import '../widgets/uiu_header.dart';
import '../widgets/custom_charts.dart';
import '../widgets/gpa_progress_ring.dart';
import '../core/utils/responsive_utils.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final semesters = UIUMockData.transcriptSemesters;
    final student = UIUMockData.student;

    // Calculate Grade Distribution
    final Map<String, int> gradeDistribution = {
      'A': 0,
      'A-': 0,
      'B+': 0,
      'B': 0,
      'B-': 0,
      'C+': 0,
      'C': 0,
      'F': 0,
    };

    for (var s in semesters) {
      for (var c in s.courses) {
        if (c.grade != null && gradeDistribution.containsKey(c.grade)) {
          gradeDistribution[c.grade!] = gradeDistribution[c.grade!]! + 1;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Academic Analytics'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveUtils.getMaxContentWidth(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UIUHeader(
                    title: 'Performance Trends',
                    subtitle: '7 Trimesters historical progression and grade metrics',
                    showStorageBadge: false,
                  ),
                  const SizedBox(height: 18),

                  // GPA Progression Trend Line Chart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CGPA & SGPA Progression',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendItem('CGPA', AppColors.primary),
                                const SizedBox(width: 10),
                                _buildLegendItem('SGPA', AppColors.navy.withOpacity(0.6)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Trimester 1 (Fall 2021) to Trimester 7 (Fall 2023)',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        GPATrendLineChart(semesters: semesters, height: 210),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grade Distribution Bar Chart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grade Distribution Frequency',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total 28 completed courses across 7 trimesters',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        GradeDistributionBarChart(gradeDistribution: gradeDistribution, height: 180),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Credit Completion Ring & Velocity
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroCardGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        GPAProgressRing(
                          currentGPA: student.completedCredits,
                          maxGPA: student.totalDegreeCredits,
                          size: 100,
                          strokeWidth: 10,
                          progressColor: AppColors.primary,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Credit Velocity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Average 10.8 credits / trimester.\nOn schedule for Summer 2025 graduation.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '62 Credits remaining (45%)',
                                  style: TextStyle(
                                    color: AppColors.secondaryLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

