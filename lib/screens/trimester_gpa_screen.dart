import 'package:flutter/material.dart';
import '../core/constants/uiu_grading_scale.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/uiu_bottom_sheet.dart';

class _TrimesterCourse {
  String name;
  double credit;
  String grade;
  double gradePoint;
  bool isRetake;

  _TrimesterCourse({
    this.name = '',
    this.credit = 3.0,
    this.grade = 'A',
    this.gradePoint = 4.00,
    this.isRetake = false,
  });
}

class TrimesterGPAScreen extends StatefulWidget {
  const TrimesterGPAScreen({super.key});

  @override
  State<TrimesterGPAScreen> createState() => _TrimesterGPAScreenState();
}

class _TrimesterGPAScreenState extends State<TrimesterGPAScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // -- CALCULATE tab state --
  double _completedCredits = 0.0;
  double _currentCGPA = 0.0;

  final List<_TrimesterCourse> _courses = [
    _TrimesterCourse(name: 'Course 1', credit: 3.0, grade: 'A', gradePoint: 4.00),
    _TrimesterCourse(name: 'Course 2', credit: 3.0, grade: 'A', gradePoint: 4.00),
  ];

  double get _trimesterGPA {
    double totalPoints = 0;
    double totalCredits = 0;
    for (final c in _courses) {
      if (!c.isRetake) {
        totalPoints += c.gradePoint * c.credit;
        totalCredits += c.credit;
      }
    }
    return totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
  }

  double get _trimesterCredits {
    double total = 0;
    for (final c in _courses) {
      if (!c.isRetake) total += c.credit;
    }
    return total;
  }

  double get _newCGPA {
    final newCredits = _completedCredits + _trimesterCredits;
    if (newCredits == 0) return 0;
    return ((_currentCGPA * _completedCredits) + (_trimesterGPA * _trimesterCredits)) / newCredits;
  }

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

  void _addCourse({bool isRetake = false}) {
    setState(() {
      _courses.add(_TrimesterCourse(
        name: isRetake ? 'Retake Course' : 'Course ${_courses.length + 1}',
        credit: 3.0,
        grade: 'A',
        gradePoint: 4.00,
        isRetake: isRetake,
      ));
    });
  }

  void _removeCourse(int index) {
    setState(() => _courses.removeAt(index));
  }

  void _reset() {
    setState(() {
      _courses.clear();
      _courses.add(_TrimesterCourse(name: 'Course 1', credit: 3.0, grade: 'A', gradePoint: 4.00));
      _courses.add(_TrimesterCourse(name: 'Course 2', credit: 3.0, grade: 'A', gradePoint: 4.00));
      _completedCredits = 0;
      _currentCGPA = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionColor = isDark ? AppColors.darkSection : AppColors.section;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar style header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UIU CGPA Calculator',
                              style: AppTypography.titleLarge.copyWith(
                                  color: textPri, fontWeight: FontWeight.w900, fontSize: 16)),
                          Text('Current Trimester GPA',
                              style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => UIUBottomSheet.showGradingScale(context),
                      icon: Icon(Icons.info_outline_rounded, color: textSec, size: 22),
                      tooltip: 'Grading Policy',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert_rounded, color: textSec, size: 22),
                    ),
                  ],
                ),
              ),

              // Tab bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: AppRadius.borderBase,
                  border: Border.all(color: borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderBase,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: textSec,
                  labelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w800),
                  unselectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'CALCULATE'),
                    Tab(text: 'GRADING POLICY'),
                  ],
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCalculateTab(surface, sectionColor, borderColor, textPri, textSec, isDark),
                    _buildGradingPolicyTab(surface, sectionColor, borderColor, textPri, textSec),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateTab(Color surface, Color sectionColor, Color borderColor,
      Color textPri, Color textSec, bool isDark) {
    return Column(
      children: [
        // Completed credits & current CGPA inputs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _buildCompactInput(
                  label: 'Completed Credits',
                  value: _completedCredits == 0 ? '' : _completedCredits.toStringAsFixed(0),
                  hint: 'Completed Cre...',
                  surface: surface,
                  borderColor: borderColor,
                  textPri: textPri,
                  textSec: textSec,
                  onChanged: (v) => setState(() => _completedCredits = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCompactInput(
                  label: 'Current CGPA',
                  value: _currentCGPA == 0 ? '' : _currentCGPA.toStringAsFixed(2),
                  hint: 'Current CGPA',
                  surface: surface,
                  borderColor: borderColor,
                  textPri: textPri,
                  textSec: textSec,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => setState(() => _currentCGPA = double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
        ),

        // Column headers
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _colHeader('Course', textSec),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _colHeader('Credit', textSec),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _colHeader('Grade', textSec),
              ),
              const SizedBox(width: 32), // space for delete button
            ],
          ),
        ),

        // Course list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            itemCount: _courses.length,
            itemBuilder: (context, i) => _buildCourseRow(
                i, surface, sectionColor, borderColor, textPri, textSec, isDark),
          ),
        ),

        // Action buttons row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              _actionButton(
                label: 'RESET',
                icon: Icons.refresh_rounded,
                onTap: _reset,
                color: AppColors.danger,
                surface: surface,
                borderColor: borderColor,
                textPri: textPri,
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'ADD MORE',
                icon: Icons.add_rounded,
                onTap: () => _addCourse(),
                color: AppColors.primary,
                surface: surface,
                borderColor: borderColor,
                textPri: textPri,
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'ADD RETAKE',
                icon: Icons.replay_rounded,
                onTap: () => _addCourse(isRetake: true),
                color: AppColors.accent,
                surface: surface,
                borderColor: borderColor,
                textPri: textPri,
              ),
            ],
          ),
        ),

        // Calculate result card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.borderLg,
            boxShadow: AppShadows.primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trimester GPA',
                      style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_trimesterGPA.toStringAsFixed(2),
                      style: AppTypography.displayLarge.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
                ],
              ),
              if (_completedCredits > 0 && _currentCGPA > 0) ...[
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('New CGPA',
                        style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(_newCGPA.toStringAsFixed(2),
                        style: AppTypography.displayLarge.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
                  ],
                ),
              ] else
                Text('CALCULATE',
                    style: AppTypography.titleLarge.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ),

        const SizedBox(height: 80), // nav bar space
      ],
    );
  }

  Widget _buildCourseRow(int i, Color surface, Color sectionColor, Color borderColor,
      Color textPri, Color textSec, bool isDark) {
    final course = _courses[i];
    final credits = [1.0, 2.0, 3.0, 4.0];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderBase,
        border: Border.all(
          color: course.isRetake
              ? AppColors.accent.withValues(alpha: 0.4)
              : borderColor,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          if (course.isRetake)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Text('RETAKE',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3)),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, course.isRetake ? 18 : 8, 8, 8),
            child: Row(
              children: [
                // Course label/number
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: course.isRetake ? 'Retake ${i + 1}' : '${i + 1}',
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: course.isRetake ? AppColors.accent : AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderSm,
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderSm,
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: course.credit,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: surface,
                        items: credits
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('${c.toInt()} cr',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textPri))))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => course.credit = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Credit (shown as number that matches label)
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Credit',
                      labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary),
                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide(color: borderColor)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: course.credit,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: surface,
                        items: credits
                            .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('${c.toInt()}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri))))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => course.credit = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Grade
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Grade',
                      labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary),
                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: BorderSide(color: borderColor)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: course.grade,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: surface,
                        items: UIUGradingScale.scale
                            .map((item) => DropdownMenuItem(
                                value: item.letterGrade,
                                child: Text(
                                  item.letterGrade,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: item.color),
                                )))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            final match = UIUGradingScale.scale
                                .firstWhere((e) => e.letterGrade == v);
                            setState(() {
                              course.grade = match.letterGrade;
                              course.gradePoint = match.gradePoint;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete
                GestureDetector(
                  onTap: _courses.length > 1 ? () => _removeCourse(i) : null,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _courses.length > 1 ? AppColors.danger : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingPolicyTab(Color surface, Color sectionColor, Color borderColor,
      Color textPri, Color textSec) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: borderColor),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    _policyHeader('Grade', flex: 2),
                    _policyHeader('Marks'),
                    _policyHeader('GP'),
                    _policyHeader('Remarks', flex: 2),
                  ],
                ),
              ),
              ...UIUGradingScale.scale.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: i.isEven ? sectionColor.withValues(alpha: 0.4) : surface,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(item.grade,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: item.color)),
                      ),
                      Expanded(
                        child: Text(item.markRange,
                            style: TextStyle(fontSize: 12, color: textSec)),
                      ),
                      Expanded(
                        child: Text(item.gradePoint.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textPri)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(item.remarks,
                            style: TextStyle(fontSize: 11, color: textSec)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadius.borderBase,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UIU Grading Policy Notes',
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      _policyNote('• Minimum passing grade: D (1.00 grade point)'),
                      _policyNote('• Minimum CGPA to maintain: 2.00 (satisfactory standing)'),
                      _policyNote('• Retake: Allowed for failed (F) courses and to improve grade'),
                      _policyNote('• Maximum CGPA: 4.00 on a 4-point scale'),
                      _policyNote('• Midterm: 30% | Final: 40% | Continuous Assessment: 30%'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _policyHeader(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
      );

  Widget _policyNote(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(text,
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary, fontSize: 11)),
      );

  Widget _buildCompactInput({
    required String label,
    required String value,
    required String hint,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      controller: TextEditingController(text: value),
      style: AppTypography.bodyMedium.copyWith(color: textPri, fontWeight: FontWeight.w700, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSec, fontSize: 12),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderBase,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _colHeader(String text, Color textSec) => Text(
        text,
        style: AppTypography.labelSmall.copyWith(
            color: textSec, fontWeight: FontWeight.w800, letterSpacing: 0.3),
      );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color surface,
    required Color borderColor,
    required Color textPri,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderBase,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
