import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/contraception_method.dart';
import '../../../core/providers/contraception_provider.dart';

class AddContraceptionDialog extends ConsumerStatefulWidget {
  final ContraceptionMethod? method; // For editing existing method

  const AddContraceptionDialog({super.key, this.method});

  @override
  ConsumerState<AddContraceptionDialog> createState() =>
      _AddContraceptionDialogState();
}

class _AddContraceptionDialogState
    extends ConsumerState<AddContraceptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prescribedByController = TextEditingController();

  ContraceptionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _nextAppointment;
  double? _effectiveness;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.method != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final method = widget.method!;
    _nameController.text = method.name;
    _descriptionController.text = method.description ?? '';
    _instructionsController.text = method.instructions ?? '';
    _prescribedByController.text = method.prescribedBy ?? '';
    _selectedType = method.type;
    _startDate = method.startDate;
    _endDate = method.endDate;
    _nextAppointment = method.nextAppointment;
    _effectiveness = method.effectiveness;
    _isActive = method.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
                      _buildTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildDateFields(),
                      const SizedBox(height: 16),
                      _buildEffectivenessField(),
                      const SizedBox(height: 16),
                      _buildInstructionsField(),
                      const SizedBox(height: 16),
                      _buildPrescribedByField(),
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
            widget.method != null ? Icons.edit : Icons.add,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            widget.method != null
                ? 'Edit Contraception Method'
                : 'Add Contraception Method',
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
        labelText: 'Method Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medical_services),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter method name';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<ContraceptionType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Contraception Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items:
          ContraceptionType.values.map((type) {
            return DropdownMenuItem(value: type, child: Text(type.displayName));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select contraception type';
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
        const SizedBox(height: 16),
        const Text(
          'Next Appointment (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectNextAppointment(context),
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
                  _nextAppointment != null
                      ? '${_nextAppointment!.day}/${_nextAppointment!.month}/${_nextAppointment!.year}'
                      : 'Select next appointment (optional)',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEffectivenessField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Effectiveness (%)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.analytics),
        suffixText: '%',
      ),
      onChanged: (value) {
        _effectiveness = double.tryParse(value);
      },
    );
  }

  Widget _buildInstructionsField() {
    return TextFormField(
      controller: _instructionsController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Instructions',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment),
      ),
    );
  }

  Widget _buildPrescribedByField() {
    return TextFormField(
      controller: _prescribedByController,
      decoration: const InputDecoration(
        labelText: 'Prescribed By',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
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
            onPressed: _saveMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(widget.method != null ? 'Update' : 'Save'),
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

  Future<void> _selectNextAppointment(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _nextAppointment = picked;
      });
    }
  }

  void _saveMethod() {
    if (_formKey.currentState!.validate() && _startDate != null) {
      final method = ContraceptionMethod(
        id: widget.method?.id ?? 0,
        name: _nameController.text,
        type: _selectedType!,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        startDate: _startDate!,
        endDate: _endDate,
        effectiveness: _effectiveness,
        instructions:
            _instructionsController.text.isEmpty
                ? null
                : _instructionsController.text,
        nextAppointment: _nextAppointment,
        isActive: _isActive,
        prescribedBy:
            _prescribedByController.text.isEmpty
                ? null
                : _prescribedByController.text,
        createdAt: widget.method?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.method != null) {
        ref.read(contraceptionProvider.notifier).updateMethod(method);
      } else {
        ref.read(contraceptionProvider.notifier).addMethod(method);
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
    _descriptionController.dispose();
    _instructionsController.dispose();
    _prescribedByController.dispose();
    super.dispose();
  }
}
