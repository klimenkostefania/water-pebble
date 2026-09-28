import 'package:flutter/material.dart';

/// Palette of the OCEAN_FRESH preset with the brief's accent overrides.
class AppColors {
  static const Color bg = Color(0xFFF2FBFF);
  static const Color bgAlt = Color(0xFFE3F4FB);

  static const Color primary = Color(0xFF2A9DCE);
  static const Color primaryDark = Color(0xFF0B4A63);
  static const Color loaderTop = Color(0xFF062B3E);
  static const Color loaderMid = Color(0xFF12708C);

  static const Color accent = Color(0xFF7ED6DF);
  static const Color highlight = Color(0xFFFFD166);
  static const Color highlightDeep = Color(0xFFF7B733);

  static const Color textPrimary = Color(0xFF183B56);
  static const Color textSecondary = Color(0xFF5A88A0);
  static const Color textTertiary = Color(0xFF6C97AC);
  static const Color textOnDark = Color(0xFFEAF8FF);

  static const Color error = Color(0xFFD96B6B);
  static const Color track = Color(0xFFDCEFF6);
  static const Color iconMuted = Color(0xFF8FB6C8);
  static const Color emptyIcon = Color(0xFF9DCEDB);
  static const Color loaderHint = Color(0xFF9FD6E6);
}

class AppTheme {
  /// Preset identifier — must stay exactly 'OCEAN_FRESH'.
  static const String name = 'OCEAN_FRESH';

  static ThemeData build() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      tertiary: AppColors.highlight,
      surface: AppColors.bg,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: AppColors.textTertiary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
