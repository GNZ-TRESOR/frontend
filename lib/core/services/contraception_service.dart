import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contraception_method.dart';
import 'api_service.dart';

/// Contraception Service for managing contraception methods
class ContraceptionService {
  final ApiService _apiService;

  ContraceptionService(this._apiService);

  /// Get user's contraception methods using new API endpoint
  Future<List<ContraceptionMethod>> getUserMethods({
    required int userId,
  }) async {
    try {
      final response = await _apiService.dio.get('/contraception/user/$userId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final activeMethods = data['activeMethods'] as List<dynamic>? ?? [];
        final inactiveMethods = data['inactiveMethods'] as List<dynamic>? ?? [];

        // Combine active and inactive methods
        final allMethods = [...activeMethods, ...inactiveMethods];

        return allMethods
            .map(
              (json) =>
                  ContraceptionMethod.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load user contraception methods: $e');
    }
  }

  /// Get active contraception method for user using new API endpoint
  Future<ContraceptionMethod?> getActiveMethod({required int userId}) async {
    try {
      final response = await _apiService.dio.get(
        '/contraception/user/$userId/active',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          return ContraceptionMethod.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      // If there's an error, fall back to getting the most recent active method from user methods
      try {
        final userMethods = await getUserMethods(userId: userId);
        final activeMethods =
            userMethods.where((method) => method.isActive == true).toList();
        if (activeMethods.isNotEmpty) {
          // Return the most recently created active method
          activeMethods.sort(
            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now(),
            ),
          );
          return activeMethods.first;
        }
      } catch (fallbackError) {
        // If fallback also fails, return null
      }
      return null;
    }
  }

  /// Get all users and their methods (Health Worker only)
  Future<Map<String, List<ContraceptionMethod>>> getAllUsersAndMethods() async {
    try {
      final response = await _apiService.dio.get(
        '/contraception/health-worker/users',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};

        final result = <String, List<ContraceptionMethod>>{};
        data.forEach((userId, userMethods) {
          final methods =
              (userMethods as List<dynamic>? ?? [])
                  .map(
                    (json) => ContraceptionMethod.fromJson(
                      json as Map<String, dynamic>,
                    ),
                  )
                  .toList();
          result[userId] = methods;
        });

        return result;
      }
      return {};
    } catch (e) {
      throw Exception('Failed to load all users and methods: $e');
    }
  }

  /// Prescribe contraception method to user (Health Worker only)
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
      final response = await _apiService.dio.post(
        '/contraception/prescribe',
        data: {
          'userId': userId,
          'type': type.name.toUpperCase(),
          'name': name,
          if (description != null) 'description': description,
          'startDate':
              (startDate ?? DateTime.now()).toIso8601String().split('T')[0],
          if (endDate != null)
            'endDate': endDate.toIso8601String().split('T')[0],
          if (effectiveness != null) 'effectiveness': effectiveness,
          if (instructions != null) 'instructions': instructions,
          if (prescribedBy != null) 'prescribedBy': prescribedBy,
          if (nextAppointment != null)
            'nextAppointment': nextAppointment.toIso8601String().split('T')[0],
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to prescribe contraception method: $e');
    }
  }

  /// Update contraception method using new API endpoint
  Future<bool> updateMethod(int methodId, ContraceptionMethod method) async {
    try {
      final response = await _apiService.dio.put(
        '/contraception/$methodId',
        data: {
          'type': method.type.name.toUpperCase(),
          'name': method.name,
          'description': method.description,
          'startDate': method.startDate.toIso8601String().split('T')[0],
          'endDate': method.endDate?.toIso8601String().split('T')[0],
          'effectiveness': method.effectiveness,
          'instructions': method.instructions,
          'nextAppointment':
              method.nextAppointment?.toIso8601String().split('T')[0],
          'isActive': method.isActive,
          'prescribedBy': method.prescribedBy,
          'sideEffects': method.sideEffects,
          'additionalData': method.additionalData,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to update contraception method: $e');
    }
  }

  /// Deactivate contraception method using new API endpoint
  Future<bool> deactivateMethod(int methodId) async {
    try {
      final response = await _apiService.dio.put(
        '/contraception/$methodId/deactivate',
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to deactivate contraception method: $e');
    }
  }

  /// Add side effect to contraception method using new API endpoint
  Future<bool> addSideEffect(int methodId, String sideEffect) async {
    try {
      final response = await _apiService.dio.post(
        '/contraception/$methodId/side-effects',
        data: {'sideEffect': sideEffect},
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to add side effect: $e');
    }
  }

  /// Get side effects for contraception method using new API endpoint
  Future<List<String>> getSideEffects(int methodId) async {
    try {
      final response = await _apiService.dio.get(
        '/contraception/$methodId/side-effects',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final sideEffects = response.data['data'] as List<dynamic>? ?? [];
        return sideEffects.map((effect) => effect.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get side effects: $e');
    }
  }

  /// Get contraception types from backend using new API endpoint
  Future<List<String>> getContraceptionTypes() async {
    try {
      final response = await _apiService.dio.get('/contraception/types');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final types = response.data['data'] as List<dynamic>? ?? [];
        return types.map((type) => type.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load contraception types: $e');
    }
  }

  /// Get health worker reports using new API endpoint
  Future<Map<String, dynamic>> getHealthWorkerReports() async {
    try {
      final response = await _apiService.dio.get(
        '/contraception/health-worker/reports',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>? ?? {};
      }
      return {};
    } catch (e) {
      throw Exception('Failed to load health worker reports: $e');
    }
  }

  /// Get all users for health worker dropdown
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _apiService.dio.get('/admin/users');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final users = response.data['users'] as List<dynamic>? ?? [];
        return users.map((user) => user as Map<String, dynamic>).toList();
      }
      return [];
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
      final response = await _apiService.dio.post(
        '/contraception/add',
        data: {
          'userId': userId,
          'type': type.name.toUpperCase(),
          'name': name,
          if (description != null) 'description': description,
          'startDate':
              (startDate ?? DateTime.now()).toIso8601String().split('T')[0],
          if (endDate != null)
            'endDate': endDate.toIso8601String().split('T')[0],
          if (effectiveness != null) 'effectiveness': effectiveness,
          if (instructions != null) 'instructions': instructions,
          if (prescribedBy != null) 'prescribedBy': prescribedBy,
          if (nextAppointment != null)
            'nextAppointment': nextAppointment.toIso8601String().split('T')[0],
          if (isActive != null) 'isActive': isActive,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to add contraception method: $e');
    }
  }

  /// User toggles active state of their contraception method
  Future<bool> toggleMethodActiveState({
    required int methodId,
    required int userId,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/contraception/$methodId/toggle-active',
        data: {'userId': userId},
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to toggle method active state: $e');
    }
  }

  /// User deletes their contraception method (only if not active)
  Future<bool> deleteMethod({
    required int methodId,
    required int userId,
  }) async {
    try {
      final response = await _apiService.dio.delete(
        '/contraception/$methodId',
        queryParameters: {'userId': userId},
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete contraception method: $e');
    }
  }
}

/// Provider for ContraceptionService
final contraceptionServiceProvider = Provider<ContraceptionService>((ref) {
  final apiService = ApiService.instance;
  return ContraceptionService(apiService);
});
