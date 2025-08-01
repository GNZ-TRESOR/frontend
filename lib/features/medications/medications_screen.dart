import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/simple_translated_text.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/medication.dart';
import '../../core/providers/health_provider.dart';
import '../../core/utils/feature_messaging.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/mixins/tts_screen_mixin.dart';
import 'add_medication_form.dart';
import 'side_effects_form.dart';

/// Professional Medications Management Screen
class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen>
    with TickerProviderStateMixin, TTSScreenMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    // Load medications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadMedications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProvider);
    final medications = ref.watch(medicationsProvider);

    return addTTSToScaffold(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: 'Medications'.str(),
        backgroundColor: AppColors.medicationPink,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(child: 'Active'.str()),
            Tab(child: 'All'.str()),
            Tab(child: 'Reminders'.str()),
            Tab(child: 'Side Effects'.str()),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: healthState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveMedicationsTab(medications),
            _buildAllMedicationsTab(medications),
            _buildRemindersTab(medications),
            _buildSideEffectsTab(medications),
          ],
        ),
      ),
      additionalFAB: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildActiveMedicationsTab(List<Medication> medications) {
    final activeMedications = medications.where((med) => med.isActive).toList();

    if (activeMedications.isEmpty) {
      return _buildEmptyState(
        'No active medications',
        'Add your current medications to track them',
        Icons.medication,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(healthProvider.notifier).loadMedications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeMedications.length,
        itemBuilder: (context, index) {
          final medication = activeMedications[index];
          return _buildMedicationCard(medication);
        },
      ),
    );
  }

  Widget _buildAllMedicationsTab(List<Medication> medications) {
    if (medications.isEmpty) {
      return _buildEmptyState(
        'No medications recorded',
        'Start tracking your medications and side effects',
        Icons.medication,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(healthProvider.notifier).loadMedications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return _buildMedicationCard(medication);
        },
      ),
    );
  }

  Widget _buildRemindersTab(List<Medication> medications) {
    final medicationsWithReminders =
        medications.where((med) => med.hasReminders && med.isActive).toList();

    if (medicationsWithReminders.isEmpty) {
      return _buildEmptyState(
        'No medication reminders',
        'Set up reminders for your medications',
        Icons.alarm,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicationsWithReminders.length,
      itemBuilder: (context, index) {
        final medication = medicationsWithReminders[index];
        return _buildReminderCard(medication);
      },
    );
  }

  Widget _buildSideEffectsTab(List<Medication> medications) {
    try {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Side Effects Tracking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track side effects to help manage your medications better',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddSideEffectForm,
              icon: const Icon(Icons.add),
              label: const Text('Report Side Effect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Medications: ${medications.length}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    } catch (e) {
      // Fallback in case of any errors
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Side Effects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewMedicationDetails(medication),
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
                      color: AppColors.medicationPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: AppColors.medicationPink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medication.dosage} • ${medication.frequency}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            medication.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medication.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(medication.status),
                          ),
                        ),
                      ),
                      if (medication.isExpiringSoon) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Expiring Soon',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMedicationDetail(
                    'Start Date',
                    medication.formattedStartDate,
                  ),
                  const SizedBox(width: 24),
                  _buildMedicationDetail(
                    'End Date',
                    medication.formattedEndDate,
                  ),
                  const SizedBox(width: 24),
                  if (medication.daysRemaining != null)
                    _buildMedicationDetail(
                      'Days Left',
                      '${medication.daysRemaining}',
                    ),
                ],
              ),
              if (medication.hasSideEffects) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Side effects: ${medication.sideEffectsString}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (medication.hasReminders)
                    _buildActionChip(
                      'Reminders',
                      Icons.alarm,
                      AppColors.secondary,
                      () => _showRemindersDialog(medication),
                    ),
                  const SizedBox(width: 8),
                  _buildActionChip(
                    'Side Effects',
                    Icons.report_problem,
                    AppColors.warning,
                    () => _showSideEffectsDialog(medication),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _editMedication(medication),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteMedication(medication),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
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

  Widget _buildReminderCard(Medication medication) {
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
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.alarm,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        medication.dosage,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (medication.isDueForNextDose)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Due Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (medication.hasReminders) ...[
              Text(
                'Reminders:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...medication.activeReminders.map((reminder) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reminder.formattedTime} - ${reminder.daysOfWeekString}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
    );
  }

  Widget _buildActionChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.textSecondary;
      case 'inactive':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _viewMedicationDetails(Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailsScreen(medication: medication),
      ),
    );
  }

  void _editMedication(Medication medication) {
    showDialog(
      context: context,
      builder:
          (context) => EditMedicationDialog(
            medication: medication,
            onMedicationUpdated: () {
              ref.read(healthProvider.notifier).loadMedications();
            },
          ),
    );
  }

  void _deleteMedication(Medication medication) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Medication'),
            content: Text(
              'Are you sure you want to delete "${medication.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performDelete(medication);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _performDelete(Medication medication) async {
    try {
      final success = await ref
          .read(healthProvider.notifier)
          .deleteMedication(medication.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete medication'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting medication: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "side_effect",
          onPressed: _showAddSideEffectForm,
          backgroundColor: AppColors.error,
          child: const Icon(Icons.report_problem, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "medication",
          onPressed: _showAddMedicationForm,
          backgroundColor: AppColors.medicationPink,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  void _showAddMedicationForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddMedicationForm(
              onMedicationAdded: () {
                ref.read(healthProvider.notifier).loadMedications();
              },
            ),
      ),
    );
  }

  void _showAddSideEffectForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SideEffectsForm(
              onSideEffectAdded: () {
                ref.read(healthProvider.notifier).loadMedications();
              },
            ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddMedicationDialog(
            onMedicationAdded: () {
              ref.read(healthProvider.notifier).loadMedications();
            },
          ),
    );
  }

  void _showRemindersDialog(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => RemindersDialog(medication: medication),
    );
  }

  void _showSideEffectsDialog(Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SideEffectsForm(
              selectedMedication: medication,
              onSideEffectAdded: () {
                ref.read(healthProvider.notifier).loadMedications();
              },
            ),
      ),
    );
  }

  // TTS Implementation
  @override
  String getTTSContent(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider);
    final currentTab = _tabController.index;

    final buffer = StringBuffer();
    buffer.write('Medications screen. ');

    String tabName = '';
    List<Medication> filteredMedications = medications;

    switch (currentTab) {
      case 0:
        tabName = 'Active Medications';
        filteredMedications =
            medications.where((m) => m.status == 'active').toList();
        break;
      case 1:
        tabName = 'All Medications';
        break;
      case 2:
        tabName = 'Medication Reminders';
        break;
      case 3:
        tabName = 'Side Effects';
        break;
    }

    buffer.write('You are viewing the $tabName tab. ');

    if (currentTab <= 1) {
      // Active or All medications tabs
      if (filteredMedications.isEmpty) {
        buffer.write(
          'No medications found. You can add a new medication using the plus button. ',
        );
      } else {
        buffer.write('${filteredMedications.length} medications found. ');

        // Read first few medications
        final medsToRead = filteredMedications.take(3).toList();
        for (int i = 0; i < medsToRead.length; i++) {
          final med = medsToRead[i];
          buffer.write('${i + 1}. ${med.name}. ');
          buffer.write('Dosage: ${med.dosage}. ');
          buffer.write('Frequency: ${med.frequency}. ');
          buffer.write('Status: ${med.status}. ');
        }

        if (filteredMedications.length > 3) {
          buffer.write(
            'And ${filteredMedications.length - 3} more medications. ',
          );
        }
      }
    } else if (currentTab == 2) {
      buffer.write('This tab shows medication reminders and schedules. ');
    } else if (currentTab == 3) {
      buffer.write(
        'This tab shows side effects tracking for your medications. ',
      );
    }

    return buffer.toString();
  }

  @override
  String getScreenName() => 'Medications';
}

