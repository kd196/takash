import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1B8C3A);
  static const Color primaryDark = Color(0xFF14692D);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color accent = Color(0xFFFFB300);
  static const Color accentDark = Color(0xFFFF8F00);
  static const Color surfaceLight = Color(0xFFF8FAF8);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  static ThemeData get lightTheme {
    final brightness = Brightness.light;
    final colorScheme = ColorScheme(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDCFCE7),
      onPrimaryContainer: const Color(0xFF14532D),
      secondary: accent,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFF3E0),
      onSecondaryContainer: const Color(0xFF7A4100),
      tertiary: const Color(0xFF0EA5E9),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE0F2FE),
      onTertiaryContainer: const Color(0xFF0C4A6E),
      error: error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF991B1B),
      surface: Colors.white,
      onSurface: textPrimary,
      surfaceContainerHighest: const Color(0xFFF5F5F5),
      outline: const Color(0xFFD1D5DB),
      outlineVariant: const Color(0xFFE5E7EB),
      shadow: const Color(0x1A000000),
      scrim: Colors.black,
      inverseSurface: const Color(0xFF1F2937),
      onInverseSurface: Colors.white,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceLight,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
        headlineMedium: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
        headlineSmall: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w700, height: 1.3),
        titleLarge: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
        titleMedium: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
        titleSmall: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
        labelMedium: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, height: 1.3),
        labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0.3),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: const Color(0x0D000000),
        surfaceTintColor: Colors.transparent,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        hoverColor: const Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: textTertiary, fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.inter(
            fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: const Color(0xFFDCFCE7),
        labelStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final brightness = Brightness.dark;
    final colorScheme = ColorScheme(
      primary: const Color(0xFF4ADE80),
      onPrimary: const Color(0xFF14532D),
      primaryContainer: const Color(0xFF166534),
      onPrimaryContainer: const Color(0xFFDCFCE7),
      secondary: const Color(0xFFFCD34D),
      onSecondary: const Color(0xFF713F12),
      secondaryContainer: const Color(0xFF92400E),
      onSecondaryContainer: const Color(0xFFFFF3E0),
      tertiary: const Color(0xFF38BDF8),
      onTertiary: const Color(0xFF0C4A6E),
      tertiaryContainer: const Color(0xFF075985),
      onTertiaryContainer: const Color(0xFFE0F2FE),
      error: const Color(0xFFFCA5A5),
      onError: const Color(0xFF7F1D1D),
      errorContainer: const Color(0xFF991B1B),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: const Color(0xFF111827),
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF1F2937),
      outline: const Color(0xFF374151),
      outlineVariant: const Color(0xFF4B5563),
      shadow: const Color(0x33000000),
      scrim: Colors.black,
      inverseSurface: const Color(0xFFF9FAFB),
      onInverseSurface: const Color(0xFF1F2937),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF374151), width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ADE80),
          foregroundColor: const Color(0xFF14532D),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4ADE80), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1F2937),
        selectedColor: const Color(0xFF166534),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
        space: 0,
      ),
    );
  }
}
