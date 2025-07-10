import 'user.dart';

/// API Response model matching backend ApiResponse structure
class ApiResponse<T> {
  final bool success;
  final String message;
  final String? userMessage;
  final String? errorCode;
  final T? data;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? userRole;

  const ApiResponse({
    required this.success,
    required this.message,
    this.userMessage,
    this.errorCode,
    this.data,
    this.metadata,
    required this.timestamp,
    this.userRole,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      userMessage: json['userMessage'] as String?,
      errorCode: json['errorCode'] as String?,
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'] as T?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
      userRole: json['userRole'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'userMessage': userMessage,
      'errorCode': errorCode,
      'data': data,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'userRole': userRole,
    };
  }

  /// Check if the response indicates success
  bool get isSuccess => success;

  /// Check if the response indicates failure
  bool get isFailure => !success;

  /// Get user-friendly error message
  String get errorMessage => userMessage ?? message;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, errorCode: $errorCode)';
  }
}

/// Authentication response model
class AuthResponse {
  final String token;
  final String? refreshToken;
  final User user;

  const AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

/// Auth result wrapper for internal use
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? token;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.token,
  });

  factory AuthResult.success(User user, {String? token}) {
    return AuthResult._(isSuccess: true, user: user, token: token);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}
