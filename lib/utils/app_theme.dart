import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Minimalist High-End Golf Theme
  static const Color primary = Color(0xFFC0D700); // Electric Lime
  static const Color background = Color(0xFF000000); // True Black
  static const Color surface = Color(0xFF111111); // Elevated Black
  static const Color accent = Color(0xFFFFFFFF); // Pure White
  static const Color muted = Color(0xFF222222); // Darker Gray
  static const Color textSecondary = Color(0xFF888888); 
  
  // Compat mappings
  static const Color tertiary = background;
  static const Color textBody = accent;
  static const Color textLight = textSecondary;
  static const Color card = surface;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.accent,
      ),
      textTheme: GoogleFonts.figtreeTextTheme().apply(
        bodyColor: AppColors.accent,
        displayColor: AppColors.accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
