import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class CommunityEventsScreen extends ConsumerStatefulWidget {
  const CommunityEventsScreen({super.key});

  @override
  ConsumerState<CommunityEventsScreen> createState() =>
      _CommunityEventsScreenState();
}

class _CommunityEventsScreenState extends ConsumerState<CommunityEventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Community events data
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _myEvents = [];

  // Form controllers
  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventLocationController = TextEditingController();
  String? _selectedEventType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _maxParticipants;

  // Event types
  final List<String> _eventTypes = [
    'Health Education Workshop',
    'Family Planning Seminar',
    'Community Health Screening',
    'Vaccination Campaign',
    'Maternal Health Session',
    'STI Prevention Workshop',
    'Nutrition Education',
    'Mental Health Awareness',
    'Youth Health Program',
    'Women\'s Health Forum',
    'Community Meeting',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _eventLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([_loadCommunityEvents(), _loadMyEvents()]);
    } catch (e) {
      debugPrint('Error loading data: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCommunityEvents() async {
    try {
      final response = await ApiService.instance.getCommunityEvents();
      if (response.success && response.data != null) {
        final events = List<Map<String, dynamic>>.from(
          (response.data as Map<String, dynamic>)['events'] ?? [],
        );
        setState(() {
          _allEvents = events;
          _upcomingEvents =
              events.where((event) {
                final eventDate = DateTime.tryParse(event['eventDate'] ?? '');
                return eventDate != null && eventDate.isAfter(DateTime.now());
              }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading community events: $e');
    }
  }

  Future<void> _loadMyEvents() async {
    try {
      final response = await ApiService.instance.getMyCommunityEvents();
      if (response.success && response.data != null) {
        setState(() {
          _myEvents = List<Map<String, dynamic>>.from(
            (response.data as Map<String, dynamic>)['events'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading my events: $e');
    }
  }

  void _loadMockData() {
    // Mock data for development
    setState(() {
      _allEvents = [
        {
          'id': 1,
          'title': 'Family Planning Education Workshop',
          'description':
              'Comprehensive workshop on modern family planning methods and reproductive health',
          'eventType': 'Family Planning Seminar',
          'eventDate': '2025-08-15T09:00:00Z',
          'location': 'Kimisagara Community Center',
          'organizer': 'Dr. Marie Uwimana',
          'organizerId': 2,
          'maxParticipants': 50,
          'currentParticipants': 23,
          'status': 'SCHEDULED',
          'isPublic': true,
          'createdAt': '2025-08-01T10:00:00Z',
        },
        {
          'id': 2,
          'title': 'Community Health Screening',
          'description':
              'Free health screening for blood pressure, diabetes, and basic health checks',
          'eventType': 'Community Health Screening',
          'eventDate': '2025-08-20T08:00:00Z',
          'location': 'Gasabo Health Center',
          'organizer': 'Dr. Marie Uwimana',
          'organizerId': 2,
          'maxParticipants': 100,
          'currentParticipants': 45,
          'status': 'SCHEDULED',
          'isPublic': true,
          'createdAt': '2025-08-02T14:30:00Z',
        },
        {
          'id': 3,
          'title': 'Maternal Health Session',
          'description':
              'Educational session for expectant mothers on prenatal care and nutrition',
          'eventType': 'Maternal Health Session',
          'eventDate': '2025-08-10T14:00:00Z',
          'location': 'Kigali Women\'s Center',
          'organizer': 'Dr. Sarah Johnson',
          'organizerId': 5,
          'maxParticipants': 30,
          'currentParticipants': 18,
          'status': 'SCHEDULED',
          'isPublic': true,
          'createdAt': '2025-07-28T11:00:00Z',
        },
        {
          'id': 4,
          'title': 'Youth Health Program',
          'description':
              'Health education program focused on adolescent health and wellness',
          'eventType': 'Youth Health Program',
          'eventDate': '2025-08-05T16:00:00Z',
          'location': 'Kimisagara Secondary School',
          'organizer': 'Dr. Marie Uwimana',
          'organizerId': 2,
          'maxParticipants': 80,
          'currentParticipants': 67,
          'status': 'COMPLETED',
          'isPublic': true,
          'createdAt': '2025-07-25T09:00:00Z',
        },
      ];

      _upcomingEvents =
          _allEvents.where((event) {
            final eventDate = DateTime.tryParse(event['eventDate'] ?? '');
            return eventDate != null && eventDate.isAfter(DateTime.now());
          }).toList();

      _myEvents =
          _allEvents.where((event) => event['organizerId'] == 2).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Events'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateEventDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Create Event',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'calendar',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_view_month),
                        SizedBox(width: 8),
                        Text('Calendar View'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Events'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'statistics',
                    child: Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('Event Statistics'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'Upcoming'),
            Tab(text: 'My Events'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllEventsTab(),
            _buildUpcomingEventsTab(),
            _buildMyEventsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllEventsTab() {
    return RefreshIndicator(
      onRefresh: _loadCommunityEvents,
      child:
          _allEvents.isEmpty
              ? _buildEmptyState(
                'No community events found',
                'Create your first community event to get started',
                Icons.event,
                () => _showCreateEventDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allEvents.length,
                itemBuilder: (context, index) {
                  final event = _allEvents[index];
                  return _buildEventCard(event);
                },
              ),
    );
  }

  Widget _buildUpcomingEventsTab() {
    return RefreshIndicator(
      onRefresh: _loadCommunityEvents,
      child:
          _upcomingEvents.isEmpty
              ? _buildEmptyState(
                'No upcoming events',
                'All community events are in the past',
                Icons.event_available,
                () => _showCreateEventDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = _upcomingEvents[index];
                  return _buildEventCard(event);
                },
              ),
    );
  }

  Widget _buildMyEventsTab() {
    return RefreshIndicator(
      onRefresh: _loadMyEvents,
      child:
          _myEvents.isEmpty
              ? _buildEmptyState(
                'No events organized',
                'You haven\'t organized any community events yet',
                Icons.event_note,
                () => _showCreateEventDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myEvents.length,
                itemBuilder: (context, index) {
                  final event = _myEvents[index];
                  return _buildEventCard(event, isMyEvent: true);
                },
              ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAction,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, {bool isMyEvent = false}) {
    final status = event['status'] ?? 'SCHEDULED';
    final eventDate = event['eventDate'];
    final maxParticipants = event['maxParticipants'] ?? 0;
    final currentParticipants = event['currentParticipants'] ?? 0;
    final title = event['title'] ?? 'Unknown Event';
    final location = event['location'] ?? 'Unknown Location';
    final organizer = event['organizer'] ?? 'Unknown Organizer';
    final eventType = event['eventType'] ?? 'Other';

    Color statusColor = AppColors.info;
    IconData statusIcon = Icons.schedule;

    switch (status) {
      case 'SCHEDULED':
        statusColor = AppColors.info;
        statusIcon = Icons.schedule;
        break;
      case 'ONGOING':
        statusColor = AppColors.warning;
        statusIcon = Icons.play_circle;
        break;
      case 'COMPLETED':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
    }

    final participationRate =
        maxParticipants > 0
            ? (currentParticipants / maxParticipants * 100).round()
            : 0;

    Color participationColor = AppColors.success;
    if (participationRate < 50) {
      participationColor = AppColors.error;
    } else if (participationRate < 80) {
      participationColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Organized by: $organizer',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isMyEvent)
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEventAction(value, event),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'view_participants',
                            child: Row(
                              children: [
                                Icon(Icons.people),
                                SizedBox(width: 8),
                                Text('View Participants'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit Event'),
                              ],
                            ),
                          ),
                          if (status == 'SCHEDULED')
                            const PopupMenuItem(
                              value: 'cancel',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel),
                                  SizedBox(width: 8),
                                  Text('Cancel Event'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.copy),
                                SizedBox(width: 8),
                                Text('Duplicate Event'),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event['description'] ?? 'No description available',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(status, statusIcon, statusColor),
                const SizedBox(width: 8),
                _buildInfoChip(eventType, Icons.category, Colors.grey),
                const SizedBox(width: 8),
                _buildInfoChip(
                  '$currentParticipants/$maxParticipants',
                  Icons.people,
                  participationColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (eventDate != null)
                  _buildInfoChip(
                    _formatDateTime(eventDate),
                    Icons.schedule,
                    Colors.grey,
                  ),
              ],
            ),
            if (!isMyEvent && status == 'SCHEDULED') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewEventDetails(event),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          currentParticipants < maxParticipants
                              ? () => _joinEvent(event)
                              : null,
                      icon: const Icon(Icons.person_add),
                      label: Text(
                        currentParticipants < maxParticipants
                            ? 'Join Event'
                            : 'Full',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Action handlers
  void _handleMenuAction(String action) {
    switch (action) {
      case 'calendar':
        _showCalendarView();
        break;
      case 'export':
        _exportEvents();
        break;
      case 'statistics':
        _showStatistics();
        break;
    }
  }

  void _handleEventAction(String action, Map<String, dynamic> event) {
    switch (action) {
      case 'view_participants':
        _viewParticipants(event);
        break;
      case 'edit':
        _editEvent(event);
        break;
      case 'cancel':
        _cancelEvent(event);
        break;
      case 'duplicate':
        _duplicateEvent(event);
        break;
    }
  }

  // Dialog methods
  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Community Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _eventTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'Enter event title',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedEventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items:
                        _eventTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                type,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEventType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _eventLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Enter event location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText:
                                _selectedDate != null
                                    ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_selectedDate!)
                                    : 'Select date',
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: _selectDate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Time',
                            hintText:
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'Select time',
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          onTap: _selectTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Participants',
                      hintText: 'Enter maximum number of participants',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxParticipants = int.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _eventDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter event description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  // Date and time selection
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  // Action implementation methods
  void _createEvent() async {
    if (_eventTitleController.text.isEmpty ||
        _selectedEventType == null ||
        _eventLocationController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await ApiService.instance.createCommunityEvent({
        'title': _eventTitleController.text,
        'description': _eventDescriptionController.text,
        'eventType': _selectedEventType,
        'eventDate': eventDateTime.toIso8601String(),
        'location': _eventLocationController.text,
        'maxParticipants': _maxParticipants ?? 50,
        'organizerId': user!.id,
        'isPublic': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community event created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearForm();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCalendarView() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening calendar view...')));
  }

  void _exportEvents() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting community events...')),
    );
  }

  void _showStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing event statistics...')),
    );
  }

  void _viewParticipants(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing participants for: ${event['title']}')),
    );
  }

  void _editEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editing event: ${event['title']}')));
  }

  void _cancelEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelling event: ${event['title']}')),
    );
  }

  void _duplicateEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicating event: ${event['title']}')),
    );
  }

  void _viewEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(event['title'] ?? 'Event Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(
                    'Event Type',
                    event['eventType'] ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    'Date & Time',
                    _formatDateTime(event['eventDate'] ?? ''),
                  ),
                  _buildDetailRow('Location', event['location'] ?? 'Unknown'),
                  _buildDetailRow('Organizer', event['organizer'] ?? 'Unknown'),
                  _buildDetailRow(
                    'Participants',
                    '${event['currentParticipants'] ?? 0}/${event['maxParticipants'] ?? 0}',
                  ),
                  _buildDetailRow('Status', event['status'] ?? 'Unknown'),
                  if (event['description'] != null &&
                      event['description'].isNotEmpty)
                    _buildDetailRow('Description', event['description']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _joinEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Joining event: ${event['title']}')));
  }

  void _clearForm() {
    _eventTitleController.clear();
    _eventDescriptionController.clear();
    _eventLocationController.clear();
    setState(() {
      _selectedEventType = null;
      _selectedDate = null;
      _selectedTime = null;
      _maxParticipants = null;
    });
  }
}
