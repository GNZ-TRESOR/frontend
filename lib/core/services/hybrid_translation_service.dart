import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'libre_translate_service.dart';

/// Hybrid translation service that combines LibreTranslate API with local .arb files
/// Uses LibreTranslate for supported languages and falls back to .arb files for others (like Kinyarwanda)
class HybridTranslationService {
  static const List<String> _libreTranslateSupportedLanguages = [
    'en',
    'ar',
    'az',
    'zh',
    'cs',
    'nl',
    'eo',
    'fi',
    'fr',
    'de',
    'el',
    'he',
    'hi',
    'hu',
    'id',
    'ga',
    'it',
    'ja',
    'ko',
    'fa',
    'pl',
    'pt',
    'ru',
    'sk',
    'es',
    'sv',
    'tr',
    'uk',
  ];

  static const List<String> _localSupportedLanguages = [
    'rw', // Kinyarwanda - supported via .arb files
  ];

  static HybridTranslationService? _instance;
  static HybridTranslationService get instance =>
      _instance ??= HybridTranslationService._();

  final LibreTranslateService _libreTranslateService =
      LibreTranslateService.instance;

  HybridTranslationService._();

  /// Check if a language is supported by LibreTranslate API
  bool isLibreTranslateSupported(String languageCode) {
    return _libreTranslateSupportedLanguages.contains(languageCode);
  }

  /// Check if a language is supported locally via .arb files
  bool isLocallySupported(String languageCode) {
    return _localSupportedLanguages.contains(languageCode);
  }

  /// Check if a language is supported by either method
  bool isLanguageSupported(String languageCode) {
    return isLibreTranslateSupported(languageCode) ||
        isLocallySupported(languageCode);
  }

  /// Translate text using the appropriate method based on target language
  Future<String> translateText(
    String text,
    String targetLang,
    BuildContext? context, {
    String sourceLang = 'en',
  }) async {
    // Return original text if target is same as source
    if (targetLang == sourceLang) {
      return text;
    }

    // Use LibreTranslate for supported languages
    if (isLibreTranslateSupported(targetLang)) {
      try {
        return await _libreTranslateService.translateText(
          text,
          targetLang,
          sourceLang: sourceLang,
        );
      } catch (e) {
        debugPrint('LibreTranslate API failed: $e');
        // For now, return a simple mock translation to test the system
        final mockResult = _getMockTranslation(text, targetLang);
        debugPrint(
          'Using mock translation: "$text" -> "$mockResult" (lang: $targetLang)',
        );
        return mockResult;
      }
    }

    // Use local .arb files for Kinyarwanda and other locally supported languages
    if (isLocallySupported(targetLang) && context != null) {
      return _getLocalTranslation(text, targetLang, context);
    }

    // Return original text if language not supported
    return text;
  }

  /// Public method to get mock translation (synchronous)
  String getMockTranslation(String text, String targetLang) {
    return _getMockTranslation(text, targetLang);
  }

  /// Mock translations for testing when API fails
  String _getMockTranslation(String text, String targetLang) {
    switch (targetLang) {
      case 'fr':
        return _getFrenchTranslation(text);
      case 'es':
        return _getSpanishTranslation(text);
      case 'de':
        return _getGermanTranslation(text);
      default:
        return text;
    }
  }

