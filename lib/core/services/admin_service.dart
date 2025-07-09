import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

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

  // User Management
  Future<List<User>> getAllUsers({
    int page = 0,
    int limit = 10,
    String? role,
    String? search,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (role != null) 'role': role,
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/admin/users').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> users = data['users'];
          return users.map((json) => User.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load users');
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  Future<User?> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/users');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['user']);
        }
      }
      
      throw Exception('Failed to create user');
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<User?> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/users/$userId');
      
      final response = await http.put(
        uri,
        headers: _getHeaders(token),
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['user']);
        }
      }
      
      throw Exception('Failed to update user');
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/users/$userId');
      
      final response = await http.delete(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<bool> updateUserStatus(String userId, String status) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/users/$userId/status');
      
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
      print('Error updating user status: $e');
      return false;
    }
  }

  // Analytics
  Future<Map<String, dynamic>?> getAnalytics({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        'startDate': startDate,
        'endDate': endDate,
      };
      
      final uri = Uri.parse('$baseUrl/admin/analytics').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['analytics'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading analytics: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getReports({
    required String type,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _getAuthToken();
      final queryParams = {
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      };
      
      final uri = Uri.parse('$baseUrl/admin/reports').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['reports']);
        }
      }
      
      throw Exception('Failed to load reports');
    } catch (e) {
      print('Error loading reports: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/dashboard/stats');
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

  Future<List<User>> getHealthWorkers() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/health-workers');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> healthWorkers = data['healthWorkers'];
          return healthWorkers.map((json) => User.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load health workers');
    } catch (e) {
      print('Error loading health workers: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSystemHealth() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/admin/system/health');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['health'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading system health: $e');
      return null;
    }
  }
}
