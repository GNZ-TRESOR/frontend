import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/models/api_response.dart';
import '../../core/widgets/loading_overlay.dart';

/// Clean, Simple Reports Screen - Displays Real Database Data
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isLoading = false;
  String? _error;

  // Real data from APIs
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _analyticsData;
  List<dynamic>? _users;
  List<dynamic>? _healthWorkers;
  List<dynamic>? _facilities;
  List<dynamic>? _healthRecords;
  List<dynamic>? _appointments;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all real data from backend APIs with individual error handling
      final results = await Future.wait([
        ApiService.instance.getDashboardStats().catchError((e) {
          print('Dashboard stats error: $e');
          return ApiResponse.error(message: 'Dashboard stats failed');
        }),
        ApiService.instance.getAnalytics(days: 30).catchError((e) {
          print('Analytics error: $e');
          return ApiResponse.error(message: 'Analytics failed');
        }),
                ApiService.instance.getAllUsers().catchError((e) {
          print('Admin users error: $e');
          return ApiResponse.error(message: 'Admin users failed');
        }),
                ApiService.instance.getAllUsers(role: 'HEALTH_WORKER').catchError((e) {
          print('Health workers error: $e');
          return ApiResponse.error(message: 'Health workers failed');
        }),
        ApiService.instance.getHealthFacilities().catchError((e) {
          print('Health facilities error: $e');
          return ApiResponse.error(message: 'Health facilities failed');
        }),
        _getAdminHealthRecords().catchError((e) {
          print('Health records error: $e');
          return ApiResponse.error(message: 'Health records failed');
        }),
                ApiService.instance.getAdminAppointments().catchError((e) {
          print('Appointments error: $e');
          return ApiResponse.error(message: 'Appointments failed');
        }),
      ]);

      print('Results array length: ${results.length}');
      for (int i = 0; i < results.length; i++) {
        print(
          'Result $i: success=${results[i].success}, data type=${results[i].data.runtimeType}',
        );
      }

      // Process dashboard stats
      try {
        if (results[0].success && results[0].data != null) {
          print('Dashboard stats raw response: ${results[0]}');
          print('Dashboard stats data: ${results[0].data}');
          // The data is already the stats object (ApiResponse extracts it)
          _dashboardStats = results[0].data;
          print('Dashboard stats assigned: $_dashboardStats');
        }
      } catch (e) {
        print('Error processing dashboard stats: $e');
      }

      // Process analytics
      try {
        if (results[1].success && results[1].data != null) {
          print('Analytics data: ${results[1].data}');
          _analyticsData = results[1].data['analytics'];
          print('Analytics data assigned: $_analyticsData');
        }
      } catch (e) {
        print('Error processing analytics: $e');
      }

      // Process users
      try {
        if (results[2].success && results[2].data != null) {
          print('Users data: ${results[2].data}');
          _users = results[2].data['users'] ?? results[2].data['data'];
          print('Users assigned: ${_users?.length} users');
        }
      } catch (e) {
        print('Error processing users: $e');
      }

      // Process health workers
      try {
        if (results[3].success && results[3].data != null) {
          print('Health workers data: ${results[3].data}');
          // Data is already in the correct format (List)
          _healthWorkers = results[3].data as List?;
          print('Health workers assigned: ${_healthWorkers?.length} workers');
        }
      } catch (e) {
        print('Error processing health workers: $e');
        _healthWorkers = []; // Fallback to empty list
      }

      // Process facilities
      try {
        if (results[4].success && results[4].data != null) {
          print('Facilities data: ${results[4].data}');
          // Data is already in the correct format (List)
          _facilities = results[4].data as List?;
          print('Facilities assigned: ${_facilities?.length} facilities');
        }
      } catch (e) {
        print('Error processing facilities: $e');
        _facilities = []; // Fallback to empty list
      }

      // Process health records
      try {
        if (results[5].success && results[5].data != null) {
          print('Health records data: ${results[5].data}');
          // Data is already in the correct format (List)
          _healthRecords = results[5].data as List?;
          print('Health records assigned: ${_healthRecords?.length} records');
        }
      } catch (e) {
        print('Error processing health records: $e');
        _healthRecords = []; // Fallback to empty list
      }

      // Process appointments
      try {
        if (results[6].success && results[6].data != null) {
          print('Appointments data: ${results[6].data}');
          // Data is already in the correct format (List)
          _appointments = results[6].data as List?;
          print('Appointments assigned: ${_appointments?.length} appointments');
        }
      } catch (e) {
        print('Error processing appointments: $e');
        _appointments = []; // Fallback to empty list
      }
    } catch (e) {
      // Don't show error if we have some data loaded
      if (_dashboardStats == null && _analyticsData == null) {
        _error = 'Failed to load data: $e';
      }
      print('Complete error in _loadAllData: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _error != null ? _buildErrorState() : _buildReportsContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadAllData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSystemOverview(),
          const SizedBox(height: 24),
          _buildUsersReport(),
          const SizedBox(height: 24),
          _buildFacilitiesReport(),
          const SizedBox(height: 24),
          _buildHealthRecordsReport(),
          const SizedBox(height: 24),
          _buildAppointmentsReport(),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'System Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboardStats != null) ...[
              _buildStatRow(
                'Total Users',
                _dashboardStats!['totalUsers']?.toString() ?? '0',
              ),
              _buildStatRow(
                'Total Clients',
                _dashboardStats!['totalClients']?.toString() ?? '0',
              ),
              _buildStatRow(
                'Health Workers',
                _dashboardStats!['totalHealthWorkers']?.toString() ?? '0',
              ),
              _buildStatRow(
                'Administrators',
                _dashboardStats!['totalAdmins']?.toString() ?? '0',
              ),
              _buildStatRow(
                'Health Facilities',
                _dashboardStats!['totalFacilities']?.toString() ?? '0',
              ),
              _buildStatRow(
                'Health Records',
                _dashboardStats!['totalHealthRecords']?.toString() ?? '0',
              ),
              _buildStatRow(
                'Total Appointments',
                _dashboardStats!['totalAppointments']?.toString() ?? '0',
              ),
            ] else
              const Text('No dashboard data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersReport() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Users Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_analyticsData != null) ...[
              _buildStatRow(
                'Active Users',
                _analyticsData!['activeUsers']?.toString() ?? '0',
              ),
              _buildStatRow(
                'New Users This Month',
                _analyticsData!['newUsersThisMonth']?.toString() ?? '0',
              ),
              if (_analyticsData!['usersByRole'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Users by Role:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._buildUsersByRole(_analyticsData!['usersByRole']),
              ],
            ] else
              const Text('No analytics data available'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUsersByRole(dynamic usersByRole) {
    try {
      if (usersByRole is List) {
        return usersByRole.map<Widget>((roleData) {
          try {
            if (roleData is List && roleData.length >= 2) {
              // Handle array format: [["admin", 1], ["client", 1]]
              return _buildStatRow(
                _formatRoleName(roleData[0].toString()),
                roleData[1].toString(),
              );
            } else if (roleData is Map<String, dynamic>) {
              // Handle object format: {'role': 'Client', 'count': 1}
              return _buildStatRow(
                _formatRoleName(roleData['role']?.toString() ?? ''),
                roleData['count']?.toString() ?? '0',
              );
            }
            return const SizedBox.shrink();
          } catch (e) {
            print('Error processing role data: $e');
            return const SizedBox.shrink();
          }
        }).toList();
      } else if (usersByRole is Map<String, dynamic>) {
        // Handle map format: {"admin": 1, "client": 2}
        return usersByRole.entries.map<Widget>((entry) {
          return _buildStatRow(
            _formatRoleName(entry.key),
            entry.value.toString(),
          );
        }).toList();
      }
      return [const Text('Invalid role data format')];
    } catch (e) {
      print('Error in _buildUsersByRole: $e');
      return [Text('Error displaying role data: $e')];
    }
  }

  String _formatRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrators';
      case 'client':
        return 'Clients';
      case 'healthworker':
      case 'health_worker':
        return 'Health Workers';
      default:
        return role;
    }
  }

  Widget _buildFacilitiesReport() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Health Facilities Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_facilities != null) ...[
              _buildStatRow('Total Facilities', _facilities!.length.toString()),
              if (_facilities!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Recent Facilities:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._facilities!.take(3).map((facility) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            facility['name']?.toString() ?? 'Unknown Facility',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ] else
              const Text('No facilities data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecordsReport() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Health Records Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_healthRecords != null) ...[
              _buildStatRow(
                'Total Health Records',
                _healthRecords!.length.toString(),
              ),
              if (_healthRecords!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Record Types:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._getRecordTypeCounts().entries.map((entry) {
                  return _buildStatRow(entry.key, entry.value.toString());
                }).toList(),
              ],
            ] else
              const Text('No health records data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsReport() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Appointments Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_appointments != null) ...[
              _buildStatRow(
                'Total Appointments',
                _appointments!.length.toString(),
              ),
              if (_appointments!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Appointment Status:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._getAppointmentStatusCounts().entries.map((entry) {
                  return _buildStatRow(entry.key, entry.value.toString());
                }).toList(),
              ],
            ] else
              const Text('No appointments data available'),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getRecordTypeCounts() {
    if (_healthRecords == null) return {};

    Map<String, int> counts = {};
    for (var record in _healthRecords!) {
      String type = record['type']?.toString() ?? 'Unknown';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _getAppointmentStatusCounts() {
    if (_appointments == null) return {};

    Map<String, int> counts = {};
    for (var appointment in _appointments!) {
      String status = appointment['status']?.toString() ?? 'Unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Get health records using admin endpoint
  Future<ApiResponse> _getAdminHealthRecords() async {
    try {
      final response = await ApiService.instance.dio.get('/health-records');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to fetch health records: $e');
    }
  }
}