  /// French translations
  String _getFrenchTranslation(String text) {
    const mockTranslations = {
      // Navigation and UI
      'Home': 'Accueil',
      'Health': 'Santé',
      'Education': 'Éducation',
      'Community': 'Communauté',
      'Profile': 'Profil',
      'Settings': 'Paramètres',
      'Back': 'Retour',
      'Next': 'Suivant',
      'Cancel': 'Annuler',
      'Save': 'Enregistrer',
      'Delete': 'Supprimer',
      'Edit': 'Modifier',
      'Add': 'Ajouter',
      'Update': 'Mettre à jour',
      'Submit': 'Soumettre',
      'Confirm': 'Confirmer',
      'Close': 'Fermer',
      'Done': 'Terminé',
      'Loading...': 'Chargement...',
      'Success': 'Succès',
      'Error': 'Erreur',
      'Warning': 'Avertissement',
      'Information': 'Information',

      // Health-specific terms
      'Appointments': 'Rendez-vous',
      'My Appointments': 'Mes rendez-vous',
      'Appointment Management': 'Gestion des rendez-vous',
      'Book Appointment': 'Prendre rendez-vous',
      'Schedule Appointment': 'Planifier un rendez-vous',
      'Health Records': 'Dossiers de santé',
      'Medical History': 'Antécédents médicaux',
      'Medications': 'Médicaments',
      'My Medications': 'Mes médicaments',
      'Add Medication': 'Ajouter un médicament',
      'Track Cycle': 'Suivre le cycle',
      'Menstrual Cycle': 'Cycle menstruel',
      'Period Tracking': 'Suivi des règles',

      // Dashboard content
      'Welcome back,': 'Bon retour,',
      'Let\'s track your health journey': 'Suivons votre parcours de santé',
      'See a doctor': 'Voir un médecin',
      'Log your period': 'Enregistrer vos règles',
      'View your data': 'Voir vos données',
      'Education hub': 'Centre éducatif',
      'Nearby facilities': 'Installations à proximité',
      'Learn': 'Apprendre',
      'Find Clinics': 'Trouver des cliniques',

      // Time and status
      'Today': 'Aujourd\'hui',
      'Tomorrow': 'Demain',
      'Yesterday': 'Hier',
      'Upcoming': 'À venir',
      'Past': 'Passé',
      'All': 'Tout',
      'Active': 'Actif',
      'Inactive': 'Inactif',
      'Pending': 'En attente',
      'Completed': 'Terminé',
      'Cancelled': 'Annulé',
      'Confirmed': 'Confirmé',
      'Scheduled': 'Planifié',

      // Medical terms
      'Dosage': 'Dosage',
      'Frequency': 'Fréquence',
      'Instructions': 'Instructions',
      'Side Effects': 'Effets secondaires',
      'Start Date': 'Date de début',
      'End Date': 'Date de fin',
      'Symptoms': 'Symptômes',
      'Temperature': 'Température',
      'Weight': 'Poids',
      'Blood Pressure': 'Tension artérielle',
      'Heart Rate': 'Fréquence cardiaque',

      // Appointment types
      'General Consultation': 'Consultation générale',
      'Follow-up Visit': 'Visite de suivi',
      'Health Screening': 'Dépistage de santé',
      'Family Planning': 'Planification familiale',
      'Prenatal Care': 'Soins prénataux',
      'Postnatal Care': 'Soins postnataux',
      'Vaccination': 'Vaccination',
      'Emergency': 'Urgence',
      'Counseling': 'Conseil',
      'Health Counseling': 'Conseil en santé',

      // Form fields
      'Name': 'Nom',
      'Email': 'E-mail',
      'Phone': 'Téléphone',
      'Address': 'Adresse',
      'Date of Birth': 'Date de naissance',
      'Gender': 'Genre',
      'Age': 'Âge',
      'Height': 'Taille',
      'Blood Type': 'Groupe sanguin',
      'Emergency Contact': 'Contact d\'urgence',
      'Insurance': 'Assurance',
      'Allergies': 'Allergies',
      'Medical Conditions': 'Conditions médicales',
      'Current Medications': 'Médicaments actuels',

      // Actions
      'View Details': 'Voir les détails',
      'View All': 'Voir tout',
      'See More': 'Voir plus',
      'Show Less': 'Voir moins',
      'Read More': 'Lire plus',
      'Learn More': 'En savoir plus',
      'Get Started': 'Commencer',
      'Continue': 'Continuer',
      'Finish': 'Terminer',
      'Skip': 'Ignorer',
      'Retry': 'Réessayer',
      'Refresh': 'Actualiser',
      'Search': 'Rechercher',
      'Filter': 'Filtrer',
      'Sort': 'Trier',
      'Share': 'Partager',

      // Messages
      'No data available': 'Aucune donnée disponible',
      'No results found': 'Aucun résultat trouvé',
      'No appointments scheduled': 'Aucun rendez-vous planifié',
      'No medications added': 'Aucun médicament ajouté',
      'Data saved successfully': 'Données enregistrées avec succès',
      'Changes saved': 'Modifications enregistrées',
      'Please try again': 'Veuillez réessayer',
      'Something went wrong': 'Quelque chose s\'est mal passé',
      'Connection error': 'Erreur de connexion',

      // Health education
      'Health Tips': 'Conseils de santé',
      'Educational Content': 'Contenu éducatif',
      'Health Articles': 'Articles de santé',
      'Wellness Guide': 'Guide de bien-être',
      'Prevention Tips': 'Conseils de prévention',
      'Healthy Living': 'Vie saine',
      'Nutrition': 'Nutrition',
      'Exercise': 'Exercice',
      'Mental Health': 'Santé mentale',
      'Sleep': 'Sommeil',
      'Stress Management': 'Gestion du stress',

      // Settings
      'Language': 'Langue',
      'Theme': 'Thème',
      'Notifications': 'Notifications',
      'Privacy': 'Confidentialité',
      'Security': 'Sécurité',
      'Account': 'Compte',
      'About': 'À propos',
      'Help': 'Aide',
      'Support': 'Support',
      'Contact Us': 'Nous contacter',
      'Logout': 'Déconnexion',
      'Sign Out': 'Se déconnecter',

      // Tabs and sections
      'Calendar': 'Calendrier',
      'Cycles': 'Cycles',
      'Insights': 'Aperçus',
      'Reminders': 'Rappels',
      'Overview': 'Aperçu',
      'Performance': 'Performance',
      'Activities': 'Activités',
      'Nearby': 'À proximité',
      'All Facilities': 'Toutes les installations',
      'Map View': 'Vue carte',
      'List': 'Liste',
      'Map': 'Carte',
      'Manage Slots': 'Gérer les créneaux',

      // Medication specific (new entries only)
      'Medication Name *': 'Nom du médicament *',
      'Please enter medication name': 'Veuillez saisir le nom du médicament',
      'Additional Information': 'Informations supplémentaires',

      'Take with food': 'Prendre avec de la nourriture',
      'Take on empty stomach': 'Prendre à jeun',
      'Once daily': 'Une fois par jour',
      'Twice daily': 'Deux fois par jour',
      'Three times daily': 'Trois fois par jour',
      'As needed': 'Au besoin',

      // Education specific
      'Health Education': 'Éducation sanitaire',
      'Featured': 'En vedette',
      'Categories': 'Catégories',
      'My Learning': 'Mon apprentissage',

      // Health facilities
      'Search facilities, services...':
          'Rechercher des installations, services...',
      'Hospital': 'Hôpital',
      'Clinic': 'Clinique',
      'Health Center': 'Centre de santé',
      'Pharmacy': 'Pharmacie',

      // Appointment booking
      'Appointment Details': 'Détails du rendez-vous',
      'Date & Time': 'Date et heure',
      'Location': 'Lieu',
      'Additional Notes': 'Notes supplémentaires',
      'Book': 'Réserver',

      'Other': 'Autre',

      // Form fields
      'First Name': 'Prénom',
      'Last Name': 'Nom de famille',
      'Enter first name': 'Saisir le prénom',
      'Enter last name': 'Saisir le nom de famille',
      'Required': 'Obligatoire',
      'Email Address': 'Adresse e-mail',
      'Enter Email': 'Saisir l\'e-mail',
      'Please enter email': 'Veuillez saisir l\'e-mail',
      'Please enter valid email': 'Veuillez saisir un e-mail valide',
      'Password': 'Mot de passe',
      'Enter password': 'Saisir le mot de passe',
      'Confirm Password': 'Confirmer le mot de passe',
      'Please enter password': 'Veuillez saisir le mot de passe',
      'Password must be at least 8 characters':
          'Le mot de passe doit contenir au moins 8 caractères',
      'Passwords do not match': 'Les mots de passe ne correspondent pas',

      // Test content
      'Translation Test': 'Test de traduction',
      'Hello World': 'Bonjour le monde',
    };

    return mockTranslations[text] ?? text;
  }

