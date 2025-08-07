/// Community Event model for the family planning platform
class CommunityEvent {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final String organizer;
  final String? organizerContact;
  final int maxParticipants;
  final int currentParticipants;
  final String status;
  final bool isOnline;
  final String? meetingLink;
  final List<String> tags;
  final String? imageUrl;
  final double? fee;
  final String? requirements;
  final DateTime? registrationDeadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommunityEvent({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.organizer,
    this.organizerContact,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.status,
    required this.isOnline,
    this.meetingLink,
    required this.tags,
    this.imageUrl,
    this.fee,
    this.requirements,
    this.registrationDeadline,
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    return CommunityEvent(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category:
          json['type'] ?? json['category'] ?? '', // Backend uses 'type' field
      location: json['location'] ?? '',
      startDate: DateTime.parse(
        json['eventDate'] ?? json['startDate'],
      ), // Backend uses 'eventDate'
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      organizer:
          json['organizer']?['name'] ??
          json['organizer'] ??
          '', // Handle User object or string
      organizerContact: json['contactInfo'] ?? json['organizerContact'],
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      status:
          json['isActive'] == true
              ? 'ACTIVE'
              : 'INACTIVE', // Backend uses boolean isActive
      isOnline:
          json['isVirtual'] ??
          json['isOnline'] ??
          false, // Backend uses 'isVirtual'
      meetingLink: json['virtualLink'] ?? json['meetingLink'],
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      fee: json['fee']?.toDouble(),
      requirements: json['requirements'],
      registrationDeadline:
          json['registrationDeadline'] != null
              ? DateTime.parse(json['registrationDeadline'])
              : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': category, // Backend expects 'type' field
      'location': location,
      'eventDate': startDate.toIso8601String(), // Backend expects 'eventDate'
      'endDate': endDate?.toIso8601String(),
      'organizerId': organizer, // Backend expects organizer ID
      'contactInfo': organizerContact,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'isActive': status == 'ACTIVE', // Backend expects boolean
      'isVirtual': isOnline, // Backend expects 'isVirtual'
      'virtualLink': meetingLink,
      'tags': tags,
      'imageUrl': imageUrl,
      'fee': fee,
      'requirements': requirements,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Check if event is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return startDate.isAfter(now);
  }

  /// Check if event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    if (endDate == null) return false;
    return startDate.isBefore(now) && endDate!.isAfter(now);
  }

  /// Check if event is past
  bool get isPast {
    final now = DateTime.now();
    final eventEnd = endDate ?? startDate;
    return eventEnd.isBefore(now);
  }

  /// Check if registration is open
  bool get isRegistrationOpen {
    if (status.toUpperCase() != 'ACTIVE') return false;
    if (currentParticipants >= maxParticipants) return false;
    if (registrationDeadline != null &&
        DateTime.now().isAfter(registrationDeadline!)) {
      return false;
    }
    return isUpcoming;
  }

  /// Check if event is full
  bool get isFull => currentParticipants >= maxParticipants;

  /// Get available spots
  int get availableSpots => maxParticipants - currentParticipants;

  /// Get category display name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'workshop':
        return 'Workshop';
      case 'seminar':
        return 'Seminar';
      case 'support_group':
        return 'Support Group';
      case 'health_screening':
        return 'Health Screening';
      case 'education':
        return 'Education';
      case 'community_outreach':
        return 'Community Outreach';
      default:
        return category;
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'CANCELLED':
        return 'Cancelled';
      case 'POSTPONED':
        return 'Postponed';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Get formatted date range
  String get dateRange {
    final startFormatted = _formatDate(startDate);
    if (endDate == null) return startFormatted;

    final endFormatted = _formatDate(endDate!);
    if (_isSameDay(startDate, endDate!)) {
      return '$startFormatted - ${_formatTime(endDate!)}';
    }
    return '$startFormatted - $endFormatted';
  }

  /// Get time until event
  String get timeUntilEvent {
    if (isPast) return 'Event ended';
    if (isOngoing) return 'Happening now';

    final now = DateTime.now();
    final difference = startDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Starting soon';
    }
  }

  /// Get fee display
  String get feeDisplay {
    if (fee == null || fee == 0) return 'Free';
    return 'RWF ${fee!.toStringAsFixed(0)}';
  }

  /// Get tags display string
  String get tagsString => tags.join(', ');

  /// Check if event has specific tag
  bool hasTag(String tag) {
    return tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()));
  }

  /// Get registration status message
  String get registrationStatusMessage {
    if (!isRegistrationOpen) {
      if (isFull) return 'Event is full';
      if (isPast) return 'Event has ended';
      if (registrationDeadline != null &&
          DateTime.now().isAfter(registrationDeadline!)) {
        return 'Registration closed';
      }
      return 'Registration not available';
    }
    return 'Registration open';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  String toString() {
    return 'CommunityEvent{id: $id, title: $title, startDate: $startDate, location: $location}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
