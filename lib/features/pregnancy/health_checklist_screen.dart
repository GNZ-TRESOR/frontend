import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Health Checklist Screen for pregnancy health tracking
class HealthChecklistScreen extends ConsumerStatefulWidget {
  const HealthChecklistScreen({super.key});

  @override
  ConsumerState<HealthChecklistScreen> createState() =>
      _HealthChecklistScreenState();
}

class _HealthChecklistScreenState extends ConsumerState<HealthChecklistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, bool> _checklistItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeChecklist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeChecklist() {
    // Initialize all checklist items as unchecked
    for (final category in _healthChecklistData.keys) {
      for (final item in _healthChecklistData[category]!) {
        _checklistItems[item.id] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Checklist'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pre-Pregnancy'),
            Tab(text: 'During Pregnancy'),
            Tab(text: 'Postpartum'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChecklistTab('prePregnancy'),
                  _buildChecklistTab('duringPregnancy'),
                  _buildChecklistTab('postpartum'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final totalItems = _checklistItems.length;
    final completedItems = _checklistItems.values.where((completed) => completed).length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pregnancyPurple.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$completedItems / $totalItems completed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.pregnancyPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pregnancyPurple),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistTab(String category) {
    final items = _healthChecklistData[category] ?? [];
    final completedItems = items.where((item) => _checklistItems[item.id] == true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(category, completedItems, items.length),
          const SizedBox(height: 16),
          ...items.map((item) => _buildChecklistItem(item)),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String category, int completed, int total) {
    final categoryNames = {
      'prePregnancy': 'Pre-Pregnancy Health',
      'duringPregnancy': 'During Pregnancy',
      'postpartum': 'Postpartum Care',
    };

    final categoryDescriptions = {
      'prePregnancy': 'Prepare your body for a healthy pregnancy',
      'duringPregnancy': 'Essential care during your pregnancy journey',
      'postpartum': 'Recovery and care after delivery',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: AppColors.pregnancyPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryNames[category] ?? category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      categoryDescriptions[category] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Progress: ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$completed / $total completed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pregnancyPurple,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(completed, total).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${((completed / total) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getProgressColor(completed, total),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(HealthChecklistItem item) {
    final isCompleted = _checklistItems[item.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleItem(item.id),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? AppColors.success : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted 
                          ? AppColors.textSecondary 
                          : AppColors.textPrimary,
                      decoration: isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(item.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(item.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (item.timing != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Timing: ${item.timing}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
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

  Color _getProgressColor(int completed, int total) {
    final percentage = completed / total;
    if (percentage >= 0.8) return AppColors.success;
    if (percentage >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.error;
      case Priority.medium:
        return AppColors.warning;
      case Priority.low:
        return AppColors.success;
    }
  }

  void _toggleItem(String itemId) {
    setState(() {
      _checklistItems[itemId] = !(_checklistItems[itemId] ?? false);
    });

    // Show feedback
    final isCompleted = _checklistItems[itemId] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted ? 'Item marked as completed!' : 'Item marked as incomplete',
        ),
        backgroundColor: isCompleted ? AppColors.success : AppColors.warning,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

enum Priority { high, medium, low }

class HealthChecklistItem {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final String? timing;

  HealthChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.timing,
  });
}

// Health checklist data
final Map<String, List<HealthChecklistItem>> _healthChecklistData = {
  'prePregnancy': [
    HealthChecklistItem(
      id: 'pre_1',
      title: 'Take Folic Acid Supplement',
      description: 'Start taking 400-800 mcg of folic acid daily to prevent birth defects',
      priority: Priority.high,
      timing: 'At least 1 month before conception',
    ),
    HealthChecklistItem(
      id: 'pre_2',
      title: 'Schedule Preconception Checkup',
      description: 'Visit your healthcare provider for a comprehensive health assessment',
      priority: Priority.high,
      timing: '3-6 months before trying to conceive',
    ),
    HealthChecklistItem(
      id: 'pre_3',
      title: 'Update Vaccinations',
      description: 'Ensure you\'re up to date on all recommended vaccines',
      priority: Priority.high,
      timing: 'Before conception',
    ),
    HealthChecklistItem(
      id: 'pre_4',
      title: 'Maintain Healthy Weight',
      description: 'Achieve and maintain a healthy BMI through diet and exercise',
      priority: Priority.medium,
      timing: 'Ongoing',
    ),
    HealthChecklistItem(
      id: 'pre_5',
      title: 'Quit Smoking and Alcohol',
      description: 'Stop smoking and limit alcohol consumption',
      priority: Priority.high,
      timing: 'Before conception',
    ),
    HealthChecklistItem(
      id: 'pre_6',
      title: 'Review Medications',
      description: 'Discuss all medications and supplements with your doctor',
      priority: Priority.medium,
      timing: 'Before conception',
    ),
  ],
  'duringPregnancy': [
    HealthChecklistItem(
      id: 'during_1',
      title: 'Regular Prenatal Checkups',
      description: 'Attend all scheduled prenatal appointments',
      priority: Priority.high,
      timing: 'Throughout pregnancy',
    ),
    HealthChecklistItem(
      id: 'during_2',
      title: 'Take Prenatal Vitamins',
      description: 'Continue taking prenatal vitamins with folic acid and iron',
      priority: Priority.high,
      timing: 'Daily throughout pregnancy',
    ),
    HealthChecklistItem(
      id: 'during_3',
      title: 'First Trimester Screening',
      description: 'Complete genetic screening tests if recommended',
      priority: Priority.medium,
      timing: '10-13 weeks',
    ),
    HealthChecklistItem(
      id: 'during_4',
      title: 'Anatomy Scan',
      description: 'Schedule detailed ultrasound to check baby\'s development',
      priority: Priority.high,
      timing: '18-22 weeks',
    ),
    HealthChecklistItem(
      id: 'during_5',
      title: 'Glucose Screening',
      description: 'Test for gestational diabetes',
      priority: Priority.high,
      timing: '24-28 weeks',
    ),
    HealthChecklistItem(
      id: 'during_6',
      title: 'Monitor Baby\'s Movement',
      description: 'Track fetal movements and report any concerns',
      priority: Priority.medium,
      timing: 'After 28 weeks',
    ),
    HealthChecklistItem(
      id: 'during_7',
      title: 'Prepare Birth Plan',
      description: 'Discuss delivery preferences with your healthcare team',
      priority: Priority.low,
      timing: 'Third trimester',
    ),
  ],
  'postpartum': [
    HealthChecklistItem(
      id: 'post_1',
      title: 'Postpartum Checkup',
      description: 'Schedule follow-up appointment with your healthcare provider',
      priority: Priority.high,
      timing: '6 weeks after delivery',
    ),
    HealthChecklistItem(
      id: 'post_2',
      title: 'Mental Health Screening',
      description: 'Monitor for signs of postpartum depression or anxiety',
      priority: Priority.high,
      timing: 'First few months',
    ),
    HealthChecklistItem(
      id: 'post_3',
      title: 'Breastfeeding Support',
      description: 'Seek help if experiencing breastfeeding difficulties',
      priority: Priority.medium,
      timing: 'As needed',
    ),
    HealthChecklistItem(
      id: 'post_4',
      title: 'Contraception Planning',
      description: 'Discuss family planning options with your doctor',
      priority: Priority.medium,
      timing: '6 weeks postpartum',
    ),
    HealthChecklistItem(
      id: 'post_5',
      title: 'Pelvic Floor Exercises',
      description: 'Begin pelvic floor strengthening exercises',
      priority: Priority.medium,
      timing: 'After clearance from doctor',
    ),
    HealthChecklistItem(
      id: 'post_6',
      title: 'Gradual Return to Exercise',
      description: 'Slowly resume physical activity as approved by doctor',
      priority: Priority.low,
      timing: 'After 6-week clearance',
    ),
  ],
};
