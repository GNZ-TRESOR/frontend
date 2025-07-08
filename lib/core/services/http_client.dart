import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;
  String? _authToken;

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  // Auth Interceptor - Adds JWT token to requests
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired
        if (error.response?.statusCode == 401) {
          await _handleTokenExpired();
        }
        handler.next(error);
      },
    );
  }

  // Logging Interceptor - Logs requests and responses in debug mode
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint('🚀 REQUEST: ${options.method} ${options.path}');
          debugPrint('📤 Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('📤 Data: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('📥 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          debugPrint('❌ Message: ${error.message}');
          if (error.response?.data != null) {
            debugPrint('❌ Data: ${error.response?.data}');
          }
        }
        handler.next(error);
      },
    );
  }

  // Error Interceptor - Handles common errors
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        String errorMessage = 'An error occurred';
        
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Connection timeout. Please check your internet connection.';
        } else if (error.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect to server. Please check your internet connection.';
        } else if (error.response != null) {
          switch (error.response!.statusCode) {
            case 400:
              errorMessage = 'Bad request. Please check your input.';
              break;
            case 401:
              errorMessage = 'Unauthorized. Please login again.';
              break;
            case 403:
              errorMessage = 'Access forbidden.';
              break;
            case 404:
              errorMessage = 'Resource not found.';
              break;
            case 500:
              errorMessage = 'Server error. Please try again later.';
              break;
            default:
              errorMessage = 'Error ${error.response!.statusCode}: ${error.response!.statusMessage}';
          }
        }

        // Create a new DioException with user-friendly message
        final userFriendlyError = DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: errorMessage,
          message: errorMessage,
        );

        handler.next(userFriendlyError);
      },
    );
  }

  // Set authentication token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, token);
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.userTokenKey);
    return _authToken;
  }

  // Clear authentication token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
  }

  // Handle token expiration
  Future<void> _handleTokenExpired() async {
    await clearAuthToken();
    // You can add navigation to login screen here
    // NavigationService.navigateToLogin();
  }

  // Check if backend is reachable
  Future<bool> checkBackendHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      return false;
    }
  }

  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?data,
    });

    return await _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }
}
