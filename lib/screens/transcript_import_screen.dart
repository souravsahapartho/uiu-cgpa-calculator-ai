import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/course.dart';
import '../models/semester_transcript.dart';
import '../core/constants/uiu_grading_scale.dart';
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
    final provider = ProfileProviderScope.of(context);
    final semesters = provider.semesters;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionClr = isDark ? AppColors.darkSection : AppColors.section;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final totalCompletedCredits = semesters.fold(0.0, (sum, s) => sum + s.creditsEarned);

    return Scaffold(
      backgroundColor: bg,
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
                  subtitle: semesters.isEmpty
                      ? 'No recorded trimesters yet'
                      : '${semesters.length} Trimesters • ${totalCompletedCredits.toStringAsFixed(1)} Credits Completed',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Export / Backup JSON',
                        onPressed: semesters.isEmpty
                            ? null
                            : () => _showExportJsonModal(context, provider.exportBackupJson()),
                        icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                      ),
                      IconButton(
                        tooltip: 'UIU Grading Policy',
                        onPressed: () => UIUBottomSheet.showGradingScale(context),
                        icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Bar (Add Trimester, Import JSON, Import CSV)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: borderClr),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: const Icon(Icons.sync_alt_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Your Academic History',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: textPri,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Add trimesters manually, or backup & restore your JSON.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: textSec,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showAddTrimesterDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Trimester', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showImportJsonModal(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPri,
                                side: BorderSide(color: borderClr),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              icon: const Icon(Icons.restore_page_rounded, size: 18, color: AppColors.primary),
                              label: const Text('Import JSON', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showImportCsvModal(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPri,
                                side: BorderSide(color: borderClr),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              icon: const Icon(Icons.table_chart_outlined, size: 18, color: AppColors.accent),
                              label: const Text('Import CSV', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filter Chips
              if (semesters.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filters.length,
                        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.s8),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedFilterIndex == index;
                          return ChoiceChip(
                            label: Text(
                              _filters[index],
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected ? Colors.white : textSec,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: sectionClr,
                            elevation: 0,
                            pressElevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderFull,
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : borderClr,
                                width: 1,
                              ),
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilterIndex = index);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Empty State or List of Semesters
              if (semesters.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: AppRadius.borderXl,
                        border: Border.all(color: borderClr),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_outlined, size: 60, color: AppColors.primary.withValues(alpha: 0.6)),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            'No Trimesters Added',
                            style: AppTypography.titleLarge.copyWith(
                              color: textPri,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Text(
                            'Your transcript is currently empty. Tap "Add Trimester" above to add your courses manually, or import your JSON backup to restore previous records.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: textSec,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showAddTrimesterDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Your First Trimester', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final semester = semesters[index];
                        return SemesterAccordion(
                          semester: semester,
                          isInitiallyExpanded: index == 0,
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: surface,
                                title: Text('Delete Trimester?', style: TextStyle(color: textPri, fontWeight: FontWeight.bold)),
                                content: Text('Are you sure you want to remove ${semester.semesterName}?', style: TextStyle(color: textSec)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await provider.deleteSemester(index);
                            }
                          },
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

  // ── ADD TRIMESTER MODAL ──
  void _showAddTrimesterDialog(BuildContext context) {
    final termController = TextEditingController(text: 'Spring 2024');
    final courses = <_NewCourseItem>[
      _NewCourseItem(code: 'CSE 1111', title: 'Structured Programming Language', credit: 3.0, grade: 'A'),
      _NewCourseItem(code: 'CSE 1112', title: 'Structured Programming Language Lab', credit: 1.0, grade: 'A'),
      _NewCourseItem(code: 'MATH 1151', title: 'Fundamental Calculus', credit: 3.0, grade: 'A-'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surface = isDark ? AppColors.darkSurface : AppColors.surface;
          final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
          final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
          final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

          double semCredits = 0;
          double semPoints = 0;
          for (final c in courses) {
            final gp = UIUGradingScale.getGradePoint(c.grade);
            semCredits += c.credit;
            semPoints += (gp * c.credit);
          }
          final semGPA = semCredits > 0 ? (semPoints / semCredits) : 0.0;

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: borderClr),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: borderClr,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Trimester',
                      style: AppTypography.headlineSmall.copyWith(
                        color: textPri,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Text(
                        'GPA: ${semGPA.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: termController,
                  style: TextStyle(color: textPri, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Trimester Name',
                    hintText: 'e.g. Fall 2023, Spring 2024',
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Courses (${courses.length})', style: TextStyle(color: textSec, fontWeight: FontWeight.w700)),
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          courses.add(_NewCourseItem(
                            code: 'COURSE ${courses.length + 1}',
                            title: 'Course Title',
                            credit: 3.0,
                            grade: 'A',
                          ));
                        });
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Course'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (cContext, i) {
                      final item = courses[i];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSection : AppColors.section,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: borderClr),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: item.code,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Code',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onChanged: (v) => item.code = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: item.title,
                                style: TextStyle(fontSize: 12, color: textPri),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Title',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onChanged: (v) => item.title = v,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 65,
                              child: DropdownButtonFormField<double>(
                                value: item.credit,
                                style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w700),
                                dropdownColor: surface,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Cr',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                ),
                                items: [1.0, 1.5, 2.0, 3.0, 4.0]
                                    .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => item.credit = v);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 68,
                              child: DropdownButtonFormField<String>(
                                value: item.grade,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                dropdownColor: surface,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Grd',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                ),
                                items: UIUGradingScale.scale
                                    .map((g) => DropdownMenuItem(
                                          value: g.letterGrade,
                                          child: Text(g.letterGrade, style: TextStyle(color: g.color)),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => item.grade = v);
                                },
                              ),
                            ),
                            if (courses.length > 1) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                                onPressed: () {
                                  setModalState(() => courses.removeAt(i));
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                    ),
                    onPressed: () async {
                      if (courses.isEmpty) return;
                      final termName = termController.text.trim().isEmpty ? 'Trimester' : termController.text.trim();
                      final provider = ProfileProviderScope.of(context);
                      final convertedCourses = courses
                          .map((c) => Course(
                                code: c.code,
                                title: c.title,
                                credit: c.credit,
                                grade: c.grade,
                                gradePoint: UIUGradingScale.getGradePoint(c.grade),
                              ))
                          .toList();

                      final newSem = SemesterTranscript(
                        semesterName: termName,
                        courses: convertedCourses,
                        creditsEarned: semCredits,
                        sgpa: double.parse(semGPA.toStringAsFixed(2)),
                        cgpa: double.parse(semGPA.toStringAsFixed(2)),
                      );

                      await provider.addSemester(newSem);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: const Text('Save Trimester to Transcript', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── EXPORT JSON MODAL ──
  void _showExportJsonModal(BuildContext context, String json) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: const Text('Backup JSON Data', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copy this JSON code to keep a safe backup of your entire profile and grades. You can restore it anytime.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSection : AppColors.section,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup JSON copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── IMPORT JSON MODAL ──
  void _showImportJsonModal(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: const Text('Restore from JSON Backup', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste your previously exported JSON backup below to restore your academic history.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: InputDecoration(
                hintText: '{\n  "version": 1,\n  "semesters": [...]\n}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final raw = controller.text.trim();
              if (raw.isEmpty) return;
              final provider = ProfileProviderScope.of(context);
              final success = await provider.importBackupJson(raw);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Successfully restored academic history!' : 'Invalid JSON backup format.'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  // ── IMPORT CSV MODAL ──
  void _showImportCsvModal(BuildContext context) {
    final termController = TextEditingController(text: 'Spring 2024');
    final csvController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: const Text('Import CSV / Grade Sheet', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Format: Code, Title, Credit, Grade\nExample: CSE 1111, Structured Programming, 3.0, A',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: termController,
              decoration: InputDecoration(
                labelText: 'Trimester Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: csvController,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: 'CSE 1111, Structured Programming, 3.0, A\nCSE 1112, SPL Lab, 1.0, A',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final term = termController.text.trim().isEmpty ? 'Trimester' : termController.text.trim();
              final csv = csvController.text.trim();
              if (csv.isEmpty) return;
              final provider = ProfileProviderScope.of(context);
              final success = await provider.importCsvCourses(term, csv);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Successfully imported courses!' : 'Could not parse CSV format.'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Import Courses'),
          ),
        ],
      ),
    );
  }
}

class _NewCourseItem {
  String code;
  String title;
  double credit;
  String grade;

  _NewCourseItem({
    required this.code,
    required this.title,
    required this.credit,
    required this.grade,
  });
}
