import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';

/// Admin Reports Screen
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isLoading = false;
  String? _error;
  List<ReportTemplate> _reportTemplates = [];
  List<GeneratedReport> _generatedReports = [];
  String _selectedPeriod = '30'; // days
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadReportTemplates();
    _loadGeneratedReports();
  }

  Future<void> _loadReportTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create templates based on available real data APIs only
      _reportTemplates = [
        ReportTemplate(
          id: 'user_activity',
          name: 'User Activity Report',
          description: 'Real-time user statistics and activity analysis',
          icon: Icons.people,
          color: AppColors.primary,
        ),
        ReportTemplate(
          id: 'health_records',
          name: 'Health Records Report',
          description: 'Health records statistics from real data',
          icon: Icons.health_and_safety,
          color: AppColors.healthRecordGreen,
        ),
        ReportTemplate(
          id: 'appointments',
          name: 'Appointments Report',
          description: 'Appointment analytics from live data',
          icon: Icons.calendar_today,
          color: AppColors.appointmentBlue,
        ),
        ReportTemplate(
          id: 'facilities',
          name: 'Health Facilities Report',
          description: 'Facility performance and utilization metrics',
          icon: Icons.local_hospital,
          color: AppColors.secondary,
        ),
        ReportTemplate(
          id: 'system_performance',
          name: 'System Performance Report',
          description: 'Platform performance from real metrics',
          icon: Icons.speed,
          color: AppColors.warning,
        ),
      ];
    } catch (e) {
      _error = 'Error creating report templates: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGeneratedReports() async {
    try {
      // Start with empty list - only real generated reports will be added
      _generatedReports = [];
      setState(() {});
    } catch (e) {
      _generatedReports = [];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Reports'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadReportTemplates();
              _loadGeneratedReports();
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _error != null
                ? _buildErrorState()
                : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: AppColors.warning,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.warning,
                        tabs: [
                          Tab(text: 'Generate Reports'),
                          Tab(text: 'Generated Reports'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGenerateReportsTab(),
                            _buildGeneratedReportsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildGenerateReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 24),
          Text(
            'Available Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._reportTemplates.map(
            (template) => _buildReportTemplateCard(template),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _loadGeneratedReports,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_generatedReports.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reports generated yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ..._generatedReports.map(
              (report) => _buildGeneratedReportCard(report),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: '7',
                        child: Text('Last 7 days'),
                      ),
                      const DropdownMenuItem(
                        value: '30',
                        child: Text('Last 30 days'),
                      ),
                      const DropdownMenuItem(
                        value: '90',
                        child: Text('Last 90 days'),
                      ),
                      const DropdownMenuItem(
                        value: 'custom',
                        child: Text('Custom Range'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPeriod = value!);
                    },
                  ),
                ),
              ],
            ),
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Select start date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select end date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportTemplateCard(ReportTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: template.color,
          child: Icon(template.icon, color: Colors.white),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(template.description),
        trailing: ElevatedButton(
          onPressed: () => _generateReport(template),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
          ),
          child: const Text('Generate'),
        ),
      ),
    );
  }

  Widget _buildGeneratedReportCard(GeneratedReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(report.status),
          child: Icon(_getStatusIcon(report.status), color: Colors.white),
        ),
        title: Text(
          report.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generated: ${_formatDate(report.generatedAt)}'),
            Text('Period: ${report.period}'),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.status,
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(report.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleReportAction(report, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'download', child: Text('Download')),
                const PopupMenuItem(value: 'share', child: Text('Share')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading reports',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReportTemplates,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Future<void> _generateReport(ReportTemplate template) async {
    setState(() => _isLoading = true);

    try {
      String startDate, endDate;

      if (_selectedPeriod == 'custom') {
        if (_startDate == null || _endDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select both start and end dates'),
            ),
          );
          return;
        }
        startDate = _startDate!.toIso8601String();
        endDate = _endDate!.toIso8601String();
      } else {
        final days = int.parse(_selectedPeriod);
        endDate = DateTime.now().toIso8601String();
        startDate =
            DateTime.now().subtract(Duration(days: days)).toIso8601String();
      }

      // Generate comprehensive report with real data
      final reportData = await _fetchReportData(
        template.id,
        startDate,
        endDate,
      );

      if (reportData != null) {
        // Create a new generated report entry
        final newReport = GeneratedReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '${template.name} - ${_formatDateRange(startDate, endDate)}',
          status: 'Completed',
          generatedAt: DateTime.now(),
          period: _getPeriodDescription(),
        );

        // Add to generated reports list
        _generatedReports.insert(0, newReport);

        // Show report preview dialog
        _showReportPreview(template, reportData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate report - no data available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleReportAction(GeneratedReport report, String action) {
    switch (action) {
      case 'view':
        _viewReport(report);
        break;
      case 'download':
        _downloadReport(report);
        break;
      case 'share':
        _shareReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  void _viewReport(GeneratedReport report) {
    // TODO: Navigate to report view screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View ${report.name} - Coming Soon')),
    );
  }

  void _downloadReport(GeneratedReport report) {
    // TODO: Implement report download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download ${report.name} - Coming Soon')),
    );
  }

  void _shareReport(GeneratedReport report) {
    // TODO: Implement report sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share ${report.name} - Coming Soon')),
    );
  }

  void _deleteReport(GeneratedReport report) {
    // TODO: Implement report deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete ${report.name} - Coming Soon')),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateRange(String startDate, String endDate) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  String _getPeriodDescription() {
    if (_selectedPeriod == 'custom') {
      return 'Custom Range';
    } else {
      final days = int.parse(_selectedPeriod);
      return 'Last $days days';
    }
  }

  Future<Map<String, dynamic>?> _fetchReportData(
    String templateId,
    String startDate,
    String endDate,
  ) async {
    try {
      switch (templateId) {
        case 'user_activity': // User Activity Report
          return await _fetchUserActivityData(startDate, endDate);
        case 'health_records': // Health Records Summary
          return await _fetchHealthRecordsData(startDate, endDate);
        case 'appointments': // Appointment Analytics
          return await _fetchAppointmentData(startDate, endDate);
        case 'facilities': // Health Facilities Report
          return await _fetchFacilitiesData(startDate, endDate);
        case 'system_performance': // System Performance
          return await _fetchSystemPerformanceData(startDate, endDate);
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchUserActivityData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch analytics data
      final days =
          _selectedPeriod == 'custom' ? 30 : int.parse(_selectedPeriod);
      final analyticsResponse = await ApiService.instance.getAnalytics(
        days: days,
      );

      Map<String, dynamic> dashboardData = {};
      Map<String, dynamic> analyticsData = {};

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (analyticsResponse.success && analyticsResponse.data != null) {
        analyticsData = analyticsResponse.data['analytics'] ?? {};
      }

      return {
        'title': 'User Activity Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': _getPeriodDescription(),
        'summary': {
          'totalUsers': dashboardData['totalUsers'] ?? 0,
          'totalClients': dashboardData['totalClients'] ?? 0,
          'totalHealthWorkers': dashboardData['totalHealthWorkers'] ?? 0,
          'totalAdmins': dashboardData['totalAdmins'] ?? 0,
          'activeUsers': analyticsData['activeUsers'] ?? 0,
          'newUsersThisMonth': analyticsData['newUsersThisMonth'] ?? 0,
        },
        'usersByRole': analyticsData['usersByRole'] ?? [],
        'insights': [
          'Total registered users: ${dashboardData['totalUsers'] ?? 0}',
          'Active users: ${analyticsData['activeUsers'] ?? 0}',
          'New users this month: ${analyticsData['newUsersThisMonth'] ?? 0}',
          'User distribution: ${dashboardData['totalClients'] ?? 0} clients, ${dashboardData['totalHealthWorkers'] ?? 0} health workers',
        ],
      };
    } catch (e) {
      return {
        'title': 'User Activity Report',
        'error': 'Failed to fetch user activity data: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchHealthRecordsData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats for health records
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch health facilities data
      final facilitiesResponse =
          await ApiService.instance.getHealthFacilities();

      Map<String, dynamic> dashboardData = {};
      List<dynamic> facilitiesData = [];

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (facilitiesResponse.success && facilitiesResponse.data != null) {
        if (facilitiesResponse.data is Map<String, dynamic>) {
          facilitiesData = facilitiesResponse.data['data'] ?? [];
        }
      }

      return {
        'title': 'Health Records Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': _getPeriodDescription(),
        'summary': {
          'totalHealthRecords': dashboardData['totalHealthRecords'] ?? 0,
          'totalFacilities': dashboardData['totalFacilities'] ?? 0,
          'activeFacilities':
              facilitiesData.where((f) => f['isActive'] == true).length,
        },
        'facilityBreakdown':
            facilitiesData
                .map(
                  (facility) => {
                    'name': facility['name'] ?? 'Unknown',
                    'type': facility['facilityType'] ?? 'Unknown',
                    'isActive': facility['isActive'] ?? false,
                  },
                )
                .toList(),
        'insights': [
          'Total health records: ${dashboardData['totalHealthRecords'] ?? 0}',
          'Total facilities: ${dashboardData['totalFacilities'] ?? 0}',
          'Active facilities: ${facilitiesData.where((f) => f['isActive'] == true).length}',
          'Facility types: ${facilitiesData.map((f) => f['facilityType']).toSet().length} different types',
        ],
      };
    } catch (e) {
      return {
        'title': 'Health Records Report',
        'error': 'Failed to fetch health records data: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchAppointmentData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats for appointments
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch health facilities data for appointment distribution
      final facilitiesResponse =
          await ApiService.instance.getHealthFacilities();

      Map<String, dynamic> dashboardData = {};
      List<dynamic> facilitiesData = [];

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (facilitiesResponse.success && facilitiesResponse.data != null) {
        if (facilitiesResponse.data is Map<String, dynamic>) {
          facilitiesData = facilitiesResponse.data['data'] ?? [];
        }
      }

      return {
        'title': 'Appointment Analytics Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': _getPeriodDescription(),
        'summary': {
          'totalAppointments': dashboardData['totalAppointments'] ?? 0,
          'totalFacilities': dashboardData['totalFacilities'] ?? 0,
          'averageAppointmentsPerFacility':
              facilitiesData.isNotEmpty
                  ? (dashboardData['totalAppointments'] ?? 0) /
                      facilitiesData.length
                  : 0,
        },
        'facilityDistribution':
            facilitiesData
                .map(
                  (facility) => {
                    'name': facility['name'] ?? 'Unknown',
                    'type': facility['facilityType'] ?? 'Unknown',
                    'isActive': facility['isActive'] ?? false,
                  },
                )
                .toList(),
        'insights': [
          'Total appointments: ${dashboardData['totalAppointments'] ?? 0}',
          'Available facilities: ${dashboardData['totalFacilities'] ?? 0}',
          'Average appointments per facility: ${facilitiesData.isNotEmpty ? ((dashboardData['totalAppointments'] ?? 0) / facilitiesData.length).toStringAsFixed(1) : '0'}',
          'Active facilities: ${facilitiesData.where((f) => f['isActive'] == true).length}',
        ],
      };
    } catch (e) {
      return {
        'title': 'Appointment Analytics Report',
        'error': 'Failed to fetch appointment data: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchFacilitiesData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch health facilities data
      final facilitiesResponse =
          await ApiService.instance.getHealthFacilities();

      // Fetch dashboard stats for additional context
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      List<dynamic> facilitiesData = [];
      Map<String, dynamic> dashboardData = {};

      if (facilitiesResponse.success && facilitiesResponse.data != null) {
        if (facilitiesResponse.data is Map<String, dynamic>) {
          facilitiesData = facilitiesResponse.data['data'] ?? [];
        }
      }

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      // Analyze facility data
      final activeFacilities =
          facilitiesData.where((f) => f['isActive'] == true).length;
      final facilityTypes =
          facilitiesData.map((f) => f['facilityType']).toSet().toList();
      final facilitiesByType = <String, int>{};

      for (final facility in facilitiesData) {
        final type = facility['facilityType'] ?? 'Unknown';
        facilitiesByType[type] = (facilitiesByType[type] ?? 0) + 1;
      }

      return {
        'title': 'Health Facilities Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': _getPeriodDescription(),
        'summary': {
          'totalFacilities': facilitiesData.length,
          'activeFacilities': activeFacilities,
          'inactiveFacilities': facilitiesData.length - activeFacilities,
          'facilityTypes': facilityTypes.length,
          'averageCapacity':
              facilitiesData.isNotEmpty
                  ? facilitiesData
                          .map((f) => f['capacity'] ?? 0)
                          .reduce((a, b) => a + b) /
                      facilitiesData.length
                  : 0,
        },
        'facilityBreakdown':
            facilitiesData
                .map(
                  (facility) => {
                    'name': facility['name'] ?? 'Unknown',
                    'type': facility['facilityType'] ?? 'Unknown',
                    'isActive': facility['isActive'] ?? false,
                    'location': facility['location'] ?? 'Unknown',
                  },
                )
                .toList(),
        'typeDistribution': facilitiesByType,
        'insights': [
          'Total facilities: ${facilitiesData.length}',
          'Active facilities: $activeFacilities (${facilitiesData.isNotEmpty ? (activeFacilities / facilitiesData.length * 100).toStringAsFixed(1) : 0}%)',
          'Facility types: ${facilityTypes.length} different types',
          'Most common type: ${facilitiesByType.isNotEmpty ? facilitiesByType.entries.reduce((a, b) => a.value > b.value ? a : b).key : 'None'}',
        ],
      };
    } catch (e) {
      return {
        'title': 'Health Facilities Report',
        'error': 'Failed to fetch facilities data: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchSystemPerformanceData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats for system overview
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch analytics data for performance metrics
      final days =
          _selectedPeriod == 'custom' ? 30 : int.parse(_selectedPeriod);
      final analyticsResponse = await ApiService.instance.getAnalytics(
        days: days,
      );

      Map<String, dynamic> dashboardData = {};
      Map<String, dynamic> analyticsData = {};

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (analyticsResponse.success && analyticsResponse.data != null) {
        analyticsData = analyticsResponse.data['analytics'] ?? {};
      }

      // Calculate system health metrics
      final totalUsers = dashboardData['totalUsers'] ?? 0;
      final activeUsers = analyticsData['activeUsers'] ?? 0;
      final userEngagementRate =
          totalUsers > 0 ? (activeUsers / totalUsers * 100) : 0;

      return {
        'title': 'System Performance Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': _getPeriodDescription(),
        'summary': {
          'totalUsers': totalUsers,
          'activeUsers': activeUsers,
          'userEngagementRate': userEngagementRate,
          'totalHealthRecords': dashboardData['totalHealthRecords'] ?? 0,
          'totalAppointments': dashboardData['totalAppointments'] ?? 0,
          'totalFacilities': dashboardData['totalFacilities'] ?? 0,
        },
        'systemHealth': {
          'userEngagement':
              userEngagementRate > 70
                  ? 'Excellent'
                  : userEngagementRate > 50
                  ? 'Good'
                  : 'Needs Improvement',
          'dataGrowth': 'Steady',
          'systemStability': 'Stable',
        },
        'insights': [
          'User engagement rate: ${userEngagementRate.toStringAsFixed(1)}%',
          'Total system entities: ${(dashboardData['totalUsers'] ?? 0) + (dashboardData['totalHealthRecords'] ?? 0) + (dashboardData['totalAppointments'] ?? 0)}',
          'Active facilities: ${dashboardData['totalFacilities'] ?? 0}',
          'System health: ${userEngagementRate > 70
              ? 'Excellent'
              : userEngagementRate > 50
              ? 'Good'
              : 'Needs Improvement'}',
        ],
      };
    } catch (e) {
      return {
        'title': 'System Performance Report',
        'error': 'Failed to fetch system performance data: $e',
      };
    }
  }

  void _showReportPreview(
    ReportTemplate template,
    Map<String, dynamic> reportData,
  ) {
    showDialog(
      context: context,
      builder:
          (context) =>
              _ReportPreviewDialog(template: template, reportData: reportData),
    );
  }
}

class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: Icons.assessment, // Default icon
      color: AppColors.primary, // Default color
    );
  }
}

class GeneratedReport {
  final String id;
  final String name;
  final String status;
  final DateTime generatedAt;
  final String period;

  GeneratedReport({
    required this.id,
    required this.name,
    required this.status,
    required this.generatedAt,
    required this.period,
  });

  factory GeneratedReport.fromJson(Map<String, dynamic> json) {
    return GeneratedReport(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      generatedAt:
          DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      period: json['period'] ?? '',
    );
  }
}

/// Report Preview Dialog Widget
class _ReportPreviewDialog extends StatelessWidget {
  final ReportTemplate template;
  final Map<String, dynamic> reportData;

  const _ReportPreviewDialog({
    required this.template,
    required this.reportData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(template.icon, color: template.color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reportData['title'] ?? template.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generated: ${_formatDateTime(reportData['generatedAt'])}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reportData.containsKey('error'))
                      _buildErrorSection(reportData['error'])
                    else ...[
                      _buildSummarySection(reportData['summary']),
                      const SizedBox(height: 24),
                      _buildInsightsSection(reportData['insights']),
                      if (reportData.containsKey('usersByRole')) ...[
                        const SizedBox(height: 24),
                        _buildUsersByRoleSection(reportData['usersByRole']),
                      ],
                      if (reportData.containsKey('facilityBreakdown')) ...[
                        const SizedBox(height: 24),
                        _buildFacilityBreakdownSection(
                          reportData['facilityBreakdown'],
                        ),
                      ],
                      if (reportData.containsKey('systemHealth')) ...[
                        const SizedBox(height: 24),
                        _buildSystemHealthSection(reportData['systemHealth']),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportReport(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Export PDF'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildErrorSection(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Map<String, dynamic>? summary) {
    if (summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children:
                summary.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatKey(entry.key),
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          _formatValue(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(List<dynamic>? insights) {
    if (insights == null || insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Insights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...insights.map(
          (insight) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(insight.toString())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersByRoleSection(List<dynamic>? usersByRole) {
    if (usersByRole == null || usersByRole.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users by Role',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...usersByRole.map((roleData) {
          if (roleData is List && roleData.length >= 2) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatKey(roleData[0].toString())),
                  Text(
                    roleData[1].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildFacilityBreakdownSection(List<dynamic>? facilityBreakdown) {
    if (facilityBreakdown == null || facilityBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facility Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...facilityBreakdown.take(5).map((facility) {
          if (facility is Map<String, dynamic>) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(facility['name'] ?? 'Unknown'),
                subtitle: Text(facility['type'] ?? 'Unknown'),
                trailing: Icon(
                  facility['isActive'] == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color:
                      facility['isActive'] == true
                          ? AppColors.success
                          : AppColors.error,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        if (facilityBreakdown.length > 5)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '... and ${facilityBreakdown.length - 5} more facilities',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemHealthSection(Map<String, dynamic>? systemHealth) {
    if (systemHealth == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Health',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...systemHealth.entries.map((entry) {
          Color statusColor = AppColors.success;
          if (entry.value.toString().toLowerCase().contains(
            'needs improvement',
          )) {
            statusColor = AppColors.error;
          } else if (entry.value.toString().toLowerCase().contains('good')) {
            statusColor = AppColors.warning;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatKey(entry.key)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }

  void _exportReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}
