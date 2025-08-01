import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Helper class for localization utilities
class LocalizationHelper {
  /// Get AppLocalizations instance from context
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// Get localized greeting based on time of day
  static String getGreeting(BuildContext context) {
    final l10n = of(context);
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 17) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  /// Get localized role display name
  static String getRoleDisplayName(BuildContext context, String role) {
    final l10n = of(context);

    switch (role.toUpperCase()) {
      case 'ADMIN':
        return l10n.administrator;
      case 'HEALTH_WORKER':
        return l10n.healthWorker;
      case 'CLIENT':
        return l10n.client;
      default:
        return role;
    }
  }

  /// Get localized appointment type
  static String getAppointmentType(BuildContext context, String type) {
    final l10n = of(context);

    switch (type.toUpperCase()) {
      case 'CONSULTATION':
        return l10n.consultation;
      case 'FAMILY_PLANNING':
        return l10n.familyPlanning;
      case 'PRENATAL_CARE':
        return l10n.prenatalCare;
      case 'POSTNATAL_CARE':
        return l10n.postnatalCare;
      case 'VACCINATION':
        return l10n.vaccination;
      case 'HEALTH_SCREENING':
        return l10n.healthScreening;
      case 'FOLLOW_UP':
        return l10n.followUp;
      case 'EMERGENCY':
        return l10n.emergency;
      case 'COUNSELING':
        return l10n.counseling;
      case 'OTHER':
        return l10n.other;
      default:
        return type;
    }
  }

  /// Get localized medication frequency
  static String getMedicationFrequency(BuildContext context, String frequency) {
    final l10n = of(context);

    switch (frequency.toLowerCase()) {
      case 'once daily':
        return l10n.onceDaily;
      case 'twice daily':
        return l10n.twiceDaily;
      case 'three times daily':
        return l10n.threeTimes;
      case 'four times daily':
        return l10n.fourTimes;
      case 'as needed':
        return l10n.asNeeded;
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      default:
        return frequency;
    }
  }

  /// Get localized flow type
  static String getFlowType(BuildContext context, String flowType) {
    final l10n = of(context);

    switch (flowType.toLowerCase()) {
      case 'spotting':
        return l10n.spotting;
      case 'light':
        return l10n.light;
      case 'medium':
        return l10n.medium;
      case 'heavy':
        return l10n.heavy;
      default:
        return flowType;
    }
  }

  /// Get localized language name
  static String getLanguageName(BuildContext context, String languageCode) {
    final l10n = of(context);

    switch (languageCode.toLowerCase()) {
      case 'en':
        return l10n.english;
      case 'fr':
        return l10n.french;
      case 'rw':
        return l10n.kinyarwanda;
      default:
        return languageCode;
    }
  }

  /// Check if current locale is RTL (Right-to-Left)
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  /// Get current language code
  static String getCurrentLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  /// Check if current language is specific language
  static bool isCurrentLanguage(BuildContext context, String languageCode) {
    return getCurrentLanguageCode(context) == languageCode;
  }

  /// Get localized contraception method name
  static String getContraceptionMethodName(
    BuildContext context,
    String methodType,
  ) {
    final l10n = of(context);

    switch (methodType.toUpperCase()) {
      case 'PILL':
        return l10n.birthControlPills;
      case 'INJECTION':
        return l10n.injection;
      case 'IMPLANT':
        return l10n.implant;
      case 'IUD':
        return l10n.iud;
      case 'CONDOM':
        return l10n.condoms;
      case 'DIAPHRAGM':
        return l10n.diaphragm;
      case 'PATCH':
        return l10n.patch;
      case 'RING':
        return l10n.ring;
      case 'NATURAL_FAMILY_PLANNING':
        return l10n.naturalFamilyPlanning;
      case 'STERILIZATION':
        return l10n.sterilization;
      case 'EMERGENCY_CONTRACEPTION':
        return l10n.emergencyContraception;
      default:
        return methodType;
    }
  }

  /// Get localized contraception method category
  static String getContraceptionMethodCategory(
    BuildContext context,
    String category,
  ) {
    final l10n = of(context);

    switch (category.toLowerCase()) {
      case 'hormonal methods':
        return l10n.hormonalMethods;
      case 'barrier methods':
        return l10n.barrierMethods;
      case 'natural methods':
        return l10n.naturalMethods;
      case 'permanent methods':
        return l10n.permanentMethods;
      case 'other methods':
        return l10n.otherMethods;
      default:
        return category;
    }
  }

  /// Get localized side effect severity
  static String getSideEffectSeverity(BuildContext context, String severity) {
    final l10n = of(context);

    switch (severity.toLowerCase()) {
      case 'mild':
        return l10n.mild;
      case 'moderate':
        return l10n.moderate;
      case 'severe':
        return l10n.severe;
      default:
        return severity;
    }
  }

  /// Get localized side effect frequency
  static String getSideEffectFrequency(BuildContext context, String frequency) {
    final l10n = of(context);

    switch (frequency.toLowerCase()) {
      case 'rare':
        return l10n.rare;
      case 'occasional':
        return l10n.occasional;
      case 'common':
        return l10n.common;
      case 'frequent':
        return l10n.frequent;
      default:
        return frequency;
    }
  }
}
