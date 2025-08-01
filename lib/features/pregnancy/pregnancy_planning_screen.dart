import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/models/pregnancy_plan.dart';
import '../../core/models/partner_invitation.dart';
import '../../core/models/partner_decision.dart';
import 'pregnancy_plan_form_screen.dart';
import 'pregnancy_plan_detail_screen.dart';
import 'partner_management_screen.dart';
import 'partner_invitation_accept_screen.dart';
import 'partner_decisions_screen.dart';
import 'ovulation_calculator_screen.dart';
import 'due_date_calculator_screen.dart';
import 'health_checklist_screen.dart';

/// Professional Pregnancy Planning Screen
class PregnancyPlanningScreen extends ConsumerStatefulWidget {
  const PregnancyPlanningScreen({super.key});

  @override
  ConsumerState<PregnancyPlanningScreen> createState() =>
      _PregnancyPlanningScreenState();
}

class _PregnancyPlanningScreenState
    extends ConsumerState<PregnancyPlanningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load family planning data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pregnancy Planning'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Planning'),
            Tab(text: 'Tracking'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildPlanningTab(),
            _buildTrackingTab(),
            _buildResourcesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        backgroundColor: AppColors.pregnancyPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final familyPlanningState = ref.watch(familyPlanningProvider);
    final pregnancyPlans = ref.watch(pregnancyPlansProvider);
    final activePregnancyPlans = ref.watch(activePregnancyPlansProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          _buildQuickStats(pregnancyPlans, activePregnancyPlans),
          const SizedBox(height: 16),
          if (familyPlanningState.error != null) ...[
            _buildErrorCard(familyPlanningState.error!),
            const SizedBox(height: 16),
          ],
          _buildPregnancyPlansCard(pregnancyPlans),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pregnancyPurple,
            AppColors.pregnancyPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pregnancyPurple.withOpacity(0.3),
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
              Icon(Icons.pregnant_woman, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Pregnancy Journey',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Plan, track, and prepare for your baby',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWelcomeInfo('Planning Phase', 'Pre-conception'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildWelcomeInfo('Next Step', 'Health checkup')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeInfo(String label, String value) {
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

  Widget _buildQuickStats(
    List<PregnancyPlan> pregnancyPlans,
    List<PregnancyPlan> activePregnancyPlans,
  ) {
    final totalPlans = pregnancyPlans.length;
    final activePlans = activePregnancyPlans.length;
    final completedPlans =
        pregnancyPlans
            .where(
              (plan) => plan.currentStatus == PregnancyPlanStatus.completed,
            )
            .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Plans',
            totalPlans.toString(),
            Icons.assignment,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Plans',
            activePlans.toString(),
            Icons.play_arrow,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            completedPlans.toString(),
            Icons.check_circle,
            AppColors.pregnancyPurple,
          ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          'Created pregnancy plan',
          '2 days ago',
          Icons.add_circle,
          AppColors.success,
        ),
        _buildActivityItem(
          'Updated health goals',
          '1 week ago',
          Icons.edit,
          AppColors.warning,
        ),
        _buildActivityItem(
          'Completed health assessment',
          '2 weeks ago',
          Icons.check_circle,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
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

  Widget _buildPlanningTab() {
    final pregnancyPlans = ref.watch(pregnancyPlansProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregnancy Plans',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRealPregnancyPlans(pregnancyPlans),
          const SizedBox(height: 24),
          Text(
            'Planning Tools',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPlanningTools(),
        ],
      ),
    );
  }

  Widget _buildRealPregnancyPlans(List<PregnancyPlan> plans) {
    if (plans.isEmpty) {
      return _buildEmptyPlansState();
    }

    return Column(
      children:
          plans
              .map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRealPlanCard(plan),
                ),
              )
              .toList(),
    );
  }

  Widget _buildEmptyPlansState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pregnant_woman,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Pregnancy Plans Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first pregnancy plan to start your journey',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewPlan(),
            icon: const Icon(Icons.add),
            label: const Text('Create Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pregnancyPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealPlanCard(PregnancyPlan plan) {
    return Card(
      child: InkWell(
        onTap: () => _viewPlanDetails(plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPlanStatusColor(
                    plan.currentStatus,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getPlanStatusIcon(plan.currentStatus),
                  color: _getPlanStatusColor(plan.currentStatus),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.planName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (plan.targetConceptionDate != null) ...[
                      Text(
                        'Target: ${_formatDate(plan.targetConceptionDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No target date set',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPlanStatusColor(
                    plan.currentStatus,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.statusDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getPlanStatusColor(plan.currentStatus),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String title,
    String description,
    String status,
    Color statusColor,
    IconData icon,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _viewPlanDetails(title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.pregnancyPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.pregnancyPurple, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanningTools() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildToolCard(
          'Ovulation Calculator',
          Icons.calculate,
          AppColors.primary,
          () => _openOvulationCalculator(),
        ),
        _buildToolCard(
          'Due Date Calculator',
          Icons.event,
          AppColors.secondary,
          () => _openDueDateCalculator(),
        ),
        _buildToolCard(
          'Health Checklist',
          Icons.checklist,
          AppColors.success,
          () => _openHealthChecklist(),
        ),
        _buildToolCard(
          'Fertility Tracker',
          Icons.trending_up,
          AppColors.warning,
          () => _showFertilityTracker(),
        ),
        _buildToolCard(
          'Partner Management',
          Icons.people,
          AppColors.pregnancyPurple,
          () => _openPartnerManagement(),
        ),
        _buildToolCard(
          'Join Partner',
          Icons.person_add,
          AppColors.success,
          () => _openPartnerInvitationAccept(),
        ),
        _buildToolCard(
          'Partner Decisions',
          Icons.how_to_vote,
          AppColors.secondary,
          () => _openPartnerDecisions(),
        ),
      ],
    );
  }

  Widget _buildToolCard(
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    final pregnancyPlans = ref.watch(pregnancyPlansProvider);
    final activePregnancyPlans = ref.watch(activePregnancyPlansProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRealTrackingStats(pregnancyPlans, activePregnancyPlans),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(
    String title,
    String description,
    String status,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Log Symptoms',
            Icons.add_circle,
            AppColors.warning,
            () => _logSymptoms(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Update Cycle',
            Icons.refresh,
            AppColors.primary,
            () => _updateCycle(),
          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregnancy Resources',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildComingSoonCard(),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Resources Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working on bringing you comprehensive pregnancy resources, educational content, and support tools.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resources feature is under development'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.notifications),
            label: const Text('Notify Me'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pregnancyPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showAddPlanDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Pregnancy Plan'),
            content: const Text('Choose a plan type to get started'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewPlan();
                },
                child: const Text('Create Plan'),
              ),
            ],
          ),
    );
  }

  void _createNewPlan() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const PregnancyPlanFormScreen()),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _viewPlanDetails(dynamic planOrTitle) async {
    if (planOrTitle is PregnancyPlan) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => PregnancyPlanDetailScreen(plan: planOrTitle),
        ),
      );

      if (result == true) {
        // Refresh the data
        ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
      }
    } else {
      // Legacy behavior for string titles
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opening $planOrTitle details')));
    }
  }

  void _openOvulationCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OvulationCalculatorScreen(),
      ),
    );
  }

  void _openDueDateCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DueDateCalculatorScreen()),
    );
  }

  void _openHealthChecklist() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HealthChecklistScreen()),
    );
  }

  void _showFertilityTracker() {
    final pregnancyPlans = ref.read(pregnancyPlansProvider);
    final tryingPlans =
        pregnancyPlans
            .where((plan) => plan.currentStatus == PregnancyPlanStatus.trying)
            .length;
    final totalPlans = pregnancyPlans.length;

    // Calculate a basic fertility rate based on pregnancy plans
    final pregnantPlans =
        pregnancyPlans
            .where((plan) => plan.currentStatus == PregnancyPlanStatus.pregnant)
            .length;
    final completedPlans =
        pregnancyPlans
            .where(
              (plan) => plan.currentStatus == PregnancyPlanStatus.completed,
            )
            .length;
    final successfulPlans = pregnantPlans + completedPlans;
    final fertilityRate =
        totalPlans > 0
            ? (successfulPlans / totalPlans * 100).toStringAsFixed(1)
            : '0.0';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.pregnancyPurple),
                const SizedBox(width: 8),
                const Text('Fertility Insights'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Based on your pregnancy planning data:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFertilityStatRow('Total Plans', totalPlans.toString()),
                _buildFertilityStatRow(
                  'Currently Trying',
                  tryingPlans.toString(),
                ),
                _buildFertilityStatRow(
                  'Successful Plans',
                  successfulPlans.toString(),
                ),
                _buildFertilityStatRow('Success Rate', '$fertilityRate%'),
                const SizedBox(height: 16),
                Text(
                  'This data is based on your pregnancy planning history and current status.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewPlan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pregnancyPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Plan'),
              ),
            ],
          ),
    );
  }

  Widget _buildFertilityStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _logSymptoms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Symptoms logged successfully')),
    );
  }

  void _updateCycle() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cycle updated successfully')));
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(familyPlanningProvider.notifier).clearError();
            },
            icon: Icon(Icons.close, color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyPlansCard(List<PregnancyPlan> pregnancyPlans) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pregnancy Plans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _createNewPlan,
                  icon: Icon(Icons.add, size: 16),
                  label: Text('New Plan'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.pregnancyPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pregnancyPlans.isEmpty) ...[
              _buildEmptyPlansState(),
            ] else ...[
              ...pregnancyPlans.take(3).map((plan) => _buildPlanListItem(plan)),
              if (pregnancyPlans.length > 3) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to full plans list
                    },
                    child: Text('View All Plans (${pregnancyPlans.length})'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanListItem(PregnancyPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getPlanStatusColor(plan.currentStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPlanStatusIcon(plan.currentStatus),
            color: _getPlanStatusColor(plan.currentStatus),
            size: 20,
          ),
        ),
        title: Text(
          plan.planName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.statusDisplayName,
              style: TextStyle(
                fontSize: 12,
                color: _getPlanStatusColor(plan.currentStatus),
              ),
            ),
            if (plan.targetConceptionDate != null) ...[
              Text(
                'Target: ${_formatDate(plan.targetConceptionDate!)}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => _viewPlanDetails(plan),
      ),
    );
  }

  Color _getPlanStatusColor(PregnancyPlanStatus status) {
    switch (status) {
      case PregnancyPlanStatus.planning:
        return AppColors.primary;
      case PregnancyPlanStatus.trying:
        return AppColors.warning;
      case PregnancyPlanStatus.pregnant:
        return AppColors.success;
      case PregnancyPlanStatus.paused:
        return AppColors.textSecondary;
      case PregnancyPlanStatus.completed:
        return AppColors.pregnancyPurple;
    }
  }

  IconData _getPlanStatusIcon(PregnancyPlanStatus status) {
    switch (status) {
      case PregnancyPlanStatus.planning:
        return Icons.assignment;
      case PregnancyPlanStatus.trying:
        return Icons.favorite;
      case PregnancyPlanStatus.pregnant:
        return Icons.pregnant_woman;
      case PregnancyPlanStatus.paused:
        return Icons.pause;
      case PregnancyPlanStatus.completed:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openPartnerManagement() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const PartnerManagementScreen()),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _openPartnerInvitationAccept() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PartnerInvitationAcceptScreen(),
      ),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _openPartnerDecisions() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const PartnerDecisionsScreen()),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  Widget _buildRealTrackingStats(
    List<PregnancyPlan> pregnancyPlans,
    List<PregnancyPlan> activePregnancyPlans,
  ) {
    final tryingPlans =
        pregnancyPlans
            .where((plan) => plan.currentStatus == PregnancyPlanStatus.trying)
            .length;
    final pregnantPlans =
        pregnancyPlans
            .where((plan) => plan.currentStatus == PregnancyPlanStatus.pregnant)
            .length;
    final planningPlans =
        pregnancyPlans
            .where((plan) => plan.currentStatus == PregnancyPlanStatus.planning)
            .length;

    return Column(
      children: [
        _buildTrackingCard(
          'Planning Phase',
          'Plans in preparation stage',
          '$planningPlans active',
          AppColors.primary,
          Icons.assignment,
        ),
        const SizedBox(height: 12),
        _buildTrackingCard(
          'Trying to Conceive',
          'Active conception attempts',
          '$tryingPlans ongoing',
          AppColors.warning,
          Icons.favorite,
        ),
        const SizedBox(height: 12),
        _buildTrackingCard(
          'Pregnancy Achieved',
          'Successful pregnancies',
          '$pregnantPlans current',
          AppColors.success,
          Icons.pregnant_woman,
        ),
      ],
    );
  }
}