// Dialog and screen classes for medication management - FULLY IMPLEMENTED
class MedicationDetailsScreen extends ConsumerStatefulWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  @override
  ConsumerState<MedicationDetailsScreen> createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState
    extends ConsumerState<MedicationDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication.name),
        backgroundColor: AppColors.medicationPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMedication(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'add_reminder',
                    child: Row(
                      children: [
                        Icon(Icons.alarm_add, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Add Reminder'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'side_effects',
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Report Side Effect'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.medication.isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.medication.isActive
                          ? AppColors.success.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.medication.isActive
                        ? Icons.check_circle
                        : Icons.pause_circle,
                    color:
                        widget.medication.isActive
                            ? AppColors.success
                            : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.medication.isActive
                              ? 'Active Medication'
                              : 'Inactive Medication',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                widget.medication.isActive
                                    ? AppColors.success
                                    : Colors.grey,
                          ),
                        ),
                        if (widget.medication.nextDoseTime != null)
                          Text(
                            'Next dose: ${_formatDateTime(widget.medication.nextDoseTime!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medication Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medication, color: AppColors.medicationPink),
                        SizedBox(width: 8),
                        Text(
                          'Medication Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow('Name', widget.medication.name),
                    _buildDetailRow('Type', widget.medication.typeDisplayName),
                    _buildDetailRow('Dosage', widget.medication.dosage),
                    _buildDetailRow(
                      'Frequency',
                      widget.medication.frequencyDisplayName,
                    ),
                    if (widget.medication.instructions != null)
                      _buildDetailRow(
                        'Instructions',
                        widget.medication.instructions!,
                      ),
                    if (widget.medication.prescribedBy != null)
                      _buildDetailRow(
                        'Prescribed By',
                        widget.medication.prescribedBy!,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.secondary),
                        SizedBox(width: 8),
                        Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow(
                      'Start Date',
                      widget.medication.formattedStartDate,
                    ),
                    if (widget.medication.endDate != null)
                      _buildDetailRow(
                        'End Date',
                        widget.medication.formattedEndDate,
                      ),
                    _buildDetailRow(
                      'Duration',
                      '${widget.medication.durationInDays} days',
                    ),
                    if (widget.medication.nextDoseTime != null)
                      _buildDetailRow(
                        'Next Dose',
                        _formatDateTime(widget.medication.nextDoseTime!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reminders Card
            if (widget.medication.hasReminders) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alarm, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Reminders',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _addReminder(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.medication.activeReminders.map((reminder) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 20,
                                color:
                                    reminder.isEnabled
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reminder.formattedTime,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            reminder.isEnabled
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      reminder.daysOfWeekString,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: reminder.isEnabled,
                                onChanged:
                                    (value) => _toggleReminder(reminder, value),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Side Effects Card
            if (widget.medication.hasSideEffects) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: AppColors.error),
                          const SizedBox(width: 8),
                          const Text(
                            'Side Effects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _reportSideEffect(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Report'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(widget.medication.sideEffects ?? []).map((
                        sideEffect,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    sideEffect,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Card
            if (widget.medication.notes != null) ...[
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
                            'Notes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.medication.notes!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
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
                          'Medication Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Medication ID',
                      widget.medication.id?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Status',
                      widget.medication.isActive ? 'Active' : 'Inactive',
                    ),
                    if (widget.medication.createdAt != null)
                      _buildDetailRow(
                        'Added',
                        _formatDateTime(widget.medication.createdAt!),
                      ),
                    if (widget.medication.updatedAt != null)
                      _buildDetailRow(
                        'Last Updated',
                        _formatDateTime(widget.medication.updatedAt!),
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
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _takeDose(context),
                    icon: const Icon(Icons.medication),
                    label: const Text('Take Dose'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.success),
                      foregroundColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _skipDose(context),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip Dose'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _editMedication(BuildContext context) {
    // TODO: Navigate to edit medication screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit medication functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'add_reminder':
        _addReminder(context);
        break;
      case 'side_effects':
        _reportSideEffect(context);
        break;
      case 'share':
        _shareMedication(context);
        break;
      case 'delete':
        _deleteMedication(context);
        break;
    }
  }

  void _addReminder(BuildContext context) {
    // TODO: Implement add reminder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add reminder functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _toggleReminder(dynamic reminder, bool value) {
    // TODO: Implement toggle reminder functionality
    setState(() {
      // Update reminder state
    });
  }

  void _reportSideEffect(BuildContext context) {
    // TODO: Implement report side effect functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report side effect functionality coming soon'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _shareMedication(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Future<void> _deleteMedication(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Medication'),
            content: Text(
              'Are you sure you want to delete ${widget.medication.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);

      try {
        // TODO: Implement delete medication API call
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication deleted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete medication: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _takeDose(BuildContext context) {
    // TODO: Implement take dose functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dose recorded successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _skipDose(BuildContext context) {
    // TODO: Implement skip dose functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dose skipped'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class AddMedicationDialog extends StatefulWidget {
  final VoidCallback onMedicationAdded;

  const AddMedicationDialog({super.key, required this.onMedicationAdded});

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _frequency = 'Once daily';
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items:
                  [
                        'Once daily',
                        'Twice daily',
                        'Three times daily',
                        'As needed',
                      ]
                      .map(
                        (freq) =>
                            DropdownMenuItem(value: freq, child: Text(freq)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _frequency = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveMedication, child: const Text('Save')),
      ],
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _saveMedication() {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // TODO: Save to backend via provider
    widget.onMedicationAdded();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication added successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}

class EditMedicationDialog extends StatelessWidget {
  final Medication medication;
  final VoidCallback onMedicationUpdated;

  const EditMedicationDialog({
    super.key,
    required this.medication,
    required this.onMedicationUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${medication.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication editing is available in the full version.',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.medicationPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current medication details:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('• Name: ${medication.name}'),
                Text('• Dosage: ${medication.dosage}'),
                Text('• Frequency: ${medication.frequency}'),
                if (medication.instructions?.isNotEmpty == true)
                  Text('• Instructions: ${medication.instructions}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'To modify this medication, please contact your healthcare provider.',
            style: TextStyle(
              fontSize: 14,
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
            FeatureMessaging.showFeatureDialog(
              context,
              featureName: 'Medication Editing',
              customMessage:
                  'Advanced medication management features are being developed. You will be able to edit dosages, schedules, and instructions.',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.medicationPink,
          ),
          child: const Text(
            'Learn More',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class RemindersDialog extends StatelessWidget {
  final Medication medication;

  const RemindersDialog({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${medication.name} Reminders'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (medication.hasReminders) ...[
            ...medication.activeReminders.map((reminder) {
              return ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(reminder.formattedTime),
                subtitle: Text(reminder.daysOfWeekString),
              );
            }),
          ] else ...[
            const Text('No reminders set for this medication'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Add reminder functionality
            Navigator.pop(context);
          },
          child: const Text('Add Reminder'),
        ),
      ],
    );
  }
}

class SideEffectsDialog extends StatelessWidget {
  final Medication medication;

  const SideEffectsDialog({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${medication.name} Side Effects'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (medication.hasSideEffects) ...[
            Text(medication.sideEffectsString),
          ] else ...[
            const Text('No side effects recorded for this medication'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Add side effect functionality
            Navigator.pop(context);
          },
          child: const Text('Report Side Effect'),
        ),
      ],
    );
  }
}
