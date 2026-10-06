import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../core/providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/uiu_bottom_sheet.dart';
import '../widgets/academic_distinctions_modal.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = ProfileProviderScope.of(context);
    final student = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    // Academic Honors calculation
    final courseCodes = <String>{};
    bool hasRetakes = false;
    for (final sem in provider.semesters) {
      for (final c in sem.courses) {
        if (c.code.trim().isNotEmpty) {
          final codeUpper = c.code.trim().toUpperCase();
          if (courseCodes.contains(codeUpper)) {
            hasRetakes = true;
          } else {
            courseCodes.add(codeUpper);
          }
        }
      }
    }
    final cgpa = student.currentCGPA;
    final isGoldEligible = cgpa >= 3.80;
    final isSummaEligible = cgpa >= 3.80 && !hasRetakes;
    final isMagnaEligible = cgpa >= 3.65;


    return Scaffold(
      backgroundColor: bg,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (Navigator.canPop(context)) ...[
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('MY PROFILE',
                                  style: AppTypography.labelSmall.copyWith(
                                      color: textSec, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                              Text('Student Profile',
                                  style: AppTypography.headlineLarge.copyWith(
                                      fontSize: 22, fontWeight: FontWeight.w900, color: textPri, letterSpacing: -0.5)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Dark mode toggle
                          GestureDetector(
                            onTap: () => provider.toggleTheme(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.section,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: borderColor),
                              ),
                              child: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: isDark ? AppColors.primary : AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit profile button
                          GestureDetector(
                            onTap: () => _showEditDialog(context, provider, isDark, surface, borderColor, textPri, textSec),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Student Info & Metric Hero Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.borderXl,
                      boxShadow: AppShadows.primary,
                    ),
                    child: Column(
                      children: [
                        // Name with academic cap icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.school_rounded, color: Colors.white, size: 21),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                student.name.isNotEmpty ? student.name : 'Student Name',
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'ID: ${student.studentId.isNotEmpty ? student.studentId : '—'} • Batch ${student.batch.isNotEmpty ? student.batch : '—'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 7),
                        // Dynamic Responsive Department Badge (handles long department names safely)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: AppRadius.borderFull,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              student.department,
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Stats row in modern dark-tint glass card
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.12),
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _profileStat('CGPA', student.currentCGPA.toStringAsFixed(2)),
                              _divider(),
                              _profileStat('Done Cr', '${student.completedCredits.toInt()}'),
                              _divider(),
                              _profileStat('Req Cr', '${student.totalDegreeCredits.toInt()}'),
                              _divider(),
                              _profileStat('Target', student.targetCGPA.toStringAsFixed(2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Direct JSON Backup & Restore Action Row ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: borderColor),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BACKUP & RESTORE DATA',
                                style: AppTypography.labelSmall.copyWith(
                                  color: textPri,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Export before uninstalling, or direct import JSON to restore all academic records.',
                          style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // 📥 Import JSON Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleDirectImportJson(context, provider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                  foregroundColor: const Color(0xFF2563EB),
                                  elevation: 0,
                                  side: BorderSide(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
                                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                ),
                                icon: const Icon(Icons.file_upload_outlined, size: 18),
                                label: const Text(
                                  'Import JSON',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 📤 Export JSON Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleDirectExportJson(context, provider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
                                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                ),
                                icon: const Icon(Icons.file_download_outlined, size: 18),
                                label: const Text(
                                  'Export JSON',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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

              // ── Achievements ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UIU CONVOCATION HONORS',
                        style: AppTypography.labelSmall.copyWith(
                          color: textSec,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => AcademicDistinctionsModal.show(
                          context,
                          profile: student,
                          hasRetakes: hasRetakes,
                          completedTrimesters: provider.semesters.length,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Verified Criteria & Rules',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 10, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 148,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    children: [
                      _honorCard(
                        context: context,
                        icon: Icons.military_tech_rounded,
                        title: 'Chancellor\'s Gold Medal',
                        subtitle: 'Top Academic Distinction',
                        cgpaRange: 'Batch Topper • Top CGPA',
                        badge: isGoldEligible ? '🔓 Eligible (Rank #1 Req)' : '🔒 Locked (< 3.80)',
                        badgeColor: const Color(0xFFD97706),
                        isQualified: isGoldEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        onTap: () => AcademicDistinctionsModal.show(
                          context,
                          profile: student,
                          hasRetakes: hasRetakes,
                          completedTrimesters: provider.semesters.length,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _honorCard(
                        context: context,
                        icon: Icons.stars_rounded,
                        title: 'Summa Cum Laude',
                        subtitle: 'Highest Academic Honor',
                        cgpaRange: 'CGPA 3.80 – 4.00',
                        badge: isSummaEligible
                            ? '🔓 Unlocked'
                            : (hasRetakes ? '🔒 Retake Restricted' : '🔒 Locked (< 3.80)'),
                        badgeColor: const Color(0xFF8B5CF6),
                        isQualified: isSummaEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        onTap: () => AcademicDistinctionsModal.show(
                          context,
                          profile: student,
                          hasRetakes: hasRetakes,
                          completedTrimesters: provider.semesters.length,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _honorCard(
                        context: context,
                        icon: Icons.verified_rounded,
                        title: 'Magna Cum Laude',
                        subtitle: 'Great Academic Honor',
                        cgpaRange: 'CGPA 3.65 – 3.79',
                        badge: isMagnaEligible ? '🔓 Unlocked' : '🔒 Locked (< 3.65)',
                        badgeColor: const Color(0xFF2563EB),
                        isQualified: isMagnaEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        onTap: () => AcademicDistinctionsModal.show(
                          context,
                          profile: student,
                          hasRetakes: hasRetakes,
                          completedTrimesters: provider.semesters.length,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _honorCard(
                        context: context,
                        icon: Icons.info_outline_rounded,
                        title: 'Cum Laude (Not at UIU)',
                        subtitle: 'Official UIU Policy Check',
                        cgpaRange: 'Not Conferred',
                        badge: 'Official: Not Awarded',
                        badgeColor: const Color(0xFF64748B),
                        isQualified: false,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        onTap: () => AcademicDistinctionsModal.show(
                          context,
                          profile: student,
                          hasRetakes: hasRetakes,
                          completedTrimesters: provider.semesters.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Settings ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text('SETTINGS & PREFERENCES',
                      style: AppTypography.labelSmall.copyWith(
                          color: textSec, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _settingItem(
                      icon: Icons.dark_mode_rounded,
                      title: isDark ? 'Dark Mode: ON' : 'Light Mode: ON',
                      subtitle: 'Tap to toggle between light and dark theme',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) => provider.toggleTheme(),
                      ),
                      onTap: () => provider.toggleTheme(),
                    ),
                    _settingItem(
                      icon: Icons.edit_note_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your name, ID, CGPA, credits & batch',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onTap: () => _showEditDialog(context, provider, isDark, surface, borderColor, textPri, textSec),
                    ),
                    _settingItem(
                      icon: Icons.policy_rounded,
                      title: 'UIU Official Grading Scale',
                      subtitle: 'View letter grades, marks, and grade points',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onTap: () => UIUBottomSheet.showGradingScale(context),
                    ),
                    _settingItem(
                      icon: Icons.workspace_premium_rounded,
                      title: 'UIU Convocation Honors Criteria',
                      subtitle: 'Gold Medal, Summa & Magna Cum Laude verified rules',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onTap: () => AcademicDistinctionsModal.show(
                        context,
                        profile: provider.profile,
                        hasRetakes: hasRetakes,
                        completedTrimesters: provider.semesters.length,
                      ),
                    ),
                    _settingItem(
                      icon: Icons.sync_rounded,
                      title: 'Data Storage Status',
                      subtitle: 'Progress is saved locally on your device',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    ),
                    _settingItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About UIU CGPA Calculator AI',
                      subtitle: 'Version 1.0.0 • Developer: Sourav Saha (sourav.com.bd)',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onTap: () => _showAboutDialog(context, isDark, surface, borderColor, textPri, textSec),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileStat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75))),
        ],
      );

  Widget _divider() => Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.25));

  Widget _honorCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String cgpaRange,
    required String badge,
    required Color badgeColor,
    required bool isQualified,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => UIUBottomSheet.showConvocationHonors(context),
        borderRadius: AppRadius.borderLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 178,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isQualified ? badgeColor.withValues(alpha: 0.75) : borderColor,
              width: isQualified ? 1.8 : 1.0,
            ),
            boxShadow: isQualified
                ? [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: (isQualified ? badgeColor : (isDark ? Colors.white12 : Colors.black12)).withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(
                      icon,
                      color: isQualified ? badgeColor : textSec,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isQualified ? AppColors.success : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05))),
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(
                        color: (isQualified ? AppColors.success : borderColor).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isQualified ? Colors.white : textSec,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: textPri,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textSec,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isQualified ? badgeColor.withValues(alpha: 0.08) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  cgpaRange,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isQualified ? badgeColor : textSec,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(
    BuildContext context,
    bool isDark,
    Color surface,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.borderLg,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UIU CGPA Calculator AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: AppRadius.borderFull,
                            ),
                            child: const Text(
                              'v1.0.0 • Official Release',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'A dedicated academic companion designed specifically for United International University (UIU) students to accurately track CGPA, plan trimesters, predict target grades, and generate official tuition fee breakdowns.',
                style: AppTypography.bodySmall.copyWith(color: textSec, height: 1.45, fontSize: 11.5),
              ),

              const SizedBox(height: 14),

              // Developer Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'SS',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sourav Saha',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: textPri,
                                ),
                              ),
                              Text(
                                'Computer Science & Engineering • UIU',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: textSec,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse('https://sourav.com.bd');
                        try {
                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!launched) {
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          }
                        } catch (_) {
                          Clipboard.setData(const ClipboardData(text: 'https://sourav.com.bd'));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied https://sourav.com.bd to clipboard'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: AppRadius.borderMd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.language_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'www.sourav.com.bd',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.copy_rounded, size: 10, color: AppColors.primary),
                                  SizedBox(width: 3),
                                  Text(
                                    'Copy',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                elevation: 0,
              ),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.soft,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700, fontSize: 13, color: textPri)),
        subtitle: Text(subtitle,
            style: AppTypography.bodySmall.copyWith(fontSize: 11, color: textSec)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserProfileProvider provider,
      bool isDark, Color surface, Color borderColor, Color textPri, Color textSec) {
    final student = provider.profile;
    final nameCtrl = TextEditingController(text: student.name);
    final idCtrl = TextEditingController(text: student.studentId);
    final batchCtrl = TextEditingController(text: student.batch);
    final cgpaCtrl = TextEditingController(text: student.currentCGPA.toStringAsFixed(2));
    final creditsCtrl = TextEditingController(text: student.completedCredits.toStringAsFixed(0));
    final totalCreditsCtrl = TextEditingController(
      text: student.totalDegreeCredits > 0 ? student.totalDegreeCredits.toStringAsFixed(0) : '138',
    );
    final targetCtrl = TextEditingController(text: student.targetCGPA.toStringAsFixed(2));

    idCtrl.addListener(() {
      final batch = extractBatchFromId(idCtrl.text);
      if (batch.isNotEmpty && batchCtrl.text.length != 3) {
        batchCtrl.text = batch;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Edit Profile',
                  style: AppTypography.headlineMedium.copyWith(
                      color: textPri, fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 16),
              _editField('Full Name', nameCtrl, textPri, borderColor, surface),
              _editField('Student ID', idCtrl, textPri, borderColor, surface,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
              _editField('Batch', batchCtrl, textPri, borderColor, surface,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)]),
              Row(
                children: [
                  Expanded(child: _editField('Current CGPA', cgpaCtrl, textPri, borderColor, surface,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 10),
                  Expanded(child: _editField('Credits Completed', creditsCtrl, textPri, borderColor, surface,
                      keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _editField('Target CGPA', targetCtrl, textPri, borderColor, surface,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 10),
                  Expanded(child: _editField('Total Required Cr *', totalCreditsCtrl, textPri, borderColor, surface,
                      keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final reqCredits = double.tryParse(totalCreditsCtrl.text.trim()) ?? 0.0;
                    if (reqCredits <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Total Required Credits is mandatory and must be > 0 (e.g. 138)!'),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    await provider.saveProfile(student.copyWith(
                      name: nameCtrl.text.trim(),
                      studentId: idCtrl.text.trim(),
                      batch: batchCtrl.text.trim().isNotEmpty ? batchCtrl.text.trim() : student.batch,
                      currentCGPA: double.tryParse(cgpaCtrl.text) ?? student.currentCGPA,
                      completedCredits: double.tryParse(creditsCtrl.text) ?? student.completedCredits,
                      totalDegreeCredits: reqCredits,
                      targetCGPA: double.tryParse(targetCtrl.text) ?? student.targetCGPA,
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
                    elevation: 0,
                  ),
                  child: Text('Save Changes',
                      style: AppTypography.titleMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, Color textPri,
      Color borderColor, Color surface,
      {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: textPri, fontWeight: FontWeight.w700, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
              borderRadius: AppRadius.borderBase,
              borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderBase,
              borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderBase,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _handleDirectImportJson(BuildContext context, UserProfileProvider provider) async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Select Academic Backup JSON',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes);

      if (content.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected JSON backup file is empty.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }

      final success = await provider.importBackupJson(content.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Academic history & profile restored successfully from JSON!'
                : 'Invalid backup JSON file structure.'),
            backgroundColor: success ? AppColors.success : AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import JSON file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleDirectExportJson(BuildContext context, UserProfileProvider provider) async {
    try {
      final jsonStr = provider.exportBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'uiu_academic_backup_$timestamp.json';

      bool saved = false;
      String savedLocation = filename;

      try {
        final uri = await FilePicker.saveFile(
          dialogTitle: 'Save Academic Backup JSON',
          fileName: filename,
          bytes: bytes,
          mimeType: 'application/json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (uri != null) {
          saved = true;
          savedLocation = uri.path.isNotEmpty ? uri.path.split('/').last : filename;
        }
      } catch (_) {}

      // On Android fallback to Download folder if picker was dismissed/unavailable
      if (!saved && !kIsWeb && Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final target = File('${downloadDir.path}/$filename');
            await target.writeAsBytes(bytes);
            saved = true;
            savedLocation = 'Downloads/$filename';
          }
        } catch (_) {}
      }

      if (saved) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup file saved successfully: $savedLocation'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        await Clipboard.setData(ClipboardData(text: jsonStr));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup JSON downloaded & copied to clipboard!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

