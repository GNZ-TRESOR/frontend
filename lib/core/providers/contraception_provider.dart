import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contraception_method.dart';
import '../models/side_effect_report.dart';
import '../services/api_service.dart';

/// Contraception state
class ContraceptionState {
  final List<ContraceptionMethod> availableMethods;
  final List<ContraceptionMethod> userMethods;
  final List<SideEffectReport> sideEffects;
  final bool isLoading;
  final String? error;

  ContraceptionState({
    this.availableMethods = const [],
    this.userMethods = const [],
    this.sideEffects = const [],
    this.isLoading = false,
    this.error,
  });

  ContraceptionState copyWith({
    List<ContraceptionMethod>? availableMethods,
    List<ContraceptionMethod>? userMethods,
    List<SideEffectReport>? sideEffects,
    bool? isLoading,
    String? error,
  }) {
    return ContraceptionState(
      availableMethods: availableMethods ?? this.availableMethods,
      userMethods: userMethods ?? this.userMethods,
      sideEffects: sideEffects ?? this.sideEffects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get active contraception methods
  List<ContraceptionMethod> get activeMethods {
    return userMethods.where((method) => method.isActive == true).toList();
  }
}

/// Contraception provider using Riverpod
class ContraceptionNotifier extends StateNotifier<ContraceptionState> {
  ContraceptionNotifier() : super(ContraceptionState());

  final ApiService _apiService = ApiService.instance;

  /// Load available contraception methods
  Future<void> loadContraceptionMethods() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAvailableContraceptionMethods();

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final methods =
            (data['methods'] as List<dynamic>)
                .map(
                  (json) => ContraceptionMethod.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();

        state = state.copyWith(availableMethods: methods, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load contraception methods',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load contraception methods: $e',
      );
    }
  }

  /// Load user's contraception methods
  Future<void> loadUserContraception() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getUserContraception();

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final methods =
            (data['methods'] as List<dynamic>)
                .map(
                  (json) => ContraceptionMethod.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();

        state = state.copyWith(userMethods: methods, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load user contraception',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user contraception: $e',
      );
    }
  }

  /// Load side effects
  Future<void> loadSideEffects() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getUserSideEffects(
        1,
      ); // Add userId parameter

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final effects =
            (data['sideEffects'] as List<dynamic>)
                .map(
                  (json) =>
                      SideEffectReport.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        state = state.copyWith(sideEffects: effects, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load side effects',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load side effects: $e',
      );
    }
  }

  /// Initialize for health worker
  Future<void> initializeForHealthWorker() async {
    await loadContraceptionMethods();
    await loadSideEffects();
  }

  /// Initialize for user
  Future<void> initializeForUser({required int userId}) async {
    await loadUserContraception();
    await loadSideEffects();
  }

  /// Add contraception method
  Future<void> addMethod(ContraceptionMethod method) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createContraceptionRecord({
        'name': method.name,
        'type': method.type,
        'startDate':
            method.startDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'isActive': method.isActive ?? true,
      });

      if (response.success) {
        await loadUserContraception();
        await loadContraceptionMethods();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to add contraception method',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add contraception method: $e',
      );
    }
  }

  /// Update contraception method
  Future<void> updateMethod(ContraceptionMethod method) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updateContraceptionRecord(method.id, {
        'name': method.name,
        'type': method.type,
        'startDate':
            method.startDate?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'isActive': method.isActive ?? true,
      });

      if (response.success) {
        await loadUserContraception();
        await loadContraceptionMethods();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update contraception method',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update contraception method: $e',
      );
    }
  }

  /// Prescribe method for health worker
  Future<void> prescribeMethod(int methodId, int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createContraceptionRecord({
        'methodId': methodId,
        'userId': userId,
        'startDate': DateTime.now().toIso8601String(),
        'isActive': true,
      });

      if (response.success) {
        await loadContraceptionMethods();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to prescribe contraception method',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to prescribe contraception method: $e',
      );
    }
  }

  /// Add side effect
  Future<void> addSideEffect(SideEffectReport sideEffect) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createSideEffectReport({
        'contraceptionMethodId': sideEffect.contraceptionMethodId,
        'symptom': sideEffect.symptom,
        'severity': sideEffect.severity,
        'notes': sideEffect.notes,
        'reportedDate': sideEffect.reportedDate.toIso8601String(),
      });

      if (response.success) {
        await loadSideEffects();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to add side effect',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add side effect: $e',
      );
    }
  }

  /// Get all users (for health worker)
  Future<void> getAllUsers() async {
    // This would typically load all users for health worker view
    // For now, we'll just reload the methods
    await loadContraceptionMethods();
  }

  /// Toggle method active state
  Future<void> toggleMethodActiveState({
    required int methodId,
    required int userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updateContraceptionRecord(methodId, {
        'isActive': false, // Toggle to inactive
      });

      if (response.success) {
        await loadUserContraception();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to toggle method state',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle method state: $e',
      );
    }
  }

  /// Delete method
  Future<void> deleteMethod({
    required int methodId,
    required int userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.deleteContraceptionRecord(methodId);

      if (response.success) {
        await loadUserContraception();
        await loadContraceptionMethods();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete method',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete method: $e',
      );
    }
  }

  /// Report side effect
  Future<void> reportSideEffect(SideEffectReport sideEffect) async {
    await addSideEffect(sideEffect);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Contraception provider
final contraceptionProvider =
    StateNotifierProvider<ContraceptionNotifier, ContraceptionState>((ref) {
      return ContraceptionNotifier();
    });

/// Available contraception methods provider
final availableContraceptionMethodsProvider =
    Provider<AsyncValue<List<ContraceptionMethod>>>((ref) {
      final state = ref.watch(contraceptionProvider);
      return AsyncValue.data(state.availableMethods);
    });

/// User contraception methods provider
final userContraceptionProvider =
    Provider<AsyncValue<List<ContraceptionMethod>>>((ref) {
      final state = ref.watch(contraceptionProvider);
      return AsyncValue.data(state.userMethods);
    });

/// Side effects provider
final sideEffectsProvider = Provider<AsyncValue<List<SideEffectReport>>>((ref) {
  final state = ref.watch(contraceptionProvider);
  return AsyncValue.data(state.sideEffects);
});

/// Active contraception method provider
final activeContraceptionMethodProvider = Provider<ContraceptionMethod?>((ref) {
  final userMethods = ref.watch(userContraceptionProvider);
  return userMethods.when(
    data: (methods) {
      try {
        return methods.firstWhere((method) => method.isActive == true);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
