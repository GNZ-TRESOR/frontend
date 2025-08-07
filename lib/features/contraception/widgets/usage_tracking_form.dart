import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/contraception_method.dart';
import '../../../core/models/health_worker_reports.dart';
// import '../../../core/services/health_worker_reports_service.dart'; // TODO: Implement this service
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/auto_translate_widget.dart';

class UsageTrackingForm extends ConsumerStatefulWidget {
  final ContraceptionMethod contraceptionMethod;
  final UsageTrackingEntry? existingEntry;

  const UsageTrackingForm({
    super.key,
    required this.contraceptionMethod,
    this.existingEntry,
  });

  @override
  ConsumerState<UsageTrackingForm> createState() => _UsageTrackingFormState();
}

class _UsageTrackingFormState extends ConsumerState<UsageTrackingForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _missedDose = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _selectedDate = DateTime.parse(widget.existingEntry!.usageDate);
      _notesController.text = widget.existingEntry!.notes ?? '';
      _missedDose = widget.existingEntry!.missedDose;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveUsage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final entry = UsageTrackingEntry(
        id: widget.existingEntry?.id,
        contraceptionMethodId: widget.contraceptionMethod.id,
        userId: user.id!,
        usageDate: _selectedDate.toIso8601String().split('T')[0],
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        missedDose: _missedDose,
      );

      // TODO: Implement HealthWorkerReportsService
      // final apiService = ref.read(apiServiceProvider);
      // final reportsService = HealthWorkerReportsService(apiService);

      // TODO: Implement service calls
      bool success = true; // Temporary placeholder
      // if (widget.existingEntry != null) {
      //   success = await reportsService.updateUsage(
      //     widget.existingEntry!.id!,
      //     entry,
      //   );
      // } else {
      //   success = await reportsService.recordUsage(entry);
      // }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoTranslateWidget(
                widget.existingEntry != null
                    ? 'Usage updated successfully'
                    : 'Usage recorded successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to save usage');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoTranslateWidget('Error saving usage: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoTranslateWidget(
          widget.existingEntry != null ? 'Edit Usage' : 'Record Usage',
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Method info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoTranslateWidget(
                        'Contraceptive Method',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.contraceptionMethod.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (widget.contraceptionMethod.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.contraceptionMethod.description!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: AutoTranslateWidget('Usage Date'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Missed dose checkbox
              Card(
                child: CheckboxListTile(
                  title: AutoTranslateWidget('Missed Dose'),
                  subtitle: AutoTranslateWidget(
                    'Check if you missed taking your contraceptive',
                  ),
                  value: _missedDose,
                  onChanged: (value) {
                    setState(() {
                      _missedDose = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoTranslateWidget(
                        'Notes (Optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Any additional notes about your usage...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUsage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : AutoTranslateWidget(
                            widget.existingEntry != null
                                ? 'Update Usage'
                                : 'Record Usage',
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider for API service (you'll need to implement this)
final apiServiceProvider = Provider<dynamic>((ref) {
  // Return your API service instance
  throw UnimplementedError('Implement API service provider');
});
