import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/translated_text.dart';
import '../../core/widgets/dynamic_translated_text.dart';
import '../../core/widgets/simple_translated_text.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/providers/health_provider.dart';
import '../../core/models/health_record.dart';
import '../../core/models/menstrual_cycle.dart';
import '../../core/mixins/tts_screen_mixin.dart';

/// Professional Health Records Screen with Real API Integration
class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  ConsumerState<HealthRecordsScreen> createState() =>
      _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen>
    with TickerProviderStateMixin, TTSScreenMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load health records when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadHealthRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addHealthRecord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHealthRecordScreen()),
    );

    if (result == true) {
      ref.read(healthProvider.notifier).loadHealthRecords();
    }
  }

  Future<void> _editHealthRecord(HealthRecord record) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHealthRecordScreen(existingRecord: record),
      ),
    );

    if (result == true) {
      ref.read(healthProvider.notifier).loadHealthRecords();
    }
  }

  Future<void> _deleteHealthRecord(HealthRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Health Record'),
            content: Text(
              'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && record.id != null) {
      final success = await ref
          .read(healthProvider.notifier)
          .deleteHealthRecord(record.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health record deleted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProvider);
    final healthRecords = ref.watch(healthRecordsProvider);

    return addTTSToScaffold(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: 'Health Records'.str(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Records'),
            Tab(text: 'Recent'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: healthState.isLoading,
        child:
            healthState.error != null
                ? _buildErrorState(healthState.error!)
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllRecordsTab(healthRecords),
                    _buildRecentRecordsTab(healthRecords),
                    _buildReportsTab(),
                  ],
                ),
      ),
      additionalFAB: FloatingActionButton(
        onPressed: _addHealthRecord,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAllRecordsTab(List<HealthRecord> healthRecords) {
    if (healthRecords.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(healthProvider.notifier).loadHealthRecords(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: healthRecords.length,
        itemBuilder: (context, index) {
          final record = healthRecords[index];
          return _buildHealthRecordCard(record);
        },
      ),
    );
  }

  Widget _buildRecentRecordsTab(List<HealthRecord> healthRecords) {
    final recentRecords =
        healthRecords
            .where(
              (record) =>
                  record.recordDate != null &&
                  DateTime.now().difference(record.recordDate!).inDays <= 30,
            )
            .toList();

    if (recentRecords.isEmpty) {
      return _buildEmptyState(message: 'No recent health records');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentRecords.length,
      itemBuilder: (context, index) {
        final record = recentRecords[index];
        return _buildHealthRecordCard(record);
      },
    );
  }

  Widget _buildReportsTab() {
    final healthRecords = ref.watch(healthRecordsProvider);
    final menstrualCycles = ref.watch(menstrualCyclesProvider);

    if (healthRecords.isEmpty && menstrualCycles.isEmpty) {
      return _buildEmptyReportsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(healthProvider.notifier).loadHealthRecords();
        await ref.read(healthProvider.notifier).loadMenstrualCycles();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Overview Card
            _buildHealthOverviewCard(healthRecords),
            const SizedBox(height: 16),

            // Vital Signs Trends
            if (healthRecords.isNotEmpty) ...[
              _buildVitalSignsTrendsCard(healthRecords),
              const SizedBox(height: 16),
            ],

            // BMI Analysis
            if (healthRecords.any((r) => r.bmi != null)) ...[
              _buildBMIAnalysisCard(healthRecords),
              const SizedBox(height: 16),
            ],

            // Health Status Distribution
            if (healthRecords.any((r) => r.healthStatus != null)) ...[
              _buildHealthStatusCard(healthRecords),
              const SizedBox(height: 16),
            ],

            // Menstrual Cycle Insights
            if (menstrualCycles.isNotEmpty) ...[
              _buildMenstrualInsightsCard(menstrualCycles),
              const SizedBox(height: 16),
            ],

            // Recent Activity Summary
            _buildRecentActivityCard(healthRecords, []),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReportsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Health Data Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add health records to see detailed analytics and insights',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addHealthRecord,
            icon: const Icon(Icons.add),
            label: const Text('Add Health Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordCard(HealthRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewHealthRecord(record),
        borderRadius: BorderRadius.circular(12),
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
                      color: _getRecordTypeColor(
                        record.recordType ?? 'general',
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getRecordTypeIcon(record.recordType ?? 'general'),
                      color: _getRecordTypeColor(
                        record.recordType ?? 'general',
                      ),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title ?? 'Health Record',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.recordType ?? 'General',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editHealthRecord(record),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteHealthRecord(record),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (record.description != null)
                Text(
                  record.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(record.recordDate ?? DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message ?? 'No health records yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first health record',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
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
            'Error Loading Records',
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
              ref.read(healthProvider.notifier).clearError();
              ref.read(healthProvider.notifier).loadHealthRecords();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _viewHealthRecord(HealthRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewHealthRecordScreen(record: record),
      ),
    );
  }

  Color _getRecordTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'general':
        return AppColors.primary;
      case 'laboratory':
        return AppColors.tertiary;
      case 'consultation':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRecordTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'general':
        return Icons.medical_services;
      case 'laboratory':
        return Icons.science;
      case 'consultation':
        return Icons.chat;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Health Reports Methods
  Widget _buildHealthOverviewCard(List<HealthRecord> healthRecords) {
    final latestRecord = healthRecords.isNotEmpty ? healthRecords.first : null;
    final totalRecords = healthRecords.length;
    final recentRecords = healthRecords.where((r) => r.isRecent).length;

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
                'Health Overview'.tr(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    'Total Records',
                    totalRecords.toString(),
                    Icons.folder,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    'Recent (30d)',
                    recentRecords.toString(),
                    Icons.schedule,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (latestRecord != null) ...[
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Latest Record',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getRecordTypeIcon(latestRecord.recordType ?? 'general'),
                    size: 20,
                    color: _getRecordTypeColor(
                      latestRecord.recordType ?? 'general',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      latestRecord.title ?? 'Health Record',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    latestRecord.formattedDate,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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

  Widget _buildOverviewStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsTrendsCard(List<HealthRecord> healthRecords) {
    final recordsWithVitals = healthRecords.where((r) => r.hasVitals).toList();

    if (recordsWithVitals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.success),
                const SizedBox(width: 8),
                const Text(
                  'Vital Signs Trends',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Heart Rate Chart
            if (recordsWithVitals.any((r) => r.heartRateValue != null)) ...[
              _buildHeartRateChart(recordsWithVitals),
              const SizedBox(height: 20),
            ],
            // Weight Chart
            if (recordsWithVitals.any((r) => r.kgValue != null)) ...[
              _buildWeightChart(recordsWithVitals),
              const SizedBox(height: 20),
            ],
            // Temperature Chart
            if (recordsWithVitals.any((r) => r.tempValue != null)) ...[
              _buildTemperatureChart(recordsWithVitals),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitalTrendsList(List<HealthRecord> records) {
    final latestRecord = records.first;
    final trends = <String, Map<String, dynamic>>{};

    // Analyze trends for each vital sign
    if (latestRecord.heartRateValue != null) {
      trends['Heart Rate'] = _analyzeVitalTrend(
        records,
        (r) => r.heartRateValue?.toDouble(),
        'bpm',
        60,
        100,
      );
    }

    if (latestRecord.tempValue != null) {
      trends['Temperature'] = _analyzeVitalTrend(
        records,
        (r) => r.tempValue,
        '°C',
        36.1,
        37.2,
      );
    }

    if (latestRecord.kgValue != null) {
      trends['Weight'] = _analyzeVitalTrend(
        records,
        (r) => r.kgValue,
        'kg',
        null,
        null,
      );
    }

    return Column(
      children:
          trends.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildVitalTrendItem(entry.key, entry.value),
            );
          }).toList(),
    );
  }

  Map<String, dynamic> _analyzeVitalTrend(
    List<HealthRecord> records,
    double? Function(HealthRecord) getValue,
    String unit,
    double? normalMin,
    double? normalMax,
  ) {
    final values =
        records.map(getValue).where((v) => v != null).cast<double>().toList();

    if (values.isEmpty) {
      return {
        'current': 0.0,
        'trend': 'stable',
        'status': 'unknown',
        'unit': unit,
      };
    }

    final current = values.first;
    final previous = values.length > 1 ? values[1] : current;

    String trend = 'stable';
    if (current > previous) {
      trend = 'increasing';
    } else if (current < previous) {
      trend = 'decreasing';
    }

    String status = 'normal';
    if (normalMin != null && normalMax != null) {
      if (current < normalMin) {
        status = 'low';
      } else if (current > normalMax) {
        status = 'high';
      }
    }

    return {
      'current': current,
      'trend': trend,
      'status': status,
      'unit': unit,
      'change': current - previous,
    };
  }

  Widget _buildVitalTrendItem(String name, Map<String, dynamic> data) {
    final current = data['current'] as double;
    final trend = data['trend'] as String;
    final status = data['status'] as String;
    final unit = data['unit'] as String;
    final change = data['change'] as double;

    Color statusColor = AppColors.success;
    IconData statusIcon = Icons.check_circle;

    switch (status) {
      case 'high':
        statusColor = AppColors.error;
        statusIcon = Icons.arrow_upward;
        break;
      case 'low':
        statusColor = AppColors.warning;
        statusIcon = Icons.arrow_downward;
        break;
      case 'normal':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
    }

    IconData trendIcon = Icons.trending_flat;
    Color trendColor = AppColors.textSecondary;

    switch (trend) {
      case 'increasing':
        trendIcon = Icons.trending_up;
        trendColor = AppColors.primary;
        break;
      case 'decreasing':
        trendIcon = Icons.trending_down;
        trendColor = AppColors.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${current.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(trendIcon, color: trendColor, size: 16),
              const SizedBox(height: 2),
              if (change != 0)
                Text(
                  '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 10, color: trendColor),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMIAnalysisCard(List<HealthRecord> healthRecords) {
    final recordsWithBMI = healthRecords.where((r) => r.bmi != null).toList();

    if (recordsWithBMI.isEmpty) {
      return const SizedBox.shrink();
    }

    final latestBMI = recordsWithBMI.first.bmi!;
    String bmiCategory = _getBMICategory(latestBMI);
    Color bmiColor = _getBMIColor(latestBMI);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'BMI Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current BMI',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestBMI.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: bmiColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bmiCategory,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: bmiColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bmiColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getBMIIcon(latestBMI),
                    color: bmiColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBMIRangeIndicator(latestBMI),
            const SizedBox(height: 16),
            if (recordsWithBMI.length > 1) _buildBMIChart(recordsWithBMI),
          ],
        ),
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getBMIIcon(double bmi) {
    if (bmi < 18.5) return Icons.trending_down;
    if (bmi < 25) return Icons.check_circle;
    if (bmi < 30) return Icons.trending_up;
    return Icons.warning;
  }

  Widget _buildBMIRangeIndicator(double currentBMI) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI Range',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                Colors.blue, // Underweight
                Colors.green, // Normal
                Colors.orange, // Overweight
                Colors.red, // Obese
              ],
              stops: [0.0, 0.33, 0.66, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '18.5',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              '25',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              '30',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              '35+',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthStatusCard(List<HealthRecord> healthRecords) {
    final recordsWithStatus =
        healthRecords.where((r) => r.healthStatus != null).toList();

    if (recordsWithStatus.isEmpty) {
      return const SizedBox.shrink();
    }

    final statusCounts = <String, int>{};
    for (final record in recordsWithStatus) {
      final status = record.healthStatus!;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Health Status Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) {
              final percentage =
                  (entry.value / recordsWithStatus.length * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildStatusItem(entry.key, entry.value, percentage),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String status, int count, int percentage) {
    Color statusColor = _getHealthStatusColor(status);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            status.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Text(
          '$count records ($percentage%)',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
      case 'good':
      case 'normal':
        return AppColors.success;
      case 'fair':
      case 'warning':
        return AppColors.warning;
      case 'poor':
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildMenstrualInsightsCard(List<dynamic> cycles) {
    if (cycles.isEmpty) {
      return const SizedBox.shrink();
    }

    final averageCycleLength = _calculateAverageCycleLength(cycles);
    final lastCycle = cycles.first;
    final nextPredictedDate = _predictNextCycle(lastCycle, averageCycleLength);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.secondary),
                const SizedBox(width: 8),
                const Text(
                  'Menstrual Cycle Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCycleInsight(
                    'Average Cycle',
                    '${averageCycleLength.round()} days',
                    Icons.schedule,
                    AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: _buildCycleInsight(
                    'Total Cycles',
                    cycles.length.toString(),
                    Icons.repeat,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Next Predicted Cycle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(nextPredictedDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleInsight(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateAverageCycleLength(List<dynamic> cycles) {
    if (cycles.length < 2) return 28.0; // Default cycle length

    double totalDays = 0;
    int validCycles = 0;

    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final next = cycles[i + 1];

      // Assuming cycles have a startDate property
      if (current is Map && next is Map) {
        final currentDate = DateTime.tryParse(current['startDate'] ?? '');
        final nextDate = DateTime.tryParse(next['startDate'] ?? '');

        if (currentDate != null && nextDate != null) {
          final difference = currentDate.difference(nextDate).inDays.abs();
          if (difference > 0 && difference < 60) {
            // Valid cycle length
            totalDays += difference;
            validCycles++;
          }
        }
      }
    }

    return validCycles > 0 ? totalDays / validCycles : 28.0;
  }

  DateTime _predictNextCycle(dynamic lastCycle, double averageCycleLength) {
    if (lastCycle is Map) {
      final lastStartDate = DateTime.tryParse(lastCycle['startDate'] ?? '');
      if (lastStartDate != null) {
        return lastStartDate.add(Duration(days: averageCycleLength.round()));
      }
    }

    // Fallback: predict based on current date
    return DateTime.now().add(Duration(days: averageCycleLength.round()));
  }

  Widget _buildRecentActivityCard(
    List<HealthRecord> healthRecords,
    List<dynamic> menstrualCycles,
  ) {
    final recentRecords =
        healthRecords.where((r) => r.isRecent).take(3).toList();
    final recentCycles = menstrualCycles.take(2).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentRecords.isEmpty && recentCycles.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...recentRecords
                  .map(
                    (record) => _buildActivityItem(
                      record.title ?? 'Health Record',
                      record.formattedDate,
                      _getRecordTypeIcon(record.recordType ?? 'general'),
                      _getRecordTypeColor(record.recordType ?? 'general'),
                    ),
                  )
                  .toList(),
              ...recentCycles.map((cycle) {
                if (cycle is Map) {
                  final startDate = DateTime.tryParse(cycle['startDate'] ?? '');
                  return _buildActivityItem(
                    'Menstrual Cycle',
                    startDate != null ? _formatDate(startDate) : 'Unknown date',
                    Icons.calendar_month,
                    AppColors.secondary,
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String date,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chart Methods
  Widget _buildHeartRateChart(List<HealthRecord> records) {
    final heartRateData =
        records
            .where((r) => r.heartRateValue != null && r.lastUpdated != null)
            .map(
              (r) => FlSpot(
                r.lastUpdated!.millisecondsSinceEpoch.toDouble(),
                r.heartRateValue!.toDouble(),
              ),
            )
            .toList();

    if (heartRateData.isEmpty) return const SizedBox.shrink();

    // Sort by date
    heartRateData.sort((a, b) => a.x.compareTo(b.x));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heart Rate Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 20,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 86400000, // 1 day in milliseconds
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        value.toInt(),
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              minX: heartRateData.first.x,
              maxX: heartRateData.last.x,
              minY: 40,
              maxY: 120,
              lineBarsData: [
                LineChartBarData(
                  spots: heartRateData,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withValues(alpha: 0.8),
                      AppColors.warning.withValues(alpha: 0.8),
                      AppColors.success.withValues(alpha: 0.8),
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      Color dotColor = AppColors.success;
                      if (spot.y < 60) {
                        dotColor = AppColors.warning;
                      } else if (spot.y > 100) {
                        dotColor = AppColors.error;
                      }
                      return FlDotCirclePainter(
                        radius: 4,
                        color: dotColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withValues(alpha: 0.1),
                        AppColors.success.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildChartLegend('Normal (60-100)', AppColors.success),
            _buildChartLegend('Low (<60)', AppColors.warning),
            _buildChartLegend('High (>100)', AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWeightChart(List<HealthRecord> records) {
    final weightData =
        records
            .where((r) => r.kgValue != null && r.lastUpdated != null)
            .map(
              (r) => FlSpot(
                r.lastUpdated!.millisecondsSinceEpoch.toDouble(),
                r.kgValue!,
              ),
            )
            .toList();

    if (weightData.isEmpty) return const SizedBox.shrink();

    // Sort by date
    weightData.sort((a, b) => a.x.compareTo(b.x));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 86400000, // 1 day in milliseconds
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        value.toInt(),
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${value.toInt()}kg',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              minX: weightData.first.x,
              maxX: weightData.last.x,
              minY:
                  weightData.map((e) => e.y).reduce((a, b) => a < b ? a : b) -
                  5,
              maxY:
                  weightData.map((e) => e.y).reduce((a, b) => a > b ? a : b) +
                  5,
              lineBarsData: [
                LineChartBarData(
                  spots: weightData,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureChart(List<HealthRecord> records) {
    final tempData =
        records
            .where((r) => r.tempValue != null && r.lastUpdated != null)
            .map(
              (r) => FlSpot(
                r.lastUpdated!.millisecondsSinceEpoch.toDouble(),
                r.tempValue!,
              ),
            )
            .toList();

    if (tempData.isEmpty) return const SizedBox.shrink();

    // Sort by date
    tempData.sort((a, b) => a.x.compareTo(b.x));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperature Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 86400000, // 1 day in milliseconds
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        value.toInt(),
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.5,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${value.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              minX: tempData.first.x,
              maxX: tempData.last.x,
              minY: 35,
              maxY: 40,
              lineBarsData: [
                LineChartBarData(
                  spots: tempData,
                  isCurved: true,
                  color: AppColors.secondary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      Color dotColor = AppColors.success;
                      if (spot.y < 36.1) {
                        dotColor = AppColors.warning;
                      } else if (spot.y > 37.2) {
                        dotColor = AppColors.error;
                      }
                      return FlDotCirclePainter(
                        radius: 4,
                        color: dotColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        AppColors.secondary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildChartLegend('Normal (36.1-37.2°C)', AppColors.success),
            _buildChartLegend('Low (<36.1°C)', AppColors.warning),
            _buildChartLegend('High (>37.2°C)', AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildBMIChart(List<HealthRecord> records) {
    final bmiData =
        records
            .where((r) => r.bmi != null && r.lastUpdated != null)
            .map(
              (r) => FlSpot(
                r.lastUpdated!.millisecondsSinceEpoch.toDouble(),
                r.bmi!,
              ),
            )
            .toList();

    if (bmiData.isEmpty) return const SizedBox.shrink();

    // Sort by date
    bmiData.sort((a, b) => a.x.compareTo(b.x));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 2,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 86400000, // 1 day in milliseconds
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        value.toInt(),
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              minX: bmiData.first.x,
              maxX: bmiData.last.x,
              minY: 15,
              maxY: 35,
              lineBarsData: [
                LineChartBarData(
                  spots: bmiData,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      Color dotColor = _getBMIColor(spot.y);
                      return FlDotCirclePainter(
                        radius: 4,
                        color: dotColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 18.5,
                    color: AppColors.warning.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Underweight',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  HorizontalLine(
                    y: 25,
                    color: AppColors.success.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Normal',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  HorizontalLine(
                    y: 30,
                    color: AppColors.error.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Obese',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildChartLegend('Underweight (<18.5)', AppColors.warning),
            _buildChartLegend('Normal (18.5-25)', AppColors.success),
            _buildChartLegend('Overweight (25-30)', AppColors.warning),
            _buildChartLegend('Obese (>30)', AppColors.error),
          ],
        ),
      ],
    );
  }

  // TTS Implementation
  @override
  String getTTSContent(BuildContext context, WidgetRef ref) {
    final healthRecords = ref.watch(healthRecordsProvider);
    final currentTab = _tabController.index;

    final buffer = StringBuffer();
    buffer.write('Health Records screen. ');

    String tabName = '';
    switch (currentTab) {
      case 0:
        tabName = 'All Records';
        break;
      case 1:
        tabName = 'Recent Records';
        break;
      case 2:
        tabName = 'Reports';
        break;
    }

    buffer.write('You are viewing the $tabName tab. ');

    if (healthRecords.isEmpty) {
      buffer.write(
        'No health records found. You can add a new record using the plus button. ',
      );
    } else {
      buffer.write('${healthRecords.length} health records found. ');

      // Read first few records
      final recordsToRead = healthRecords.take(3).toList();
      for (int i = 0; i < recordsToRead.length; i++) {
        final record = recordsToRead[i];
        buffer.write('${i + 1}. ${record.title ?? 'Health Record'}. ');
        if (record.recordType != null) {
          buffer.write('Type: ${record.recordType}. ');
        }
        if (record.createdAt != null) {
          buffer.write(
            'Created on ${record.createdAt.toString().split(' ')[0]}. ',
          );
        }
        if (record.notes != null && record.notes!.isNotEmpty) {
          buffer.write('Notes: ${record.notes}. ');
        }
      }

      if (healthRecords.length > 3) {
        buffer.write('And ${healthRecords.length - 3} more records. ');
      }
    }

    return buffer.toString();
  }

  String getScreenName() => 'Health Records';
}

/// Add Health Record Screen - FULLY IMPLEMENTED WITH ALL DATABASE FIELDS
class AddHealthRecordScreen extends ConsumerStatefulWidget {
  final HealthRecord? existingRecord; // For editing

  const AddHealthRecordScreen({super.key, this.existingRecord});

  @override
  ConsumerState<AddHealthRecordScreen> createState() =>
      _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends ConsumerState<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all database fields
  final _heartRateController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  final _recordedByController = TextEditingController();

  // Dropdown selections
  String _selectedType = 'general';
  String _heartRateUnit = 'bpm';
  String _bpUnit = 'mmHg';
  String _weightUnit = 'kg';
  String _tempUnit = '°C';
  String _heightUnit = 'cm';
  String _healthStatus = 'normal';
  int? _selectedHealthWorkerId;

  bool _isLoading = false;
  bool _isVerified = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingRecord != null;

    // Load health workers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadHealthWorkers();
    });

    if (_isEditMode) {
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    final record = widget.existingRecord!;
    _heartRateController.text = record.heartRateValue?.toString() ?? '';
    _bloodPressureController.text = record.bpValue ?? '';
    _weightController.text = record.kgValue?.toString() ?? '';
    _temperatureController.text = record.tempValue?.toString() ?? '';
    _heightController.text = record.heightValue?.toString() ?? '';
    _notesController.text = record.notes ?? '';
    _recordedByController.text =
        record.recordType ?? ''; // Using recordType as recordedBy for now

    _heartRateUnit = record.heartRateUnit ?? 'bpm';
    _bpUnit = record.bpUnit ?? 'mmHg';
    _weightUnit = record.kgUnit ?? 'kg';
    _tempUnit = record.tempUnit ?? '°C';
    _heightUnit = record.heightUnit ?? 'cm';
    _healthStatus = record.healthStatus ?? 'normal';
    _selectedHealthWorkerId = record.assignedHealthWorkerId;
    _isVerified = record.isVerified ?? false;
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    _recordedByController.dispose();
    super.dispose();
  }

  Future<void> _saveHealthRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Calculate BMI if height and weight are provided
      double? bmi;
      if (_heightController.text.isNotEmpty &&
          _weightController.text.isNotEmpty) {
        final height = double.tryParse(_heightController.text);
        final weight = double.tryParse(_weightController.text);
        if (height != null && weight != null && height > 0) {
          final heightInMeters = _heightUnit == 'cm' ? height / 100 : height;
          bmi = weight / (heightInMeters * heightInMeters);
        }
      }

      final healthRecord = HealthRecord(
        id: _isEditMode ? widget.existingRecord!.id : null,
        heartRateValue:
            _heartRateController.text.isNotEmpty
                ? int.tryParse(_heartRateController.text)
                : null,
        heartRateUnit:
            _heartRateController.text.isNotEmpty ? _heartRateUnit : null,
        bpValue:
            _bloodPressureController.text.isNotEmpty
                ? _bloodPressureController.text
                : null,
        bpUnit: _bloodPressureController.text.isNotEmpty ? _bpUnit : null,
        kgValue:
            _weightController.text.isNotEmpty
                ? double.tryParse(_weightController.text)
                : null,
        kgUnit: _weightController.text.isNotEmpty ? _weightUnit : null,
        tempValue:
            _temperatureController.text.isNotEmpty
                ? double.tryParse(_temperatureController.text)
                : null,
        tempUnit: _temperatureController.text.isNotEmpty ? _tempUnit : null,
        heightValue:
            _heightController.text.isNotEmpty
                ? double.tryParse(_heightController.text)
                : null,
        heightUnit: _heightController.text.isNotEmpty ? _heightUnit : null,
        bmi: bmi,
        healthStatus: _calculateHealthStatus(),
        isVerified: _isVerified,
        recordedBy:
            _recordedByController.text.isNotEmpty
                ? _recordedByController.text
                : null,
        assignedHealthWorkerId: _selectedHealthWorkerId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        lastUpdated: DateTime.now(),
        // Legacy fields for compatibility
        title:
            '${_selectedType.toUpperCase()} - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        recordType: _selectedType,
        recordDate: DateTime.now(),
        createdAt:
            _isEditMode ? widget.existingRecord!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditMode) {
        success = await ref
            .read(healthProvider.notifier)
            .updateHealthRecord(healthRecord);
      } else {
        success = await ref
            .read(healthProvider.notifier)
            .createHealthRecord(healthRecord);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Health record updated successfully!'
                  : 'Health record saved successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save health record: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculateHealthStatus() {
    // Simple health status calculation based on vital signs
    final heartRate = int.tryParse(_heartRateController.text) ?? 0;
    final temperature = double.tryParse(_temperatureController.text) ?? 0;

    if (heartRate > 100 || temperature > 37.5) {
      return 'critical'; // Critical/sick
    } else if (heartRate > 90 || temperature > 37.0) {
      return 'warning'; // Take care
    } else {
      return 'normal'; // Normal/good
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Health Record'),
            content: const Text(
              'Are you sure you want to delete this health record? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteHealthRecord();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteHealthRecord() async {
    if (!_isEditMode || widget.existingRecord?.id == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(healthProvider.notifier)
          .deleteHealthRecord(widget.existingRecord!.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health record deleted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete health record: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Health Record' : 'Add Health Record'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Record Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Record Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text('General Checkup'),
                        ),
                        DropdownMenuItem(
                          value: 'consultation',
                          child: Text('Consultation'),
                        ),
                        DropdownMenuItem(
                          value: 'laboratory',
                          child: Text('Laboratory Results'),
                        ),
                        DropdownMenuItem(
                          value: 'emergency',
                          child: Text('Emergency Visit'),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() => _selectedType = value!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vital Signs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vital Signs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Heart Rate with Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _heartRateController,
                            decoration: const InputDecoration(
                              labelText: 'Heart Rate',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final rate = int.tryParse(value);
                                if (rate == null || rate < 30 || rate > 200) {
                                  return 'Enter valid rate (30-200)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _heartRateUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'bpm',
                                child: Text('bpm'),
                              ),
                            ],
                            onChanged:
                                (value) =>
                                    setState(() => _heartRateUnit = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Blood Pressure with Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _bloodPressureController,
                            decoration: const InputDecoration(
                              labelText: 'Blood Pressure',
                              hintText: '120/80',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.monitor_heart,
                                color: Colors.blue,
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(
                                  r'^\d{2,3}\/\d{2,3}$',
                                ).hasMatch(value)) {
                                  return 'Format: 120/80';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _bpUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'mmHg',
                                child: Text('mmHg'),
                              ),
                            ],
                            onChanged:
                                (value) => setState(() => _bpUnit = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weight with Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.monitor_weight,
                                color: Colors.green,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final weight = double.tryParse(value);
                                if (weight == null ||
                                    weight < 20 ||
                                    weight > 300) {
                                  return 'Enter valid weight (20-300)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _weightUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'kg', child: Text('kg')),
                              DropdownMenuItem(
                                value: 'lbs',
                                child: Text('lbs'),
                              ),
                            ],
                            onChanged:
                                (value) => setState(() => _weightUnit = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Temperature with Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _temperatureController,
                            decoration: const InputDecoration(
                              labelText: 'Temperature',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.thermostat,
                                color: Colors.orange,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final temp = double.tryParse(value);
                                if (temp == null || temp < 30 || temp > 45) {
                                  return 'Enter valid temp (30-45)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _tempUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: '°C', child: Text('°C')),
                              DropdownMenuItem(value: '°F', child: Text('°F')),
                            ],
                            onChanged:
                                (value) => setState(() => _tempUnit = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Measurements
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Measurements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Height with Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Height',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.height,
                                color: Colors.purple,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height < 50 ||
                                    height > 250) {
                                  return 'Enter valid height (50-250)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _heightUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'cm', child: Text('cm')),
                              DropdownMenuItem(value: 'm', child: Text('m')),
                              DropdownMenuItem(value: 'ft', child: Text('ft')),
                            ],
                            onChanged:
                                (value) => setState(() => _heightUnit = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Health Status
                    DropdownButtonFormField<String>(
                      value: _healthStatus,
                      decoration: const InputDecoration(
                        labelText: 'Health Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.health_and_safety,
                          color: Colors.teal,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(
                          value: 'warning',
                          child: Text('Warning'),
                        ),
                        DropdownMenuItem(
                          value: 'critical',
                          child: Text('Critical'),
                        ),
                        DropdownMenuItem(
                          value: 'excellent',
                          child: Text('Excellent'),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() => _healthStatus = value!),
                    ),
                    const SizedBox(height: 16),

                    // Recorded By
                    TextFormField(
                      controller: _recordedByController,
                      decoration: const InputDecoration(
                        labelText: 'Recorded By (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.indigo),
                        hintText: 'Name of person recording this data',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Health Worker Assignment
                    Consumer(
                      builder: (context, ref, child) {
                        final healthWorkers =
                            ref.watch(healthProvider).healthWorkers;

                        if (healthWorkers.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return DropdownButtonFormField<int>(
                          value: _selectedHealthWorkerId,
                          decoration: const InputDecoration(
                            labelText: 'Assign to Health Worker (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.medical_services,
                              color: Colors.blue,
                            ),
                            hintText: 'Select a health worker to notify',
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('No assignment'),
                            ),
                            ...healthWorkers.map((worker) {
                              return DropdownMenuItem<int>(
                                value: worker.id,
                                child: Text(worker.name),
                              );
                            }).toList(),
                          ],
                          onChanged:
                              (value) => setState(
                                () => _selectedHealthWorkerId = value,
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Verification Status
                    CheckboxListTile(
                      title: const Text('Mark as Verified'),
                      subtitle: const Text(
                        'Check if this record has been verified by a healthcare professional',
                      ),
                      value: _isVerified,
                      onChanged:
                          (value) =>
                              setState(() => _isVerified = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Enter any additional notes or symptoms...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveHealthRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        _isEditMode
                            ? 'Update Health Record'
                            : 'Save Health Record',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid(Map<String, dynamic> vitals) {
    final vitalsList = <Widget>[];

    vitals.forEach((key, value) {
      if (value != null) {
        vitalsList.add(_buildVitalCard(key, value.toString()));
      }
    });

    return Wrap(spacing: 12, runSpacing: 12, children: vitalsList);
  }

  Widget _buildVitalCard(String label, String value) {
    IconData icon;
    Color color;
    String unit = '';

    switch (label.toLowerCase()) {
      case 'heartrate':
        icon = Icons.favorite;
        color = Colors.red;
        unit = ' bpm';
        label = 'Heart Rate';
        break;
      case 'bloodpressure':
        icon = Icons.monitor_heart;
        color = Colors.blue;
        label = 'Blood Pressure';
        break;
      case 'weight':
        icon = Icons.monitor_weight;
        color = Colors.green;
        unit = ' kg';
        label = 'Weight';
        break;
      case 'temperature':
        icon = Icons.thermostat;
        color = Colors.orange;
        unit = '°C';
        label = 'Temperature';
        break;
      case 'healthstatus':
        icon = Icons.health_and_safety;
        color = _getHealthStatusColor(value);
        label = 'Health Status';
        value = _getHealthStatusText(value);
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mwiza':
        return AppColors.success;
      case 'iyiteho':
        return Colors.orange;
      case 'urarwaye':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getHealthStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'mwiza':
        return 'Mwiza (Good)';
      case 'iyiteho':
        return 'Iyiteho (Take Care)';
      case 'urarwaye':
        return 'Urarwaye (Critical)';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareRecord(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _downloadAttachment(BuildContext context, String attachment) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $attachment...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class ViewHealthRecordScreen extends StatelessWidget {
  final HealthRecord record;

  const ViewHealthRecordScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(record.title ?? 'Health Record'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHealthRecordScreen(record: record),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRecord(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getRecordTypeColor(
                              record.recordType ?? 'general',
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getRecordTypeIcon(record.recordType ?? 'general'),
                            color: _getRecordTypeColor(
                              record.recordType ?? 'general',
                            ),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.recordTypeDisplayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.formattedDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (record.isRecent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Recent',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vital Signs Card
            if (record.hasVitals) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.monitor_heart, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Vital Signs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildVitalsGrid(record.vitals!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description Card
            if (record.description != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        record.description!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Diagnosis Card
            if (record.diagnosis != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.medical_information,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Diagnosis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          record.diagnosis!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Treatment Card
            if (record.treatment != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.healing, color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            'Treatment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          record.treatment!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Card
            if (record.notes != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note, color: AppColors.secondary),
                          SizedBox(width: 8),
                          Text(
                            'Additional Notes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        record.notes!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Healthcare Provider Info
            if (record.doctorName != null || record.facilityName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_hospital, color: AppColors.tertiary),
                          SizedBox(width: 8),
                          Text(
                            'Healthcare Provider',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (record.doctorName != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Doctor: ${record.doctorName}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (record.facilityName != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Facility: ${record.facilityName}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Attachments Card
            if (record.hasAttachments) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.attach_file, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Attachments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...record.attachments!.map((attachment) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  attachment,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed:
                                    () => _downloadAttachment(
                                      context,
                                      attachment,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Record Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Record ID', record.id?.toString() ?? 'N/A'),
                    _buildInfoRow('Record Type', record.recordTypeDisplayName),
                    _buildInfoRow('Date Created', record.formattedDate),
                    if (record.createdAt != null)
                      _buildInfoRow(
                        'Created At',
                        _formatDateTime(record.createdAt!),
                      ),
                    if (record.updatedAt != null)
                      _buildInfoRow(
                        'Last Updated',
                        _formatDateTime(record.updatedAt!),
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

  Widget _buildVitalsGrid(Map<String, dynamic> vitals) {
    final vitalsList = <Widget>[];

    vitals.forEach((key, value) {
      if (value != null) {
        vitalsList.add(_buildVitalCard(key, value.toString()));
      }
    });

    return Wrap(spacing: 12, runSpacing: 12, children: vitalsList);
  }

  Widget _buildVitalCard(String label, String value) {
    IconData icon;
    Color color;
    String unit = '';

    switch (label.toLowerCase()) {
      case 'heartrate':
        icon = Icons.favorite;
        color = Colors.red;
        unit = ' bpm';
        label = 'Heart Rate';
        break;
      case 'bloodpressure':
        icon = Icons.monitor_heart;
        color = Colors.blue;
        label = 'Blood Pressure';
        break;
      case 'weight':
        icon = Icons.monitor_weight;
        color = Colors.green;
        unit = ' kg';
        label = 'Weight';
        break;
      case 'temperature':
        icon = Icons.thermostat;
        color = Colors.orange;
        unit = '°C';
        label = 'Temperature';
        break;
      case 'healthstatus':
        icon = Icons.health_and_safety;
        color = _getHealthStatusColor(value);
        label = 'Health Status';
        value = _getHealthStatusText(value);
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Color _getRecordTypeColor(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'emergency':
        return AppColors.error;
      case 'laboratory':
        return AppColors.tertiary;
      case 'consultation':
        return AppColors.secondary;
      case 'prescription':
        return AppColors.medicationPink;
      case 'vaccination':
        return AppColors.success;
      case 'general':
      default:
        return AppColors.primary;
    }
  }

  IconData _getRecordTypeIcon(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'laboratory':
        return Icons.science;
      case 'consultation':
        return Icons.medical_services;
      case 'prescription':
        return Icons.medication;
      case 'vaccination':
        return Icons.vaccines;
      case 'general':
      default:
        return Icons.health_and_safety;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mwiza':
        return AppColors.success;
      case 'iyiteho':
        return Colors.orange;
      case 'urarwaye':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getHealthStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'mwiza':
        return 'Mwiza (Good)';
      case 'iyiteho':
        return 'Iyiteho (Take Care)';
      case 'urarwaye':
        return 'Urarwaye (Critical)';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareRecord(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _downloadAttachment(BuildContext context, String attachment) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $attachment...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class EditHealthRecordScreen extends ConsumerStatefulWidget {
  final HealthRecord record;

  const EditHealthRecordScreen({super.key, required this.record});

  @override
  ConsumerState<EditHealthRecordScreen> createState() =>
      _EditHealthRecordScreenState();
}

class _EditHealthRecordScreenState
    extends ConsumerState<EditHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _facilityNameController = TextEditingController();

  // Vitals controllers
  final _heartRateController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();

  String _selectedType = 'general';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.record.title ?? 'Health Record';
    _descriptionController.text = widget.record.description ?? '';
    _diagnosisController.text = widget.record.diagnosis ?? '';
    _treatmentController.text = widget.record.treatment ?? '';
    _notesController.text = widget.record.notes ?? '';
    _doctorNameController.text = widget.record.doctorName ?? '';
    _facilityNameController.text = widget.record.facilityName ?? '';
    _selectedType = widget.record.recordType ?? 'general';
    _selectedDate = widget.record.recordDate ?? DateTime.now();

    // Initialize vitals if available
    if (widget.record.hasVitals) {
      final vitals = widget.record.vitals!;
      _heartRateController.text = vitals['heartRate']?.toString() ?? '';
      _bloodPressureController.text = vitals['bloodPressure']?.toString() ?? '';
      _weightController.text = vitals['weight']?.toString() ?? '';
      _temperatureController.text = vitals['temperature']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _doctorNameController.dispose();
    _facilityNameController.dispose();
    _heartRateController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _updateHealthRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Build vitals map
      final vitalsMap = <String, dynamic>{};
      if (_heartRateController.text.isNotEmpty) {
        vitalsMap['heartRate'] = int.tryParse(_heartRateController.text);
      }
      if (_bloodPressureController.text.isNotEmpty) {
        vitalsMap['bloodPressure'] = _bloodPressureController.text;
      }
      if (_weightController.text.isNotEmpty) {
        vitalsMap['weight'] = double.tryParse(_weightController.text);
      }
      if (_temperatureController.text.isNotEmpty) {
        vitalsMap['temperature'] = double.tryParse(_temperatureController.text);
      }
      vitalsMap['healthStatus'] = _calculateHealthStatus();

      final updatedRecord = widget.record.copyWith(
        title: _titleController.text,
        recordType: _selectedType,
        recordDate: _selectedDate,
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        diagnosis:
            _diagnosisController.text.isNotEmpty
                ? _diagnosisController.text
                : null,
        treatment:
            _treatmentController.text.isNotEmpty
                ? _treatmentController.text
                : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        doctorName:
            _doctorNameController.text.isNotEmpty
                ? _doctorNameController.text
                : null,
        facilityName:
            _facilityNameController.text.isNotEmpty
                ? _facilityNameController.text
                : null,
        vitals: vitalsMap.isNotEmpty ? vitalsMap : null,
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(healthProvider.notifier)
          .updateHealthRecord(updatedRecord);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health record updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update health record: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculateHealthStatus() {
    final heartRate = int.tryParse(_heartRateController.text) ?? 0;
    final temperature = double.tryParse(_temperatureController.text) ?? 0;

    if (heartRate > 100 || temperature > 37.5) {
      return 'urarwaye'; // Critical/sick
    } else if (heartRate > 90 || temperature > 37.0) {
      return 'iyiteho'; // Take care
    } else {
      return 'mwiza'; // Normal/good
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Health Record'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Record Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Record Type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Record Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text('General Checkup'),
                        ),
                        DropdownMenuItem(
                          value: 'consultation',
                          child: Text('Consultation'),
                        ),
                        DropdownMenuItem(
                          value: 'laboratory',
                          child: Text('Laboratory Results'),
                        ),
                        DropdownMenuItem(
                          value: 'emergency',
                          child: Text('Emergency Visit'),
                        ),
                        DropdownMenuItem(
                          value: 'prescription',
                          child: Text('Prescription'),
                        ),
                        DropdownMenuItem(
                          value: 'vaccination',
                          child: Text('Vaccination'),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() => _selectedType = value!),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Record Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vital Signs Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vital Signs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Heart Rate
                    TextFormField(
                      controller: _heartRateController,
                      decoration: const InputDecoration(
                        labelText: 'Heart Rate (bpm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite, color: Colors.red),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final rate = int.tryParse(value);
                          if (rate == null || rate < 30 || rate > 200) {
                            return 'Enter a valid heart rate (30-200 bpm)';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Blood Pressure
                    TextFormField(
                      controller: _bloodPressureController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Pressure (e.g., 120/80)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.monitor_heart,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^\d{2,3}\/\d{2,3}$').hasMatch(value)) {
                            return 'Enter in format: 120/80';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.monitor_weight,
                          color: Colors.green,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 20 || weight > 300) {
                            return 'Enter a valid weight (20-300 kg)';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Temperature
                    TextFormField(
                      controller: _temperatureController,
                      decoration: const InputDecoration(
                        labelText: 'Temperature (°C)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.thermostat,
                          color: Colors.orange,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final temp = double.tryParse(value);
                          if (temp == null || temp < 30 || temp > 45) {
                            return 'Enter a valid temperature (30-45°C)';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Medical Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Medical Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the reason for this record...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Diagnosis
                    TextFormField(
                      controller: _diagnosisController,
                      decoration: const InputDecoration(
                        labelText: 'Diagnosis',
                        hintText: 'Enter diagnosis if available...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.medical_information,
                          color: AppColors.error,
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Treatment
                    TextFormField(
                      controller: _treatmentController,
                      decoration: const InputDecoration(
                        labelText: 'Treatment',
                        hintText: 'Enter treatment plan...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.healing,
                          color: AppColors.success,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Healthcare Provider Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Healthcare Provider',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Doctor Name
                    TextFormField(
                      controller: _doctorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Name',
                        hintText: 'Enter doctor or healthcare provider name...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Facility Name
                    TextFormField(
                      controller: _facilityNameController,
                      decoration: const InputDecoration(
                        labelText: 'Healthcare Facility',
                        hintText: 'Enter hospital or clinic name...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Notes Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter any additional notes, symptoms, or observations...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateHealthRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Update Record',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
}
