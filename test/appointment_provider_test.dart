import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ubuzima_app/core/models/appointment.dart';
import 'package:ubuzima_app/core/models/time_slot.dart';
import 'package:ubuzima_app/core/models/user.dart';
import 'package:ubuzima_app/core/providers/appointment_provider.dart';
import 'package:ubuzima_app/core/providers/auth_provider.dart';
import 'package:ubuzima_app/core/services/appointment_service.dart';

// Generate mock classes
@GenerateMocks([AppointmentService])
import 'appointment_provider_test.mocks.dart';

void main() {
  late MockAppointmentService mockAppointmentService;
  late ProviderContainer container;
  late User testPatient;
  late User testHealthWorker;

  // Sample data
  final testAppointments = [
    Appointment(
      id: 1,
      userId: 101,
      healthFacilityId: 201,
      healthWorkerId: 301,
      appointmentType: 'CONSULTATION',
      status: 'SCHEDULED',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      reason: 'Regular checkup',
      healthWorkerName: 'Dr. Smith',
      facilityName: 'Central Hospital',
    ),
    Appointment(
      id: 2,
      userId: 101,
      healthFacilityId: 201,
      healthWorkerId: 302,
      appointmentType: 'FOLLOW_UP',
      status: 'COMPLETED',
      scheduledDate: DateTime.now().subtract(const Duration(days: 5)),
      reason: 'Follow-up visit',
      healthWorkerName: 'Dr. Johnson',
      facilityName: 'Central Hospital',
    ),
  ];

  final testTimeSlots = [
    TimeSlot(
      id: 1,
      healthFacilityId: 201,
      healthWorkerId: 301,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      isAvailable: true,
      maxAppointments: 3,
      currentAppointments: 1,
    ),
    TimeSlot(
      id: 2,
      healthFacilityId: 201,
      healthWorkerId: 301,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      isAvailable: true,
      maxAppointments: 3,
      currentAppointments: 0,
    ),
  ];

  setUp(() {
    mockAppointmentService = MockAppointmentService();
    
    // Create test users
    testPatient = User(
      id: 101,
      name: 'Test Patient',
      email: 'patient@test.com',
      role: 'CLIENT',
    );
    
    testHealthWorker = User(
      id: 301,
      name: 'Dr. Smith',
      email: 'doctor@test.com',
      role: 'HEALTH_WORKER',
    );

    // Setup mock container with overrides
    container = ProviderContainer(
      overrides: [
        appointmentServiceProvider.overrideWithValue(mockAppointmentService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AppointmentNotifier Tests', () {
    test('Initial state should be empty', () {
      final state = container.read(appointmentProvider);
      expect(state.appointments, isEmpty);
      expect(state.timeSlots, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('loadAppointments should update state for patient role', () async {
      // Setup auth provider with patient user
      container = ProviderContainer(
        overrides: [
          appointmentServiceProvider.overrideWithValue(mockAppointmentService),
          currentUserProvider.overrideWithValue(testPatient),
        ],
      );

      // Setup mock response
      when(mockAppointmentService.getAppointments(
        status: anyNamed('status'),
        date: anyNamed('date'),
        page: anyNamed('page'),
        size: anyNamed('size'),
      )).thenAnswer((_) async => testAppointments);

      // Call the method
      await container.read(appointmentProvider.notifier).loadAppointments();

      // Verify state
      final state = container.read(appointmentProvider);
      expect(state.appointments, equals(testAppointments));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);

      // Verify the correct method was called
      verify(mockAppointmentService.getAppointments(
        status: anyNamed('status'),
        date: anyNamed('date'),
        page: anyNamed('page'),
        size: anyNamed('size'),
      )).called(1);
    });

    test('loadAppointments should update state for health worker role', () async {
      // Setup auth provider with health worker user
      container = ProviderContainer(
        overrides: [
          appointmentServiceProvider.overrideWithValue(mockAppointmentService),
          currentUserProvider.overrideWithValue(testHealthWorker),
        ],
      );

      // Setup mock response
      when(mockAppointmentService.getHealthWorkerAppointments(
        testHealthWorker.id,
        status: anyNamed('status'),
        date: anyNamed('date'),
      )).thenAnswer((_) async => testAppointments);

      // Call the method
      await container.read(appointmentProvider.notifier).loadAppointments();

      // Verify state
      final state = container.read(appointmentProvider);
      expect(state.appointments, equals(testAppointments));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);

      // Verify the correct method was called
      verify(mockAppointmentService.getHealthWorkerAppointments(
        testHealthWorker.id,
        status: anyNamed('status'),
        date: anyNamed('date'),
      )).called(1);
    });

    test('loadTimeSlots should update state', () async {
      // Setup mock response
      when(mockAppointmentService.getTimeSlots(
        healthWorkerId: anyNamed('healthWorkerId'),
        healthFacilityId: anyNamed('healthFacilityId'),
        date: anyNamed('date'),
        isAvailable: anyNamed('isAvailable'),
        page: anyNamed('page'),
        size: anyNamed('size'),
      )).thenAnswer((_) async => testTimeSlots);

      // Call the method
      await container.read(appointmentProvider.notifier).loadTimeSlots(
        healthWorkerId: testHealthWorker.id,
      );

      // Verify state
      final state = container.read(appointmentProvider);
      expect(state.timeSlots, equals(testTimeSlots));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);

      // Verify the correct method was called
      verify(mockAppointmentService.getTimeSlots(
        healthWorkerId: testHealthWorker.id,
        healthFacilityId: anyNamed('healthFacilityId'),
        date: anyNamed('date'),
        isAvailable: anyNamed('isAvailable'),
        page: anyNamed('page'),
        size: anyNamed('size'),
      )).called(1);
    });

    test('createAppointment should add appointment to state', () async {
      final newAppointment = Appointment(
        id: 3,
        userId: 101,
        healthFacilityId: 201,
        healthWorkerId: 301,
        appointmentType: 'CONSULTATION',
        status: 'SCHEDULED',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        reason: 'New patient visit',
      );

      // Setup mock response
      when(mockAppointmentService.createAppointment(
        healthFacilityId: anyNamed('healthFacilityId'),
        healthWorkerId: anyNamed('healthWorkerId'),
        appointmentType: anyNamed('appointmentType'),
        scheduledDate: anyNamed('scheduledDate'),
        durationMinutes: anyNamed('durationMinutes'),
        reason: anyNamed('reason'),
        notes: anyNamed('notes'),
      )).thenAnswer((_) async => newAppointment);

      // Initialize with existing appointments
      container.read(appointmentProvider.notifier).state = 
          container.read(appointmentProvider).copyWith(
            appointments: testAppointments,
          );

      // Call the method
      final result = await container.read(appointmentProvider.notifier).createAppointment(
        healthFacilityId: 201,
        healthWorkerId: 301,
        appointmentType: 'CONSULTATION',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        reason: 'New patient visit',
      );

      // Verify result
      expect(result, isTrue);

      // Verify state
      final state = container.read(appointmentProvider);
      expect(state.appointments.length, equals(testAppointments.length + 1));
      expect(state.appointments.last, equals(newAppointment));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    // Add more tests for other methods as needed
  });
}
