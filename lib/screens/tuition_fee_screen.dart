import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
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
  String _system = 'trimester'; // 'trimester' or 'semester'

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

  @override
  void initState() {
    super.initState();
    _creditFeeCtrl = TextEditingController();
    _sessionFeeCtrl = TextEditingController();
    _registeredCreditsCtrl = TextEditingController();
    _customWaiverCtrl = TextEditingController();
    _firstRetakeCreditsCtrl = TextEditingController();
    _subsequentRetakeCreditsCtrl = TextEditingController();
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

    // Step 2: Tuition per category
    final regularTuition = regularCredits * creditFee;
    final firstRetakeNormal = firstRetakeCr * creditFee;
    final firstRetakeDiscount = firstRetakeNormal * 0.50; // 50% discount
    final firstRetakeTuition = firstRetakeNormal - firstRetakeDiscount;
    final subRetakeTuition = subRetakeCr * creditFee; // 0% discount

    // Step 3: Apply Scholarship/Waiver ONLY to Regular Tuition
    final double waiverPct = _isCustomWaiver
        ? (double.tryParse(_customWaiverCtrl.text) ?? 0.0)
        : _waiverPercent;
    final waiverDiscount = regularTuition * (waiverPct / 100.0);
    final finalRegularTuition = regularTuition - waiverDiscount;

    // Step 4: Totals
    final totalTuition = finalRegularTuition + firstRetakeTuition + subRetakeTuition;
    final totalDiscount = firstRetakeDiscount + waiverDiscount;
    final totalPayable = totalTuition + sessionFee;

    final lateFine = _missedInstallments * 500.0;
    final totalWithFine = totalPayable + lateFine;

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
                child: const UIUHeader(
                  title: 'Tuition Fee',
                  subtitle: 'Official UIU Fee Structure & Policies',
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Academic System Selector Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: sectionColor,
                        borderRadius: AppRadius.borderLg,
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _systemTabButton(
                              label: 'Trimester (3 Terms)',
                              icon: Icons.calendar_month_rounded,
                              isSelected: _system == 'trimester',
                              onTap: () => setState(() => _system = 'trimester'),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _systemTabButton(
                              label: 'Semester (2 Terms)',
                              icon: Icons.date_range_rounded,
                              isSelected: _system == 'semester',
                              onTap: () => setState(() => _system = 'semester'),
                            ),
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
                                      onChanged: (_) => setState(() {}),
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
                                      onChanged: (_) => setState(() {}),
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
                              _quickCreditChip('0 Cr', () {
                                _firstRetakeCreditsCtrl.text = '0';
                                setState(() {});
                              }, sectionColor, borderColor, textPri),
                              const SizedBox(width: 4),
                              _quickCreditChip('3 Cr', () {
                                _firstRetakeCreditsCtrl.text = '3';
                                setState(() {});
                              }, sectionColor, borderColor, textPri),
                              const SizedBox(width: 4),
                              _quickCreditChip('6 Cr', () {
                                _firstRetakeCreditsCtrl.text = '6';
                                setState(() {});
                              }, sectionColor, borderColor, textPri),
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
                              _quickCreditChip('0 Cr', () {
                                _subsequentRetakeCreditsCtrl.text = '0';
                                setState(() {});
                              }, sectionColor, borderColor, textPri),
                              const SizedBox(width: 4),
                              _quickCreditChip('3 Cr', () {
                                _subsequentRetakeCreditsCtrl.text = '3';
                                setState(() {});
                              }, sectionColor, borderColor, textPri),
                              const SizedBox(width: 4),
                              _quickCreditChip('6 Cr', () {
                                _subsequentRetakeCreditsCtrl.text = '6';
                                setState(() {});
                              }, sectionColor, borderColor, textPri),
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
                          const SizedBox(height: 2),
                          Text('*Applies ONLY to Regular Courses. Retakes & session fees excluded.',
                              style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 10)),
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
                          const Text('TOTAL PAYABLE TUITION FEE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)),
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
                          _feeRow('Academic System', _system == 'trimester' ? 'Trimester (3 Terms)' : 'Semester (2 Terms)', textSec, textPri, isBold: true),
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
                          _feeRow('Scholarship / Waiver Discount (${waiverPct.toStringAsFixed(0)}%)', '−${waiverDiscount.round()} BDT', const Color(0xFF0284C7), const Color(0xFF0284C7), isBold: true),
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
                          if (_system == 'trimester') ...[
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

                    const SizedBox(height: 14),

                    // POLICY SUMMARY NOTES
                    _cardWrapper(
                      surface: surface,
                      borderColor: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text('Summary of Official UIU Rules',
                                  style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800, color: textPri)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _policyBullet('First-time retake:', '50% discount on that course\'s tuition.', textPri, textSec),
                          _policyBullet('Subsequent retake (2nd+):', 'No discount (100% full course fee).', textPri, textSec),
                          _policyBullet('Scholarship / Waiver:', 'Applies ONLY to regular courses. Retakes and session fees excluded.', textPri, textSec),
                          _policyBullet('Session Fee:', 'Always added as-is without any discounts.', textPri, textSec),
                          _policyBullet('Trimester Plan:', '3 installments: 40% → 30% → 30%.', textPri, textSec),
                          _policyBullet('Semester Plan:', '4 installments: 25% → 25% → 25% → 25%.', textPri, textSec),
                          _policyBullet('Missed Payment:', '500 BDT fine per missed installment deadline.', textPri, textSec),
                        ],
                      ),
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

  Widget _quickCreditChip(String label, VoidCallback onTap, Color surface, Color border, Color textPri) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textPri),
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

  Widget _policyBullet(String title, String desc, Color textPri, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 11, color: textSec, height: 1.3),
                children: [
                  TextSpan(text: '$title ', style: TextStyle(fontWeight: FontWeight.bold, color: textPri)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
