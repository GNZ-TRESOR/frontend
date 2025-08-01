import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Authentication provider using Riverpod
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  final ApiService _apiService = ApiService.instance;

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await StorageService.getAuthToken();
      if (token != null) {
        _apiService.setAuthToken(token);
        await _loadUserProfile();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check authentication status',
      );
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.data != null) {
        final authData = response.data as Map<String, dynamic>;
        final token = authData['accessToken'] as String;
        final userData = authData['user'] as Map<String, dynamic>;

        // Clear any existing tokens first
        await StorageService.clearAuthToken();
        _apiService.clearAuthToken();

        // Store new token
        await StorageService.setAuthToken(token);
        _apiService.setAuthToken(token);

        // Create user object
        final user = User.fromJson(userData);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed: $e');
      return false;
    }
  }

  /// Register user
  Future<bool> register(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.register(userData);

      if (response.success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed: $e',
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    // Clear local storage
    await StorageService.clearAuthToken();
    _apiService.clearAuthToken();

    state = AuthState();
  }

  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
        );
      } else {
        // Token might be invalid, logout
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updateUserProfile(userData);

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(isLoading: false, user: user);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Profile update failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profile update failed: $e',
      );
      return false;
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        final response = await _apiService.refreshToken(refreshToken);

        if (response.success && response.data != null) {
          final authData = response.data as Map<String, dynamic>;
          final newToken = authData['token'] as String;

          await StorageService.setAuthToken(newToken);
          _apiService.setAuthToken(newToken);
        } else {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// User role provider
final userRoleProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// Role-based access providers
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role?.toLowerCase() == 'admin';
});

final isHealthWorkerProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role?.toLowerCase() == 'healthworker' ||
      role?.toLowerCase() == 'health_worker';
});

final isClientProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role?.toLowerCase() == 'client' || role?.toLowerCase() == 'user';
});
