import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/models/side_effect.dart';
import '../../../core/providers/side_effects_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/contraception_provider.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_overlay.dart';
import 'simple_side_effect_form.dart';

class SideEffectsTab extends ConsumerStatefulWidget {
  final bool isHealthWorker;

  const SideEffectsTab({super.key, required this.isHealthWorker});

  @override
  ConsumerState<SideEffectsTab> createState() => _SideEffectsTabState();
}

class _SideEffectsTabState extends ConsumerState<SideEffectsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSideEffects();
    });
  }

  void _loadSideEffects() {
    final user = ref.read(currentUserProvider);
    if (user?.id != null) {
      if (widget.isHealthWorker) {
        ref.read(sideEffectsProvider.notifier).loadAllSideEffects();
      } else {
        ref
            .read(sideEffectsProvider.notifier)
            .loadUserSideEffects(userId: user!.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sideEffectsState = ref.watch(sideEffectsProvider);
    final contraceptionState = ref.watch(contraceptionProvider);

    return LoadingOverlay(
      isLoading: sideEffectsState.isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: AppColors.contraceptionOrange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isHealthWorker
                        ? l10n.sideEffectsReports
                        : l10n.sideEffects,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (!widget.isHealthWorker &&
                    contraceptionState.userMethods.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _showAddSideEffectDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.reportSideEffect),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.contraceptionOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Error handling
            if (sideEffectsState.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sideEffectsState.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(sideEffectsProvider.notifier).clearError();
                        _loadSideEffects();
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),

            // Content
            if (widget.isHealthWorker)
              _buildHealthWorkerView(sideEffectsState.allReports)
            else
              _buildUserView(sideEffectsState.userReports),
          ],
        ),
      ),
    );
  }

  Widget _buildUserView(List<SideEffectReport> reports) {
    final l10n = AppLocalizations.of(context)!;
    final contraceptionState = ref.watch(contraceptionProvider);

    if (contraceptionState.userMethods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No contraceptive methods found',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a contraceptive method first to report side effects',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.report_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No side effects reported',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the "Report Side Effect" button to add your first report',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          reports.map((report) => _buildSideEffectCard(report, false)).toList(),
    );
  }

  Widget _buildHealthWorkerView(List<SideEffectReport> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.report_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No side effect reports',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Users haven\'t reported any side effects yet',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          reports.map((report) => _buildSideEffectCard(report, true)).toList(),
    );
  }

  Widget _buildSideEffectCard(SideEffectReport report, bool showUserInfo) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(report.severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSeverityColor(report.severity),
                    ),
                  ),
                  child: Text(
                    LocalizationHelper.getSideEffectSeverity(
                      context,
                      report.severity.displayName,
                    ),
                    style: TextStyle(
                      color: _getSeverityColor(report.severity),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.contraceptionOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LocalizationHelper.getSideEffectFrequency(
                      context,
                      report.frequency.displayName,
                    ),
                    style: TextStyle(
                      color: AppColors.contraceptionOrange,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (!showUserInfo)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditSideEffectDialog(report);
                      } else if (value == 'delete') {
                        _deleteSideEffect(report);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 18),
                                const SizedBox(width: 8),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Side Effect Name
            Text(
              report.sideEffectName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            if (report.description != null && report.description!.isNotEmpty)
              Text(
                report.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.dateReported.day}/${report.dateReported.month}/${report.dateReported.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (showUserInfo) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'User ID: ${report.userId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(SideEffectSeverity severity) {
    switch (severity) {
      case SideEffectSeverity.mild:
        return Colors.green;
      case SideEffectSeverity.moderate:
        return Colors.orange;
      case SideEffectSeverity.severe:
        return Colors.red;
    }
  }

  void _showAddSideEffectDialog() {
    final contraceptionState = ref.read(contraceptionProvider);
    final activeMethods =
        contraceptionState.userMethods.where((m) => m.isActive).toList();

    if (activeMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active contraceptive methods found'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Use the first active method or show selection if multiple
    final methodId = activeMethods.first.id;
    if (methodId != null) {
      showDialog(
        context: context,
        builder: (context) => SimpleSideEffectForm(onSuccess: _loadSideEffects),
      );
    }
  }

  void _showEditSideEffectDialog(SideEffectReport report) {
    showDialog(
      context: context,
      builder: (context) => SimpleSideEffectForm(onSuccess: _loadSideEffects),
    );
  }

  void _deleteSideEffect(SideEffectReport report) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Side Effect Report'),
            content: const Text(
              'Are you sure you want to delete this side effect report?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final user = ref.read(currentUserProvider);
                  if (user?.id != null && report.id != null) {
                    await ref
                        .read(sideEffectsProvider.notifier)
                        .deleteSideEffectReport(report.id!, user!.id!);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
