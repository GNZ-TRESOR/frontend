import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class HealthWorkerReportsScreen extends ConsumerStatefulWidget {
  const HealthWorkerReportsScreen({super.key});

  @override
  ConsumerState<HealthWorkerReportsScreen> createState() =>
      _HealthWorkerReportsScreenState();
}

class _HealthWorkerReportsScreenState
    extends ConsumerState<HealthWorkerReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Report data
  Map<String, dynamic> _userActivityData = {};
  Map<String, dynamic> _healthRecordsData = {};
  Map<String, dynamic> _appointmentsData = {};
  Map<String, dynamic> _dashboardStats = {};

  // Date range for reports
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReportsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportsData() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadDashboardStats(user!.id!),
        _loadUserActivityReport(),
        _loadHealthRecordsReport(),
        _loadAppointmentsReport(),
      ]);
    } catch (e) {
      debugPrint('Error loading reports data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDashboardStats(int healthWorkerId) async {
    try {
      final response = await ApiService.instance.getHealthWorkerDashboardStats(
        healthWorkerId,
      );
      if (response.success && response.data != null) {
        setState(() {
          _dashboardStats = Map<String, dynamic>.from(response.data as Map);
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  Future<void> _loadUserActivityReport() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/reports/user-activity',
        queryParameters: {
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(_endDate),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userActivityData = Map<String, dynamic>.from(response.data);
        });
      }
    } catch (e) {
      debugPrint('Error loading user activity report: $e');
      // Fallback to mock data for development
      _loadMockUserActivityData();
    }
  }

  Future<void> _loadHealthRecordsReport() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/reports/health-records',
        queryParameters: {
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(_endDate),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _healthRecordsData = Map<String, dynamic>.from(response.data);
        });
      }
    } catch (e) {
      debugPrint('Error loading health records report: $e');
      // Fallback to mock data for development
      _loadMockHealthRecordsData();
    }
  }

  Future<void> _loadAppointmentsReport() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/reports/appointments',
        queryParameters: {
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(_endDate),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _appointmentsData = Map<String, dynamic>.from(response.data);
        });
      }
    } catch (e) {
      debugPrint('Error loading appointments report: $e');
      // Fallback to mock data for development
      _loadMockAppointmentsData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Worker Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            onPressed: _exportReports,
            icon: const Icon(Icons.download),
            tooltip: 'Export Reports',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Client Activity'),
            Tab(text: 'Health Records'),
            Tab(text: 'Appointments'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildUserActivityTab(),
            _buildHealthRecordsTab(),
            _buildAppointmentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final stats = Map<String, dynamic>.from(_dashboardStats['stats'] ?? {});

    return RefreshIndicator(
      onRefresh: _loadReportsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeCard(),
            const SizedBox(height: 16),
            _buildStatsOverview(stats),
            const SizedBox(height: 16),
            _buildQuickReportActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.date_range, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report Period',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _showDateRangePicker,
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Clients',
          '${stats['totalClients'] ?? 0}',
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          'Total Appointments',
          '${stats['totalAppointments'] ?? 0}',
          Icons.calendar_today,
          AppColors.success,
        ),
        _buildStatCard(
          'Today\'s Appointments',
          '${stats['todayAppointments'] ?? 0}',
          Icons.today,
          AppColors.warning,
        ),
        _buildStatCard(
          'Completed',
          '${stats['completedAppointments'] ?? 0}',
          Icons.check_circle,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickReportActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildActionButton(
                  'Export PDF',
                  Icons.picture_as_pdf,
                  AppColors.error,
                  () => _exportReport('pdf'),
                ),
                _buildActionButton(
                  'Export Excel',
                  Icons.table_chart,
                  AppColors.success,
                  () => _exportReport('excel'),
                ),
                _buildActionButton(
                  'Generate Report',
                  Icons.assessment,
                  AppColors.primary,
                  () => _generateCustomReport(),
                ),
                _buildActionButton(
                  'Share Report',
                  Icons.share,
                  AppColors.info,
                  () => _shareReport(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityTab() {
    return RefreshIndicator(
      onRefresh: _loadReportsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Client Activity Overview'),
            const SizedBox(height: 16),
            _buildActivityMetrics(),
            const SizedBox(height: 24),
            _buildSectionHeader('Client Registrations'),
            const SizedBox(height: 16),
            _buildRegistrationChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecordsTab() {
    return RefreshIndicator(
      onRefresh: _loadReportsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Health Records Analytics'),
            const SizedBox(height: 16),
            _buildHealthRecordsMetrics(),
            const SizedBox(height: 24),
            _buildSectionHeader('Records by Type'),
            const SizedBox(height: 16),
            _buildRecordsTypeChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return RefreshIndicator(
      onRefresh: _loadReportsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appointment Analytics'),
            const SizedBox(height: 16),
            _buildAppointmentMetrics(),
            const SizedBox(height: 24),
            _buildSectionHeader('Appointment Status Distribution'),
            const SizedBox(height: 16),
            _buildAppointmentStatusChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActivityMetrics() {
    final userRegistrations =
        _userActivityData['userRegistrations'] as List<dynamic>? ?? [];
    final activityMetrics =
        _userActivityData['activityMetrics'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Summary',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMetricRow('New Registrations', '${userRegistrations.length}'),
            _buildMetricRow(
              'Active Users',
              '${activityMetrics['activeUsers'] ?? 0}',
            ),
            _buildMetricRow(
              'Total Logins',
              '${activityMetrics['totalLogins'] ?? 0}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecordsMetrics() {
    final recordsByType =
        _healthRecordsData['recordsByType'] as Map<String, dynamic>? ?? {};
    final completionTrends =
        _healthRecordsData['completionTrends'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Records Summary',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Total Records',
              '${recordsByType.values.fold(0, (sum, value) => sum + (value as int? ?? 0))}',
            ),
            _buildMetricRow(
              'Completion Rate',
              '${completionTrends['completionRate'] ?? 0}%',
            ),
            _buildMetricRow(
              'New Records',
              '${completionTrends['newRecords'] ?? 0}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentMetrics() {
    final appointmentsByStatus =
        _appointmentsData['appointmentsByStatus'] as Map<String, dynamic>? ??
        {};
    final timeSlotAnalysis =
        _appointmentsData['timeSlotAnalysis'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Summary',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Total Appointments',
              '${appointmentsByStatus.values.fold(0, (sum, value) => sum + (value as int? ?? 0))}',
            ),
            _buildMetricRow(
              'Completed',
              '${appointmentsByStatus['COMPLETED'] ?? 0}',
            ),
            _buildMetricRow(
              'Cancelled',
              '${appointmentsByStatus['CANCELLED'] ?? 0}',
            ),
            _buildMetricRow(
              'Peak Time',
              '${timeSlotAnalysis['peakTime'] ?? 'N/A'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRegistrationChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Client Registration Trends',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Chart visualization would go here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsTypeChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Records by Type Distribution',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Pie chart visualization would go here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStatusChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Appointment Status Overview',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.donut_small, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Status distribution chart would go here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportsData();
    }
  }

  void _exportReports() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Export Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.error,
                  ),
                  title: const Text('Export as PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportReport('pdf');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.table_chart,
                    color: AppColors.success,
                  ),
                  title: const Text('Export as Excel'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportReport('excel');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: AppColors.info),
                  title: const Text('Export as CSV'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportReport('csv');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _exportReport(String format) async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      setState(() => _isLoading = true);

      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/reports/export/$format',
        queryParameters: {
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(_endDate),
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report exported successfully as $format'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateCustomReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom report generation feature coming soon'),
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report sharing feature coming soon')),
    );
  }

  // Mock data methods for development
  void _loadMockUserActivityData() {
    setState(() {
      _userActivityData = {
        'totalUsers': 125,
        'activeUsers': 98,
        'newRegistrations': 15,
        'userGrowthRate': 12.5,
        'dailyActiveUsers': [
          {'date': '2025-08-01', 'count': 45},
          {'date': '2025-08-02', 'count': 52},
          {'date': '2025-08-03', 'count': 48},
          {'date': '2025-08-04', 'count': 61},
          {'date': '2025-08-05', 'count': 58},
          {'date': '2025-08-06', 'count': 67},
        ],
        'usersByRole': {'clients': 98, 'healthWorkers': 25, 'admins': 2},
        'usersByLocation': {
          'Kigali': 85,
          'Eastern Province': 20,
          'Northern Province': 12,
          'Southern Province': 8,
        },
      };
    });
  }

  void _loadMockHealthRecordsData() {
    setState(() {
      _healthRecordsData = {
        'totalRecords': 342,
        'newRecords': 28,
        'recordsGrowthRate': 8.9,
        'recordsByType': {
          'consultations': 156,
          'prescriptions': 89,
          'labResults': 67,
          'vaccinations': 30,
        },
        'recordsByMonth': [
          {'month': 'Jan', 'count': 45},
          {'month': 'Feb', 'count': 52},
          {'month': 'Mar', 'count': 48},
          {'month': 'Apr', 'count': 61},
          {'month': 'May', 'count': 58},
          {'month': 'Jun', 'count': 67},
          {'month': 'Jul', 'count': 72},
          {'month': 'Aug', 'count': 28},
        ],
        'topConditions': [
          {'condition': 'Family Planning Consultation', 'count': 89},
          {'condition': 'Prenatal Care', 'count': 67},
          {'condition': 'STI Testing', 'count': 45},
          {'condition': 'General Health Check', 'count': 34},
        ],
      };
    });
  }

  void _loadMockAppointmentsData() {
    setState(() {
      _appointmentsData = {
        'totalAppointments': 156,
        'completedAppointments': 134,
        'cancelledAppointments': 12,
        'pendingAppointments': 10,
        'completionRate': 85.9,
        'appointmentsByStatus': {
          'completed': 134,
          'cancelled': 12,
          'pending': 10,
        },
        'appointmentsByType': {
          'consultation': 89,
          'followUp': 45,
          'screening': 22,
        },
        'appointmentsByDay': [
          {'day': 'Monday', 'count': 28},
          {'day': 'Tuesday', 'count': 32},
          {'day': 'Wednesday', 'count': 25},
          {'day': 'Thursday', 'count': 31},
          {'day': 'Friday', 'count': 27},
          {'day': 'Saturday', 'count': 13},
        ],
        'monthlyTrend': [
          {'month': 'Jan', 'count': 18},
          {'month': 'Feb', 'count': 22},
          {'month': 'Mar', 'count': 19},
          {'month': 'Apr', 'count': 25},
          {'month': 'May', 'count': 23},
          {'month': 'Jun', 'count': 28},
          {'month': 'Jul', 'count': 31},
          {'month': 'Aug', 'count': 10},
        ],
      };
    });
  }
}
