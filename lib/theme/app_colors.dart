import 'package:flutter/material.dart';

class AppColors {
  // UIU Official Brand Palette (From UIU Logo)
  static const Color primary = Color(0xFFF26522); // Official UIU Orange
  static const Color primaryLight = Color(0xFFFF7A3D);
  static const Color primaryDark = Color(0xFFD44F0F);
  static const Color primarySubtle = Color(0xFFFFF1EB);

  static const Color secondary = Color(0xFF1E293B); // UIU Slate Navy / Charcoal
  static const Color secondaryLight = Color(0xFF334155);
  static const Color secondaryDark = Color(0xFF0F172A);
  static const Color secondarySubtle = Color(0xFFF1F5F9);

  static const Color accent = Color(0xFFEA580C);
  static const Color accentLight = Color(0xFFFB923C);
  static const Color accentDark = Color(0xFFC2410C);
  static const Color accentSubtle = Color(0xFFFFF7ED);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF047857);

  static const Color danger = Color(0xFFE11D48);
  static const Color dangerLight = Color(0xFFFFE4E6);
  static const Color dangerDark = Color(0xFF9F1239);
  static const Color error = Color(0xFFE11D48);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Background Layers
  static const Color scaffold = Color(0xFFF7F8FC);
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color section = Color(0xFFF3F6FB);
  static const Color surfaceMuted = Color(0xFFF3F6FB);
  static const Color border = Color(0xFFE6ECF5);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Dark Theme Surfaces
  static const Color darkScaffold = Color(0xFF0B111E);
  static const Color darkSurface = Color(0xFF131D31);
  static const Color darkSection = Color(0xFF1A263E);
  static const Color darkBorder = Color(0xFF243452);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFF26522), Color(0xFFFF7A3D), Color(0xFFD44F0F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy mappings for backward compatibility
  static const Color navy = Color(0xFF1E293B);
  static const Color navyLight = Color(0xFF334155);
  static const Color navyMuted = Color(0xFF475569);
  static const Color navySubtle = Color(0xFFF1F5F9);
  static const Color uiuOrange = Color(0xFFF26522);
  static const Color lightBg = scaffold;
  static const Color lightSurface = surface;
  static const Color lightSurfaceMuted = section;
  static const Color lightBorder = border;
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightTextTertiary = textTertiary;
  static const Color darkBg = darkScaffold;
  static const Color darkSurfaceMuted = darkSection;
}