  /// Spanish translations
  String _getSpanishTranslation(String text) {
    const mockTranslations = {
      'Home': 'Inicio',
      'Health': 'Salud',
      'Education': 'Educación',
      'Community': 'Comunidad',
      'Profile': 'Perfil',
      'Appointments': 'Citas',
      'My Appointments': 'Mis citas',
      'Book Appointment': 'Reservar cita',
      'Health Records': 'Registros de salud',
      'Medications': 'Medicamentos',
      'Welcome back,': 'Bienvenido de vuelta,',
      'Let\'s track your health journey': 'Sigamos tu viaje de salud',
      'Track Cycle': 'Seguir ciclo',
      'See a doctor': 'Ver un médico',
      'Today': 'Hoy',
      'Upcoming': 'Próximo',
      'Past': 'Pasado',
      'All': 'Todo',
      'Active': 'Activo',
      'Settings': 'Configuración',
      'Language': 'Idioma',
    };
    return mockTranslations[text] ?? text;
  }

  /// German translations
  String _getGermanTranslation(String text) {
    const mockTranslations = {
      'Home': 'Startseite',
      'Health': 'Gesundheit',
      'Education': 'Bildung',
      'Community': 'Gemeinschaft',
      'Profile': 'Profil',
      'Appointments': 'Termine',
      'My Appointments': 'Meine Termine',
      'Book Appointment': 'Termin buchen',
      'Health Records': 'Gesundheitsakten',
      'Medications': 'Medikamente',
      'Welcome back,': 'Willkommen zurück,',
      'Let\'s track your health journey':
          'Lass uns deine Gesundheitsreise verfolgen',
      'Track Cycle': 'Zyklus verfolgen',
      'See a doctor': 'Einen Arzt aufsuchen',
      'Today': 'Heute',
      'Upcoming': 'Bevorstehend',
      'Past': 'Vergangen',
      'All': 'Alle',
      'Active': 'Aktiv',
      'Settings': 'Einstellungen',
      'Language': 'Sprache',
    };
    return mockTranslations[text] ?? text;
  }

