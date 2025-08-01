import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/side_effect.dart';
import '../services/side_effects_service.dart';

/// Side Effects State
class SideEffectsState {
  final List<SideEffectReport> userReports;
  final List<SideEffectReport> allReports;
  final List<SideEffectReport> methodReports;
  final List<String> commonSideEffects;
  final bool isLoading;
  final String? error;

  const SideEffectsState({
    this.userReports = const [],
    this.allReports = const [],
    this.methodReports = const [],
    this.commonSideEffects = const [],
    this.isLoading = false,
    this.error,
  });

  SideEffectsState copyWith({
    List<SideEffectReport>? userReports,
    List<SideEffectReport>? allReports,
    List<SideEffectReport>? methodReports,
    List<String>? commonSideEffects,
    bool? isLoading,
    String? error,
  }) {
    return SideEffectsState(
      userReports: userReports ?? this.userReports,
      allReports: allReports ?? this.allReports,
      methodReports: methodReports ?? this.methodReports,
      commonSideEffects: commonSideEffects ?? this.commonSideEffects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Side Effects State Notifier
class SideEffectsNotifier extends StateNotifier<SideEffectsState> {
  final SideEffectsService _sideEffectsService;

  SideEffectsNotifier(this._sideEffectsService) : super(const SideEffectsState());

  /// Load user's side effect reports
  Future<void> loadUserSideEffects({required int userId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final reports = await _sideEffectsService.getUserSideEffects(userId: userId);
      
      state = state.copyWith(
        userReports: reports,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load all side effect reports (Health Worker only)
  Future<void> loadAllSideEffects() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final reports = await _sideEffectsService.getAllSideEffects();
      
      state = state.copyWith(
        allReports: reports,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load side effect reports for a specific method
  Future<void> loadMethodSideEffects({required int methodId}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final reports = await _sideEffectsService.getMethodSideEffects(methodId: methodId);
      
      state = state.copyWith(
        methodReports: reports,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load common side effects for a method type
  Future<void> loadCommonSideEffects(String methodType) async {
    try {
      final commonEffects = await _sideEffectsService.getCommonSideEffects(methodType);
      
      state = state.copyWith(commonSideEffects: commonEffects);
    } catch (e) {
      // Silently fail for common side effects as they're not critical
      state = state.copyWith(commonSideEffects: []);
    }
  }

  /// Create a new side effect report
  Future<bool> createSideEffectReport(SideEffectReport report) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _sideEffectsService.createSideEffectReport(report);
      
      if (success) {
        // Refresh user reports to include the new one
        await loadUserSideEffects(userId: report.userId);
      } else {
        state = state.copyWith(
          error: 'Failed to create side effect report',
          isLoading: false,
        );
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Update a side effect report
  Future<bool> updateSideEffectReport(int reportId, SideEffectReport report) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _sideEffectsService.updateSideEffectReport(reportId, report);
      
      if (success) {
        // Refresh user reports to reflect the update
        await loadUserSideEffects(userId: report.userId);
      } else {
        state = state.copyWith(
          error: 'Failed to update side effect report',
          isLoading: false,
        );
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Delete a side effect report
  Future<bool> deleteSideEffectReport(int reportId, int userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _sideEffectsService.deleteSideEffectReport(reportId);
      
      if (success) {
        // Refresh user reports to reflect the deletion
        await loadUserSideEffects(userId: userId);
      } else {
        state = state.copyWith(
          error: 'Failed to delete side effect report',
          isLoading: false,
        );
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all data
  Future<void> refresh({int? userId, bool isHealthWorker = false}) async {
    if (userId != null) {
      await loadUserSideEffects(userId: userId);
    }
    
    if (isHealthWorker) {
      await loadAllSideEffects();
    }
  }
}

/// Provider for Side Effects State
final sideEffectsProvider = StateNotifierProvider<SideEffectsNotifier, SideEffectsState>((ref) {
  final sideEffectsService = ref.read(sideEffectsServiceProvider);
  return SideEffectsNotifier(sideEffectsService);
});
