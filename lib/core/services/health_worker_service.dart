import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/health_record_model.dart';

class HealthWorkerService {
  static final HealthWorkerService _instance = HealthWorkerService._internal();
  factory HealthWorkerService() => _instance;
  HealthWorkerService._internal();

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

  // Client Management
  Future<List<User>> getClients({
    int page = 0,
    int limit = 10,
    String? search,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/health-worker/clients').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> clients = data['clients'];
          return clients.map((json) => User.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load clients');
    } catch (e) {
      print('Error loading clients: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getClientDetails(String clientId) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-worker/clients/$clientId');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['clientDetails'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading client details: $e');
      return null;
    }
  }

  // Appointments
  Future<List<Appointment>> getAppointments({String? healthWorkerId}) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        if (healthWorkerId != null) 'healthWorkerId': healthWorkerId,
      };
      
      final uri = Uri.parse('$baseUrl/health-worker/appointments').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> appointments = data['appointments'];
          return appointments.map((json) => Appointment.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load appointments');
    } catch (e) {
      print('Error loading appointments: $e');
      return [];
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-worker/appointments/$appointmentId/status');
      
      final response = await http.put(
        uri,
        headers: _getHeaders(token),
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  // Health Records
  Future<List<HealthRecord>> getClientHealthRecords(String clientId) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-worker/clients/$clientId/health-records');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> records = data['healthRecords'];
          return records.map((json) => HealthRecord.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load client health records');
    } catch (e) {
      print('Error loading client health records: $e');
      return [];
    }
  }

  Future<HealthRecord?> createClientHealthRecord(String clientId, Map<String, dynamic> recordData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-worker/clients/$clientId/health-records');
      
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

  // Consultations
  Future<Map<String, dynamic>?> createConsultation(Map<String, dynamic> consultationData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-worker/consultations');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(consultationData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['consultation'];
        }
      }
      
      throw Exception('Failed to create consultation');
    } catch (e) {
      print('Error creating consultation: $e');
      return null;
    }
  }

  // Dashboard
  Future<Map<String, dynamic>?> getDashboardStats({String? healthWorkerId}) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/health-worker/${healthWorkerId ?? 'current'}/dashboard/stats');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['stats'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading dashboard stats: $e');
      return null;
    }
  }
}