  /// Get translation from local .arb files
  String _getLocalTranslation(
    String text,
    String targetLang,
    BuildContext context,
  ) {
    // final localizations = AppLocalizations.of(context);
    // if (localizations == null) return text;

    // Temporarily return original text until localization is properly set up
    return text;

    // Map common English strings to their localization keys
    // final translationMap = _getTranslationMap(localizations);

    // return translationMap[text] ?? text;
  }

  /// Get all supported languages
  Future<List<Map<String, String>>> getAllSupportedLanguages() async {
    return [
      {'code': 'en', 'name': 'English'},
      {'code': 'rw', 'name': 'Kinyarwanda'},
      {'code': 'fr', 'name': 'French'},
    ];
  }

  /// Get translation mapping for local .arb files
  /*
  Map<String, String> _getTranslationMap(AppLocalizations l) {
    return {
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
    };
  }

  /// Get all supported languages (LibreTranslate + Local)
  Future<List<Map<String, String>>> getAllSupportedLanguages() async {
    final libreLanguages = await _libreTranslateService.getAvailableLanguages();

    // Add locally supported languages
    final localLanguages = [
      {'code': 'rw', 'name': 'Kinyarwanda'},
    ];

    // Combine and deduplicate
    final allLanguages = <String, Map<String, String>>{};

    for (final lang in libreLanguages) {
      allLanguages[lang['code']!] = lang;
    }

    for (final lang in localLanguages) {
      allLanguages[lang['code']!] = lang;
    }

    return allLanguages.values.toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  /// Get translation method info for a language
  Map<String, dynamic> getLanguageInfo(String languageCode) {
    return {
      'code': languageCode,
      'isLibreTranslateSupported': isLibreTranslateSupported(languageCode),
      'isLocallySupported': isLocallySupported(languageCode),
      'translationMethod':
          isLibreTranslateSupported(languageCode)
              ? 'LibreTranslate API'
              : isLocallySupported(languageCode)
              ? 'Local .arb files'
              : 'Not supported',
    };
  }
  */
}
