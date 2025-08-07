/// Application constants for Ubuzima Family Planning Platform
class AppConstants {
  // App Information
  static const String appName = 'Ubuzima';
  static const String appTagline = 'Empowering Your Health Journey';
  static const String appDescription =
      'Your comprehensive companion for family planning, reproductive health, and wellness - designed with care for the modern woman';

  // API Configuration
  static const String baseUrl = 'http://192.168.1.70:8080/api/v1';
  static const String apiVersion = 'v1';
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'selected_theme';
  static const String onboardingKey = 'onboarding_completed';

  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Health Tracking Constants
  static const int defaultCycleLength = 28;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 35;
  static const int defaultPeriodLength = 5;
  static const int minPeriodLength = 2;
  static const int maxPeriodLength = 10;

  // Notification Constants
  static const String medicationChannelId = 'medication_reminders';
  static const String appointmentChannelId = 'appointment_reminders';
  static const String cycleChannelId = 'cycle_reminders';

  // File Upload Constants
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Pagination Constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Error Messages
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError =
      'An unexpected error occurred. Please try again.';
  static const String validationError =
      'Please check your input and try again.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String updateSuccess = 'Updated successfully!';
  static const String deleteSuccess = 'Deleted successfully!';

  // User Roles
  static const String adminRole = 'ADMIN';
  static const String healthWorkerRole = 'HEALTH_WORKER';
  static const String clientRole = 'CLIENT';

  // Appointment Types (matching backend enum)
  static const List<String> appointmentTypes = [
    'CONSULTATION',
    'FAMILY_PLANNING',
    'PRENATAL_CARE',
    'POSTNATAL_CARE',
    'VACCINATION',
    'HEALTH_SCREENING',
    'FOLLOW_UP',
    'EMERGENCY',
    'COUNSELING',
    'OTHER',
  ];

  // Medication Frequencies
  static const List<String> medicationFrequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
    'Weekly',
    'Monthly',
  ];

  // Menstrual Flow Types
  static const List<String> flowTypes = [
    'Spotting',
    'Light',
    'Medium',
    'Heavy',
  ];

  // Common Symptoms
  static const List<String> commonSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Mood swings',
    'Fatigue',
    'Back pain',
    'Breast tenderness',
    'Nausea',
    'Acne',
    'Food cravings',
  ];

  // Mood Options
  static const List<String> moodOptions = [
    'Happy',
    'Sad',
    'Anxious',
    'Irritable',
    'Calm',
    'Energetic',
    'Tired',
    'Stressed',
  ];

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'rw', 'name': 'Kinyarwanda'},
    {'code': 'fr', 'name': 'Français'},
  ];

  // Regular Expressions
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // URLs
  static const String privacyPolicyUrl = 'https://ubuzima.com/privacy';
  static const String termsOfServiceUrl = 'https://ubuzima.com/terms';
  static const String supportUrl = 'https://ubuzima.com/support';
  static const String aboutUrl = 'https://ubuzima.com/about';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/ubuzima';
  static const String twitterUrl = 'https://twitter.com/ubuzima';
  static const String instagramUrl = 'https://instagram.com/ubuzima';

  // Contact Information
  static const String supportEmail = 'support@ubuzima.com';
  static const String supportPhone = '+250 788 123 456';
  static const String emergencyNumber = '114';

  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // Development Settings
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableMockData = false;

  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheEntries = 1000;

  // Security Settings
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);

  // Utility Methods
  static bool isValidEmail(String email) {
    return RegExp(emailRegex).hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(phoneRegex).hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return RegExp(passwordRegex).hasMatch(password);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case adminRole:
        return 'Administrator';
      case healthWorkerRole:
        return 'Health Worker';
      case clientRole:
        return 'Client';
      default:
        return role;
    }
  }
}
