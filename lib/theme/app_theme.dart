import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette — mirrors the web app exactly
  static const background = Color(0xFF0B1118);
  static const surface = Color(0xFF0F1923);
  static const surfaceAlt = Color(0xFF131E2B);
  static const border = Color(0xFF1E2D3D);
  static const accent = Color(0xFF06B6D4); // teal
  static const accentDim = Color(0xFF0E7490);
  static const accentGlow = Color(0x2006B6D4);
  static const text = Color(0xFFE6F7F5);
  static const textMuted = Color(0xFF64748B);
  static const textSub = Color(0xFF94A3B8);

  // Lane / section colours (execution flow)
  static const laneUser = Color(0xFF818CF8);
  static const laneFront = Color(0xFF06B6D4);
  static const laneBack = Color(0xFFF59E0B);
  static const laneAI = Color(0xFFA78BFA);
  static const laneDB = Color(0xFF34D399);
  static const laneOutput = Color(0xFFFB923C);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFF87171);
  static const youtube = Color(0xFFEF4444);

  // Chart gradient
  static const chartA = Color(0xFF06B6D4);
  static const chartB = Color(0xFF818CF8);
  static const chartC = Color(0xFF34D399);
  static const chartD = Color(0xFFF59E0B);
  static const chartE = Color(0xFFFB923C);
  static const chartF = Color(0xFFA78BFA);

  static List<Color> chartPalette = [
    chartA,
    chartB,
    chartC,
    chartD,
    chartE,
    chartF,
  ];
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.laneAI,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSurface: AppColors.text,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: _t(28, FontWeight.w700, AppColors.text),
        displayMedium: _t(22, FontWeight.w700, AppColors.text),
        displaySmall: _t(18, FontWeight.w600, AppColors.text),
        headlineMedium: _t(16, FontWeight.w600, AppColors.text),
        headlineSmall: _t(14, FontWeight.w600, AppColors.text),
        titleLarge: _t(15, FontWeight.w600, AppColors.text),
        titleMedium: _t(13, FontWeight.w600, AppColors.text),
        titleSmall: _t(12, FontWeight.w600, AppColors.textSub),
        bodyLarge: _t(14, FontWeight.w400, AppColors.text),
        bodyMedium: _t(13, FontWeight.w400, AppColors.textSub),
        bodySmall: _t(11, FontWeight.w400, AppColors.textMuted),
        labelLarge: _t(13, FontWeight.w600, AppColors.accent),
        labelMedium: _t(11, FontWeight.w600, AppColors.textSub),
        labelSmall: _t(10, FontWeight.w500, AppColors.textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSub),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        labelStyle: const TextStyle(color: AppColors.textSub, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  static TextStyle _t(double size, FontWeight w, Color c) =>
      TextStyle(fontSize: size, fontWeight: w, color: c);
}
