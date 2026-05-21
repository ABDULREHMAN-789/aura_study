import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraColors {
  static const Color background = Color(0xFF070913);
  static const Color surface = Color(0xFF0F1225);
  static const Color cardBg = Color(0x12FFFFFF); // Transparent glassmorphic base
  static const Color border = Color(0x1AFFFFFF); // Subtle thin white border
  
  // Neon Futuristic Accent Palette
  static const Color accentIndigo = Color(0xFF8F5BFF);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGreen = Color(0xFF00FF87);
  static const Color accentPink = Color(0xFFFF007A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8F9BB3);
  static const Color textMuted = Color(0xFF555F7D);

  // Gradients for high-end look
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentIndigo, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [accentCyan, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [accentPink, accentIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AuraTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AuraColors.accentIndigo,
      scaffoldBackgroundColor: AuraColors.background,
      cardColor: AuraColors.surface,
      
      colorScheme: const ColorScheme.dark(
        primary: AuraColors.accentIndigo,
        secondary: AuraColors.accentCyan,
        surface: AuraColors.surface,
        error: AuraColors.accentPink,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AuraColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AuraColors.textPrimary,
          letterSpacing: 1.2,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AuraColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AuraColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AuraColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AuraColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AuraColors.textSecondary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AuraColors.textMuted,
        ),
      ),

      cardTheme: CardThemeData(
        color: AuraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AuraColors.border, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AuraColors.textPrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: AuraColors.textPrimary),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AuraColors.accentCyan,
        unselectedItemColor: AuraColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
