import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';
import '../support_groups/support_groups_tab.dart';
import '../messages/messages_tab.dart';
import '../support_tickets/support_tickets_tab.dart';
import '../../core/models/community_event.dart';
import '../../core/providers/health_provider.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';

/// Professional Community Events Screen
class CommunityEventsScreen extends ConsumerStatefulWidget {
  const CommunityEventsScreen({super.key});

  @override
  ConsumerState<CommunityEventsScreen> createState() =>
      _CommunityEventsScreenState();
}

class _CommunityEventsScreenState extends ConsumerState<CommunityEventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // API Integration State
  List<CommunityEvent> _allEvents = [];
  List<CommunityEvent> _myEvents = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all community events
      final eventsResponse = await ApiService.instance.getCommunityEvents();

      List<CommunityEvent> events = [];
      if (eventsResponse.success && eventsResponse.data != null) {
        final eventsData =
            eventsResponse.data['events'] as List<dynamic>? ?? [];
        events =
            eventsData
                .map((e) => CommunityEvent.fromJson(e as Map<String, dynamic>))
                .toList();
      }

      // Load user's registered events
      final myEventsResponse = await ApiService.instance.getMyEvents();

      List<CommunityEvent> myEvents = [];
      if (myEventsResponse.success && myEventsResponse.data != null) {
        final myEventsData =
            myEventsResponse.data['events'] as List<dynamic>? ?? [];
        myEvents =
            myEventsData
                .map((e) => CommunityEvent.fromJson(e as Map<String, dynamic>))
                .toList();
      }

      setState(() {
        _allEvents = events;
        _myEvents = myEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final canCreateEvents =
        user != null &&
        (user.role.toLowerCase() == 'admin' ||
            user.role.toLowerCase() == 'health_worker');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community Events'),
        backgroundColor: AppColors.communityTeal,
        foregroundColor: Colors.white,
        actions: [
          if (canCreateEvents)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createEvent,
              tooltip: 'Create Event',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(child: 'Events'.at()),
            Tab(child: 'Support Groups'.at()),
            Tab(child: 'Messages'.at()),
            Tab(child: 'Support'.at()),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEventsTab(),
                  const SupportGroupsTab(),
                  const MessagesTab(),
                  const SupportTicketsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        backgroundColor: AppColors.communityTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.communityTeal),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'All',
                    'Workshop',
                    'Seminar',
                    'Support Group',
                    'Health Screening',
                    'Education',
                  ].map((category) => _buildFilterChip(category)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.communityTeal.withValues(alpha: 0.2),
        checkmarkColor: AppColors.communityTeal,
      ),
    );
  }

  Widget _buildEventsTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.communityTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.communityTeal,
            tabs: [
              Tab(child: 'Upcoming'.at()),
              Tab(child: 'My Events'.at()),
              Tab(child: 'Past Events'.at()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUpcomingTab(),
                _buildMyEventsTab(),
                _buildPastEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    final upcomingEvents =
        _allEvents.where((event) => event.isUpcoming).toList();
    final filteredEvents = _filterEvents(upcomingEvents);

    if (filteredEvents.isEmpty) {
      return _buildEmptyState(
        'No upcoming events',
        'Check back later for new community events',
        Icons.event,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildMyEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_myEvents.isEmpty) {
      return _buildEmptyState(
        'No registered events',
        'Register for events to see them here',
        Icons.event_available,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myEvents.length,
        itemBuilder: (context, index) {
          final event = _myEvents[index];
          return _buildEventCard(event, isRegistered: true);
        },
      ),
    );
  }

  Widget _buildPastEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    final pastEvents = _allEvents.where((event) => event.isPast).toList();

    if (pastEvents.isEmpty) {
      return _buildEmptyState(
        'No past events',
        'Past events will appear here',
        Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastEvents.length,
        itemBuilder: (context, index) {
          final event = pastEvents[index];
          return _buildEventCard(event, isPast: true);
        },
      ),
    );
  }

  Widget _buildEventCard(
    CommunityEvent event, {
    bool isRegistered = false,
    bool isPast = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  event.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildEventHeader(event),
                ),
              )
            else
              _buildEventHeader(event),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            event.category,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.categoryDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(event.category),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (event.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.appointmentBlue.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 12,
                                color: AppColors.appointmentBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.appointmentBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _buildEventInfo(event),
                  const SizedBox(height: 16),
                  _buildEventActions(
                    event,
                    isRegistered: isRegistered,
                    isPast: isPast,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(CommunityEvent event) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(event.category).withValues(alpha: 0.8),
            _getCategoryColor(event.category),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(event.category),
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEventInfo(CommunityEvent event) {
    return Column(
      children: [
        _buildInfoRow(Icons.schedule, event.dateRange),
        const SizedBox(height: 8),
        _buildInfoRow(
          event.isOnline ? Icons.videocam : Icons.location_on,
          event.location,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.person, event.organizer),
        if (!event.isOnline) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.people,
            '${event.currentParticipants}/${event.maxParticipants} participants',
          ),
        ],
        if (event.fee != null && event.fee! > 0) ...[
          const SizedBox(height: 8),
          _buildInfoRow(Icons.payment, event.feeDisplay),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildEventActions(
    CommunityEvent event, {
    bool isRegistered = false,
    bool isPast = false,
  }) {
    if (isPast) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewEventDetails(event),
              icon: const Icon(Icons.info),
              label: const Text('View Details'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _provideFeedback(event),
              icon: const Icon(Icons.feedback),
              label: const Text('Feedback'),
            ),
          ),
        ],
      );
    }

    if (isRegistered) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: event.isOngoing ? () => _joinEvent(event) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    event.isOngoing
                        ? AppColors.success
                        : AppColors.communityTeal,
                foregroundColor: Colors.white,
              ),
              icon: Icon(event.isOngoing ? Icons.play_arrow : Icons.schedule),
              label: Text(event.isOngoing ? 'Join Now' : event.timeUntilEvent),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _cancelRegistration(event),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
            ),
            child: const Text('Cancel'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                event.isRegistrationOpen
                    ? () => _registerForEvent(event)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.communityTeal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.event_available),
            label: Text(event.isRegistrationOpen ? 'Register' : 'Full'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => _shareEvent(event),
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<CommunityEvent> _filterEvents(List<CommunityEvent> events) {
    return events.where((event) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          event.organizer.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' ||
          event.category.toLowerCase() ==
              _selectedCategory.toLowerCase().replaceAll(' ', '_');

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return AppColors.primary;
      case 'seminar':
        return AppColors.secondary;
      case 'support_group':
        return AppColors.supportPurple;
      case 'health_screening':
        return AppColors.appointmentBlue;
      case 'education':
        return AppColors.educationBlue;
      case 'community_outreach':
        return AppColors.communityTeal;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return Icons.build;
      case 'seminar':
        return Icons.school;
      case 'support_group':
        return Icons.people;
      case 'health_screening':
        return Icons.health_and_safety;
      case 'education':
        return Icons.menu_book;
      case 'community_outreach':
        return Icons.volunteer_activism;
      default:
        return Icons.event;
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.communityTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ROLE-BASED CRUD OPERATIONS

  Future<void> _createEvent() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Check role permissions
    final canCreate =
        user.role.toLowerCase() == 'admin' ||
        user.role.toLowerCase() == 'health_worker';

    if (!canCreate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to create events'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show create event dialog
    _showCreateEventDialog();
  }

  /// Show create event dialog
  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    String selectedCategory = 'workshop';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    int maxParticipants = 50;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['workshop', 'seminar', 'support_group', 'health_camp']
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.toUpperCase()),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedCategory = value!,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      locationController.text.isNotEmpty) {
                    final eventData = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'location': locationController.text,
                      'category': selectedCategory,
                      'startDate': selectedDate.toIso8601String(),
                      'endDate':
                          selectedDate
                              .add(const Duration(hours: 2))
                              .toIso8601String(),
                      'maxParticipants': maxParticipants,
                      'isOnline': false,
                      'status': 'ACTIVE',
                    };

                    final success = await ref
                        .read(healthProvider.notifier)
                        .createCommunityEvent(eventData);

                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event created successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      _loadEvents(); // Refresh events
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create event'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.communityTeal,
                ),
                child: const Text(
                  'Create Event',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _viewEventDetails(CommunityEvent event) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(event.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 16),
                  _buildDetailRow('Category', event.category.toUpperCase()),
                  _buildDetailRow('Location', event.location),
                  _buildDetailRow('Organizer', event.organizer),
                  _buildDetailRow('Date', _formatEventDate(event.startDate)),
                  if (event.endDate != null)
                    _buildDetailRow(
                      'End Date',
                      _formatEventDate(event.endDate!),
                    ),
                  _buildDetailRow(
                    'Participants',
                    '${event.currentParticipants}/${event.maxParticipants}',
                  ),
                  if (event.fee != null && event.fee! > 0)
                    _buildDetailRow(
                      'Fee',
                      'RWF ${event.fee!.toStringAsFixed(0)}',
                    ),
                  if (event.isOnline && event.meetingLink != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Meeting Link',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _joinEvent(event),
                      child: Text(
                        event.meetingLink!,
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              if (!_isUserRegistered(event))
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _registerForEvent(event);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.communityTeal,
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
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
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  bool _isUserRegistered(CommunityEvent event) {
    // Check if user is registered for this event
    return _myEvents.any((myEvent) => myEvent.id == event.id);
  }

  String _formatEventDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _registerForEvent(CommunityEvent event) async {
    if (event.id == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(healthProvider.notifier)
          .registerForEvent(event.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully registered for ${event.title}!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload events to update registration status
        await _loadEvents();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to register for event'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering for event: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRegistration(CommunityEvent event) async {
    if (event.id == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Registration'),
            content: Text(
              'Are you sure you want to cancel your registration for "${event.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Yes, Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.instance.cancelEventRegistration(
        event.id!,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration cancelled for ${event.title}'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        // Refresh events to update registration status
        await _loadEvents();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to cancel registration: ${response.message}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling registration: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinEvent(CommunityEvent event) async {
    if (event.isOnline && event.meetingLink != null) {
      // TODO: Launch meeting link
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Joining ${event.title} - Link functionality coming soon',
          ),
          backgroundColor: AppColors.communityTeal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event location: ${event.location}'),
          backgroundColor: AppColors.communityTeal,
        ),
      );
    }
  }

  Future<void> _shareEvent(CommunityEvent event) async {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${event.title} - Coming Soon'),
        backgroundColor: AppColors.communityTeal,
      ),
    );
  }

  Future<void> _provideFeedback(CommunityEvent event) async {
    // TODO: Implement feedback functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Provide feedback for ${event.title} - Coming Soon'),
        backgroundColor: AppColors.communityTeal,
      ),
    );
  }
}
