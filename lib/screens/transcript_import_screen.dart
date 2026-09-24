import 'package:flutter/material.dart';
import '../data/uiu_mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/semester_accordion.dart';
import '../widgets/uiu_header.dart';
import '../widgets/uiu_bottom_sheet.dart';

class TranscriptImportScreen extends StatefulWidget {
  const TranscriptImportScreen({super.key});

  @override
  State<TranscriptImportScreen> createState() => _TranscriptImportScreenState();
}

class _TranscriptImportScreenState extends State<TranscriptImportScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All Trimesters', 'Year 1', 'Year 2', 'Year 3', 'Year 4'];

  @override
  Widget build(BuildContext context) {
    final semesters = UIUMockData.transcriptSemesters;
    final totalCompletedCredits = semesters.fold(0.0, (sum, s) => sum + s.creditsEarned);

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
                  title: 'Academic Records',
                  subtitle: '${semesters.length} Trimesters • ${totalCompletedCredits.toStringAsFixed(1)} Credits Completed',
                  trailing: IconButton(
                    onPressed: () => UIUBottomSheet.showGradingScale(context),
                    icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                  ),
                ),
              ),

              // Upload Action Banner (CSV / PDF Import)
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Import Transcript',
                                    style: AppTypography.titleLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Auto-parse UCAM Grade Sheet / PDF export',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('UCAM PDF transcript parsing ready')),
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                label: const Text('Upload PDF'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('CSV grade record parsing ready')),
                                  );
                                },
                                icon: const Icon(Icons.table_chart_rounded, size: 16),
                                label: const Text('Upload CSV'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
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

              // Filter Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilterIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: AppRadius.borderFull,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            boxShadow: isSelected ? AppShadows.primary : AppShadows.soft,
                          ),
                          child: Text(
                            _filters[index],
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Trimester Transcript Accordions
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final semester = semesters[semesters.length - 1 - index]; // Newest first
                      return SemesterAccordion(
                        semester: semester,
                        isInitiallyExpanded: index == 0,
                      );
                    },
                    childCount: semesters.length,
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
