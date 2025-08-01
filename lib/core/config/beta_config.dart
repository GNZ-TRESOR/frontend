import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Beta testing configuration and utilities
class BetaConfig {
  /// Beta version information
  static const String betaVersion = '1.0.0-beta.1';
  static const String betaBuildNumber = '1001';
  static final DateTime betaStartDate = DateTime(2024, 1, 15);
  static final DateTime betaEndDate = DateTime(2024, 3, 15);

  /// Beta testing features
  static const bool enableBetaFeatures = true;
  static const bool enableFeedbackCollection = true;
  static const bool enableUsageAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDebugOverlay = false; // Only for internal testing

  /// Test user accounts for different roles
  static const Map<String, Map<String, String>> testUsers = {
    'admin': {
      'email': 'admin@ubuzima.test',
      'password': 'Admin123!',
      'role': 'ADMIN',
      'name': 'Test Administrator',
    },
    'health_worker': {
      'email': 'healthworker@ubuzima.test',
      'password': 'Health123!',
      'role': 'HEALTH_WORKER',
      'name': 'Test Health Worker',
    },
    'client': {
      'email': 'client@ubuzima.test',
      'password': 'Client123!',
      'role': 'CLIENT',
      'name': 'Test Client User',
    },
  };

  /// Beta testing limits
  static const int maxBetaUsers = 100;
  static const int maxFeedbackSubmissions = 10; // Per user per day
  static const Duration sessionTimeout = Duration(hours: 8);

  /// Feature availability during beta
  static const Map<String, bool> betaFeatureFlags = {
    'healthRecords': true,
    'appointments': true,
    'menstrualCycle': true,
    'medications': true,
    'pregnancyPlanning': true,
    'contraception': true,
    'education': true,
    'supportGroups': true,
    'messaging': true,
    'stiTesting': true,
    'healthFacilities': true,
    'partners': true,
    'communityEvents': true,
    'notifications': true,
    'settings': true,
    'feedback': true,

    // Future features (disabled for beta)
    'voiceInterface': false,
    'aiAssistant': false,
    'videoConsultation': false,
    'advancedAnalytics': false,
  };

  /// Check if beta period is active
  static bool get isBetaActive {
    final now = DateTime.now();
    return now.isAfter(betaStartDate) && now.isBefore(betaEndDate);
  }

  /// Check if beta features are enabled
  static bool get areBetaFeaturesEnabled {
    return enableBetaFeatures &&
        isBetaActive &&
        !EnvironmentConfig.isProduction;
  }

  /// Check if a specific feature is available in beta
  static bool isFeatureAvailable(String featureName) {
    return betaFeatureFlags[featureName] ?? false;
  }

  /// Get beta user credentials for testing
  static Map<String, String>? getBetaUserCredentials(String role) {
    return testUsers[role.toLowerCase()];
  }

  /// Get all available test user roles
  static List<String> get availableTestRoles {
    return testUsers.keys.toList();
  }

  /// Beta testing guidelines
  static const List<String> betaTestingGuidelines = [
    'Test all core features thoroughly',
    'Report any bugs or issues immediately',
    'Provide feedback on user experience',
    'Test with different user roles',
    'Verify data persistence and sync',
    'Test offline functionality',
    'Check notification delivery',
    'Validate security features',
    'Test on different devices and screen sizes',
    'Verify performance under load',
  ];

  /// Known limitations in beta
  static const List<String> betaLimitations = [
    'Voice interface is not available',
    'AI assistant features are disabled',
    'Video consultation is not implemented',
    'Advanced analytics are limited',
    'Some animations may be placeholder',
    'Performance optimizations are ongoing',
    'Data migration tools are not final',
    'Third-party integrations are limited',
  ];

  /// Beta feedback categories
  static const List<Map<String, String>> feedbackCategories = [
    {
      'id': 'bug',
      'name': 'Bug Report',
      'description': 'Report technical issues',
    },
    {'id': 'ui', 'name': 'UI/UX', 'description': 'User interface feedback'},
    {
      'id': 'feature',
      'name': 'Feature Request',
      'description': 'Suggest new features',
    },
    {
      'id': 'performance',
      'name': 'Performance',
      'description': 'Speed and responsiveness',
    },
    {
      'id': 'usability',
      'name': 'Usability',
      'description': 'Ease of use feedback',
    },
    {
      'id': 'content',
      'name': 'Content',
      'description': 'Educational content feedback',
    },
    {
      'id': 'accessibility',
      'name': 'Accessibility',
      'description': 'Accessibility improvements',
    },
    {'id': 'other', 'name': 'Other', 'description': 'General feedback'},
  ];

