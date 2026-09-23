import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../data/uiu_mock_data.dart';
import '../core/utils/calculator_utils.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../core/utils/responsive_utils.dart';
import '../widgets/uiu_header.dart';
import '../widgets/gpa_progress_ring.dart';
import '../widgets/uiu_bottom_sheet.dart';

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  State<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Target Planner State
  double _currentCGPA = UIUMockData.student.currentCGPA;
  double _completedCredits = UIUMockData.student.completedCredits;
  double _targetCGPA = UIUMockData.student.targetCGPA;
  double _remainingCredits = UIUMockData.student.remainingCredits;

  // Semester SGPA Calculator State
  final List<Map<String, dynamic>> _simulatedCourses = [
    {'title': 'Microprocessors & Microcontrollers', 'credit': 3.0, 'grade': 'A', 'gradePoint': 4.00},
    {'title': 'Microprocessors Lab', 'credit': 1.0, 'grade': 'A', 'gradePoint': 4.00},
    {'title': 'Machine Learning', 'credit': 3.0, 'grade': 'A-', 'gradePoint': 3.67},
    {'title': 'Machine Learning Lab', 'credit': 1.0, 'grade': 'A', 'gradePoint': 4.00},
    {'title': 'Developing English Language Skills II', 'credit': 3.0, 'grade': 'A', 'gradePoint': 4.00},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

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
                    title: 'GPA Calculator',
                    subtitle: 'UIU Accurate Grade Forecasting & Target Planner',
                    trailing: IconButton(
                      onPressed: () => UIUBottomSheets.showGradingScale(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                      tooltip: 'UIU Grading Scale',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mode Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.primaryDark,
                      unselectedLabelColor: AppColors.textTertiary,
                      labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Target CGPA Planner'),
                        Tab(text: 'Term SGPA Simulator'),
                      ],
                      onTap: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Content
                  _tabController.index == 0
                      ? _buildTargetPlannerView()
                      : _buildTermSGPASimulatorView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetPlannerView() {
    final result = CalculatorUtils.calculateRequiredGPA(
      currentCGPA: _currentCGPA,
      completedCredits: _completedCredits,
      targetCGPA: _targetCGPA,
      remainingCredits: _remainingCredits,
    );

    return Column(
      children: [
        // Hero Result Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: result.statusColor.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: result.statusColor.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REQUIRED FUTURE SGPA',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              result.requiredGPA.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: result.statusColor,
                                letterSpacing: -1.2,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'per term avg',
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: result.statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result.message,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: result.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GPAProgressRing(
                    currentGPA: result.requiredGPA.clamp(0.0, 4.0),
                    maxGPA: 4.00,
                    size: 88,
                    strokeWidth: 8,
                    progressColor: result.statusColor,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Interactive Input Controls
        _buildSliderCard(
          title: 'Target CGPA Goal',
          value: _targetCGPA,
          min: 2.0,
          max: 4.0,
          divisions: 200,
          unit: '',
          color: AppColors.primary,
          onChanged: (val) => setState(() => _targetCGPA = double.parse(val.toStringAsFixed(2))),
        ),
        const SizedBox(height: 12),

        _buildSliderCard(
          title: 'Current CGPA',
          value: _currentCGPA,
          min: 2.0,
          max: 4.0,
          divisions: 200,
          unit: '',
          color: AppColors.navy,
          onChanged: (val) => setState(() => _currentCGPA = double.parse(val.toStringAsFixed(2))),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildNumberInputCard(
                title: 'Completed Credits',
                value: _completedCredits,
                step: 1.0,
                onChanged: (val) => setState(() => _completedCredits = val.clamp(0.0, 138.0)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberInputCard(
                title: 'Remaining Credits',
                value: _remainingCredits,
                step: 1.0,
                onChanged: (val) => setState(() => _remainingCredits = val.clamp(1.0, 138.0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // UIU Honors Forecast
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projected Convocation Standing',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      CalculatorUtils.getGraduationDistinction(_targetCGPA),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermSGPASimulatorView() {
    final sgpa = CalculatorUtils.calculateSGPA(_simulatedCourses);
    final totalTermCredits = _simulatedCourses.fold(0.0, (sum, item) => sum + (item['credit'] as double));

    // Calculate updated CGPA
    final totalQualityPoints = (_currentCGPA * _completedCredits) + (sgpa * totalTermCredits);
    final newTotalCredits = _completedCredits + totalTermCredits;
    final projectedCGPA = totalQualityPoints / newTotalCredits;

    return Column(
      children: [
        // Live SGPA & Impact Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMULATED TERM SGPA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sgpa.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                    ),
                  ),
                  Text(
                    '$totalTermCredits Credits Enrolled',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'New Projected CGPA',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      projectedCGPA.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      projectedCGPA >= _currentCGPA
                          ? '+${(projectedCGPA - _currentCGPA).toStringAsFixed(2)} Boost'
                          : '${(projectedCGPA - _currentCGPA).toStringAsFixed(2)} Drop',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: projectedCGPA >= _currentCGPA ? AppColors.secondaryLight : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Enrolled Courses (${_simulatedCourses.length})',
              style: AppTypography.headlineMedium.copyWith(fontSize: 16),
            ),
            TextButton.icon(
              onPressed: _addNewSimulatedCourse,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Course'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ..._simulatedCourses.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          return _buildSimulatedCourseRow(index, course);
        }).toList(),
      ],
    );
  }

  Widget _buildSimulatedCourseRow(int index, Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: AppTypography.headlineSmall.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(course['credit'] as double).toStringAsFixed(1)} Credits',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Grade Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: course['grade'],
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                isDense: true,
                items: UIUGradingScale.scale.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.grade,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.grade,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${item.gradePoint.toStringAsFixed(1)})',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newGrade) {
                  if (newGrade != null) {
                    setState(() {
                      _simulatedCourses[index]['grade'] = newGrade;
                      _simulatedCourses[index]['gradePoint'] = UIUGradingScale.getGradePoint(newGrade);
                    });
                  }
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_simulatedCourses.length > 1) {
                setState(() => _simulatedCourses.removeAt(index));
              }
            },
            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textTertiary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _addNewSimulatedCourse() {
    setState(() {
      _simulatedCourses.add({
        'title': 'New Elective / Core Course',
        'credit': 3.0,
        'grade': 'A',
        'gradePoint': 4.00,
      });
    });
  }

  Widget _buildSliderCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toStringAsFixed(2)}$unit',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: AppColors.border,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputCard({
    required String title,
    required double value,
    required double step,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChanged(value - step),
                icon: const Icon(Icons.remove_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  padding: const EdgeInsets.all(6),
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => onChanged(value + step),
                icon: const Icon(Icons.add_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

