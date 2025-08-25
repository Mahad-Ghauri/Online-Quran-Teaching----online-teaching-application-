// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF009688), // Teal (matches logo)
    scaffoldBackgroundColor: const Color(0xFFFDFDFD), // Soft white
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF009688), // Teal
      secondary: const Color(0xFF2ECC71), // Emerald Green
      tertiary: const Color(0xFFF4D03F), // Golden Sand
      background: const Color(0xFFFDFDFD),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF009688),
      elevation: 0,
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.all(8),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF009688),
    scaffoldBackgroundColor: const Color(0xFF0B2239), // Deep Navy
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF009688),
      secondary: const Color(0xFF2ECC71),
      tertiary: const Color(0xFFF4D03F),
      background: const Color(0xFF0B2239),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white60,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF009688),
      elevation: 0,
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2ECC71), // Emerald Green for dark mode
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      color: const Color(0xFF162B45),
      margin: const EdgeInsets.all(8),
    ),
  );
}
