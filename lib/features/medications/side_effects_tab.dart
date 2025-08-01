import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/medication.dart';
import '../../core/providers/health_provider.dart';
import 'side_effects_form.dart';

/// Side Effects Tab for Medications Screen
class SideEffectsTab extends ConsumerStatefulWidget {
  const SideEffectsTab({super.key});

  @override
  ConsumerState<SideEffectsTab> createState() => _SideEffectsTabState();
}

class _SideEffectsTabState extends ConsumerState<SideEffectsTab> {
  String _selectedFilter = 'all';
  String _selectedSeverity = 'all';

  final List<String> _filterOptions = ['all', 'recent', 'severe'];
  final List<String> _severityOptions = ['all', 'mild', 'moderate', 'severe'];

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationsProvider);
    final medicationsWithSideEffects =
        medications
            .where(
              (med) => med.sideEffects != null && med.sideEffects!.isNotEmpty,
            )
            .toList();

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter',
                    prefixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      _filterOptions.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(_getFilterDisplayName(filter)),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedFilter = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  decoration: InputDecoration(
                    labelText: 'Severity',
                    prefixIcon: const Icon(Icons.thermostat),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      _severityOptions.map((severity) {
                        return DropdownMenuItem(
                          value: severity,
                          child: Text(_getSeverityDisplayName(severity)),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedSeverity = value!),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child:
              medicationsWithSideEffects.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                    onRefresh:
                        () =>
                            ref.read(healthProvider.notifier).loadMedications(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: medicationsWithSideEffects.length,
                      itemBuilder: (context, index) {
                        final medication = medicationsWithSideEffects[index];
                        return _buildMedicationSideEffectsCard(medication);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Side Effects Recorded',
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
            onPressed: _addSideEffect,
            icon: const Icon(Icons.add),
            label: const Text('Report Side Effect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSideEffectsCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.medicationPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: AppColors.medicationPink,
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
                        '${medication.dosage} • ${medication.frequency}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _addSideEffectForMedication(medication),
                  icon: Icon(Icons.add_circle_outline, color: AppColors.error),
                  tooltip: 'Report new side effect',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Side Effects List
            if (medication.sideEffects != null &&
                medication.sideEffects!.isNotEmpty) ...[
              Text(
                'Reported Side Effects:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...medication.sideEffects!.map((sideEffect) {
                return _buildSideEffectItem(sideEffect);
              }).toList(),
            ],

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewMedicationDetails(medication),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addSideEffectForMedication(medication),
                    icon: const Icon(Icons.report_problem, size: 16),
                    label: const Text('Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
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

  Widget _buildSideEffectItem(String sideEffect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sideEffect,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // TODO: Add severity indicator when available from API
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Reported',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Side Effects';
      case 'recent':
        return 'Recent (7 days)';
      case 'severe':
        return 'Severe Only';
      default:
        return filter;
    }
  }

  String _getSeverityDisplayName(String severity) {
    switch (severity) {
      case 'all':
        return 'All Severities';
      case 'mild':
        return 'Mild';
      case 'moderate':
        return 'Moderate';
      case 'severe':
        return 'Severe';
      default:
        return severity;
    }
  }

  void _addSideEffect() {
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

  void _addSideEffectForMedication(Medication medication) {
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

  void _viewMedicationDetails(Medication medication) {
    // TODO: Navigate to medication details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${medication.name}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
