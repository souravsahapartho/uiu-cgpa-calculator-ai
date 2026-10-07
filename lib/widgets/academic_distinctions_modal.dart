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
  int _selectedTabIndex = 0;

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
    final selectedDistinction = (_selectedTabIndex >= 0 && _selectedTabIndex < distinctions.length)
        ? distinctions[_selectedTabIndex]
        : distinctions.first;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
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
            padding: const EdgeInsets.fromLTRB(18, 8, 14, 10),
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
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Official UIU Convocation Eligibility Rules',
                        style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
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

          // Horizontal Distinction Selector Tabs (Separate dynamic option for each honor)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: distinctions.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx, index) {
                final d = distinctions[index];
                final isSelected = _selectedTabIndex == index;
                final isEligible = d.status == EligibilityStatus.eligible;
                final isDisqualified = d.status == EligibilityStatus.disqualified;

                Color activeColor;
                if (isEligible) {
                  activeColor = const Color(0xFF059669);
                } else if (isDisqualified) {
                  activeColor = const Color(0xFFDC2626);
                } else if (d.status == EligibilityStatus.notAwarded) {
                  activeColor = const Color(0xFF64748B);
                } else {
                  activeColor = AppColors.primary;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: AppRadius.borderFull,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        borderRadius: AppRadius.borderFull,
                        border: Border.all(
                          color: isSelected ? activeColor : borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getHonorIcon(d),
                            size: 13,
                            color: isSelected ? Colors.white : textSec,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getShortHonorName(d.name),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? Colors.white : textPri,
                            ),
                          ),
                          if (isEligible) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Scrollable Content for Selected Distinction & Interactive Parameters
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Student Academic Snapshot Card (Responsive row/column)
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
                          Text(
                            'STUDENT ACADEMIC STATUS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: textSec,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _snapshotItem(
                              'Retaken Courses',
                              widget.hasRetakes ? 'Yes' : 'None',
                              widget.hasRetakes ? Colors.orange : AppColors.success,
                              textSec,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: _snapshotItem(
                              'Duration',
                              _withinNormalDuration ? '≤ 12 Terms' : 'Extended',
                              _withinNormalDuration ? AppColors.success : Colors.red,
                              textSec,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: _snapshotItem(
                              'Program / Dept',
                              widget.profile.department.isNotEmpty ? widget.profile.department : 'Undergraduate',
                              textPri,
                              textSec,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Selected Distinction Detailed Card
                _buildFocusedDistinctionCard(
                  selectedDistinction,
                  isDark,
                  surface,
                  borderColor,
                  textPri,
                  textSec,
                ),

                const SizedBox(height: 12),

                // Interactive Student Examination Parameters (Toggles for Verification)
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
                          Text(
                            'ELIGIBILITY VERIFICATION TOGGLES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: textPri,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Improvement Exam Toggle
                      _toggleRow(
                        title: 'Appeared in Improvement Exam?',
                        subtitle: 'Mid/Final Improvement Exam strictly disqualifies from Gold Medals.',
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
                        subtitle: 'Any Make-up Exam strictly disqualifies from Gold Medals.',
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
                        subtitle: 'Must have no failing grade (F) throughout academic history.',
                        value: _hasFGrades,
                        isDisqualifier: true,
                        onChanged: (v) => setState(() => _hasFGrades = v),
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const Divider(height: 14),

                      // Normal Duration Toggle
                      _toggleRow(
                        title: 'Degree Completed Within Normal Duration (≤ 12 Terms)?',
                        subtitle: 'Degrees must be completed in normal timeframe without extension.',
                        value: _withinNormalDuration,
                        onChanged: (v) => setState(() => _withinNormalDuration = v),
                        textPri: textPri,
                        textSec: textSec,
                      ),
                      const Divider(height: 14),

                      // Batch Topper Status Selector
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batch / School Topper (#1 Rank)?',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: textPri),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Required for Chancellor\'s Gold Medal & Valedictorian.',
                                  style: TextStyle(fontSize: 10, color: textSec),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<bool?>(
                            value: _isBatchTopper,
                            dropdownColor: surface,
                            underline: const SizedBox(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textPri),
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

                const SizedBox(height: 14),

                // Official Policies & Regulations Note
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
                          Text(
                            'UIU OFFICIAL CONVOCATION POLICIES',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: textPri),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _bulletPoint(
                        'Gold Medal Rule: Mid-Term or Final Improvement Examination examinees and Make-up Examination examinees are permanently barred from receiving Gold Medals.',
                        textSec,
                      ),
                      const SizedBox(height: 4),
                      _bulletPoint(
                        'Cum Laude: UIU Convocation does not confer Cum Laude (only Summa Cum Laude, Magna Cum Laude, and Gold Medals are awarded).',
                        textSec,
                      ),
                      const SizedBox(height: 4),
                      _bulletPoint(
                        'Academic Probation: Term GPA < 2.00 for two consecutive terms or CGPA < 2.00 places a student on Academic Probation.',
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

  IconData _getHonorIcon(AcademicDistinction d) {
    if (d.honorType == 'Gold Medal') {
      return Icons.military_tech_rounded;
    } else if (d.id == 'summa_cum_laude') {
      return Icons.stars_rounded;
    } else if (d.id == 'magna_cum_laude') {
      return Icons.verified_rounded;
    } else if (d.id == 'valedictorian') {
      return Icons.record_voice_over_rounded;
    } else {
      return Icons.emoji_events_rounded;
    }
  }

  String _getShortHonorName(String fullName) {
    if (fullName.contains('Chancellor\'s Gold Medal') && !fullName.contains('Vice')) {
      return 'Chancellor Gold';
    }
    if (fullName.contains('Vice-Chancellor\'s Gold Medal')) {
      return 'VC Gold';
    }
    if (fullName.contains('Summa Cum Laude')) {
      return 'Summa Cum Laude';
    }
    if (fullName.contains('Magna Cum Laude')) {
      return 'Magna Cum Laude';
    }
    if (fullName.contains('Cum Laude')) {
      return 'Cum Laude';
    }
    if (fullName.contains('Valedictorian')) {
      return 'Valedictorian';
    }
    return fullName;
  }

  Widget _snapshotItem(String title, String value, Color valColor, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: textSec),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: valColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: isDisqualifier ? Colors.red : AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildFocusedDistinctionCard(
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
        verifLabel = 'Officially Verified Criterion';
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

    final cardIcon = _getHonorIcon(d);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: d.status == EligibilityStatus.eligible
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : (d.status == EligibilityStatus.disqualified ? Colors.red.withValues(alpha: 0.3) : borderColor),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (d.honorType == 'Gold Medal' ? const Color(0xFFD97706) : AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(cardIcon, size: 22, color: d.honorType == 'Gold Medal' ? const Color(0xFFD97706) : AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: textPri),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.minCgpa != null ? 'Minimum Required CGPA: ${d.minCgpa!.toStringAsFixed(2)}' : d.honorType,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: textSec),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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

          const SizedBox(height: 10),

          // Honor Description
          Text(
            d.description,
            style: TextStyle(
              fontSize: 11,
              color: textSec,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          // Status Reason
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: d.status == EligibilityStatus.eligible
                  ? const Color(0xFF10B981).withValues(alpha: 0.08)
                  : (d.status == EligibilityStatus.disqualified
                      ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))),
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: d.status == EligibilityStatus.eligible
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : (d.status == EligibilityStatus.disqualified ? Colors.red.withValues(alpha: 0.3) : borderColor),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  d.status == EligibilityStatus.eligible
                      ? Icons.check_circle_rounded
                      : (d.status == EligibilityStatus.disqualified ? Icons.error_outline_rounded : Icons.info_outline_rounded),
                  size: 16,
                  color: d.status == EligibilityStatus.eligible
                      ? const Color(0xFF059669)
                      : (d.status == EligibilityStatus.disqualified ? Colors.red : AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    d.statusReason,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: d.status == EligibilityStatus.disqualified
                          ? Colors.red
                          : (d.status == EligibilityStatus.eligible ? const Color(0xFF059669) : textPri),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (d.disqualifiers.isNotEmpty && d.status == EligibilityStatus.disqualified) ...[
            const SizedBox(height: 8),
            Text(
              'Disqualification Triggers:',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.red),
            ),
            const SizedBox(height: 4),
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

          if (d.requirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Official Evaluation Checklist:',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: textPri),
            ),
            const SizedBox(height: 6),
            ...d.requirements.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        req.isMet ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        size: 14,
                        color: req.isMet ? const Color(0xFF059669) : textSec,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.title,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: req.isMet ? textPri : textSec,
                              ),
                            ),
                            Text(
                              req.description,
                              style: TextStyle(fontSize: 9.5, color: textSec),
                            ),
                          ],
                        ),
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
