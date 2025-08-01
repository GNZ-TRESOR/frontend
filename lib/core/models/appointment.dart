/// Appointment model matching the database schema
class Appointment {
  final int? id;
  final int userId;
  final int healthFacilityId;
  final int? healthWorkerId;
  final String appointmentType;
  final String status;
  final DateTime scheduledDate;
  final int? durationMinutes;
  final String? reason;
  final String? notes;
  final bool? reminderSent;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  // Additional fields for UI display (from joins)
  final String? userName;
  final String? healthWorkerName;
  final String? facilityName;
  final String? facilityAddress;

  Appointment({
    this.id,
    required this.userId,
    required this.healthFacilityId,
    this.healthWorkerId,
    required this.appointmentType,
    this.status = 'SCHEDULED',
    required this.scheduledDate,
    this.durationMinutes,
    this.reason,
    this.notes,
    this.reminderSent,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.version,
    // UI display fields
    this.userName,
    this.healthWorkerName,
    this.facilityName,
    this.facilityAddress,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId:
          json['userId'] ??
          json['user_id'] ??
          (json['user'] != null ? json['user']['id'] : null) ??
          0,
      healthFacilityId:
          json['healthFacilityId'] ??
          json['health_facility_id'] ??
          (json['healthFacility'] != null
              ? json['healthFacility']['id']
              : null) ??
          0,
      healthWorkerId:
          json['healthWorkerId'] ??
          json['health_worker_id'] ??
          (json['healthWorker'] != null ? json['healthWorker']['id'] : null),
      appointmentType:
          json['appointmentType'] ?? json['appointment_type'] ?? 'CONSULTATION',
      status: json['status'] ?? 'SCHEDULED',
      scheduledDate: DateTime.parse(
        json['scheduledDate'] ??
            json['scheduled_date'] ??
            DateTime.now().toIso8601String(),
      ),
      durationMinutes: json['durationMinutes'] ?? json['duration_minutes'],
      reason: json['reason'],
      notes: json['notes'],
      reminderSent: json['reminderSent'] ?? json['reminder_sent'],
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'])
              : json['cancelled_at'] != null
              ? DateTime.parse(json['cancelled_at'])
              : null,
      cancellationReason:
          json['cancellationReason'] ?? json['cancellation_reason'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      version: json['version'],
      // UI display fields
      userName:
          json['userName'] ??
          json['user_name'] ??
          (json['user'] != null ? json['user']['name'] : null),
      healthWorkerName:
          json['healthWorkerName'] ??
          json['health_worker_name'] ??
          (json['healthWorker'] != null ? json['healthWorker']['name'] : null),
      facilityName:
          json['facilityName'] ??
          json['facility_name'] ??
          (json['healthFacility'] != null
              ? json['healthFacility']['name']
              : null),
      facilityAddress:
          json['facilityAddress'] ??
          json['facility_address'] ??
          (json['healthFacility'] != null
              ? json['healthFacility']['address']
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'healthFacilityId': healthFacilityId,
      'healthWorkerId': healthWorkerId,
      'appointmentType': appointmentType,
      'status': status,
      'scheduledDate': scheduledDate.toIso8601String(),
      'durationMinutes': durationMinutes,
      'reason': reason,
      'notes': notes,
      'reminderSent': reminderSent,
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version,
    };
  }

  Appointment copyWith({
    int? id,
    int? userId,
    int? healthFacilityId,
    int? healthWorkerId,
    String? appointmentType,
    String? status,
    DateTime? scheduledDate,
    int? durationMinutes,
    String? reason,
    String? notes,
    bool? reminderSent,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? userName,
    String? healthWorkerName,
    String? facilityName,
    String? facilityAddress,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      healthFacilityId: healthFacilityId ?? this.healthFacilityId,
      healthWorkerId: healthWorkerId ?? this.healthWorkerId,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      reminderSent: reminderSent ?? this.reminderSent,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      userName: userName ?? this.userName,
      healthWorkerName: healthWorkerName ?? this.healthWorkerName,
      facilityName: facilityName ?? this.facilityName,
      facilityAddress: facilityAddress ?? this.facilityAddress,
    );
  }

  /// Get formatted appointment date
  String get formattedDate {
    return '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  }

  /// Get formatted appointment time
  String get formattedTime {
    final hour = scheduledDate.hour;
    final minute = scheduledDate.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get appointment type display name
  String get typeDisplayName {
    switch (appointmentType.toLowerCase()) {
      case 'consultation':
        return 'Consultation';
      case 'family_planning':
        return 'Family Planning';
      case 'prenatal_care':
        return 'Prenatal Care';
      case 'postnatal_care':
        return 'Postnatal Care';
      case 'vaccination':
        return 'Vaccination';
      case 'health_screening':
        return 'Health Screening';
      case 'follow_up':
        return 'Follow-up';
      case 'emergency':
        return 'Emergency';
      case 'counseling':
        return 'Counseling';
      case 'other':
        return 'Other';
      default:
        return appointmentType;
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      case 'rescheduled':
        return 'Rescheduled';
      default:
        return status;
    }
  }

  /// Get status color based on status
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return '#2196F3'; // Blue
      case 'confirmed':
        return '#4CAF50'; // Green
      case 'in_progress':
        return '#FF9800'; // Orange
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      case 'no_show':
        return '#9E9E9E'; // Grey
      case 'rescheduled':
        return '#FF9800'; // Orange
      default:
        return '#2196F3'; // Blue
    }
  }

  /// Check if appointment is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return scheduledDate.isAfter(now) &&
        (status.toUpperCase() == 'SCHEDULED' ||
            status.toUpperCase() == 'CONFIRMED');
  }

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  /// Check if appointment is overdue
  bool get isOverdue {
    final now = DateTime.now();
    return scheduledDate.isBefore(now) &&
        (status.toUpperCase() == 'SCHEDULED' ||
            status.toUpperCase() == 'CONFIRMED');
  }

  /// Get time until appointment
  Duration? get timeUntilAppointment {
    if (!isUpcoming) return null;
    final now = DateTime.now();
    return scheduledDate.difference(now);
  }

  /// Get days until appointment
  int? get daysUntilAppointment {
    final duration = timeUntilAppointment;
    if (duration == null) return null;
    return duration.inDays;
  }

  /// Get hours until appointment
  int? get hoursUntilAppointment {
    final duration = timeUntilAppointment;
    if (duration == null) return null;
    return duration.inHours;
  }

  /// Check if reminder should be shown
  bool get shouldShowReminder {
    if (reminderSent == true) return false;
    final now = DateTime.now();
    // Show reminder 1 hour before appointment
    final reminderTime = scheduledDate.subtract(const Duration(hours: 1));
    return now.isAfter(reminderTime) && isUpcoming;
  }

  /// Get appointment location
  String get location {
    if (facilityName != null) {
      if (facilityAddress != null) {
        return '$facilityName, $facilityAddress';
      }
      return facilityName!;
    }
    return 'Location not specified';
  }

  /// Check if appointment can be cancelled
  bool get canBeCancelled {
    return status.toUpperCase() == 'SCHEDULED' ||
        status.toUpperCase() == 'CONFIRMED';
  }

  /// Check if appointment can be rescheduled
  bool get canBeRescheduled {
    return status.toUpperCase() == 'SCHEDULED' ||
        status.toUpperCase() == 'CONFIRMED';
  }

  /// Get display title for appointment
  String get displayTitle {
    return typeDisplayName;
  }

  /// Get health worker display name
  String get doctorName {
    return healthWorkerName ?? 'Not assigned';
  }

  /// Get appointment date (for backward compatibility)
  DateTime get appointmentDate {
    return scheduledDate;
  }

  @override
  String toString() {
    return 'Appointment{id: $id, type: $appointmentType, date: $formattedDate, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment &&
        other.id == id &&
        other.appointmentType == appointmentType &&
        other.scheduledDate == scheduledDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ appointmentType.hashCode ^ scheduledDate.hashCode;
  }
}
