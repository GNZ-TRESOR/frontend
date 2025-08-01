import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

/// Storage service for managing local data persistence
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize storage service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await SecureStorageService.initialize();
    debugPrint('✅ Storage Service initialized');
  }

  /// Ensure preferences are initialized
  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception(
        'StorageService not initialized. Call StorageService.initialize() first.',
      );
    }
    return _prefs!;
  }

  // ==================== AUTHENTICATION STORAGE (SECURE) ====================

  /// Store authentication token securely
  static Future<bool> setAuthToken(String token) async {
    try {
      await SecureStorageService.setAuthToken(token);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to store auth token: $e');
      return false;
    }
  }

  /// Get authentication token securely
  static Future<String?> getAuthToken() async {
    try {
      return await SecureStorageService.getAuthToken();
    } catch (e) {
      debugPrint('❌ Failed to get auth token: $e');
      return null;
    }
  }

  /// Store refresh token securely
  static Future<bool> setRefreshToken(String token) async {
    try {
      await SecureStorageService.setRefreshToken(token);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to store refresh token: $e');
      return false;
    }
  }

  /// Get refresh token securely
  static Future<String?> getRefreshToken() async {
    try {
      return await SecureStorageService.getRefreshToken();
    } catch (e) {
      debugPrint('❌ Failed to get refresh token: $e');
      return null;
    }
  }

  /// Clear authentication tokens securely
  static Future<bool> clearAuthToken() async {
    try {
      await SecureStorageService.clearAuthTokens();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to clear auth tokens: $e');
      return false;
    }
  }

  // ==================== USER DATA STORAGE ====================

  /// Store user data
  static Future<bool> setUserData(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    return await _preferences.setString('user_data', userJson);
  }

  /// Get user data
  static Map<String, dynamic>? getUserData() {
    final userJson = _preferences.getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear user data
  static Future<bool> clearUserData() async {
    return await _preferences.remove('user_data');
  }

  // ==================== APP SETTINGS STORAGE ====================

  /// Store theme mode
  static Future<bool> setThemeMode(String themeMode) async {
    return await _preferences.setString('theme_mode', themeMode);
  }

  /// Get theme mode
  static String getThemeMode() {
    return _preferences.getString('theme_mode') ?? 'light';
  }

  /// Store language
  static Future<bool> setLanguage(String language) async {
    return await _preferences.setString('language', language);
  }

  /// Get language
  static String getLanguage() {
    return _preferences.getString('language') ?? 'en';
  }

  /// Store notification settings
  static Future<bool> setNotificationSettings(
    Map<String, bool> settings,
  ) async {
    final settingsJson = jsonEncode(settings);
    return await _preferences.setString('notification_settings', settingsJson);
  }

  /// Get notification settings
  static Map<String, bool> getNotificationSettings() {
    final settingsJson = _preferences.getString('notification_settings');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      return settings.map((key, value) => MapEntry(key, value as bool));
    }
    return {
      'cycle_reminders': true,
      'medication_reminders': true,
      'appointment_reminders': true,
      'educational_content': true,
      'support_group_messages': true,
    };
  }

  // ==================== HEALTH DATA STORAGE ====================

  /// Store last sync timestamp
  static Future<bool> setLastSyncTimestamp(DateTime timestamp) async {
    return await _preferences.setString(
      'last_sync',
      timestamp.toIso8601String(),
    );
  }

  /// Get last sync timestamp
  static DateTime? getLastSyncTimestamp() {
    final timestampString = _preferences.getString('last_sync');
    if (timestampString != null) {
      return DateTime.parse(timestampString);
    }
    return null;
  }

  /// Store offline health data
  static Future<bool> setOfflineHealthData(
    List<Map<String, dynamic>> data,
  ) async {
    final dataJson = jsonEncode(data);
    return await _preferences.setString('offline_health_data', dataJson);
  }

  /// Get offline health data
  static List<Map<String, dynamic>> getOfflineHealthData() {
    final dataJson = _preferences.getString('offline_health_data');
    if (dataJson != null) {
      final data = jsonDecode(dataJson) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Clear offline health data
  static Future<bool> clearOfflineHealthData() async {
    return await _preferences.remove('offline_health_data');
  }

  // ==================== ONBOARDING & TUTORIAL STORAGE ====================

  /// Set onboarding completed
  static Future<bool> setOnboardingCompleted(bool completed) async {
    return await _preferences.setBool('onboarding_completed', completed);
  }

  /// Check if onboarding is completed
  static bool isOnboardingCompleted() {
    return _preferences.getBool('onboarding_completed') ?? false;
  }

  /// Set tutorial completed for a specific feature
  static Future<bool> setTutorialCompleted(
    String feature,
    bool completed,
  ) async {
    return await _preferences.setBool('tutorial_$feature', completed);
  }

  /// Check if tutorial is completed for a specific feature
  static bool isTutorialCompleted(String feature) {
    return _preferences.getBool('tutorial_$feature') ?? false;
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Store cached data with expiration
  static Future<bool> setCachedData(
    String key,
    Map<String, dynamic> data, {
    Duration? expiration,
  }) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'expiration': expiration?.inMilliseconds,
    };
    final cacheJson = jsonEncode(cacheData);
    return await _preferences.setString('cache_$key', cacheJson);
  }

  /// Get cached data if not expired
  static Map<String, dynamic>? getCachedData(String key) {
    final cacheJson = _preferences.getString('cache_$key');
    if (cacheJson != null) {
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheData['timestamp']);
      final expirationMs = cacheData['expiration'] as int?;

      if (expirationMs != null) {
        final expiration = Duration(milliseconds: expirationMs);
        if (DateTime.now().difference(timestamp) > expiration) {
          // Cache expired, remove it
          _preferences.remove('cache_$key');
          return null;
        }
      }

      return cacheData['data'] as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear specific cached data
  static Future<bool> clearCachedData(String key) async {
    return await _preferences.remove('cache_$key');
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    final keys = _preferences.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith('cache_'));
    for (final key in cacheKeys) {
      await _preferences.remove(key);
    }
  }

  // ==================== GENERAL STORAGE METHODS ====================

  /// Store string value
  static Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  /// Get string value
  static String? getString(String key) {
    return _preferences.getString(key);
  }

  /// Store integer value
  static Future<bool> setInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  /// Get integer value
  static int? getInt(String key) {
    return _preferences.getInt(key);
  }

  /// Store boolean value
  static Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  /// Get boolean value
  static bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  /// Store double value
  static Future<bool> setDouble(String key, double value) async {
    return await _preferences.setDouble(key, value);
  }

  /// Get double value
  static double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  /// Store list of strings
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }

  /// Get list of strings
  static List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  /// Remove specific key
  static Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  /// Get all keys
  static Set<String> getAllKeys() {
    return _preferences.getKeys();
  }

  /// Clear all data
  static Future<bool> clearAll() async {
    return await _preferences.clear();
  }

  /// Get storage size (approximate)
  static int getStorageSize() {
    final keys = _preferences.getKeys();
    int totalSize = 0;

    for (final key in keys) {
      final value = _preferences.get(key);
      if (value is String) {
        totalSize += value.length;
      } else if (value != null) {
        totalSize += value.toString().length;
      }
    }

    return totalSize;
  }
}
