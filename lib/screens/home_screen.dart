import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';
import '../widgets/uiu_bottom_sheet.dart';
import 'analytics_screen.dart';
import 'main_navigation_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late AnimationController _cardsAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _cardsAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _headerFade =
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _cardsAnim.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Good Morning';
    if (hour < 17) return '🌤️ Good Afternoon';
    if (hour < 21) return '🌆 Good Evening';
    return '🌙 Good Night';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  double get _requiredSGPA {
    final provider = ProfileProviderScope.of(context);
    final p = provider.profile;
    final remaining = p.remainingCredits;
    if (remaining <= 0) return 0.0;
    final total = p.completedCredits + remaining;
    final req = (p.targetCGPA * total) - (p.currentCGPA * p.completedCredits);
    return (req / remaining).clamp(0.0, 9.99);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ProfileProviderScope.of(context);
    final student = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final bg = isDark ? AppColors.darkScaffold : AppColors.scaffold;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final sectionClr = isDark ? AppColors.darkSection : AppColors.section;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final requiredSGPA = _requiredSGPA;
    final firstName = student.name.split(' ').first;
    final progressPct = (student.progressPercentage * 100).toInt();

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Decorative background blobs
          _bgBlob(top: -120, right: -100, size: 320,
              color: AppColors.primary, opacity: isDark ? 0.08 : 0.07),
          _bgBlob(top: 180, left: -80, size: 240,
              color: AppColors.accent, opacity: isDark ? 0.06 : 0.05),
          _bgBlob(bottom: 200, right: -60, size: 200,
              color: AppColors.secondary, opacity: isDark ? 0.07 : 0.05),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── HERO HEADER ──
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _buildHeroHeader(
                        firstName: firstName,
                        isDark: isDark,
                        textPri: textPri,
                        textSec: textSec,
                        surface: surface,
                        borderColor: borderColor,
                      ),
                    ),
                  ),
                ),

                // ── CGPA HIGHLIGHT BANNER ──
                SliverToBoxAdapter(
                  child: _buildCGPABanner(
                    student: student,
                    requiredSGPA: requiredSGPA,
                    progressPct: progressPct,
                    isDark: isDark,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ),

                // ── QUICK FEATURE NAVIGATION GRID ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QUICK ACCESS',
                            style: AppTypography.labelSmall.copyWith(
                                color: textSec,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                fontSize: 11)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _featureNavButton(
                                label: 'GPA Calculator',
                                sub: 'Calculate & Predict',
                                icon: Icons.calculate_rounded,
                                color: AppColors.primary,
                                isDark: isDark,
                                onTap: () => MainNavigationScreen.switchTab(context, 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _featureNavButton(
                                label: 'Transcript',
                                sub: 'Add/Import Courses',
                                icon: Icons.description_rounded,
                                color: AppColors.success,
                                isDark: isDark,
                                onTap: () => MainNavigationScreen.switchTab(context, 2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _featureNavButton(
                                label: 'AI Advisor',
                                sub: 'Smart Suggestions',
                                icon: Icons.auto_awesome_rounded,
                                color: AppColors.accent,
                                isDark: isDark,
                                onTap: () => MainNavigationScreen.switchTab(context, 3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _featureNavButton(
                                label: 'Tuition Fee',
                                sub: 'Waiver, Retake & Plan',
                                icon: Icons.payments_rounded,
                                color: const Color(0xFF2563EB),
                                isDark: isDark,
                                onTap: () => MainNavigationScreen.switchTab(context, 4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 4 QUICK STAT CARDS ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 2,
                      mainAxisSpacing: AppSpacing.s10,
                      crossAxisSpacing: AppSpacing.s10,
                      mainAxisExtent: 112,
                    ),
                    delegate: SliverChildListDelegate([
                      _statCard(
                        title: 'Current CGPA',
                        value: student.currentCGPA.toStringAsFixed(2),
                        sub: 'UIU Scale 4.00 Max',
                        icon: Icons.school_rounded,
                        iconBg: AppColors.primary,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        index: 0,
                        onTap: () => MainNavigationScreen.switchTab(context, 1),
                      ),
                      _statCard(
                        title: 'Credits Done',
                        value: '${student.completedCredits.toInt()} / ${student.totalDegreeCredits.toInt()}',
                        sub: '$progressPct% Degree Progress',
                        icon: Icons.check_circle_outline_rounded,
                        iconBg: AppColors.success,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        index: 1,
                        onTap: () => MainNavigationScreen.switchTab(context, 2),
                      ),
                      _statCard(
                        title: 'Target CGPA',
                        value: student.targetCGPA.toStringAsFixed(2),
                        sub: 'Req GPA: ${requiredSGPA.toStringAsFixed(2)}',
                        icon: Icons.track_changes_rounded,
                        iconBg: AppColors.accent,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        index: 2,
                        onTap: () => MainNavigationScreen.switchTab(context, 1),
                      ),
                      _statCard(
                        title: 'Remaining',
                        value: '${student.remainingCredits.toInt()} Cr',
                        sub: '${student.department.split(' ').first} Program',
                        icon: Icons.moving_rounded,
                        iconBg: AppColors.secondary,
                        surface: surface,
                        borderColor: borderColor,
                        textPri: textPri,
                        textSec: textSec,
                        index: 3,
                        onTap: () => MainNavigationScreen.switchTab(context, 2),
                      ),
                    ]),
                  ),
                ),

                // ── PROGRESS BAR SECTION ──
                SliverToBoxAdapter(
                  child: _buildProgressSection(
                    student: student,
                    progressPct: progressPct,
                    isDark: isDark,
                    surface: surface,
                    borderColor: borderColor,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ),

                // ── QUICK GPA PREDICTOR ──
                SliverToBoxAdapter(
                  child: _buildPredictorCard(
                    requiredSGPA: requiredSGPA,
                    isDark: isDark,
                    surface: surface,
                    borderColor: borderColor,
                    textPri: textPri,
                    textSec: textSec,
                    sectionClr: sectionClr,
                  ),
                ),

                // ── QUICK TIPS SECTION ──
                SliverToBoxAdapter(
                  child: _buildTipsSection(
                    isDark: isDark,
                    surface: surface,
                    borderColor: borderColor,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO HEADER ────────────────────────────────
  Widget _buildHeroHeader({
    required String firstName,
    required bool isDark,
    required Color textPri,
    required Color textSec,
    required Color surface,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.primary.withValues(alpha: 0.28), AppColors.primaryDark.withValues(alpha: 0.18)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderXl,
        boxShadow: isDark ? [] : AppShadows.primary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName.isNotEmpty ? firstName : 'Student',
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Text(
                        _formattedDate(),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerIconBtn(Icons.verified_rounded, () => UIUBottomSheet.showGradingScale(context)),
              const SizedBox(width: 8),
              _headerIconBtn(Icons.person_rounded, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  // ── CGPA BANNER ────────────────────────────────
  Widget _buildCGPABanner({
    required dynamic student,
    required double requiredSGPA,
    required int progressPct,
    required bool isDark,
    required Color textPri,
    required Color textSec,
  }) {
    final reqColor = requiredSGPA <= 4.0 ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _miniMetricCard(
              label: 'CGPA',
              value: student.currentCGPA.toStringAsFixed(2),
              accent: AppColors.primary,
              icon: Icons.school_rounded,
              isDark: isDark,
              textPri: textPri,
              textSec: textSec,
              onTap: () => MainNavigationScreen.switchTab(context, 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniMetricCard(
              label: 'Progress',
              value: '$progressPct%',
              accent: AppColors.success,
              icon: Icons.pie_chart_rounded,
              isDark: isDark,
              textPri: textPri,
              textSec: textSec,
              onTap: () => MainNavigationScreen.switchTab(context, 2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniMetricCard(
              label: 'Req. GPA',
              value: requiredSGPA.toStringAsFixed(2),
              accent: reqColor,
              icon: Icons.auto_graph_rounded,
              isDark: isDark,
              textPri: textPri,
              textSec: textSec,
              onTap: () => MainNavigationScreen.switchTab(context, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureNavButton({
    required String label,
    required String sub,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textPri,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sub,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 9.5,
                        color: textSec,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 15, color: textSec.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniMetricCard({
    required String label,
    required String value,
    required Color accent,
    required IconData icon,
    required bool isDark,
    required Color textPri,
    required Color textSec,
    VoidCallback? onTap,
  }) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: borderColor),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: AppTypography.titleLarge.copyWith(
                      fontSize: 16, fontWeight: FontWeight.w900, color: accent)),
              Text(label,
                  style: AppTypography.bodySmall.copyWith(
                      fontSize: 10, color: textSec, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── STAT CARD ──────────────────────────────────
  Widget _statCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconBg,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    required int index,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOutBack,
      builder: (context, val, child) => Transform.scale(
        scale: val,
        child: child,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderXl,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: borderColor),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: AppTypography.labelSmall.copyWith(
                            color: textSec,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.2)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconBg.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(icon, size: 16, color: iconBg),
                    ),
                  ],
                ),
                const Spacer(),
                Text(value,
                    style: AppTypography.headlineLarge.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textPri,
                        letterSpacing: -0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(sub,
                    style: AppTypography.bodySmall.copyWith(
                        fontSize: 10, color: textSec),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── PROGRESS SECTION ───────────────────────────
  Widget _buildProgressSection({
    required dynamic student,
    required int progressPct,
    required bool isDark,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DEGREE PROGRESS',
                    style: AppTypography.labelSmall.copyWith(
                        color: textSec,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontSize: 11)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text('$progressPct% Done',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: AppRadius.borderFull,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: student.progressPercentage),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) => LinearProgressIndicator(
                  value: val,
                  minHeight: 10,
                  backgroundColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _progressLabel('Completed', '${student.completedCredits.toInt()} cr', AppColors.primary, textSec),
                _progressLabel('Remaining', '${student.remainingCredits.toInt()} cr', AppColors.accent, textSec),
                _progressLabel('Total', '${student.totalDegreeCredits.toInt()} cr', textSec, textSec),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => MainNavigationScreen.switchTab(context, 2),
                borderRadius: AppRadius.borderBase,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderBase,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Manage Courses in Transcript',
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressLabel(String label, String value, Color valueColor, Color labelColor) =>
      Column(
        children: [
          Text(value,
              style: AppTypography.titleMedium.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w800, color: valueColor)),
          Text(label,
              style: AppTypography.bodySmall.copyWith(
                  fontSize: 10, color: labelColor)),
        ],
      );

  // ── GPA PREDICTOR CARD ─────────────────────────
  Widget _buildPredictorCard({
    required double requiredSGPA,
    required bool isDark,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    required Color sectionClr,
  }) {
    final labelColor = requiredSGPA <= 3.30
        ? AppColors.success
        : requiredSGPA <= 3.75
            ? AppColors.accent
            : requiredSGPA <= 4.0
                ? AppColors.danger
                : AppColors.danger;
    final label = requiredSGPA <= 3.30
        ? '✅ Easily Attainable'
        : requiredSGPA <= 3.75
            ? '⚠️ Challenging'
            : requiredSGPA <= 4.0
                ? '🔥 Extremely Demanding'
                : '❌ Impossible (>4.00)';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('QUICK GPA TARGET PREDICTOR',
                    style: AppTypography.labelSmall.copyWith(
                        color: textSec,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontSize: 11)),
                Icon(Icons.auto_graph_rounded, color: AppColors.accent, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sectionClr,
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Required GPA / Trimester',
                          style: AppTypography.bodySmall.copyWith(
                              color: textSec, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        requiredSGPA.toStringAsFixed(2),
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: labelColor,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: labelColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderBase,
                    ),
                    child: Text(label,
                        style: AppTypography.labelSmall.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => MainNavigationScreen.switchTab(context, 1),
                borderRadius: AppRadius.borderBase,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderBase,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Open Full Trimester GPA Calculator',
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TIPS SECTION ───────────────────────────────
  Widget _buildTipsSection({
    required bool isDark,
    required Color surface,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
  }) {
    final tips = [
      ('🎯', 'Lab Perfection', 'Maintain 4.00 in 1-credit labs — they\'re easy GPA anchors', AppColors.success),
      ('📊', 'Credit Balance', 'Aim for 10–12 credits per trimester for optimal grade probability', AppColors.primary),
      ('📝', 'Midterm Priority', 'UIU weights midterms at 30%. Score 26+ before finals for safety', AppColors.accent),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: borderColor),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI STUDY TIPS',
                style: AppTypography.labelSmall.copyWith(
                    color: textSec,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 11)),
            const SizedBox(height: 12),
            ...tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: t.$4.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(t.$1, style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.$2,
                                style: AppTypography.titleMedium.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: textPri)),
                            const SizedBox(height: 1),
                            Text(t.$3,
                                style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11, color: textSec)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => MainNavigationScreen.switchTab(context, 3),
                borderRadius: AppRadius.borderBase,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderBase,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ask AI Academic Advisor',
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                      const SizedBox(width: 4),
                      const Icon(Icons.auto_awesome_rounded,
                          size: 14, color: AppColors.accent),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BACKGROUND BLOB ────────────────────────────
  Widget _bgBlob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