  /// Get beta status message
  static String get betaStatusMessage {
    if (!isBetaActive) {
      if (DateTime.now().isBefore(betaStartDate)) {
        return 'Beta testing has not started yet';
      } else {
        return 'Beta testing period has ended';
      }
    }

    final daysRemaining = betaEndDate.difference(DateTime.now()).inDays;
    return 'Beta testing active - $daysRemaining days remaining';
  }

  /// Get beta progress percentage
  static double get betaProgress {
    if (!isBetaActive) return 0.0;

    final totalDays = betaEndDate.difference(betaStartDate).inDays;
    final elapsedDays = DateTime.now().difference(betaStartDate).inDays;

    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  /// Beta testing metrics
  static Map<String, dynamic> getBetaMetrics() {
    return {
      'version': betaVersion,
      'buildNumber': betaBuildNumber,
      'isActive': isBetaActive,
      'progress': betaProgress,
      'daysRemaining':
          isBetaActive ? betaEndDate.difference(DateTime.now()).inDays : 0,
      'featuresEnabled': betaFeatureFlags.values.where((v) => v).length,
      'totalFeatures': betaFeatureFlags.length,
      'testUsersAvailable': testUsers.length,
    };
  }

  /// Initialize beta configuration
  static Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('🧪 Initializing Beta Configuration');
      debugPrint('📱 Beta Version: $betaVersion');
      debugPrint('🏗️ Build Number: $betaBuildNumber');
      debugPrint(
        '📅 Beta Period: ${betaStartDate.toString().split(' ')[0]} - ${betaEndDate.toString().split(' ')[0]}',
      );
      debugPrint('✅ Beta Active: $isBetaActive');
      debugPrint(
        '🎯 Features Available: ${betaFeatureFlags.values.where((v) => v).length}/${betaFeatureFlags.length}',
      );
      debugPrint('👥 Test Users: ${testUsers.length} roles available');
    }
  }

  /// Validate beta configuration
  static bool validateBetaConfig() {
    try {
      // Check version format
      if (!RegExp(r'^\d+\.\d+\.\d+-beta\.\d+$').hasMatch(betaVersion)) {
        debugPrint('❌ Invalid beta version format');
        return false;
      }

      // Check date validity
      if (betaStartDate.isAfter(betaEndDate)) {
        debugPrint('❌ Invalid beta date range');
        return false;
      }

      // Check test users
      if (testUsers.isEmpty) {
        debugPrint('❌ No test users configured');
        return false;
      }

      // Validate test user data
      for (final user in testUsers.values) {
        final email = user['email'];
        final password = user['password'];
        final role = user['role'];

        if (email == null ||
            email.isEmpty ||
            password == null ||
            password.isEmpty ||
            role == null ||
            role.isEmpty) {
          debugPrint('❌ Invalid test user configuration');
          return false;
        }
      }

      debugPrint('✅ Beta configuration is valid');
      return true;
    } catch (e) {
      debugPrint('❌ Beta configuration validation failed: $e');
      return false;
    }
  }

  /// Get beta welcome message
  static String get welcomeMessage {
    return '''
Welcome to Ubuzima Beta Testing!

You are using version $betaVersion of the Ubuzima family planning app. 

This is a beta version designed for testing purposes. Please help us improve by:
• Testing all available features
• Reporting any bugs or issues
• Providing feedback on user experience
• Suggesting improvements

Your feedback is valuable in making Ubuzima the best family planning app for Rwanda.

Thank you for participating in our beta program!
''';
  }

  /// Check if user can submit more feedback today
  static bool canSubmitFeedback(int submissionsToday) {
    return submissionsToday < maxFeedbackSubmissions;
  }

  /// Get remaining feedback submissions for today
  static int getRemainingFeedbackSubmissions(int submissionsToday) {
    return (maxFeedbackSubmissions - submissionsToday).clamp(
      0,
      maxFeedbackSubmissions,
    );
  }
}
