import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/side_effect.dart';
import 'api_service.dart';

/// Side Effects Service for managing side effect reports
class SideEffectsService {
  final ApiService _apiService;

  SideEffectsService(this._apiService);

  /// Get side effect reports for a specific user
  Future<List<SideEffectReport>> getUserSideEffects({
    required int userId,
  }) async {
    try {
      final response = await _apiService.getUserSideEffects(userId);

      if (response.success && response.data != null) {
        final reportsData = response.data as List<dynamic>? ?? [];
        return reportsData
            .map(
              (json) => SideEffectReport.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load user side effects: $e');
    }
  }

  /// Get side effect reports for a specific contraception method
  Future<List<SideEffectReport>> getMethodSideEffects({
    required int methodId,
  }) async {
    try {
      final response = await _apiService.getMethodSideEffects(methodId);

      if (response.success && response.data != null) {
        final reportsData = response.data as List<dynamic>? ?? [];
        return reportsData
            .map(
              (json) => SideEffectReport.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load method side effects: $e');
    }
  }

  /// Get all side effect reports (Health Worker only)
  Future<List<SideEffectReport>> getAllSideEffects() async {
    try {
      final response = await _apiService.getAllSideEffects();

      if (response.success && response.data != null) {
        final reportsData = response.data as List<dynamic>? ?? [];
        return reportsData
            .map(
              (json) => SideEffectReport.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load all side effects: $e');
    }
  }

  /// Create a new side effect report
  Future<bool> createSideEffectReport(SideEffectReport report) async {
    try {
      final response = await _apiService.createSideEffectReport({
        'contraception_method_id': report.contraceptionMethodId,
        'user_id': report.userId,
        'side_effect_name': report.sideEffectName,
        'severity': report.severity.name.toUpperCase(),
        'frequency': report.frequency.name.toUpperCase(),
        'description': report.description,
        'date_reported': report.dateReported.toIso8601String().split('T')[0],
      });

      return response.success;
    } catch (e) {
      throw Exception('Failed to create side effect report: $e');
    }
  }

  /// Update a side effect report
  Future<bool> updateSideEffectReport(
    int reportId,
    SideEffectReport report,
  ) async {
    try {
      final response = await _apiService.updateSideEffectReport(reportId, {
        'side_effect_name': report.sideEffectName,
        'severity': report.severity.name.toUpperCase(),
        'frequency': report.frequency.name.toUpperCase(),
        'description': report.description,
        'date_reported': report.dateReported.toIso8601String().split('T')[0],
      });

      return response.success;
    } catch (e) {
      throw Exception('Failed to update side effect report: $e');
    }
  }

  /// Delete a side effect report
  Future<bool> deleteSideEffectReport(int reportId) async {
    try {
      final response = await _apiService.deleteSideEffectReport(reportId);
      return response.success;
    } catch (e) {
      throw Exception('Failed to delete side effect report: $e');
    }
  }

  /// Get common side effects for a contraception method type
  Future<List<String>> getCommonSideEffects(String methodType) async {
    try {
      final response = await _apiService.getCommonSideEffects(methodType);

      if (response.success && response.data != null) {
        final sideEffectsData = response.data as List<dynamic>? ?? [];
        return sideEffectsData.map((e) => e.toString()).toList();
      }

      // Return default common side effects if API call fails
      return _getDefaultCommonSideEffects(methodType);
    } catch (e) {
      // Return default common side effects if API call fails
      return _getDefaultCommonSideEffects(methodType);
    }
  }

  /// Get default common side effects for fallback
  List<String> _getDefaultCommonSideEffects(String methodType) {
    switch (methodType.toUpperCase()) {
      case 'PILL':
        return [
          'Nausea',
          'Breast tenderness',
          'Mood changes',
          'Weight gain',
          'Headaches',
        ];
      case 'INJECTION':
        return [
          'Weight gain',
          'Irregular bleeding',
          'Mood changes',
          'Bone density loss',
        ];
      case 'IMPLANT':
        return ['Irregular bleeding', 'Weight gain', 'Mood changes', 'Acne'];
      case 'IUD':
        return ['Cramping', 'Irregular bleeding', 'Spotting', 'Pelvic pain'];
      case 'CONDOM':
        return ['Allergic reaction', 'Reduced sensation', 'Breakage'];
      case 'PATCH':
        return [
          'Skin irritation',
          'Breast tenderness',
          'Mood changes',
          'Nausea',
        ];
      case 'RING':
        return ['Vaginal discharge', 'Irritation', 'Mood changes', 'Nausea'];
      default:
        return ['Nausea', 'Headaches', 'Mood changes', 'Weight changes'];
    }
  }
}

/// Provider for Side Effects Service
final sideEffectsServiceProvider = Provider<SideEffectsService>((ref) {
  // Use the singleton instance of ApiService
  final apiService = ApiService.instance;
  return SideEffectsService(apiService);
});
