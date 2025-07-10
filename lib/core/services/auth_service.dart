import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'http_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpClient _httpClient = HttpClient();
  User? _currentUser;
  String? _currentToken;

  // Getters
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isAuthenticated => _currentUser != null && _currentToken != null;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadStoredAuth();
  }

  // Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _httpClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['accessToken'] as String;
        final userMap = data['user'] as Map<String, dynamic>;

        final user = User.fromJson(userMap);

        await _saveAuth(user, token);
        await _httpClient.setAuthToken(token);

        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Login failed');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String role = AppConstants.roleClient,
    String? gender,
    DateTime? dateOfBirth,
    String? district,
    String? sector,
    String? cell,
    String? village,
    String? emergencyContact,
    String? preferredLanguage,
    String? facilityId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'name': '$firstName $lastName',
        'email': email,
        'password': password,
        'phone': phoneNumber,
      };

      // Add optional fields if provided
      if (gender != null) requestData['gender'] = gender;
      if (dateOfBirth != null)
        requestData['dateOfBirth'] =
            dateOfBirth.toIso8601String().split('T')[0];
      if (district != null) requestData['district'] = district;
      if (sector != null) requestData['sector'] = sector;
      if (cell != null) requestData['cell'] = cell;
      if (village != null) requestData['village'] = village;
      if (emergencyContact != null)
        requestData['emergencyContact'] = emergencyContact;
      if (preferredLanguage != null)
        requestData['preferredLanguage'] = preferredLanguage;
      if (facilityId != null) requestData['facilityId'] = facilityId;

      final response = await _httpClient.post(
        '/auth/register',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final token = data['accessToken'] as String;

          // Create a basic user object since the backend doesn't return full user data in register
          final user = User(
            id: email, // Use email as temporary ID
            name: '$firstName $lastName',
            email: email,
            phone: phoneNumber,
            role: UserRole.fromValue(role),
            createdAt: DateTime.now(),
          );

          await _saveAuth(user, token);
          await _httpClient.setAuthToken(token);

          return AuthResult.success(user);
        } else {
          return AuthResult.failure(
            responseData['userMessage'] ?? 'Registration failed',
          );
        }
      } else {
        return AuthResult.failure('Registration failed');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call backend logout endpoint
      await _httpClient.post('/auth/logout');
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      // Clear local auth data regardless of backend response
      await _clearAuth();
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      if (_currentToken == null) return false;

      final response = await _httpClient.post(
        '/auth/refresh',
        data: {'refreshToken': _currentToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['token'] as String;

        await _httpClient.setAuthToken(newToken);
        _currentToken = newToken;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userTokenKey, newToken);

        return true;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }

    return false;
  }

  // Get current user profile from backend
  Future<User?> getCurrentUserProfile() async {
    try {
      final response = await _httpClient.get('/users/profile');

      if (response.statusCode == 200) {
        final userMap = response.data as Map<String, dynamic>;
        final user = User.fromJson(userMap);

        _currentUser = user;
        await _saveUserData(user);

        return user;
      }
    } catch (e) {
      debugPrint('Get profile error: $e');
    }

    return null;
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _httpClient.put('/users/profile', data: updates);

      if (response.statusCode == 200) {
        final userMap = response.data as Map<String, dynamic>;
        final user = User.fromJson(userMap);

        _currentUser = user;
        await _saveUserData(user);

        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }

    return false;
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _httpClient.put(
        '/users/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _httpClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _httpClient.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  // Private methods
  Future<void> _saveAuth(User user, String token) async {
    _currentUser = user;
    _currentToken = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, token);
    await prefs.setString(AppConstants.userIdKey, user.id);
    await prefs.setString(AppConstants.userRoleKey, user.role.name);
    await _saveUserData(user);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();

    _currentToken = prefs.getString(AppConstants.userTokenKey);
    final userData = prefs.getString('user_data');

    if (_currentToken != null && userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        await _httpClient.setAuthToken(_currentToken!);
      } catch (e) {
        debugPrint('Error loading stored auth: $e');
        await _clearAuth();
      }
    }
  }

  Future<void> _clearAuth() async {
    _currentUser = null;
    _currentToken = null;

    await _httpClient.clearAuthToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userRoleKey);
    await prefs.remove('user_data');
  }

  // Password reset methods
  Future<bool> sendPasswordResetCode(String email) async {
    try {
      final response = await _httpClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send password reset code error: $e');
      return false;
    }
  }

  Future<bool> verifyPasswordResetCode(String email, String code) async {
    try {
      // This would typically verify the code with the backend
      // For now, return true as a placeholder
      return true;
    } catch (e) {
      debugPrint('Verify password reset code error: $e');
      return false;
    }
  }

  Future<bool> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await _httpClient.post(
        '/auth/reset-password',
        data: {
          'token': code, // Assuming the code is used as token
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password with code error: $e');
      return false;
    }
  }

  // Email verification methods
  Future<bool> sendEmailVerificationCode(String email) async {
    try {
      // This would typically send email verification code
      // For now, return true as a placeholder
      return true;
    } catch (e) {
      debugPrint('Send email verification code error: $e');
      return false;
    }
  }

  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      // This would typically verify email code with the backend
      // For now, return true as a placeholder
      return true;
    } catch (e) {
      debugPrint('Verify email code error: $e');
      return false;
    }
  }

  // Phone verification methods
  Future<bool> sendPhoneVerificationCode(String phone) async {
    try {
      // This would typically send phone verification code
      // For now, return true as a placeholder
      return true;
    } catch (e) {
      debugPrint('Send phone verification code error: $e');
      return false;
    }
  }

  Future<bool> verifyPhoneCode(String phone, String code) async {
    try {
      // This would typically verify phone code with the backend
      // For now, return true as a placeholder
      return true;
    } catch (e) {
      debugPrint('Verify phone code error: $e');
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Connection')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResult.success(this.user) : isSuccess = true, error = null;
  AuthResult.failure(this.error) : isSuccess = false, user = null;
}
