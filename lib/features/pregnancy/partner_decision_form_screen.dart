import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/partner_decision.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Partner Decision Form Screen for creating and editing decisions
class PartnerDecisionFormScreen extends ConsumerStatefulWidget {
  final PartnerDecision? existingDecision;

  const PartnerDecisionFormScreen({
    super.key,
    this.existingDecision,
  });

  @override
  ConsumerState<PartnerDecisionFormScreen> createState() =>
      _PartnerDecisionFormScreenState();
}

class _PartnerDecisionFormScreenState
    extends ConsumerState<PartnerDecisionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  DecisionType _decisionType = DecisionType.familyPlanning;
  DecisionStatus _decisionStatus = DecisionStatus.proposed;
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingDecision != null) {
      final decision = widget.existingDecision!;
      _titleController.text = decision.decisionTitle;
      _descriptionController.text = decision.decisionDescription ?? '';
      _notesController.text = decision.notes ?? '';
      _decisionType = decision.decisionType;
      _decisionStatus = decision.decisionStatus;
      _targetDate = decision.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyPlanningState = ref.watch(familyPlanningProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.existingDecision == null ? 'Create Decision' : 'Edit Decision',
        ),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDecision,
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
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Decision Details'),
                const SizedBox(height: 16),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDecisionTypeField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Timeline & Status'),
                const SizedBox(height: 16),
                _buildTargetDateField(),
                const SizedBox(height: 16),
                _buildStatusField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Additional Notes'),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pregnancyPurple,
            AppColors.pregnancyPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pregnancyPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.how_to_vote, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingDecision == null 
                      ? 'Create Partner Decision' 
                      : 'Edit Partner Decision',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Collaborate on important family planning decisions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Decision Title *',
        hintText: 'Enter a clear title for this decision',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.title, color: AppColors.pregnancyPurple),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Decision title is required';
        }
        return null;
      },
    );
  }

  Widget _buildDecisionTypeField() {
    return DropdownButtonFormField<DecisionType>(
      value: _decisionType,
      decoration: InputDecoration(
        labelText: 'Decision Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.category, color: AppColors.pregnancyPurple),
      ),
      items: DecisionType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getDecisionTypeDisplayName(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _decisionType = value;
          });
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe the decision and its implications...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTargetDateField() {
    return InkWell(
      onTap: _selectTargetDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Target Decision Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.pregnancyPurple),
        ),
        child: Text(
          _targetDate != null
              ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
              : 'Select target decision date (optional)',
          style: TextStyle(
            color: _targetDate != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<DecisionStatus>(
      value: _decisionStatus,
      decoration: InputDecoration(
        labelText: 'Current Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.flag, color: AppColors.pregnancyPurple),
      ),
      items: DecisionStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_getDecisionStatusDisplayName(status)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _decisionStatus = value;
          });
        }
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Add any additional notes or considerations...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveDecision,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pregnancyPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.existingDecision == null ? 'Create Decision' : 'Update Decision',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _targetDate = selectedDate;
      });
    }
  }

  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final decision = PartnerDecision(
        id: widget.existingDecision?.id,
        userId: currentUser.id!,
        decisionType: _decisionType,
        decisionTitle: _titleController.text.trim(),
        decisionDescription: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        decisionStatus: _decisionStatus,
        targetDate: _targetDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      bool success;
      if (widget.existingDecision == null) {
        success = await ref.read(familyPlanningProvider.notifier).createPartnerDecision(decision);
      } else {
        success = await ref.read(familyPlanningProvider.notifier).updatePartnerDecision(decision);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingDecision == null
                    ? 'Partner decision created successfully!'
                    : 'Partner decision updated successfully!',
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
              content: Text(error ?? 'Failed to save partner decision'),
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

  String _getDecisionTypeDisplayName(DecisionType type) {
    switch (type) {
      case DecisionType.contraception:
        return 'Contraception';
      case DecisionType.familyPlanning:
        return 'Family Planning';
      case DecisionType.healthGoal:
        return 'Health Goal';
      case DecisionType.lifestyle:
        return 'Lifestyle';
    }
  }

  String _getDecisionStatusDisplayName(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.proposed:
        return 'Proposed';
      case DecisionStatus.discussing:
        return 'Discussing';
      case DecisionStatus.agreed:
        return 'Agreed';
      case DecisionStatus.disagreed:
        return 'Disagreed';
      case DecisionStatus.postponed:
        return 'Postponed';
    }
  }
}
