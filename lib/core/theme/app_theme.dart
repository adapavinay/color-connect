import 'package:flutter/material.dart';

class CCColors {
  static const primary   = Color(0xFF3D5AFE); // Indigo A400
  static const secondary = Color(0xFF00C853); // Emerald
  static const accent    = Color(0xFFFFCA28); // Amber 400
  static const bg        = Color(0xFFF7F8FC);
  static const surface   = Color(0xFFFFFFFF);
  static const text      = Color(0xFF0F172A);
  static const subt      = Color(0xFF475569);
  static const board     = Color(0xFF0B0B0E); // black board for grid area
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: CCColors.primary,
      onPrimary: Colors.white,
      secondary: CCColors.secondary,
      onSecondary: Colors.white,
      tertiary: CCColors.accent,
      onTertiary: CCColors.text,
      surface: CCColors.surface,
      onSurface: CCColors.text,
      background: CCColors.bg,
      onBackground: CCColors.text,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: CCColors.bg,
      textTheme: base.textTheme.apply(
        bodyColor: CCColors.text,
        displayColor: CCColors.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CCColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: CCColors.text,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CCColors.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CCColors.secondary, // secondary filled (Daily)
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CCColors.text,
          side: BorderSide(color: CCColors.subt.withOpacity(.2)),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: CCColors.surface,
        side: BorderSide(color: CCColors.subt.withOpacity(.15)),
        labelStyle: TextStyle(color: CCColors.subt),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CCColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      cardTheme: CardThemeData(
        color: CCColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: CCColors.subt.withOpacity(.12),
    );
  }
}
