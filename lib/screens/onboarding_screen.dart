import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../core/providers/user_profile_provider.dart';
import '../main.dart';
import 'main_navigation_screen.dart';
import 'transcript_import_screen.dart';

/// Departments available at UIU
const _departments = [
  'Computer Science and Engineering (CSE)',
  'Electrical and Electronic Engineering (EEE)',
  'Civil Engineering',
  'Data Science',
  'English',
  'Environment Studies',
  'Pharmacy',
  'Biotechnology & Genetic Engineering',
  'Economics',
  'Business Administration',
  'Law',
  'Other',
];

const _programs = {
  'Computer Science and Engineering (CSE)': 'B.Sc. in CSE',
  'Electrical and Electronic Engineering (EEE)': 'B.Sc. in EEE',
  'Civil Engineering': 'B.Sc. in CE',
  'Data Science': 'B.Sc. in Data Science',
  'English': 'B.A. in English',
  'Environment Studies': 'B.Sc. in Environment Studies',
  'Pharmacy': 'B.Pharm',
  'Biotechnology & Genetic Engineering': 'B.Sc. in Biotechnology',
  'Economics': 'B.S.S. in Economics',
  'Business Administration': 'BBA',
  'Law': 'LL.B.',
  'Other': 'B.Sc.',
};


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  // Academic System
  String _academicSystem = 'trimester'; // 'trimester' or 'semester'

  // Page 1 – personal info
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  String? _selectedDept;
  String _batchController = '';
  bool _batchEdited = false;

  // Page 2 – academic standing
  final _cgpaController = TextEditingController();
  final _creditsController = TextEditingController();
  final _targetController = TextEditingController();
  final _totalRequiredCreditsController = TextEditingController();

  late AnimationController _logoAnim;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _logoScale = CurvedAnimation(parent: _logoAnim, curve: Curves.easeOutBack);

    _idController.addListener(_onIdChanged);
  }

  void _onIdChanged() {
    if (_batchEdited) return;
    final batch = extractBatchFromId(_idController.text);
    if (batch != _batchController) {
      setState(() => _batchController = batch);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _cgpaController.dispose();
    _creditsController.dispose();
    _targetController.dispose();
    _totalRequiredCreditsController.dispose();
    _logoAnim.dispose();
    super.dispose();
  }

  bool get _page1Valid =>
      _nameController.text.trim().isNotEmpty &&
      _idController.text.trim().isNotEmpty &&
      _selectedDept != null;

  bool get _page2Valid {
    final cgpa = double.tryParse(_cgpaController.text) ?? -1;
    final credits = double.tryParse(_creditsController.text) ?? -1;
    final target = double.tryParse(_targetController.text) ?? -1;
    final totalReqText = _totalRequiredCreditsController.text.trim();
    final totalReq = totalReqText.isEmpty ? 141.0 : (double.tryParse(totalReqText) ?? -1);
    return cgpa >= 0 && cgpa <= 4.0 && credits >= 0 && target >= 0 && target <= 4.0 && totalReq > 0;
  }

  Future<void> _finish() async {
    final provider = ProfileProviderScope.of(context);
    final dept = _selectedDept ?? 'Computer Science and Engineering (CSE)';
    final totalReqText = _totalRequiredCreditsController.text.trim();
    final totalCredits = totalReqText.isNotEmpty
        ? (double.tryParse(totalReqText) ?? 141.0)
        : 141.0;
    final profile = UserProfile(
      name: _nameController.text.trim(),
      studentId: _idController.text.trim(),
      department: dept,
      program: _programs[dept] ?? 'B.Sc.',
      batch: _batchController.isNotEmpty ? _batchController : '—',
      currentCGPA: double.tryParse(_cgpaController.text) ?? 0.0,
      completedCredits: double.tryParse(_creditsController.text) ?? 0.0,
      totalDegreeCredits: totalCredits,
      targetCGPA: double.tryParse(_targetController.text) ?? 3.75,
    );
    await provider.saveProfile(profile);

    // Save academic system preference locally for tuition fees & app
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uiu_tuition_system', _academicSystem);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const MainNavigationScreen(),
        transitionsBuilder: (c, a1, a2, child) =>
            FadeTransition(opacity: a1, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Decorative ambient blobs
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: 0.08),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Logo header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 46,
                              height: 46,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UIU CGPA Calculator',
                              style: AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: textPri,
                                  fontSize: 16)),
                          Text('Set up your academic profile',
                              style: AppTypography.bodySmall.copyWith(
                                  color: textSec, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Setup',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: textPri)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Step indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      _stepDot(0, 'Personal Info', isDark),
                      Expanded(child: Divider(color: _currentPage >= 1 ? AppColors.primary : border, thickness: 2)),
                      _stepDot(1, 'Academic Data', isDark),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildPage1(surface, border, textPri, textSec, cs),
                      _buildPage2(surface, border, textPri, textSec, cs),
                    ],
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == 0) {
                          if (!_page1Valid) {
                            _showError('Please enter your name and student ID.');
                            return;
                          }
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          if (!_page2Valid) {
                            _showError('Please enter valid CGPA (0-4) and credits.');
                            return;
                          }
                          _finish();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderBase,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 0 ? 'Continue →' : 'Get Started 🎓',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(int step, String label, bool isDark) {
    final active = _currentPage == step;
    final done = _currentPage > step;
    final color = done || active ? AppColors.primary : AppColors.textTertiary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active
                ? AppColors.primary
                : (isDark ? AppColors.darkSection : AppColors.section),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ],
    );
  }

  Widget _buildPage1(Color surface, Color border, Color textPri, Color textSec,
      ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('👋 Welcome!',
              style: AppTypography.displayMedium.copyWith(
                  fontSize: 26, fontWeight: FontWeight.w900, color: textPri)),
          const SizedBox(height: 4),
          Text('Tell us a bit about yourself or restore an existing transcript.',
              style: AppTypography.bodyMedium.copyWith(color: textSec)),
          const SizedBox(height: 20),

          // Fast Track Import Banner for Returning Users
          _buildFastTrackImportBanner(surface, border, textPri, textSec),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR SET UP MANUALLY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: textSec.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    )),
              ),
              Expanded(child: Divider(color: border)),
            ],
          ),
          const SizedBox(height: 20),

          _fieldLabel('Full Name', textSec),
          _buildTextField(
            controller: _nameController,
            hint: 'e.g. Rahim Uddin',
            icon: Icons.person_outline_rounded,
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Student ID', textSec),
          _buildTextField(
            controller: _idController,
            hint: 'e.g. 0112330538',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 8),
          if (_batchController.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Auto-detected Batch: ',
                      style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11)),
                  Text(_batchController,
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                ],
              ),
            ),
          // Batch (editable)
          _fieldLabel('Batch (editable)', textSec),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: border),
              boxShadow: AppShadows.soft,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'e.g. 233',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: textPri.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon:
                    const Icon(Icons.groups_2_outlined, color: AppColors.primary, size: 20),
              ),
              controller: TextEditingController(text: _batchController),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              style: AppTypography.bodyMedium.copyWith(
                  color: textPri, fontWeight: FontWeight.w700),
              onChanged: (v) {
                _batchEdited = true;
                _batchController = v;
              },
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Department *', textSec),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: AppRadius.borderBase,
              border: Border.all(
                color: _selectedDept == null ? border : AppColors.primary.withValues(alpha: 0.5),
              ),
              boxShadow: AppShadows.soft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDept,
                hint: Text(
                  'Select your department',
                  style: AppTypography.bodyMedium.copyWith(
                    color: textPri.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                isExpanded: true,
                items: _departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d, style: AppTypography.bodyMedium.copyWith(color: textPri))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedDept = v;
                    });
                  }
                },
                dropdownColor: surface,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Academic System (Trimester vs Semester)
          _fieldLabel('Academic System (Trimester / Semester) *', textSec),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _academicSystem = 'trimester'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _academicSystem == 'trimester'
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : surface,
                      borderRadius: AppRadius.borderBase,
                      border: Border.all(
                        color: _academicSystem == 'trimester' ? AppColors.primary : border,
                        width: _academicSystem == 'trimester' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_view_month_rounded,
                          color: _academicSystem == 'trimester' ? AppColors.primary : textSec,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trimester',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _academicSystem == 'trimester' ? AppColors.primary : textPri,
                          ),
                        ),
                        Text(
                          '3 Terms / Year',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: textSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _academicSystem = 'semester'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _academicSystem == 'semester'
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : surface,
                      borderRadius: AppRadius.borderBase,
                      border: Border.all(
                        color: _academicSystem == 'semester' ? AppColors.primary : border,
                        width: _academicSystem == 'semester' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          color: _academicSystem == 'semester' ? AppColors.primary : textSec,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semester',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _academicSystem == 'semester' ? AppColors.primary : textPri,
                          ),
                        ),
                        Text(
                          '2 Terms / Year',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: textSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage2(Color surface, Color border, Color textPri, Color textSec,
      ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Academic Standing',
              style: AppTypography.displayMedium.copyWith(
                  fontSize: 24, fontWeight: FontWeight.w900, color: textPri)),
          const SizedBox(height: 4),
          Text('All fields below are mandatory to compute your targets.',
              style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 12)),
          const SizedBox(height: 16),

          // Offline & Privacy Notice Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '100% Offline & Stored Locally',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No personal or academic data is stored on remote servers. All your CGPA, credits, and records stay safely on this device only.',
                        style: TextStyle(
                          color: textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _fieldLabel('Current CGPA (0.00 – 4.00) *', textSec),
          _buildTextField(
            controller: _cgpaController,
            hint: '0.00',
            icon: Icons.school_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Completed Credits (e.g. 0 if 1st trimester) *', textSec),
          _buildTextField(
            controller: _creditsController,
            hint: '0',
            icon: Icons.playlist_add_check_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Target CGPA (e.g. 3.75) *', textSec),
          _buildTextField(
            controller: _targetController,
            hint: '3.75',
            icon: Icons.track_changes_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Total Required Credits (Degree Total) *', textSec),
          _buildTextField(
            controller: _totalRequiredCreditsController,
            hint: '141',
            icon: Icons.grade_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If you are in your 1st trimester, keep CGPA as 0.00 and Completed Credits as 0. You can update anytime from Profile or Transcript.',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, Color textSec) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: AppTypography.labelSmall.copyWith(
                color: textSec, fontWeight: FontWeight.w700, fontSize: 12)),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color surface,
    required Color border,
    required Color textPri,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: border),
        boxShadow: AppShadows.soft,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTypography.bodyMedium.copyWith(color: textPri, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: textPri.withValues(alpha: 0.35),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildFastTrackImportBanner(
      Color surface, Color border, Color textPri, Color textSec) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.12)
            : const Color(0xFFFFF7ED),
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderLg,
          onTap: () => _showRestoreOptionsModal(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(Icons.cloud_download_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Returning Student?',
                              style: TextStyle(
                                color: textPri,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.borderFull,
                            ),
                            child: const Text(
                              'RESTORE DATA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.5),
                      Text(
                        'Import exported backup (.json) or transcript (PDF/CSV/Text) to skip setup & restore all data!',
                        style: TextStyle(
                          color: textSec,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary, size: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRestoreOptionsModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(Icons.settings_backup_restore_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restore Academic Data',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textPri,
                        ),
                      ),
                      Text(
                        'Choose your previously saved backup method',
                        style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Option 1: Import Exported Backup JSON
            InkWell(
              borderRadius: AppRadius.borderBase,
              onTap: () {
                Navigator.pop(ctx);
                _handleDirectImportJson();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderBase,
                  border: Border.all(color: border),
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(Icons.file_present_rounded, color: Color(0xFF10B981), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Import Exported Backup (.json)',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: textPri,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: AppRadius.borderFull,
                                ),
                                child: const Text(
                                  'RECOMMENDED',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Restore from previously downloaded academic backup file',
                            style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: textSec, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Option 2: Transcript Import (PDF / CSV / OCR / Text)
            InkWell(
              borderRadius: AppRadius.borderBase,
              onTap: () {
                Navigator.pop(ctx);
                _openTranscriptImport();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderBase,
                  border: Border.all(color: border),
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Import UIU Transcript (PDF / CSV / Image)',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Scan or upload official UIU portal grade sheets',
                            style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: textSec, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDirectImportJson() async {
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
        _showError('Selected JSON backup file is empty.');
        return;
      }

      if (!mounted) return;
      final prov = ProfileProviderScope.of(context);
      final success = await prov.importBackupJson(content.trim());

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Academic backup restored successfully! Welcome back.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const MainNavigationScreen(),
            transitionsBuilder: (c, a1, a2, child) =>
                FadeTransition(opacity: a1, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      } else {
        _showError('Invalid backup JSON structure. Please select a valid backup file.');
      }
    } catch (e) {
      _showError('Failed to import backup JSON: $e');
    }
  }

  Future<void> _openTranscriptImport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TranscriptImportScreen(),
      ),
    );
    if (!mounted) return;
    final prov = ProfileProviderScope.of(context);
    if (prov.semesters.isNotEmpty || prov.profile.completedCredits > 0) {
      final p = prov.profile;
      await prov.saveProfile(p.copyWith(
        name: p.name.isNotEmpty
            ? p.name
            : (_nameController.text.trim().isNotEmpty
                ? _nameController.text.trim()
                : 'UIU Student'),
        studentId: p.studentId.isNotEmpty
            ? p.studentId
            : (_idController.text.trim().isNotEmpty
                ? _idController.text.trim()
                : '0110000000'),
        department: p.department.isNotEmpty
            ? p.department
            : (_selectedDept ?? 'Computer Science and Engineering (CSE)'),
      ));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const MainNavigationScreen(),
          transitionsBuilder: (c, a1, a2, child) =>
              FadeTransition(opacity: a1, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderBase),
      ),
    );
  }
}
