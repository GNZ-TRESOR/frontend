import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/pregnancy_plan.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Pregnancy Plan Form Screen for creating and editing plans
class PregnancyPlanFormScreen extends ConsumerStatefulWidget {
  final PregnancyPlan? existingPlan;

  const PregnancyPlanFormScreen({super.key, this.existingPlan});

  @override
  ConsumerState<PregnancyPlanFormScreen> createState() =>
      _PregnancyPlanFormScreenState();
}

class _PregnancyPlanFormScreenState
    extends ConsumerState<PregnancyPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planNameController = TextEditingController();
  final _preconceptionGoalsController = TextEditingController();
  final _healthPreparationsController = TextEditingController();
  final _lifestyleChangesController = TextEditingController();
  final _medicalConsultationsController = TextEditingController();
  final _progressNotesController = TextEditingController();

  DateTime? _targetConceptionDate;
  PregnancyPlanStatus _currentStatus = PregnancyPlanStatus.planning;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingPlan != null) {
      final plan = widget.existingPlan!;
      _planNameController.text = plan.planName;
      _preconceptionGoalsController.text = plan.preconceptionGoals ?? '';
      _healthPreparationsController.text = plan.healthPreparations ?? '';
      _lifestyleChangesController.text = plan.lifestyleChanges ?? '';
      _medicalConsultationsController.text = plan.medicalConsultations ?? '';
      _progressNotesController.text = plan.progressNotes ?? '';
      _targetConceptionDate = plan.targetConceptionDate;
      _currentStatus = plan.currentStatus;
    }
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _preconceptionGoalsController.dispose();
    _healthPreparationsController.dispose();
    _lifestyleChangesController.dispose();
    _medicalConsultationsController.dispose();
    _progressNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyPlanningState = ref.watch(familyPlanningProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.existingPlan == null
              ? 'Create Pregnancy Plan'
              : 'Edit Pregnancy Plan',
        ),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePlan,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || familyPlanningState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanNameField(),
                const SizedBox(height: 16),
                _buildTargetDateField(),
                const SizedBox(height: 16),
                _buildStatusField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Preconception Goals'),
                const SizedBox(height: 8),
                _buildPreconceptionGoalsField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Health Preparations'),
                const SizedBox(height: 8),
                _buildHealthPreparationsField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Lifestyle Changes'),
                const SizedBox(height: 8),
                _buildLifestyleChangesField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Medical Consultations'),
                const SizedBox(height: 8),
                _buildMedicalConsultationsField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Progress Notes'),
                const SizedBox(height: 8),
                _buildProgressNotesField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPlanNameField() {
    return TextFormField(
      controller: _planNameController,
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Plan Name *',
        hintText: 'Enter a name for your pregnancy plan',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.assignment, color: AppColors.pregnancyPurple),
        counterText: '${_planNameController.text.length}/100',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Plan name is required';
        }
        if (value.trim().length < 3) {
          return 'Plan name must be at least 3 characters long';
        }
        if (value.trim().length > 100) {
          return 'Plan name cannot exceed 100 characters';
        }
        // Check for inappropriate characters
        if (RegExp(r'[<>{}[\]\\|`~]').hasMatch(value)) {
          return 'Plan name contains invalid characters';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {}); // Update character counter
      },
    );
  }

  Widget _buildTargetDateField() {
    return InkWell(
      onTap: _selectTargetDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Target Conception Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(
            Icons.calendar_today,
            color: AppColors.pregnancyPurple,
          ),
        ),
        child: Text(
          _targetConceptionDate != null
              ? '${_targetConceptionDate!.day}/${_targetConceptionDate!.month}/${_targetConceptionDate!.year}'
              : 'Select target conception date',
          style: TextStyle(
            color:
                _targetConceptionDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<PregnancyPlanStatus>(
      value: _currentStatus,
      decoration: InputDecoration(
        labelText: 'Current Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.flag, color: AppColors.pregnancyPurple),
      ),
      items:
          PregnancyPlanStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(_getStatusDisplayName(status)),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _currentStatus = value;
          });
        }
      },
    );
  }

  Widget _buildPreconceptionGoalsField() {
    return TextFormField(
      controller: _preconceptionGoalsController,
      maxLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Describe your preconception goals and objectives...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '${_preconceptionGoalsController.text.length}/500',
      ),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          if (value.trim().length > 500) {
            return 'Preconception goals cannot exceed 500 characters';
          }
          if (value.trim().length < 10) {
            return 'Please provide more detailed goals (at least 10 characters)';
          }
        }
        return null;
      },
      onChanged: (value) {
        setState(() {}); // Update character counter
      },
    );
  }

  Widget _buildHealthPreparationsField() {
    return TextFormField(
      controller: _healthPreparationsController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'List health preparations and checkups needed...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLifestyleChangesField() {
    return TextFormField(
      controller: _lifestyleChangesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Describe lifestyle changes you plan to make...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMedicalConsultationsField() {
    return TextFormField(
      controller: _medicalConsultationsController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'List medical consultations and appointments...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProgressNotesField() {
    return TextFormField(
      controller: _progressNotesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Add notes about your progress and experiences...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pregnancyPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.existingPlan == null ? 'Create Plan' : 'Update Plan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _targetConceptionDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Select target conception date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      fieldLabelText: 'Target conception date',
      fieldHintText: 'mm/dd/yyyy',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
    );

    if (selectedDate != null) {
      // Validate the selected date
      if (selectedDate.isBefore(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target conception date cannot be in the past'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (selectedDate.isAfter(now.add(const Duration(days: 365 * 2)))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Target conception date cannot be more than 2 years in the future',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _targetConceptionDate = selectedDate;
      });
    }
  }

  Future<void> _savePlan() async {
    // Clear any previous errors
    ref.read(familyPlanningProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Additional business logic validation
    if (_targetConceptionDate != null) {
      final now = DateTime.now();
      if (_targetConceptionDate!.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Target conception date cannot be in the past'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final plan = PregnancyPlan(
        id: widget.existingPlan?.id,
        userId: 0, // Will be set by the backend
        planName: _planNameController.text.trim(),
        targetConceptionDate: _targetConceptionDate,
        currentStatus: _currentStatus,
        preconceptionGoals:
            _preconceptionGoalsController.text.trim().isNotEmpty
                ? _preconceptionGoalsController.text.trim()
                : null,
        healthPreparations:
            _healthPreparationsController.text.trim().isNotEmpty
                ? _healthPreparationsController.text.trim()
                : null,
        lifestyleChanges:
            _lifestyleChangesController.text.trim().isNotEmpty
                ? _lifestyleChangesController.text.trim()
                : null,
        medicalConsultations:
            _medicalConsultationsController.text.trim().isNotEmpty
                ? _medicalConsultationsController.text.trim()
                : null,
        progressNotes:
            _progressNotesController.text.trim().isNotEmpty
                ? _progressNotesController.text.trim()
                : null,
      );

      bool success;
      if (widget.existingPlan == null) {
        success = await ref
            .read(familyPlanningProvider.notifier)
            .createPregnancyPlan(plan);
      } else {
        success = await ref
            .read(familyPlanningProvider.notifier)
            .updatePregnancyPlan(plan);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingPlan == null
                    ? 'Pregnancy plan created successfully!'
                    : 'Pregnancy plan updated successfully!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        final error = ref.read(familyPlanningProvider).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to save pregnancy plan'),
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

  String _getStatusDisplayName(PregnancyPlanStatus status) {
    switch (status) {
      case PregnancyPlanStatus.planning:
        return 'Planning';
      case PregnancyPlanStatus.trying:
        return 'Trying to Conceive';
      case PregnancyPlanStatus.pregnant:
        return 'Pregnant';
      case PregnancyPlanStatus.paused:
        return 'Paused';
      case PregnancyPlanStatus.completed:
        return 'Completed';
    }
  }
}
