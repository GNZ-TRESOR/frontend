/// TimeSlot model matching the database schema
class TimeSlot {
  final int? id;
  final int? healthFacilityId;
  final int? healthWorkerId;
  final DateTime startTime;
  final DateTime endTime;
  final bool? isAvailable;
  final String? reason;
  final int? maxAppointments;
  final int? currentAppointments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  // Additional fields for UI display (from joins)
  final String? healthWorkerName;
  final String? facilityName;

  TimeSlot({
    this.id,
    this.healthFacilityId,
    this.healthWorkerId,
    required this.startTime,
    required this.endTime,
    this.isAvailable,
    this.reason,
    this.maxAppointments,
    this.currentAppointments,
    this.createdAt,
    this.updatedAt,
    this.version,
    // UI display fields
    this.healthWorkerName,
    this.facilityName,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      healthFacilityId: json['healthFacilityId'] ?? json['health_facility_id'],
      healthWorkerId: json['healthWorkerId'] ?? json['health_worker_id'],
      startTime: DateTime.parse(json['startTime'] ?? json['start_time']),
      endTime: DateTime.parse(json['endTime'] ?? json['end_time']),
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      reason: json['reason'],
      maxAppointments: json['maxAppointments'] ?? json['max_appointments'] ?? 1,
      currentAppointments: json['currentAppointments'] ?? json['current_appointments'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : json['updated_at'] != null 
              ? DateTime.parse(json['updated_at'])
              : null,
      version: json['version'],
      // UI display fields
      healthWorkerName: json['healthWorkerName'] ?? json['health_worker_name'],
      facilityName: json['facilityName'] ?? json['facility_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'healthFacilityId': healthFacilityId,
      'healthWorkerId': healthWorkerId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'reason': reason,
      'maxAppointments': maxAppointments,
      'currentAppointments': currentAppointments,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version,
    };
  }

  TimeSlot copyWith({
    int? id,
    int? healthFacilityId,
    int? healthWorkerId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    String? reason,
    int? maxAppointments,
    int? currentAppointments,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? healthWorkerName,
    String? facilityName,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      healthFacilityId: healthFacilityId ?? this.healthFacilityId,
      healthWorkerId: healthWorkerId ?? this.healthWorkerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      reason: reason ?? this.reason,
      maxAppointments: maxAppointments ?? this.maxAppointments,
      currentAppointments: currentAppointments ?? this.currentAppointments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      healthWorkerName: healthWorkerName ?? this.healthWorkerName,
      facilityName: facilityName ?? this.facilityName,
    );
  }

  /// Get formatted start time
  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted end time
  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted time range
  String get formattedTimeRange {
    return '$formattedStartTime - $formattedEndTime';
  }

  /// Get formatted date
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${startTime.day} ${months[startTime.month - 1]} ${startTime.year}';
  }

  /// Check if slot is available for booking
  bool get canBook {
    if (isAvailable != true) return false;
    if (currentAppointments != null && maxAppointments != null) {
      return currentAppointments! < maxAppointments!;
    }
    return true;
  }

  /// Check if slot is in the past
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// Check if slot is today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }

  /// Get duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Get availability status
  String get availabilityStatus {
    if (!canBook) return 'Unavailable';
    if (isPast) return 'Past';
    if (currentAppointments != null && maxAppointments != null) {
      return '${maxAppointments! - currentAppointments!} slots available';
    }
    return 'Available';
  }

  @override
  String toString() {
    return 'TimeSlot{id: $id, time: $formattedTimeRange, available: $canBook}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
           other.id == id &&
           other.startTime == startTime &&
           other.endTime == endTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^ startTime.hashCode ^ endTime.hashCode;
  }
}
