import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import 'http_client.dart';

/// Menstrual cycle phase enum
enum CyclePhase {
  menstrual('MENSTRUAL'),
  follicular('FOLLICULAR'),
  ovulation('OVULATION'),
  luteal('LUTEAL');

  const CyclePhase(this.value);
  final String value;

  static CyclePhase fromValue(String value) {
    return CyclePhase.values.firstWhere(
      (phase) => phase.value == value,
      orElse: () => CyclePhase.menstrual,
    );
  }

  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Imihango';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }
}

/// Flow intensity enum
enum FlowIntensity {
  light('LIGHT'),
  medium('MEDIUM'),
  heavy('HEAVY'),
  veryHeavy('VERY_HEAVY');

  const FlowIntensity(this.value);
  final String value;

  static FlowIntensity fromValue(String value) {
    return FlowIntensity.values.firstWhere(
      (intensity) => intensity.value == value,
      orElse: () => FlowIntensity.medium,
    );
  }

  String get displayName {
    switch (this) {
      case FlowIntensity.light:
        return 'Bike';
      case FlowIntensity.medium:
        return 'Hagati';
      case FlowIntensity.heavy:
        return 'Byinshi';
      case FlowIntensity.veryHeavy:
        return 'Byinshi cyane';
    }
  }
}

