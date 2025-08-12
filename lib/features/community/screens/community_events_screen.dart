import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/auto_translate_widget.dart';
import '../providers/community_events_provider.dart';
import '../models/community_event.dart';
import '../widgets/event_card.dart';
import '../widgets/create_event_dialog.dart';
import '../widgets/event_filters.dart';
import '../../support_groups/support_groups_tab.dart';
import '../../messages/messages_tab.dart';
import '../../support_tickets/support_tickets_tab.dart';

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
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityEventsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(communityEventsProvider);
    final user = ref.watch(currentUserProvider);
    final isHealthWorker = user?.role == 'healthworker';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Community Events',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          if (isHealthWorker)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateEventDialog(),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  if (isHealthWorker)
                    const PopupMenuItem(
                      value: 'my_events',
                      child: Row(
                        children: [
                          Icon(Icons.event_note),
                          SizedBox(width: 8),
                          Text('My Events'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'calendar',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Calendar View'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showFilters ? 160 : 100),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filters
              if (_showFilters)
                EventFilters(
                  selectedCategory: eventsState.selectedCategory,
                  selectedEventType: eventsState.selectedEventType,
                  onCategoryChanged: (category) {
                    ref
                        .read(communityEventsProvider.notifier)
                        .setCategory(category);
                  },
                  onEventTypeChanged: (eventType) {
                    ref
                        .read(communityEventsProvider.notifier)
                        .setEventType(eventType);
                  },
                  onClearFilters: () {
                    ref.read(communityEventsProvider.notifier).clearFilters();
                  },
                ),

              // Tabs
              TabBar(
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
            ],
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: eventsState.isLoading,
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
      floatingActionButton:
          isHealthWorker
              ? FloatingActionButton(
                onPressed: _showCreateEventDialog,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
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
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // Filters
          if (_showFilters) ...[
            const SizedBox(height: 16),
            EventFilters(
              selectedCategory:
                  ref.watch(communityEventsProvider).selectedCategory,
              selectedEventType:
                  ref.watch(communityEventsProvider).selectedEventType,
              onCategoryChanged: (category) {
                ref
                    .read(communityEventsProvider.notifier)
                    .setCategory(category);
              },
              onEventTypeChanged: (eventType) {
                ref
                    .read(communityEventsProvider.notifier)
                    .setEventType(eventType);
              },
              onClearFilters: () {
                ref.read(communityEventsProvider.notifier).clearFilters();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(child: 'Upcoming'.at()),
              Tab(child: 'My Events'.at()),
              Tab(child: 'Past Events'.at()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUpcomingEventsTab(),
                _buildMyEventsTab(),
                _buildPastEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsTab() {
    final eventsState = ref.watch(communityEventsProvider);
    final events = _getFilteredEvents(
      eventsState.getEventsByStatus('upcoming'),
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(communityEventsProvider.notifier).refresh(),
      child:
          events.isEmpty
              ? _buildEmptyState(
                'No upcoming events',
                'All events are in the past or there are no events scheduled',
                Icons.schedule,
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => _showEventDetails(event),
                    onJoin: () => _joinEvent(event),
                    onLeave: () => _leaveEvent(event),
                  );
                },
              ),
    );
  }

  Widget _buildMyEventsTab() {
    final eventsState = ref.watch(communityEventsProvider);
    final events = _getFilteredEvents(eventsState.myEvents);

    return RefreshIndicator(
      onRefresh:
          () => ref.read(communityEventsProvider.notifier).loadMyEvents(),
      child:
          events.isEmpty
              ? _buildEmptyState(
                'No registered events',
                'Join events to see them here',
                Icons.event_available,
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => _showEventDetails(event),
                    onJoin: () => _joinEvent(event),
                    onLeave: () => _leaveEvent(event),
                    showManageOptions: true,
                  );
                },
              ),
    );
  }

  Widget _buildPastEventsTab() {
    final eventsState = ref.watch(communityEventsProvider);
    final events = _getFilteredEvents(eventsState.getEventsByStatus('past'));

    return RefreshIndicator(
      onRefresh: () => ref.read(communityEventsProvider.notifier).refresh(),
      child:
          events.isEmpty
              ? _buildEmptyState(
                'No past events',
                'Past events will appear here',
                Icons.history,
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => _showEventDetails(event),
                    isPastEvent: true,
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed:
                () => ref.read(communityEventsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<CommunityEvent> _getFilteredEvents(List<CommunityEvent> events) {
    if (_searchQuery.isEmpty) return events;

    return ref
        .read(communityEventsProvider.notifier)
        .searchEvents(_searchQuery);
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateEventDialog(),
    ).then((created) {
      if (created == true) {
        ref.read(communityEventsProvider.notifier).refresh();
      }
    });
  }

  void _showEventDetails(CommunityEvent event) {
    // Navigate to event details screen
    // This would be implemented based on your navigation structure
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Event details: ${event.title}')));
  }

  Future<void> _joinEvent(CommunityEvent event) async {
    if (event.id == null) return;

    final success = await ref
        .read(communityEventsProvider.notifier)
        .joinEvent(event.id!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully joined ${event.title}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _leaveEvent(CommunityEvent event) async {
    if (event.id == null) return;

    final success = await ref
        .read(communityEventsProvider.notifier)
        .leaveEvent(event.id!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Left ${event.title}'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        ref.read(communityEventsProvider.notifier).refresh();
        break;
      case 'my_events':
        _tabController.animateTo(2);
        break;
      case 'calendar':
        // Navigate to calendar view
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar view coming soon')),
        );
        break;
    }
  }
}
