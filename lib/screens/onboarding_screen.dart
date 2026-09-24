import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../core/providers/user_profile_provider.dart';
import '../main.dart';
import 'main_navigation_screen.dart';

/// Departments available at UIU
const _departments = [
  'Computer Science & Engineering',
  'Electrical & Electronic Engineering',
  'Civil Engineering',
  'Business Administration',
  'English',
  'Law',
  'Pharmacy',
  'Architecture',
  'Other',
];

const _programs = {
  'Computer Science & Engineering': 'B.Sc. in CSE',
  'Electrical & Electronic Engineering': 'B.Sc. in EEE',
  'Civil Engineering': 'B.Sc. in CE',
  'Business Administration': 'BBA',
  'English': 'B.A. in English',
  'Law': 'LL.B.',
  'Pharmacy': 'B.Pharm',
  'Architecture': 'B.Arch',
  'Other': 'B.Sc.',
};

const _totalCreditsByProgram = {
  'Computer Science & Engineering': 138.0,
  'Electrical & Electronic Engineering': 143.0,
  'Civil Engineering': 148.0,
  'Business Administration': 130.0,
  'English': 120.0,
  'Law': 120.0,
  'Pharmacy': 160.0,
  'Architecture': 170.0,
  'Other': 130.0,
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

  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _batchController = TextEditingController();
  String _selectedDept = 'Computer Science & Engineering';
  bool _batchEdited = false;

  // Page 2 – academic standing
  final _cgpaController = TextEditingController(text: '0.00');
  final _creditsController = TextEditingController(text: '0');
  final _targetController = TextEditingController(text: '3.75');

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
    if (batch != _batchController.text) {
      _batchController.text = batch;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _batchController.dispose();
    _cgpaController.dispose();
    _creditsController.dispose();
    _targetController.dispose();
    _logoAnim.dispose();
    super.dispose();
  }

  bool get _page1Valid =>
      _nameController.text.trim().isNotEmpty && _idController.text.trim().isNotEmpty;

  bool get _page2Valid {
    final cgpa = double.tryParse(_cgpaController.text) ?? -1;
    final credits = double.tryParse(_creditsController.text) ?? -1;
    final target = double.tryParse(_targetController.text) ?? -1;
    return cgpa >= 0 && cgpa <= 4.0 && credits >= 0 && target >= 0 && target <= 4.0;
  }

  Future<void> _finish() async {
    final provider = ProfileProviderScope.of(context);
    final dept = _selectedDept;
    final totalCredits = _totalCreditsByProgram[dept] ?? 138.0;
    final profile = UserProfile(
      name: _nameController.text.trim(),
      studentId: _idController.text.trim(),
      department: dept,
      program: _programs[dept] ?? 'B.Sc.',
      batch: _batchController.text.trim().isNotEmpty ? _batchController.text.trim() : '—',
      currentCGPA: double.tryParse(_cgpaController.text) ?? 0.0,
      completedCredits: double.tryParse(_creditsController.text) ?? 0.0,
      totalDegreeCredits: totalCredits,
      targetCGPA: double.tryParse(_targetController.text) ?? 3.75,
    );
    await provider.saveProfile(profile);
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.borderMd,
                            boxShadow: AppShadows.primary,
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: Colors.white, size: 24),
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
          Text('👋 Welcome!',
              style: AppTypography.displayMedium.copyWith(
                  fontSize: 26, fontWeight: FontWeight.w900, color: textPri)),
          const SizedBox(height: 4),
          Text('Tell us a bit about yourself.',
              style: AppTypography.bodyMedium.copyWith(color: textSec)),
          const SizedBox(height: 28),
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
          if (_batchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Auto-detected Batch: ',
                      style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 11)),
                  Text(_batchController.text,
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
              controller: _batchController,
              decoration: const InputDecoration(
                hintText: 'e.g. 233',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon:
                    Icon(Icons.groups_2_outlined, color: AppColors.primary, size: 20),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              style: AppTypography.bodyMedium.copyWith(
                  color: textPri, fontWeight: FontWeight.w700),
              onChanged: (v) {
                _batchEdited = true;
              },
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Department', textSec),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: AppRadius.borderBase,
              border: Border.all(color: border),
              boxShadow: AppShadows.soft,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDept,
                isExpanded: true,
                items: _departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d, style: AppTypography.bodyMedium.copyWith(color: textPri))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDept = v);
                },
                dropdownColor: surface,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
          Text('Enter your current progress (you can update later in Profile).',
              style: AppTypography.bodySmall.copyWith(color: textSec, fontSize: 12)),
          const SizedBox(height: 24),
          _fieldLabel('Current CGPA (0.00 – 4.00)', textSec),
          _buildTextField(
            controller: _cgpaController,
            hint: '3.50',
            icon: Icons.school_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Credits Completed', textSec),
          _buildTextField(
            controller: _creditsController,
            hint: '60',
            icon: Icons.playlist_add_check_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            surface: surface,
            border: border,
            textPri: textPri,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Target CGPA', textSec),
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
                    'If you\'re a new student, leave CGPA as 0.00 and credits as 0. You can update anytime from Profile.',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
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
