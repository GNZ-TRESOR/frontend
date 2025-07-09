import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/health_record_model.dart';
import '../models/health_facility_model.dart';

class ClientService {
  static final ClientService _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

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

  // Profile Management
  Future<User?> getProfile({String? clientId}) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/client/${clientId ?? 'current'}/profile');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['profile']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading profile: $e');
      return null;
    }
  }

  // Appointments
  Future<List<Appointment>> getAppointments({String? clientId}) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/client/${clientId ?? 'current'}/appointments');
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

  Future<Appointment?> bookAppointment(String clientId, Map<String, dynamic> appointmentData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/client/$clientId/appointments');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Appointment.fromJson(data['appointment']);
        }
      }
      
      throw Exception('Failed to book appointment');
    } catch (e) {
      print('Error booking appointment: $e');
      return null;
    }
  }

  // Health Records
  Future<List<HealthRecord>> getHealthRecords({String? clientId}) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/client/${clientId ?? 'current'}/health-records');
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

  Future<HealthRecord?> createHealthRecord(String clientId, Map<String, dynamic> recordData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/client/$clientId/health-records');
      
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

  // Health Facilities
  Future<List<HealthFacility>> getNearbyFacilities({
    String? clientId,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        if (radius != null) 'radius': radius.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/client/${clientId ?? 'current'}/nearby-facilities')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> facilities = data['facilities'];
          return facilities.map((json) => HealthFacility.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load nearby facilities');
    } catch (e) {
      print('Error loading nearby facilities: $e');
      return [];
    }
  }

  // Dashboard
  Future<Map<String, dynamic>?> getDashboardStats({String? clientId}) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/client/${clientId ?? 'current'}/dashboard/stats');
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
