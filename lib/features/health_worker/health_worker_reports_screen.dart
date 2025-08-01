import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';

/// Health Worker Reports Screen
class HealthWorkerReportsScreen extends ConsumerStatefulWidget {
  const HealthWorkerReportsScreen({super.key});

  @override
  ConsumerState<HealthWorkerReportsScreen> createState() => _HealthWorkerReportsScreenState();
}

class _HealthWorkerReportsScreenState extends ConsumerState<HealthWorkerReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _dashboardStats;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getHealthWorkerDashboardStats(user!.id!);
      
      if (response.success && response.data != null) {
        _dashboardStats = response.data;
        // TODO: Load recent activities
        _recentActivities = []; // Placeholder
      } else {
        _error = response.message ?? 'Failed to load dashboard data';
      }
    } catch (e) {
      _error = 'Error loading dashboard: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: AppColors.healthWorkerBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Performance'),
            Tab(text: 'Activities'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _error != null
            ? _buildErrorState()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPerformanceTab(),
                  _buildActivitiesTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_dashboardStats == null) {
      return const Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 20),
            _buildTodaySchedule(),
            const SizedBox(height: 20),
            _buildClientSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = _dashboardStats!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              'Total Clients',
              stats['totalClients']?.toString() ?? '0',
              Icons.people,
              AppColors.primary,
            ),
            _buildStatCard(
              'Today\'s Appointments',
              stats['todayAppointments']?.toString() ?? '0',
              Icons.calendar_today,
              AppColors.appointmentBlue,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              'Completed',
              stats['completedAppointments']?.toString() ?? '0',
              Icons.check_circle,
              AppColors.success,
            ),
            _buildStatCard(
              'Pending',
              stats['pendingAppointments']?.toString() ?? '0',
              Icons.schedule,
              AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.schedule, color: AppColors.appointmentBlue),
                SizedBox(width: 8),
                Text(
                  'Today\'s Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Add actual schedule items
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('No appointments scheduled for today'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: AppColors.healthWorkerBlue),
                SizedBox(width: 8),
                Text(
                  'Client Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Active Clients', _dashboardStats!['totalClients']?.toString() ?? '0'),
            _buildSummaryRow('New This Month', '0'), // TODO: Add actual data
            _buildSummaryRow('High Priority', '0'), // TODO: Add actual data
            _buildSummaryRow('Follow-ups Needed', '0'), // TODO: Add actual data
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceMetrics(),
            const SizedBox(height: 20),
            _buildMonthlyTrends(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Appointment Completion Rate', '95%', AppColors.success),
            _buildMetricRow('Client Satisfaction', '4.8/5', AppColors.success),
            _buildMetricRow('Response Time', '< 2 hours', AppColors.success),
            _buildMetricRow('Follow-up Rate', '88%', AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrends() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Monthly Trends',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart visualization coming soon',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _recentActivities.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No recent activities',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recentActivities.length,
              itemBuilder: (context, index) {
                final activity = _recentActivities[index];
                return _buildActivityCard(activity);
              },
            ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.healthWorkerBlue,
          child: Icon(
            Icons.medical_services,
            color: Colors.white,
          ),
        ),
        title: Text(activity['title'] ?? 'Activity'),
        subtitle: Text(activity['description'] ?? 'No description'),
        trailing: Text(
          activity['time'] ?? 'Unknown time',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
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
          Text('Error loading reports', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.healthWorkerBlue),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
