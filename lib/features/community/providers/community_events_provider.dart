import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/community_event.dart';

/// Community Events State
class CommunityEventsState {
  final List<CommunityEvent> allEvents;
  final List<CommunityEvent> myEvents;
  final List<CommunityEvent> upcomingEvents;
  final List<CommunityEvent> pastEvents;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final String selectedEventType;

  const CommunityEventsState({
    this.allEvents = const [],
    this.myEvents = const [],
    this.upcomingEvents = const [],
    this.pastEvents = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'all',
    this.selectedEventType = 'all',
  });

  CommunityEventsState copyWith({
    List<CommunityEvent>? allEvents,
    List<CommunityEvent>? myEvents,
    List<CommunityEvent>? upcomingEvents,
    List<CommunityEvent>? pastEvents,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? selectedEventType,
  }) {
    return CommunityEventsState(
      allEvents: allEvents ?? this.allEvents,
      myEvents: myEvents ?? this.myEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      pastEvents: pastEvents ?? this.pastEvents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedEventType: selectedEventType ?? this.selectedEventType,
    );
  }

  /// Get filtered events based on selected filters
  List<CommunityEvent> get filteredEvents {
    List<CommunityEvent> events = allEvents;

    // Filter by category
    if (selectedCategory != 'all') {
      events = events.where((event) => event.category == selectedCategory).toList();
    }

    // Filter by event type
    if (selectedEventType != 'all') {
      events = events.where((event) => event.eventType == selectedEventType).toList();
    }

    return events;
  }

  /// Get events by status
  List<CommunityEvent> getEventsByStatus(String status) {
    switch (status) {
      case 'upcoming':
        return allEvents.where((event) => event.isUpcoming).toList();
      case 'ongoing':
        return allEvents.where((event) => event.isOngoing).toList();
      case 'past':
        return allEvents.where((event) => event.isPast).toList();
      default:
        return allEvents;
    }
  }
}

/// Community Events Notifier
class CommunityEventsNotifier extends StateNotifier<CommunityEventsState> {
  final ApiService _apiService;

  CommunityEventsNotifier(this._apiService) : super(const CommunityEventsState());

  /// Load all community events
  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getCommunityEvents();
      
      if (response.success && response.data != null) {
        final eventsData = response.data!['events'] as List<dynamic>? ?? [];
        final events = eventsData
            .map((json) => CommunityEvent.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort events by date
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

        // Categorize events
        final upcoming = events.where((event) => event.isUpcoming).toList();
        final past = events.where((event) => event.isPast).toList();

        state = state.copyWith(
          allEvents: events,
          upcomingEvents: upcoming,
          pastEvents: past,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load events',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load events: $e',
      );
    }
  }

  /// Load user's events
  Future<void> loadMyEvents() async {
    try {
      final response = await _apiService.getMyEvents();
      
      if (response.success && response.data != null) {
        final eventsData = response.data!['events'] as List<dynamic>? ?? [];
        final myEvents = eventsData
            .map((json) => CommunityEvent.fromJson(json as Map<String, dynamic>))
            .toList();

        state = state.copyWith(myEvents: myEvents);
      }
    } catch (e) {
      // Silently handle error for now
      print('Error loading my events: $e');
    }
  }

  /// Create a new event
  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _apiService.createCommunityEvent(eventData);
      
      if (response.success) {
        // Reload events to include the new one
        await loadEvents();
        return true;
      } else {
        state = state.copyWith(error: response.message ?? 'Failed to create event');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to create event: $e');
      return false;
    }
  }

  /// Join an event
  Future<bool> joinEvent(int eventId) async {
    try {
      // This would call the join event API
      // For now, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update the event in the list
      final updatedEvents = state.allEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(
            currentParticipants: event.currentParticipants + 1,
          );
        }
        return event;
      }).toList();

      state = state.copyWith(allEvents: updatedEvents);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to join event: $e');
      return false;
    }
  }

  /// Leave an event
  Future<bool> leaveEvent(int eventId) async {
    try {
      // This would call the leave event API
      // For now, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update the event in the list
      final updatedEvents = state.allEvents.map((event) {
        if (event.id == eventId) {
          return event.copyWith(
            currentParticipants: (event.currentParticipants - 1).clamp(0, double.infinity).toInt(),
          );
        }
        return event;
      }).toList();

      state = state.copyWith(allEvents: updatedEvents);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to leave event: $e');
      return false;
    }
  }

  /// Set category filter
  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Set event type filter
  void setEventType(String eventType) {
    state = state.copyWith(selectedEventType: eventType);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      selectedCategory: 'all',
      selectedEventType: 'all',
    );
  }

  /// Search events
  List<CommunityEvent> searchEvents(String query) {
    if (query.isEmpty) return state.filteredEvents;
    
    final lowercaseQuery = query.toLowerCase();
    return state.filteredEvents.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
             event.description.toLowerCase().contains(lowercaseQuery) ||
             event.category.toLowerCase().contains(lowercaseQuery) ||
             event.eventType.toLowerCase().contains(lowercaseQuery) ||
             event.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh events
  Future<void> refresh() async {
    await Future.wait([
      loadEvents(),
      loadMyEvents(),
    ]);
  }
}

/// Community Events Provider
final communityEventsProvider = StateNotifierProvider<CommunityEventsNotifier, CommunityEventsState>((ref) {
  return CommunityEventsNotifier(ApiService.instance);
});

/// Available Categories
final availableCategories = [
  'all',
  'family_planning',
  'maternal_health',
  'mental_health',
  'nutrition',
  'general_health',
  'support',
];

/// Available Event Types
final availableEventTypes = [
  'all',
  'workshop',
  'seminar',
  'support_group',
  'health_screening',
  'education',
  'community_meeting',
];
