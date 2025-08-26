// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette extracted from logo
  static const Color primaryTeal = Color(0xFF00A693); // Main teal from logo
  static const Color accentTeal = Color(0xFF00BFA5); // Lighter teal
  static const Color deepTeal = Color(0xFF00796B); // Darker teal
  static const Color complementaryOrange = Color(0xFFFF7043); // Warm complement
  static const Color lightBackground = Color(
    0xFFF8FDFC,
  ); // Very light teal tint
  static const Color darkBackground = Color.fromARGB(255, 38, 92, 82); // Deep teal-dark
  static const Color cardDark = Color.fromARGB(255, 36, 66, 60); // Dark teal for cards

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.light(
      primary: primaryTeal,
      secondary: accentTeal,
      tertiary: complementaryOrange,
      surface: Colors.white,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1A1A1A),
      onBackground: const Color(0xFF1A1A1A),
    ),
    textTheme: TextTheme(
      // Headings with serif font for educational/academic feel
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
        letterSpacing: -0.25,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTeal,
      ),
      // Body text with clean sans-serif
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF2A2A2A),
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFF666666),
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFF888888),
      ),
      // Labels and buttons
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: primaryTeal.withOpacity(0.1),
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryTeal,
      ),
      iconTheme: const IconThemeData(color: primaryTeal, size: 24),
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryTeal.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: BorderSide(color: primaryTeal, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: primaryTeal.withOpacity(0.1),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    iconTheme: const IconThemeData(color: primaryTeal, size: 24),
    dividerTheme: DividerThemeData(
      color: primaryTeal.withOpacity(0.1),
      thickness: 1,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentTeal,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.dark(
      primary: accentTeal,
      secondary: primaryTeal,
      tertiary: complementaryOrange,
      surface: cardDark,
      background: darkBackground,
      onPrimary: darkBackground,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.25,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: accentTeal,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.9),
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white.withOpacity(0.7),
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white.withOpacity(0.6),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkBackground,
        letterSpacing: 0.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: accentTeal.withOpacity(0.1),
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: accentTeal,
      ),
      iconTheme: const IconThemeData(color: accentTeal, size: 24),
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentTeal,
        foregroundColor: darkBackground,
        elevation: 3,
        shadowColor: accentTeal.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentTeal,
        side: BorderSide(color: accentTeal, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      color: cardDark,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentTeal,
      foregroundColor: darkBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    iconTheme: const IconThemeData(color: accentTeal, size: 24),
    dividerTheme: DividerThemeData(
      color: accentTeal.withOpacity(0.2),
      thickness: 1,
    ),
  );

  // Helper methods for consistent styling
  static BoxDecoration get lightCardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryTeal.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: cardDark,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // Gradient for special elements
  static LinearGradient get tealGradient => LinearGradient(
    colors: [primaryTeal, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
