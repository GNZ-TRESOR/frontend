import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/partner_decision.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import 'partner_decision_form_screen.dart';

/// Partner Decisions Screen for managing shared decisions
class PartnerDecisionsScreen extends ConsumerStatefulWidget {
  const PartnerDecisionsScreen({super.key});

  @override
  ConsumerState<PartnerDecisionsScreen> createState() =>
      _PartnerDecisionsScreenState();
}

class _PartnerDecisionsScreenState extends ConsumerState<PartnerDecisionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final familyPlanningState = ref.watch(familyPlanningProvider);
    final partnerDecisions = ref.watch(partnerDecisionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Decisions'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Resolved'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || familyPlanningState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPendingDecisionsTab(partnerDecisions),
            _buildResolvedDecisionsTab(partnerDecisions),
            _buildAllDecisionsTab(partnerDecisions),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewDecision,
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Decision'),
      ),
    );
  }

  Widget _buildPendingDecisionsTab(List<PartnerDecision> decisions) {
    final pendingDecisions = decisions.where((decision) => decision.isPending).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Pending Decisions',
            'Decisions that need discussion or agreement',
            Icons.pending_actions,
          ),
          const SizedBox(height: 16),
          if (pendingDecisions.isEmpty) ...[
            _buildEmptyState(
              'No Pending Decisions',
              'All decisions have been resolved or you haven\'t created any yet',
              Icons.check_circle_outline,
              'Create Decision',
              _createNewDecision,
            ),
          ] else ...[
            ...pendingDecisions.map((decision) => _buildDecisionCard(decision)),
          ],
        ],
      ),
    );
  }

  Widget _buildResolvedDecisionsTab(List<PartnerDecision> decisions) {
    final resolvedDecisions = decisions.where((decision) => decision.isResolved).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Resolved Decisions',
            'Decisions that have been agreed upon or declined',
            Icons.check_circle,
          ),
          const SizedBox(height: 16),
          if (resolvedDecisions.isEmpty) ...[
            _buildEmptyState(
              'No Resolved Decisions',
              'No decisions have been resolved yet',
              Icons.hourglass_empty,
              null,
              null,
            ),
          ] else ...[
            ...resolvedDecisions.map((decision) => _buildDecisionCard(decision)),
          ],
        ],
      ),
    );
  }

  Widget _buildAllDecisionsTab(List<PartnerDecision> decisions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'All Decisions',
            'Complete history of partner decisions',
            Icons.history,
          ),
          const SizedBox(height: 16),
          if (decisions.isEmpty) ...[
            _buildEmptyState(
              'No Decisions Yet',
              'Start collaborating by creating your first decision',
              Icons.how_to_vote,
              'Create Decision',
              _createNewDecision,
            ),
          ] else ...[
            ...decisions.map((decision) => _buildDecisionCard(decision)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pregnancyPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pregnancyPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
                Text(
                  subtitle,
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
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    String? buttonText,
    VoidCallback? onPressed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pregnancyPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionCard(PartnerDecision decision) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(decision.decisionStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(decision.decisionStatus),
                    color: _getStatusColor(decision.decisionStatus),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        decision.decisionTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        decision.typeDisplayName,
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
                    color: _getStatusColor(decision.decisionStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    decision.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(decision.decisionStatus),
                    ),
                  ),
                ),
              ],
            ),
            if (decision.decisionDescription != null) ...[
              const SizedBox(height: 12),
              Text(
                decision.decisionDescription!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (decision.targetDate != null) ...[
                  Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Target: ${_formatDate(decision.targetDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                ],
                if (decision.isPending) ...[
                  TextButton(
                    onPressed: () => _updateDecisionStatus(decision, DecisionStatus.discussing),
                    child: const Text('Discuss'),
                  ),
                  TextButton(
                    onPressed: () => _updateDecisionStatus(decision, DecisionStatus.agreed),
                    child: const Text('Agree'),
                  ),
                ],
                PopupMenuButton<String>(
                  onSelected: (value) => _handleDecisionAction(value, decision),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.proposed:
        return AppColors.primary;
      case DecisionStatus.discussing:
        return AppColors.warning;
      case DecisionStatus.agreed:
        return AppColors.success;
      case DecisionStatus.disagreed:
        return AppColors.error;
      case DecisionStatus.postponed:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.proposed:
        return Icons.lightbulb;
      case DecisionStatus.discussing:
        return Icons.forum;
      case DecisionStatus.agreed:
        return Icons.check_circle;
      case DecisionStatus.disagreed:
        return Icons.cancel;
      case DecisionStatus.postponed:
        return Icons.schedule;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _createNewDecision() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PartnerDecisionFormScreen(),
      ),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _updateDecisionStatus(PartnerDecision decision, DecisionStatus newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedDecision = decision.copyWith(decisionStatus: newStatus);
      final success = await ref
          .read(familyPlanningProvider.notifier)
          .updatePartnerDecision(updatedDecision);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Decision status updated to ${newStatus.name}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(familyPlanningProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update decision status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleDecisionAction(String action, PartnerDecision decision) {
    switch (action) {
      case 'edit':
        _editDecision(decision);
        break;
      case 'delete':
        _showDeleteConfirmation(decision);
        break;
    }
  }

  void _editDecision(PartnerDecision decision) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PartnerDecisionFormScreen(existingDecision: decision),
      ),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _showDeleteConfirmation(PartnerDecision decision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Decision'),
        content: Text(
          'Are you sure you want to delete "${decision.decisionTitle}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDecision(decision);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDecision(PartnerDecision decision) async {
    if (decision.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(familyPlanningProvider.notifier)
          .deletePartnerDecision(decision.id!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Decision deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(familyPlanningProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to delete decision'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
