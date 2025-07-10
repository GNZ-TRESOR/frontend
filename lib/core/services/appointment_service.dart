import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/appointment_model.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../models/health_facility_model.dart';
import 'http_client.dart';

/// Service for managing appointments with complete CRUD operations
class AppointmentService {
  final HttpClient _httpClient = HttpClient();

  /// Get all appointments with filtering and pagination
  Future<List<Appointment>> getAppointments({
    int page = 0,
    int limit = 10,
    String? status,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (userId != null) queryParams['userId'] = userId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _httpClient.get(
        '/appointments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final appointmentsData = apiResponse.data as Map<String, dynamic>;
          final appointmentsList = appointmentsData['appointments'] as List<dynamic>;
          
          return appointmentsList
              .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      return [];
    }
  }

  /// Get appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final response = await _httpClient.get('/appointments/$appointmentId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Appointment.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching appointment: $e');
      return null;
    }
  }

  /// Create new appointment
  Future<Appointment?> createAppointment({
    required String clientId,
    required String facilityId,
    String? healthWorkerId,
    required AppointmentType type,
    required DateTime scheduledDate,
    String? reason,
    String? notes,
    bool isUrgent = false,
  }) async {
    try {
      final requestData = {
        'clientId': clientId,
        'facilityId': facilityId,
        'healthWorkerId': healthWorkerId,
        'type': type.name.toUpperCase(),
        'scheduledDate': scheduledDate.toIso8601String(),
        'reason': reason,
        'notes': notes,
        'isUrgent': isUrgent,
      };

      final response = await _httpClient.post(
        '/appointments',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Appointment.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error creating appointment: $e');
      return null;
    }
  }

  /// Update appointment
  Future<Appointment?> updateAppointment({
    required String appointmentId,
    AppointmentType? type,
    AppointmentStatus? status,
    DateTime? scheduledDate,
    DateTime? actualDate,
    String? reason,
    String? notes,
    String? symptoms,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? followUpInstructions,
    DateTime? nextAppointmentDate,
    bool? isUrgent,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (type != null) requestData['type'] = type.name.toUpperCase();
      if (status != null) requestData['status'] = status.name.toUpperCase();
      if (scheduledDate != null) requestData['scheduledDate'] = scheduledDate.toIso8601String();
      if (actualDate != null) requestData['actualDate'] = actualDate.toIso8601String();
      if (reason != null) requestData['reason'] = reason;
      if (notes != null) requestData['notes'] = notes;
      if (symptoms != null) requestData['symptoms'] = symptoms;
      if (diagnosis != null) requestData['diagnosis'] = diagnosis;
      if (treatment != null) requestData['treatment'] = treatment;
      if (prescription != null) requestData['prescription'] = prescription;
      if (followUpInstructions != null) requestData['followUpInstructions'] = followUpInstructions;
      if (nextAppointmentDate != null) requestData['nextAppointmentDate'] = nextAppointmentDate.toIso8601String();
      if (isUrgent != null) requestData['isUrgent'] = isUrgent;

      final response = await _httpClient.put(
        '/appointments/$appointmentId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Appointment.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error updating appointment: $e');
      return null;
    }
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      final response = await _httpClient.put(
        '/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      return false;
    }
  }

  /// Reschedule appointment
  Future<Appointment?> rescheduleAppointment({
    required String appointmentId,
    required DateTime newScheduledDate,
    String? reason,
  }) async {
    try {
      final response = await _httpClient.put(
        '/appointments/$appointmentId/reschedule',
        data: {
          'newScheduledDate': newScheduledDate.toIso8601String(),
          'reason': reason,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Appointment.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error rescheduling appointment: $e');
      return null;
    }
  }

  /// Confirm appointment
  Future<bool> confirmAppointment(String appointmentId) async {
    return updateAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.confirmed,
    ) != null;
  }

  /// Mark appointment as completed
  Future<Appointment?> completeAppointment({
    required String appointmentId,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? followUpInstructions,
    DateTime? nextAppointmentDate,
  }) async {
    return updateAppointment(
      appointmentId: appointmentId,
      status: AppointmentStatus.completed,
      actualDate: DateTime.now(),
      diagnosis: diagnosis,
      treatment: treatment,
      prescription: prescription,
      followUpInstructions: followUpInstructions,
      nextAppointmentDate: nextAppointmentDate,
    );
  }

  /// Get available time slots for a facility
  Future<List<DateTime>> getAvailableTimeSlots({
    required String facilityId,
    required DateTime date,
    String? healthWorkerId,
  }) async {
    try {
      final queryParams = {
        'facilityId': facilityId,
        'date': date.toIso8601String().split('T')[0], // Date only
        if (healthWorkerId != null) 'healthWorkerId': healthWorkerId,
      };

      final response = await _httpClient.get(
        '/appointments/available-slots',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final slotsData = apiResponse.data as Map<String, dynamic>;
          final slotsList = slotsData['availableSlots'] as List<dynamic>;
          
          return slotsList
              .map((slot) => DateTime.parse(slot as String))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching available time slots: $e');
      return [];
    }
  }

  /// Get appointments for a specific user
  Future<List<Appointment>> getUserAppointments(String userId) async {
    return getAppointments(userId: userId);
  }

  /// Get today's appointments
  Future<List<Appointment>> getTodaysAppointments() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return getAppointments(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get upcoming appointments (next 7 days)
  Future<List<Appointment>> getUpcomingAppointments() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return getAppointments(
      startDate: now,
      endDate: nextWeek,
    );
  }

  /// Search appointments
  Future<List<Appointment>> searchAppointments(String query) async {
    try {
      final response = await _httpClient.get(
        '/appointments/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final appointmentsData = apiResponse.data as Map<String, dynamic>;
          final appointmentsList = appointmentsData['appointments'] as List<dynamic>;
          
          return appointmentsList
              .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching appointments: $e');
      return [];
    }
  }
}
