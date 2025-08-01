import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/pregnancy_plan.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/utils/family_planning_access_control.dart';
import 'pregnancy_plan_form_screen.dart';

/// Pregnancy Plan Detail Screen for viewing plan details
class PregnancyPlanDetailScreen extends ConsumerStatefulWidget {
  final PregnancyPlan plan;

  const PregnancyPlanDetailScreen({super.key, required this.plan});

  @override
  ConsumerState<PregnancyPlanDetailScreen> createState() =>
      _PregnancyPlanDetailScreenState();
}

class _PregnancyPlanDetailScreenState
    extends ConsumerState<PregnancyPlanDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final familyPlanningState = ref.watch(familyPlanningProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Check permissions
    final canEdit = FamilyPlanningAccessControl.canEditPregnancyPlan(
      currentUser,
      widget.plan,
    );
    final canDelete = FamilyPlanningAccessControl.canDeletePregnancyPlan(
      currentUser,
      widget.plan,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.plan.planName),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit) ...[
            IconButton(onPressed: _editPlan, icon: const Icon(Icons.edit)),
          ],
          if (canDelete) ...[
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Plan'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || familyPlanningState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 16),
              if (widget.plan.preconceptionGoals != null) ...[
                _buildSectionCard(
                  'Preconception Goals',
                  widget.plan.preconceptionGoals!,
                  Icons.flag,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.plan.healthPreparations != null) ...[
                _buildSectionCard(
                  'Health Preparations',
                  widget.plan.healthPreparations!,
                  Icons.health_and_safety,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.plan.lifestyleChanges != null) ...[
                _buildSectionCard(
                  'Lifestyle Changes',
                  widget.plan.lifestyleChanges!,
                  Icons.fitness_center,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.plan.medicalConsultations != null) ...[
                _buildSectionCard(
                  'Medical Consultations',
                  widget.plan.medicalConsultations!,
                  Icons.medical_services,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.plan.progressNotes != null) ...[
                _buildSectionCard(
                  'Progress Notes',
                  widget.plan.progressNotes!,
                  Icons.notes,
                ),
                const SizedBox(height: 16),
              ],
              _buildTimelineCard(),
            ],
          ),
        ),
      ),
      floatingActionButton:
          canEdit
              ? FloatingActionButton(
                onPressed: _editPlan,
                backgroundColor: AppColors.pregnancyPurple,
                child: const Icon(Icons.edit, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildHeaderCard() {
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
                child: Text(
                  widget.plan.planName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.plan.targetConceptionDate != null) ...[
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Target Date: ${_formatDate(widget.plan.targetConceptionDate!)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.plan.daysUntilTarget != null) ...[
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.plan.daysUntilTarget} days until target',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    widget.plan.statusDisplayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.plan.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.pregnancyPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: AppColors.pregnancyPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.plan.createdAt != null) ...[
              _buildTimelineItem(
                'Plan Created',
                _formatDate(widget.plan.createdAt!),
                Icons.add_circle,
                AppColors.success,
              ),
            ],
            if (widget.plan.updatedAt != null &&
                widget.plan.updatedAt != widget.plan.createdAt) ...[
              _buildTimelineItem(
                'Last Updated',
                _formatDate(widget.plan.updatedAt!),
                Icons.edit,
                AppColors.warning,
              ),
            ],
            if (widget.plan.targetConceptionDate != null) ...[
              _buildTimelineItem(
                'Target Conception',
                _formatDate(widget.plan.targetConceptionDate!),
                Icons.flag,
                AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
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

  Color _getStatusColor() {
    switch (widget.plan.currentStatus) {
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

  IconData _getStatusIcon() {
    switch (widget.plan.currentStatus) {
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

  void _editPlan() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (context) => PregnancyPlanFormScreen(existingPlan: widget.plan),
      ),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Pregnancy Plan'),
            content: Text(
              'Are you sure you want to delete "${widget.plan.planName}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deletePlan();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deletePlan() async {
    if (widget.plan.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(familyPlanningProvider.notifier)
          .deletePregnancyPlan(widget.plan.id!);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pregnancy plan deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        final error = ref.read(familyPlanningProvider).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to delete pregnancy plan'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
