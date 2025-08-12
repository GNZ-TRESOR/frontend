import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/community_events_provider.dart';

class CreateEventDialog extends ConsumerStatefulWidget {
  const CreateEventDialog({super.key});

  @override
  ConsumerState<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends ConsumerState<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime? _endDate;
  TimeOfDay? _endTime;
  
  String _selectedEventType = 'workshop';
  String _selectedCategory = 'general_health';
  bool _isPublic = true;
  bool _isLoading = false;

  final List<String> _eventTypes = [
    'workshop',
    'seminar',
    'support_group',
    'health_screening',
    'education',
    'community_meeting',
  ];

  final List<String> _categories = [
    'family_planning',
    'maternal_health',
    'mental_health',
    'nutrition',
    'general_health',
    'support',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter event title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter event description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Event Type and Category
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedEventType,
                              decoration: const InputDecoration(
                                labelText: 'Event Type',
                                border: OutlineInputBorder(),
                              ),
                              items: _eventTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getEventTypeDisplayName(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEventType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(_getCategoryDisplayName(category)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                child: Text(_selectedTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Participants
                      TextFormField(
                        controller: _maxParticipantsController,
                        decoration: const InputDecoration(
                          labelText: 'Max Participants (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      // Public/Private toggle
                      SwitchListTile(
                        title: const Text('Public Event'),
                        subtitle: Text(
                          _isPublic 
                              ? 'Anyone can see and join this event'
                              : 'Only invited people can see this event',
                        ),
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
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
                          : const Text('Create Event'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'eventType': _selectedEventType,
        'category': _selectedCategory,
        'eventDate': eventDateTime.toIso8601String(),
        'location': _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() 
            : null,
        'maxParticipants': _maxParticipantsController.text.trim().isNotEmpty 
            ? int.tryParse(_maxParticipantsController.text.trim()) 
            : null,
        'isPublic': _isPublic,
        'isActive': true,
      };
      
      final success = await ref
          .read(communityEventsProvider.notifier)
          .createEvent(eventData);
      
      if (success && mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "${_titleController.text}" created successfully'),
            backgroundColor: AppColors.success,
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

  String _getEventTypeDisplayName(String type) {
    switch (type) {
      case 'workshop':
        return 'Workshop';
      case 'seminar':
        return 'Seminar';
      case 'support_group':
        return 'Support Group';
      case 'health_screening':
        return 'Health Screening';
      case 'education':
        return 'Education Session';
      case 'community_meeting':
        return 'Community Meeting';
      default:
        return type;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'family_planning':
        return 'Family Planning';
      case 'maternal_health':
        return 'Maternal Health';
      case 'mental_health':
        return 'Mental Health';
      case 'nutrition':
        return 'Nutrition';
      case 'general_health':
        return 'General Health';
      case 'support':
        return 'Support';
      default:
        return category;
    }
  }
}
