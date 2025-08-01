import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/contraception_method.dart';
import '../../../core/providers/contraception_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/contraception_methods.dart';
import '../../../core/widgets/auto_translate_widget.dart';

class AddMethodForm extends ConsumerStatefulWidget {
  const AddMethodForm({super.key});

  @override
  ConsumerState<AddMethodForm> createState() => _AddMethodFormState();
}

class _AddMethodFormState extends ConsumerState<AddMethodForm> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _descriptionController = TextEditingController();
  final _effectivenessController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prescribedByController = TextEditingController();

  // Form state
  ContraceptionType? _selectedType;
  String? _selectedMethodName;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _nextAppointment;
  bool _isActive = true;

  // Available method names for selected type
  List<String> _availableMethodNames = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _effectivenessController.dispose();
    _instructionsController.dispose();
    _prescribedByController.dispose();
    super.dispose();
  }

  void _onTypeChanged(ContraceptionType? type) {
    setState(() {
      _selectedType = type;
      _selectedMethodName = null; // Reset method name when type changes
      _availableMethodNames =
          type != null ? ContraceptionMethods.getMethodNamesForType(type) : [];
    });
  }

  void _onMethodNameChanged(String? methodName) {
    setState(() {
      _selectedMethodName = methodName;

      // Auto-fill details if available
      if (methodName != null) {
        final details = ContraceptionMethods.getMethodDetails(methodName);
        if (details != null) {
          _descriptionController.text = details['description'] ?? '';
          _effectivenessController.text =
              details['effectiveness']?.toString() ?? '';
          _instructionsController.text = details['instructions'] ?? '';
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case 'start':
            _startDate = picked;
            break;
          case 'end':
            _endDate = picked;
            break;
          case 'appointment':
            _nextAppointment = picked;
            break;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null || _selectedMethodName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select contraception type and method name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final success = await ref
          .read(contraceptionProvider.notifier)
          .addMethod(
            userId: user!.id!,
            type: _selectedType!,
            name: _selectedMethodName!,
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            effectiveness:
                _effectivenessController.text.trim().isEmpty
                    ? null
                    : double.tryParse(_effectivenessController.text.trim()),
            instructions:
                _instructionsController.text.trim().isEmpty
                    ? null
                    : _instructionsController.text.trim(),
            prescribedBy:
                _prescribedByController.text.trim().isEmpty
                    ? null
                    : _prescribedByController.text.trim(),
            nextAppointment: _nextAppointment,
            isActive: _isActive,
          );

      if (success) {
        // Clear form
        _formKey.currentState!.reset();
        setState(() {
          _selectedType = null;
          _selectedMethodName = null;
          _startDate = null;
          _endDate = null;
          _nextAppointment = null;
          _isActive = true;
          _availableMethodNames = [];
        });
        _descriptionController.clear();
        _effectivenessController.clear();
        _instructionsController.clear();
        _prescribedByController.clear();

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Contraception method added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AutoTranslateWidget('Add New Contraception Method'),
              const SizedBox(height: 16),

              // Contraception Type Dropdown
              DropdownButtonFormField<ContraceptionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Contraception Type *',
                  border: OutlineInputBorder(),
                ),
                items:
                    ContraceptionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text('${type.displayName} (${type.category})'),
                      );
                    }).toList(),
                onChanged: _onTypeChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a contraception type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Method Name Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMethodName,
                decoration: const InputDecoration(
                  labelText: 'Method Name *',
                  border: OutlineInputBorder(),
                ),
                items:
                    _availableMethodNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                onChanged: _onMethodNameChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a method name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: () => _selectDate(context, 'start'),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select start date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date
              InkWell(
                onTap: () => _selectDate(context, 'end'),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Select end date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Effectiveness
              TextFormField(
                controller: _effectivenessController,
                decoration: const InputDecoration(
                  labelText: 'Effectiveness (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final effectiveness = double.tryParse(value);
                    if (effectiveness == null ||
                        effectiveness < 0 ||
                        effectiveness > 100) {
                      return 'Please enter a valid percentage (0-100)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Instructions
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Prescribed By
              TextFormField(
                controller: _prescribedByController,
                decoration: const InputDecoration(
                  labelText: 'Prescribed By',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Next Appointment
              InkWell(
                onTap: () => _selectDate(context, 'appointment'),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Appointment (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _nextAppointment != null
                        ? '${_nextAppointment!.day}/${_nextAppointment!.month}/${_nextAppointment!.year}'
                        : 'Select appointment date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const AutoTranslateWidget('Currently Using'),
                subtitle: const AutoTranslateWidget(
                  'Toggle if you are currently using this method',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const AutoTranslateWidget('Add Method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
