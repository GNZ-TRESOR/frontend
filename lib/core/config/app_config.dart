import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Application configuration for Ubuzima Family Planning Platform
class AppConfig {
  static bool _isInitialized = false;

  // API Configuration - Environment-based
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  static int get connectTimeout => EnvironmentConfig.apiTimeout.inMilliseconds;
  static int get receiveTimeout => EnvironmentConfig.apiTimeout.inMilliseconds;
  static int get sendTimeout => EnvironmentConfig.apiTimeout.inMilliseconds;

  // Alternative backend URLs for different environments
  static const String localUrl =
      'http://192.168.1.70:8080/api/v1'; // Use machine IP for reliable connectivity
  static const String developmentUrl =
      'http://192.168.1.100:8080/api/v1'; // Update with your dev server IP
  static const String productionUrl =
      'https://your-domain.com/api/v1'; // Update with your production URL

  // App Information
  static const String appName = 'Ubuzima';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription =
      'Family Planning & Reproductive Health Platform';

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCrashReporting = false;
  static const bool enableAnalytics = false;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;

  // Database Configuration (for offline storage)
  static const String databaseName = 'ubuzima_local.db';
  static const int databaseVersion = 1;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // Security Configuration
  static const String encryptionKey = 'ubuzima_family_planning_2024';
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Health Tracking Configuration
  static const int defaultCycleLength = 28; // days
  static const int minCycleLength = 21; // days
  static const int maxCycleLength = 35; // days
  static const int defaultPeriodLength = 5; // days

  // Notification Configuration
  static const Duration medicationReminderInterval = Duration(hours: 8);
  static const Duration appointmentReminderAdvance = Duration(hours: 24);
  static const Duration cycleReminderAdvance = Duration(days: 2);

  /// Initialize the application configuration
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔧 Initializing Ubuzima App Configuration...');

      // Initialize any async configuration here
      await _loadEnvironmentConfig();
      await _validateConfiguration();

      _isInitialized = true;
      debugPrint('✅ Ubuzima App Configuration initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize app configuration: $e');
      rethrow;
    }
  }

  /// Load environment-specific configuration
  static Future<void> _loadEnvironmentConfig() async {
    // Load configuration based on build mode
    if (kDebugMode) {
      debugPrint('🔧 Loading development configuration');
      debugPrint('🔧 Setting base URL to: $localUrl');
      EnvironmentConfig.setBaseUrl(localUrl);
    } else if (kProfileMode) {
      debugPrint('🔧 Loading profile configuration');
      EnvironmentConfig.setBaseUrl(developmentUrl);
    } else {
      debugPrint('🔧 Loading production configuration');
      EnvironmentConfig.setBaseUrl(productionUrl);
    }
  }

  /// Validate configuration values
  static Future<void> _validateConfiguration() async {
    if (baseUrl.isEmpty) {
      throw Exception('Base URL cannot be empty');
    }

    if (appName.isEmpty) {
      throw Exception('App name cannot be empty');
    }

    if (connectTimeout <= 0 || receiveTimeout <= 0 || sendTimeout <= 0) {
      throw Exception('Timeout values must be positive');
    }

    debugPrint('✅ Configuration validation passed');
  }

  /// Get the appropriate base URL based on environment
  static String getBaseUrl() {
    if (kDebugMode) {
      return localUrl;
    } else if (kProfileMode) {
      return developmentUrl;
    } else {
      return productionUrl;
    }
  }

  /// Check if the app is initialized
  static bool get isInitialized => _isInitialized;

  /// Get app information as a map
  static Map<String, dynamic> getAppInfo() {
    return {
      'name': appName,
      'version': appVersion,
      'buildNumber': appBuildNumber,
      'description': appDescription,
      'baseUrl': getBaseUrl(),
    };
  }

  /// Get feature flags as a map
  static Map<String, bool> getFeatureFlags() {
    return {
      'logging': enableLogging,
      'crashReporting': enableCrashReporting,
      'analytics': enableAnalytics,
      'offlineMode': enableOfflineMode,
      'pushNotifications': enablePushNotifications,
    };
  }

  /// Get timeout configuration
  static Map<String, int> getTimeoutConfig() {
    return {
      'connect': connectTimeout,
      'receive': receiveTimeout,
      'send': sendTimeout,
    };
  }

  /// Get health tracking defaults
  static Map<String, int> getHealthTrackingDefaults() {
    return {
      'defaultCycleLength': defaultCycleLength,
      'minCycleLength': minCycleLength,
      'maxCycleLength': maxCycleLength,
      'defaultPeriodLength': defaultPeriodLength,
    };
  }

  /// Ensure configuration is initialized
  static void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.initialize() first.',
      );
    }
  }
}
