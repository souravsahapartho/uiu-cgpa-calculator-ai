import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/course.dart';
import '../data/uiu_mock_data.dart';
import '../widgets/uiu_header.dart';
import '../widgets/course_card.dart';
import '../widgets/workload_indicator.dart';
import '../widgets/uiu_bottom_sheet.dart';
import '../core/utils/responsive_utils.dart';

class SemesterPlannerScreen extends StatefulWidget {
  const SemesterPlannerScreen({super.key});

  @override
  State<SemesterPlannerScreen> createState() => _SemesterPlannerScreenState();
}

class _SemesterPlannerScreenState extends State<SemesterPlannerScreen> {
  // Planned Future Semesters
  final List<Course> _plannedTerm1 = [
    UIUMockData.availableUpcomingCourses[0], // CSE 4325 Microprocessors (3.0)
    UIUMockData.availableUpcomingCourses[1], // CSE 4326 Microprocessors Lab (1.0)
    UIUMockData.availableUpcomingCourses[4], // CSE 4889 Machine Learning (3.0)
    UIUMockData.availableUpcomingCourses[5], // CSE 4890 ML Lab (1.0)
    UIUMockData.availableUpcomingCourses[9], // ENG 1013 English II (3.0)
  ];

  final List<Course> _plannedTerm2 = [
    UIUMockData.availableUpcomingCourses[2], // CSE 4531 Compiler Design (3.0)
    UIUMockData.availableUpcomingCourses[3], // CSE 4532 Compiler Lab (1.0)
    UIUMockData.availableUpcomingCourses[6], // CSE 4181 Mobile App Dev (3.0)
    UIUMockData.availableUpcomingCourses[7], // CSE 4182 Mobile App Lab (1.0)
    UIUMockData.availableUpcomingCourses[10], // ECO 3101 Eng Economics (3.0)
  ];

  int _selectedTermIndex = 0; // 0 = Term 8 (Spring 2024), 1 = Term 9 (Summer 2024)

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final currentCourses = _selectedTermIndex == 0 ? _plannedTerm1 : _plannedTerm2;

    final totalCredits = currentCourses.fold(0.0, (sum, c) => sum + c.credit);
    final labCount = currentCourses.where((c) => c.category == CourseCategory.lab).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Future Semester Planner'),
        actions: [
          IconButton(
            onPressed: () => UIUBottomSheets.showGradingScale(context),
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          ),
        ],
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
                    title: 'Degree Roadmap Builder',
                    subtitle: 'Drag and reorder future courses to maintain balanced trimesters',
                    showStorageBadge: false,
                  ),
                  const SizedBox(height: 16),

                  // Trimester Selector Tabs
                  Row(
                    children: [
                      Expanded(
                        child: _buildTermTab(
                          index: 0,
                          title: 'Trimester 8 (Spring 24)',
                          credits: _plannedTerm1.fold(0.0, (sum, c) => sum + c.credit),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTermTab(
                          index: 1,
                          title: 'Trimester 9 (Summer 24)',
                          credits: _plannedTerm2.fold(0.0, (sum, c) => sum + c.credit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Real-time Workload Meter
                  WorkloadIndicator(
                    totalCredits: totalCredits,
                    courseCount: currentCourses.length,
                    labCount: labCount,
                  ),
                  const SizedBox(height: 20),

                  // Draggable Course List (UI Only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Planned Courses (${currentCourses.length})',
                        style: AppTypography.headlineLarge.copyWith(fontSize: 17),
                      ),
                      TextButton.icon(
                        onPressed: _showAddCourseDialog,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Add Course'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentCourses.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = currentCourses.removeAt(oldIndex);
                        currentCourses.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final course = currentCourses[index];
                      return Container(
                        key: ValueKey('${course.code}_$index'),
                        child: CourseCard(
                          course: course,
                          isDraggable: true,
                          showGrade: false,
                          onTap: () => UIUBottomSheets.showCourseDetails(context, course),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textTertiary, size: 20),
                            onPressed: () {
                              setState(() {
                                currentCourses.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // AI Strategy Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Schedule Validation',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedTermIndex == 0
                                    ? 'Balanced load of 11.0 credits. No direct exam schedule conflicts detected for Spring 2024.'
                                    : 'Compiler Design + Mobile App is a heavy project load. Ensure 15+ weekly hours dedicated to coding labs.',
                                style: AppTypography.bodySmall,
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

  Widget _buildTermTab({
    required int index,
    required String title,
    required double credits,
  }) {
    final isSelected = _selectedTermIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTermIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${credits.toStringAsFixed(1)} Credits',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white.withOpacity(0.85) : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCourseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available UIU Catalog Courses',
                        style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: UIUMockData.availableUpcomingCourses.length,
                      itemBuilder: (context, index) {
                        final course = UIUMockData.availableUpcomingCourses[index];
                        return CourseCard(
                          course: course,
                          showGrade: false,
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_selectedTermIndex == 0) {
                                  _plannedTerm1.add(course);
                                } else {
                                  _plannedTerm2.add(course);
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Add', style: TextStyle(fontSize: 12)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

