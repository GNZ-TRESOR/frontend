import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/health_facility.dart';
import '../models/api_response.dart';
import 'http_client.dart';

/// Service for managing health facilities with complete CRUD operations
class HealthFacilityService {
  final HttpClient _httpClient = HttpClient();

  /// Get all health facilities with filtering and pagination
  Future<List<HealthFacility>> getHealthFacilities({
    int page = 0,
    int limit = 10,
    String? district,
    String? sector,
    FacilityType? type,
    bool? isActive,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (district != null) queryParams['district'] = district;
      if (sector != null) queryParams['sector'] = sector;
      if (type != null) queryParams['type'] = type.value;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radiusKm != null) queryParams['radiusKm'] = radiusKm.toString();

      final response = await _httpClient.get(
        '/facilities',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final facilitiesData = apiResponse.data as Map<String, dynamic>;
          final facilitiesList = facilitiesData['facilities'] as List<dynamic>;
          
          return facilitiesList
              .map((json) => HealthFacility.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching health facilities: $e');
      return [];
    }
  }

  /// Get health facility by ID
  Future<HealthFacility?> getHealthFacilityById(String facilityId) async {
    try {
      final response = await _httpClient.get('/facilities/$facilityId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return HealthFacility.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching health facility: $e');
      return null;
    }
  }

  /// Create new health facility
  Future<HealthFacility?> createHealthFacility({
    required String name,
    required FacilityType type,
    String? description,
    String? address,
    required String district,
    required String sector,
    String? cell,
    String? village,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    List<String> services = const [],
    Map<String, String> operatingHours = const {},
    bool isActive = true,
  }) async {
    try {
      final requestData = {
        'name': name,
        'type': type.value,
        'description': description,
        'address': address,
        'district': district,
        'sector': sector,
        'cell': cell,
        'village': village,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'website': website,
        'services': services,
        'operatingHours': operatingHours,
        'isActive': isActive,
      };

      final response = await _httpClient.post(
        '/facilities',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return HealthFacility.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error creating health facility: $e');
      return null;
    }
  }

  /// Update health facility
  Future<HealthFacility?> updateHealthFacility({
    required String facilityId,
    String? name,
    FacilityType? type,
    String? description,
    String? address,
    String? district,
    String? sector,
    String? cell,
    String? village,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    List<String>? services,
    Map<String, String>? operatingHours,
    bool? isActive,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (name != null) requestData['name'] = name;
      if (type != null) requestData['type'] = type.value;
      if (description != null) requestData['description'] = description;
      if (address != null) requestData['address'] = address;
      if (district != null) requestData['district'] = district;
      if (sector != null) requestData['sector'] = sector;
      if (cell != null) requestData['cell'] = cell;
      if (village != null) requestData['village'] = village;
      if (latitude != null) requestData['latitude'] = latitude;
      if (longitude != null) requestData['longitude'] = longitude;
      if (phone != null) requestData['phone'] = phone;
      if (email != null) requestData['email'] = email;
      if (website != null) requestData['website'] = website;
      if (services != null) requestData['services'] = services;
      if (operatingHours != null) requestData['operatingHours'] = operatingHours;
      if (isActive != null) requestData['isActive'] = isActive;

      final response = await _httpClient.put(
        '/facilities/$facilityId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return HealthFacility.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error updating health facility: $e');
      return null;
    }
  }

  /// Delete health facility
  Future<bool> deleteHealthFacility(String facilityId) async {
    try {
      final response = await _httpClient.delete('/facilities/$facilityId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting health facility: $e');
      return false;
    }
  }

  /// Get nearby health facilities
  Future<List<HealthFacility>> getNearbyFacilities({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    FacilityType? type,
    int limit = 20,
  }) async {
    return getHealthFacilities(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      type: type,
      limit: limit,
    );
  }

  /// Search health facilities
  Future<List<HealthFacility>> searchHealthFacilities(String query) async {
    try {
      final response = await _httpClient.get(
        '/facilities/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final facilitiesData = apiResponse.data as Map<String, dynamic>;
          final facilitiesList = facilitiesData['facilities'] as List<dynamic>;
          
          return facilitiesList
              .map((json) => HealthFacility.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching health facilities: $e');
      return [];
    }
  }

  /// Get facilities by district
  Future<List<HealthFacility>> getFacilitiesByDistrict(String district) async {
    return getHealthFacilities(district: district);
  }

  /// Get facilities by type
  Future<List<HealthFacility>> getFacilitiesByType(FacilityType type) async {
    return getHealthFacilities(type: type);
  }

  /// Get facility services
  Future<List<String>> getFacilityServices(String facilityId) async {
    try {
      final response = await _httpClient.get('/facilities/$facilityId/services');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final servicesData = apiResponse.data as Map<String, dynamic>;
          final servicesList = servicesData['services'] as List<dynamic>;
          
          return servicesList.map((service) => service.toString()).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching facility services: $e');
      return [];
    }
  }

  /// Get facility operating hours
  Future<Map<String, String>> getFacilityOperatingHours(String facilityId) async {
    try {
      final response = await _httpClient.get('/facilities/$facilityId/hours');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final hoursData = apiResponse.data as Map<String, dynamic>;
          return Map<String, String>.from(hoursData['operatingHours'] ?? {});
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error fetching facility operating hours: $e');
      return {};
    }
  }

  /// Check if facility is open now
  Future<bool> isFacilityOpenNow(String facilityId) async {
    try {
      final response = await _httpClient.get('/facilities/$facilityId/is-open');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final statusData = apiResponse.data as Map<String, dynamic>;
          return statusData['isOpen'] ?? false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking facility status: $e');
      return false;
    }
  }

  /// Get facility statistics
  Future<Map<String, dynamic>> getFacilityStatistics() async {
    try {
      final response = await _httpClient.get('/facilities/statistics');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return apiResponse.data as Map<String, dynamic>;
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error fetching facility statistics: $e');
      return {};
    }
  }
}
