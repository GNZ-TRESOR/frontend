import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Helper class to automatically translate common hardcoded strings
class AutoTranslateHelper {
  static final Map<String, String Function(AppLocalizations)> _translations = {
    // Common UI elements
    'Save': (l) => l.save,
    'Cancel': (l) => l.cancel,
    'Delete': (l) => l.delete,
    'Edit': (l) => l.edit,
    'Add': (l) => l.add,
    'Search': (l) => l.search,
    'Filter': (l) => l.filter,
    'Sort': (l) => l.sort,
    'Refresh': (l) => l.refresh,
    'Loading...': (l) => l.loading,
    'Error': (l) => l.error,
    'Success': (l) => l.success,
    'Warning': (l) => l.warning,
    'Information': (l) => l.info,
    'Confirm': (l) => l.confirm,
    'Yes': (l) => l.yes,
    'No': (l) => l.no,
    'OK': (l) => l.ok,
    'Close': (l) => l.close,
    'Back': (l) => l.back,
    'Next': (l) => l.next,
    'Previous': (l) => l.previous,
    'Done': (l) => l.done,
    'Submit': (l) => l.submit,
    'Send': (l) => l.send,
    'View': (l) => l.view,
    'Details': (l) => l.details,
    'More': (l) => l.more,
    'Less': (l) => l.less,
    'Show': (l) => l.show,
    'Hide': (l) => l.hide,
    'Select': (l) => l.select,
    'Choose': (l) => l.choose,

    'Create': (l) => l.create,
    'Open': (l) => l.open,
    'Update': (l) => l.update,
    'Clear': (l) => l.clear,
    'Reset': (l) => l.reset,

    // Health-specific terms
    'Welcome back,': (l) => l.welcomeBackComma,
    'Let\'s track your health journey': (l) => l.letsTrackYourHealthJourney,
    'Appointment Management': (l) => l.appointmentManagement,
    'My Appointments': (l) => l.myAppointments,
    'Health Overview': (l) => l.healthOverview,
    'Total Records': (l) => l.totalRecords,
    'Recent (30d)': (l) => l.recentRecords,
    'General Consultation': (l) => l.generalConsultation,
    'Follow-up Visit': (l) => l.followUpVisit,
    'Health Counseling': (l) => l.healthCounseling,
    'Dashboard': (l) => l.dashboard,
    'Appointments': (l) => l.appointments,
    'Health Records': (l) => l.healthRecords,
    'Medications': (l) => l.medications,
    'Education': (l) => l.education,
    'Community': (l) => l.community,
    'Profile': (l) => l.profile,
    'Settings': (l) => l.settings,
    'Logout': (l) => l.logout,
    'Home': (l) => l.home,
    'Health': (l) => l.health,
    'Book Appointment': (l) => l.bookAppointment,
    'View Records': (l) => l.viewRecords,
    'Track Cycle': (l) => l.trackCycle,
    'AI Assistant': (l) => l.aiAssistant,
    'Read screen content aloud': (l) => l.readScreenContentAloud,
    'Today': (l) => l.today,
    'Upcoming': (l) => l.upcoming,
    'Past': (l) => l.past,
    'All': (l) => l.all,
    'Manage Slots': (l) => l.manageSlots,

    // Appointment types
    'Consultation': (l) => l.consultation,
    'Family Planning': (l) => l.familyPlanning,
    'Prenatal Care': (l) => l.prenatalCare,
    'Postnatal Care': (l) => l.postnatalCare,
    'Vaccination': (l) => l.vaccination,
    'Health Screening': (l) => l.healthScreening,
    'Follow Up': (l) => l.followUp,
    'Emergency': (l) => l.emergency,
    'Counseling': (l) => l.counseling,
    'Other': (l) => l.other,

    // Medication frequencies
    'Once daily': (l) => l.onceDaily,
    'Twice daily': (l) => l.twiceDaily,
    'Three times daily': (l) => l.threeTimes,
    'Four times daily': (l) => l.fourTimes,
    'As needed': (l) => l.asNeeded,
    'Weekly': (l) => l.weekly,
    'Monthly': (l) => l.monthly,

    // Menstrual flow types
    'Spotting': (l) => l.spotting,
    'Light': (l) => l.light,
    'Medium': (l) => l.medium,
    'Heavy': (l) => l.heavy,

    // Language settings
    'Language': (l) => l.language,
    'Select Language': (l) => l.selectLanguage,
    'English': (l) => l.english,
    'Français': (l) => l.french,
    'Kinyarwanda': (l) => l.kinyarwanda,

    // Login screen
    'Welcome Back': (l) => l.welcomeBack,
    'Sign in to continue your health journey': (l) => l.signInToContinue,
    'Email': (l) => l.email,
    'Email Address': (l) => l.emailAddress,
    'Enter your email': (l) => l.enterEmail,
    'Please enter your email': (l) => l.pleaseEnterEmail,
    'Please enter a valid email': (l) => l.pleaseEnterValidEmail,
    'Password': (l) => l.password,
    'Enter your password': (l) => l.enterPassword,
    'Please enter your password': (l) => l.pleaseEnterPassword,
    'Password must be at least 6 characters': (l) => l.passwordTooShort,
    'Remember me': (l) => l.rememberMe,
    'Sign In': (l) => l.signIn,
    'Forgot Password?': (l) => l.forgotPassword,
    'OR': (l) => l.or,
    'Don\'t have an account?': (l) => l.dontHaveAccount,
    'Create Account': (l) => l.createAccount,
    'Terms of Service': (l) => l.termsOfService,
    'Privacy Policy': (l) => l.privacyPolicy,
    'By signing in, you agree to our': (l) => l.bySigningIn,
    ' and ': (l) => l.and,

    // Greetings
    'Good morning': (l) => l.goodMorning,
    'Good afternoon': (l) => l.goodAfternoon,
    'Good evening': (l) => l.goodEvening,

    // Roles
    'Administrator': (l) => l.administrator,
    'Health Worker': (l) => l.healthWorker,
    'Client': (l) => l.client,

    // Success messages
    'Login successful!': (l) => l.loginSuccess,
    'Registration successful!': (l) => l.registrationSuccess,
    'Updated successfully!': (l) => l.updateSuccess,
    'Deleted successfully!': (l) => l.deleteSuccess,
  };

  /// Automatically translate a string if translation exists
  static String translate(BuildContext context, String text) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return text;

    final translator = _translations[text];
    if (translator != null) {
      return translator(localizations);
    }

    return text; // Return original text if no translation found
  }

  /// Check if a translation exists for the given text
  static bool hasTranslation(String text) {
    return _translations.containsKey(text);
  }

  /// Get all available translations
  static Map<String, String Function(AppLocalizations)> get translations =>
      _translations;

  /// Add a new translation mapping
  static void addTranslation(
    String key,
    String Function(AppLocalizations) translator,
  ) {
    _translations[key] = translator;
  }

  /// Remove a translation mapping
  static void removeTranslation(String key) {
    _translations.remove(key);
  }

  /// Clear all translations
  static void clearTranslations() {
    _translations.clear();
  }
}

/// Extension to make translation easier
extension StringTranslation on String {
  /// Translate this string using AutoTranslateHelper
  String tr(BuildContext context) {
    return AutoTranslateHelper.translate(context, this);
  }
}

/// Widget that automatically translates its text
class AutoTranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const AutoTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      AutoTranslateHelper.translate(context, text),
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
