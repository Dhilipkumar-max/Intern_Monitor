import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary & Brand Colors (Editorial Green)
  static const Color primaryColor = Color(0xFF006A39);
  static const Color primaryContainer = Color(0xFF008649);
  static const Color secondaryContainer = Color(0xFFBBEBC5);
  
  // Status Colors (Refined)
  static const Color successColor = Color(0xFF006A39);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color accentColor = Color(0xFF22C55E);
  static const Color tertiaryColor = Color(0xFFA23546); // Refined Red
  
  // Neutral Colors (Tonal Stacking)
  static const Color backgroundColor = Color(0xFFF8F9FA); // Base Desk
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5); // Folder
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Paper/Card
  
  static const Color textPrimary = Color(0xFF191C1D); // Jet Black Softened
  static const Color textSecondary = Color(0xFF3E4A3F); // On Surface Variant
  static const Color sidebarText = Color(0xFF3E4A3F); 
  static const Color borderColor = Color(0xFFE5E7EB);
  
  // Sidebar/Navigation
  static const Color sidebarBackground = Color(0xFFFFFFFF);
  static const Color sidebarActive = Color(0xFFBBEBC5);

  static const List<String> departments = [
    'Computer Science and Engineering',
    'Artificial Intelligence & Machine Learning',
    'Electronics and Communication Engineering',
    'Artificial Intelligence & Data Science',
    'Computer Communication Engineering',
    'Computer Science and Business System',
    'BioTech',
    'VLSI',
    'Mechanical Engineering'
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: secondaryContainer,
        onSecondary: Color(0xFF00210E),
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: Color(0xFF416C4D),
        surface: surfaceColor,
        onSurface: textPrimary,
        tertiary: tertiaryColor,
        error: errorColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.02,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.7),
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'verified':
      case 'active':
        return primaryColor;
      case 'ongoing':
      case 'assigned':
        return const Color(0xFF3B82F6);
      case 'pending':
        return warningColor;
      case 'rejected':
      case 'not done':
      case 'not assigned':
        return errorColor;
      default:
        return textSecondary;
    }
  }
}
