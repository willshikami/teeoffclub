import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [AppColors] defines the new Sage & Forest palette.
class AppColors {
  /// The primary brand color (Light Lime/Yellow from image 01).
  static const Color primary = Color(0xFFF9FF82); 

  /// The sage green/light olive top background.
  static const Color sage = Color(0xFFC8D5B9);

  /// The deep forest green bottom background.
  static const Color forest = Color(0xFF2C3923);

  /// Elevated surface color for cards in the dark section.
  static const Color surface = Color(0xFF2C3923);

  /// High-contrast text color (Pure White for dark, Black for light).
  static const Color accent = Color(0xFFFFFFFF);

  /// Muted colors.
  static const Color textSecondary = Color(0xFF888888); 
  
  /// Bento palette update
  static const Color bentoGreen = primary;
  static const Color bentoBlue = Color(0xFF8ED7F5);
  static const Color bentoOrange = primary;
  static const Color bentoCream = Color(0xFFF5F5F5);

  static const Color background = forest;
  static const Color tertiary = forest;
  static const Color textBody = accent;
  static const Color textLight = textSecondary;
  static const Color card = forest;
}

/// [AppTheme] centralizes the visual configuration of the Flutter application.
class AppTheme {
  /// Returns the global configuration for the application's visual style.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.sage,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.figtreeTextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: Colors.black,
        ),
      ),
    );
  }
}
