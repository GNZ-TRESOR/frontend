import '../models/health_facility.dart';
import '../models/health_worker.dart';
import 'api_service.dart';

/// Health Facility Service for managing facilities and health workers
class HealthFacilityService {
  final ApiService _apiService;

  HealthFacilityService(this._apiService);

  // ==================== HEALTH FACILITY OPERATIONS ====================

  /// Get all health facilities
  Future<List<HealthFacility>> getHealthFacilities({
    String? facilityType,
    bool? isActive,
    int page = 0,
    int size = 20,
  }) async {
    try {
      print(
        'DEBUG: HealthFacilityService - calling API with isActive: $isActive',
      );
      final response = await _apiService.getHealthFacilities(
        facilityType: facilityType,
        isActive: isActive,
        page: page,
        size: size,
      );

      print(
        'DEBUG: HealthFacilityService - API response success: ${response.success}',
      );
      print(
        'DEBUG: HealthFacilityService - API response data type: ${response.data.runtimeType}',
      );

      if (response.success && response.data != null) {
        // Handle different response formats
        List<dynamic> facilitiesJson;

        // The API service now normalizes the response format
        if (response.data is List) {
          print('DEBUG: HealthFacilityService - Response data is List');
          facilitiesJson = response.data;
        } else if (response.data is Map<String, dynamic>) {
          print(
            'DEBUG: HealthFacilityService - Response data is Map, checking for facilities field',
          );
          // Check for facilities field first, then fallback to data/content
          facilitiesJson =
              response.data['facilities'] ??
              response.data['data'] ??
              response.data['content'] ??
              [];
        } else {
          print(
            'DEBUG: HealthFacilityService - Response data is neither Map nor List',
          );
          facilitiesJson = [];
        }

        print('DEBUG: Found ${facilitiesJson.length} facilities in response');

        if (facilitiesJson.isNotEmpty) {
          print('DEBUG: First facility JSON: ${facilitiesJson[0]}');
        }

        final facilities =
            facilitiesJson
                .map((json) => HealthFacility.fromJson(json))
                .toList();
        print('DEBUG: Parsed ${facilities.length} facilities successfully');

        if (facilities.isNotEmpty) {
          print('DEBUG: First parsed facility: ${facilities[0].name}');
        }

        return facilities;
      }
      print(
        'DEBUG: HealthFacilityService - API response not successful or data is null',
      );
      return [];
    } catch (e) {
      print('DEBUG: HealthFacilityService - Exception: $e');
      throw Exception('Failed to load health facilities: $e');
    }
  }

  /// Get active health facilities only
  Future<List<HealthFacility>> getActiveHealthFacilities({
    String? facilityType,
    int page = 0,
    int size = 20,
  }) async {
    return await getHealthFacilities(
      facilityType: facilityType,
      isActive: true,
      page: page,
      size: size,
    );
  }