/// Menstrual cycle record model
class MenstrualCycleRecord {
  final String id;
  final String userId;
  final DateTime date;
  final CyclePhase phase;
  final FlowIntensity? flowIntensity;
  final List<String> symptoms;
  final String? mood;
  final double? temperature;
  final String? notes;
  final bool isPredicted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenstrualCycleRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.phase,
    this.flowIntensity,
    required this.symptoms,
    this.mood,
    this.temperature,
    this.notes,
    this.isPredicted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenstrualCycleRecord.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleRecord(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      phase: CyclePhase.fromValue(json['phase'] ?? 'MENSTRUAL'),
      flowIntensity: json['flowIntensity'] != null
          ? FlowIntensity.fromValue(json['flowIntensity'])
          : null,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      mood: json['mood'],
      temperature: json['temperature']?.toDouble(),
      notes: json['notes'],
      isPredicted: json['isPredicted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'phase': phase.value,
      'flowIntensity': flowIntensity?.value,
      'symptoms': symptoms,
      'mood': mood,
      'temperature': temperature,
      'notes': notes,
      'isPredicted': isPredicted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Menstrual cycle summary model
class MenstrualCycleSummary {
  final String userId;
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime? lastPeriodStart;
  final DateTime? nextPeriodPredicted;
  final DateTime? nextOvulationPredicted;
  final List<String> commonSymptoms;
  final Map<String, int> symptomFrequency;
  final DateTime createdAt;

  const MenstrualCycleSummary({
    required this.userId,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    this.lastPeriodStart,
    this.nextPeriodPredicted,
    this.nextOvulationPredicted,
    required this.commonSymptoms,
    required this.symptomFrequency,
    required this.createdAt,
  });

  factory MenstrualCycleSummary.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleSummary(
      userId: json['userId']?.toString() ?? '',
      averageCycleLength: json['averageCycleLength'] ?? 28,
      averagePeriodLength: json['averagePeriodLength'] ?? 5,
      lastPeriodStart: json['lastPeriodStart'] != null
          ? DateTime.parse(json['lastPeriodStart'])
          : null,
      nextPeriodPredicted: json['nextPeriodPredicted'] != null
          ? DateTime.parse(json['nextPeriodPredicted'])
          : null,
      nextOvulationPredicted: json['nextOvulationPredicted'] != null
          ? DateTime.parse(json['nextOvulationPredicted'])
          : null,
      commonSymptoms: List<String>.from(json['commonSymptoms'] ?? []),
      symptomFrequency: Map<String, int>.from(json['symptomFrequency'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'lastPeriodStart': lastPeriodStart?.toIso8601String(),
      'nextPeriodPredicted': nextPeriodPredicted?.toIso8601String(),
      'nextOvulationPredicted': nextOvulationPredicted?.toIso8601String(),
      'commonSymptoms': commonSymptoms,
      'symptomFrequency': symptomFrequency,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Service for managing menstrual cycle tracking
class MenstrualCycleService {
  final HttpClient _httpClient = HttpClient();

  /// Get menstrual cycle records for user
  Future<List<MenstrualCycleRecord>> getCycleRecords({
    required String userId,
    int page = 0,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
    CyclePhase? phase,
    bool? isPredicted,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (phase != null) queryParams['phase'] = phase.value;
      if (isPredicted != null) queryParams['isPredicted'] = isPredicted.toString();

      final response = await _httpClient.get(
        '/menstrual-cycle/user/$userId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final recordsData = apiResponse.data as Map<String, dynamic>;
          final recordsList = recordsData['records'] as List<dynamic>;
          
          return recordsList
              .map((json) => MenstrualCycleRecord.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching cycle records: $e');
      return [];
    }
  }

  /// Create new cycle record
  Future<MenstrualCycleRecord?> createCycleRecord({
    required String userId,
    required DateTime date,
    required CyclePhase phase,
    FlowIntensity? flowIntensity,
    List<String> symptoms = const [],
    String? mood,
    double? temperature,
    String? notes,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'date': date.toIso8601String(),
        'phase': phase.value,
        'flowIntensity': flowIntensity?.value,
        'symptoms': symptoms,
        'mood': mood,
        'temperature': temperature,
        'notes': notes,
      };

      final response = await _httpClient.post(
        '/menstrual-cycle',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return MenstrualCycleRecord.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error creating cycle record: $e');
      return null;
    }
  }

  /// Update cycle record
  Future<MenstrualCycleRecord?> updateCycleRecord({
    required String recordId,
    CyclePhase? phase,
    FlowIntensity? flowIntensity,
    List<String>? symptoms,
    String? mood,
    double? temperature,
    String? notes,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (phase != null) requestData['phase'] = phase.value;
      if (flowIntensity != null) requestData['flowIntensity'] = flowIntensity.value;
      if (symptoms != null) requestData['symptoms'] = symptoms;
      if (mood != null) requestData['mood'] = mood;
      if (temperature != null) requestData['temperature'] = temperature;
      if (notes != null) requestData['notes'] = notes;

      final response = await _httpClient.put(
        '/menstrual-cycle/$recordId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return MenstrualCycleRecord.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error updating cycle record: $e');
      return null;
    }
  }

  /// Delete cycle record
  Future<bool> deleteCycleRecord(String recordId) async {
    try {
      final response = await _httpClient.delete('/menstrual-cycle/$recordId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting cycle record: $e');
      return false;
    }
  }

  /// Get cycle summary for user
  Future<MenstrualCycleSummary?> getCycleSummary(String userId) async {
    try {
      final response = await _httpClient.get('/menstrual-cycle/summary/$userId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return MenstrualCycleSummary.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching cycle summary: $e');
      return null;
    }
  }

  /// Get cycle predictions for user
  Future<List<MenstrualCycleRecord>> getCyclePredictions(String userId) async {
    return getCycleRecords(userId: userId, isPredicted: true);
  }

  /// Start new period
  Future<MenstrualCycleRecord?> startPeriod({
    required String userId,
    required DateTime startDate,
    FlowIntensity flowIntensity = FlowIntensity.medium,
    List<String> symptoms = const [],
    String? mood,
    String? notes,
  }) async {
    return createCycleRecord(
      userId: userId,
      date: startDate,
      phase: CyclePhase.menstrual,
      flowIntensity: flowIntensity,
      symptoms: symptoms,
      mood: mood,
      notes: notes,
    );
  }

  /// Log daily symptoms
  Future<MenstrualCycleRecord?> logDailySymptoms({
    required String userId,
    required DateTime date,
    required List<String> symptoms,
    String? mood,
    double? temperature,
    String? notes,
  }) async {
    // Determine phase based on cycle data
    final summary = await getCycleSummary(userId);
    CyclePhase phase = CyclePhase.follicular; // Default

    if (summary?.lastPeriodStart != null) {
      final daysSinceLastPeriod = date.difference(summary!.lastPeriodStart!).inDays;
      
      if (daysSinceLastPeriod <= summary.averagePeriodLength) {
        phase = CyclePhase.menstrual;
      } else if (daysSinceLastPeriod <= 14) {
        phase = CyclePhase.follicular;
      } else if (daysSinceLastPeriod <= 16) {
        phase = CyclePhase.ovulation;
      } else {
        phase = CyclePhase.luteal;
      }
    }

    return createCycleRecord(
      userId: userId,
      date: date,
      phase: phase,
      symptoms: symptoms,
      mood: mood,
      temperature: temperature,
      notes: notes,
    );
  }

  /// Get available symptoms list
  Future<List<String>> getAvailableSymptoms() async {
    try {
      final response = await _httpClient.get('/menstrual-cycle/symptoms');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final symptomsData = apiResponse.data as Map<String, dynamic>;
          final symptomsList = symptomsData['symptoms'] as List<dynamic>;
          
          return symptomsList.map((symptom) => symptom.toString()).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching available symptoms: $e');
      return [];
    }
  }

  /// Get cycle statistics
  Future<Map<String, dynamic>> getCycleStatistics(String userId) async {
    try {
      final response = await _httpClient.get('/menstrual-cycle/statistics/$userId');

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
      debugPrint('Error fetching cycle statistics: $e');
      return {};
    }
  }
}
