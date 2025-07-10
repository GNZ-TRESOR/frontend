import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import 'http_client.dart';

/// Medication model
class Medication {
  final String id;
  final String name;
  final String nameKinyarwanda;
  final String? genericName;
  final String? description;
  final String? descriptionKinyarwanda;
  final String category;
  final String dosageForm;
  final String strength;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    required this.id,
    required this.name,
    required this.nameKinyarwanda,
    this.genericName,
    this.description,
    this.descriptionKinyarwanda,
    required this.category,
    required this.dosageForm,
    required this.strength,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameKinyarwanda: json['nameKinyarwanda'] ?? '',
      genericName: json['genericName'],
      description: json['description'],
      descriptionKinyarwanda: json['descriptionKinyarwanda'],
      category: json['category'] ?? '',
      dosageForm: json['dosageForm'] ?? '',
      strength: json['strength'] ?? '',
      indications: List<String>.from(json['indications'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameKinyarwanda': nameKinyarwanda,
      'genericName': genericName,
      'description': description,
      'descriptionKinyarwanda': descriptionKinyarwanda,
      'category': category,
      'dosageForm': dosageForm,
      'strength': strength,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Medication prescription model
class MedicationPrescription {
  final String id;
  final String userId;
  final String medicationId;
  final Medication? medication;
  final String prescribedBy;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;
  final String instructionsKinyarwanda;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicationPrescription({
    required this.id,
    required this.userId,
    required this.medicationId,
    this.medication,
    required this.prescribedBy,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.instructionsKinyarwanda,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationPrescription.fromJson(Map<String, dynamic> json) {
    return MedicationPrescription(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      medicationId: json['medicationId']?.toString() ?? '',
      medication: json['medication'] != null
          ? Medication.fromJson(json['medication'] as Map<String, dynamic>)
          : null,
      prescribedBy: json['prescribedBy'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'] ?? '',
      instructionsKinyarwanda: json['instructionsKinyarwanda'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'medicationId': medicationId,
      'medication': medication?.toJson(),
      'prescribedBy': prescribedBy,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'instructionsKinyarwanda': instructionsKinyarwanda,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Check if prescription is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    final isAfterStart = now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
    final isBeforeEnd = endDate == null || now.isBefore(endDate!) || now.isAtSameMomentAs(endDate!);
    return isActive && isAfterStart && isBeforeEnd;
  }

  /// Get days remaining in prescription
  int? get daysRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }
}

/// Service for managing medications and prescriptions
class MedicationService {
  final HttpClient _httpClient = HttpClient();

  /// Get all medications
  Future<List<Medication>> getMedications({
    int page = 0,
    int limit = 20,
    String? category,
    String? dosageForm,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (dosageForm != null) queryParams['dosageForm'] = dosageForm;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final response = await _httpClient.get(
        '/medications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final medicationsData = apiResponse.data as Map<String, dynamic>;
          final medicationsList = medicationsData['medications'] as List<dynamic>;
          
          return medicationsList
              .map((json) => Medication.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching medications: $e');
      return [];
    }
  }

  /// Get medication by ID
  Future<Medication?> getMedicationById(String medicationId) async {
    try {
      final response = await _httpClient.get('/medications/$medicationId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Medication.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching medication: $e');
      return null;
    }
  }

  /// Search medications
  Future<List<Medication>> searchMedications(String query) async {
    try {
      final response = await _httpClient.get(
        '/medications/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final medicationsData = apiResponse.data as Map<String, dynamic>;
          final medicationsList = medicationsData['medications'] as List<dynamic>;
          
          return medicationsList
              .map((json) => Medication.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching medications: $e');
      return [];
    }
  }

  /// Get user's prescriptions
  Future<List<MedicationPrescription>> getUserPrescriptions(String userId) async {
    try {
      final response = await _httpClient.get('/medications/prescriptions/user/$userId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final prescriptionsData = apiResponse.data as Map<String, dynamic>;
          final prescriptionsList = prescriptionsData['prescriptions'] as List<dynamic>;
          
          return prescriptionsList
              .map((json) => MedicationPrescription.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching user prescriptions: $e');
      return [];
    }
  }

  /// Create new prescription
  Future<MedicationPrescription?> createPrescription({
    required String userId,
    required String medicationId,
    required String prescribedBy,
    required String dosage,
    required String frequency,
    required String duration,
    required String instructions,
    required String instructionsKinyarwanda,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'medicationId': medicationId,
        'prescribedBy': prescribedBy,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'instructions': instructions,
        'instructionsKinyarwanda': instructionsKinyarwanda,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

      final response = await _httpClient.post(
        '/medications/prescriptions',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return MedicationPrescription.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error creating prescription: $e');
      return null;
    }
  }

  /// Update prescription
  Future<MedicationPrescription?> updatePrescription({
    required String prescriptionId,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    String? instructionsKinyarwanda,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (dosage != null) requestData['dosage'] = dosage;
      if (frequency != null) requestData['frequency'] = frequency;
      if (duration != null) requestData['duration'] = duration;
      if (instructions != null) requestData['instructions'] = instructions;
      if (instructionsKinyarwanda != null) requestData['instructionsKinyarwanda'] = instructionsKinyarwanda;
      if (startDate != null) requestData['startDate'] = startDate.toIso8601String();
      if (endDate != null) requestData['endDate'] = endDate.toIso8601String();
      if (isActive != null) requestData['isActive'] = isActive;

      final response = await _httpClient.put(
        '/medications/prescriptions/$prescriptionId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return MedicationPrescription.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error updating prescription: $e');
      return null;
    }
  }

  /// Delete prescription
  Future<bool> deletePrescription(String prescriptionId) async {
    try {
      final response = await _httpClient.delete('/medications/prescriptions/$prescriptionId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting prescription: $e');
      return false;
    }
  }

  /// Get active prescriptions for user
  Future<List<MedicationPrescription>> getActivePrescriptions(String userId) async {
    final allPrescriptions = await getUserPrescriptions(userId);
    return allPrescriptions.where((prescription) => prescription.isCurrentlyActive).toList();
  }

  /// Get medication categories
  Future<List<String>> getMedicationCategories() async {
    try {
      final response = await _httpClient.get('/medications/categories');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final categoriesData = apiResponse.data as Map<String, dynamic>;
          final categoriesList = categoriesData['categories'] as List<dynamic>;
          
          return categoriesList.map((category) => category.toString()).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching medication categories: $e');
      return [];
    }
  }

  /// Get medication statistics
  Future<Map<String, dynamic>> getMedicationStatistics(String userId) async {
    try {
      final response = await _httpClient.get('/medications/statistics/$userId');

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
      debugPrint('Error fetching medication statistics: $e');
      return {};
    }
  }
}
