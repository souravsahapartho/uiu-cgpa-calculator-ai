import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../core/utils/tuition_pdf_generator.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import '../widgets/subtle_background.dart';
import '../widgets/uiu_header.dart';

class RetakeCourseItem {
  final String id;
  String name;
  double credit;

  RetakeCourseItem({
    required this.id,
    required this.name,
    this.credit = 3.0,
  });
}

class TuitionFeeScreen extends StatefulWidget {
  const TuitionFeeScreen({super.key});

  @override
  State<TuitionFeeScreen> createState() => _TuitionFeeScreenState();
}

class _TuitionFeeScreenState extends State<TuitionFeeScreen> {
  static const _keyTuitionSystem = 'uiu_tuition_system';
  static const _keyCreditFee = 'uiu_tuition_credit_fee';
  static const _keySessionFee = 'uiu_tuition_session_fee';
  static const _keyTuitionTutorialCompleted = 'uiu_tuition_tutorial_completed';

  String? _system; // null initially if user hasn't selected or saved yet!
  String _discountType = 'scholarship'; // 'scholarship' or 'waiver'

  late final TextEditingController _creditFeeCtrl;
  late final TextEditingController _sessionFeeCtrl;
  late final TextEditingController _registeredCreditsCtrl;
  late final TextEditingController _customWaiverCtrl;
  late final TextEditingController _firstRetakeCreditsCtrl;
  late final TextEditingController _subsequentRetakeCreditsCtrl;

  final List<RetakeCourseItem> _firstRetakes = [];
  final List<RetakeCourseItem> _subsequentRetakes = [];

  double _waiverPercent = 0.0;
  bool _isCustomWaiver = false;
  int _missedInstallments = 0;
  bool _tutorialCompleted = false;

  @override
  void initState() {
    super.initState();
    _creditFeeCtrl = TextEditingController();
    _sessionFeeCtrl = TextEditingController();
    _registeredCreditsCtrl = TextEditingController();
    _customWaiverCtrl = TextEditingController();
    _firstRetakeCreditsCtrl = TextEditingController();
    _subsequentRetakeCreditsCtrl = TextEditingController();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSystem = prefs.getString(_keyTuitionSystem);
    final savedCreditFee = prefs.getString(_keyCreditFee);
    final savedSessionFee = prefs.getString(_keySessionFee);
    final tutorialDone = prefs.getBool(_keyTuitionTutorialCompleted) ?? false;

    if (mounted) {
      setState(() {
        if (savedSystem != null && (savedSystem == 'trimester' || savedSystem == 'semester')) {
          _system = savedSystem;
        }
        if (savedCreditFee != null && savedCreditFee.isNotEmpty) {
          _creditFeeCtrl.text = savedCreditFee;
        }
        if (savedSessionFee != null && savedSessionFee.isNotEmpty) {
          _sessionFeeCtrl.text = savedSessionFee;
        }
        _tutorialCompleted = tutorialDone;
      });
    }
  }

