import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Color Palette - Cool Orange Theme for Ubuzima
  static const Color primaryColor = Color(0xFFFF7043); // Cool Orange
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color primaryLight = Color(0xFFFF8A65);

  static const Color secondaryColor = Color(0xFFFFAB40); // Warm Amber
  static const Color secondaryDark = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFCC02);

  static const Color accentColor = Color(0xFFFF5722); // Deep Orange
  static const Color accentLight = Color(0xFFFF7043);

  // Neutral Colors - Orange Theme
  static const Color backgroundColor = Color(
    0xFFFFF8F5,
  ); // Warm white with orange tint
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFFFFFFE);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Gradients - Cool Orange Theme
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, secondaryLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8F5), Color(0xFFFFF3E0)], // Warm orange background
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  // Additional Orange Gradients
  static const LinearGradient warmOrangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7043), Color(0xFFFFAB40)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5722), Color(0xFFFF8A65), Color(0xFFFFCC02)],
  );

  // Spacing
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 50.0;

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    height: 1.4,
  );

  // Aliases for compatibility
  static TextStyle get headlineSmall => headingSmall;
  static TextStyle get headlineMedium => headingMedium;

  // Border color
  static const Color borderColor = Color(0xFFE2E8F0);

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: surfaceColor,
    foregroundColor: primaryColor,
    elevation: 0,
    shadowColor: Colors.transparent,
    side: const BorderSide(color: primaryColor, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
  );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: headingMedium,
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
    ),
  );

  // Kinyarwanda Text Style Helper
  static TextStyle kinyarwandaStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? textSecondary,
      height: height ?? 1.5,
    );
  }
}
