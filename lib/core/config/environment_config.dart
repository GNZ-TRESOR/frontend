import 'package:flutter/foundation.dart';
import '../utils/network_utils.dart';

/// Environment configuration for different build flavors
enum Environment { development, staging, production }

/// Environment configuration class
class EnvironmentConfig {
  static const Environment _currentEnvironment =
      kDebugMode ? Environment.development : Environment.production;

  static String? _overriddenBaseUrl;

  /// Override the API base URL (for development and testing)
  static void setBaseUrl(String url) {
    _overriddenBaseUrl = url;
    debugPrint('🔧 API base URL overridden to: $url');
  }

  /// Get current environment
  static Environment get currentEnvironment => _currentEnvironment;

  /// Check if running in development mode
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// Check if running in staging mode
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// Check if running in production mode
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Get API base URL based on environment
  static String get apiBaseUrl {
    if (_overriddenBaseUrl != null) {
      return _overriddenBaseUrl!;
    }

    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://10.0.2.2:8080/api/v1'; // Android emulator localhost mapping (WiFi-independent)
      case Environment.staging:
        return 'https://staging-api.ubuzima.com';
      case Environment.production:
        return 'https://api.ubuzima.com';
    }
  }

  /// Get dynamic API base URL with automatic IP detection (for development)
  static Future<String> getDynamicApiBaseUrl() async {
    if (_overriddenBaseUrl != null) {
      return _overriddenBaseUrl!;
    }

    switch (_currentEnvironment) {
      case Environment.development:
        // Use dynamic IP detection for development
        return await NetworkUtils.getDynamicApiUrl(
          port: 8080,
          path: '/api/v1',
          fallbackIP: '10.0.2.2', // Android emulator localhost mapping
        );
      case Environment.staging:
        return 'https://staging-api.ubuzima.com';
      case Environment.production:
        return 'https://api.ubuzima.com';
    }
  }

  /// Get WebSocket URL based on environment
  static String get websocketUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'ws://10.0.2.2:8080/ws'; // Android emulator host access
      case Environment.staging:
        return 'wss://staging-api.ubuzima.com/ws';
      case Environment.production:
        return 'wss://api.ubuzima.com/ws';
    }
  }

  /// Enable/disable debug features
  static bool get enableDebugFeatures => isDevelopment;

  /// Enable/disable logging
  static bool get enableLogging => isDevelopment || isStaging;

  /// Enable/disable crash reporting
  static bool get enableCrashReporting => isStaging || isProduction;

  /// Enable/disable analytics
  static bool get enableAnalytics => isStaging || isProduction;

  /// Enable/disable mock data
  static bool get enableMockData => isDevelopment;

  /// API timeout duration
  static Duration get apiTimeout {
    switch (_currentEnvironment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }

  /// App name based on environment
  static String get appName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Ubuzima Dev';
      case Environment.staging:
        return 'Ubuzima Beta';
      case Environment.production:
        return 'Ubuzima';
    }
  }

  /// App version suffix
  static String get versionSuffix {
    switch (_currentEnvironment) {
      case Environment.development:
        return '-dev';
      case Environment.staging:
        return '-beta';
      case Environment.production:
        return '';
    }
  }

  /// Database configuration
  static Map<String, dynamic> get databaseConfig {
    return {
      'enableEncryption': isProduction,
      'enableBackup': isProduction,
      'maxCacheSize': isDevelopment ? 50 : 100, // MB
    };
  }

  /// Security configuration
  static Map<String, dynamic> get securityConfig {
    return {
      'enableCertificatePinning': isProduction,
      'enableBiometrics': true,
      'sessionTimeout':
          isDevelopment ? const Duration(hours: 24) : const Duration(hours: 8),
      'maxLoginAttempts': isDevelopment ? 10 : 5,
    };
  }

  /// Feature flags
  static Map<String, bool> get featureFlags {
    return {
      'enableVoiceFeatures': false, // Disabled for beta
      'enableOfflineMode': true,
      'enablePushNotifications': isProduction || isStaging,
      'enableLocationServices': true,
      'enableFileUploads': true,
      'enableMessaging': true,
      'enableVideoCall': false, // Future feature
      'enableAIAssistant': false, // Future feature
      'enableAdvancedAnalytics': isProduction,
    };
  }

  /// Performance configuration
  static Map<String, dynamic> get performanceConfig {
    return {
      'enableImageCaching': true,
      'maxImageCacheSize': 100, // MB
      'enableNetworkCaching': true,
      'cacheExpiration': const Duration(hours: 24),
      'enableLazyLoading': true,
    };
  }

  /// Logging configuration
  static Map<String, dynamic> get loggingConfig {
    return {
      'enableConsoleLogging': enableLogging,
      'enableFileLogging': isProduction,
      'logLevel': isDevelopment ? 'debug' : 'info',
      'maxLogFileSize': 10, // MB
      'maxLogFiles': 5,
    };
  }

  /// Get environment display name
  static String get environmentDisplayName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Beta Testing';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get environment color for UI indication
  static int get environmentColor {
    switch (_currentEnvironment) {
      case Environment.development:
        return 0xFF4CAF50; // Green
      case Environment.staging:
        return 0xFFFF9800; // Orange
      case Environment.production:
        return 0xFF2196F3; // Blue
    }
  }

  /// Check if feature is enabled
  static bool isFeatureEnabled(String featureName) {
    return featureFlags[featureName] ?? false;
  }

  /// Get configuration value
  static T? getConfigValue<T>(String key, Map<String, dynamic> config) {
    return config[key] as T?;
  }

  /// Print environment info (debug only)
  static void printEnvironmentInfo() {
    if (enableLogging) {
      debugPrint('🌍 Environment: $environmentDisplayName');
      debugPrint('🔗 API URL: $apiBaseUrl');
      debugPrint('🔌 WebSocket URL: $websocketUrl');
      debugPrint('⚡ Debug Features: $enableDebugFeatures');
      debugPrint('📊 Analytics: $enableAnalytics');
      debugPrint('💥 Crash Reporting: $enableCrashReporting');
      debugPrint('🎯 Feature Flags: $featureFlags');
    }
  }

  /// Validate environment configuration
  static bool validateConfiguration() {
    try {
      // Check if API URL is valid
      if (apiBaseUrl.isEmpty) {
        debugPrint('❌ Invalid API URL');
        return false;
      }

      // Check if WebSocket URL is valid
      if (websocketUrl.isEmpty) {
        debugPrint('❌ Invalid WebSocket URL');
        return false;
      }

      // Validate security settings for production
      if (isProduction) {
        final securitySettings = securityConfig;
        if (!(securitySettings['enableCertificatePinning'] as bool)) {
          debugPrint('⚠️ Certificate pinning should be enabled in production');
        }
      }

      debugPrint('✅ Environment configuration is valid');
      return true;
    } catch (e) {
      debugPrint('❌ Environment configuration validation failed: $e');
      return false;
    }
  }
}
