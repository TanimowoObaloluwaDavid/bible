import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary       = Color(0xFFFF5C00);
  static const Color primaryDark   = Color(0xFFB34100);
  static const Color primaryDeeper = Color(0xFF8A3200);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color background    = Color(0xFFFFFFFF);
  static const Color surface       = Color(0xFFFFF8F4);
  static const Color orangeTint    = Color(0xFFFFF0E6);
  static const Color orangeTint2   = Color(0xFFFFE4CC);
  static const Color textPrimary   = Color(0xFF1A0A00);
  static const Color textSecondary = Color(0xFF6B3A1F);
  static const Color textMuted     = Color(0xFFB07850);
  static const Color divider       = Color(0xFFFFE4CC);
  static const Color error         = Color(0xFFD64045);
  static const Color success       = Color(0xFF2D8653);

  static ThemeData get light {
    return ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryDark,
        surface: white,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onSurface: textPrimary,
        onError: white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: serif(18, FontWeight.w700, textPrimary),
        iconTheme: const IconThemeData(color: primaryDark),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: sans(15, FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: sans(15, FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: orangeTint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: divider, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 2)),
        labelStyle: sans(14, FontWeight.w500, textSecondary),
        hintStyle: sans(14, FontWeight.w400, textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      cardTheme: const CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: sans(14, FontWeight.w400, white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme() => TextTheme(
    displayLarge:   serif(48, FontWeight.w700, textPrimary),
    displayMedium:  serif(36, FontWeight.w700, textPrimary),
    displaySmall:   serif(28, FontWeight.w700, textPrimary),
    headlineLarge:  serif(26, FontWeight.w700, textPrimary),
    headlineMedium: serif(22, FontWeight.w700, textPrimary),
    headlineSmall:  serif(18, FontWeight.w700, textPrimary),
    titleLarge:     sans(18, FontWeight.w700, textPrimary),
    titleMedium:    sans(16, FontWeight.w600, textPrimary),
    titleSmall:     sans(14, FontWeight.w600, textPrimary),
    bodyLarge:      serif(17, FontWeight.w400, textPrimary),
    bodyMedium:     sans(15, FontWeight.w400, textPrimary),
    bodySmall:      sans(13, FontWeight.w400, textSecondary),
    labelLarge:     sans(14, FontWeight.w700, textPrimary),
    labelMedium:    sans(12, FontWeight.w600, textSecondary),
    labelSmall:     sans(11, FontWeight.w600, textMuted),
  );

  static TextStyle serif(double size, FontWeight weight, [Color? color]) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight, color: color ?? textPrimary, height: 1.35);

  static TextStyle sans(double size, FontWeight weight, [Color? color]) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color ?? textPrimary, height: 1.5);
}
