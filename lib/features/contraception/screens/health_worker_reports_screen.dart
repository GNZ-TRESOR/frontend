import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/health_worker_reports.dart';
import '../../../core/services/health_worker_reports_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/auto_translate_widget.dart';
import '../widgets/usage_stats_card.dart';
import '../widgets/side_effects_stats_card.dart';
import '../widgets/compliance_stats_card.dart';

class HealthWorkerReportsScreen extends ConsumerStatefulWidget {
  const HealthWorkerReportsScreen({super.key});

  @override
  ConsumerState<HealthWorkerReportsScreen> createState() =>
      _HealthWorkerReportsScreenState();
}

class _HealthWorkerReportsScreenState
    extends ConsumerState<HealthWorkerReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  HealthWorkerDashboard? _dashboardData;
  UsageStats? _usageStats;
  EnhancedSideEffectsStats? _sideEffectsStats;
  ComplianceData? _complianceStats;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the service (you'll need to provide this through dependency injection)
      final apiService = ref.read(apiServiceProvider);
      final reportsService = HealthWorkerReportsService(apiService);

      // Load all data in parallel
      final results = await Future.wait([
        reportsService.getDashboardStats(),
        reportsService.getContraceptionUsageStats(),
        reportsService.getSideEffectsStats(),
        reportsService.getUserComplianceStats(),
      ]);

      setState(() {
        _dashboardData = results[0] as HealthWorkerDashboard?;
        _usageStats = results[1] as UsageStats?;
        _sideEffectsStats = results[2] as EnhancedSideEffectsStats?;
        _complianceStats = results[3] as ComplianceData?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoTranslateWidget('Health Worker Reports'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(child: AutoTranslateWidget('Dashboard')),
            Tab(child: AutoTranslateWidget('Usage Stats')),
            Tab(child: AutoTranslateWidget('Side Effects')),
            Tab(child: AutoTranslateWidget('Compliance')),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildUsageStatsTab(),
                  _buildSideEffectsTab(),
                  _buildComplianceTab(),
                ],
              ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          AutoTranslateWidget(
            'Error loading reports',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: AutoTranslateWidget('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_dashboardData == null) {
      return const Center(child: Text('No dashboard data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Quick stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Total Users',
                _dashboardData!.totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                'Active Methods',
                _dashboardData!.activeMethods.toString(),
                Icons.medical_services,
                Colors.green,
              ),
              _buildStatCard(
                'Side Effect Reports',
                _dashboardData!.totalSideEffectReports.toString(),
                Icons.warning,
                Colors.orange,
              ),
              _buildStatCard(
                'Upcoming Appointments',
                _dashboardData!.upcomingAppointments.toString(),
                Icons.calendar_today,
                Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslateWidget(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.report, color: Colors.red),
                    title: AutoTranslateWidget('Recent Side Effect Reports'),
                    subtitle: Text(
                      '${_dashboardData!.recentSideEffectReports} reports in the last 30 days',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            AutoTranslateWidget(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatsTab() {
    if (_usageStats == null) {
      return const Center(child: Text('No usage statistics available'));
    }

    return UsageStatsCard(stats: _usageStats!);
  }

  Widget _buildSideEffectsTab() {
    if (_sideEffectsStats == null) {
      return const Center(child: Text('No side effects statistics available'));
    }

    return SideEffectsStatsCard(stats: _sideEffectsStats!);
  }

  Widget _buildComplianceTab() {
    if (_complianceStats == null) {
      return const Center(child: Text('No compliance statistics available'));
    }

    return ComplianceStatsCard(stats: _complianceStats!);
  }

  Future<void> _exportReports() async {
    // Show export options dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: AutoTranslateWidget('Export Reports'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: AutoTranslateWidget('Export as CSV'),
                  onTap: () => _performExport('csv'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: AutoTranslateWidget('Export as Excel'),
                  onTap: () => _performExport('excel'),
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: AutoTranslateWidget('Export as PDF'),
                  onTap: () => _performExport('pdf'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: AutoTranslateWidget('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _performExport(String format) async {
    Navigator.of(context).pop(); // Close dialog

    try {
      final apiService = ref.read(apiServiceProvider);
      final reportsService = HealthWorkerReportsService(apiService);

      final result = await reportsService.exportReportsData(
        format: format,
        reportTypes: ['usage', 'sideEffects', 'compliance'],
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoTranslateWidget('Reports exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Export failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoTranslateWidget('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});
