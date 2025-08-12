import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment.dart';
import '../models/time_slot.dart';
import '../services/appointment_service.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

/// Appointment Provider State
class AppointmentState {
  final List<Appointment> appointments;
  final List<TimeSlot> timeSlots;
  final bool isLoading;
  final String? error;

  AppointmentState({
    this.appointments = const [],
    this.timeSlots = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentState copyWith({
    List<Appointment>? appointments,
    List<TimeSlot>? timeSlots,
    bool? isLoading,
    String? error,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      timeSlots: timeSlots ?? this.timeSlots,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Appointment Provider
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final AppointmentService _appointmentService;
  final Ref _ref;

  AppointmentNotifier(this._appointmentService, this._ref)
    : super(AppointmentState());

  // ==================== APPOINTMENT OPERATIONS ====================

  /// Load appointments based on user role
  Future<void> loadAppointments({
    String? status,
    String? date,
    int page = 0,
    int size = 20,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(currentUserProvider);
      List<Appointment> appointments;

      if (user?.role == 'HEALTH_WORKER' && user?.id != null) {
        // Load health worker appointments
        appointments = await _appointmentService.getHealthWorkerAppointments(
          user!.id!,
          status: status,
          date: date,
        );
      } else {
        // Load patient appointments
        appointments = await _appointmentService.getAppointments(
          status: status,
          date: date,
          page: page,
          size: size,
        );
      }

      print('DEBUG: Provider loaded ${appointments.length} appointments');
      state = state.copyWith(appointments: appointments, isLoading: false);
      print(
        'DEBUG: Provider state now has ${state.appointments.length} appointments',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create new appointment
  Future<bool> createAppointment({
    required int healthFacilityId,
    int? healthWorkerId,
    required String appointmentType,
    required DateTime scheduledDate,
    int? durationMinutes,
    String? reason,
    String? notes,
  }) async {
    try {
      final appointment = await _appointmentService.createAppointment(
        healthFacilityId: healthFacilityId,
        healthWorkerId: healthWorkerId,
        appointmentType: appointmentType,
        scheduledDate: scheduledDate,
        durationMinutes: durationMinutes,
        reason: reason,
        notes: notes,
      );

      // Add to current appointments list
      final updatedAppointments = [...state.appointments, appointment];
      state = state.copyWith(appointments: updatedAppointments);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update appointment
  Future<bool> updateAppointment(
    int appointmentId, {
    String? appointmentType,
    DateTime? scheduledDate,
    int? durationMinutes,
    String? reason,
    String? notes,
    String? status,
  }) async {
    try {
      final updatedAppointment = await _appointmentService.updateAppointment(
        appointmentId,
        appointmentType: appointmentType,
        scheduledDate: scheduledDate,
        durationMinutes: durationMinutes,
        reason: reason,
        notes: notes,
        status: status,
      );

      // Update in current appointments list
      final updatedAppointments =
          state.appointments.map((appointment) {
            return appointment.id == appointmentId
                ? updatedAppointment
                : appointment;
          }).toList();

      state = state.copyWith(appointments: updatedAppointments);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update appointment status (health worker only)
  Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final success = await _appointmentService.updateAppointmentStatus(
        appointmentId,
        status,
      );

      if (success) {
        // Update status in current appointments list
        final updatedAppointments =
            state.appointments.map((appointment) {
              if (appointment.id == appointmentId) {
                return appointment.copyWith(status: status);
              }
              return appointment;
            }).toList();

        state = state.copyWith(appointments: updatedAppointments);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(int appointmentId, String? reason) async {
    try {
      final success = await _appointmentService.cancelAppointment(
        appointmentId,
        reason,
      );

      if (success) {
        // Update status in current appointments list
        final updatedAppointments =
            state.appointments.map((appointment) {
              if (appointment.id == appointmentId) {
                return appointment.copyWith(
                  status: 'CANCELLED',
                  cancelledAt: DateTime.now(),
                  cancellationReason: reason,
                );
              }
              return appointment;
            }).toList();

        state = state.copyWith(appointments: updatedAppointments);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete appointment
  Future<bool> deleteAppointment(int appointmentId) async {
    try {
      final success = await _appointmentService.deleteAppointment(
        appointmentId,
      );

      if (success) {
        // Remove from current appointments list
        final updatedAppointments =
            state.appointments
                .where((appointment) => appointment.id != appointmentId)
                .toList();

        state = state.copyWith(appointments: updatedAppointments);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reschedule appointment
  Future<bool> rescheduleAppointment(
    int appointmentId,
    DateTime newScheduledDate,
  ) async {
    try {
      final updatedAppointment = await _appointmentService
          .rescheduleAppointment(appointmentId, newScheduledDate);

      // Update in current appointments list
      final updatedAppointments =
          state.appointments.map((appointment) {
            return appointment.id == appointmentId
                ? updatedAppointment
                : appointment;
          }).toList();

      state = state.copyWith(appointments: updatedAppointments);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // ==================== TIME SLOT OPERATIONS ====================

  /// Load time slots (health worker only)
  Future<void> loadTimeSlots({
    int? healthWorkerId,
    int? healthFacilityId,
    String? date,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final timeSlots = await _appointmentService.getTimeSlots(
        healthWorkerId: healthWorkerId,
        healthFacilityId: healthFacilityId,
        date: date,
        isAvailable: isAvailable,
        page: page,
        size: size,
      );

      state = state.copyWith(timeSlots: timeSlots, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Get available time slots for booking
  Future<List<TimeSlot>> getAvailableTimeSlots({
    required int healthFacilityId,
    int? healthWorkerId,
    required String date,
  }) async {
    try {
      return await _appointmentService.getAvailableTimeSlots(
        healthFacilityId: healthFacilityId,
        healthWorkerId: healthWorkerId,
        date: date,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Create time slot (health worker only)
  Future<bool> createTimeSlot({
    required int healthFacilityId,
    required int healthWorkerId,
    required DateTime startTime,
    required DateTime endTime,
    bool isAvailable = true,
    String? reason,
    int maxAppointments = 1,
  }) async {
    try {
      final timeSlot = await _appointmentService.createTimeSlot(
        healthFacilityId: healthFacilityId,
        healthWorkerId: healthWorkerId,
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
        reason: reason,
        maxAppointments: maxAppointments,
      );

      // Add to current time slots list
      final updatedTimeSlots = <TimeSlot>[...state.timeSlots, timeSlot];
      state = state.copyWith(timeSlots: updatedTimeSlots);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update time slot (health worker only)
  Future<bool> updateTimeSlot(
    int timeSlotId, {
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    String? reason,
    int? maxAppointments,
  }) async {
    try {
      final updatedTimeSlot = await _appointmentService.updateTimeSlot(
        timeSlotId,
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
        reason: reason,
        maxAppointments: maxAppointments,
      );

      // Update in current time slots list
      final updatedTimeSlots =
          state.timeSlots.map<TimeSlot>((timeSlot) {
            return timeSlot.id == timeSlotId ? updatedTimeSlot : timeSlot;
          }).toList();

      state = state.copyWith(timeSlots: updatedTimeSlots);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete time slot (health worker only)
  Future<bool> deleteTimeSlot(int timeSlotId) async {
    try {
      final success = await _appointmentService.deleteTimeSlot(timeSlotId);

      if (success) {
        // Remove from current time slots list
        final updatedTimeSlots =
            state.timeSlots
                .where((timeSlot) => timeSlot.id != timeSlotId)
                .toList();

        state = state.copyWith(timeSlots: updatedTimeSlots);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadAppointments();

    final user = _ref.read(currentUserProvider);
    if (user?.role == 'HEALTH_WORKER' && user?.id != null) {
      await loadTimeSlots(healthWorkerId: user!.id!);
    }
  }
}

// ==================== PROVIDERS ====================

/// Appointment Service Provider
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  // Use the singleton instance of ApiService
  final apiService = ApiService.instance;
  return AppointmentService(apiService);
});

/// Appointment Provider
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
      final appointmentService = ref.read(appointmentServiceProvider);
      return AppointmentNotifier(appointmentService, ref);
    });

/// Convenience providers for specific data
final appointmentsListProvider = Provider<List<Appointment>>((ref) {
  return ref.watch(appointmentProvider).appointments;
});

final timeSlotsListProvider = Provider<List<TimeSlot>>((ref) {
  return ref.watch(appointmentProvider).timeSlots;
});

final appointmentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appointmentProvider).isLoading;
});

final appointmentErrorProvider = Provider<String?>((ref) {
  return ref.watch(appointmentProvider).error;
});
