import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class DashboardService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userTokenKey);
  }

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        final userMap = json.decode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get dashboard statistics for current user
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final token = await _getAuthToken();
      final user = await _getCurrentUser();

      if (user == null) return null;

      String endpoint;
      switch (user.role) {
        case UserRole.admin:
          endpoint = '/admin/dashboard/stats';
          break;
        case UserRole.healthWorker:
          endpoint = '/health-worker/${user.id}/dashboard/stats';
          break;
        case UserRole.client:
          endpoint = '/client/${user.id}/dashboard/stats';
          break;
        default:
          return null;
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['stats'] ?? data['data'];
        }
      }

      return null;
    } catch (e) {
      print('Error loading dashboard stats: $e');
      return null;
    }
  }

  // Get recent activities for dashboard
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final token = await _getAuthToken();
      final user = await _getCurrentUser();

      if (user == null) return [];

      final activities = <Map<String, dynamic>>[];

      // Get recent appointments
      final appointmentsUri = Uri.parse(
        '$baseUrl/appointments?limit=3&userId=${user.id}',
      );
      final appointmentsResponse = await http.get(
        appointmentsUri,
        headers: _getHeaders(token),
      );

      if (appointmentsResponse.statusCode == 200) {
        final appointmentsData = json.decode(appointmentsResponse.body);
        if (appointmentsData['success'] == true) {
          final appointments = appointmentsData['data'] as List?;
          if (appointments != null) {
            for (final appointment in appointments.take(2)) {
              activities.add({
                'type': 'appointment',
                'title': 'Gahunda y\'ubuvuzi',
                'subtitle': appointment['facilityName'] ?? 'Ikigo cy\'ubuzima',
                'icon': 'calendar',
                'time':
                    appointment['appointmentDate'] ??
                    DateTime.now().toIso8601String(),
                'color': 'primary',
              });
            }
          }
        }
      }

      // Get recent health records
      final healthRecordsUri = Uri.parse('$baseUrl/health-records?limit=2');
      final healthRecordsResponse = await http.get(
        healthRecordsUri,
        headers: _getHeaders(token),
      );

      if (healthRecordsResponse.statusCode == 200) {
        final healthRecordsData = json.decode(healthRecordsResponse.body);
        if (healthRecordsData['success'] == true) {
          final records = healthRecordsData['data'] as List?;
          if (records != null) {
            for (final record in records.take(1)) {
              activities.add({
                'type': 'health_record',
                'title': 'Gukurikirana ubuzima',
                'subtitle': record['recordType'] ?? 'Inyandiko y\'ubuzima',
                'icon': 'health',
                'time':
                    record['recordedAt'] ?? DateTime.now().toIso8601String(),
                'color': 'secondary',
              });
            }
          }
        }
      }

      // Get recent messages
      final messagesUri = Uri.parse('$baseUrl/messages?limit=2');
      final messagesResponse = await http.get(
        messagesUri,
        headers: _getHeaders(token),
      );

      if (messagesResponse.statusCode == 200) {
        final messagesData = json.decode(messagesResponse.body);
        if (messagesData['success'] == true) {
          final messages = messagesData['data'] as List?;
          if (messages != null && messages.isNotEmpty) {
            activities.add({
              'type': 'message',
              'title': 'Ubutumwa',
              'subtitle': 'Umukozi w\'ubuzima',
              'icon': 'message',
              'time':
                  messages.first['sentAt'] ?? DateTime.now().toIso8601String(),
              'color': 'accent',
            });
          }
        }
      }

      // Sort by time (most recent first)
      activities.sort((a, b) {
        final timeA = DateTime.tryParse(a['time'] ?? '') ?? DateTime.now();
        final timeB = DateTime.tryParse(b['time'] ?? '') ?? DateTime.now();
        return timeB.compareTo(timeA);
      });

      return activities.take(3).toList();
    } catch (e) {
      print('Error loading recent activities: $e');
      return [];
    }
  }

  // Get education progress
  Future<Map<String, dynamic>?> getEducationProgress() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/education/progress');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final progress = data['data'] as List?;
          if (progress != null && progress.isNotEmpty) {
            final completedLessons =
                progress.where((p) => p['completed'] == true).length;
            final totalLessons = progress.length;
            final progressPercentage =
                totalLessons > 0
                    ? (completedLessons / totalLessons * 100).round()
                    : 0;

            return {
              'completedLessons': completedLessons,
              'totalLessons': totalLessons,
              'progressPercentage': progressPercentage,
            };
          }
        }
      }

      return null;
    } catch (e) {
      print('Error loading education progress: $e');
      return null;
    }
  }

  // Get contraception effectiveness
  Future<Map<String, dynamic>?> getContraceptionInfo() async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/contraception/active');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final contraception = data['data'];
          return {
            'methodName': contraception['methodName'] ?? 'Ntabwo hahari',
            'effectiveness': contraception['effectiveness'] ?? 0,
            'isActive': true,
          };
        }
      }

      return {
        'methodName': 'Ntabwo hahari',
        'effectiveness': 0,
        'isActive': false,
      };
    } catch (e) {
      print('Error loading contraception info: $e');
      return {
        'methodName': 'Ntabwo hahari',
        'effectiveness': 0,
        'isActive': false,
      };
    }
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount() async {
    try {
      final token = await _getAuthToken();
      final user = await _getCurrentUser();

      if (user == null) return 0;

      final uri = Uri.parse('$baseUrl/messages/unread?userId=${user.id}');
      final response = await http.get(uri, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['count'] ?? 0;
        }
      }

      return 0;
    } catch (e) {
      print('Error loading unread messages count: $e');
      return 0;
    }
  }
}
