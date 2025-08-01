import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contraception_method.dart';
import '../services/contraception_service.dart';

/// Contraception State
class ContraceptionState {
  final List<ContraceptionMethod> userMethods;
  final ContraceptionMethod? activeMethod;
  final List<String> contraceptionTypes;
  final Map<String, List<ContraceptionMethod>>
  allUsersAndMethods; // For health workers
  final bool isLoading;
  final String? error;

  const ContraceptionState({
    this.userMethods = const [],
    this.activeMethod,
    this.contraceptionTypes = const [],
    this.allUsersAndMethods = const {},
    this.isLoading = false,
    this.error,
  });

  ContraceptionState copyWith({
    List<ContraceptionMethod>? userMethods,
    ContraceptionMethod? activeMethod,
    List<String>? contraceptionTypes,
    Map<String, List<ContraceptionMethod>>? allUsersAndMethods,
    bool? isLoading,
    String? error,
  }) {
    return ContraceptionState(
      userMethods: userMethods ?? this.userMethods,
      activeMethod: activeMethod ?? this.activeMethod,
      contraceptionTypes: contraceptionTypes ?? this.contraceptionTypes,
      allUsersAndMethods: allUsersAndMethods ?? this.allUsersAndMethods,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get active user methods
  List<ContraceptionMethod> get activeMethods {
    return userMethods.where((method) => method.isActive == true).toList();
  }

  /// Get inactive user methods
  List<ContraceptionMethod> get inactiveMethods {
    return userMethods.where((method) => method.isActive != true).toList();
  }
}

/// Contraception Notifier
class ContraceptionNotifier extends StateNotifier<ContraceptionState> {
  final ContraceptionService _contraceptionService;

  ContraceptionNotifier(this._contraceptionService)
    : super(const ContraceptionState());

  /// Initialize contraception data for users
  Future<void> initializeForUser({required int userId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load user methods
      final userMethods = await _contraceptionService.getUserMethods(
        userId: userId,
      );

      // Load active method
      final activeMethod = await _contraceptionService.getActiveMethod(
        userId: userId,
      );

      // Load contraception types
      final contraceptionTypes =
          await _contraceptionService.getContraceptionTypes();

      state = state.copyWith(
        userMethods: userMethods,
        activeMethod: activeMethod,
        contraceptionTypes: contraceptionTypes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Initialize contraception data for health workers
  Future<void> initializeForHealthWorker() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all users and their methods
      final allUsersAndMethods =
          await _contraceptionService.getAllUsersAndMethods();

      // Load contraception types
      final contraceptionTypes =
          await _contraceptionService.getContraceptionTypes();

      state = state.copyWith(
        allUsersAndMethods: allUsersAndMethods,
        contraceptionTypes: contraceptionTypes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Refresh data
  Future<void> refresh({int? userId, bool isHealthWorker = false}) async {
    if (isHealthWorker) {
      await initializeForHealthWorker();
    } else if (userId != null) {
      await initializeForUser(userId: userId);
    }
  }

  /// Prescribe contraception method (Health Worker)
  Future<bool> prescribeMethod({
    required int userId,
    required ContraceptionType type,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? effectiveness,
    String? instructions,
    String? prescribedBy,
    DateTime? nextAppointment,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.prescribeMethod(
        userId: userId,
        type: type,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        effectiveness: effectiveness,
        instructions: instructions,
        prescribedBy: prescribedBy,
        nextAppointment: nextAppointment,
      );

      if (success) {
        // Refresh data to show the new method
        await refresh(isHealthWorker: true);
      } else {
        state = state.copyWith(
          error: 'Failed to prescribe contraception method',
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Update contraception method
  Future<bool> updateMethod(
    int methodId,
    ContraceptionMethod method, {
    int? userId,
    bool isHealthWorker = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.updateMethod(
        methodId,
        method,
      );

      if (success) {
        // Refresh data to show the updated method
        await refresh(userId: userId, isHealthWorker: isHealthWorker);
      } else {
        state = state.copyWith(
          error: 'Failed to update contraception method',
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Deactivate contraception method
  Future<bool> deactivateMethod(
    int methodId, {
    int? userId,
    bool isHealthWorker = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.deactivateMethod(methodId);

      if (success) {
        // Refresh data to update the method status
        await refresh(userId: userId, isHealthWorker: isHealthWorker);
      } else {
        state = state.copyWith(
          error: 'Failed to deactivate contraception method',
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Add side effect to contraception method
  Future<bool> addSideEffect(
    int methodId,
    String sideEffect, {
    int? userId,
    bool isHealthWorker = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.addSideEffect(
        methodId,
        sideEffect,
      );

      if (success) {
        // Refresh data to show the new side effect
        await refresh(userId: userId, isHealthWorker: isHealthWorker);
      } else {
        state = state.copyWith(
          error: 'Failed to add side effect',
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get all users for health worker dropdown
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await _contraceptionService.getAllUsers();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // ==================== USER SELF-MANAGEMENT METHODS ====================

  /// User adds their own contraception method
  Future<bool> addMethod({
    required int userId,
    required ContraceptionType type,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? effectiveness,
    String? instructions,
    String? prescribedBy,
    DateTime? nextAppointment,
    bool? isActive,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.addMethod(
        userId: userId,
        type: type,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        effectiveness: effectiveness,
        instructions: instructions,
        prescribedBy: prescribedBy,
        nextAppointment: nextAppointment,
        isActive: isActive,
      );

      if (success) {
        // Refresh user methods after successful addition
        await initializeForUser(userId: userId);
      }

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// User toggles active state of their contraception method
  Future<bool> toggleMethodActiveState({
    required int methodId,
    required int userId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.toggleMethodActiveState(
        methodId: methodId,
        userId: userId,
      );

      if (success) {
        // Refresh user methods after successful toggle
        await initializeForUser(userId: userId);
      }

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  /// User deletes their contraception method (only if not active)
  Future<bool> deleteMethod({
    required int methodId,
    required int userId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _contraceptionService.deleteMethod(
        methodId: methodId,
        userId: userId,
      );

      if (success) {
        // Refresh user methods after successful deletion
        await initializeForUser(userId: userId);
      }

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

/// Contraception Provider
final contraceptionProvider =
    StateNotifierProvider<ContraceptionNotifier, ContraceptionState>((ref) {
      final contraceptionService = ref.watch(contraceptionServiceProvider);
      return ContraceptionNotifier(contraceptionService);
    });

/// Specific providers for different data
final userMethodsProvider = Provider<List<ContraceptionMethod>>((ref) {
  final contraceptionState = ref.watch(contraceptionProvider);
  return contraceptionState.userMethods;
});

final activeMethodProvider = Provider<ContraceptionMethod?>((ref) {
  final contraceptionState = ref.watch(contraceptionProvider);
  return contraceptionState.activeMethod;
});

final contraceptionTypesProvider = Provider<List<String>>((ref) {
  final contraceptionState = ref.watch(contraceptionProvider);
  return contraceptionState.contraceptionTypes;
});

final allUsersAndMethodsProvider =
    Provider<Map<String, List<ContraceptionMethod>>>((ref) {
      final contraceptionState = ref.watch(contraceptionProvider);
      return contraceptionState.allUsersAndMethods;
    });