  Future<void> _saveSystemPreference(String sys) async {
    setState(() => _system = sys);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTuitionSystem, sys);
  }

  Future<void> _saveCreditFeePreference(String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCreditFee, val.trim());
  }

  Future<void> _saveSessionFeePreference(String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySessionFee, val.trim());
  }

  
  Future<void> _dismissTutorial() async {
    setState(() => _tutorialCompleted = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTuitionTutorialCompleted, true);
  }

  Future<void> _checkCompleteTutorial() async {
    if (!_tutorialCompleted) {
      setState(() => _tutorialCompleted = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyTuitionTutorialCompleted, true);
    }
  }

  int get _tutorialCurrentStep {
    if (_system == null) return 1;
    if (_creditFeeCtrl.text.trim().isEmpty) return 2;
    final regCr = double.tryParse(_registeredCreditsCtrl.text.trim()) ?? 0.0;
    if (regCr <= 0) return 3;
    if (_waiverPercent == 0 && !_isCustomWaiver) return 4;
    return 5;
  }

  @override
  void dispose() {
    _creditFeeCtrl.dispose();
    _sessionFeeCtrl.dispose();
    _registeredCreditsCtrl.dispose();
    _customWaiverCtrl.dispose();
    _firstRetakeCreditsCtrl.dispose();
    _subsequentRetakeCreditsCtrl.dispose();
    super.dispose();
  }

  void _addFirstRetake() {
    setState(() {
      final idx = _firstRetakes.length + 1;
      _firstRetakes.add(
        RetakeCourseItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Retake Course $idx',
          credit: 3.0,
        ),
      );
    });
  }

  void _addSubsequentRetake() {
    setState(() {
      final idx = _subsequentRetakes.length + 1;
      _subsequentRetakes.add(
        RetakeCourseItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Subsequent Course $idx',
          credit: 3.0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_tutorialCompleted && _tutorialCurrentStep == 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkCompleteTutorial();
      });
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionColor = isDark ? AppColors.darkSection : AppColors.section;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    // Numerical Calculations (Placeholders: 6500, 5000, 0)
    final creditFee = double.tryParse(_creditFeeCtrl.text.trim()) ?? 6500.0;
    final sessionFee = double.tryParse(_sessionFeeCtrl.text.trim()) ?? 5000.0;
    final totalRegCredits = double.tryParse(_registeredCreditsCtrl.text.trim()) ?? 0.0;

    double firstRetakeCr = double.tryParse(_firstRetakeCreditsCtrl.text.trim()) ?? 0.0;
    for (final c in _firstRetakes) {
      firstRetakeCr += c.credit;
    }

    double subRetakeCr = double.tryParse(_subsequentRetakeCreditsCtrl.text.trim()) ?? 0.0;
    for (final c in _subsequentRetakes) {
      subRetakeCr += c.credit;
    }

    final totalRetakeCr = firstRetakeCr + subRetakeCr;
    final regularCredits = totalRegCredits > 0
        ? (totalRegCredits - totalRetakeCr).clamp(0.0, 999.0)
        : 0.0;

    // Step 2: 1st-time Retake (Automatic 50% discount for everyone)
    final firstRetakeNormal = firstRetakeCr * creditFee;
    final firstRetakeDiscount = firstRetakeNormal * 0.50;
    final firstRetakeTuition = firstRetakeNormal - firstRetakeDiscount;

    // Step 3: Regular & Subsequent Retake Credits are eligible for Scholarship / Waiver
    final eligibleCredits = regularCredits + subRetakeCr;
    final double discountPct = _isCustomWaiver
        ? (double.tryParse(_customWaiverCtrl.text) ?? 0.0)
        : _waiverPercent;

    // Scholarship has a maximum cap of 13 credits; Tuition Waiver has no credit limit
    final double discountCredits = _discountType == 'scholarship'
        ? eligibleCredits.clamp(0.0, 13.0)
        : eligibleCredits;

    final waiverDiscount = (discountCredits * creditFee) * (discountPct / 100.0);
    final regularAndSubTuition = (eligibleCredits * creditFee) - waiverDiscount;
    final subRetakeTuition = subRetakeCr * creditFee;
    final regularTuition = regularCredits * creditFee;

    // Step 4: Totals
    final totalTuition = regularAndSubTuition + firstRetakeTuition;
    final totalDiscount = firstRetakeDiscount + waiverDiscount;
    final totalPayable = totalTuition + sessionFee;

    final lateFine = _missedInstallments * 500.0;
    final totalWithFine = totalPayable + lateFine;

    return Scaffold(
      backgroundColor: bg,
      body: SubtleBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Fixed Top Navigation Header
              UIUHeader(
                title: 'Tuition Fee',
                subtitle: 'Official UIU Fee Structure & Policies',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restart_alt_rounded, color: AppColors.danger, size: 21),
                      tooltip: 'Reset All Fields',
                      onPressed: _resetAllFields,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.history_rounded, color: AppColors.accent, size: 21),
                      tooltip: 'Calculation History',
                      onPressed: () => _showTuitionHistoryModal(context),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 21),
                      tooltip: 'Summary of UIU Rules',
                      onPressed: () => _showTuitionFeeRulesModal(context),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Guided Step Tracker
                    if (!_tutorialCompleted)
                      _buildStepTracker(_tutorialCurrentStep, surface, borderColor, textPri, textSec, isDark),

                    // Interactive Step Banner
                    if (!_tutorialCompleted)
                      _buildGuidedStepBanner(_tutorialCurrentStep, surface, borderColor, textPri, textSec, isDark),

                    // Academic System Selector Toggle (User must choose!)
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: sectionColor,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(
                          color: _system == null ? AppColors.primary : borderColor,
                          width: _system == null ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'STEP 1: ACADEMIC SYSTEM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: _system == null ? AppColors.primary : textSec,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (_system != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text('Saved', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                                    ],
                                  )
                                else
                                  Text('Select One', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _systemTabButton(
                                  label: 'Trimester (3 Terms)',
                                  icon: Icons.calendar_month_rounded,
                                  isSelected: _system == 'trimester',
                                  onTap: () => _saveSystemPreference('trimester'),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _systemTabButton(
                                  label: 'Semester (2 Terms)',
                                  icon: Icons.date_range_rounded,
                                  isSelected: _system == 'semester',
                                  onTap: () => _saveSystemPreference('semester'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Primary Inputs Card
                    _cardWrapper(
                      surface: surface,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payments_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text('Fee & Credit Parameters',
                                  style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800, color: textPri)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('CREDIT FEE (BDT)',
                                        style: AppTypography.labelSmall.copyWith(
                                            fontSize: 10, fontWeight: FontWeight.w800, color: textSec)),
                                    const SizedBox(height: 4),
                                    _numberInput(
                                      controller: _creditFeeCtrl,
                                      hintText: '6500',
                                      surface: sectionColor,
                                      borderColor: borderColor,
                                      textPri: textPri,
                                      onChanged: (val) {
                                        _saveCreditFeePreference(val);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('SESSION FEE (BDT)',
                                        style: AppTypography.labelSmall.copyWith(
                                            fontSize: 10, fontWeight: FontWeight.w800, color: textSec)),
                                    const SizedBox(height: 4),
                                    _numberInput(
                                      controller: _sessionFeeCtrl,
                                      hintText: '5000',
                                      surface: sectionColor,
                                      borderColor: borderColor,
                                      textPri: textPri,
                                      onChanged: (val) {
                                        _saveSessionFeePreference(val);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('TOTAL REGISTERED CREDITS THIS TERM',
                              style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10, fontWeight: FontWeight.w800, color: textSec)),
                          const SizedBox(height: 4),
                          _numberInput(
                            controller: _registeredCreditsCtrl,
                            hintText: 'e.g. 13.0',
                            surface: sectionColor,
                            borderColor: borderColor,
                            textPri: textPri,
                            stepDecimals: true,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // First-Time Retake Courses Card (50% Off)
                    _cardWrapper(
                      surface: surface,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.replay_rounded, color: AppColors.success, size: 18),
                                      const SizedBox(width: 6),
                                      Text('First-Time Retakes',
                                          style: AppTypography.titleSmall.copyWith(
                                              fontWeight: FontWeight.w800, color: textPri)),
                                    ],
                                  ),
                                  Text('50% discount applies on course tuition',
                                      style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _addFirstRetake,
                                icon: const Icon(Icons.add_rounded, size: 14),
                                label: const Text('Add Course', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('ENTER RETAKE CREDITS (DEFAULT 0)',
                              style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10, fontWeight: FontWeight.w800, color: textSec)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: _numberInput(
                                  controller: _firstRetakeCreditsCtrl,
                                  hintText: '0',
                                  surface: sectionColor,
                                  borderColor: borderColor,
                                  textPri: textPri,
                                  stepDecimals: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _quickCreditChip(
                                label: '0 Cr',
                                creditVal: 0,
                                controller: _firstRetakeCreditsCtrl,
                                surface: sectionColor,
                                border: borderColor,
                                textPri: textPri,
                              ),
                              const SizedBox(width: 4),
                              _quickCreditChip(
                                label: '3 Cr',
                                creditVal: 3,
                                controller: _firstRetakeCreditsCtrl,
                                surface: sectionColor,
                                border: borderColor,
                                textPri: textPri,
                              ),
                              const SizedBox(width: 4),
                              _quickCreditChip(
                                label: '6 Cr',
                                creditVal: 6,
                                controller: _firstRetakeCreditsCtrl,
                                surface: sectionColor,
                                border: borderColor,
                                textPri: textPri,
                              ),
                            ],
                          ),
                          if (_firstRetakes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ...List.generate(_firstRetakes.length, (i) {
                              final item = _firstRetakes[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        initialValue: item.name,
                                        onChanged: (val) => item.name = val,
                                        style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          hintText: 'Course Code/Title',
                                          filled: true,
                                          fillColor: sectionColor,
                                          border: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        initialValue: item.credit.toString(),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (val) {
                                          setState(() {
                                            item.credit = double.tryParse(val) ?? 0.0;
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w800),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixText: 'Cr',
                                          filled: true,
                                          fillColor: sectionColor,
                                          border: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() => _firstRetakes.removeAt(i)),
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          if (_firstRetakes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('${_firstRetakes.length} added courses (${firstRetakeCr.toStringAsFixed(1)} Credits)',
                                style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11)),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subsequent Retake Courses Card (0% Off)
                    _cardWrapper(
                      surface: surface,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 18),
                                      const SizedBox(width: 6),
                                      Text('Subsequent Retakes',
                                          style: AppTypography.titleSmall.copyWith(
                                              fontWeight: FontWeight.w800, color: textPri)),
                                    ],
                                  ),
                                  Text('2nd+ time: No discount (100% full fee)',
                                      style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _addSubsequentRetake,
                                icon: const Icon(Icons.add_rounded, size: 14),
                                label: const Text('Add Course', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('ENTER RETAKE CREDITS (DEFAULT 0)',
                              style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10, fontWeight: FontWeight.w800, color: textSec)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: _numberInput(
                                  controller: _subsequentRetakeCreditsCtrl,
                                  hintText: '0',
                                  surface: sectionColor,
                                  borderColor: borderColor,
                                  textPri: textPri,
                                  stepDecimals: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _quickCreditChip(
                                label: '0 Cr',
                                creditVal: 0,
                                controller: _subsequentRetakeCreditsCtrl,
                                surface: sectionColor,
                                border: borderColor,
                                textPri: textPri,
                              ),
                              const SizedBox(width: 4),
                              _quickCreditChip(
                                label: '3 Cr',
                                creditVal: 3,
                                controller: _subsequentRetakeCreditsCtrl,
                                surface: sectionColor,
                                border: borderColor,
                                textPri: textPri,
                              ),
                              const SizedBox(width: 4),
                              _quickCreditChip(
                                label: '6 Cr',
                                creditVal: 6,
                                controller: _subsequentRetakeCreditsCtrl,
                                surface: sectionColor,
                                border: borderColor,
                                textPri: textPri,
                              ),
                            ],
                          ),
                          if (_subsequentRetakes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ...List.generate(_subsequentRetakes.length, (i) {
                              final item = _subsequentRetakes[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        initialValue: item.name,
                                        onChanged: (val) => item.name = val,
                                        style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          hintText: 'Course Code/Title',
                                          filled: true,
                                          fillColor: sectionColor,
                                          border: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        initialValue: item.credit.toString(),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (val) {
                                          setState(() {
                                            item.credit = double.tryParse(val) ?? 0.0;
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w800),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixText: 'Cr',
                                          filled: true,
                                          fillColor: sectionColor,
                                          border: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: AppRadius.borderMd,
                                              borderSide: BorderSide(color: borderColor)),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() => _subsequentRetakes.removeAt(i)),
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          if (_subsequentRetakes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('${_subsequentRetakes.length} added courses (${subRetakeCr.toStringAsFixed(1)} Credits)',
                                style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11)),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Scholarship or Tuition Waiver
                    _cardWrapper(
                      surface: surface,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.military_tech_rounded, color: Color(0xFF0284C7), size: 18),
                              const SizedBox(width: 8),
                              Text('Scholarship / Tuition Waiver',
                                  style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800, color: textPri)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Scholarship vs Waiver selector
                          Row(
                            children: [
                              Expanded(
                                child: _discountTypeTab(
                                  label: 'Scholarship',
                                  subLabel: 'Max 13 Credits',
                                  icon: Icons.school_rounded,
                                  isSelected: _discountType == 'scholarship',
                                  onTap: () => setState(() => _discountType = 'scholarship'),
                                  sectionColor: sectionColor,
                                  borderColor: borderColor,
                                  textPri: textPri,
                                  textSec: textSec,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _discountTypeTab(
                                  label: 'Tuition Waiver',
                                  subLabel: 'No Credit Limit',
                                  icon: Icons.stars_rounded,
                                  isSelected: _discountType == 'waiver',
                                  onTap: () => setState(() => _discountType = 'waiver'),
                                  sectionColor: sectionColor,
                                  borderColor: borderColor,
                                  textPri: textPri,
                                  textSec: textSec,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _discountType == 'scholarship'
                                ? '• Scholarship applies to regular & subsequent retakes up to max 13 credits.'
                                : '• Tuition Waiver has no credit limit and applies to all eligible credits.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF0284C7),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _waiverChip(label: '0% (None)', isSelected: !_isCustomWaiver && _waiverPercent == 0, onTap: () => setState(() { _isCustomWaiver = false; _waiverPercent = 0; })),
                              _waiverChip(label: '25%', isSelected: !_isCustomWaiver && _waiverPercent == 25, onTap: () => setState(() { _isCustomWaiver = false; _waiverPercent = 25; })),
                              _waiverChip(label: '50%', isSelected: !_isCustomWaiver && _waiverPercent == 50, onTap: () => setState(() { _isCustomWaiver = false; _waiverPercent = 50; })),
                              _waiverChip(label: '100% (Full)', isSelected: !_isCustomWaiver && _waiverPercent == 100, onTap: () => setState(() { _isCustomWaiver = false; _waiverPercent = 100; })),
                              _waiverChip(label: 'Custom %', isSelected: _isCustomWaiver, onTap: () => setState(() => _isCustomWaiver = true)),
                            ],
                          ),
                          if (_isCustomWaiver) ...[
                            const SizedBox(height: 8),
                            _numberInput(
                              controller: _customWaiverCtrl,
                              surface: sectionColor,
                              borderColor: borderColor,
                              textPri: textPri,
                              stepDecimals: true,
                              hintText: 'Enter discount % (e.g. 20, 35)',
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Missed Installment Fine
                    _cardWrapper(
                      surface: surface,
                      borderColor: borderColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield_outlined, color: AppColors.danger, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Missed Installments',
                                      style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w800, color: textPri)),
                                ],
                              ),
                              Text('500 BDT fine per missed installment',
                                  style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 10)),
                            ],
                          ),
                          Row(
                            children: [0, 1, 2, 3].map((n) {
                              final isSel = _missedInstallments == n;
                              return GestureDetector(
                                onTap: () => setState(() => _missedInstallments = n),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.danger : sectionColor,
                                    borderRadius: AppRadius.borderMd,
                                    border: Border.all(
                                      color: isSel ? AppColors.danger : borderColor,
                                    ),
                                  ),
                                  child: Text(
                                    '$n',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSel ? Colors.white : textPri,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (totalRegCredits <= 0) ...[
                      // Clean prompt when no credits are entered yet (no demo calculations shown!)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: borderColor),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 34),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ready to Calculate Tuition Fee',
                              style: TextStyle(
                                color: textPri,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter your registered credits in Step 3 above to calculate your exact tuition fee, retake savings, waiver deductions, and installment schedule.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSec,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      // HERO TOTAL PAYABLE BANNER
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppRadius.borderXl,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TOTAL PAYABLE TUITION FEE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5)),
                                Builder(
                                  builder: (context) {
                                    final currentSig = '${totalWithFine.round()}_${totalDiscount.round()}_${totalRegCredits.toStringAsFixed(1)}_${discountPct.toStringAsFixed(1)}_$_missedInstallments';
                                    final isAlreadySaved = (_lastSavedCalcSignature == currentSig);

                                    if (isAlreadySaved) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text('Saved', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                      );
                                    }

                                    return InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _lastSavedCalcSignature = currentSig;
                                        });
                                        await _saveCurrentCalculationToHistory(
                                          totalPayable: totalWithFine,
                                          totalDiscount: totalDiscount,
                                          creditFee: creditFee,
                                          sessionFee: sessionFee,
                                          totalRegCredits: totalRegCredits,
                                          firstRetakeCr: firstRetakeCr,
                                          subRetakeCr: subRetakeCr,
                                          discountPct: discountPct,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Calculation saved to local history!'),
                                              backgroundColor: AppColors.success,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.bookmark_add_outlined, size: 13, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text('Save', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '৳ ${totalWithFine.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} BDT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _missedInstallments > 0
                                  ? 'Includes +৳${lateFine.round()} BDT late fine ($_missedInstallments missed)'
                                  : 'Includes course tuition and academic session fee',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // DETAILED BREAKDOWN CARD
                      _cardWrapper(
                        surface: surface,
                        borderColor: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Detailed Calculation Breakdown',
                                style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w900, color: textPri)),
                            const SizedBox(height: 10),
                            _feeRow('Academic System', _system == 'trimester' ? 'Trimester (3 Terms)' : (_system == 'semester' ? 'Semester (2 Terms)' : 'Not Selected Yet'), textSec, textPri, isBold: true),
                            _feeRow('Credit Fee', '${creditFee.round()} BDT', textSec, textPri),
                            _feeRow('Trimester/Semester Fee', '${sessionFee.round()} BDT', textSec, textPri),
                            _feeRow('Registered Credits', '${totalRegCredits.toStringAsFixed(1)} Cr', textSec, textPri, isBold: true),
                            _feeRow('  • Regular Credits', '${regularCredits.toStringAsFixed(1)} Cr', textSec, textPri),
                            _feeRow('  • 1st-Time Retake Credits', '${firstRetakeCr.toStringAsFixed(1)} Cr', textSec, AppColors.success),
                            _feeRow('  • Subsequent Retake Credits', '${subRetakeCr.toStringAsFixed(1)} Cr', textSec, AppColors.accent),
                            const Divider(height: 16),
                            _feeRow('Regular Tuition', '${regularTuition.round()} BDT', textSec, textPri),
                            _feeRow('1st-Time Retake Tuition (50% off)', '${firstRetakeTuition.round()} BDT', textSec, AppColors.success),
                            _feeRow('Subsequent Retake Tuition', '${subRetakeTuition.round()} BDT', textSec, textPri),
                            const Divider(height: 16),
                            _feeRow('1st Retake Discount (50%)', '−${firstRetakeDiscount.round()} BDT', AppColors.success, AppColors.success, isBold: true),
                            _feeRow('${_discountType == 'scholarship' ? 'Scholarship (Max 13 Cr)' : 'Waiver (No Limit)'} (${discountPct.toStringAsFixed(0)}%)', '−${waiverDiscount.round()} BDT', const Color(0xFF0284C7), const Color(0xFF0284C7), isBold: true),
                            _feeRow('Total Savings / Discount', '−${totalDiscount.round()} BDT', AppColors.success, AppColors.success, isBold: true),
                            const Divider(height: 16),
                            _feeRow('FINAL PAYABLE', '${totalPayable.round()} BDT', textPri, AppColors.primary, isBold: true, isLarge: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // INSTALLMENT PLAN CARD
                      _cardWrapper(
                        surface: surface,
                        borderColor: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pie_chart_rounded, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Installment Plan',
                                        style: AppTypography.titleSmall.copyWith(
                                            fontWeight: FontWeight.w900, color: textPri)),
                                  ],
                                ),
                                Text(
                                  _system == 'trimester' ? '40% / 30% / 30%' : '25% each (x4)',
                                  style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_system == null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: AppRadius.borderMd,
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Please select your Academic System (Trimester or Semester) in Step 1 to generate your exact installment schedule.',
                                        style: TextStyle(color: textPri, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (_system == 'trimester') ...[
                              _installmentRow('1st Installment (40%)', totalPayable * 0.40, 'Registration & term start', surface, sectionColor, borderColor, textPri, textSec),
                              _installmentRow('2nd Installment (30%)', totalPayable * 0.30, 'Before Midterm examinations', surface, sectionColor, borderColor, textPri, textSec),
                              _installmentRow('3rd Installment (30%)', totalPayable * 0.30, 'Before Final examinations', surface, sectionColor, borderColor, textPri, textSec),
                            ] else ...[
                              _installmentRow('1st Installment (25%)', totalPayable * 0.25, 'Registration installment', surface, sectionColor, borderColor, textPri, textSec),
                              _installmentRow('2nd Installment (25%)', totalPayable * 0.25, 'Before 1st term assessment', surface, sectionColor, borderColor, textPri, textSec),
                              _installmentRow('3rd Installment (25%)', totalPayable * 0.25, 'Before Midterm examination', surface, sectionColor, borderColor, textPri, textSec),
                              _installmentRow('4th Installment (25%)', totalPayable * 0.25, 'Before Final examination', surface, sectionColor, borderColor, textPri, textSec),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Download Breakdown PDF Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final provider = ProfileProviderScope.of(context);
                            TuitionPdfGenerator.printOrDownloadPdf(
                              context: context,
                              profile: provider.profile,
                              system: _system ?? 'trimester',
                              creditFee: creditFee,
                              sessionFee: sessionFee,
                              regularCredits: regularCredits,
                              firstRetakeCr: firstRetakeCr,
                              subRetakeCr: subRetakeCr,
                              regularTuition: regularTuition,
                              firstRetakeTuition: firstRetakeTuition,
                              subRetakeTuition: subRetakeTuition,
                              firstRetakeDiscount: firstRetakeDiscount,
                              discountType: _discountType,
                              discountPct: discountPct,
                              waiverDiscount: waiverDiscount,
                              totalDiscount: totalDiscount,
                              lateFine: lateFine,
                              missedInstallments: _missedInstallments,
                              totalPayable: totalWithFine,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 22),
                          label: const Text(
                            'Download Fee Breakdown (PDF)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                  ]),
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

  Widget _cardWrapper({required Widget child, required Color surface, required Color borderColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _systemTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waiverChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _quickCreditChip({
    required String label,
    required double creditVal,
    required TextEditingController controller,
    required Color surface,
    required Color border,
    required Color textPri,
  }) {
    final currentText = controller.text.trim();
    final currentVal = double.tryParse(currentText) ?? 0.0;
    final isSelected = (currentVal == creditVal) || (creditVal == 0.0 && (currentText.isEmpty || currentVal == 0.0));

    return InkWell(
      onTap: isSelected
          ? null
          : () {
              controller.text = creditVal.toInt().toString();
              setState(() {});
            },
      borderRadius: AppRadius.borderMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? Colors.white : textPri,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberInput({
    required TextEditingController controller,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    bool stepDecimals = false,
    String? hintText,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: stepDecimals),
      onChanged: onChanged,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPri),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: textPri.withValues(alpha: 0.30),
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: borderColor)),
      ),
    );
  }

  Widget _feeRow(String label, String value, Color labelColor, Color valueColor, {bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: isLarge ? 13 : 11, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500)),
          Text(value, style: TextStyle(color: valueColor, fontSize: isLarge ? 14 : 12, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _installmentRow(String title, double amount, String subtitle, Color surface, Color sectionColor, Color borderColor, Color textPri, Color textSec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: sectionColor,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: textPri)),
              Text(subtitle, style: TextStyle(color: textSec, fontSize: 10)),
            ],
          ),
          Text(
            '৳ ${amount.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _discountTypeTab({
    required String label,
    required String subLabel,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color sectionColor,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : sectionColor,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : textSec),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.primary : textPri,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : textSec,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTuitionFeeRulesModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderClr,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
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
                          'Summary of UIU Rules',
                          style: AppTypography.titleLarge.copyWith(
                            color: textPri,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Official Fee Structure & Policies',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSec,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ruleCard(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'Scholarship vs. Tuition Waiver',
                description: '• Scholarship: Discount applies to regular & subsequent retakes up to a maximum of 13 credits.\n• Tuition Waiver: Has NO credit limit and applies to all registered eligible credits.',
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              ),
              const SizedBox(height: 10),
              _ruleCard(
                icon: Icons.replay_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'First-Time Retake (50% Flat Discount)',
                description: 'Every student automatically receives a 50% discount on credit tuition for 1st-time retake courses, regardless of scholarship or waiver.',
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              ),
              const SizedBox(height: 10),
              _ruleCard(
                icon: Icons.sync_problem_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Subsequent Retakes & Scholarship/Waiver',
                description: 'Subsequent retakes (taken for the 2nd time or more) do not get the automatic 50% discount, but ARE eligible for Scholarship or Tuition Waiver discounts.',
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              ),
              const SizedBox(height: 10),
              _ruleCard(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Trimester / Semester Session Fee',
                description: 'Fixed academic session fee is NOT subject to any discount and is always added as-is.',
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              ),
              const SizedBox(height: 10),
              _ruleCard(
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.primary,
                title: 'Installment Schedules',
                description: '• Trimester Students (3 Installments): 40% (1st) → 30% (2nd) → 30% (3rd)\n• Semester Students (4 Installments): 25% → 25% → 25% → 25%',
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              ),
              const SizedBox(height: 10),
              _ruleCard(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.danger,
                title: 'Payment Failure Policy',
                description: 'If a student misses an installment payment deadline, a late fine of 500 BDT per missed installment will be added.',
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
    required Color textPri,
    required Color textSec,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(color: textSec, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTracker(int currentStep, Color surface, Color borderColor, Color textPri, Color textSec, bool isDark) {
    final steps = [
      {'num': 1, 'label': 'System'},
      {'num': 2, 'label': 'Fees'},
      {'num': 3, 'label': 'Credits'},
      {'num': 4, 'label': 'Waiver'},
      {'num': 5, 'label': 'Result'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: steps.map((s) {
            final sNum = s['num'] as int;
            final sLabel = s['label'] as String;
            final isDone = sNum < currentStep;
            final isCurrent = sNum == currentStep;

            Color badgeBg = isDone
                ? AppColors.success
                : (isCurrent ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)));
            Color textColor = (isDone || isCurrent) ? textPri : textSec;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                        : Text(
                            '$sNum',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isCurrent ? Colors.white : textSec,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  sLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (sNum < 5) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 14, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                  const SizedBox(width: 6),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGuidedStepBanner(int currentStep, Color surface, Color borderColor, Color textPri, Color textSec, bool isDark) {
    String stepBadge;
    String stepTitle;
    String stepDesc;
    IconData stepIcon;
    Color stepColor;

    switch (currentStep) {
      case 1:
        stepBadge = 'STEP 1 OF 5 • CHOOSE ACADEMIC SYSTEM';
        stepTitle = 'Select Trimester or Semester First';
        stepDesc = 'Choose whether your program operates on UIU\'s Trimester (3 terms/yr) or Semester (2 terms/yr) system. This choice is remembered automatically.';
        stepIcon = Icons.touch_app_rounded;
        stepColor = AppColors.primary;
        break;
      case 2:
        stepBadge = 'STEP 2 OF 5 • ACADEMIC FEES';
        stepTitle = 'Confirm Credit Fee & Session Fee';
        stepDesc = 'Enter your program per-credit fee (e.g. 6500) and session fee (e.g. 5000).';
        stepIcon = Icons.payments_rounded;
        stepColor = const Color(0xFF0284C7);
        break;
      case 3:
        stepBadge = 'STEP 3 OF 5 • TERM CREDITS';
        stepTitle = 'Enter Registered Credits This Term';
        stepDesc = 'Type the total registered credits you are taking this term. Add any 1st-time retake (50% off) or subsequent retake courses below.';
        stepIcon = Icons.format_list_numbered_rounded;
        stepColor = const Color(0xFF10B981);
        break;
      case 4:
        stepBadge = 'STEP 4 OF 5 • SCHOLARSHIP / WAIVER';
        stepTitle = 'Select Scholarship or Tuition Waiver';
        stepDesc = 'Choose Scholarship (max 13 Cr discount) or Waiver (unlimited). Both apply to regular and subsequent retake courses!';
        stepIcon = Icons.military_tech_rounded;
        stepColor = const Color(0xFF8B5CF6);
        break;
      default:
        stepBadge = 'STEP 5 OF 5 • OFFICIAL CALCULATION READY';
        stepTitle = 'Payable Tuition & Installment Schedule';
        stepDesc = 'Your payable tuition fee and installments are calculated below according to UIU\'s official policy.';
        stepIcon = Icons.check_circle_rounded;
        stepColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stepColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: stepColor.withValues(alpha: isDark ? 0.35 : 0.25), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.18),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(stepIcon, color: stepColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stepColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stepBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _dismissTutorial,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: textSec,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stepTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stepDesc,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSec,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _keyTuitionHistory = 'uiu_tuition_calc_history_v1';

  void _resetAllFields() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Reset Calculator?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all entered credit values, retakes, and waiver selections?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _registeredCreditsCtrl.clear();
                _firstRetakeCreditsCtrl.clear();
                _subsequentRetakeCreditsCtrl.clear();
                _customWaiverCtrl.clear();
                _firstRetakes.clear();
                _subsequentRetakes.clear();
                _waiverPercent = 0.0;
                _isCustomWaiver = false;
                _missedInstallments = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All calculation fields have been reset.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }


  Future<void> _saveCurrentCalculationToHistory({
    required double totalPayable,
    required double totalDiscount,
    required double creditFee,
    required double sessionFee,
    required double totalRegCredits,
    required double firstRetakeCr,
    required double subRetakeCr,
    required double discountPct,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList(_keyTuitionHistory) ?? [];
      final now = DateTime.now();
      final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final entry = {
        'id': now.millisecondsSinceEpoch.toString(),
        'date': dateStr,
        'system': _system ?? 'trimester',
        'creditFee': creditFee,
        'sessionFee': sessionFee,
        'registeredCredits': totalRegCredits,
        'firstRetakeCredits': firstRetakeCr,
        'subsequentRetakeCredits': subRetakeCr,
        'discountType': _discountType,
        'discountPct': discountPct,
        'missedInstallments': _missedInstallments,
        'totalPayable': totalPayable,
        'totalDiscount': totalDiscount,
      };

      historyList.insert(0, jsonEncode(entry));
      if (historyList.length > 25) {
        historyList.removeRange(25, historyList.length);
      }
      await prefs.setStringList(_keyTuitionHistory, historyList);
    } catch (_) {}
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }

  Future<void> _showTuitionHistoryModal(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getStringList(_keyTuitionHistory) ?? [];
    List<Map<String, dynamic>> history = [];
    for (final s in rawHistory) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          history.add(decoded);
        }
      } catch (_) {}
    }

    if (!context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.border;
    final sectionClr = isDark ? AppColors.darkSection : AppColors.section;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderClr,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(Icons.history_rounded, color: AppColors.accent, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calculation History',
                            style: AppTypography.titleLarge.copyWith(
                              color: textPri,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${history.length} saved records • Stored locally',
                            style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (history.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: ctx,
                            builder: (c) => AlertDialog(
                              title: const Text('Clear All History?'),
                              content: const Text('This will delete all saved tuition calculations from your device.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                                  child: const Text('Clear All'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await prefs.remove(_keyTuitionHistory);
                            setModalState(() => history.clear());
                          }
                        },
                        icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.danger),
                        label: const Text('Clear All', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off_rounded, size: 48, color: textSec.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(
                                'No Saved Calculations Yet',
                                style: TextStyle(color: textPri, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Calculate your tuition fee above and tap "Save" to keep track of previous estimates here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textSec, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final item = history[i];
                            final id = item['id']?.toString() ?? '';
                            final date = item['date']?.toString() ?? 'Recent';
                            final sys = item['system']?.toString() ?? 'trimester';
                            final total = (item['totalPayable'] as num?)?.toDouble() ?? 0.0;
                            final regCr = (item['registeredCredits'] as num?)?.toDouble() ?? 0.0;
                            final retakeCr = (item['firstRetakeCredits'] as num?)?.toDouble() ?? 0.0;
                            final waiverPct = (item['discountPct'] as num?)?.toDouble() ?? 0.0;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sectionClr,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: borderClr),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          sys.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      ),
                                      Text(date, style: TextStyle(color: textSec, fontSize: 10.5)),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.danger),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () async {
                                          rawHistory.removeWhere((raw) {
                                            try {
                                              return jsonDecode(raw)['id']?.toString() == id;
                                            } catch (_) {
                                              return false;
                                            }
                                          });
                                          await prefs.setStringList(_keyTuitionHistory, rawHistory);
                                          setModalState(() => history.removeAt(i));
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '৳ ${total.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} BDT',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFFEA580C),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Credits: ${regCr.toStringAsFixed(1)} Cr  •  Retake: ${retakeCr.toStringAsFixed(1)} Cr  •  Waiver: ${waiverPct.toStringAsFixed(0)}%',
                                            style: TextStyle(color: textSec, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          setState(() {
                                            if (sys == 'trimester' || sys == 'semester') {
                                              _system = sys;
                                            }
                                            _registeredCreditsCtrl.text = regCr > 0 ? regCr.toString() : '';
                                            _firstRetakeCreditsCtrl.text = retakeCr > 0 ? retakeCr.toString() : '0';
                                            _waiverPercent = waiverPct;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Calculation restored into calculator!'),
                                              backgroundColor: AppColors.success,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.restore_rounded, size: 14),
                                        label: const Text('Restore', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
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