/// API Response model for handling all backend responses
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      statusCode: json['statusCode'],
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'statusCode': statusCode,
      'errors': errors,
    };
  }

  /// Create a successful response
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message ?? 'Operation successful',
    );
  }

  /// Create an error response
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Check if the response is successful
  bool get isSuccess => success;

  /// Check if the response is an error
  bool get isError => !success;

  /// Get error message or default message
  String get errorMessage => message ?? 'Unknown error occurred';

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, data: $data, statusCode: $statusCode}';
  }
}
