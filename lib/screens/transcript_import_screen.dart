import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _keyDismissedAIPromptBanner = 'dismissed_ai_prompt_banner';
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerDismissedState();
  }

  Future<void> _loadBannerDismissedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _bannerDismissed = prefs.getBool(_keyDismissedAIPromptBanner) ?? false;
      });
    }
  }

  Future<void> _dismissBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDismissedAIPromptBanner, true);
    if (mounted) {
      setState(() {
        _bannerDismissed = true;
      });
    }
  }

  static String _getDynamicTrimester([List<SemesterTranscript>? semesters]) {
    if (semesters != null && semesters.isNotEmpty) {
      final last = semesters.last.semesterName.trim();
      final parts = last.split(' ');
      if (parts.length == 2) {
        final season = parts[0].toLowerCase();
        final year = int.tryParse(parts[1]);
        if (year != null) {
          if (season.startsWith('spr')) return 'Summer $year';
          if (season.startsWith('sum')) return 'Fall $year';
          if (season.startsWith('fal')) return 'Spring ${year + 1}';
        }
      }
    }
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;
    if (month >= 1 && month <= 4) {
      return 'Spring $year';
    } else if (month >= 5 && month <= 8) {
      return 'Summer $year';
    } else {
      return 'Fall $year';
    }
  }

  static List<String> _getRecentTrimesterSuggestions([List<SemesterTranscript>? semesters]) {
    final now = DateTime.now();
    final y = now.year;
    final suggestions = <String>{
      'Spring ${y - 1}',
      'Summer ${y - 1}',
      'Fall ${y - 1}',
      'Spring $y',
      'Summer $y',
      'Fall $y',
      'Spring ${y + 1}',
    };
    if (semesters != null) {
      for (final s in semesters) {
        if (s.semesterName.trim().isNotEmpty) {
          suggestions.add(s.semesterName.trim());
        }
      }
    }
    return suggestions.toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ProfileProviderScope.of(context);
    final semesters = provider.semesters;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final cumulativeMetrics = provider.getTranscriptCumulativeMetrics();
    final totalCompletedCredits = cumulativeMetrics['credits'] ?? 0.0;

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
          child: Column(
            children: [
              // Fixed Top Navigation Header
              UIUHeader(
                title: 'Academic Records',
                subtitle: semesters.isEmpty
                    ? 'No recorded trimesters yet'
                    : '${semesters.length} Trimesters • ${totalCompletedCredits.toStringAsFixed(1)} Credits Completed',
                trailing: IconButton(
                  tooltip: 'Academic Guidelines & Policy',
                  onPressed: () => _showAcademicGuidelinesModal(context, isDark, surface, borderClr, textPri, textSec),
                  icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [

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
                        // Add Trimester Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
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
                        ),
                        const SizedBox(height: 8),
                        // Single responsive line for 3 import options
                        Row(
                          children: [
                            Expanded(
                              child: _buildImportActionBtn(
                                label: 'Import CSV',
                                icon: Icons.table_chart_outlined,
                                color: AppColors.accent,
                                textPri: textPri,
                                onTap: () => _showImportCsvModal(context),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildImportActionBtn(
                                label: 'Import PDF',
                                icon: Icons.picture_as_pdf_outlined,
                                color: AppColors.danger,
                                textPri: textPri,
                                onTap: () => _showImportPdfModal(context),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildImportActionBtn(
                                label: 'Import Image',
                                icon: Icons.image_outlined,
                                color: const Color(0xFF0284C7),
                                textPri: textPri,
                                onTap: () => _showImportImageModal(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── AI Prompt Suggestion Banner for New Users (shown until dismissed or courses added) ──
              if (semesters.isEmpty && !_bannerDismissed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 12, AppSpacing.s16, 4),
                    child: _buildNewUserAIPromptBanner(
                      context: context,
                      isDark: isDark,
                      surface: surface,
                      borderClr: borderClr,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                  ),
                ),

              // ── Live Academic Overview Banner (Dynamic CGPA, Credits, Latest GPA) ──
              if (semesters.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [const Color(0xFFF0FDF4), const Color(0xFFECFDF5)],
                        ),
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.4 : 0.3),
                          width: 1.2,
                        ),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.insights_rounded, color: Color(0xFF10B981), size: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ACADEMIC OVERVIEW',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: isDark ? Colors.white : const Color(0xFF065F46),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 11, color: Color(0xFF10B981)),
                                    SizedBox(width: 2),
                                    Text(
                                      'Live Auto-Sync',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLiveMetricPill(
                                  label: 'Cumulative CGPA',
                                  value: (cumulativeMetrics['cgpa'] ?? 0.0).toStringAsFixed(2),
                                  suffix: ' / 4.00',
                                  valColor: const Color(0xFF10B981),
                                  textSec: textSec,
                                ),
                              ),
                              Container(width: 1, height: 32, color: borderClr),
                              Expanded(
                                child: _buildLiveMetricPill(
                                  label: 'Completed Cr',
                                  value: (cumulativeMetrics['credits'] ?? 0.0).toStringAsFixed(1),
                                  suffix: ' Cr',
                                  valColor: AppColors.primary,
                                  textSec: textSec,
                                ),
                              ),
                              Container(width: 1, height: 32, color: borderClr),
                              Expanded(
                                child: _buildLiveMetricPill(
                                  label: 'Latest GPA',
                                  value: semesters.first.sgpa.toStringAsFixed(2),
                                  suffix: '',
                                  valColor: const Color(0xFF8B5CF6),
                                  textSec: textSec,
                                ),
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
                        return Dismissible(
                          key: ValueKey('${semester.semesterName}_$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 26),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
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
                          },
                          onDismissed: (direction) async {
                            final originalIndex = provider.semesters.indexOf(semester);
                            if (originalIndex != -1) {
                              await provider.deleteSemester(originalIndex);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed ${semester.semesterName} instantly.')),
                              );
                            }
                          },
                          child: SemesterAccordion(
                            semester: semester,
                            isInitiallyExpanded: index == 0,
                            onAddCourse: (sem) => _showAddCourseToSemesterDialog(context, sem),
                            onEditCourse: (course, sem) => _showEditCourseToSemesterDialog(context, sem, course),
                            onDeleteCourse: (course) async {
                              await provider.deleteCourse(semester.semesterName, course);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Removed ${course.code} instantly.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
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
                          ),
                        );
                      },
                      childCount: displayedSemesters.length,
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
                    // ── AI Prompt Helper: Convert UCAM Result to CSV ──
                    _buildAIPromptHelperCard(
                      context: context,
                      isDark: isDark,
                      borderClr: borderClr,
                      surface: surface,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    _policyCard(
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFEF4444),
                      title: 'Academic Probation Policy (UIU Regulation)',
                      desc: 'A student whose Term GPA is less than 2.00 for two consecutive trimesters/semesters or whose cumulative GPA falls below 2.00 will be placed on Academic Probation. A maximum of 3 probations are permitted before dismissal under UIU Academic Regulations.',
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

  Widget _buildNewUserAIPromptBanner({
    required BuildContext context,
    required bool isDark,
    required Color surface,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
  }) {
    const aiPromptText =
        'Convert my UIU UCAM result history into CSV format for UIU Grade Calculator app.\n\n'
        'Output columns: Trimester,Course Code,Course Title,Credit,Grade\n\n'
        'Instructions:\n'
        '1. Extract every trimester (e.g., Fall 2023, Spring 2024, etc.).\n'
        '2. For each course, extract Course Code (e.g., CSE 1111), Title, Credit (e.g., 3.0), and Grade (e.g., A, B+, etc.).\n'
        '3. Provide ONLY pure CSV text without markdown or conversational commentary so I can save as .csv directly.\n\n'
        'Here is my UCAM result:';

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'AI Prompt: Convert UCAM Result to CSV',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textPri,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'UIU UCAM does NOT have direct CSV download. Use AI to make CSV in seconds!',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _dismissBanner,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: textSec.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 16, color: textSec),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'How to easily make your CSV with ChatGPT / Claude:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textPri,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1. Take a screenshot or copy text of your Grade History from UIU UCAM.\n'
            '2. Copy the prompt below and paste into ChatGPT or Claude with your screenshot/text.\n'
            '3. Save the response as a .csv file and tap "Import CSV" above!',
            style: TextStyle(
              fontSize: 11,
              color: textSec,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: borderClr),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    aiPromptText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      height: 1.35,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: aiPromptText));
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
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text(
                'Copy AI Prompt to Clipboard',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPromptHelperCard({
    required BuildContext context,
    required bool isDark,
    required Color borderClr,
    required Color surface,
    required Color textPri,
    required Color textSec,
  }) {
    const aiPromptText =
        'Convert my UIU UCAM result history into CSV format for UIU Grade Calculator app.\n\n'
        'Output columns: Trimester,Course Code,Course Title,Credit,Grade\n\n'
        'Instructions:\n'
        '1. Extract every trimester (e.g., Fall 2023, Spring 2024, etc.).\n'
        '2. For each course, extract Course Code (e.g., CSE 1111), Title, Credit (e.g., 3.0), and Grade (e.g., A, B+, etc.).\n'
        '3. Provide ONLY pure CSV text without markdown or conversational commentary so I can save as .csv directly.\n\n'
        'Here is my UCAM result:';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
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
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Helper: Convert UCAM Result to CSV',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textPri,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Turn UCAM screenshot / copied text into CSV via ChatGPT / Claude',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSec,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'How to easily make your CSV with AI:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textPri,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1. Take a screenshot or copy text of your Grade History from UIU UCAM portal.\n'
            '2. Copy the prompt below and paste into ChatGPT or Claude with your screenshot/text.\n'
            '3. Save the response as a .csv file (or copy text) and import here directly!',
            style: TextStyle(
              fontSize: 11,
              color: textSec,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Prompt snippet box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: borderClr),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    aiPromptText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      height: 1.35,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Copy Prompt Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: aiPromptText));
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
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text(
                'Copy AI Prompt to Clipboard',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
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
    final provider = ProfileProviderScope.of(context);
    final defaultDynamicTerm = _getDynamicTrimester(provider.semesters);
    final termController = TextEditingController();
    final courses = <_NewCourseItem>[
      _NewCourseItem(code: '', title: '', credit: 3.0, grade: 'A'),
      _NewCourseItem(code: '', title: '', credit: 1.0, grade: 'A'),
      _NewCourseItem(code: '', title: '', credit: 3.0, grade: 'A-'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

          Future<void> saveTrimester() async {
            if (courses.isEmpty) return;
            final termName = termController.text.trim().isEmpty ? defaultDynamicTerm : termController.text.trim();
            final convertedCourses = courses
                .map((c) => Course(
                      code: c.code.trim().isEmpty ? 'COURSE' : c.code.trim().toUpperCase(),
                      title: c.title.trim().isEmpty
                          ? (c.code.trim().isEmpty ? 'Course Title' : c.code.trim().toUpperCase())
                          : c.title.trim(),
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
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.90,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: borderClr),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pinned Compact Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
                  child: Column(
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Trimester',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: textPri,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'GPA: ${semGPA.toStringAsFixed(2)} • ${courses.length} courses',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quick Save Button at Header
                          FilledButton.icon(
                            onPressed: saveTrimester,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: textSec, size: 20),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderClr),
                // Scrollable Body - Never Crushed by Keyboard!
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    children: [
                      // Target Trimester input
                      TextField(
                        controller: termController,
                        style: TextStyle(color: textPri, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Target Trimester Name *',
                          hintText: 'e.g. $defaultDynamicTerm',
                          helperText: 'Enter target trimester (e.g. $defaultDynamicTerm)',
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getRecentTrimesterSuggestions(provider.semesters).map((suggested) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(suggested, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: textPri)),
                                backgroundColor: surface,
                                side: BorderSide(color: borderClr, width: 0.8),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  setModalState(() {
                                    termController.text = suggested;
                                  });
                                },
                              ),
                            );
                          }).toList(),
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
                      const SizedBox(height: 8),
                      ...courses.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sectionClr,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(color: borderClr),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      initialValue: item.code,
                                      textCapitalization: TextCapitalization.characters,
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
                                      textCapitalization: TextCapitalization.words,
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
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                          ),
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          onPressed: saveTrimester,
                          label: const Text('Save Trimester to Transcript', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── ADD COURSE TO EXISTING TRIMESTER MODAL ──
  void _showAddCourseToSemesterDialog(BuildContext context, SemesterTranscript semester) {
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    double selectedCredit = 3.0;
    String selectedGrade = 'A';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final sectionClr = isDark ? AppColors.darkSection : AppColors.section;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final points = UIUGradingScale.getGradePoint(selectedGrade);
          final currentSemCredits = semester.creditsEarned;
          final currentSemPoints = semester.sgpa * currentSemCredits;
          final newSemCredits = currentSemCredits + selectedCredit;
          final newSemGPA = newSemCredits > 0 ? (currentSemPoints + points * selectedCredit) / newSemCredits : 0.0;

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: borderClr),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: borderClr,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_chart_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Course to ${semester.semesterName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Current SGPA: ${semester.sgpa.toStringAsFixed(2)} • ${semester.courses.length} courses',
                              style: TextStyle(fontSize: 11.5, color: textSec, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: textSec, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Course Code Field
                  TextFormField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(fontWeight: FontWeight.w700, color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Course Code *',
                      hintText: 'e.g. CSE 2215',
                      prefixIcon: const Icon(Icons.code_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Course Title Field
                  TextFormField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Course Title (Optional)',
                      hintText: 'e.g. Data Structures and Algorithms',
                      prefixIcon: const Icon(Icons.title_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Credits & Grade Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: selectedCredit,
                          style: TextStyle(fontWeight: FontWeight.w700, color: textPri, fontSize: 13),
                          dropdownColor: surface,
                          decoration: InputDecoration(
                            labelText: 'Credit Hours',
                            prefixIcon: const Icon(Icons.star_rounded, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1.0, child: Text('1.0 Cr (Lab)')),
                            DropdownMenuItem(value: 1.5, child: Text('1.5 Cr (Lab)')),
                            DropdownMenuItem(value: 2.0, child: Text('2.0 Cr')),
                            DropdownMenuItem(value: 3.0, child: Text('3.0 Cr (Theory)')),
                            DropdownMenuItem(value: 4.0, child: Text('4.0 Cr (Project)')),
                            DropdownMenuItem(value: 6.0, child: Text('6.0 Cr (Thesis)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedCredit = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGrade,
                          style: TextStyle(fontWeight: FontWeight.w800, color: textPri, fontSize: 13),
                          dropdownColor: surface,
                          decoration: InputDecoration(
                            labelText: 'Grade',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: UIUGradingScale.scale.map((g) {
                            return DropdownMenuItem(
                              value: g.letterGrade,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: g.color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${g.letterGrade} (${g.gradePoint.toStringAsFixed(2)})',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: g.color)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedGrade = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Live Estimated Impact Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sectionClr,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderClr),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Impact Preview',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSec),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'New SGPA: ${newSemGPA.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+$selectedCredit Cr (${points.toStringAsFixed(2)} pts)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        'Add to ${semester.semesterName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      onPressed: () async {
                        final rawCode = codeController.text.trim();
                        if (rawCode.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a course code (e.g. CSE 2215).'),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final code = rawCode.toUpperCase();
                        final title = titleController.text.trim().isEmpty ? code : titleController.text.trim();
                        final newCourse = Course(
                          code: code,
                          title: title,
                          credit: selectedCredit,
                          grade: selectedGrade,
                          gradePoint: UIUGradingScale.getGradePoint(selectedGrade),
                        );

                        final provider = ProfileProviderScope.of(context);
                        await provider.addCourseToSemester(semester.semesterName, newCourse);

                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $code to ${semester.semesterName}!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveMetricPill({
    required String label,
    required String value,
    required String suffix,
    required Color valColor,
    required Color textSec,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: valColor,
              ),
            ),
            if (suffix.isNotEmpty)
              Text(
                suffix,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textSec,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textSec,
          ),
        ),
      ],
    );
  }

  // ── EDIT COURSE IN EXISTING TRIMESTER MODAL ──
  void _showEditCourseToSemesterDialog(
    BuildContext context,
    SemesterTranscript semester,
    Course course,
  ) {
    final codeController = TextEditingController(text: course.code);
    final titleController = TextEditingController(text: course.title);
    double selectedCredit = course.credit;
    String selectedGrade = course.grade ?? 'A';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final sectionClr = isDark ? AppColors.darkSection : AppColors.section;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final otherCourses = semester.courses.where((c) => c != course).toList();
          double previewCredits = 0.0;
          double previewPoints = 0.0;
          for (final c in otherCourses) {
            final gp = c.gradePoint ?? (c.grade != null ? UIUGradingScale.getGradePoint(c.grade!) : 0.0);
            previewCredits += c.credit;
            previewPoints += (gp * c.credit);
          }
          final editedPoints = UIUGradingScale.getGradePoint(selectedGrade);
          previewCredits += selectedCredit;
          previewPoints += (editedPoints * selectedCredit);
          final newSemGPA = previewCredits > 0 ? (previewPoints / previewCredits) : 0.0;

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: borderClr),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: borderClr,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_note_rounded, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Course: ${course.code}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'In ${semester.semesterName} • Current SGPA: ${semester.sgpa.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11.5, color: textSec, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: textSec, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(fontWeight: FontWeight.w700, color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Course Code *',
                      hintText: 'e.g. CSE 2215',
                      prefixIcon: const Icon(Icons.code_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Course Title',
                      hintText: 'e.g. Data Structures and Algorithms',
                      prefixIcon: const Icon(Icons.title_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: selectedCredit,
                          style: TextStyle(fontWeight: FontWeight.w700, color: textPri, fontSize: 13),
                          dropdownColor: surface,
                          decoration: InputDecoration(
                            labelText: 'Credit Hours',
                            prefixIcon: const Icon(Icons.star_rounded, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1.0, child: Text('1.0 Cr (Lab)')),
                            DropdownMenuItem(value: 1.5, child: Text('1.5 Cr (Lab)')),
                            DropdownMenuItem(value: 2.0, child: Text('2.0 Cr')),
                            DropdownMenuItem(value: 3.0, child: Text('3.0 Cr (Theory)')),
                            DropdownMenuItem(value: 4.0, child: Text('4.0 Cr (Project)')),
                            DropdownMenuItem(value: 6.0, child: Text('6.0 Cr (Thesis)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedCredit = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGrade,
                          style: TextStyle(fontWeight: FontWeight.w800, color: textPri, fontSize: 13),
                          dropdownColor: surface,
                          decoration: InputDecoration(
                            labelText: 'Grade',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: UIUGradingScale.scale.map((g) {
                            return DropdownMenuItem(
                              value: g.letterGrade,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: g.color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${g.letterGrade} (${g.gradePoint.toStringAsFixed(2)})',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: g.color)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedGrade = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sectionClr,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderClr),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Updated SGPA Preview',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSec),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'New SGPA: ${newSemGPA.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$selectedCredit Cr (${editedPoints.toStringAsFixed(2)} pts)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text(
                        'Save Course Changes',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      onPressed: () async {
                        final rawCode = codeController.text.trim();
                        if (rawCode.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a course code.'),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final code = rawCode.toUpperCase();
                        final title = titleController.text.trim().isEmpty ? code : titleController.text.trim();
                        final updatedCourse = Course(
                          code: code,
                          title: title,
                          credit: selectedCredit,
                          grade: selectedGrade,
                          gradePoint: UIUGradingScale.getGradePoint(selectedGrade),
                        );

                        final provider = ProfileProviderScope.of(context);
                        await provider.updateCourse(semester.semesterName, course, updatedCourse);

                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Updated $code in ${semester.semesterName} successfully!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── MODERN RESPONSIVE TRANSCRIPT IMPORT BOTTOM SHEET ──
  void _showModernImportSheet({
    required BuildContext context,
    required String mode, // 'csv', 'pdf', 'image'
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionBg = isDark ? AppColors.darkSection : AppColors.section;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final Color accentColor = mode == 'csv'
        ? AppColors.accent
        : (mode == 'pdf' ? AppColors.danger : const Color(0xFF0284C7));

    final IconData modeIcon = mode == 'csv'
        ? Icons.table_chart_rounded
        : (mode == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.image_search_rounded);

    final String modeTitle = mode == 'csv'
        ? 'Import CSV / Spreadsheet'
        : (mode == 'pdf' ? 'Import PDF Transcript' : 'Import Grade Sheet Image');

    final String modeSubtitle = mode == 'csv'
        ? 'Upload .csv or paste comma/tab-separated course records'
        : (mode == 'pdf'
            ? 'Select your UCAM PDF transcript or paste extracted text'
            : 'Select grade sheet photo or paste OCR recognized text');

    final String placeholderExample = mode == 'csv'
        ? 'CSE 1111, Structured Programming, 3.0, A\nCSE 1112, SPL Laboratory, 1.0, A\nMATH 1151, Fundamental Calculus, 3.0, A-'
        : (mode == 'pdf'
            ? 'CSE 2213 Object Oriented Programming 3.00 A\nCSE 2214 OOP Lab 1.00 A\nMATH 2183 Calculus and Linear Algebra 3.00 B+'
            : 'CSE 1111, Structured Programming, 3.0, A\nCSE 1112, SPL Lab, 1.0, A');

    final provider = ProfileProviderScope.of(context);
    final defaultDynamicTerm = _getDynamicTrimester(provider.semesters);

    final contentController = TextEditingController();

    String? pickedFileName;
    String? pickedFileSize;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: borderClr,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(modeIcon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          modeTitle,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: textPri,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          modeSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: textSec,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textSec, size: 20),
                    onPressed: () => Navigator.pop(modalCtx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File Upload Dropzone
                      GestureDetector(
                        onTap: () async {
                          try {
                            if (mode == 'csv') {
                              final file = await FilePicker.pickFile(
                                type: FileType.custom,
                                allowedExtensions: ['csv', 'txt'],
                              );
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                final str = utf8.decode(bytes, allowMalformed: true);
                                setModalState(() {
                                  pickedFileName = file.name;
                                  pickedFileSize = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
                                  contentController.text = str;
                                });
                              }
                            } else if (mode == 'pdf') {
                              final file = await FilePicker.pickFile(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'txt'],
                              );
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                final str = utf8.decode(bytes, allowMalformed: true);
                                setModalState(() {
                                  pickedFileName = file.name;
                                  pickedFileSize = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
                                  contentController.text = str;
                                });
                              }
                            } else {
                              final file = await FilePicker.pickFile(
                                type: FileType.image,
                              );
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                setModalState(() {
                                  pickedFileName = file.name;
                                  pickedFileSize = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
                                });
                              }
                            }
                          } catch (e) {
                            debugPrint('File pick error: $e');
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.04),
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.cloud_upload_outlined, color: accentColor, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pickedFileName != null
                                    ? 'Selected: $pickedFileName ($pickedFileSize)'
                                    : (mode == 'csv'
                                        ? 'Tap to select .CSV or .TXT file'
                                        : (mode == 'pdf' ? 'Tap to select UIU Transcript PDF' : 'Tap to select Grade Sheet Image')),
                                textAlign: TextAlign.center,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Supports official UIU formats & grade matrices',
                                style: AppTypography.bodySmall.copyWith(
                                  color: textSec,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Direct Text Editor / Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Parsed / Extracted Content',
                            style: AppTypography.labelSmall.copyWith(color: textSec, fontWeight: FontWeight.w700),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Auto Multi-Term Detection',
                              style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 9.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: sectionBg,
                          borderRadius: AppRadius.borderBase,
                          border: Border.all(color: borderClr),
                        ),
                        child: TextField(
                          controller: contentController,
                          maxLines: 5,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: placeholderExample,
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: textPri.withValues(alpha: 0.35),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Format Hint
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.07),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14, color: accentColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Course format: [Code] [Title] [Credit] [Grade] (e.g. CSE 1111 SPL 3.0 A)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: textSec,
                                  fontSize: 10.5,
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

              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPri,
                        side: BorderSide(color: borderClr),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(modalCtx),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Import & Parse Data',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      onPressed: () async {
                        final term = defaultDynamicTerm;
                        final raw = contentController.text.trim();
                        if (raw.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a file or paste course records to import.'),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final provider = ProfileProviderScope.of(context);
                        final res = await provider.importMultiTrimesterContent(term, raw);
                        final count = res['courses'] ?? 0;
                        final terms = res['trimesters'] ?? 0;

                        if (modalCtx.mounted) Navigator.pop(modalCtx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                count > 0
                                    ? 'Successfully imported $count courses across $terms trimester(s)!'
                                    : 'Could not parse course records. Please check the format.',
                              ),
                              backgroundColor: count > 0 ? AppColors.success : AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          if (count > 0) {
                            _checkAndUpdateProfileCgpa(context, provider);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FORWARDERS FOR IMPORT MODALS ──
  void _showImportCsvModal(BuildContext context) =>
      _showModernImportSheet(context: context, mode: 'csv');

  void _showImportPdfModal(BuildContext context) =>
      _showModernImportSheet(context: context, mode: 'pdf');

  void _showImportImageModal(BuildContext context) =>
      _showModernImportSheet(context: context, mode: 'image');



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

  Widget _buildImportActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color textPri,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
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
