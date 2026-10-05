import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../core/services/academic_distinction_engine.dart';
import '../models/academic_distinction.dart';
import '../core/providers/user_profile_provider.dart';

class AcademicDistinctionsModal extends StatefulWidget {
  final UserProfile profile;
  final bool hasRetakes;
  final int completedTrimesters;

  const AcademicDistinctionsModal({
    super.key,
    required this.profile,
    required this.hasRetakes,
    required this.completedTrimesters,
  });

  static void show(
    BuildContext context, {
    required UserProfile profile,
    required bool hasRetakes,
    required int completedTrimesters,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AcademicDistinctionsModal(
        profile: profile,
        hasRetakes: hasRetakes,
        completedTrimesters: completedTrimesters,
      ),
    );
  }

  @override
  State<AcademicDistinctionsModal> createState() => _AcademicDistinctionsModalState();
}

class _AcademicDistinctionsModalState extends State<AcademicDistinctionsModal> {
  bool _hasImprovementExam = false;
  bool _hasMakeupExam = false;
  bool _withinNormalDuration = true;
  bool? _isBatchTopper;
  bool? _isFacultyTopper;
  bool _hasFGrades = false;

  @override
  void initState() {
    super.initState();
    _withinNormalDuration = widget.completedTrimesters <= 12;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final surface = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final params = AcademicDistinctionParams(
      currentCgpa: widget.profile.currentCGPA,
      completedCredits: widget.profile.completedCredits,
      totalRequiredCredits: widget.profile.totalDegreeCredits,
      completedTrimesters: _withinNormalDuration ? 12 : 13,
      hasRetakes: widget.hasRetakes,
      hasImprovementExam: _hasImprovementExam,
      hasMakeupExam: _hasMakeupExam,
      hasFGrades: _hasFGrades,
      isBatchTopper: _isBatchTopper,
      isFacultyTopper: _isFacultyTopper,
      academicSystem: (widget.profile.program.toLowerCase().contains('pharmacy') ||
              widget.profile.department.toLowerCase().contains('pharmacy'))
          ? 'semester'
          : 'trimester',
    );

    final distinctions = AcademicDistinctionEngine.evaluateDistinctions(params);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(Icons.military_tech_rounded, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UIU Academic Distinction & Honors',
                        style: AppTypography.headlineSmall.copyWith(
                          color: textPri,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Official UIU Convocation Eligibility Rules',
                        style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: textSec,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Strict Accuracy & Source Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF0284C7), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Strict UIU Official Policy Engine',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Rules are strictly mapped from official UIU examination regulations and convocation ordinances. Unofficial estimates from other universities are excluded.',
                              style: TextStyle(fontSize: 10.5, color: textSec, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Student Academic Snapshot Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('STUDENT ACADEMIC STATUS',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: textSec, letterSpacing: 0.5)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Text(
                              'CGPA ${widget.profile.currentCGPA.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _snapshotItem('Retaken Courses', widget.hasRetakes ? 'Yes (Detected)' : 'None',
                              widget.hasRetakes ? Colors.orange : AppColors.success, textSec),
                          _snapshotItem('Normal Duration', _withinNormalDuration ? 'Within 12 Terms' : 'Extended',
                              _withinNormalDuration ? AppColors.success : Colors.red, textSec),
                          _snapshotItem('Program', widget.profile.department.isNotEmpty ? widget.profile.department : 'Undergrad',
                              textPri, textSec),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Interactive Student Examination Parameters (Toggles)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('VERIFY YOUR ELIGIBILITY CONDITIONS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textPri, letterSpacing: 0.4)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Improvement Exam Toggle
                      _toggleRow(
                        title: 'Appeared in Improvement Exam?',
                        subtitle: 'Official UIU Notice: Any Mid/Final Improvement Exam strictly disqualifies from Gold Medal.',
                        value: _hasImprovementExam,
                        isDisqualifier: true,
                        onChanged: (v) => setState(() => _hasImprovementExam = v),
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const Divider(height: 14),

                      // Make-up Exam Toggle
                      _toggleRow(
                        title: 'Appeared in Make-up Exam?',
                        subtitle: 'Official UIU Notice: Any Make-up Exam strictly disqualifies from Gold Medal.',
                        value: _hasMakeupExam,
                        isDisqualifier: true,
                        onChanged: (v) => setState(() => _hasMakeupExam = v),
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const Divider(height: 14),

                      // Any F-Grade Toggle
                      _toggleRow(
                        title: 'Any F Grade on Record?',
                        subtitle: 'Official UIU Rule: Must have no failing grade (F) throughout academic history.',
                        value: _hasFGrades,
                        isDisqualifier: true,
                        onChanged: (v) => setState(() => _hasFGrades = v),
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const Divider(height: 14),

                      // Normal Duration Toggle
                      _toggleRow(
                        title: 'Degree Within Normal Duration (≤ 12 Terms)?',
                        subtitle: 'Undergraduate degrees must be finished in 4 years without extension for honors.',
                        value: _withinNormalDuration,
                        onChanged: (v) => setState(() => _withinNormalDuration = v),
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const Divider(height: 14),

                      // Batch Topper Status Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Batch / School Topper (#1 Rank)?',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: textPri)),
                                const SizedBox(height: 2),
                                Text('Required for Chancellor\'s Gold Medal & Valedictorian.',
                                    style: TextStyle(fontSize: 10, color: textSec)),
                              ],
                            ),
                          ),
                          DropdownButton<bool?>(
                            value: _isBatchTopper,
                            dropdownColor: surface,
                            underline: const SizedBox(),
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: textPri),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Pending / Unknown')),
                              DropdownMenuItem(value: true, child: Text('Yes (Rank #1)')),
                              DropdownMenuItem(value: false, child: Text('No')),
                            ],
                            onChanged: (v) => setState(() => _isBatchTopper = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Section title
                Text(
                  'HONORS & MEDALS STATUS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSec, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),

                // Distinction Cards
                ...distinctions.map((d) => _buildDistinctionCard(d, isDark, surface, borderColor, textPri, textSec)),

                const SizedBox(height: 14),

                // UIU Academic Policies Reference
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gavel_rounded, size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('UIU OFFICIAL POLICIES SUMMARY',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: textPri)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _bulletPoint(
                        'Gold Medal Rule: Mid-Term or Final Improvement Examination examinees and Make-up Examination examinees are permanently barred from receiving Gold Medals.',
                        textSec,
                      ),
                      const SizedBox(height: 4),
                      _bulletPoint(
                        'Cum Laude: UIU Convocation does not confer Cum Laude (only Summa Cum Laude, Magna Cum Laude, and Gold Medals).',
                        textSec,
                      ),
                      const SizedBox(height: 4),
                      _bulletPoint(
                        'Academic Probation: Term GPA < 2.00 for two consecutive trimesters/semesters or CGPA < 2.00 puts a student on Academic Probation (UIU Academic Regulation, Spring 2025).',
                        textSec,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _snapshotItem(String title, String value, Color valColor, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: textSec)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: valColor)),
      ],
    );
  }

  Widget _toggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textPri,
    required Color textSec,
    bool isDisqualifier = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: textPri)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDisqualifier && value ? Colors.red : textSec,
                  fontWeight: isDisqualifier && value ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: isDisqualifier ? Colors.red : AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDistinctionCard(
    AcademicDistinction d,
    bool isDark,
    Color surface,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    Color statusBg;
    Color statusText;
    String statusLabel;
    IconData statusIcon;

    switch (d.status) {
      case EligibilityStatus.eligible:
        statusBg = const Color(0xFF10B981).withValues(alpha: 0.15);
        statusText = const Color(0xFF059669);
        statusLabel = 'ELIGIBLE';
        statusIcon = Icons.check_circle_rounded;
        break;
      case EligibilityStatus.disqualified:
        statusBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        statusText = const Color(0xFFDC2626);
        statusLabel = 'DISQUALIFIED';
        statusIcon = Icons.cancel_rounded;
        break;
      case EligibilityStatus.cannotDetermine:
        statusBg = const Color(0xFF8B5CF6).withValues(alpha: 0.15);
        statusText = const Color(0xFF7C3AED);
        statusLabel = 'CANNOT DETERMINE';
        statusIcon = Icons.help_outline_rounded;
        break;
      case EligibilityStatus.notEligible:
        statusBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
        statusText = textSec;
        statusLabel = 'NOT ELIGIBLE';
        statusIcon = Icons.lock_outline_rounded;
        break;
      case EligibilityStatus.notAwarded:
        statusBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        statusText = const Color(0xFF64748B);
        statusLabel = 'NOT AWARDED AT UIU';
        statusIcon = Icons.info_outline_rounded;
        break;
    }

    String verifLabel;
    Color verifColor;
    switch (d.verificationLevel) {
      case VerificationLevel.officiallyVerified:
        verifLabel = 'Officially Verified';
        verifColor = const Color(0xFF059669);
        break;
      case VerificationLevel.partiallyVerified:
        verifLabel = 'Partially Verified';
        verifColor = const Color(0xFFD97706);
        break;
      case VerificationLevel.notAwardedAtUIU:
        verifLabel = 'Verified: Not Conferred at UIU';
        verifColor = const Color(0xFF64748B);
        break;
      case VerificationLevel.unverified:
        verifLabel = 'Official Criterion Unverified';
        verifColor = const Color(0xFFDC2626);
        break;
    }

    IconData cardIcon;
    if (d.honorType == 'Gold Medal') {
      cardIcon = Icons.military_tech_rounded;
    } else if (d.id == 'summa_cum_laude') {
      cardIcon = Icons.stars_rounded;
    } else if (d.id == 'magna_cum_laude') {
      cardIcon = Icons.verified_rounded;
    } else if (d.id == 'valedictorian') {
      cardIcon = Icons.record_voice_over_rounded;
    } else {
      cardIcon = Icons.emoji_events_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: d.status == EligibilityStatus.eligible ? const Color(0xFF10B981).withValues(alpha: 0.4) : borderColor,
          width: d.status == EligibilityStatus.eligible ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (d.honorType == 'Gold Medal' ? const Color(0xFFD97706) : AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(cardIcon, size: 20, color: d.honorType == 'Gold Medal' ? const Color(0xFFD97706) : AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textPri)),
                    const SizedBox(height: 2),
                    Text(
                      d.minCgpa != null ? 'Minimum CGPA: ${d.minCgpa!.toStringAsFixed(2)}' : d.honorType,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: textSec),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: AppRadius.borderSm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusText),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: statusText, letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status Reason
          Text(
            d.statusReason,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: d.status == EligibilityStatus.disqualified ? Colors.red : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
              height: 1.35,
            ),
          ),

          if (d.disqualifiers.isNotEmpty && d.status == EligibilityStatus.disqualified) ...[
            const SizedBox(height: 6),
            ...d.disqualifiers.map((dq) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                      Expanded(
                        child: Text(dq, style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // Verification badge & Source
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded, size: 12, color: verifColor),
                  const SizedBox(width: 4),
                  Text(
                    verifLabel,
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: verifColor),
                  ),
                ],
              ),
              Text(
                'UIU Convocation Ordinance',
                style: TextStyle(fontSize: 9, color: textSec),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 10.5, color: color, height: 1.35),
          ),
        ),
      ],
    );
  }
}
