class AppConstants {
  // App Information
  static const String appName = 'Ubuzima';
  static const String appTagline = 'Ubuzima bw\'imyororokere';
  static const String appDescription = 'Family Planning & Reproductive Health';
  static const String appVersion = '1.0.0';

  // API Configuration
  // Use 10.0.2.2 for Android emulator to reach host machine
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  static const String apiVersion = 'v1';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Database Configuration
  static const String databaseName = 'ubuzima.db';
  static const int databaseVersion = 1;

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String languageKey = 'app_language';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String offlineModeKey = 'offline_mode';

  // User Roles (matching backend UserRole enum)
  static const String roleClient = 'CLIENT';
  static const String roleHealthWorker = 'HEALTH_WORKER';
  static const String roleWorker =
      'HEALTH_WORKER'; // Alias for roleHealthWorker
  static const String roleAdmin = 'ADMIN';
  static const String roleAnonymous = 'anonymous';

  // Languages
  static const String languageKinyarwanda = 'rw';
  static const String languageEnglish = 'en';
  static const String languageFrench = 'fr';

  // Audio Configuration
  static const Duration maxRecordingDuration = Duration(minutes: 5);
  static const String audioFormat = 'mp3';
  static const double defaultVolume = 0.8;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Sizes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Health Tracking
  static const int minCycleLength = 21;
  static const int maxCycleLength = 35;
  static const int defaultCycleLength = 28;

  // Notification IDs
  static const int reminderNotificationId = 1;
  static const int appointmentNotificationId = 2;
  static const int medicationNotificationId = 3;

  // Error Messages
  static const String networkErrorMessage =
      'Nta murongo wa interineti. Gerageza nyuma.';
  static const String serverErrorMessage =
      'Ikibazo cy\'ubutumwa. Gerageza nyuma.';
  static const String unknownErrorMessage = 'Ikibazo kitazwi. Gerageza nyuma.';

  // Success Messages
  static const String dataSavedMessage = 'Amakuru yarabitswe neza.';
  static const String profileUpdatedMessage = 'Umwirondoro wahinduwe neza.';
  static const String appointmentBookedMessage = 'Gahunda yarateguwe neza.';
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String education = '/education';
  static const String tracking = '/tracking';
  static const String messages = '/messages';
  static const String appointments = '/appointments';
  static const String clinics = '/clinics';
  static const String settings = '/settings';
  static const String help = '/help';
}

class AppAssets {
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  static const String onboarding4 = 'assets/images/onboarding_4.png';

  // Icons
  static const String voiceIcon = 'assets/icons/voice.svg';
  static const String healthIcon = 'assets/icons/health.svg';
  static const String educationIcon = 'assets/icons/education.svg';
  static const String trackingIcon = 'assets/icons/tracking.svg';

  // Lottie Animations
  static const String loadingAnimation = 'assets/lottie/loading.json';
  static const String successAnimation = 'assets/lottie/success.json';
  static const String errorAnimation = 'assets/lottie/error.json';
  static const String voiceAnimation = 'assets/lottie/voice.json';

  // Audio
  static const String welcomeAudio = 'assets/audio/welcome.mp3';
  static const String successSound = 'assets/audio/success.mp3';
  static const String errorSound = 'assets/audio/error.mp3';
}

class AppStrings {
  // Common
  static const String yes = 'Yego';
  static const String no = 'Oya';
  static const String ok = 'Sawa';
  static const String cancel = 'Kuraguza';
  static const String save = 'Bika';
  static const String delete = 'Siba';
  static const String edit = 'Hindura';
  static const String next = 'Komeza';
  static const String back = 'Subira';
  static const String done = 'Byarangiye';
  static const String loading = 'Gutegura...';
  static const String retry = 'Ongera ugerageze';

  // Authentication
  static const String login = 'Injira';
  static const String register = 'Iyandikishe';
  static const String logout = 'Sohoka';
  static const String forgotPassword = 'Wibagiwe ijambo ry\'ibanga?';
  static const String resetPassword = 'Subiza ijambo ry\'ibanga';

  // Navigation
  static const String home = 'Ahabanza';
  static const String education = 'Amasomo';
  static const String tracking = 'Gukurikirana';
  static const String messages = 'Ubutumwa';
  static const String profile = 'Umwirondoro';
  static const String settings = 'Igenamiterere';

  // Health
  static const String familyPlanning = 'Kubana n\'ubwiyunge';
  static const String reproductiveHealth = 'Ubuzima bw\'imyororokere';
  static const String menstrualCycle = 'Imihango';
  static const String contraception = 'Gukumira inda';
  static const String pregnancy = 'Inda';

  // Voice
  static const String voiceCommand = 'Koresha ijwi';
  static const String listening = 'Ndumva...';
  static const String speakNow = 'Vuga ubu';
  static const String voiceNotAvailable = 'Ijwi ntirihari';

  // Errors
  static const String errorOccurred = 'Ikibazo cyabaye';
  static const String networkError = 'Nta murongo wa interineti';
  static const String serverError = 'Ikibazo cy\'ubutumwa';
  static const String invalidInput = 'Amakuru atari yo';

  // Success
  static const String success = 'Byagenze neza';
  static const String saved = 'Byabitswe';
  static const String updated = 'Byahinduwe';
  static const String deleted = 'Byasibwe';
}

class AppValidation {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shyiramo imeyili';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Imeyili ntabwo ari yo';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shyiramo ijambo ry\'ibanga';
    }
    if (value.length < minPasswordLength) {
      return 'Ijambo ry\'ibanga rigomba kuba rifite byibuze inyuguti $minPasswordLength';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shyiramo nimero ya telefone';
    }
    if (value.length < minPhoneLength) {
      return 'Nimero ya telefone ntabwo ari yo';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shyiramo izina';
    }
    if (value.length < minNameLength) {
      return 'Izina rigomba kuba rifite byibuze inyuguti $minNameLength';
    }
    return null;
  }
}
