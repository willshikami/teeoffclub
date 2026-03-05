import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [AppColors] defines the "Minimalist Ultra-Black" color palette.
/// Features a high-contrast combination of True Black and Electric Lime accents.
class AppColors {
  /// The primary brand color used for highlights and action indicators.
  static const Color primary = Color(0xFFC0D700); // Electric Lime

  /// The root background color of the application.
  static const Color background = Color(0xFF000000); // True Black

  /// Elevated surface color used for cards, list items, and containers.
  static const Color surface = Color(0xFF111111); // Elevated Black

  /// High-contrast text and icon color.
  static const Color accent = Color(0xFFFFFFFF); // Pure White

  /// Muted background or border color.
  static const Color muted = Color(0xFF222222); // Darker Gray

  /// Secondary text color for supplementary information.
  static const Color textSecondary = Color(0xFF888888); 
  
  // Compat mappings
  static const Color tertiary = background;
  static const Color textBody = accent;
  static const Color textLight = textSecondary;
  static const Color card = surface;
}

/// [AppTheme] centralizes the visual configuration of the Flutter application.
/// It uses [Material3] and the [Figtree] font to achieve an elegant, modern athletic look.
class AppTheme {
  /// Returns the global configuration for the application's visual style.
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
