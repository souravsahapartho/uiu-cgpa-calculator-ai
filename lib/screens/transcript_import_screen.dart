import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../core/providers/user_profile_provider.dart';
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
  String _selectedTrimesterFilter = 'All Trimesters';

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

    // Dynamic dropdown filter options from user's actual trimesters
    final filterOptions = ['All Trimesters', ...semesters.map((s) => s.semesterName)];
    if (!filterOptions.contains(_selectedTrimesterFilter)) {
      _selectedTrimesterFilter = 'All Trimesters';
    }

    final displayedSemesters = _selectedTrimesterFilter == 'All Trimesters'
        ? semesters
        : semesters.where((s) => s.semesterName == _selectedTrimesterFilter).toList();

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
                        tooltip: 'Academic Guidelines & Policy',
                        onPressed: () => _showAcademicGuidelinesModal(context, isDark, surface, borderClr, textPri, textSec),
                        icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                      ),
                      IconButton(
                        tooltip: 'Student Profile',
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        icon: const Icon(Icons.person_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Bar (Add Trimester, Import CSV, Import PDF, Import Image)
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
                                    'Manage Academic History',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: textPri,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Add trimesters manually, or import from CSV, PDF, Image.',
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
                            OutlinedButton.icon(
                              onPressed: () => _showImportPdfModal(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPri,
                                side: BorderSide(color: borderClr),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.danger),
                              label: const Text('Import PDF', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showImportImageModal(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPri,
                                side: BorderSide(color: borderClr),
                                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              icon: const Icon(Icons.image_outlined, size: 18, color: Color(0xFF0284C7)),
                              label: const Text('Import Image', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Dynamic Trimester Filter Dropdown
              if (semesters.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: borderClr),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FILTER BY TRIMESTER / SEMESTER',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: textSec,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTrimesterFilter,
                                    isDense: true,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
                                    dropdownColor: surface,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: textPri,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                    items: filterOptions.map((term) {
                                      return DropdownMenuItem<String>(
                                        value: term,
                                        child: Text(
                                          term == 'All Trimesters' ? 'All Trimesters (${semesters.length})' : term,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedTrimesterFilter = val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedTrimesterFilter != 'All Trimesters') ...[
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => setState(() => _selectedTrimesterFilter = 'All Trimesters'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.close_rounded, size: 12, color: AppColors.primary),
                                    SizedBox(width: 2),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final semester = displayedSemesters[index];
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
                              final originalIndex = provider.semesters.indexOf(semester);
                              if (originalIndex != -1) {
                                await provider.deleteSemester(originalIndex);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed ${semester.semesterName} instantly.')),
                                );
                              }
                            }
                          },
                        );
                      },
                      childCount: displayedSemesters.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ACADEMIC GUIDELINES & RETAKE POLICY MODAL ──
  void _showAcademicGuidelinesModal(
    BuildContext context,
    bool isDark,
    Color surface,
    Color borderClr,
    Color textPri,
    Color textSec,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Records & Policies',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              color: textPri,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'UIU official guidelines & calculation rules',
                            style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      color: textSec,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderClr),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _policyCard(
                      icon: Icons.replay_rounded,
                      iconColor: AppColors.success,
                      title: 'Retake Policy • Highest GPA Applied',
                      desc: 'If you take the same course multiple times (1st time or subsequent retakes), the system automatically takes your HIGHEST / BEST grade point for cumulative CGPA calculation. Course credits are counted only once in your degree.',
                      isDark: isDark,
                      borderClr: borderClr,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                    const SizedBox(height: 12),
                    _policyCard(
                      icon: Icons.document_scanner_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'File Import Accuracy & Safety',
                      desc: 'Analysis accuracy may vary depending on CSV, PDF, or Image scan quality. Importing only detects and populates trimester courses — your main profile CGPA & credits are NEVER altered without your confirmation.',
                      isDark: isDark,
                      borderClr: borderClr,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                    const SizedBox(height: 12),
                    _policyCard(
                      icon: Icons.edit_note_rounded,
                      iconColor: AppColors.primary,
                      title: 'Manual Course Editing & Auto-Save',
                      desc: 'You can tap any course card inside an expanded trimester to edit its code, title, credits, or grade. All additions, edits, or deletions are instantly auto-saved to your device storage.',
                      isDark: isDark,
                      borderClr: borderClr,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          UIUBottomSheet.showGradingScale(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
                        ),
                        icon: const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
                        label: const Text(
                          'View UIU Official Grading Scale (A to F)',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
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

  Widget _policyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isDark,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: iconColor.withValues(alpha: isDark ? 0.35 : 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPri,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: textSec,
                    fontSize: 11.5,
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

  // ── ADD TRIMESTER MODAL (CLEAN RESPONSIVE CARD LAYOUT) ──
  void _showAddTrimesterDialog(BuildContext context) {
    final termController = TextEditingController(text: 'Spring 2024');
    final courses = <_NewCourseItem>[
      _NewCourseItem(code: '', title: '', credit: 3.0, grade: 'A'),
      _NewCourseItem(code: '', title: '', credit: 1.0, grade: 'A'),
      _NewCourseItem(code: '', title: '', credit: 3.0, grade: 'A-'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surface = isDark ? AppColors.darkSurface : AppColors.surface;
          final sectionClr = isDark ? AppColors.darkSection : AppColors.section;
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
            height: MediaQuery.of(context).size.height * 0.88,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                        fontWeight: FontWeight.w900,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Courses (${courses.length})', style: TextStyle(color: textSec, fontWeight: FontWeight.w700, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          courses.add(_NewCourseItem(
                            code: '',
                            title: '',
                            credit: 3.0,
                            grade: 'A',
                          ));
                        });
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sectionClr,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: borderClr),
                        ),
                        child: Column(
                          children: [
                            // Row 1: Code and Title with clear responsive placeholders
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    initialValue: item.code,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPri),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'e.g. CSE 1111',
                                      labelText: 'Code',
                                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                                    ),
                                    onChanged: (v) => item.code = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    initialValue: item.title,
                                    style: TextStyle(fontSize: 13, color: textPri),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'e.g. Structured Prog.',
                                      labelText: 'Course Title',
                                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                                    ),
                                    onChanged: (v) => item.title = v,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Row 2: Credit, Grade and Delete action
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<double>(
                                    value: item.credit,
                                    style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w700),
                                    dropdownColor: surface,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Credits',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                                    ),
                                    items: [1.0, 1.5, 2.0, 3.0, 4.0, 6.0]
                                        .map((c) => DropdownMenuItem(value: c, child: Text('$c Cr')))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => item.credit = v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: item.grade,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                    dropdownColor: surface,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Grade',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                                    ),
                                    items: UIUGradingScale.scale
                                        .map((g) => DropdownMenuItem(
                                              value: g.letterGrade,
                                              child: Text('${g.letterGrade} (${g.gradePoint.toStringAsFixed(2)})',
                                                  style: TextStyle(color: g.color, fontWeight: FontWeight.bold)),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => item.grade = v);
                                    },
                                  ),
                                ),
                                if (courses.length > 1) ...[
                                  const SizedBox(width: 6),
                                  IconButton(
                                    tooltip: 'Remove Course',
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
                                    onPressed: () {
                                      setModalState(() => courses.removeAt(i));
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
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
                                code: c.code.trim().isEmpty ? 'COURSE' : c.code.trim(),
                                title: c.title.trim().isEmpty ? (c.code.trim().isEmpty ? 'Course Title' : c.code.trim()) : c.title.trim(),
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
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $termName to records successfully!')),
                        );
                      }
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
        content: SingleChildScrollView(
          child: Column(
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.file_open_outlined, size: 16),
                label: const Text('Pick .CSV File', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  try {
                    final file = await FilePicker.pickFile(
                      type: FileType.custom,
                      allowedExtensions: ['csv', 'txt'],
                    );
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      final str = utf8.decode(bytes);
                      csvController.text = str;
                    }
                  } catch (e) {
                    debugPrint('File picker error: $e');
                  }
                },
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
              final res = await provider.importMultiTrimesterContent(term, csv);
              final count = res['courses'] ?? 0;
              final terms = res['trimesters'] ?? 0;
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count > 0 ? 'Successfully imported ' + count.toString() + ' courses across ' + terms.toString() + ' trimester(s)!' : 'Could not parse CSV format.'),
                    backgroundColor: count > 0 ? AppColors.success : AppColors.danger,
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

  // ── IMPORT PDF MODAL ──
  void _showImportPdfModal(BuildContext context) {
    final termController = TextEditingController(text: 'Spring 2024');
    final pdfTextController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: const Text('Import UIU Transcript PDF', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload a transcript file or paste extracted text:',
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('Select PDF / TXT File', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  try {
                    final file = await FilePicker.pickFile(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'txt'],
                    );
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      final str = utf8.decode(bytes, allowMalformed: true);
                      pdfTextController.text = str;
                    }
                  } catch (e) {
                    debugPrint('PDF pick error: $e');
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pdfTextController,
                maxLines: 5,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'CSE 2213 Object Oriented Programming 3.00 A\nCSE 2214 OOP Lab 1.00 A',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
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
              final rawText = pdfTextController.text.trim();
              if (rawText.isEmpty) return;
              final provider = ProfileProviderScope.of(context);
              final res = await provider.importMultiTrimesterContent(term, rawText);
              final count = res['courses'] ?? 0;
              final terms = res['trimesters'] ?? 0;
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count > 0 ? 'Successfully imported ' + count.toString() + ' courses across ' + terms.toString() + ' trimester(s) from PDF!' : 'Could not detect courses in PDF text.'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _checkAndUpdateProfileCgpa(context, provider);
              }
            },
            child: const Text('Import PDF Data'),
          ),
        ],
      ),
    );
  }

  // ── IMPORT IMAGE MODAL ──
  void _showImportImageModal(BuildContext context) {
    final termController = TextEditingController(text: 'Summer 2023');
    final imgTextController = TextEditingController(
      text: 'CSE 2213, Object Oriented Programming, 3.0, A\nCSE 2214, OOP Lab, 1.0, A\nMATH 2183, Calculus, 3.0, A-',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: const Text('Import Grade Sheet Image', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload screenshot or photo of UIU grade sheet:',
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.image_search_outlined, size: 16),
                label: const Text('Select Image (PNG/JPG)', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  try {
                    await FilePicker.pickFile(
                      type: FileType.image,
                    );
                  } catch (e) {
                    debugPrint('Image picker error: $e');
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text('Recognized Courses Preview:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: imgTextController,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
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
              final raw = imgTextController.text.trim();
              if (raw.isEmpty) return;
              final provider = ProfileProviderScope.of(context);
              final res = await provider.importMultiTrimesterContent(term, raw);
              final count = res['courses'] ?? 0;
              final terms = res['trimesters'] ?? 0;
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count > 0 ? 'Successfully imported ' + count.toString() + ' courses across ' + terms.toString() + ' trimester(s)!' : 'Could not parse image courses.'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _checkAndUpdateProfileCgpa(context, provider);
              }
            },
            child: const Text('Import Courses'),
          ),
        ],
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

  void _checkAndUpdateProfileCgpa(BuildContext context, UserProfileProvider provider) {
    final metrics = provider.getTranscriptCumulativeMetrics();
    final cgpa = metrics['cgpa'] ?? 0.0;
    final credits = metrics['credits'] ?? 0.0;

    if (credits <= 0) return;

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Update Profile CGPA?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detected Transcript CGPA: ${cgpa.toStringAsFixed(2)} (${credits.toInt()} Credits)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Is this your current CGPA? Would you like to update your student profile with this result?',
                style: TextStyle(fontSize: 13, height: 1.35),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('No, Keep Current', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.updateProfileFromTranscript(cgpa, credits);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile CGPA updated to ${cgpa.toStringAsFixed(2)}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
              ),
              child: const Text('Yes, Update Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
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
