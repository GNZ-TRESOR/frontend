import 'package:dio/dio.dart';
import '../models/health_worker_reports.dart';
import 'api_service.dart';

class HealthWorkerReportsService {
  final ApiService _apiService;

  HealthWorkerReportsService(this._apiService);

  /// Get dashboard statistics using existing endpoints
  Future<HealthWorkerDashboard> getDashboardStats() async {
    try {
      // Use existing contraception endpoints to get basic stats
      final contraceptionResponse = await _apiService.dio.get('/contraception');

      // Create mock dashboard data using existing endpoints
      final contraceptionData = contraceptionResponse.data;
      final totalMethods = contraceptionData['total'] ?? 0;

      // Create a basic dashboard response
      final dashboardData = {
        'totalUsers': 50, // Mock data - would need user endpoint
        'totalMethods': totalMethods,
        'activeMethods': totalMethods,
        'totalSideEffectReports': 0,
        'recentSideEffectReports': 0,
        'methodsDistribution': <String, int>{},
        'recentActivity': <Map<String, dynamic>>[],
      };

      return HealthWorkerDashboard.fromJson(dashboardData);
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  /// Get contraception usage statistics
  Future<ContraceptionUsageStats?> getContraceptionUsageStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.dio.get(
        '/health-worker/reports/contraception-usage',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ContraceptionUsageStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching contraception usage stats: $e');
      return null;
    }
  }

  /// Get side effects statistics
  Future<SideEffectsStats?> getSideEffectsStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.dio.get(
        '/health-worker/reports/side-effects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SideEffectsStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching side effects stats: $e');
      return null;
    }
  }

  /// Get user compliance statistics
  Future<UserComplianceStats?> getUserComplianceStats() async {
    try {
      final response = await _apiService.dio.get(
        '/health-worker/reports/user-compliance',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserComplianceStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching user compliance stats: $e');
      return null;
    }
  }

  /// Get dashboard data
  Future<HealthWorkerDashboard?> getDashboardData() async {
    try {
      final response = await _apiService.dio.get(
        '/health-worker/reports/dashboard',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return HealthWorkerDashboard.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return null;
    }
  }

  /// Record contraceptive usage (for users)
  Future<bool> recordUsage(UsageTrackingEntry entry) async {
    try {
      final response = await _apiService.dio.post(
        '/contraception/usage',
        data: entry.toJson(),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error recording usage: $e');
      return false;
    }
  }

  /// Get user's usage history
  Future<List<UsageTrackingEntry>> getUserUsageHistory(
    int userId, {
    int? methodId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'userId': userId};
      if (methodId != null) queryParams['methodId'] = methodId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.dio.get(
        '/contraception/usage',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> usageData = response.data['data'] ?? [];
        return usageData
            .map((json) => UsageTrackingEntry.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching usage history: $e');
      return [];
    }
  }

  /// Update usage entry
  Future<bool> updateUsage(int entryId, UsageTrackingEntry entry) async {
    try {
      final response = await _apiService.dio.put(
        '/contraception/usage/$entryId',
        data: entry.toJson(),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error updating usage: $e');
      return false;
    }
  }

  /// Delete usage entry
  Future<bool> deleteUsage(int entryId) async {
    try {
      final response = await _apiService.dio.delete(
        '/contraception/usage/$entryId',
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error deleting usage: $e');
      return false;
    }
  }

  /// Export reports data (for health workers)
  Future<String?> exportReportsData({
    String format = 'csv', // csv, excel, pdf
    String? startDate,
    String? endDate,
    List<String>? reportTypes, // ['usage', 'sideEffects', 'compliance']
  }) async {
    try {
      final queryParams = <String, dynamic>{'format': format};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (reportTypes != null)
        queryParams['reportTypes'] = reportTypes.join(',');

      final response = await _apiService.dio.get(
        '/health-worker/reports/export',
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Return base64 encoded data or file path
        // Implementation depends on how you want to handle file downloads
        return response.data.toString();
      }
      return null;
    } catch (e) {
      print('Error exporting reports: $e');
      return null;
    }
  }

  /// Get method effectiveness analysis
  Future<Map<String, dynamic>?> getMethodEffectivenessAnalysis() async {
    try {
      final response = await _apiService.dio.get(
        '/health-worker/reports/effectiveness',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching effectiveness analysis: $e');
      return null;
    }
  }

  /// Get trending side effects
  Future<Map<String, dynamic>?> getTrendingSideEffects({
    String period = 'month', // week, month, quarter, year
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/health-worker/reports/trending-side-effects',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching trending side effects: $e');
      return null;
    }
  }
}
