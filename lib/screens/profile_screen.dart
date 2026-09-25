import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../core/providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/subtle_background.dart';
import '../widgets/uiu_bottom_sheet.dart';

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
    final isGoldEligible = cgpa >= 3.98;
    final isSummaEligible = cgpa >= 3.95 && !hasRetakes;
    final isMagnaEligible = cgpa >= 3.85 && cgpa < 3.95;
    final isCumLaudeEligible = cgpa >= 3.75 && cgpa < 3.85;

    // Avatar initials
    final initials = student.name.isNotEmpty
        ? student.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

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

              // ── Avatar & Info Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                        // Avatar with initials
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          student.name.isNotEmpty ? student.name : 'Student Name',
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${student.studentId.isNotEmpty ? student.studentId : '—'} • Batch ${student.batch.isNotEmpty ? student.batch : '—'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: AppRadius.borderFull,
                          ),
                          child: Text(
                            student.department,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _profileStat('CGPA', student.currentCGPA.toStringAsFixed(2)),
                            _divider(),
                            _profileStat('Credits', '${student.completedCredits.toInt()}'),
                            _divider(),
                            _profileStat('Target', student.targetCGPA.toStringAsFixed(2)),
                            _divider(),
                            _profileStat('Batch', student.batch.isNotEmpty ? student.batch : '—'),
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
                        onTap: () => UIUBottomSheet.showConvocationHonors(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Criteria & Rules',
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
                        title: 'Gold Medal',
                        subtitle: 'সর্বোচ্চ সম্মান',
                        cgpaRange: 'Batch Topper • Top CGPA',
                        badge: isGoldEligible ? 'Top Runner' : 'Batch Top',
                        badgeColor: const Color(0xFFD97706),
                        isQualified: isGoldEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const SizedBox(width: 10),
                      _honorCard(
                        context: context,
                        icon: Icons.stars_rounded,
                        title: 'Summa Cum Laude',
                        subtitle: 'Highest Honor',
                        cgpaRange: 'CGPA 3.95 – 4.00',
                        badge: isSummaEligible
                            ? 'On Track'
                            : (hasRetakes ? 'Retake Restricted' : 'No Retakes'),
                        badgeColor: const Color(0xFF8B5CF6),
                        isQualified: isSummaEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const SizedBox(width: 10),
                      _honorCard(
                        context: context,
                        icon: Icons.verified_rounded,
                        title: 'Magna Cum Laude',
                        subtitle: 'Great Honor',
                        cgpaRange: 'CGPA 3.85 – 3.94',
                        badge: isMagnaEligible ? 'On Track' : 'Retake OK',
                        badgeColor: const Color(0xFF2563EB),
                        isQualified: isMagnaEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const SizedBox(width: 10),
                      _honorCard(
                        context: context,
                        icon: Icons.emoji_events_rounded,
                        title: 'Cum Laude',
                        subtitle: 'Honor',
                        cgpaRange: 'CGPA 3.75 – 3.84',
                        badge: isCumLaudeEligible ? 'On Track' : 'Retake OK',
                        badgeColor: const Color(0xFF059669),
                        isQualified: isCumLaudeEligible,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
                      subtitle: 'Gold Medal, Summa, Magna & Cum Laude requirements',
                      surface: surface,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onTap: () => UIUBottomSheet.showConvocationHonors(context),
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => UIUBottomSheet.showConvocationHonors(context),
        borderRadius: AppRadius.borderLg,
        child: Container(
          width: 172,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isQualified ? badgeColor.withValues(alpha: 0.6) : borderColor,
              width: isQualified ? 1.5 : 1,
            ),
            boxShadow: AppShadows.soft,
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
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(icon, color: badgeColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isQualified ? AppColors.success : badgeColor).withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isQualified) ...[
                          const Icon(Icons.check_circle_rounded, size: 10, color: AppColors.success),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isQualified ? AppColors.success : badgeColor,
                          ),
                        ),
                      ],
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
                  color: badgeColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  cgpaRange,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
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
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderMd,
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'UIU CGPA Calculator AI',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900, color: textPri),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A dedicated academic companion for students of United International University (UIU). Calculate CGPA, plan trimesters, predict target grades, and track academic honors.',
              style: AppTypography.bodySmall.copyWith(color: textSec, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _aboutRow('Developer', 'Sourav Saha', AppColors.primaryDark),
                  const SizedBox(height: 6),
                  _aboutRow('Website', 'www.sourav.com.bd', AppColors.primary),
                  const SizedBox(height: 6),
                  _aboutRow('Version', '1.0.0 (Release)', AppColors.primaryDark),
                  const SizedBox(height: 6),
                  _aboutRow('Institution', 'United International University', AppColors.primaryDark),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: valColor)),
      ],
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
                  Expanded(child: _editField('Credits Done', creditsCtrl, textPri, borderColor, surface,
                      keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: _editField('Target CGPA', targetCtrl, textPri, borderColor, surface,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.saveProfile(student.copyWith(
                      name: nameCtrl.text.trim(),
                      studentId: idCtrl.text.trim(),
                      batch: batchCtrl.text.trim().isNotEmpty ? batchCtrl.text.trim() : student.batch,
                      currentCGPA: double.tryParse(cgpaCtrl.text) ?? student.currentCGPA,
                      completedCredits: double.tryParse(creditsCtrl.text) ?? student.completedCredits,
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
}
