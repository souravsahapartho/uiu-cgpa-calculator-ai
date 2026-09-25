import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import 'home_screen.dart';
import 'trimester_gpa_screen.dart';
import 'transcript_import_screen.dart';
import 'ai_advisor_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    TrimesterGPAScreen(),
    TranscriptImportScreen(),
    AIAdvisorScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final navBorder = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffold,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: navBorder, width: 1),
            boxShadow: AppShadows.floating,
          ),
          child: Row(
            children: [
              Expanded(child: _buildNavItem(index: 0, icon: Icons.grid_view_rounded, label: 'Home')),
              Expanded(child: _buildNavItem(index: 1, icon: Icons.calculate_rounded, label: 'GPA')),
              Expanded(child: _buildNavItem(index: 2, icon: Icons.description_rounded, label: 'Transcript')),
              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI',
                  isHero: true,
                ),
              ),
              Expanded(child: _buildNavItem(index: 4, icon: Icons.person_rounded, label: 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isHero = false,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    if (isHero) {
      return GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primarySubtle),
              borderRadius: AppRadius.borderBase,
              boxShadow: isSelected ? AppShadows.primary : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 20,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  const Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
                : Colors.transparent,
            borderRadius: AppRadius.borderBase,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : inactiveColor,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
