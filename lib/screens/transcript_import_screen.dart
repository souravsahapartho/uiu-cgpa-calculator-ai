import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../data/uiu_mock_data.dart';
import '../widgets/uiu_header.dart';
import '../widgets/semester_accordion.dart';
import '../widgets/uiu_bottom_sheet.dart';
import '../core/utils/responsive_utils.dart';

class TranscriptImportScreen extends StatefulWidget {
  const TranscriptImportScreen({super.key});

  @override
  State<TranscriptImportScreen> createState() => _TranscriptImportScreenState();
}

class _TranscriptImportScreenState extends State<TranscriptImportScreen> {
  bool _isTranscriptLoaded = true;
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final semesters = UIUMockData.transcriptSemesters;

    final filteredSemesters = _selectedFilter == 'All'
        ? semesters
        : semesters.where((s) => s.semesterName.contains(_selectedFilter)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveUtils.getMaxContentWidth(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIUHeader(
                    title: 'Transcript & Records',
                    subtitle: 'UIU Official Academic History & Course Breakdown',
                    trailing: IconButton(
                      onPressed: () => UIUBottomSheets.showGradingScale(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                      tooltip: 'UIU Scale Info',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Drag & Drop Upload Zone (UI Only)
                  _buildUploadSection(),
                  const SizedBox(height: 20),

                  if (_isTranscriptLoaded) ...[
                    // Summary Banner
                    _buildTranscriptStatsHeader(semesters),
                    const SizedBox(height: 18),

                    // Filter Chips (All, Spring, Summer, Fall)
                    Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Spring'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Summer'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Fall'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Semester Cards
                    Text(
                      'Completed Trimesters (${filteredSemesters.length})',
                      style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),

                    ...filteredSemesters.map((semester) {
                      return SemesterAccordion(
                        semester: semester,
                        initialExpanded: semester.semesterIndex == semesters.length,
                        onCourseTap: (course) => UIUBottomSheets.showCourseDetails(context, course),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.35), style: BorderStyle.solid, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import UIU Transcript',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Upload UCAM PDF, CSV, or Grade Sheet',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UI Demo: PDF Parser is ready. Transcript loaded from sample!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Upload PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UI Demo: CSV Parser is ready. Transcript loaded!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.table_view_rounded, size: 18),
                  label: const Text('Upload CSV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              setState(() => _isTranscriptLoaded = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('UIU Sample Transcript Reset!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reload UIU Sample Transcript (Batch 201)'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptStatsHeader(List<dynamic> semesters) {
    int totalCourses = 0;
    int aGrades = 0;
    for (var sem in semesters) {
      totalCourses += (sem.courses as List).length;
      for (var c in sem.courses) {
        if (c.grade == 'A' || c.grade == 'A-') aGrades++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Courses', '$totalCourses Taken'),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
          _buildStatItem('A & A- Grades', '$aGrades Courses'),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
          _buildStatItem('Retake Eligible', '1 Course (B)'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

