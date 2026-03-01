import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra Premium Color Palette (Light Mode - Slate & Indigo)
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400

  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color accent = Color(0xFFF43F5E); // Rose 500

  // Neutral Backgrounds
  static const Color bgDark = Color(0xFFF1F5F9); // Slate 100 (Deepest)
  static const Color bgSurface = Color(0xFFF8FAFC); // Slate 50 (Standard)
  static const Color bgCard = Color(0xFFFFFFFF); // Pure White
  static const Color bgCardLight = Color(0xFFFFFFFF); // Pure White

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (Main Title)
  static const Color textSecondary = Color(0xFF334155); // Slate 700 (Body)
  static const Color textMuted = Color(0xFF64748B); // Slate 500 (Captions)
  static const Color textDisabled = Color(0xFF94A3B8); // Slate 400

  // Modern Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Sophisticated Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Layered Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> deepShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 30,
          offset: const Offset(0, 10),
          spreadRadius: -5,
        ),
      ];

  // Border Settings
  static Border sideBorder = Border.all(
    color: const Color(0xFFE2E8F0), // Slate 200
    width: 1,
  );

  static BorderRadius radiusSmall = BorderRadius.circular(12);
  static BorderRadius radiusMedium = BorderRadius.circular(20);
  static BorderRadius radiusLarge = BorderRadius.circular(32);

  static BorderRadius borderRadius = radiusMedium;
  static BorderRadius borderRadiusSmall = radiusSmall;
  static List<BoxShadow> cardShadow = softShadow;
  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x1A6366F1), Color(0x054338CA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Theme Data Construction
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bgSurface,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
              headlineMedium: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              bodyLarge: const TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: const TextStyle(color: textSecondary),
            ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: bgCard,
        error: error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusMedium,
          side: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: textDisabled),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: radiusSmall),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
