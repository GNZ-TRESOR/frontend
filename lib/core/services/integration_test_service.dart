import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class IntegrationTestService {
  static final IntegrationTestService _instance = IntegrationTestService._internal();
  factory IntegrationTestService() => _instance;
  IntegrationTestService._internal();

  final String baseUrl = AppConstants.baseUrl;

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Test all backend endpoints
  Future<Map<String, bool>> testAllEndpoints() async {
    final results = <String, bool>{};

    // Test Authentication endpoints
    results['auth_login'] = await _testEndpoint('POST', '/auth/login');
    results['auth_register'] = await _testEndpoint('POST', '/auth/register');
    results['auth_refresh'] = await _testEndpoint('POST', '/auth/refresh');
    results['auth_forgot_password'] = await _testEndpoint('POST', '/auth/forgot-password');
    results['auth_reset_password'] = await _testEndpoint('POST', '/auth/reset-password');

    // Test User endpoints
    results['users_profile'] = await _testEndpoint('GET', '/users/profile');
    results['users_update_profile'] = await _testEndpoint('PUT', '/users/profile');
    results['users_change_password'] = await _testEndpoint('POST', '/users/change-password');

    // Test Health Records endpoints
    results['health_records_get'] = await _testEndpoint('GET', '/health-records');
    results['health_records_create'] = await _testEndpoint('POST', '/health-records');
    results['health_records_statistics'] = await _testEndpoint('GET', '/health-records/statistics?userId=1');

    // Test Menstrual Cycle endpoints
    results['menstrual_cycles_get'] = await _testEndpoint('GET', '/menstrual-cycles');
    results['menstrual_cycles_create'] = await _testEndpoint('POST', '/menstrual-cycles');
    results['menstrual_cycles_current'] = await _testEndpoint('GET', '/menstrual-cycles/current?userId=1');
    results['menstrual_cycles_predictions'] = await _testEndpoint('GET', '/menstrual-cycles/predictions?userId=1');

    // Test Medications endpoints
    results['medications_get'] = await _testEndpoint('GET', '/medications');
    results['medications_create'] = await _testEndpoint('POST', '/medications');
    results['medications_active'] = await _testEndpoint('GET', '/medications/active');

    // Test Contraception endpoints
    results['contraception_get'] = await _testEndpoint('GET', '/contraception');
    results['contraception_create'] = await _testEndpoint('POST', '/contraception');
    results['contraception_active'] = await _testEndpoint('GET', '/contraception/active');
    results['contraception_types'] = await _testEndpoint('GET', '/contraception/types');

    // Test Appointments endpoints
    results['appointments_get'] = await _testEndpoint('GET', '/appointments');
    results['appointments_create'] = await _testEndpoint('POST', '/appointments');
    results['appointments_available_slots'] = await _testEndpoint('GET', '/appointments/available-slots?facilityId=1&healthWorkerId=1&date=2024-01-01');

    // Test Messages endpoints
    results['messages_get'] = await _testEndpoint('GET', '/messages');
    results['messages_send'] = await _testEndpoint('POST', '/messages');
    results['messages_conversations'] = await _testEndpoint('GET', '/conversations');
    results['messages_unread'] = await _testEndpoint('GET', '/messages/unread?userId=1');
    results['messages_emergency'] = await _testEndpoint('GET', '/messages/emergency?userId=1');

    // Test Health Facilities endpoints
    results['facilities_get'] = await _testEndpoint('GET', '/facilities');
    results['facilities_nearby'] = await _testEndpoint('GET', '/facilities/nearby?latitude=0&longitude=0');
    results['facilities_create'] = await _testEndpoint('POST', '/facilities');

    // Test Education endpoints
    results['education_lessons'] = await _testEndpoint('GET', '/education/lessons');
    results['education_progress'] = await _testEndpoint('GET', '/education/progress');
    results['education_popular'] = await _testEndpoint('GET', '/education/popular');
    results['education_search'] = await _testEndpoint('GET', '/education/search?query=test');

    // Test Notifications endpoints
    results['notifications_get'] = await _testEndpoint('GET', '/notifications');
    results['notifications_create'] = await _testEndpoint('POST', '/notifications');
    results['notifications_unread'] = await _testEndpoint('GET', '/notifications/unread?userId=1');
    results['notifications_register_device'] = await _testEndpoint('POST', '/notifications/register-device');

    // Test File Upload endpoints
    results['files_upload'] = await _testEndpoint('POST', '/files/upload');
    results['files_upload_multiple'] = await _testEndpoint('POST', '/files/upload-multiple');
    results['files_upload_profile_image'] = await _testEndpoint('POST', '/files/upload/profile-image');
    results['files_upload_health_document'] = await _testEndpoint('POST', '/files/upload/health-document');

    // Test Admin endpoints
    results['admin_users'] = await _testEndpoint('GET', '/admin/users');
    results['admin_create_user'] = await _testEndpoint('POST', '/admin/users');
    results['admin_analytics'] = await _testEndpoint('GET', '/admin/analytics?startDate=2024-01-01&endDate=2024-12-31');
    results['admin_reports'] = await _testEndpoint('GET', '/admin/reports?type=user&startDate=2024-01-01&endDate=2024-12-31');
    results['admin_dashboard_stats'] = await _testEndpoint('GET', '/admin/dashboard/stats');
    results['admin_health_workers'] = await _testEndpoint('GET', '/admin/health-workers');
    results['admin_system_health'] = await _testEndpoint('GET', '/admin/system/health');

    // Test Health Worker endpoints
    results['health_worker_clients'] = await _testEndpoint('GET', '/health-worker/clients');
    results['health_worker_client_details'] = await _testEndpoint('GET', '/health-worker/clients/1');
    results['health_worker_consultations'] = await _testEndpoint('POST', '/health-worker/consultations');
    results['health_worker_appointments'] = await _testEndpoint('GET', '/health-worker/1/appointments');
    results['health_worker_dashboard_stats'] = await _testEndpoint('GET', '/health-worker/1/dashboard/stats');

    // Test Client endpoints
    results['client_profile'] = await _testEndpoint('GET', '/client/1/profile');
    results['client_appointments'] = await _testEndpoint('GET', '/client/1/appointments');
    results['client_book_appointment'] = await _testEndpoint('POST', '/client/1/appointments');
    results['client_health_records'] = await _testEndpoint('GET', '/client/1/health-records');
    results['client_nearby_facilities'] = await _testEndpoint('GET', '/client/1/nearby-facilities');
    results['client_dashboard_stats'] = await _testEndpoint('GET', '/client/1/dashboard/stats');

    return results;
  }

  Future<bool> _testEndpoint(String method, String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _getHeaders());
          break;
        case 'POST':
          response = await http.post(uri, headers: _getHeaders(), body: json.encode({}));
          break;
        case 'PUT':
          response = await http.put(uri, headers: _getHeaders(), body: json.encode({}));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _getHeaders());
          break;
        default:
          return false;
      }

      // Consider endpoint available if it returns any response (even errors)
      // 404 means endpoint doesn't exist, other codes mean it exists but may need auth/data
      return response.statusCode != 404;
    } catch (e) {
      print('Error testing endpoint $method $endpoint: $e');
      return false;
    }
  }

  // Generate compatibility report
  String generateCompatibilityReport(Map<String, bool> results) {
    final total = results.length;
    final available = results.values.where((v) => v).length;
    final percentage = ((available / total) * 100).toStringAsFixed(1);

    final report = StringBuffer();
    report.writeln('🔄 FRONTEND-BACKEND COMPATIBILITY REPORT');
    report.writeln('=' * 50);
    report.writeln('📊 Overall Compatibility: $percentage% ($available/$total endpoints)');
    report.writeln('');

    // Group by category
    final categories = <String, List<MapEntry<String, bool>>>{};
    for (final entry in results.entries) {
      final category = entry.key.split('_')[0];
      categories.putIfAbsent(category, () => []).add(entry);
    }

    for (final category in categories.keys) {
      final categoryResults = categories[category]!;
      final categoryAvailable = categoryResults.where((e) => e.value).length;
      final categoryTotal = categoryResults.length;
      final categoryPercentage = ((categoryAvailable / categoryTotal) * 100).toStringAsFixed(1);

      report.writeln('📁 ${category.toUpperCase()}: $categoryPercentage% ($categoryAvailable/$categoryTotal)');
      
      for (final result in categoryResults) {
        final status = result.value ? '✅' : '❌';
        report.writeln('  $status ${result.key}');
      }
      report.writeln('');
    }

    return report.toString();
  }
}
