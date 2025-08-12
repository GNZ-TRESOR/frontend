import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'network_service.dart';

/// Comprehensive Family Planning API Service with Full CRUD Operations
/// Handles all backend communication for the family planning platform
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

  /// Get the Dio instance for direct access
  Dio get dio => _dio;

  /// Initialize the API service with dynamic network detection
  Future<void> initialize() async {
    if (!AppConfig.isInitialized) {
      throw StateError(
        'AppConfig must be initialized before initializing ApiService',
      );
    }

    // Initialize network service for dynamic endpoint detection
    await NetworkService.instance.initialize();

    // Use dynamic URL if available, fallback to config
    final baseUrl = NetworkService.instance.currentBaseUrl ?? AppConfig.baseUrl;
    debugPrint('🔵 Initializing Family Planning API Service');
    debugPrint('🔵 Base URL: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
    _dio.interceptors.add(_createNetworkRetryInterceptor());
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('🔑 Auth token set');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    debugPrint('🔑 Auth token cleared');
  }

  /// Helper method to safely convert response data to Map<String, dynamic>
  Map<String, dynamic> _safeResponseData(dynamic responseData) {
    if (responseData is String) {
      return json.decode(responseData);
    } else if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    } else {
      return {'success': false, 'message': 'Invalid response format'};
    }
  }

  // ==================== AUTHENTICATION ENDPOINTS ====================

  /// User login
  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// User registration
  Future<ApiResponse> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Logout user
  Future<ApiResponse> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Refresh authentication token
  Future<ApiResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Forgot password
  Future<ApiResponse> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Reset password
  Future<ApiResponse> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Verify email
  Future<ApiResponse> verifyEmail(String token) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Resend verification email
  Future<ApiResponse> resendVerificationEmail(String email) async {
    try {
      final response = await _dio.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== USER MANAGEMENT ENDPOINTS ====================

  /// Get user profile
  Future<ApiResponse> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== ADMIN API METHODS ====================

  /// Get all users (Admin only)
  Future<ApiResponse> getAllUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? role,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (role != null && role != 'All') {
        queryParams['role'] = role;
      }

      final response = await _dio.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      // Special handling for users response
      // Backend returns: {"success": true, "users": [...], "total": 3, "page": 0, "size": 20}
      // But ApiResponse expects: {"success": true, "data": {...}}
      Map<String, dynamic> responseData;

      if (response.data is String) {
        responseData = json.decode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        responseData = Map<String, dynamic>.from(response.data);
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
      }

      if (responseData.containsKey('users')) {
        // Transform the response to include all pagination info in data
        responseData['data'] = {
          'users': responseData['users'],
          'total': responseData['total'],
          'page': responseData['page'],
          'size': responseData['size'],
        };
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get analytics data (Admin only)
  Future<ApiResponse> getAnalytics({int days = 30}) async {
    try {
      // Calculate date range based on days parameter
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await _dio.get(
        '/admin/analytics',
        queryParameters: {
          'startDate':
              startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
          'endDate':
              endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
        },
      );

      // Handle analytics response which has different structure
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'],
        data: responseData, // Pass the entire response as data
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get dashboard stats (Admin only)
  Future<ApiResponse> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/dashboard/stats');

      // Special handling for dashboard stats response
      // Backend returns: {"success": true, "stats": {...}}
      // But ApiResponse expects: {"success": true, "data": {...}}
      Map<String, dynamic> responseData;

      if (response.data is String) {
        responseData = json.decode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        responseData = Map<String, dynamic>.from(response.data);
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
      }

      if (responseData.containsKey('stats')) {
        // Move stats to data field for consistent parsing
        responseData['data'] = responseData['stats'];
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update user status (Admin only)
  Future<ApiResponse> updateUserStatus(String userId, bool isActive) async {
    try {
      final response = await _dio.put(
        '/admin/users/$userId/status',
        data: {'isActive': isActive},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete user (Admin only)
  Future<ApiResponse> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/admin/users/$userId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create user (Admin only)
  Future<ApiResponse> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/admin/users', data: userData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update user (Admin only)
  Future<ApiResponse> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dio.put('/admin/users/$userId', data: userData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get system settings (Admin only)
  Future<ApiResponse> getSystemSettings() async {
    try {
      final response = await _dio.get('/admin/system/settings');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update system settings (Admin only)
  Future<ApiResponse> updateSystemSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await _dio.put('/admin/system/settings', data: settings);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== HEALTH FACILITIES ENDPOINTS ====================

  /// Get health facilities
  Future<ApiResponse> getHealthFacilities({
    String? facilityType,
    bool? isActive,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (facilityType != null) queryParams['facilityType'] = facilityType;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await _dio.get(
        '/facilities',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get health facility by ID
  Future<ApiResponse> getHealthFacilityById(int facilityId) async {
    try {
      final response = await _dio.get('/facilities/$facilityId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create health facility (Admin only)
  Future<ApiResponse> createHealthFacility(
    Map<String, dynamic> facilityData,
  ) async {
    try {
      final response = await _dio.post('/admin/facilities', data: facilityData);
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update health facility (Admin only)
  Future<ApiResponse> updateHealthFacility(
    int facilityId,
    Map<String, dynamic> facilityData,
  ) async {
    try {
      final response = await _dio.put(
        '/admin/facilities/$facilityId',
        data: facilityData,
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete health facility (Admin only)
  Future<ApiResponse> deleteHealthFacility(int facilityId) async {
    try {
      final response = await _dio.delete('/admin/facilities/$facilityId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get nearby health facilities
  Future<ApiResponse> getNearbyFacilities({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    try {
      final response = await _dio.get(
        '/facilities/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get all notifications (Admin only)
  Future<ApiResponse> getAllNotifications({
    int page = 0,
    int size = 20,
    String? type,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};

      if (type != null) queryParams['type'] = type;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/admin/notifications',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create notification (Admin only)
  Future<ApiResponse> createNotification(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/notifications',
        data: notificationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update notification (Admin only)
  Future<ApiResponse> updateNotification(
    int id,
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final response = await _dio.put(
        '/admin/notifications/$id',
        data: notificationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete notification (Admin only)
  Future<ApiResponse> deleteAdminNotification(int id) async {
    try {
      final response = await _dio.delete('/admin/notifications/$id');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Broadcast notification (Admin only)
  Future<ApiResponse> broadcastNotification(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/notifications/broadcast',
        data: notificationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get report templates (Admin only)
  Future<ApiResponse> getReportTemplates() async {
    try {
      final response = await _dio.get('/admin/reports/templates');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get generated reports (Admin only)
  Future<ApiResponse> getGeneratedReports() async {
    try {
      final response = await _dio.get('/admin/reports');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generate report (Admin only)
  Future<ApiResponse> generateReport(
    String templateId,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/reports/generate',
        data: {
          'templateId': templateId,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get report summary data (Admin only)
  Future<ApiResponse> getReportSummary(String reportType) async {
    try {
      final response = await _dio.get('/admin/reports/$reportType/summary');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get detailed report data (Admin only)
  Future<ApiResponse> getReportDetails(
    String reportType,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await _dio.get(
        '/admin/reports/$reportType/details',
        queryParameters: {'startDate': startDate, 'endDate': endDate},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get report insights (Admin only)
  Future<ApiResponse> getReportInsights(String reportType) async {
    try {
      final response = await _dio.get('/admin/reports/insights/$reportType');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Export report as PDF (Admin only)
  Future<ApiResponse> exportReportPDF(
    String reportType,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/reports/export/pdf',
        data: {
          'reportType': reportType,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get system overview report (Admin only)
  Future<ApiResponse> getSystemOverview() async {
    try {
      final response = await _dio.get('/admin/reports/system/overview');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== HEALTH WORKER API METHODS ====================

  /// Get assigned clients for health worker
  Future<ApiResponse> getAssignedClients(int healthWorkerId) async {
    try {
      final response = await _dio.get('/health-worker/$healthWorkerId/clients');
      debugPrint('✅ [getAssignedClients] Success Response: ${response.data}');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          '❌ [getAssignedClients] DioException: ${e.response?.statusCode} - ${e.response?.data}',
        );
        if (e.response?.statusCode == 403) {
          debugPrint(
            "🚨 Access Denied: You don't have permission to view clients.",
          );
          return ApiResponse.success(data: {'success': true, 'clients': []});
        }
      } else {
        debugPrint('❌ [getAssignedClients] Error: $e');
      }
      return _handleError(e);
    }
  }

  /// Get health worker dashboard stats
  Future<ApiResponse> getHealthWorkerDashboardStats(int healthWorkerId) async {
    try {
      final response = await _dio.get(
        '/health-worker/$healthWorkerId/dashboard/stats',
      );

      debugPrint(
        '✅ [getHealthWorkerDashboardStats] Success Response: ${response.data}',
      );

      // Handle the special case where backend returns stats directly
      final responseData = _safeResponseData(response.data);
      if (responseData.containsKey('stats') &&
          responseData.containsKey('success')) {
        // Backend format: {"stats": {...}, "success": true}
        // Convert to expected format: {"success": true, "data": {...}}
        return ApiResponse.success(data: responseData['stats']);
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          '❌ [getHealthWorkerDashboardStats] DioException: ${e.response?.statusCode} - ${e.response?.data}',
        );
        if (e.response?.statusCode == 403) {
          debugPrint(
            "🚨 Access Denied: You don't have permission to view dashboard stats.",
          );
          return ApiResponse.error(
            message: 'Access denied. Please check your authentication.',
          );
        }
      }
      return _handleError(e);
    }
  }

  /// Get health worker clients
  Future<ApiResponse> getHealthWorkerClients(int healthWorkerId) async {
    try {
      final response = await _dio.get('/health-worker/$healthWorkerId/clients');

      debugPrint(
        '✅ [getHealthWorkerClients] Success Response: ${response.data}',
      );

      // Handle the special case where backend returns clients directly
      final responseData = _safeResponseData(response.data);
      if (responseData.containsKey('clients') &&
          responseData.containsKey('success')) {
        // Backend format: {"clients": [...], "success": true}
        // Convert to expected format: {"success": true, "data": [...]}
        return ApiResponse.success(data: responseData['clients']);
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          '❌ [getHealthWorkerClients] DioException: ${e.response?.statusCode} - ${e.response?.data}',
        );
        if (e.response?.statusCode == 403) {
          debugPrint(
            "🚨 Access Denied: You don't have permission to view clients.",
          );
          return ApiResponse.error(
            message: 'Access denied. Please check your authentication.',
          );
        }
      }
      return _handleError(e);
    }
  }

  /// Get health worker appointments
  Future<ApiResponse> getHealthWorkerAppointments(
    int healthWorkerId, {
    String? status,
    String? date,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (date != null) queryParams['date'] = date;

      final response = await _dio.get(
        '/health-worker/$healthWorkerId/appointments',
        queryParameters: queryParams,
      );
      debugPrint(
        '✅ [getHealthWorkerAppointments] Success Response: ${response.data}',
      );

      // Handle the special case where backend returns appointments directly
      final responseData = _safeResponseData(response.data);
      if (responseData.containsKey('appointments') &&
          responseData.containsKey('success')) {
        // Backend format: {"appointments": [...], "success": true}
        // Convert to expected format: {"success": true, "data": [...]}
        return ApiResponse.success(data: responseData['appointments']);
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          '❌ [getHealthWorkerAppointments] DioException: ${e.response?.statusCode} - ${e.response?.data}',
        );
        if (e.response?.statusCode == 403) {
          debugPrint(
            "🚨 Access Denied: You don't have permission to view appointments.",
          );
          return ApiResponse.error(
            message: 'Access denied. Please check your authentication.',
          );
        }
      } else {
        debugPrint('❌ [getHealthWorkerAppointments] Error: $e');
      }
      return _handleError(e);
    }
  }

  /// Update appointment status (Health Worker)
  Future<ApiResponse> updateAppointmentStatus(
    int appointmentId,
    String status,
  ) async {
    try {
      final response = await _dio.put(
        '/health-worker/appointments/$appointmentId/status',
        data: {'status': status},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get client health records (Health Worker)
  Future<ApiResponse> getClientHealthRecords(int clientId) async {
    try {
      final response = await _dio.get(
        '/health-worker/clients/$clientId/health-records',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Add health record for client (Health Worker)
  Future<ApiResponse> addClientHealthRecord(
    int clientId,
    Map<String, dynamic> recordData,
  ) async {
    try {
      final response = await _dio.post(
        '/health-worker/clients/$clientId/health-records',
        data: recordData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update user profile
  Future<ApiResponse> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/users/profile', data: userData);
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== COMMUNITY EVENTS ENDPOINTS ====================

  /// Get all community events
  Future<ApiResponse> getCommunityEvents() async {
    try {
      final response = await _dio.get('/community-events');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      // Handle 403 errors gracefully by returning empty events
      if (e.toString().contains('403')) {
        return ApiResponse.success(
          data: {
            'success': true,
            'events': [],
            'message': 'No community events available',
          },
        );
      }
      return _handleError(e);
    }
  }

  /// Get my registered events
  Future<ApiResponse> getMyEvents() async {
    try {
      final response = await _dio.get('/community-events/my-events');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      // Handle 403 errors gracefully by returning empty events
      if (e.toString().contains('403')) {
        return ApiResponse.success(
          data: {
            'success': true,
            'events': [],
            'message': 'No registered events found',
          },
        );
      }
      return _handleError(e);
    }
  }

  /// Get events created by health worker
  Future<ApiResponse> getMyCommunityEvents() async {
    try {
      final response = await _dio.get('/community-events/created');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      // Handle 403 errors gracefully by returning empty events
      if (e.toString().contains('403')) {
        return ApiResponse.success(
          data: {
            'success': true,
            'events': [],
            'message': 'No created events available',
          },
        );
      }
      return _handleError(e);
    }
  }

  /// Create a community event (Health worker only)
  Future<ApiResponse> createCommunityEvent(
    Map<String, dynamic> eventData,
  ) async {
    try {
      final response = await _dio.post('/community-events', data: eventData);
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Register for a community event
  Future<ApiResponse> registerForEvent(int eventId) async {
    try {
      final response = await _dio.post('/community-events/$eventId/register');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Cancel event registration
  Future<ApiResponse> cancelEventRegistration(int eventId) async {
    try {
      final response = await _dio.delete('/community-events/$eventId/register');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== HEALTH RECORDS ENDPOINTS ====================

  /// Get health records
  Future<ApiResponse> getHealthRecords({int page = 0, int size = 20}) async {
    try {
      // Get current user to determine the correct endpoint
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];
      final userRole = userData['role'];

      // Health workers don't have personal health records
      if (userRole == 'healthWorker') {
        return ApiResponse.fromJson({
          'success': true,
          'data': [], // Empty array for health workers
          'message': 'Health workers do not have personal health records',
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': 0,
          'pageSize': size,
        });
      }

      // Use user-centric health endpoint for clients
      final response = await _dio.get('/user-centric-health/record/$userId');

      if (response.data['success'] == true) {
        // The user-centric endpoint returns a single record, wrap it in an array for consistency
        final singleRecord = response.data['data'];
        return ApiResponse.fromJson({
          'success': true,
          'data': [singleRecord], // Wrap single record in array
          'message': 'Health records retrieved successfully',
          'totalElements': 1,
          'totalPages': 1,
          'currentPage': 0,
          'pageSize': size,
        });
      } else {
        return ApiResponse.fromJson(response.data);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create health record
  Future<ApiResponse> createHealthRecord(
    Map<String, dynamic> recordData,
  ) async {
    try {
      final response = await _dio.post('/health-records', data: recordData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update health record
  Future<ApiResponse> updateHealthRecord(
    int recordId,
    Map<String, dynamic> recordData,
  ) async {
    try {
      final response = await _dio.put(
        '/health-records/$recordId',
        data: recordData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete health record
  Future<ApiResponse> deleteHealthRecord(int recordId) async {
    try {
      final response = await _dio.delete('/health-records/$recordId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get available health workers
  Future<ApiResponse> getHealthWorkers({
    int? healthFacilityId,
    String? specialization,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (healthFacilityId != null) {
        queryParams['healthFacilityId'] = healthFacilityId;
      }
      if (specialization != null) {
        queryParams['specialization'] = specialization;
      }
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable;

      final response = await _dio.get(
        '/health-records/health-workers',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== MENSTRUAL CYCLE ENDPOINTS ====================

  /// Get menstrual cycles
  Future<ApiResponse> getMenstrualCycles({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/menstrual-cycles',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create menstrual cycle
  Future<ApiResponse> createMenstrualCycle(
    Map<String, dynamic> cycleData,
  ) async {
    try {
      final response = await _dio.post('/menstrual-cycles', data: cycleData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update menstrual cycle
  Future<ApiResponse> updateMenstrualCycle(
    int cycleId,
    Map<String, dynamic> cycleData,
  ) async {
    try {
      final response = await _dio.put(
        '/menstrual-cycles/$cycleId',
        data: cycleData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete menstrual cycle
  Future<ApiResponse> deleteMenstrualCycle(int cycleId) async {
    try {
      final response = await _dio.delete('/menstrual-cycles/$cycleId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get menstrual symptoms
  Future<ApiResponse> getMenstrualSymptoms({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/menstrual-cycles/symptoms',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Add symptom to menstrual cycle
  Future<ApiResponse> addSymptomToCycle(int cycleId, String symptom) async {
    try {
      final response = await _dio.post(
        '/menstrual-cycles/$cycleId/symptoms',
        data: {'symptom': symptom},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Remove symptom from menstrual cycle
  Future<ApiResponse> removeSymptomFromCycle(
    int cycleId,
    String symptom,
  ) async {
    try {
      final response = await _dio.delete(
        '/menstrual-cycles/$cycleId/symptoms',
        data: {'symptom': symptom},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== MEDICATIONS ENDPOINTS ====================

  /// Get medications
  Future<ApiResponse> getMedications({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/medications',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create medication
  Future<ApiResponse> createMedication(
    Map<String, dynamic> medicationData,
  ) async {
    try {
      final response = await _dio.post('/medications', data: medicationData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update medication
  Future<ApiResponse> updateMedication(
    int medicationId,
    Map<String, dynamic> medicationData,
  ) async {
    try {
      final response = await _dio.put(
        '/medications/$medicationId',
        data: medicationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete medication
  Future<ApiResponse> deleteMedication(int medicationId) async {
    try {
      final response = await _dio.delete('/medications/$medicationId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get medication side effects
  Future<ApiResponse> getMedicationSideEffects(int medicationId) async {
    try {
      final response = await _dio.get(
        '/medications/$medicationId/side-effects',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create medication side effect
  Future<ApiResponse> createMedicationSideEffect(
    int medicationId,
    Map<String, dynamic> sideEffectData,
  ) async {
    try {
      final response = await _dio.post(
        '/medications/$medicationId/side-effects',
        data: sideEffectData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== CONTRACEPTION ENDPOINTS ====================

  /// Get contraception methods
  Future<ApiResponse> getContraceptionMethods() async {
    try {
      final response = await _dio.get(
        '/contraception',
      ); // ✅ FIXED: Changed from /contraception/methods to /contraception
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get available contraception methods (where user_id is null)
  Future<ApiResponse> getAvailableContraceptionMethods() async {
    try {
      final response = await _dio.get(
        '/contraception',
        queryParameters: {'available': true},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get user contraception
  Future<ApiResponse> getUserContraception({
    int page = 0,
    int size = 20,
    int? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (userId != null) queryParams['userId'] = userId;

      final response = await _dio.get(
        '/contraception',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create contraception record
  Future<ApiResponse> createContraceptionRecord(
    Map<String, dynamic> contraceptionData,
  ) async {
    try {
      final response = await _dio.post(
        '/contraception',
        data: contraceptionData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update contraception record
  Future<ApiResponse> updateContraceptionRecord(
    int recordId,
    Map<String, dynamic> contraceptionData,
  ) async {
    try {
      final response = await _dio.put(
        '/contraception/$recordId',
        data: contraceptionData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete contraception record
  Future<ApiResponse> deleteContraceptionRecord(int recordId) async {
    try {
      final response = await _dio.delete('/contraception/$recordId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Cancel contraception method (set is_active to false)
  Future<ApiResponse> cancelContraceptionMethod(int methodId) async {
    try {
      final response = await _dio.put('/contraception/$methodId/cancel');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get active contraception method for user
  Future<ApiResponse> getActiveContraceptionMethod(int userId) async {
    try {
      final response = await _dio.get(
        '/contraception/active',
        queryParameters: {'userId': userId},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get contraception types
  Future<ApiResponse> getContraceptionTypes() async {
    try {
      final response = await _dio.get('/contraception/types');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Side Effects API endpoints

  /// Get side effect reports for a specific user
  Future<ApiResponse> getUserSideEffects(int userId) async {
    try {
      final response = await _dio.get('/side-effect-reports/user/$userId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get side effect reports for a specific contraception method
  Future<ApiResponse> getMethodSideEffects(int methodId) async {
    try {
      final response = await _dio.get(
        '/contraception-side-effects/method/$methodId',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get all side effect reports (Health Worker only)
  Future<ApiResponse> getAllSideEffects() async {
    try {
      final response = await _dio.get('/side-effect-reports');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create a new side effect report
  Future<ApiResponse> createSideEffectReport(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/side-effect-reports', data: data);
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update a side effect report
  Future<ApiResponse> updateSideEffectReport(
    int reportId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/side-effect-reports/$reportId',
        data: data,
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete a side effect report
  Future<ApiResponse> deleteSideEffectReport(int reportId) async {
    try {
      final response = await _dio.delete('/side-effect-reports/$reportId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get common side effects for a contraception method type
  Future<ApiResponse> getCommonSideEffects(String methodType) async {
    try {
      final response = await _dio.get(
        '/contraception-side-effects/common/$methodType',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get specific contraception method by ID
  Future<ApiResponse> getContraceptionMethod(int methodId) async {
    try {
      final response = await _dio.get('/contraception/$methodId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== EDUCATION ENDPOINTS ====================

  /// Get education lessons
  Future<ApiResponse> getEducationLessons({
    int page = 0,
    int size = 20,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get(
        '/education/lessons',
        queryParameters: queryParams,
      );

      // Handle direct response format from backend
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('lessons')) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.fromJson(response.data);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get lesson by ID
  Future<ApiResponse> getLessonById(int lessonId) async {
    try {
      final response = await _dio.get('/education/lessons/$lessonId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create a new education lesson
  Future<ApiResponse> createEducationLesson(
    Map<String, dynamic> lessonData,
  ) async {
    try {
      final response = await _dio.post('/education/lessons', data: lessonData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update an education lesson
  Future<ApiResponse> updateEducationLesson(
    int lessonId,
    Map<String, dynamic> lessonData,
  ) async {
    try {
      final response = await _dio.put(
        '/education/lessons/$lessonId',
        data: lessonData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete an education lesson
  Future<ApiResponse> deleteEducationLesson(int lessonId) async {
    try {
      final response = await _dio.delete('/education/lessons/$lessonId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Toggle lesson publish status
  Future<ApiResponse> toggleLessonPublishStatus(int lessonId) async {
    try {
      final response = await _dio.patch(
        '/education/lessons/$lessonId/toggle-publish',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get user education progress
  Future<ApiResponse> getEducationProgress() async {
    try {
      final response = await _dio.get('/education/progress');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update education progress
  Future<ApiResponse> updateEducationProgress(
    int lessonId,
    Map<String, dynamic> progressData,
  ) async {
    try {
      final response = await _dio.post(
        '/education/progress/$lessonId',
        data: progressData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== APPOINTMENTS ENDPOINTS ====================

  /// Get appointments
  Future<ApiResponse> getAppointments({
    int page = 0,
    int size = 20,
    String? status,
    String? date,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};

      if (status != null) queryParams['status'] = status;
      if (date != null) queryParams['date'] = date;

      final response = await _dio.get(
        '/appointments',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get appointment details by ID
  Future<ApiResponse> getAppointmentDetails(int appointmentId) async {
    try {
      final response = await _dio.get('/appointments/$appointmentId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get client details by ID
  Future<ApiResponse> getClientDetails(int clientId) async {
    try {
      final response = await _dio.get('/users/$clientId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get client appointments
  Future<ApiResponse> getClientAppointments(int clientId) async {
    try {
      final response = await _dio.get('/users/$clientId/appointments');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create appointment
  Future<ApiResponse> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      final response = await _dio.post('/appointments', data: appointmentData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update appointment
  Future<ApiResponse> updateAppointment(
    int appointmentId,
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      print(
        'DEBUG: Updating appointment $appointmentId with data: $appointmentData',
      );
      final response = await _dio.put(
        '/appointments/$appointmentId',
        data: appointmentData,
      );
      print('DEBUG: Update response: ${response.data}');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      print('DEBUG: Update error: $e');
      return _handleError(e);
    }
  }

  /// Delete appointment
  Future<ApiResponse> deleteAppointment(
    int appointmentId, {
    String? reason,
  }) async {
    try {
      print('DEBUG: Deleting appointment $appointmentId with reason: $reason');
      final data = reason != null ? {'reason': reason} : null;
      final response = await _dio.delete(
        '/appointments/$appointmentId',
        data: data,
      );
      print('DEBUG: Delete response: ${response.data}');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      print('DEBUG: Delete error: $e');
      return _handleError(e);
    }
  }

  // ==================== TIME SLOTS ENDPOINTS ====================

  /// Get time slots
  Future<ApiResponse> getTimeSlots({
    int? healthWorkerId,
    int? healthFacilityId,
    String? date,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (healthWorkerId != null) {
        queryParams['healthWorkerId'] = healthWorkerId;
      }
      if (healthFacilityId != null) {
        queryParams['healthFacilityId'] = healthFacilityId;
      }
      if (date != null) queryParams['date'] = date;
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable;

      final response = await _dio.get(
        '/time-slots',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create time slot
  Future<ApiResponse> createTimeSlot(Map<String, dynamic> timeSlotData) async {
    try {
      final response = await _dio.post('/time-slots', data: timeSlotData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update time slot
  Future<ApiResponse> updateTimeSlot(
    int timeSlotId,
    Map<String, dynamic> timeSlotData,
  ) async {
    try {
      final response = await _dio.put(
        '/time-slots/$timeSlotId',
        data: timeSlotData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete time slot
  Future<ApiResponse> deleteTimeSlot(int timeSlotId) async {
    try {
      final response = await _dio.delete('/time-slots/$timeSlotId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get available time slots for booking
  Future<ApiResponse> getAvailableTimeSlots({
    required int healthFacilityId,
    int? healthWorkerId,
    required String date,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'facilityId': healthFacilityId.toString(),
        'date': date,
      };
      if (healthWorkerId != null) {
        queryParams['healthWorkerId'] = healthWorkerId.toString();
      }

      final response = await _dio.get(
        '/appointments/available-slots',
        queryParameters: queryParams,
      );

      // Special handling for time slots response
      // Backend returns: {"success": true, "timeSlots": [...]}
      // But ApiResponse expects: {"success": true, "data": [...]}
      Map<String, dynamic> responseData;

      if (response.data is String) {
        responseData = json.decode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        responseData = Map<String, dynamic>.from(response.data);
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
      }

      if (responseData.containsKey('timeSlots')) {
        // Move timeSlots to data field for consistent parsing
        responseData['data'] = responseData['timeSlots'];
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== FAMILY PLANNING ENDPOINTS ====================

  /// Get pregnancy plans for current user
  Future<ApiResponse> getPregnancyPlans({int page = 0, int size = 20}) async {
    try {
      // Get current user to determine the correct endpoint
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];

      final response = await _dio.get(
        '/family-planning/pregnancy-plans',
        queryParameters: {'userId': userId, 'page': page, 'size': size},
      );

      // Handle the specific response format
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('success') &&
            responseMap['success'] == true) {
          return ApiResponse.success(
            data: responseMap,
            message:
                responseMap['message'] ??
                'Pregnancy plans retrieved successfully',
          );
        } else {
          return ApiResponse.error(
            message: responseMap['message'] ?? 'Failed to load pregnancy plans',
          );
        }
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create pregnancy plan
  Future<ApiResponse> createPregnancyPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _dio.post(
        '/family-planning/pregnancy-plans',
        data: planData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update pregnancy plan
  Future<ApiResponse> updatePregnancyPlan(
    int planId,
    Map<String, dynamic> planData,
  ) async {
    try {
      final response = await _dio.put(
        '/family-planning/pregnancy-plans/$planId',
        data: planData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete pregnancy plan
  Future<ApiResponse> deletePregnancyPlan(int planId) async {
    try {
      final response = await _dio.delete(
        '/family-planning/pregnancy-plans/$planId',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get partner invitations for current user
  Future<ApiResponse> getPartnerInvitations({
    int page = 0,
    int size = 20,
  }) async {
    try {
      // Get current user to determine the correct endpoint
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];

      final response = await _dio.get(
        '/partner-invitations',
        queryParameters: {'userId': userId, 'page': page, 'size': size},
      );

      // Handle the specific response format
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('success') &&
            responseMap['success'] == true) {
          return ApiResponse.success(
            data: responseMap,
            message:
                responseMap['message'] ??
                'Partner invitations retrieved successfully',
          );
        } else {
          return ApiResponse.error(
            message:
                responseMap['message'] ?? 'Failed to load partner invitations',
          );
        }
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Send partner invitation
  Future<ApiResponse> sendPartnerInvitation(
    Map<String, dynamic> invitationData,
  ) async {
    try {
      final response = await _dio.post(
        '/partner-invitations',
        data: invitationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Accept partner invitation
  Future<ApiResponse> acceptPartnerInvitation(String invitationCode) async {
    try {
      final response = await _dio.post(
        '/partner-invitations/$invitationCode/accept',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Decline partner invitation
  Future<ApiResponse> declinePartnerInvitation(String invitationCode) async {
    try {
      final response = await _dio.post(
        '/partner-invitations/$invitationCode/decline',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get partner decisions for current user
  Future<ApiResponse> getPartnerDecisions({int page = 0, int size = 20}) async {
    try {
      // Get current user to determine the correct endpoint
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];

      final response = await _dio.get(
        '/partner-decisions',
        queryParameters: {'userId': userId, 'page': page, 'size': size},
      );

      // Handle the specific response format
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('success') &&
            responseMap['success'] == true) {
          return ApiResponse.success(
            data: responseMap,
            message:
                responseMap['message'] ??
                'Partner decisions retrieved successfully',
          );
        } else {
          return ApiResponse.error(
            message:
                responseMap['message'] ?? 'Failed to load partner decisions',
          );
        }
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create partner decision
  Future<ApiResponse> createPartnerDecision(
    Map<String, dynamic> decisionData,
  ) async {
    try {
      final response = await _dio.post(
        '/partner-decisions',
        data: decisionData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update partner decision
  Future<ApiResponse> updatePartnerDecision(
    int decisionId,
    Map<String, dynamic> decisionData,
  ) async {
    try {
      final response = await _dio.put(
        '/partner-decisions/$decisionId',
        data: decisionData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete partner decision
  Future<ApiResponse> deletePartnerDecision(int decisionId) async {
    try {
      final response = await _dio.delete('/partner-decisions/$decisionId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== STI TESTING ENDPOINTS ====================

  /// Get STI test records for current user
  Future<ApiResponse> getStiTestRecords({int page = 0, int size = 20}) async {
    try {
      // Get current user to determine the correct endpoint
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];

      final response = await _dio.get(
        '/sti-test-records',
        queryParameters: {'userId': userId, 'page': page, 'size': size},
      );

      // Handle the specific STI response format
      // Backend returns: {"records": [...], "success": true}
      // We need to transform it to match ApiResponse format
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('success') &&
            responseMap['success'] == true) {
          // Transform the response to match ApiResponse format
          return ApiResponse.success(
            data: responseMap, // Pass the entire response as data
            message:
                responseMap['message'] ?? 'STI records retrieved successfully',
          );
        } else {
          return ApiResponse.error(
            message:
                responseMap['message'] ?? 'Failed to load STI test records',
          );
        }
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create STI test record
  Future<ApiResponse> createStiTestRecord(Map<String, dynamic> testData) async {
    try {
      // Get current user ID and add to test data
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];

      // Add userId to test data
      testData['userId'] = userId;

      final response = await _dio.post('/sti-test-records', data: testData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update STI test record
  Future<ApiResponse> updateStiTestRecord(
    int recordId,
    Map<String, dynamic> testData,
  ) async {
    try {
      final response = await _dio.put(
        '/sti-test-records/$recordId',
        data: testData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete STI test record
  Future<ApiResponse> deleteStiTestRecord(int recordId) async {
    try {
      // Get current user ID for authorization
      final userProfileResponse = await getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        return ApiResponse.error(message: 'Failed to get user profile');
      }

      final userData = userProfileResponse.data as Map<String, dynamic>;
      final userId = userData['id'];

      final response = await _dio.delete(
        '/sti-test-records/$recordId',
        queryParameters: {'userId': userId},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== SUPPORT GROUPS ENDPOINTS ====================

  // ==================== SUPPORT GROUPS ENDPOINTS ====================

  /// Get support groups
  Future<ApiResponse> getSupportGroups({
    int page = 0,
    int size = 20,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/community/support-groups',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      if (e.toString().contains('403')) {
        return ApiResponse.success(
          data: {
            'success': true,
            'groups': [],
            'message': 'No support groups available',
          },
        );
      }
      return _handleError(e);
    }
  }

  /// Join support group
  Future<ApiResponse> joinSupportGroup(int groupId) async {
    try {
      final response = await _dio.post(
        '/community/support-groups/$groupId/join',
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Leave support group
  Future<ApiResponse> leaveSupportGroup(int groupId) async {
    try {
      final response = await _dio.post(
        '/community/support-groups/$groupId/leave',
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create support group (Health Worker only)
  Future<ApiResponse> createSupportGroup(Map<String, dynamic> groupData) async {
    try {
      final response = await _dio.post(
        '/community/support-groups',
        data: groupData,
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update support group (Health Worker only)
  Future<ApiResponse> updateSupportGroup(
    int groupId,
    Map<String, dynamic> groupData,
  ) async {
    try {
      final response = await _dio.put(
        '/community/support-groups/$groupId',
        data: groupData,
      );
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete support group (Health Worker only)
  Future<ApiResponse> deleteSupportGroup(int groupId) async {
    try {
      final response = await _dio.delete('/community/support-groups/$groupId');
      return ApiResponse.fromJson(_safeResponseData(response.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get support group members (Health Worker only)
  Future<ApiResponse> getSupportGroupMembers(int groupId) async {
    try {
      final response = await _dio.get(
        '/community/support-groups/$groupId/members',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Add member to support group (Health Worker only)
  Future<ApiResponse> addSupportGroupMember(int groupId, int userId) async {
    try {
      final response = await _dio.post(
        '/community/support-groups/$groupId/members',
        data: {'userId': userId},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Remove member from support group (Health Worker only)
  Future<ApiResponse> removeSupportGroupMember(int groupId, int userId) async {
    try {
      final response = await _dio.delete(
        '/community/support-groups/$groupId/members/$userId',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get support tickets
  Future<ApiResponse> getSupportTickets({
    String? status,
    String? type,
    String? priority,
    int? userId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (priority != null) queryParams['priority'] = priority;
      if (userId != null) queryParams['userId'] = userId;

      final response = await _dio.get(
        '/support-tickets',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Create support ticket
  Future<ApiResponse> createSupportTicket(
    Map<String, dynamic> ticketData,
  ) async {
    try {
      final response = await _dio.post('/support-tickets', data: ticketData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update support ticket (Health Worker only)
  Future<ApiResponse> updateSupportTicket(
    int ticketId,
    Map<String, dynamic> ticketData,
  ) async {
    try {
      final response = await _dio.put(
        '/support-tickets/$ticketId',
        data: ticketData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Resolve support ticket (Health Worker only)
  Future<ApiResponse> resolveSupportTicket(
    int ticketId,
    String resolutionNotes,
  ) async {
    try {
      final response = await _dio.post(
        '/support-tickets/$ticketId/resolve',
        data: {'resolutionNotes': resolutionNotes},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== HEALTH FACILITIES ENDPOINTS ====================

  // ==================== USER SETTINGS ENDPOINTS ====================

  /// Get user settings
  Future<ApiResponse> getUserSettings() async {
    try {
      final response = await _dio.get('/user-settings');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update user settings
  Future<ApiResponse> updateUserSettings(
    Map<String, dynamic> settingsData,
  ) async {
    try {
      final response = await _dio.put('/user-settings', data: settingsData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Reset user settings to default
  Future<ApiResponse> resetUserSettings() async {
    try {
      final response = await _dio.post('/user-settings/reset');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== NOTIFICATIONS ENDPOINTS ====================

  /// Get notifications for current user
  Future<ApiResponse> getNotifications({
    int page = 0,
    int size = 20,
    bool? unreadOnly,
    String? type,
  }) async {
    try {
      // Get current user ID from profile
      final userProfile = await getUserProfile();
      if (!userProfile.success || userProfile.data == null) {
        return ApiResponse(
          success: false,
          message: 'Failed to get user profile',
          data: null,
        );
      }

      final userId = userProfile.data['id'];
      final queryParams = <String, dynamic>{
        'userId': userId,
        'page': page,
        'limit': size,
      };
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      // Special handling for notifications response
      // Backend returns: {"notifications": [...], "page": 0, "totalPages": 0, "success": true, "total": 0}
      // But ApiResponse expects: {"success": true, "data": {...}}
      Map<String, dynamic> responseData;

      if (response.data is String) {
        responseData = json.decode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        responseData = Map<String, dynamic>.from(response.data);
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
      }

      if (responseData.containsKey('notifications')) {
        // Transform the response to include all notification data in data field
        responseData['data'] = {
          'notifications': responseData['notifications'],
          'total': responseData['total'],
          'page': responseData['page'],
          'totalPages': responseData['totalPages'],
        };
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get unread notifications count
  Future<ApiResponse> getUnreadNotificationsCount() async {
    try {
      // Get current user ID from profile
      final userProfile = await getUserProfile();
      if (!userProfile.success || userProfile.data == null) {
        return ApiResponse(
          success: false,
          message: 'Failed to get user profile',
          data: null,
        );
      }

      final userId = userProfile.data['id'];
      final response = await _dio.get(
        '/notifications/unread',
        queryParameters: {'userId': userId},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Mark notification as read
  Future<ApiResponse> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _dio.put('/notifications/$notificationId/read');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse> markAllNotificationsAsRead() async {
    try {
      final response = await _dio.put('/notifications/mark-all-read');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete notification
  Future<ApiResponse> deleteNotification(int notificationId) async {
    try {
      final response = await _dio.delete('/notifications/$notificationId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Clear all notifications
  Future<ApiResponse> clearAllNotifications() async {
    try {
      final response = await _dio.delete('/notifications/clear-all');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get notification settings
  Future<ApiResponse> getNotificationSettings() async {
    try {
      final response = await _dio.get('/notifications/settings');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update notification settings
  Future<ApiResponse> updateNotificationSettings(
    Map<String, dynamic> settingsData,
  ) async {
    try {
      final response = await _dio.put(
        '/notifications/settings',
        data: settingsData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== NOTIFICATION MANAGEMENT ENDPOINTS ====================

  /// Create notification (Health Worker and Admin only)
  Future<ApiResponse> createNotificationForUser({
    required int userId,
    required String title,
    required String message,
    String type = 'GENERAL',
    int priority = 2,
    String? actionUrl,
    String? icon,
    DateTime? scheduledFor,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notificationData = {
        'userId': userId,
        'title': title,
        'message': message,
        'notificationType': type,
        'priority': priority,
        if (actionUrl != null) 'actionUrl': actionUrl,
        if (icon != null) 'icon': icon,
        if (scheduledFor != null)
          'scheduledFor': scheduledFor.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _dio.post(
        '/notifications/create',
        data: notificationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Send notification to multiple users (Health Worker and Admin only)
  Future<ApiResponse> sendNotificationToUsers({
    required List<int> userIds,
    required String title,
    required String message,
    String type = 'GENERAL',
    int priority = 2,
    String? actionUrl,
    String? icon,
    DateTime? scheduledFor,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notificationData = {
        'userIds': userIds,
        'title': title,
        'message': message,
        'notificationType': type,
        'priority': priority,
        if (actionUrl != null) 'actionUrl': actionUrl,
        if (icon != null) 'icon': icon,
        if (scheduledFor != null)
          'scheduledFor': scheduledFor.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _dio.post(
        '/notifications/send-multiple',
        data: notificationData,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get notifications by type for current user
  Future<ApiResponse> getNotificationsByType(String type) async {
    try {
      // Get current user ID from profile
      final userProfile = await getUserProfile();
      if (!userProfile.success || userProfile.data == null) {
        return ApiResponse(
          success: false,
          message: 'Failed to get user profile',
          data: null,
        );
      }

      final userId = userProfile.data['id'];
      final response = await _dio.get(
        '/notifications/types/$type',
        queryParameters: {'userId': userId},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get sent notifications (Health Worker and Admin only)
  Future<ApiResponse> getSentNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications/sent',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== FILE UPLOADS ENDPOINTS ====================

  /// Upload file
  Future<ApiResponse> uploadFile(String filePath, {String? category}) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (category != null) 'category': category,
      });

      final response = await _dio.post('/file-uploads', data: formData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get user's uploaded files
  Future<ApiResponse> getUserFiles({
    int page = 0,
    int size = 20,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get(
        '/file-uploads/my-files',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete uploaded file
  Future<ApiResponse> deleteFile(int fileId) async {
    try {
      final response = await _dio.delete('/file-uploads/$fileId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Download file
  Future<ApiResponse> downloadFile(int fileId) async {
    try {
      final response = await _dio.get('/file-uploads/$fileId/download');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== INTERCEPTORS ====================

  /// Create logging interceptor
  Interceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      requestHeader: kDebugMode,
      responseHeader: false,
      error: true,
      logPrint: (obj) => debugPrint('🌐 API: $obj'),
    );
  }

  /// Create authentication interceptor
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          debugPrint('🔑 Adding auth token to request: Bearer $_authToken');
        } else {
          debugPrint(
            '⚠️ No auth token available for request to ${options.uri}',
          );
        }
        handler.next(options);
      },
    );
  }

  /// Create error interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('🔴 API Error: ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Create network retry interceptor for dynamic endpoint switching
  Interceptor _createNetworkRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout) {
          debugPrint(
            '🔄 Network error detected, trying to find new endpoint...',
          );

          // Try to refresh endpoint
          await NetworkService.instance.refreshEndpoint();
          final newBaseUrl = NetworkService.instance.currentBaseUrl;

          if (newBaseUrl != null && newBaseUrl != _dio.options.baseUrl) {
            debugPrint('🔄 Switching to new endpoint: $newBaseUrl');
            _dio.options.baseUrl = newBaseUrl;

            // Retry the request with new endpoint
            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (retryError) {
              debugPrint('🔄 Retry failed: $retryError');
            }
          }
        }

        handler.next(error);
      },
    );
  }

  /// Handle API errors
  ApiResponse _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse(
            success: false,
            message:
                'Connection timeout. Please check your internet connection.',
            data: null,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          String message = 'Server error occurred';

          // Handle 403 errors differently
          if (statusCode == 403) {
            // Check if auth token is missing
            if (_authToken == null) {
              return ApiResponse(
                success: false,
                message: 'Please log in to access this feature',
                data: null,
                statusCode: statusCode,
              );
            }
            // Return empty success response for certain endpoints
            if (error.requestOptions.path.contains('/community-events')) {
              return ApiResponse.success(
                data: {
                  'success': true,
                  'events': [],
                  'message': 'No events available',
                },
              );
            }
          }

          // Safely extract message from response data
          final responseData = error.response?.data;
          if (responseData != null && responseData is Map<String, dynamic>) {
            message = responseData['message'] ?? message;
          }

          return ApiResponse(
            success: false,
            message: message,
            data: null,
            statusCode: statusCode,
          );
        case DioExceptionType.cancel:
          return ApiResponse(
            success: false,
            message: 'Request was cancelled',
            data: null,
          );
        default:
          return ApiResponse(
            success: false,
            message: 'Network error occurred',
            data: null,
          );
      }
    }

    return ApiResponse(
      success: false,
      message: 'An unexpected error occurred',
      data: null,
    );
  }

  // ==================== FEEDBACK ENDPOINTS ====================

  /// Submit feedback
  Future<ApiResponse> submitFeedback(Map<String, dynamic> feedbackData) async {
    try {
      final response = await _dio.post('/feedback', data: feedbackData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get feedback (admin only)
  Future<ApiResponse> getFeedback({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/feedback',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get feedback categories
  Future<ApiResponse> getFeedbackCategories() async {
    try {
      final response = await _dio.get('/feedback/categories');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get feedback statistics (admin only)
  Future<ApiResponse> getFeedbackStats() async {
    try {
      final response = await _dio.get('/feedback/stats');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== MISSING BACKEND ENDPOINTS ====================

  /// Get messages (messaging system)
  Future<ApiResponse> getMessages({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/messages',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Send message
  Future<ApiResponse> sendMessage({
    required int senderId,
    required int receiverId,
    String? content,
    String? conversationId,
    String messageType = 'TEXT',
    String priority = 'NORMAL',
    bool isEmergency = false,
    String? audioUrl,
    int? audioDuration,
    int? quotedMessageId,
    bool isForwarded = false,
    String? forwardedFrom,
  }) async {
    try {
      final data = {
        'senderId': senderId,
        'receiverId': receiverId,
        'conversationId': conversationId,
        'messageType': messageType,
        'priority': priority,
        'isEmergency': isEmergency,
        'isForwarded': isForwarded,
      };

      // Add optional fields only if they have values
      if (content != null) data['content'] = content;
      if (audioUrl != null) data['audioUrl'] = audioUrl;
      if (audioDuration != null) data['audioDuration'] = audioDuration;
      if (quotedMessageId != null) data['quotedMessageId'] = quotedMessageId;
      if (forwardedFrom != null) data['forwardedFrom'] = forwardedFrom;

      final response = await _dio.post('/messages', data: data);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Upload audio file for voice message
  Future<ApiResponse> uploadAudioMessage({
    required String filePath,
    required int senderId,
    required int receiverId,
    int? duration,
    String? conversationId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'senderId': senderId,
        'receiverId': receiverId,
        'duration': duration,
        'conversationId': conversationId,
      });

      final response = await _dio.post('/audio/upload', data: formData);
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update message status (delivered, read)
  Future<ApiResponse> updateMessageStatus({
    required int messageId,
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        '/messages/$messageId/status',
        data: {'status': status},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Add reaction to message
  Future<ApiResponse> addMessageReaction({
    required int messageId,
    required String reaction,
  }) async {
    try {
      final response = await _dio.post(
        '/messages/$messageId/reaction',
        data: {'reaction': reaction},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get conversations
  Future<ApiResponse> getConversations({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/conversations',
        queryParameters: {'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Mark message as read
  Future<ApiResponse> markMessageAsRead(int messageId) async {
    try {
      final response = await _dio.put('/messages/$messageId/read');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get conversation between two users
  Future<ApiResponse> getConversation(
    int userId1,
    int userId2, {
    int page = 0,
    int size = 50,
  }) async {
    debugPrint(
      '🔥 getConversation called with userId1=$userId1, userId2=$userId2',
    );
    try {
      debugPrint('🔥 About to make API call...');
      final response = await _dio.get(
        '/messages/conversation/$userId1/$userId2',
        queryParameters: {'page': page, 'size': size},
      );
      debugPrint('🔥 API call completed, processing response...');

      // Special handling for conversation response
      // Backend returns: {"success": true, "messages": [...], "totalPages": 1, "totalElements": 5, "currentPage": 0}
      // But ApiResponse expects: {"success": true, "data": {...}}
      Map<String, dynamic> responseData;

      debugPrint('🔍 Raw response.data type: ${response.data.runtimeType}');
      debugPrint('🔍 Raw response.data: ${response.data}');

      if (response.data is String) {
        responseData = json.decode(response.data);
        debugPrint('🔍 Parsed from String: $responseData');
      } else if (response.data is Map<String, dynamic>) {
        responseData = Map<String, dynamic>.from(response.data);
        debugPrint('🔍 Converted from Map: $responseData');
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
        debugPrint('🔍 Invalid format, using default: $responseData');
      }

      debugPrint('🔍 Response data keys: ${responseData.keys.toList()}');
      debugPrint(
        '🔍 Contains messages: ${responseData.containsKey('messages')}',
      );

      if (responseData.containsKey('messages')) {
        debugPrint('🔍 Moving messages to data field...');
        // Move all conversation data to data field for consistent parsing
        responseData['data'] = {
          'messages': responseData['messages'],
          'totalPages': responseData['totalPages'],
          'totalElements': responseData['totalElements'],
          'currentPage': responseData['currentPage'],
        };
        debugPrint('🔍 Final responseData: $responseData');
      }

      debugPrint('🔍 About to call ApiResponse.fromJson with: $responseData');
      return ApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('🔥 Exception in getConversation: $e');
      return _handleError(e);
    }
  }

  /// Get conversation partners (users who have messaged with current user)
  Future<ApiResponse> getConversationPartners(int userId) async {
    try {
      final response = await _dio.get(
        '/messages/conversations',
        queryParameters: {'userId': userId},
      );

      // Special handling for conversations response
      // Backend returns: {"success": true, "conversations": [...]}
      // But ApiResponse expects: {"success": true, "data": {...}}
      Map<String, dynamic> responseData;

      if (response.data is String) {
        responseData = json.decode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        responseData = Map<String, dynamic>.from(response.data);
      } else {
        responseData = {'success': false, 'message': 'Invalid response format'};
      }

      if (responseData.containsKey('conversations')) {
        // Move conversations to data field for consistent parsing
        responseData['data'] = {'conversations': responseData['conversations']};
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get unread messages count
  Future<ApiResponse> getUnreadMessagesCount(int userId) async {
    try {
      final response = await _dio.get(
        '/messages/unread',
        queryParameters: {'userId': userId},
      );

      // Handle the special case where backend returns unread data directly
      final responseData = _safeResponseData(response.data);
      if (responseData.containsKey('unreadCount') &&
          responseData.containsKey('success')) {
        // Backend format: {"unreadCount": 2, "unreadMessages": [...], "success": true}
        // Convert to expected format: {"success": true, "data": {...}}
        return ApiResponse.success(data: responseData);
      }

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get messages for a specific user
  Future<ApiResponse> getMessagesForUser(
    int userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/messages',
        queryParameters: {'userId': userId, 'page': page, 'size': size},
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get community overview
  Future<ApiResponse> getCommunityOverview() async {
    try {
      final response = await _dio.get('/community/overview');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get support groups
  Future<ApiResponse> getCommunityGroups({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/community/support-groups',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get admin dashboard stats
  Future<ApiResponse> getAdminDashboardStats() async {
    try {
      final response = await _dio.get('/admin/dashboard/stats');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get admin users
  Future<ApiResponse> getAdminUsers({
    int page = 0,
    int size = 20,
    String? role,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (role != null) queryParams['role'] = role;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/admin/users',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get all appointments (Admin only)
  Future<ApiResponse> getAdminAppointments({
    int page = 0,
    int size = 20,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/admin/appointments',
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get health facility by ID (alias for getHealthFacilityById)
  Future<ApiResponse> getHealthFacility(int facilityId) async {
    return await getHealthFacilityById(facilityId);
  }

  /// Get health worker by ID
  Future<ApiResponse> getHealthWorker(int healthWorkerId) async {
    try {
      final response = await _dio.get('/health-workers/$healthWorkerId');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Prescribe contraception method (Health Worker)
  Future<ApiResponse> prescribeContraceptionMethod(
    int methodId,
    int userId,
  ) async {
    try {
      final response = await _dio.post(
        '/contraception/prescribe',
        data: {
          'methodId': methodId,
          'userId': userId,
          'startDate': DateTime.now().toIso8601String(),
          'isActive': true,
        },
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Toggle contraception method active state
  Future<ApiResponse> toggleContraceptionMethodActive(int methodId) async {
    try {
      final response = await _dio.patch(
        '/contraception/$methodId/toggle-active',
      );
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }
}
