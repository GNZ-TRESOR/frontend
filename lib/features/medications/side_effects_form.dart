import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/medication.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/health_provider.dart';

/// Side Effects Recording Form
class SideEffectsForm extends ConsumerStatefulWidget {
  final Medication? selectedMedication;
  final VoidCallback onSideEffectAdded;

  const SideEffectsForm({
    super.key,
    this.selectedMedication,
    required this.onSideEffectAdded,
  });

  @override
  ConsumerState<SideEffectsForm> createState() => _SideEffectsFormState();
}

class _SideEffectsFormState extends ConsumerState<SideEffectsForm> {
  final _formKey = GlobalKey<FormState>();
  final _sideEffectController = TextEditingController();
  final _severityController = TextEditingController();
  final _notesController = TextEditingController();

  Medication? _selectedMedication;
  String _severity = 'mild';
  DateTime _dateOccurred = DateTime.now();
  bool _isLoading = false;

  final List<String> _severityLevels = ['mild', 'moderate', 'severe'];

  final List<String> _commonSideEffects = [
    'Nausea',
    'Headache',
    'Dizziness',
    'Fatigue',
    'Stomach upset',
    'Drowsiness',
    'Dry mouth',
    'Constipation',
    'Diarrhea',
    'Skin rash',
    'Allergic reaction',
    'Sleep problems',
    'Mood changes',
    'Loss of appetite',
    'Weight gain',
    'Weight loss',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMedication = widget.selectedMedication;
  }

  @override
  void dispose() {
    _sideEffectController.dispose();
    _severityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Side Effect'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSideEffect,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If you\'re experiencing severe side effects, please contact your healthcare provider immediately.',
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
              ),
              const SizedBox(height: 20),

              // Medication Selection Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medication, color: AppColors.medicationPink),
                          const SizedBox(width: 8),
                          Text(
                            'Select Medication',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (medications.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No medications found. Please add a medication first.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<Medication>(
                          value: _selectedMedication,
                          decoration: InputDecoration(
                            labelText: 'Medication *',
                            prefixIcon: const Icon(Icons.medical_services),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: medications.map((medication) {
                            return DropdownMenuItem(
                              value: medication,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    medication.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${medication.dosage} • ${medication.frequency}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedMedication = value),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a medication';
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Side Effect Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.report_problem, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text(
                            'Side Effect Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Common Side Effects Chips
                      Text(
                        'Common Side Effects (tap to select):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _commonSideEffects.map((effect) {
                          return FilterChip(
                            label: Text(effect),
                            selected: _sideEffectController.text == effect,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _sideEffectController.text = effect;
                                });
                              }
                            },
                            selectedColor: AppColors.error.withOpacity(0.2),
                            checkmarkColor: AppColors.error,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Custom Side Effect
                      TextFormField(
                        controller: _sideEffectController,
                        decoration: InputDecoration(
                          labelText: 'Side Effect *',
                          hintText: 'Describe the side effect you experienced',
                          prefixIcon: const Icon(Icons.warning_amber),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe the side effect';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Severity
                      DropdownButtonFormField<String>(
                        value: _severity,
                        decoration: InputDecoration(
                          labelText: 'Severity *',
                          prefixIcon: const Icon(Icons.thermostat),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _severityLevels.map((severity) {
                          return DropdownMenuItem(
                            value: severity,
                            child: Row(
                              children: [
                                Icon(
                                  _getSeverityIcon(severity),
                                  color: _getSeverityColor(severity),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(_getSeverityDisplayName(severity)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _severity = value!),
                      ),
                      const SizedBox(height: 16),

                      // Date Occurred
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.calendar_today, color: AppColors.primary),
                        title: const Text('Date Occurred'),
                        subtitle: Text(
                          '${_dateOccurred.day}/${_dateOccurred.month}/${_dateOccurred.year}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 16),

                      // Additional Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Additional Notes',
                          hintText: 'Any additional details about the side effect...',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSideEffect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Report Side Effect',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'mild':
        return Icons.sentiment_satisfied;
      case 'moderate':
        return Icons.sentiment_neutral;
      case 'severe':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'mild':
        return AppColors.warning;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getSeverityDisplayName(String severity) {
    switch (severity) {
      case 'mild':
        return 'Mild - Manageable discomfort';
      case 'moderate':
        return 'Moderate - Noticeable impact';
      case 'severe':
        return 'Severe - Significant impact';
      default:
        return severity;
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOccurred,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateOccurred = date);
    }
  }

  Future<void> _saveSideEffect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a medication'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sideEffectData = {
        'sideEffect': _sideEffectController.text.trim(),
        'severity': _severity,
        'dateOccurred': _dateOccurred.toIso8601String(),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      final apiService = ApiService.instance;
      final response = await apiService.createMedicationSideEffect(
        _selectedMedication!.id!,
        sideEffectData,
      );

      if (response.success) {
        widget.onSideEffectAdded();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Side effect reported successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to report side effect'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
