import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/simple_translated_text.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';

/// Comprehensive Add Medication Form
class AddMedicationForm extends ConsumerStatefulWidget {
  final VoidCallback onMedicationAdded;

  const AddMedicationForm({super.key, required this.onMedicationAdded});

  @override
  ConsumerState<AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends ConsumerState<AddMedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prescribedByController = TextEditingController();
  final _notesController = TextEditingController();

  String _frequency = 'daily';
  String _purpose = 'general';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _frequencies = [
    'daily',
    'twice_daily',
    'three_times_daily',
    'weekly',
    'as_needed',
  ];

  final List<String> _purposes = [
    'general',
    'contraception',
    'hormone',
    'supplement',
    'antibiotic',
    'pain_relief',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _prescribedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Add Medication'.str(),
        backgroundColor: AppColors.medicationPink,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: 'Save'.str(
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
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            color: AppColors.medicationPink,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Medication Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Medication Name *',
                          hintText: 'e.g., Paracetamol, Birth Control Pills',
                          prefixIcon: const Icon(Icons.medical_services),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter medication name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dosage
                      TextFormField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          labelText: 'Dosage *',
                          hintText: 'e.g., 500mg, 1 tablet, 5ml',
                          prefixIcon: const Icon(Icons.straighten),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter dosage';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Frequency
                      DropdownButtonFormField<String>(
                        value: _frequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency *',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            _frequencies.map((freq) {
                              return DropdownMenuItem(
                                value: freq,
                                child: Text(_getFrequencyDisplayName(freq)),
                              );
                            }).toList(),
                        onChanged:
                            (value) => setState(() => _frequency = value!),
                      ),
                      const SizedBox(height: 16),

                      // Purpose
                      DropdownButtonFormField<String>(
                        value: _purpose,
                        decoration: InputDecoration(
                          labelText: 'Purpose',
                          prefixIcon: const Icon(Icons.healing),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            _purposes.map((purpose) {
                              return DropdownMenuItem(
                                value: purpose,
                                child: Text(_getPurposeDisplayName(purpose)),
                              );
                            }).toList(),
                        onChanged: (value) => setState(() => _purpose = value!),
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
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Schedule',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Start Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.play_arrow,
                          color: AppColors.success,
                        ),
                        title: const Text('Start Date'),
                        subtitle: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: _selectStartDate,
                      ),

                      // End Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.stop, color: AppColors.error),
                        title: const Text('End Date (Optional)'),
                        subtitle: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Ongoing treatment',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_endDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed:
                                    () => setState(() => _endDate = null),
                              ),
                            const Icon(Icons.edit),
                          ],
                        ),
                        onTap: _selectEndDate,
                      ),

                      // Active Status
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active Medication'),
                        subtitle: Text(
                          _isActive
                              ? 'Currently taking this medication'
                              : 'Not currently taking',
                        ),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instructions
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Instructions',
                          hintText: 'e.g., Take with food, Before bedtime',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prescribed By
                      TextFormField(
                        controller: _prescribedByController,
                        decoration: InputDecoration(
                          labelText: 'Prescribed By',
                          hintText: 'e.g., Dr. Smith, Kigali Hospital',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Any additional notes or observations',
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
                  onPressed: _isLoading ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.medicationPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                            'Save Medication',
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

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Once daily';
      case 'twice_daily':
        return 'Twice daily';
      case 'three_times_daily':
        return 'Three times daily';
      case 'weekly':
        return 'Once weekly';
      case 'as_needed':
        return 'As needed';
      default:
        return frequency;
    }
  }

  String _getPurposeDisplayName(String purpose) {
    switch (purpose) {
      case 'general':
        return 'General Medicine';
      case 'contraception':
        return 'Contraception';
      case 'hormone':
        return 'Hormone Therapy';
      case 'supplement':
        return 'Supplement';
      case 'antibiotic':
        return 'Antibiotic';
      case 'pain_relief':
        return 'Pain Relief';
      default:
        return purpose;
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final medicationData = {
        'name': _nameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'frequency': _frequency,
        'purpose': _purpose,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'instructions':
            _instructionsController.text.trim().isNotEmpty
                ? _instructionsController.text.trim()
                : null,
        'prescribedBy':
            _prescribedByController.text.trim().isNotEmpty
                ? _prescribedByController.text.trim()
                : null,
        'notes':
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        'isActive': _isActive,
      };

      final apiService = ApiService.instance;
      final response = await apiService.createMedication(medicationData);

      if (response.success) {
        widget.onMedicationAdded();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication added successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to add medication'),
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
