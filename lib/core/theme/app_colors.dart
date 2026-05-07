import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Dark Theme Colors ──────────────────────────────────
  // Background
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1A1F36);
  static const Color surfaceLight = Color(0xFF252A40);

  // Glass
  static const Color glassFill = Color(0x0DFFFFFF); // 5% white
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white
  static const Color glassHighlight = Color(0x33FFFFFF); // 20% white

  // ── Light Theme Colors ─────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFEEEFF5);
  static const Color lightGlassFill = Color(0x0D000000); // 5% black
  static const Color lightGlassBorder = Color(0x1A000000); // 10% black
  static const Color lightTextPrimary = Color(0xFF1A1F36);
  static const Color lightTextSecondary = Color(0xFF6B7085);
  static const Color lightTextTertiary = Color(0xFF9B9FB3);

  // Accents
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color secondary = Color(0xFF00D9FF);
  static const Color secondaryLight = Color(0xFF66E8FF);

  // Semantic
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFFF5252);

  // Text (dark theme defaults)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B8FA3);
  static const Color textTertiary = Color(0xFF5A5E72);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Priority colors
  static const Color priorityLow = Color(0xFF00D9FF);
  static const Color priorityMedium = Color(0xFFFFB74D);
  static const Color priorityHigh = Color(0xFFFF5252);

  // Plan preset colors
  static const List<Color> planColors = [
    Color(0xFF6C63FF),
    Color(0xFF00D9FF),
    Color(0xFF00E676),
    Color(0xFFFFB74D),
    Color(0xFFFF5252),
    Color(0xFFE040FB),
    Color(0xFF448AFF),
    Color(0xFFFF6E40),
  ];

  // ── Theme-aware helpers ────────────────────────────────
  /// Returns the appropriate surface color based on the current theme.
  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surface
        : lightSurface;
  }

  static Color surfaceLightOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceLight
        : lightSurfaceLight;
  }

  static Color glassFillOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? glassFill
        : lightGlassFill;
  }

  static Color glassBorderOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? glassBorder
        : lightGlassBorder;
  }

  static Color textPrimaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimary
        : lightTextPrimary;
  }

  static Color textSecondaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondary
        : lightTextSecondary;
  }

  static Color textTertiaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textTertiary
        : lightTextTertiary;
  }
}
