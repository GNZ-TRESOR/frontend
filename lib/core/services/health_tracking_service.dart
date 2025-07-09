import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/health_record_model.dart';

class HealthTrackingService {
  static final HealthTrackingService _instance = HealthTrackingService._internal();
  factory HealthTrackingService() => _instance;
  HealthTrackingService._internal();

  final String baseUrl = AppConstants.baseUrl;

  Future<String?> _getAuthToken() async {
    // Get token from secure storage
    // For now, return null (will be handled by auth service)
    return null;
  }

  Map<String, String> _getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Health Records
  Future<List<HealthRecord>> getHealthRecords({
    int page = 0,
    int limit = 10,
    String? type,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
      };
      
      final uri = Uri.parse('$baseUrl/health-records').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> records = data['healthRecords'];
          return records.map((json) => HealthRecord.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load health records');
    } catch (e) {
      print('Error loading health records: $e');
      return [];
    }
  }

  Future<HealthRecord?> createHealthRecord(Map<String, dynamic> recordData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-records');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(recordData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return HealthRecord.fromJson(data['healthRecord']);
        }
      }
      
      throw Exception('Failed to create health record');
    } catch (e) {
      print('Error creating health record: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getHealthStatistics({String? userId}) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        if (userId != null) 'userId': userId,
      };
      
      final uri = Uri.parse('$baseUrl/health-records/statistics').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['statistics'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading health statistics: $e');
      return null;
    }
  }

  // Menstrual Cycle
  Future<List<Map<String, dynamic>>> getMenstrualCycles({
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/menstrual-cycles').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['menstrualCycles']);
        }
      }
      
      throw Exception('Failed to load menstrual cycles');
    } catch (e) {
      print('Error loading menstrual cycles: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentCycle({String? userId}) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        if (userId != null) 'userId': userId,
      };
      
      final uri = Uri.parse('$baseUrl/menstrual-cycles/current').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['currentCycle'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading current cycle: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCyclePredictions({String? userId}) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        if (userId != null) 'userId': userId,
      };
      
      final uri = Uri.parse('$baseUrl/menstrual-cycles/predictions').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['predictions'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading cycle predictions: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createMenstrualCycle(Map<String, dynamic> cycleData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/menstrual-cycles');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(cycleData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['menstrualCycle'];
        }
      }
      
      throw Exception('Failed to create menstrual cycle');
    } catch (e) {
      print('Error creating menstrual cycle: $e');
      return null;
    }
  }

  // Medications
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/medications');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['medications']);
        }
      }
      
      throw Exception('Failed to load medications');
    } catch (e) {
      print('Error loading medications: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActiveMedications() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/medications/active');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['activeMedications']);
        }
      }
      
      throw Exception('Failed to load active medications');
    } catch (e) {
      print('Error loading active medications: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createMedication(Map<String, dynamic> medicationData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/medications');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(medicationData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['medication'];
        }
      }
      
      throw Exception('Failed to create medication');
    } catch (e) {
      print('Error creating medication: $e');
      return null;
    }
  }
}
