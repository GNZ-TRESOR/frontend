import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';

/// Admin Analytics Screen
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _analyticsData;
  String _selectedPeriod = '30'; // days

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load both analytics and dashboard stats
      final analyticsResponse = await ApiService.instance.getAnalytics(
        days: int.parse(_selectedPeriod),
      );

      final dashboardResponse = await ApiService.instance.getDashboardStats();

      if (analyticsResponse.success && dashboardResponse.success) {
        // Handle analytics response - it doesn't have 'data' field, analytics is at root level
        Map<String, dynamic> analyticsData = {};
        if (analyticsResponse.data != null) {
          // If data exists, try to extract analytics from it
          if (analyticsResponse.data is Map<String, dynamic>) {
            analyticsData =
                (analyticsResponse.data['analytics']
                    as Map<String, dynamic>?) ??
                {};
          }
        } else {
          // If data is null, the analytics might be in the raw response
          // We need to get it from the raw response, but for now use empty map
          analyticsData = {};
        }

        // Dashboard response: the data field contains the stats directly
        Map<String, dynamic> dashboardData = {};
        if (dashboardResponse.data != null &&
            dashboardResponse.data is Map<String, dynamic>) {
          dashboardData = Map<String, dynamic>.from(
            dashboardResponse.data as Map<String, dynamic>,
          );
        }

        _analyticsData = {
          // Analytics data
          ...analyticsData,
          // Dashboard stats data
          ...dashboardData,
          // Map some fields for compatibility
          'newUsers': analyticsData['newUsersThisMonth'] ?? 0,
          'dailyActiveUsers': analyticsData['activeUsers'] ?? 0,
          'monthlyActiveUsers': analyticsData['activeUsers'] ?? 0,
          'retentionRate': 85, // Mock data for now
          'newHealthRecords': dashboardData['totalHealthRecords'] ?? 0,
          'newAppointments': dashboardData['totalAppointments'] ?? 0,
          'activeMedications': 0, // Mock data
          'cycleTrackingUsers': 0, // Mock data
          'communityEvents': 0, // Mock data
          'eventRegistrations': 0, // Mock data
          'messagesSent': 0, // Mock data
          'feedbackCount': 0, // Mock data
          'systemUptime': 99.9, // Mock data
          'avgResponseTime': 120, // Mock data
          'errorRate': 0.1, // Mock data
          'databaseHealth': 'Healthy', // Mock data
        };
      } else {
        _error =
            analyticsResponse.message ??
            dashboardResponse.message ??
            'Failed to load analytics';
      }
    } catch (e) {
      _error = 'Error loading analytics: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Platform Analytics'),
        backgroundColor: AppColors.adminPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: '7', child: Text('Last 7 days')),
                  const PopupMenuItem(value: '30', child: Text('Last 30 days')),
                  const PopupMenuItem(value: '90', child: Text('Last 90 days')),
                  const PopupMenuItem(value: '365', child: Text('Last year')),
                ],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.date_range),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _error != null
                ? _buildErrorState()
                : _analyticsData != null
                ? _buildAnalyticsContent()
                : const Center(child: Text('No data available')),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodHeader(),
            const SizedBox(height: 20),
            _buildOverviewCards(),
            const SizedBox(height: 20),
            _buildUserMetrics(),
            const SizedBox(height: 20),
            _buildHealthMetrics(),
            const SizedBox(height: 20),
            _buildEngagementMetrics(),
            const SizedBox(height: 20),
            _buildSystemHealth(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.adminPurple,
            AppColors.adminPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Last $_selectedPeriod days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final data = _analyticsData ?? <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard(
              'Total Users',
              data['totalUsers']?.toString() ?? '0',
              Icons.people,
              AppColors.primary,
            ),
            _buildMetricCard(
              'Active Users',
              data['activeUsers']?.toString() ?? '0',
              Icons.person_outline,
              AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard(
              'Health Records',
              data['totalHealthRecords']?.toString() ?? '0',
              Icons.medical_information,
              AppColors.healthRecordGreen,
            ),
            _buildMetricCard(
              'Appointments',
              data['totalAppointments']?.toString() ?? '0',
              Icons.calendar_today,
              AppColors.appointmentBlue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMetrics() {
    final data = _analyticsData ?? <String, dynamic>{};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'User Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsRow(
              'New Registrations',
              data['newUsers']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Daily Active Users',
              data['dailyActiveUsers']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Monthly Active Users',
              data['monthlyActiveUsers']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'User Retention Rate',
              '${data['retentionRate']?.toString() ?? '0'}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetrics() {
    final data = _analyticsData ?? <String, dynamic>{};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: AppColors.healthRecordGreen,
                ),
                SizedBox(width: 8),
                Text(
                  'Health Data Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsRow(
              'Health Records Created',
              data['newHealthRecords']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Appointments Booked',
              data['newAppointments']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Medications Tracked',
              data['activeMedications']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Cycle Tracking Users',
              data['cycleTrackingUsers']?.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    final data = _analyticsData ?? <String, dynamic>{};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Engagement Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsRow(
              'Community Events',
              data['communityEvents']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Event Registrations',
              data['eventRegistrations']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Messages Sent',
              data['messagesSent']?.toString() ?? '0',
            ),
            _buildAnalyticsRow(
              'Feedback Submitted',
              data['feedbackCount']?.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
    final data = _analyticsData ?? <String, dynamic>{};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_heart, color: AppColors.error),
                SizedBox(width: 8),
                Text(
                  'System Health',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsRow(
              'System Uptime',
              '${data['systemUptime']?.toString() ?? '99.9'}%',
            ),
            _buildAnalyticsRow(
              'API Response Time',
              '${data['avgResponseTime']?.toString() ?? '120'}ms',
            ),
            _buildAnalyticsRow(
              'Error Rate',
              '${data['errorRate']?.toString() ?? '0.1'}%',
            ),
            _buildAnalyticsRow(
              'Database Health',
              data['databaseHealth'] ?? 'Healthy',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
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
            'Error loading analytics',
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
            onPressed: _loadAnalytics,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPurple,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
