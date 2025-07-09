import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/contraception_model.dart';

class ContraceptionService {
  static final ContraceptionService _instance =
      ContraceptionService._internal();
  factory ContraceptionService() => _instance;
  ContraceptionService._internal();

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

  Future<List<ContraceptionMethod>> getContraceptionMethods({
    String? userId,
  }) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse(
        '$baseUrl/contraception${userId != null ? '?userId=$userId' : ''}',
      );

      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> methods = data['contraceptionMethods'];
          return methods
              .map((json) => ContraceptionMethod.fromJson(json))
              .toList();
        }
      }

      throw Exception('Failed to load contraception methods');
    } catch (e) {
      print('Error loading contraception methods: $e');
      return [];
    }
  }

  Future<ContraceptionMethod?> createContraceptionMethod(
    Map<String, dynamic> methodData,
  ) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/contraception');

      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(methodData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ContraceptionMethod.fromJson(data['contraceptionMethod']);
        }
      }

      throw Exception('Failed to create contraception method');
    } catch (e) {
      print('Error creating contraception method: $e');
      return null;
    }
  }

  Future<ContraceptionMethod?> updateContraceptionMethod(
    String id,
    Map<String, dynamic> methodData,
  ) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/contraception/$id');

      final response = await http.put(
        uri,
        headers: _getHeaders(token),
        body: json.encode(methodData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ContraceptionMethod.fromJson(data['contraceptionMethod']);
        }
      }

      throw Exception('Failed to update contraception method');
    } catch (e) {
      print('Error updating contraception method: $e');
      return null;
    }
  }

  Future<bool> deleteContraceptionMethod(String id) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/contraception/$id');

      final response = await http.delete(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error deleting contraception method: $e');
      return false;
    }
  }

  Future<ContraceptionMethod?> getActiveContraception({String? userId}) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse(
        '$baseUrl/contraception/active${userId != null ? '?userId=$userId' : ''}',
      );

      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['activeContraception'] != null) {
          return ContraceptionMethod.fromJson(data['activeContraception']);
        }
      }

      return null;
    } catch (e) {
      print('Error loading active contraception: $e');
      return null;
    }
  }

  Future<List<ContraceptionType>> getContraceptionTypes() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/contraception/types');

      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> types = data['contraceptionTypes'];
          return types
              .map(
                (type) => ContraceptionType.values.firstWhere(
                  (e) =>
                      e.toString().split('.').last ==
                      type.toString().toLowerCase(),
                  orElse: () => ContraceptionType.pill,
                ),
              )
              .toList();
        }
      }

      return ContraceptionType.values;
    } catch (e) {
      print('Error loading contraception types: $e');
      return ContraceptionType.values;
    }
  }

  // Helper method to convert ContraceptionMethod to JSON for API calls
  Map<String, dynamic> _contraceptionMethodToJson(ContraceptionMethod method) {
    return {
      'type': method.type.toString().split('.').last.toUpperCase(),
      'name': method.name,
      'startDate': method.startDate.toIso8601String(),
      'effectiveness': method.effectiveness,
      'sideEffects': method.sideEffects,
      'instructions': method.instructions,
      'nextAppointment': method.nextAppointment?.toIso8601String(),
      'isActive': method.isActive,
    };
  }
}
