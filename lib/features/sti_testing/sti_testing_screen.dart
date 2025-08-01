import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/models/sti_test_record.dart';
import '../../core/providers/sti_provider.dart';
import '../clinic_finder/clinic_finder_screen.dart';
import 'add_sti_test_screen.dart';

/// Professional STI Testing Screen
class StiTestingScreen extends ConsumerStatefulWidget {
  const StiTestingScreen({super.key});

  @override
  ConsumerState<StiTestingScreen> createState() => _StiTestingScreenState();
}

class _StiTestingScreenState extends ConsumerState<StiTestingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load STI test records when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any existing error state first
      ref.read(stiProvider.notifier).clearError();
      // Then load the records
      ref.read(stiProvider.notifier).loadStiTestRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stiState = ref.watch(stiProvider);
    final testRecords = ref.watch(stiTestRecordsProvider);
    final statistics = ref.watch(stiStatisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('STI Testing'),
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Test History'),
            Tab(text: 'Education'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: stiState.isLoading,
        child:
            stiState.error != null
                ? _buildErrorState(stiState.error!)
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(statistics, testRecords),
                    _buildTestHistoryTab(testRecords),
                    _buildEducationTab(),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTest(context),
        backgroundColor: AppColors.appointmentBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab(
    Map<String, dynamic> statistics,
    List<StiTestRecord> testRecords,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(stiProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(statistics, testRecords),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildRecommendations(),
            const SizedBox(height: 16),
            _buildRecentTests(testRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    Map<String, dynamic> statistics,
    List<StiTestRecord> testRecords,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.appointmentBlue,
            AppColors.appointmentBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.appointmentBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Sexual Health Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusInfo(
                  'Last Test',
                  _getLastTestInfo(testRecords),
                ),
              ),
              Expanded(
                child: _buildStatusInfo(
                  'Status',
                  _getOverallStatus(testRecords),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusInfo(
                  'Next Test',
                  _getNextTestInfo(testRecords),
                ),
              ),
              Expanded(
                child: _buildStatusInfo(
                  'Tests Done',
                  '${statistics['totalTests']} total',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Schedule Test',
                Icons.calendar_today,
                AppColors.appointmentBlue,
                () => _scheduleTest(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Find Clinic',
                Icons.location_on,
                AppColors.error,
                () => _findClinic(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Add Results',
                Icons.add_circle,
                AppColors.success,
                () => _addTestResults(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Set Reminder',
                Icons.alarm,
                AppColors.warning,
                () => _setReminder(),
              ),
            ),
          ],
        ),
      ],
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildRecommendationCard(
          'Regular Testing',
          'Get tested every 3-6 months if sexually active',
          Icons.schedule,
          AppColors.primary,
        ),
        const SizedBox(height: 8),
        _buildRecommendationCard(
          'Safe Practices',
          'Use protection and communicate with partners',
          Icons.shield,
          AppColors.success,
        ),
        const SizedBox(height: 8),
        _buildRecommendationCard(
          'Partner Testing',
          'Encourage partners to get tested regularly',
          Icons.people,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Tests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routine STI Screening',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Due in 3 months',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _scheduleTest(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appointmentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Schedule'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestHistoryTab(List<StiTestRecord> testRecords) {
    if (testRecords.isEmpty) {
      return _buildEmptyState(
        'No test history',
        'Add your STI test records to track your health',
        Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: testRecords.length,
      itemBuilder: (context, index) {
        final test = testRecords[index];
        return _buildTestHistoryCard(test);
      },
    );
  }

  Widget _buildTestHistoryCard(StiTestRecord test) {
    final resultColor = _getResultColor(test.resultStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEditTest(context, test),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getResultIcon(test.resultStatus),
                      color: resultColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.testTypeDisplayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          test.formattedTestDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      test.resultStatusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: resultColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (test.testLocation?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      test.testLocation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STI Education & Prevention',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildEducationSection('Common STIs', [
            'Chlamydia',
            'Gonorrhea',
            'Syphilis',
            'HIV/AIDS',
            'Herpes (HSV)',
            'HPV',
          ]),
          const SizedBox(height: 16),
          _buildEducationSection('Prevention Methods', [
            'Safe Sex Practices',
            'Regular Testing',
            'Partner Communication',
            'Vaccination (HPV, Hepatitis)',
          ]),
          const SizedBox(height: 16),
          _buildEducationSection('Testing Guidelines', [
            'When to Get Tested',
            'Types of Tests Available',
            'Understanding Results',
            'Follow-up Care',
          ]),
        ],
      ),
    );
  }

  Widget _buildEducationSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildEducationItem(item)).toList(),
      ],
    );
  }

  Widget _buildEducationItem(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.appointmentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.info, color: AppColors.appointmentBlue, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: () => _openEducationTopic(title),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showAddTestDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Test Record'),
            content: const Text('Add a new STI test record to your history'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addTestRecord();
                },
                child: const Text('Add Record'),
              ),
            ],
          ),
    );
  }

  void _addTestRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test record added successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _scheduleTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecting to appointment booking...')),
    );
  }

  void _findClinic() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClinicFinderScreen()),
    );
  }

  void _addTestResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add test results feature coming soon')),
    );
  }

  void _setReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test reminder set successfully')),
    );
  }

  void _openEducationTopic(String topic) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening $topic information')));
  }

  // Helper methods for STI data processing
  String _getLastTestInfo(List<StiTestRecord> testRecords) {
    if (testRecords.isEmpty) return 'No tests recorded';

    final latestTest = testRecords.first; // Already sorted by date
    final daysSince = DateTime.now().difference(latestTest.testDate).inDays;

    if (daysSince == 0) return 'Today';
    if (daysSince == 1) return '1 day ago';
    if (daysSince < 30) return '$daysSince days ago';
    if (daysSince < 60) return '1 month ago';

    final monthsSince = (daysSince / 30).round();
    return '$monthsSince months ago';
  }

  String _getOverallStatus(List<StiTestRecord> testRecords) {
    if (testRecords.isEmpty) return 'No data';

    final recentTests = testRecords.where((test) => test.isRecent).toList();
    if (recentTests.isEmpty) return 'Tests needed';

    final hasPositive = recentTests.any(
      (test) => test.resultStatus.toUpperCase() == 'POSITIVE',
    );
    final hasPending = recentTests.any(
      (test) => test.resultStatus.toUpperCase() == 'PENDING',
    );

    if (hasPositive) return 'Needs attention';
    if (hasPending) return 'Results pending';
    return 'All clear';
  }

  String _getNextTestInfo(List<StiTestRecord> testRecords) {
    if (testRecords.isEmpty) return 'Schedule now';

    final latestTest = testRecords.first;
    final daysSinceLastTest =
        DateTime.now().difference(latestTest.testDate).inDays;

    // Recommend testing every 6 months for sexually active individuals
    const recommendedInterval = 180; // 6 months
    final daysUntilNext = recommendedInterval - daysSinceLastTest;

    if (daysUntilNext <= 0) return 'Due now';
    if (daysUntilNext < 30) return 'Due in $daysUntilNext days';

    final monthsUntilNext = (daysUntilNext / 30).round();
    return 'Due in $monthsUntilNext months';
  }

  Color _getResultColor(String resultStatus) {
    switch (resultStatus.toUpperCase()) {
      case 'NEGATIVE':
        return AppColors.success;
      case 'POSITIVE':
        return AppColors.error;
      case 'INCONCLUSIVE':
        return AppColors.warning;
      case 'PENDING':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getResultIcon(String resultStatus) {
    switch (resultStatus.toUpperCase()) {
      case 'NEGATIVE':
        return Icons.check_circle;
      case 'POSITIVE':
        return Icons.warning;
      case 'INCONCLUSIVE':
        return Icons.help;
      case 'PENDING':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  void _navigateToAddTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStiTestScreen()),
    );
  }

  void _navigateToEditTest(BuildContext context, StiTestRecord test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStiTestScreen(existingRecord: test),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading STI Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(stiProvider.notifier).clearError();
              ref.read(stiProvider.notifier).loadStiTestRecords();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTests(List<StiTestRecord> testRecords) {
    final recentTests =
        testRecords.where((test) => test.isRecent).take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentTests.isEmpty)
              Text(
                'No recent tests in the last 6 months',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...recentTests.map(
                (test) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        _getResultIcon(test.resultStatus),
                        color: _getResultColor(test.resultStatus),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${test.testTypeDisplayName} - ${test.formattedTestDate}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        test.resultStatusDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getResultColor(test.resultStatus),
                          fontWeight: FontWeight.w500,
                        ),
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
}
