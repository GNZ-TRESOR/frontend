import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/health_record_model.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'http_client.dart';

/// Service for managing health records with complete CRUD operations
class HealthRecordService {
  final HttpClient _httpClient = HttpClient();

  /// Get all health records with filtering and pagination
  Future<List<HealthRecord>> getHealthRecords({
    int page = 0,
    int limit = 10,
    String? userId,
    String? recordType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isConfidential,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['userId'] = userId;
      if (recordType != null) queryParams['recordType'] = recordType;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (isConfidential != null) queryParams['isConfidential'] = isConfidential.toString();

      final response = await _httpClient.get(
        '/health-records',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final recordsData = apiResponse.data as Map<String, dynamic>;
          final recordsList = recordsData['healthRecords'] as List<dynamic>;
          
          return recordsList
              .map((json) => HealthRecord.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching health records: $e');
      return [];
    }
  }

  /// Get health record by ID
  Future<HealthRecord?> getHealthRecordById(String recordId) async {
    try {
      final response = await _httpClient.get('/health-records/$recordId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return HealthRecord.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching health record: $e');
      return null;
    }
  }

  /// Create new health record
  Future<HealthRecord?> createHealthRecord({
    required String userId,
    required String healthWorkerId,
    required DateTime recordDate,
    required String recordType,
    required HealthRecordType type,
    required Map<String, dynamic> data,
    String? notes,
    List<String> attachments = const [],
    bool isConfidential = true,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'healthWorkerId': healthWorkerId,
        'recordDate': recordDate.toIso8601String(),
        'recordType': recordType,
        'type': type.name.toUpperCase(),
        'data': data,
        'notes': notes,
        'attachments': attachments,
        'isConfidential': isConfidential,
      };

      final response = await _httpClient.post(
        '/health-records',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return HealthRecord.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error creating health record: $e');
      return null;
    }
  }

  /// Update health record
  Future<HealthRecord?> updateHealthRecord({
    required String recordId,
    DateTime? recordDate,
    String? recordType,
    HealthRecordType? type,
    Map<String, dynamic>? data,
    String? notes,
    List<String>? attachments,
    bool? isConfidential,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (recordDate != null) requestData['recordDate'] = recordDate.toIso8601String();
      if (recordType != null) requestData['recordType'] = recordType;
      if (type != null) requestData['type'] = type.name.toUpperCase();
      if (data != null) requestData['data'] = data;
      if (notes != null) requestData['notes'] = notes;
      if (attachments != null) requestData['attachments'] = attachments;
      if (isConfidential != null) requestData['isConfidential'] = isConfidential;

      final response = await _httpClient.put(
        '/health-records/$recordId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return HealthRecord.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error updating health record: $e');
      return null;
    }
  }

  /// Delete health record
  Future<bool> deleteHealthRecord(String recordId) async {
    try {
      final response = await _httpClient.delete('/health-records/$recordId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting health record: $e');
      return false;
    }
  }

  /// Get health records for a specific user
  Future<List<HealthRecord>> getUserHealthRecords(String userId) async {
    return getHealthRecords(userId: userId);
  }

  /// Get health records by type
  Future<List<HealthRecord>> getHealthRecordsByType(HealthRecordType type) async {
    return getHealthRecords(recordType: type.name.toUpperCase());
  }

  /// Create vital signs record
  Future<HealthRecord?> createVitalSignsRecord({
    required String userId,
    required String healthWorkerId,
    double? weight,
    double? height,
    int? systolicBP,
    int? diastolicBP,
    double? temperature,
    int? heartRate,
    int? respiratoryRate,
    double? oxygenSaturation,
    String? notes,
  }) async {
    final vitalSignsData = <String, dynamic>{};
    
    if (weight != null) vitalSignsData['weight'] = weight;
    if (height != null) vitalSignsData['height'] = height;
    if (systolicBP != null) vitalSignsData['systolicBP'] = systolicBP;
    if (diastolicBP != null) vitalSignsData['diastolicBP'] = diastolicBP;
    if (temperature != null) vitalSignsData['temperature'] = temperature;
    if (heartRate != null) vitalSignsData['heartRate'] = heartRate;
    if (respiratoryRate != null) vitalSignsData['respiratoryRate'] = respiratoryRate;
    if (oxygenSaturation != null) vitalSignsData['oxygenSaturation'] = oxygenSaturation;

    return createHealthRecord(
      userId: userId,
      healthWorkerId: healthWorkerId,
      recordDate: DateTime.now(),
      recordType: 'VITAL_SIGNS',
      type: HealthRecordType.vitalSigns,
      data: vitalSignsData,
      notes: notes,
    );
  }

  /// Create family planning record
  Future<HealthRecord?> createFamilyPlanningRecord({
    required String userId,
    required String healthWorkerId,
    String? contraceptiveMethod,
    DateTime? lastMenstrualPeriod,
    bool? isPregnant,
    int? pregnancyWeeks,
    String? familyPlanningGoals,
    String? notes,
  }) async {
    final familyPlanningData = <String, dynamic>{};
    
    if (contraceptiveMethod != null) familyPlanningData['contraceptiveMethod'] = contraceptiveMethod;
    if (lastMenstrualPeriod != null) familyPlanningData['lastMenstrualPeriod'] = lastMenstrualPeriod.toIso8601String();
    if (isPregnant != null) familyPlanningData['isPregnant'] = isPregnant;
    if (pregnancyWeeks != null) familyPlanningData['pregnancyWeeks'] = pregnancyWeeks;
    if (familyPlanningGoals != null) familyPlanningData['familyPlanningGoals'] = familyPlanningGoals;

    return createHealthRecord(
      userId: userId,
      healthWorkerId: healthWorkerId,
      recordDate: DateTime.now(),
      recordType: 'FAMILY_PLANNING',
      type: HealthRecordType.familyPlanning,
      data: familyPlanningData,
      notes: notes,
    );
  }

  /// Create prenatal care record
  Future<HealthRecord?> createPrenatalRecord({
    required String userId,
    required String healthWorkerId,
    required int gestationalWeeks,
    double? weight,
    int? systolicBP,
    int? diastolicBP,
    String? fetalHeartRate,
    String? fundalHeight,
    String? complications,
    String? notes,
  }) async {
    final prenatalData = <String, dynamic>{
      'gestationalWeeks': gestationalWeeks,
    };
    
    if (weight != null) prenatalData['weight'] = weight;
    if (systolicBP != null) prenatalData['systolicBP'] = systolicBP;
    if (diastolicBP != null) prenatalData['diastolicBP'] = diastolicBP;
    if (fetalHeartRate != null) prenatalData['fetalHeartRate'] = fetalHeartRate;
    if (fundalHeight != null) prenatalData['fundalHeight'] = fundalHeight;
    if (complications != null) prenatalData['complications'] = complications;

    return createHealthRecord(
      userId: userId,
      healthWorkerId: healthWorkerId,
      recordDate: DateTime.now(),
      recordType: 'PRENATAL_CARE',
      type: HealthRecordType.prenatalCare,
      data: prenatalData,
      notes: notes,
    );
  }

  /// Search health records
  Future<List<HealthRecord>> searchHealthRecords(String query) async {
    try {
      final response = await _httpClient.get(
        '/health-records/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final recordsData = apiResponse.data as Map<String, dynamic>;
          final recordsList = recordsData['healthRecords'] as List<dynamic>;
          
          return recordsList
              .map((json) => HealthRecord.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching health records: $e');
      return [];
    }
  }

  /// Get health record statistics
  Future<Map<String, dynamic>> getHealthRecordStatistics(String userId) async {
    try {
      final response = await _httpClient.get('/health-records/statistics/$userId');

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
      debugPrint('Error fetching health record statistics: $e');
      return {};
    }
  }
}
