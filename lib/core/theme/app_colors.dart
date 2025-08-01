import 'package:flutter/material.dart';

/// Professional Family Planning Application Color Scheme
class AppColors {
  // Primary Colors - Enhanced warm orange theme
  static const Color primary = Color(
    0xFFFF6B35,
  ); // Warm Orange - welcoming and energetic
  static const Color primaryLight = Color(0xFFFFE0D6);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryVariant = Color(0xFFFF8A65);

  // Secondary Colors - Modern and trustworthy
  static const Color secondary = Color(
    0xFF6C5CE7,
  ); // Modern Purple - trust and wisdom
  static const Color secondaryLight = Color(0xFFE8E4FF);
  static const Color secondaryDark = Color(0xFF5A4FCF);
  static const Color secondaryVariant = Color(0xFF8B7ED8);

  // Tertiary Colors - Fresh and vibrant
  static const Color tertiary = Color(
    0xFF00D2FF,
  ); // Bright Cyan - health and vitality
  static const Color tertiaryLight = Color(0xFFB3F0FF);
  static const Color tertiaryDark = Color(0xFF00A8CC);

  // Neutral Colors - Clean and modern
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFF0F0F0);

  // Text Colors - Clear hierarchy
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors - Clear communication
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);

  // Border Colors - Subtle definition
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Family Planning Specific Colors
  static const Color menstrualRed = Color(0xFFE53E3E); // Period tracking
  static const Color menstrualLight = Color(0xFFFED7D7);
  static const Color fertilityGreen = Color(0xFF38A169); // Fertile window
  static const Color fertilityLight = Color(0xFFC6F6D5);
  static const Color ovulationBlue = Color(0xFF3182CE); // Ovulation day
  static const Color ovulationLight = Color(0xFFBEE3F8);
  static const Color pregnancyPurple = Color(0xFF805AD5); // Pregnancy planning
  static const Color pregnancyLight = Color(0xFFE9D8FD);
  static const Color contraceptionOrange = Color(0xFFDD6B20); // Contraception
  static const Color contraceptionLight = Color(0xFFFBD38D);

  // Health Status Colors
  static const Color healthNormal = Color(0xFF4CAF50); // Normal/Good health
  static const Color healthWarning = Color(0xFFFF9800); // Attention needed
  static const Color healthCritical = Color(0xFFF44336); // Critical/Urgent
  static const Color healthRecordGreen = Color(0xFF4CAF50); // Health records

  // Education Colors
  static const Color educationBlue = Color(0xFF1976D2);
  static const Color educationLight = Color(0xFFE3F2FD);
  static const Color progressGreen = Color(0xFF388E3C);
  static const Color progressLight = Color(0xFFE8F5E8);

  // Support Group Colors
  static const Color supportPurple = Color(0xFF7B1FA2);
  static const Color supportLight = Color(0xFFF3E5F5);
  static const Color communityTeal = Color(0xFF00796B);
  static const Color communityLight = Color(0xFFE0F2F1);

  // Appointment Colors
  static const Color appointmentBlue = Color(0xFF1565C0);
  static const Color appointmentLight = Color(0xFFE1F5FE);
  static const Color scheduledGreen = Color(0xFF2E7D32);
  static const Color pendingOrange = Color(0xFFE65100);
  static const Color cancelledRed = Color(0xFFC62828);

  // Medication Colors
  static const Color medicationPink = Color(0xFFAD1457);
  static const Color medicationLight = Color(0xFFFCE4EC);
  static const Color sideEffectYellow = Color(0xFFF57F17);
  static const Color sideEffectLight = Color(0xFFFFF9C4);

  // Role-based Colors
  static const Color adminPurple = Color(0xFF673AB7);
  static const Color adminLight = Color(0xFFEDE7F6);
  static const Color healthWorkerBlue = Color(0xFF1976D2);
  static const Color healthWorkerLight = Color(0xFFE3F2FD);
  static const Color clientPink = Color(0xFFE91E63);
  static const Color clientLight = Color(0xFFFCE4EC);

  // Gradient Colors for enhanced UI
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient healthGradient = LinearGradient(
    colors: [tertiary, tertiaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors
  static const Color overlayLight = Color(0x33000000);
  static const Color overlayMedium = Color(0x66000000);
  static const Color overlayDark = Color(0x99000000);

  // Shimmer Colors for loading states
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Chart Colors for health analytics
  static const List<Color> chartColors = [
    primary,
    secondary,
    tertiary,
    warning,
    info,
    pregnancyPurple,
    contraceptionOrange,
    supportPurple,
  ];
}
