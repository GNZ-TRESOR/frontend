import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/side_effect_report.dart';
import '../../../core/providers/contraception_provider.dart';

class ReportSideEffectDialog extends ConsumerStatefulWidget {
  final int? contraceptionMethodId;

  const ReportSideEffectDialog({super.key, this.contraceptionMethodId});

  @override
  ConsumerState<ReportSideEffectDialog> createState() =>
      _ReportSideEffectDialogState();
}

class _ReportSideEffectDialogState
    extends ConsumerState<ReportSideEffectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedSymptom;
  String? _selectedSeverity;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = true;

  final List<String> _symptoms = [
    'NAUSEA',
    'HEADACHE',
    'MOOD_CHANGES',
    'WEIGHT_GAIN',
    'WEIGHT_LOSS',
    'BREAST_TENDERNESS',
    'IRREGULAR_BLEEDING',
    'ACNE',
    'DECREASED_LIBIDO',
    'FATIGUE',
    'DIZZINESS',
    'CRAMPING',
    'ALLERGIC_REACTION',
    'OTHER',
  ];

  final List<String> _severities = ['MILD', 'MODERATE', 'SEVERE'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSymptomDropdown(),
                      const SizedBox(height: 16),
                      _buildSeverityDropdown(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildDateFields(),
                      const SizedBox(height: 16),
                      _buildOngoingSwitch(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Report Side Effect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSymptom,
      decoration: const InputDecoration(
        labelText: 'Symptom',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medical_services),
      ),
      items:
          _symptoms.map((symptom) {
            return DropdownMenuItem(
              value: symptom,
              child: Text(
                symptom
                    .replaceAll('_', ' ')
                    .toLowerCase()
                    .split(' ')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' '),
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSymptom = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a symptom';
        }
        return null;
      },
    );
  }

  Widget _buildSeverityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSeverity,
      decoration: const InputDecoration(
        labelText: 'Severity',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.warning),
      ),
      items:
          _severities.map((severity) {
            return DropdownMenuItem(
              value: severity,
              child: Text(
                severity
                    .toLowerCase()
                    .split(' ')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' '),
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSeverity = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select severity level';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        hintText: 'Describe the side effect in detail...',
      ),
    );
  }

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Started At', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, true),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  _startedAt != null
                      ? '${_startedAt!.day}/${_startedAt!.month}/${_startedAt!.year}'
                      : 'Select start date',
                ),
              ],
            ),
          ),
        ),
        if (!_isOngoing) ...[
          const SizedBox(height: 16),
          const Text('Ended At', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, false),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    _endedAt != null
                        ? '${_endedAt!.day}/${_endedAt!.month}/${_endedAt!.year}'
                        : 'Select end date',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOngoingSwitch() {
    return Row(
      children: [
        const Icon(Icons.schedule),
        const SizedBox(width: 8),
        const Text('Ongoing', style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Switch(
          value: _isOngoing,
          onChanged: (value) {
            setState(() {
              _isOngoing = value;
              if (value) {
                _endedAt = null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveSideEffect,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Report'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startedAt = picked;
        } else {
          _endedAt = picked;
        }
      });
    }
  }

  void _saveSideEffect() {
    if (_formKey.currentState!.validate() && _startedAt != null) {
      final sideEffect = SideEffectReport(
        id: 0,
        userId: 1, // This should come from auth provider
        contraceptionMethodId: widget.contraceptionMethodId,
        symptom: _selectedSymptom!,
        severity: _selectedSeverity!,
        notes:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        reportedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ref.read(contraceptionProvider.notifier).reportSideEffect(sideEffect);
      Navigator.of(context).pop();
    } else if (_startedAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
