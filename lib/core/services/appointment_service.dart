import '../models/appointment.dart';
import '../models/time_slot.dart';
import 'api_service.dart';

/// Comprehensive Appointment Service with Role-Based CRUD Operations
class AppointmentService {
  final ApiService _apiService;

  AppointmentService(this._apiService);

  // ==================== APPOINTMENT CRUD OPERATIONS ====================

  /// Get appointments for current user (role-based)
  Future<List<Appointment>> getAppointments({
    String? status,
    String? date,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiService.getAppointments(
        page: page,
        size: size,
        status: status,
        date: date,
      );

      if (response.success && response.data != null) {
        List<dynamic> appointmentsJson;
        if (response.data is Map<String, dynamic>) {
          appointmentsJson =
              response.data['data'] ?? response.data['content'] ?? [];
        } else if (response.data is List) {
          appointmentsJson = response.data;
        } else {
          appointmentsJson = [];
        }

        final appointments = <Appointment>[];
        for (int i = 0; i < appointmentsJson.length; i++) {
          try {
            final appointment = Appointment.fromJson(appointmentsJson[i]);
            appointments.add(appointment);
          } catch (e) {
            continue;
          }
        }
        return appointments;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  /// Get health worker appointments (health worker role only)
  Future<List<Appointment>> getHealthWorkerAppointments(
    int healthWorkerId, {
    String? status,
    String? date,
  }) async {
    try {
      final response = await _apiService.getHealthWorkerAppointments(
        healthWorkerId,
        status: status,
        date: date,
      );

      if (response.success && response.data != null) {
        List<dynamic> appointmentsJson;
        if (response.data is Map<String, dynamic>) {
          appointmentsJson =
              response.data['data'] ?? response.data['content'] ?? [];
        } else if (response.data is List) {
          appointmentsJson = response.data;
        } else {
          appointmentsJson = [];
        }

        return appointmentsJson
            .map((json) => Appointment.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load health worker appointments: $e');
    }
  }

  /// Create new appointment (patient role)
  Future<Appointment> createAppointment({
    required int healthFacilityId,
    int? healthWorkerId,
    required String appointmentType,
    required DateTime scheduledDate,
    int? durationMinutes,
    String? reason,
    String? notes,
  }) async {
    try {
      final userProfileResponse = await _apiService.getUserProfile();
      if (!userProfileResponse.success || userProfileResponse.data == null) {
        throw Exception('Failed to get user profile');
      }

      final userId = userProfileResponse.data['id'];
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final appointmentData = {
        'userId': userId,
        'healthFacilityId': healthFacilityId,
        'healthWorkerId': healthWorkerId,
        'appointmentType': appointmentType,
        'scheduledDate': scheduledDate.toIso8601String(),
        'durationMinutes': durationMinutes,
        'reason': reason,
        'notes': notes,
        'status': 'SCHEDULED',
      };

      final response = await _apiService.createAppointment(appointmentData);

      if (response.success && response.data != null) {
        Map<String, dynamic> appointmentJson;
        if (response.data is Map<String, dynamic>) {
          appointmentJson = response.data['appointment'] ?? response.data;
        } else {
          appointmentJson = response.data;
        }

        return Appointment.fromJson(appointmentJson);
      } else {
        throw Exception(response.message ?? 'Failed to create appointment');
      }
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  /// Update appointment (role-based permissions)
  Future<Appointment> updateAppointment(
    int appointmentId, {
    String? appointmentType,
    DateTime? scheduledDate,
    int? durationMinutes,
    String? reason,
    String? notes,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (appointmentType != null) {
        updateData['appointmentType'] = appointmentType;
      }
      if (scheduledDate != null) {
        updateData['scheduledDate'] = scheduledDate.toIso8601String();
      }
      if (durationMinutes != null) {
        updateData['durationMinutes'] = durationMinutes;
      }
      if (reason != null) updateData['reason'] = reason;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;

      final response = await _apiService.updateAppointment(
        appointmentId,
        updateData,
      );

      if (response.success && response.data != null) {
        Map<String, dynamic> appointmentJson;
        if (response.data is Map<String, dynamic>) {
          appointmentJson = response.data['appointment'] ?? response.data;
        } else {
          appointmentJson = response.data;
        }

        return Appointment.fromJson(appointmentJson);
      } else {
        throw Exception(response.message ?? 'Failed to update appointment');
      }
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  /// Update appointment status (health worker role)
  Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final response = await _apiService.updateAppointmentStatus(
        appointmentId,
        status,
      );
      return response.success;
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  /// Cancel appointment (patient and health worker roles)
  Future<bool> cancelAppointment(int appointmentId, String? reason) async {
    try {
      final response = await _apiService.deleteAppointment(
        appointmentId,
        reason: reason,
      );
      return response.success;
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  /// Delete appointment (admin role or appointment owner)
  Future<bool> deleteAppointment(int appointmentId) async {
    try {
      final response = await _apiService.deleteAppointment(appointmentId);
      return response.success;
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  /// Reschedule appointment
  Future<Appointment> rescheduleAppointment(
    int appointmentId,
    DateTime newScheduledDate,
  ) async {
    try {
      return await updateAppointment(
        appointmentId,
        scheduledDate: newScheduledDate,
      );
    } catch (e) {
      throw Exception('Failed to reschedule appointment: $e');
    }
  }

  // ==================== TIME SLOT OPERATIONS ====================

  /// Get time slots (health worker role)
  Future<List<TimeSlot>> getTimeSlots({
    int? healthWorkerId,
    int? healthFacilityId,
    String? date,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiService.getTimeSlots(
        healthWorkerId: healthWorkerId,
        healthFacilityId: healthFacilityId,
        date: date,
        isAvailable: isAvailable,
        page: page,
        size: size,
      );

      if (response.success && response.data != null) {
        List<dynamic> timeSlotsJson;
        if (response.data is Map<String, dynamic>) {
          timeSlotsJson =
              response.data['data'] ?? response.data['content'] ?? [];
        } else if (response.data is List) {
          timeSlotsJson = response.data;
        } else {
          timeSlotsJson = [];
        }

        return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load time slots: $e');
    }
  }

  /// Get available time slots for booking (patient role)
  Future<List<TimeSlot>> getAvailableTimeSlots({
    required int healthFacilityId,
    int? healthWorkerId,
    required String date,
  }) async {
    try {
      final response = await _apiService.getAvailableTimeSlots(
        healthFacilityId: healthFacilityId,
        healthWorkerId: healthWorkerId,
        date: date,
      );

      if (response.success && response.data != null) {
        List<dynamic> timeSlotsJson;
        if (response.data is Map<String, dynamic>) {
          timeSlotsJson =
              response.data['data'] ?? response.data['content'] ?? [];
        } else if (response.data is List) {
          timeSlotsJson = response.data;
        } else {
          timeSlotsJson = [];
        }

        return timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load available time slots: $e');
    }
  }

  /// Create time slot (health worker role)
  Future<TimeSlot> createTimeSlot({
    required int healthFacilityId,
    required int healthWorkerId,
    required DateTime startTime,
    required DateTime endTime,
    bool isAvailable = true,
    String? reason,
    int maxAppointments = 1,
  }) async {
    try {
      final timeSlotData = {
        'healthFacilityId': healthFacilityId,
        'healthWorkerId': healthWorkerId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'isAvailable': isAvailable,
        'reason': reason,
        'maxAppointments': maxAppointments,
        'currentAppointments': 0,
      };

      final response = await _apiService.createTimeSlot(timeSlotData);

      if (response.success && response.data != null) {
        Map<String, dynamic> timeSlotJson;
        if (response.data is Map<String, dynamic>) {
          timeSlotJson = response.data['timeSlot'] ?? response.data;
        } else {
          timeSlotJson = response.data;
        }

        return TimeSlot.fromJson(timeSlotJson);
      } else {
        throw Exception(response.message ?? 'Failed to create time slot');
      }
    } catch (e) {
      throw Exception('Failed to create time slot: $e');
    }
  }

  /// Update time slot (health worker role)
  Future<TimeSlot> updateTimeSlot(
    int timeSlotId, {
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    String? reason,
    int? maxAppointments,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (startTime != null) {
        updateData['startTime'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        updateData['endTime'] = endTime.toIso8601String();
      }
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;
      if (reason != null) updateData['reason'] = reason;
      if (maxAppointments != null) {
        updateData['maxAppointments'] = maxAppointments;
      }

      final response = await _apiService.updateTimeSlot(timeSlotId, updateData);

      if (response.success && response.data != null) {
        Map<String, dynamic> timeSlotJson;
        if (response.data is Map<String, dynamic>) {
          timeSlotJson = response.data['timeSlot'] ?? response.data;
        } else {
          timeSlotJson = response.data;
        }

        return TimeSlot.fromJson(timeSlotJson);
      } else {
        throw Exception(response.message ?? 'Failed to update time slot');
      }
    } catch (e) {
      throw Exception('Failed to update time slot: $e');
    }
  }

  /// Delete time slot (health worker role)
  Future<bool> deleteTimeSlot(int timeSlotId) async {
    try {
      final response = await _apiService.deleteTimeSlot(timeSlotId);
      return response.success;
    } catch (e) {
      throw Exception('Failed to delete time slot: $e');
    }
  }
}
