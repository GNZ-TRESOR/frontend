import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user_model.dart';
import '../models/health_record_model.dart';
import '../models/appointment_model.dart';
import '../models/health_facility_model.dart';
import '../constants/app_constants.dart';

// part 'api_service.g.dart'; // Generated file - will be created when running build_runner

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiService {
  // factory ApiService(Dio dio, {String baseUrl}) = _ApiService; // Generated implementation

  // Authentication endpoints
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/auth/refresh')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST('/auth/logout')
  Future<void> logout();

  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Body() ForgotPasswordRequest request);

  @POST('/auth/reset-password')
  Future<void> resetPassword(@Body() ResetPasswordRequest request);

  // User endpoints
  @GET('/users/profile')
  Future<User> getProfile();

  @PUT('/users/profile')
  Future<User> updateProfile(@Body() Map<String, dynamic> request);

  @POST('/users/change-password')
  Future<void> changePassword(@Body() Map<String, dynamic> request);

  @DELETE('/users/account')
  Future<void> deleteAccount();

  // Health Records endpoints
  @GET('/health-records')
  Future<List<HealthRecord>> getHealthRecords(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('type') String? type,
  );

  @POST('/health-records')
  Future<HealthRecord> createHealthRecord(@Body() Map<String, dynamic> request);

  @GET('/health-records/{id}')
  Future<HealthRecord> getHealthRecord(@Path('id') String id);

  @PUT('/health-records/{id}')
  Future<HealthRecord> updateHealthRecord(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/health-records/{id}')
  Future<void> deleteHealthRecord(@Path('id') String id);

  // Menstrual Cycle endpoints
  @GET('/menstrual-cycles')
  Future<List<Map<String, dynamic>>> getMenstrualCycles(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/menstrual-cycles')
  Future<Map<String, dynamic>> createMenstrualCycle(
    @Body() Map<String, dynamic> request,
  );

  @PUT('/menstrual-cycles/{id}')
  Future<Map<String, dynamic>> updateMenstrualCycle(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  // Medications endpoints
  @GET('/medications')
  Future<List<Map<String, dynamic>>> getMedications();

  @POST('/medications')
  Future<Map<String, dynamic>> createMedication(
    @Body() Map<String, dynamic> request,
  );

  @PUT('/medications/{id}')
  Future<Map<String, dynamic>> updateMedication(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/medications/{id}')
  Future<void> deleteMedication(@Path('id') String id);

  // Appointments endpoints
  @GET('/appointments')
  Future<List<Appointment>> getAppointments(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('status') String? status,
  );

  @POST('/appointments')
  Future<Appointment> createAppointment(@Body() Map<String, dynamic> request);

  @GET('/appointments/{id}')
  Future<Appointment> getAppointment(@Path('id') String id);

  @PUT('/appointments/{id}')
  Future<Appointment> updateAppointment(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/appointments/{id}')
  Future<void> cancelAppointment(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  @GET('/appointments/available-slots')
  Future<List<TimeSlot>> getAvailableSlots(
    @Query('facilityId') String facilityId,
    @Query('healthWorkerId') String healthWorkerId,
    @Query('date') String date,
  );

  // Messages endpoints
  @GET('/messages')
  Future<List<Map<String, dynamic>>> getMessages(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('conversationId') String? conversationId,
  );

  @POST('/messages')
  Future<Map<String, dynamic>> sendMessage(
    @Body() Map<String, dynamic> request,
  );

  @PUT('/messages/{id}/read')
  Future<void> markMessageAsRead(@Path('id') String id);

  @GET('/conversations')
  Future<List<Map<String, dynamic>>> getConversations();

  // Health Facilities endpoints
  @GET('/facilities')
  Future<List<HealthFacility>> getHealthFacilities(
    @Query('lat') double? latitude,
    @Query('lng') double? longitude,
    @Query('radius') double? radius,
    @Query('type') String? type,
  );

  @GET('/facilities/{id}')
  Future<HealthFacility> getHealthFacility(@Path('id') String id);

  @GET('/facilities/{id}/health-workers')
  Future<List<User>> getFacilityHealthWorkers(@Path('id') String facilityId);

  // Education endpoints
  @GET('/education/lessons')
  Future<List<Map<String, dynamic>>> getEducationLessons(
    @Query('category') String? category,
    @Query('level') String? level,
  );

  @GET('/education/lessons/{id}')
  Future<Map<String, dynamic>> getEducationLesson(@Path('id') String id);

  @GET('/education/progress')
  Future<List<Map<String, dynamic>>> getEducationProgress();

  @POST('/education/progress')
  Future<Map<String, dynamic>> updateEducationProgress(
    @Body() Map<String, dynamic> request,
  );

  // File upload endpoints
  @POST('/files/upload')
  @MultiPart()
  Future<FileUploadResponse> uploadFile(@Part() MultipartFile file);

  @POST('/files/upload-multiple')
  @MultiPart()
  Future<List<FileUploadResponse>> uploadMultipleFiles(
    @Part() List<MultipartFile> files,
  );

  // Health Worker specific endpoints
  @GET('/health-worker/clients')
  Future<List<User>> getClients(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('search') String? search,
  );

  @GET('/health-worker/clients/{id}')
  Future<Map<String, dynamic>> getClientDetails(@Path('id') String clientId);

  @POST('/health-worker/consultations')
  Future<Map<String, dynamic>> createConsultation(
    @Body() Map<String, dynamic> request,
  );

  // Admin specific endpoints
  @GET('/admin/users')
  Future<List<User>> getAllUsers(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('role') String? role,
    @Query('search') String? search,
  );

  @POST('/admin/users')
  Future<User> createUser(@Body() Map<String, dynamic> request);

  @PUT('/admin/users/{id}')
  Future<User> updateUser(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/admin/users/{id}')
  Future<void> deleteUser(@Path('id') String id);

  @GET('/admin/analytics')
  Future<Map<String, dynamic>> getAnalytics(
    @Query('startDate') String startDate,
    @Query('endDate') String endDate,
  );

  @GET('/admin/reports')
  Future<List<Map<String, dynamic>>> getReports(
    @Query('type') String type,
    @Query('startDate') String startDate,
    @Query('endDate') String endDate,
  );

  // Notifications endpoints
  @GET('/notifications')
  Future<List<Map<String, dynamic>>> getNotifications(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @PUT('/notifications/{id}/read')
  Future<void> markNotificationAsRead(@Path('id') String id);

  @POST('/notifications/register-device')
  Future<void> registerDevice(@Body() Map<String, dynamic> request);
}

// Request/Response models
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  final Map<String, dynamic>? additionalData;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.additionalData,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'role': role,
    if (additionalData != null) ...additionalData!,
  };
}

class AuthResponse {
  final String token;
  final String refreshToken;
  final User user;
  final DateTime expiresAt;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'],
    refreshToken: json['refreshToken'],
    user: User.fromJson(json['user']),
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() => {'token': token, 'newPassword': newPassword};
}

class FileUploadResponse {
  final String id;
  final String url;
  final String filename;
  final int size;
  final String mimeType;

  FileUploadResponse({
    required this.id,
    required this.url,
    required this.filename,
    required this.size,
    required this.mimeType,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      FileUploadResponse(
        id: json['id'],
        url: json['url'],
        filename: json['filename'],
        size: json['size'],
        mimeType: json['mimeType'],
      );
}