  /// Get health facility by ID
  Future<HealthFacility?> getHealthFacility(int facilityId) async {
    try {
      final response = await _apiService.getHealthFacility(facilityId);

      if (response.success && response.data != null) {
        return HealthFacility.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load health facility: $e');
    }
  }

  // ==================== HEALTH WORKER OPERATIONS ====================

  /// Get all health workers
  Future<List<HealthWorker>> getHealthWorkers({
    int? healthFacilityId,
    String? specialization,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiService.getHealthWorkers(
        healthFacilityId: healthFacilityId,
        specialization: specialization,
        isAvailable: isAvailable,
        page: page,
        size: size,
      );

      if (response.success && response.data != null) {
        // Handle different response formats
        List<dynamic> healthWorkersJson;
        if (response.data is Map<String, dynamic>) {
          // Check for healthWorkers field first, then fallback to data/content
          healthWorkersJson =
              response.data['healthWorkers'] ??
              response.data['data'] ??
              response.data['content'] ??
              [];
        } else if (response.data is List) {
          healthWorkersJson = response.data;
        } else {
          healthWorkersJson = [];
        }

        return healthWorkersJson
            .map((json) => HealthWorker.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load health workers: $e');
    }
  }

  /// Get health workers for a specific facility
  Future<List<HealthWorker>> getHealthWorkersByFacility(
    int healthFacilityId, {
    String? specialization,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    return await getHealthWorkers(
      healthFacilityId: healthFacilityId,
      specialization: specialization,
      isAvailable: isAvailable,
      page: page,
      size: size,
    );
  }

  /// Get available health workers for a specific facility
  Future<List<HealthWorker>> getAvailableHealthWorkers(
    int healthFacilityId, {
    String? specialization,
    int page = 0,
    int size = 20,
  }) async {
    return await getHealthWorkers(
      healthFacilityId: healthFacilityId,
      specialization: specialization,
      isAvailable: true,
      page: page,
      size: size,
    );
  }

  /// Get health worker by ID
  Future<HealthWorker?> getHealthWorker(int healthWorkerId) async {
    try {
      final response = await _apiService.getHealthWorker(healthWorkerId);

      if (response.success && response.data != null) {
        return HealthWorker.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load health worker: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get facility types
  List<Map<String, String>> getFacilityTypes() {
    return [
      {'value': 'HOSPITAL', 'label': 'Hospital'},
      {'value': 'HEALTH_CENTER', 'label': 'Health Center'},
      {'value': 'CLINIC', 'label': 'Clinic'},
      {'value': 'DISPENSARY', 'label': 'Dispensary'},
      {'value': 'PHARMACY', 'label': 'Pharmacy'},
      {'value': 'LABORATORY', 'label': 'Laboratory'},
      {'value': 'MATERNITY_CENTER', 'label': 'Maternity Center'},
      {'value': 'COMMUNITY_HEALTH_POST', 'label': 'Community Health Post'},
      {'value': 'PRIVATE_PRACTICE', 'label': 'Private Practice'},
      {'value': 'OTHER', 'label': 'Other'},
    ];
  }

  /// Get specializations
  List<Map<String, String>> getSpecializations() {
    return [
      {'value': 'GENERAL_PRACTICE', 'label': 'General Practice'},
      {'value': 'FAMILY_PLANNING', 'label': 'Family Planning'},
      {'value': 'MATERNAL_HEALTH', 'label': 'Maternal Health'},
      {'value': 'CHILD_HEALTH', 'label': 'Child Health'},
      {'value': 'REPRODUCTIVE_HEALTH', 'label': 'Reproductive Health'},
      {'value': 'NUTRITION', 'label': 'Nutrition'},
      {'value': 'MENTAL_HEALTH', 'label': 'Mental Health'},
      {'value': 'EMERGENCY_CARE', 'label': 'Emergency Care'},
      {'value': 'PREVENTIVE_CARE', 'label': 'Preventive Care'},
      {'value': 'CHRONIC_DISEASE', 'label': 'Chronic Disease Management'},
      {'value': 'INFECTIOUS_DISEASE', 'label': 'Infectious Disease'},
      {'value': 'SURGERY', 'label': 'Surgery'},
      {'value': 'PHARMACY', 'label': 'Pharmacy'},
      {'value': 'LABORATORY', 'label': 'Laboratory'},
      {'value': 'RADIOLOGY', 'label': 'Radiology'},
      {'value': 'OTHER', 'label': 'Other'},
    ];
  }

  /// Search facilities by name or location
  Future<List<HealthFacility>> searchFacilities(
    String query, {
    String? facilityType,
    bool? isActive,
    int page = 0,
    int size = 20,
  }) async {
    // For now, get all facilities and filter locally
    // In a real implementation, this would be a server-side search
    final facilities = await getHealthFacilities(
      facilityType: facilityType,
      isActive: isActive,
      page: page,
      size: size,
    );

    if (query.isEmpty) return facilities;

    final lowerQuery = query.toLowerCase();
    return facilities.where((facility) {
      return facility.name.toLowerCase().contains(lowerQuery) ||
          (facility.address?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Search health workers by name or specialization
  Future<List<HealthWorker>> searchHealthWorkers(
    String query, {
    int? healthFacilityId,
    String? specialization,
    bool? isAvailable,
    int page = 0,
    int size = 20,
  }) async {
    // For now, get all health workers and filter locally
    // In a real implementation, this would be a server-side search
    final healthWorkers = await getHealthWorkers(
      healthFacilityId: healthFacilityId,
      specialization: specialization,
      isAvailable: isAvailable,
      page: page,
      size: size,
    );

    if (query.isEmpty) return healthWorkers;

    final lowerQuery = query.toLowerCase();
    return healthWorkers.where((worker) {
      return worker.name.toLowerCase().contains(lowerQuery) ||
          (worker.specialization?.toLowerCase().contains(lowerQuery) ??
              false) ||
          (worker.qualification?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get facilities near a location (placeholder for future implementation)
  Future<List<HealthFacility>> getFacilitiesNearLocation(
    double latitude,
    double longitude, {
    double radiusKm = 10.0,
    String? facilityType,
    bool? isActive,
    int page = 0,
    int size = 20,
  }) async {
    // For now, just return all facilities
    // In a real implementation, this would use geolocation filtering
    return await getHealthFacilities(
      facilityType: facilityType,
      isActive: isActive,
      page: page,
      size: size,
    );
  }
}
