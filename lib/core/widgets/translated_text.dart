import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A comprehensive text widget that automatically translates common strings
class TranslatedText extends StatelessWidget {
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

  const TranslatedText(
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
      _getTranslatedText(context, text),
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

  /// Get translated text for common strings
  String _getTranslatedText(BuildContext context, String originalText) {
    // final l = AppLocalizations.of(context);
    // if (l == null) return originalText;

    // Temporarily return original text until localization is properly set up
    return originalText;

    /*
    // Create a comprehensive mapping of common strings
    final translations = <String, String>{
      // Basic UI
      'Save': l.save,
      'Cancel': l.cancel,
      'Delete': l.delete,
      'Edit': l.edit,
      'Add': l.add,
      'Search': l.search,
      'Filter': l.filter,
      'Sort': l.sort,
      'Refresh': l.refresh,
      'Loading...': l.loading,
      'Error': l.error,
      'Success': l.success,
      'Warning': l.warning,
      'Information': l.info,
      'Confirm': l.confirm,
      'Yes': l.yes,
      'No': l.no,
      'OK': l.ok,
      'Close': l.close,
      'Back': l.back,
      'Next': l.next,
      'Previous': l.previous,
      'Done': l.done,
      'Submit': l.submit,
      'Send': l.send,
      'View': l.view,
      'Details': l.details,
      'More': l.more,
      'Less': l.less,
      'Show': l.show,
      'Hide': l.hide,
      'Select': l.select,
      'Choose': l.choose,

      'Create': l.create,
      'Open': l.open,
      'Update': l.update,
      'Clear': l.clear,
      'Reset': l.reset,

      // Health-specific
      'Welcome back,': l.welcomeBackComma,
      'Let\'s track your health journey': l.letsTrackYourHealthJourney,
      'Appointment Management': l.appointmentManagement,
      'My Appointments': l.myAppointments,
      'Health Overview': l.healthOverview,
      'Total Records': l.totalRecords,
      'Recent (30d)': l.recentRecords,
      'General Consultation': l.generalConsultation,
      'Follow-up Visit': l.followUpVisit,
      'Health Counseling': l.healthCounseling,
      'Dashboard': l.dashboard,
      'Appointments': l.appointments,
      'Health Records': l.healthRecords,
      'Medications': l.medications,
      'Education': l.education,
      'Community': l.community,
      'Profile': l.profile,
      'Settings': l.settings,
      'Logout': l.logout,
      'Home': l.home,
      'Health': l.health,
      'Book Appointment': l.bookAppointment,
      'View Records': l.viewRecords,
      'Track Cycle': l.trackCycle,
      'AI Assistant': l.aiAssistant,
      'Read screen content aloud': l.readScreenContentAloud,
      'Today': l.today,
      'Upcoming': l.upcoming,
      'Past': l.past,
      'All': l.all,
      'Manage Slots': l.manageSlots,

      // Appointment types
      'Consultation': l.consultation,
      'Family Planning': l.familyPlanning,
      'Prenatal Care': l.prenatalCare,
      'Postnatal Care': l.postnatalCare,
      'Vaccination': l.vaccination,
      'Health Screening': l.healthScreening,
      'Follow Up': l.followUp,
      'Emergency': l.emergency,
      'Counseling': l.counseling,
      'Other': l.other,

      // Medication frequencies
      'Once daily': l.onceDaily,
      'Twice daily': l.twiceDaily,
      'Three times daily': l.threeTimes,
      'Four times daily': l.fourTimes,
      'As needed': l.asNeeded,
      'Weekly': l.weekly,
      'Monthly': l.monthly,

      // Menstrual flow
      'Spotting': l.spotting,
      'Light': l.light,
      'Medium': l.medium,
      'Heavy': l.heavy,

      // Language
      'Language': l.language,
      'Select Language': l.selectLanguage,
      'English': l.english,
      'Français': l.french,
      'Kinyarwanda': l.kinyarwanda,

      // Login
      'Welcome Back': l.welcomeBack,
      'Sign in to continue your health journey': l.signInToContinue,
      'Email': l.email,
      'Email Address': l.emailAddress,
      'Enter your email': l.enterEmail,
      'Please enter your email': l.pleaseEnterEmail,
      'Please enter a valid email': l.pleaseEnterValidEmail,
      'Password': l.password,
      'Enter your password': l.enterPassword,
      'Please enter your password': l.pleaseEnterPassword,
      'Password must be at least 6 characters': l.passwordTooShort,
      'Remember me': l.rememberMe,
      'Sign In': l.signIn,
      'Forgot Password?': l.forgotPassword,
      'OR': l.or,
      'Don\'t have an account?': l.dontHaveAccount,
      'Create Account': l.createAccount,
      'Terms of Service': l.termsOfService,
      'Privacy Policy': l.privacyPolicy,
      'By signing in, you agree to our': l.bySigningIn,
      ' and ': l.and,

      // Greetings
      'Good morning': l.goodMorning,
      'Good afternoon': l.goodAfternoon,
      'Good evening': l.goodEvening,

      // Roles
      'Administrator': l.administrator,
      'Health Worker': l.healthWorker,
      'Client': l.client,

      // Success messages
      'Login successful!': l.loginSuccess,
      'Registration successful!': l.registrationSuccess,
      'Updated successfully!': l.updateSuccess,
      'Deleted successfully!': l.deleteSuccess,

      // Common appointment-related strings
      'Book new appointment': l.bookNewAppointment,
      'Appointment booked': l.appointmentBooked,
      'Appointment cancelled': l.appointmentCancelled,
      'Appointment confirmed': l.appointmentConfirmed,
      'Appointment rescheduled': l.appointmentRescheduled,
      'No appointments': l.noAppointments,
      'No appointments found': l.noAppointmentsFound,
      'Appointment details': l.appointmentDetails,
      'Appointment type': l.appointmentType,
      'Appointment date': l.appointmentDate,
      'Appointment time': l.appointmentTime,
      'Appointment location': l.appointmentLocation,
      'Appointment notes': l.appointmentNotes,
      'Appointment status': l.appointmentStatus,
      'Reschedule appointment': l.rescheduleAppointment,
      'Cancel appointment': l.cancelAppointment,
      'Confirm appointment': l.confirmAppointment,
      'Edit appointment': l.editAppointment,
      'Delete appointment': l.deleteAppointment,
      'View appointment': l.viewAppointment,

      // Status
      'Scheduled': l.scheduled,
      'Confirmed': l.confirmed,
      'Completed': l.completed,
      'Cancelled': l.cancelled,
      'Rescheduled': l.rescheduled,
      'Pending': l.pending,
      'Approved': l.approved,
      'Rejected': l.rejected,
      'In Progress': l.inProgress,
      'On Hold': l.onHold,
      'Delayed': l.delayed,
      'Urgent': l.urgent,
      'Normal': l.normal,
      'Low': l.low,
      'High': l.high,
      'Critical': l.critical,
      'Routine': l.routine,

      // Medical terms
      'Diagnosis': l.diagnosis,
      'Treatment': l.treatment,
      'Therapy': l.therapy,
      'Surgery': l.surgery,
      'Procedure': l.procedure,
      'Test': l.test,
      'Examination': l.examination,
      'Visit': l.visit,
      'Session': l.session,
      'Assessment': l.assessment,
      'Evaluation': l.evaluation,
      'Review': l.review,
      'Analysis': l.analysis,
      'Report': l.report,
      'Summary': l.summary,
      'Overview': l.overview,
      'History': l.history,
      'Record': l.record,
      'File': l.file,
      'Document': l.document,
      'Form': l.form,
      'Application': l.application,
      'Request': l.request,
      'Order': l.order,
      'Prescription': l.prescription,
      'Medication': l.medication,
      'Medicine': l.medicine,
      'Drug': l.drug,
      'Pill': l.pill,
      'Tablet': l.tablet,
      'Capsule': l.capsule,
      'Injection': l.injection,
      'Vaccine': l.vaccine,
      'Shot': l.shot,
      'Dose': l.dose,
      'Dosage': l.dosage,
      'Frequency': l.frequency,
      'Schedule': l.schedule,
      'Duration': l.duration,
      'Period': l.period,
      'Interval': l.interval,
      'Cycle': l.cycle,
      'Phase': l.phase,
      'Stage': l.stage,
      'Step': l.step,
      'Level': l.level,
      'Grade': l.grade,
      'Degree': l.degree,
      'Severity': l.severity,
      'Intensity': l.intensity,
      'Strength': l.strength,
      'Health': l.health,
      'Wellness': l.wellness,
      'Condition': l.condition,
      'State': l.state,
      'Status': l.status,
      'Situation': l.situation,
      'Position': l.position,
      'Location': l.location,
      'Place': l.place,
      'Area': l.area,
      'Region': l.region,
      'Zone': l.zone,
      'Center': l.center,
      'Clinic': l.clinic,
      'Hospital': l.hospital,
      'Pharmacy': l.pharmacy,
      'Laboratory': l.laboratory,
      'Office': l.office,
      'Room': l.room,
      'Department': l.department,
      'Unit': l.unit,
      'Division': l.division,
      'Section': l.section,
      'Service': l.service,
      'Program': l.program,
      'Project': l.project,
      'Plan': l.plan,
      'Method': l.method,
      'Technique': l.technique,
      'Approach': l.approach,
      'System': l.system,
      'Network': l.network,
      'Platform': l.platform,
    };

    return translations[originalText] ?? originalText;
    */
  }
}

/// Extension to make any string translatable
extension StringTranslation on String {
  /// Convert this string to a TranslatedText widget
  Widget tr({
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return TranslatedText(
      this,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
