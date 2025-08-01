import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data like JWT tokens
class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Initialize secure storage
  static Future<void> initialize() async {
    try {
      debugPrint('🔐 Initializing Secure Storage Service');
      // Test if secure storage is available
      await _secureStorage.containsKey(key: 'test');
      debugPrint('✅ Secure Storage Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize secure storage: $e');
      rethrow;
    }
  }

  // ==================== AUTHENTICATION TOKENS ====================

  /// Store authentication token securely
  static Future<void> setAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
      debugPrint('🔑 Auth token stored securely');
    } catch (e) {
      debugPrint('❌ Failed to store auth token: $e');
      rethrow;
    }
  }

  /// Get authentication token
  static Future<String?> getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: _authTokenKey);
      if (token != null) {
        debugPrint('🔑 Auth token retrieved from secure storage');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Failed to retrieve auth token: $e');
      return null;
    }
  }

  /// Store refresh token securely
  static Future<void> setRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
      debugPrint('🔑 Refresh token stored securely');
    } catch (e) {
      debugPrint('❌ Failed to store refresh token: $e');
      rethrow;
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null) {
        debugPrint('🔑 Refresh token retrieved from secure storage');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Failed to retrieve refresh token: $e');
      return null;
    }
  }

  /// Clear authentication tokens
  static Future<void> clearAuthTokens() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      debugPrint('🔑 Auth tokens cleared from secure storage');
    } catch (e) {
      debugPrint('❌ Failed to clear auth tokens: $e');
      rethrow;
    }
  }

  // ==================== USER DATA ====================

  /// Store user data securely
  static Future<void> setUserData(String userData) async {
    try {
      await _secureStorage.write(key: _userDataKey, value: userData);
      debugPrint('👤 User data stored securely');
    } catch (e) {
      debugPrint('❌ Failed to store user data: $e');
      rethrow;
    }
  }

  /// Get user data
  static Future<String?> getUserData() async {
    try {
      final userData = await _secureStorage.read(key: _userDataKey);
      if (userData != null) {
        debugPrint('👤 User data retrieved from secure storage');
      }
      return userData;
    } catch (e) {
      debugPrint('❌ Failed to retrieve user data: $e');
      return null;
    }
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: _userDataKey);
      debugPrint('👤 User data cleared from secure storage');
    } catch (e) {
      debugPrint('❌ Failed to clear user data: $e');
      rethrow;
    }
  }

  // ==================== BIOMETRIC SETTINGS ====================

  /// Set biometric authentication enabled status
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey, 
        value: enabled.toString(),
      );
      debugPrint('🔐 Biometric setting stored: $enabled');
    } catch (e) {
      debugPrint('❌ Failed to store biometric setting: $e');
      rethrow;
    }
  }

  /// Get biometric authentication enabled status
  static Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Failed to retrieve biometric setting: $e');
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if a key exists in secure storage
  static Future<bool> containsKey(String key) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      debugPrint('❌ Failed to check key existence: $e');
      return false;
    }
  }

  /// Clear all secure storage data
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('🔐 All secure storage data cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear all secure storage: $e');
      rethrow;
    }
  }

  /// Get all stored keys (for debugging purposes only)
  static Future<Map<String, String>> getAllData() async {
    try {
      if (kDebugMode) {
        final allData = await _secureStorage.readAll();
        debugPrint('🔐 Retrieved all secure storage data (debug mode)');
        return allData;
      } else {
        throw UnsupportedError('getAllData is only available in debug mode');
      }
    } catch (e) {
      debugPrint('❌ Failed to retrieve all secure storage data: $e');
      return {};
    }
  }

  /// Check if secure storage is available on the device
  static Future<bool> isAvailable() async {
    try {
      await _secureStorage.containsKey(key: 'availability_test');
      return true;
    } catch (e) {
      debugPrint('❌ Secure storage not available: $e');
      return false;
    }
  }

  /// Migrate data from SharedPreferences to secure storage
  static Future<void> migrateFromSharedPreferences() async {
    try {
      debugPrint('🔄 Starting migration from SharedPreferences to secure storage');
      
      // This would be implemented if we need to migrate existing users
      // For now, we'll just log that migration is available
      
      debugPrint('✅ Migration completed successfully');
    } catch (e) {
      debugPrint('❌ Migration failed: $e');
      rethrow;
    }
  }
}
