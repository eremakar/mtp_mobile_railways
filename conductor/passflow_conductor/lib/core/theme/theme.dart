import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
class AppColors {
  // Light theme colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightAppBar = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFF6F7FB);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color accentBlue = Color(0xFF0070E0);
  static const Color successGreen = Color(0xFF43A047);
  static const Color errorRed = Color(0xFFD32F2F);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF9CA3AF);
  static const Color darkAppBar = Color(0xFF1F1F1F);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkDivider = Color(0xFF4B5563);
}

final ColorScheme _lightScheme = ColorScheme.fromSeed(
  seedColor: AppColors.accentBlue,
  brightness: Brightness.light,
).copyWith(
  primary: AppColors.accentBlue,
  secondary: AppColors.accentBlue,
  error: AppColors.errorRed,
  surface: const Color.fromARGB(255, 239, 239, 239),
  onSurface: AppColors.lightOnBackground,
  // Use container roles for cards/panels so they don't blend into the page surface.
  surfaceContainerHigh: AppColors.lightSurface,
  surfaceContainerHighest: const Color.fromARGB(255, 255, 255, 255),
  onSurfaceVariant: AppColors.lightSecondaryText,
  outlineVariant: AppColors.lightDivider,
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: _lightScheme,
  scaffoldBackgroundColor: _lightScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _lightScheme.surface,
    foregroundColor: _lightScheme.onSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: _lightScheme.onSurface),
  ),
  cardColor: _lightScheme.surfaceContainerHighest,
  dividerColor: _lightScheme.outlineVariant,
  fontFamily: 'Arial',
);

final ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: AppColors.accentBlue,
  brightness: Brightness.dark,
).copyWith(
  primary: AppColors.accentBlue,
  secondary: AppColors.accentBlue,
  error: AppColors.errorRed,
  surface: AppColors.darkBackground,
  onSurface: AppColors.darkOnBackground,
  surfaceContainerHigh: AppColors.darkSurface,
  surfaceContainerHighest: AppColors.darkSurface,
  onSurfaceVariant: AppColors.darkSecondaryText,
  outlineVariant: AppColors.darkDivider,
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _darkScheme,
  scaffoldBackgroundColor: _darkScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _darkScheme.surface,
    foregroundColor: _darkScheme.onSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: _darkScheme.onSurface),
  ),
  cardColor: _darkScheme.surfaceContainerHighest,
  dividerColor: _darkScheme.outlineVariant,
  fontFamily: 'Arial',
);