import 'package:json_annotation/json_annotation.dart';

part 'community_event.g.dart';

/// Community Event Model
@JsonSerializable()
class CommunityEvent {
  final int? id;
  final String title;
  final String description;
  final String? location;
  final DateTime eventDate;
  final DateTime? endDate;
  final String eventType;
  final String category;
  final int? maxParticipants;
  final int currentParticipants;
  final bool isPublic;
  final bool isActive;
  final String? imageUrl;
  final String? organizerName;
  final int? organizerId;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommunityEvent({
    this.id,
    required this.title,
    required this.description,
    this.location,
    required this.eventDate,
    this.endDate,
    required this.eventType,
    required this.category,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.isPublic = true,
    this.isActive = true,
    this.imageUrl,
    this.organizerName,
    this.organizerId,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    // Custom date parsing function to handle both String and List formats
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.tryParse(value);
      } else if (value is List && value.length >= 3) {
        return DateTime(
          value[0] as int,
          value[1] as int,
          value[2] as int,
          value.length > 3 ? value[3] as int : 0,
          value.length > 4 ? value[4] as int : 0,
          value.length > 5 ? value[5] as int : 0,
          value.length > 6 ? (value[6] as int) ~/ 1000000 : 0,
        );
      }
      return null;
    }

    return CommunityEvent(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String?,
      eventDate: parseDate(json['eventDate']) ?? DateTime.now(),
      endDate: parseDate(json['endDate']),
      eventType: json['eventType'] as String? ?? 'workshop',
      category: json['category'] as String? ?? 'general',
      maxParticipants: json['maxParticipants'] as int?,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      organizerName: json['organizerName'] as String?,
      organizerId: json['organizerId'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$CommunityEventToJson(this);

  CommunityEvent copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    DateTime? endDate,
    String? eventType,
    String? category,
    int? maxParticipants,
    int? currentParticipants,
    bool? isPublic,
    bool? isActive,
    String? imageUrl,
    String? organizerName,
    int? organizerId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      endDate: endDate ?? this.endDate,
      eventType: eventType ?? this.eventType,
      category: category ?? this.category,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerName: organizerName ?? this.organizerName,
      organizerId: organizerId ?? this.organizerId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if event is upcoming
  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  /// Check if event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return eventDate.isBefore(now) && (endDate?.isAfter(now) ?? false);
  }

  /// Check if event is past
  bool get isPast {
    final now = DateTime.now();
    return (endDate ?? eventDate).isBefore(now);
  }

  /// Get event status
  String get status {
    if (isOngoing) return 'ongoing';
    if (isUpcoming) return 'upcoming';
    return 'past';
  }

  /// Check if event has available spots
  bool get hasAvailableSpots {
    if (maxParticipants == null) return true;
    return currentParticipants < maxParticipants!;
  }

  /// Get available spots count
  int? get availableSpots {
    if (maxParticipants == null) return null;
    return maxParticipants! - currentParticipants;
  }

  /// Get formatted date range
  String get formattedDateRange {
    if (endDate != null) {
      return '${_formatDate(eventDate)} - ${_formatDate(endDate!)}';
    }
    return _formatDate(eventDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get event type display name
  String get eventTypeDisplayName {
    switch (eventType.toLowerCase()) {
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
        return eventType;
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
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

  @override
  String toString() {
    return 'CommunityEvent(id: $id, title: $title, eventDate: $eventDate, eventType: $eventType, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Event Type Enum
enum EventType {
  workshop,
  seminar,
  supportGroup,
  healthScreening,
  education,
  communityMeeting,
}

/// Event Category Enum
enum EventCategory {
  familyPlanning,
  maternalHealth,
  mentalHealth,
  nutrition,
  generalHealth,
  support,
}

/// Event Status Enum
enum EventStatus {
  upcoming,
  ongoing,
  past,
  cancelled,
}
