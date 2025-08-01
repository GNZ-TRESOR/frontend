import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/health_record.dart';
import '../models/health_worker.dart';
import '../models/menstrual_cycle.dart';
import '../models/medication.dart';
import '../models/appointment.dart';
import '../models/community_event.dart';

/// Health state for managing all health-related data
class HealthState {
  final List<HealthRecord> healthRecords;
  final List<HealthWorker> healthWorkers;
  final List<MenstrualCycle> menstrualCycles;
  final List<Medication> medications;
  final List<Appointment> appointments;
  final bool isLoading;
  final String? error;

  HealthState({
    this.healthRecords = const [],
    this.healthWorkers = const [],
    this.menstrualCycles = const [],
    this.medications = const [],
    this.appointments = const [],
    this.isLoading = false,
    this.error,
  });

  HealthState copyWith({
    List<HealthRecord>? healthRecords,
    List<HealthWorker>? healthWorkers,
    List<MenstrualCycle>? menstrualCycles,
    List<Medication>? medications,
    List<Appointment>? appointments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    // Handle potential null state fields by providing safe defaults
    try {
      return HealthState(
        healthRecords: healthRecords ?? this.healthRecords,
        healthWorkers: healthWorkers ?? this.healthWorkers,
        menstrualCycles: menstrualCycles ?? this.menstrualCycles,
        medications: medications ?? this.medications,
        appointments: appointments ?? this.appointments,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
    } catch (e) {
      // If there's any issue with the current state, create a fresh one
      return HealthState(
        healthRecords: healthRecords ?? const [],
        healthWorkers: healthWorkers ?? const [],
        menstrualCycles: menstrualCycles ?? const [],
        medications: medications ?? const [],
        appointments: appointments ?? const [],
        isLoading: isLoading ?? false,
        error: clearError ? null : error,
      );
    }
  }
}

/// Health provider for managing all health-related data and API calls
class HealthNotifier extends StateNotifier<HealthState> {
  HealthNotifier()
    : super(
        HealthState(
          healthRecords: const [],
          healthWorkers: const [],
          menstrualCycles: const [],
          medications: const [],
          appointments: const [],
          isLoading: false,
          error: null,
        ),
      );

  final ApiService _apiService = ApiService.instance;

  /// Load all health data
  Future<void> loadAllHealthData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await Future.wait([
        loadHealthRecords(),
        loadMenstrualCycles(),
        loadMedications(),
        loadAppointments(),
      ]);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load health data: $e',
      );
    }
  }

  /// Load health records from API
  Future<void> loadHealthRecords() async {
    try {
      final response = await _apiService.getHealthRecords();
      print(
        'DEBUG: API response success: ${response.success}, data: ${response.data}',
      );

      if (response.success && response.data != null) {
        final records =
            (response.data as List<dynamic>).map((json) {
              print('DEBUG: Processing health record JSON: $json');
              return HealthRecord.fromJson(json);
            }).toList();

        print('DEBUG: Parsed ${records.length} health records');
        state = state.copyWith(healthRecords: records);
        print('DEBUG: State updated successfully');
      } else {
        print('DEBUG: API response not successful or data is null');
        // Handle 404 or other errors gracefully - no health records is a valid state
        state = state.copyWith(healthRecords: []);
      }
    } catch (e, stackTrace) {
      print('DEBUG: Exception in loadHealthRecords: $e');
      print('DEBUG: Stack trace: $stackTrace');
      // Handle network errors gracefully - set empty list and log error
      state = state.copyWith(
        healthRecords: [],
        error: 'Error loading health records: $e',
      );
      // Don't rethrow - let the UI handle the empty state gracefully
    }
  }

  /// Create health record
  Future<bool> createHealthRecord(HealthRecord record) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.createHealthRecord(record.toJson());

      if (response.success) {
        await loadHealthRecords(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create health record',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating health record: $e',
      );
      return false;
    }
  }

  /// Update health record
  Future<bool> updateHealthRecord(HealthRecord record) async {
    if (record.id == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.updateHealthRecord(
        record.id!,
        record.toJson(),
      );

      if (response.success) {
        await loadHealthRecords(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update health record',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error updating health record: $e',
      );
      return false;
    }
  }

  /// Delete health record
  Future<bool> deleteHealthRecord(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.deleteHealthRecord(id);

      if (response.success) {
        await loadHealthRecords(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete health record',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error deleting health record: $e',
      );
      return false;
    }
  }

  /// Load health workers from API
  Future<void> loadHealthWorkers() async {
    try {
      final response = await _apiService.getHealthWorkers();

      if (response.success && response.data != null) {
        final List<dynamic> workersData = response.data;
        final healthWorkers =
            workersData.map((data) => HealthWorker.fromJson(data)).toList();

        state = state.copyWith(healthWorkers: healthWorkers);
      }
    } catch (e) {
      // Silently fail - health workers are optional
      print('Error loading health workers: $e');
    }
  }

  /// Load menstrual cycles from API
  Future<void> loadMenstrualCycles() async {
    try {
      final response = await _apiService.getMenstrualCycles();

      if (response.success && response.data != null) {
        final cycles =
            (response.data as List<dynamic>)
                .map((json) => MenstrualCycle.fromJson(json))
                .toList();

        state = state.copyWith(menstrualCycles: cycles);
      } else {
        // Handle 404 or other errors gracefully - no menstrual cycles is a valid state
        state = state.copyWith(menstrualCycles: []);
      }
    } catch (e) {
      // Handle network errors gracefully - set empty list and log error
      state = state.copyWith(
        menstrualCycles: [],
        error: 'Error loading menstrual cycles: $e',
      );
      // Don't rethrow - let the UI handle the empty state gracefully
    }
  }

  /// Create menstrual cycle
  Future<bool> createMenstrualCycle(MenstrualCycle cycle) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.createMenstrualCycle(cycle.toJson());

      if (response.success) {
        await loadMenstrualCycles(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create menstrual cycle',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating menstrual cycle: $e',
      );
      return false;
    }
  }

  /// Add symptom to menstrual cycle
  Future<bool> addSymptomToCycle(int cycleId, String symptom) async {
    try {
      final response = await _apiService.addSymptomToCycle(cycleId, symptom);

      if (response.success) {
        await loadMenstrualCycles(); // Refresh the list to get updated symptoms
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to add symptom',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error adding symptom: $e');
      return false;
    }
  }

  /// Remove symptom from menstrual cycle
  Future<bool> removeSymptomFromCycle(int cycleId, String symptom) async {
    try {
      final response = await _apiService.removeSymptomFromCycle(
        cycleId,
        symptom,
      );

      if (response.success) {
        await loadMenstrualCycles(); // Refresh the list to get updated symptoms
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to remove symptom',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error removing symptom: $e');
      return false;
    }
  }

  /// Load medications from API
  Future<void> loadMedications() async {
    try {
      final response = await _apiService.getMedications();

      if (response.success && response.data != null) {
        final medications =
            (response.data as List<dynamic>)
                .map((json) => Medication.fromJson(json))
                .toList();

        state = state.copyWith(medications: medications);
      } else {
        // Handle 404 or other errors gracefully - no medications is a valid state
        state = state.copyWith(medications: []);
      }
    } catch (e) {
      // Handle network errors gracefully - set empty list and log error
      state = state.copyWith(
        medications: [],
        error: 'Error loading medications: $e',
      );
      // Don't rethrow - let the UI handle the empty state gracefully
    }
  }

  /// Create medication
  Future<bool> createMedication(Medication medication) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.createMedication(medication.toJson());

      if (response.success) {
        await loadMedications(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create medication',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating medication: $e',
      );
      return false;
    }
  }

  /// Delete medication
  Future<bool> deleteMedication(int medicationId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.deleteMedication(medicationId);

      if (response.success) {
        await loadMedications(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete medication',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error deleting medication: $e',
      );
      return false;
    }
  }

  /// Load appointments from API
  Future<void> loadAppointments() async {
    try {
      final response = await _apiService.getAppointments();

      if (response.success && response.data != null) {
        final appointments =
            (response.data as List<dynamic>)
                .map((json) => Appointment.fromJson(json))
                .toList();

        state = state.copyWith(appointments: appointments);
      } else {
        // Handle 404 or other errors gracefully - no appointments is a valid state
        state = state.copyWith(appointments: []);
      }
    } catch (e) {
      // Handle network errors gracefully - set empty list and log error
      state = state.copyWith(
        appointments: [],
        error: 'Error loading appointments: $e',
      );
      // Don't rethrow - let the UI handle the empty state gracefully
    }
  }

  /// Create appointment
  Future<bool> createAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.createAppointment(
        appointment.toJson(),
      );

      if (response.success) {
        await loadAppointments(); // Refresh the list
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create appointment',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating appointment: $e',
      );
      return false;
    }
  }

  /// Get current menstrual cycle
  MenstrualCycle? get currentMenstrualCycle {
    if (state.menstrualCycles.isEmpty) return null;

    // Sort by start date and get the most recent
    final sortedCycles = List<MenstrualCycle>.from(state.menstrualCycles)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sortedCycles.first;
  }

  /// Get next period prediction
  DateTime? get nextPeriodPrediction {
    final current = currentMenstrualCycle;
    if (current == null) return null;

    // Simple prediction: add average cycle length to start date
    return current.startDate.add(Duration(days: current.cycleLength ?? 28));
  }

  /// Get upcoming appointments
  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return state.appointments
        .where((appointment) => appointment.appointmentDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  /// Get active medications
  List<Medication> get activeMedications {
    return state.medications
        .where((medication) => medication.isActive)
        .toList();
  }

  /// Clear all data
  void clearAllData() {
    state = HealthState(
      healthRecords: const [],
      healthWorkers: const [],
      menstrualCycles: const [],
      medications: const [],
      appointments: const [],
      isLoading: false,
      error: null,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ==================== COMMUNITY EVENTS METHODS ====================

  /// Get community events
  Future<List<CommunityEvent>> getCommunityEvents({
    String? category,
    String? status,
  }) async {
    try {
      final response = await _apiService.getCommunityEvents(
        category: category,
        status: status,
      );

      if (response.success && response.data != null) {
        final eventsData = response.data['events'] as List<dynamic>? ?? [];
        return eventsData
            .map(
              (json) => CommunityEvent.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      state = state.copyWith(error: 'Failed to load community events: $e');
      return [];
    }
  }

  /// Get user's registered events
  Future<List<CommunityEvent>> getMyEvents() async {
    try {
      final response = await _apiService.getMyEvents();

      if (response.success && response.data != null) {
        final eventsData = response.data['events'] as List<dynamic>? ?? [];
        return eventsData
            .map(
              (json) => CommunityEvent.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      state = state.copyWith(error: 'Failed to load my events: $e');
      return [];
    }
  }

  /// Register for an event
  Future<bool> registerForEvent(int eventId) async {
    try {
      final response = await _apiService.registerForEvent(eventId);
      return response.success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to register for event: $e');
      return false;
    }
  }

  /// Create a new community event
  Future<bool> createCommunityEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.createCommunityEvent(eventData);
      return response.success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create event: $e');
      return false;
    }
  }
}

/// Health provider
final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>((
  ref,
) {
  return HealthNotifier();
});

/// Specific providers for different health data
final healthRecordsProvider = Provider<List<HealthRecord>>((ref) {
  final healthState = ref.watch(healthProvider);
  return healthState.healthRecords;
});

final menstrualCyclesProvider = Provider<List<MenstrualCycle>>((ref) {
  final healthState = ref.watch(healthProvider);
  return healthState.menstrualCycles;
});

final medicationsProvider = Provider<List<Medication>>((ref) {
  final healthState = ref.watch(healthProvider);
  return healthState.medications;
});

final appointmentsProvider = Provider<List<Appointment>>((ref) {
  final healthState = ref.watch(healthProvider);
  return healthState.appointments;
});

final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final healthNotifier = ref.watch(healthProvider.notifier);
  return healthNotifier.upcomingAppointments;
});

final activeMedicationsProvider = Provider<List<Medication>>((ref) {
  final healthNotifier = ref.watch(healthProvider.notifier);
  return healthNotifier.activeMedications;
});

final currentMenstrualCycleProvider = Provider<MenstrualCycle?>((ref) {
  final healthNotifier = ref.watch(healthProvider.notifier);
  return healthNotifier.currentMenstrualCycle;
});

final nextPeriodPredictionProvider = Provider<DateTime?>((ref) {
  final healthNotifier = ref.watch(healthProvider.notifier);
  return healthNotifier.nextPeriodPrediction;
});
