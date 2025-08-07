import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/medication.dart';
import '../../../core/providers/health_provider.dart';

class AddMedicationDialog extends ConsumerStatefulWidget {
  final Medication? medication; // For editing existing medication

  const AddMedicationDialog({super.key, this.medication});

  @override
  ConsumerState<AddMedicationDialog> createState() =>
      _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _prescribedByController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final medication = widget.medication!;
    _nameController.text = medication.name;
    _dosageController.text = medication.dosage ?? '';
    _frequencyController.text = medication.frequency ?? '';
    _prescribedByController.text = medication.prescribedBy ?? '';
    _notesController.text = medication.notes ?? '';
    _startDate = medication.startDate;
    _endDate = medication.endDate;
    _isActive = medication.isActive ?? true;
  }

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
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildDosageField(),
                      const SizedBox(height: 16),
                      _buildFrequencyField(),
                      const SizedBox(height: 16),
                      _buildDateFields(),
                      const SizedBox(height: 16),
                      _buildPrescribedByField(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                      const SizedBox(height: 16),
                      _buildActiveSwitch(),
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
          Icon(
            widget.medication != null ? Icons.edit : Icons.add,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            widget.medication != null ? 'Edit Medication' : 'Add Medication',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Medication Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medication),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter medication name';
        }
        return null;
      },
    );
  }

  Widget _buildDosageField() {
    return TextFormField(
      controller: _dosageController,
      decoration: const InputDecoration(
        labelText: 'Dosage',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.science),
        hintText: 'e.g., 500mg, 1 tablet',
      ),
    );
  }

  Widget _buildFrequencyField() {
    return TextFormField(
      controller: _frequencyController,
      decoration: const InputDecoration(
        labelText: 'Frequency',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.schedule),
        hintText: 'e.g., Twice daily, Every 8 hours',
      ),
    );
  }

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _startDate != null
                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      : 'Select start date',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'End Date (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  _endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Select end date (optional)',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescribedByField() {
    return TextFormField(
      controller: _prescribedByController,
      decoration: const InputDecoration(
        labelText: 'Prescribed By',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        hintText: 'Doctor or healthcare provider name',
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Notes',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
        hintText: 'Additional instructions or notes',
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Row(
      children: [
        const Icon(Icons.check_circle),
        const SizedBox(width: 8),
        const Text('Active', style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
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
            onPressed: _saveMedication,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(widget.medication != null ? 'Update' : 'Save'),
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
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate() && _startDate != null) {
      final medication = Medication(
        id: widget.medication?.id,
        name: _nameController.text,
        dosage:
            _dosageController.text.isEmpty
                ? 'Not specified'
                : _dosageController.text,
        frequency:
            _frequencyController.text.isEmpty
                ? 'As needed'
                : _frequencyController.text,
        startDate: _startDate!,
        endDate: _endDate,
        isActive: _isActive,
        prescribedBy:
            _prescribedByController.text.isEmpty
                ? null
                : _prescribedByController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.medication?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.medication != null) {
        ref.read(healthProvider.notifier).updateMedication(medication);
      } else {
        ref.read(healthProvider.notifier).addMedication(medication);
      }

      Navigator.of(context).pop();
    } else if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _prescribedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
