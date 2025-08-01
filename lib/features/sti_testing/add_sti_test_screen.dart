import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/sti_test_record.dart';
import '../../core/providers/sti_provider.dart';

/// Add/Edit STI Test Record Screen
class AddStiTestScreen extends ConsumerStatefulWidget {
  final StiTestRecord? existingRecord;

  const AddStiTestScreen({super.key, this.existingRecord});

  @override
  ConsumerState<AddStiTestScreen> createState() => _AddStiTestScreenState();
}

class _AddStiTestScreenState extends ConsumerState<AddStiTestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _testLocationController = TextEditingController();
  final _testProviderController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  String _selectedTestType = StiTestType.hiv;
  DateTime _testDate = DateTime.now();
  String _resultStatus = TestResultStatus.pending;
  DateTime? _resultDate;
  bool _followUpRequired = false;
  DateTime? _followUpDate;
  bool _isConfidential = true;
  bool _isLoading = false;

  bool get _isEditMode => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFieldsForEdit();
    }
  }

  @override
  void dispose() {
    _testLocationController.dispose();
    _testProviderController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateFieldsForEdit() {
    final record = widget.existingRecord!;
    _selectedTestType = record.testType;
    _testDate = record.testDate;
    _testLocationController.text = record.testLocation ?? '';
    _testProviderController.text = record.testProvider ?? '';
    _resultStatus = record.resultStatus;
    _resultDate = record.resultDate;
    _followUpRequired = record.followUpRequired;
    _followUpDate = record.followUpDate;
    _notesController.text = record.notes ?? '';
    _isConfidential = record.isConfidential;
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isTestDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTestDate ? _testDate : (_resultDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isTestDate) {
          _testDate = picked;
        } else {
          _resultDate = picked;
        }
      });
    }
  }

  Future<void> _selectFollowUpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _followUpDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final record = StiTestRecord(
      id: _isEditMode ? widget.existingRecord!.id : null,
      testType: _selectedTestType,
      testDate: _testDate,
      testLocation:
          _testLocationController.text.isNotEmpty
              ? _testLocationController.text
              : null,
      testProvider:
          _testProviderController.text.isNotEmpty
              ? _testProviderController.text
              : null,
      resultStatus: _resultStatus,
      resultDate: _resultDate,
      followUpRequired: _followUpRequired,
      followUpDate: _followUpDate,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isConfidential: _isConfidential,
    );

    bool success;
    if (_isEditMode) {
      success = await ref
          .read(stiProvider.notifier)
          .updateStiTestRecord(record);
    } else {
      success = await ref
          .read(stiProvider.notifier)
          .createStiTestRecord(record);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'STI test record updated successfully!'
                  : 'STI test record added successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final error = ref.read(stiProvider).error ?? 'An error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit STI Test Record' : 'Add STI Test Record',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Test Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Test Type
                            DropdownButtonFormField<String>(
                              value: _selectedTestType,
                              decoration: const InputDecoration(
                                labelText: 'Test Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.medical_services),
                              ),
                              items:
                                  StiTestType.all.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        StiTestType.getDisplayName(type),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedTestType = value!);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a test type';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Test Date
                            InkWell(
                              onTap:
                                  () => _selectDate(context, isTestDate: true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Test Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_testDate.day}/${_testDate.month}/${_testDate.year}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Test Location
                            TextFormField(
                              controller: _testLocationController,
                              decoration: const InputDecoration(
                                labelText: 'Test Location (Optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'e.g., City Health Center',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Test Provider
                            TextFormField(
                              controller: _testProviderController,
                              decoration: const InputDecoration(
                                labelText: 'Test Provider (Optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                                hintText: 'e.g., Dr. Smith',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Result Status
                            DropdownButtonFormField<String>(
                              value: _resultStatus,
                              decoration: const InputDecoration(
                                labelText: 'Result Status',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.assignment_turned_in),
                              ),
                              items:
                                  TestResultStatus.all.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        TestResultStatus.getDisplayName(status),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => _resultStatus = value!);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Result Date (only if not pending)
                            if (_resultStatus != TestResultStatus.pending) ...[
                              InkWell(
                                onTap:
                                    () =>
                                        _selectDate(context, isTestDate: false),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Result Date',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _resultDate != null
                                        ? '${_resultDate!.day}/${_resultDate!.month}/${_resultDate!.year}'
                                        : 'Select result date',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Follow-up Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Follow-up Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Follow-up Required
                            SwitchListTile(
                              title: const Text('Follow-up Required'),
                              subtitle: const Text(
                                'Schedule a follow-up appointment',
                              ),
                              value: _followUpRequired,
                              onChanged: (value) {
                                setState(() {
                                  _followUpRequired = value;
                                  if (!value) {
                                    _followUpDate = null;
                                  }
                                });
                              },
                            ),

                            // Follow-up Date (only if required)
                            if (_followUpRequired) ...[
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _selectFollowUpDate(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Follow-up Date',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.event),
                                  ),
                                  child: Text(
                                    _followUpDate != null
                                        ? '${_followUpDate!.day}/${_followUpDate!.month}/${_followUpDate!.year}'
                                        : 'Select follow-up date',
                                  ),
                                ),
                              ),
                            ],
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
                            const Text(
                              'Additional Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes (Optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                                hintText:
                                    'Any additional notes or observations...',
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Confidential
                            SwitchListTile(
                              title: const Text('Keep Confidential'),
                              subtitle: const Text(
                                'This record will be kept private',
                              ),
                              value: _isConfidential,
                              onChanged: (value) {
                                setState(() => _isConfidential = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveRecord,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            _isEditMode ? 'Update Record' : 'Save Record',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Test Record'),
            content: const Text(
              'Are you sure you want to delete this STI test record? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteRecord();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteRecord() async {
    if (widget.existingRecord?.id == null) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(stiProvider.notifier)
        .deleteStiTestRecord(widget.existingRecord!.id!);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('STI test record deleted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final error = ref.read(stiProvider).error ?? 'Failed to delete record';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
