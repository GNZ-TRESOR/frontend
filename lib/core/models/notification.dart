/// Notification model based on the database schema
class AppNotification {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? actionUrl;
  final String? icon;
  final bool isRead;
  final String message;
  final String? metadata;
  final int priority;
  final DateTime? readAt;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final String title;
  final String notificationType;
  final int userId;

  AppNotification({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.version,
    this.actionUrl,
    this.icon,
    required this.isRead,
    required this.message,
    this.metadata,
    required this.priority,
    this.readAt,
    this.scheduledFor,
    this.sentAt,
    required this.title,
    required this.notificationType,
    required this.userId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? _parseDateTime(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
      version: json['version'],
      actionUrl: json['actionUrl'],
      icon: json['icon'],
      isRead: json['isRead'] ?? false,
      message: json['message'] ?? '',
      metadata: json['metadata'],
      priority: json['priority'] ?? 2,
      readAt: json['readAt'] != null ? _parseDateTime(json['readAt']) : null,
      scheduledFor:
          json['scheduledFor'] != null
              ? _parseDateTime(json['scheduledFor'])
              : null,
      sentAt: json['sentAt'] != null ? _parseDateTime(json['sentAt']) : null,
      title: json['title'] ?? '',
      notificationType: json['notificationType'] ?? json['type'] ?? 'GENERAL',
      userId:
          json['userId'] ??
          (json['user'] != null ? json['user']['id'] : null) ??
          0,
    );
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is String) {
      return DateTime.parse(dateTime);
    } else if (dateTime is List) {
      // Handle Java LocalDateTime array format [year, month, day, hour, minute, second, nano]
      return DateTime(
        dateTime[0], // year
        dateTime[1], // month
        dateTime[2], // day
        dateTime.length > 3 ? dateTime[3] : 0, // hour
        dateTime.length > 4 ? dateTime[4] : 0, // minute
        dateTime.length > 5 ? dateTime[5] : 0, // second
        dateTime.length > 6
            ? (dateTime[6] / 1000000).round()
            : 0, // millisecond
      );
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version,
      'actionUrl': actionUrl,
      'icon': icon,
      'isRead': isRead,
      'message': message,
      'metadata': metadata,
      'priority': priority,
      'readAt': readAt?.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'title': title,
      'notificationType': notificationType,
      'userId': userId,
    };
  }

  AppNotification copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? actionUrl,
    String? icon,
    bool? isRead,
    String? message,
    String? metadata,
    int? priority,
    DateTime? readAt,
    DateTime? scheduledFor,
    DateTime? sentAt,
    String? title,
    String? notificationType,
    int? userId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      actionUrl: actionUrl ?? this.actionUrl,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      readAt: readAt ?? this.readAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      title: title ?? this.title,
      notificationType: notificationType ?? this.notificationType,
      userId: userId ?? this.userId,
    );
  }

  AppNotification markAsRead() {
    return copyWith(isRead: true, readAt: DateTime.now());
  }

  String get priorityText {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Normal';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Normal';
    }
  }

  String get typeDisplayName {
    switch (notificationType) {
      case 'SUCCESS':
        return 'Success';
      case 'ERROR':
        return 'Error';
      case 'WARNING':
        return 'Warning';
      case 'INFO':
        return 'Information';
      case 'APPOINTMENT_REMINDER':
        return 'Appointment Reminder';
      case 'MEDICATION_REMINDER':
        return 'Medication Reminder';
      case 'HEALTH_TIP':
        return 'Health Tip';
      case 'EMERGENCY_ALERT':
        return 'Emergency Alert';
      case 'SYSTEM_NOTIFICATION':
        return 'System Notification';
      case 'MESSAGE_RECEIVED':
        return 'Message Received';
      case 'EDUCATION_REMINDER':
        return 'Education Reminder';
      case 'CONTRACEPTION_REMINDER':
        return 'Contraception Reminder';
      case 'MENSTRUAL_REMINDER':
        return 'Menstrual Reminder';
      case 'GENERAL':
      default:
        return 'General';
    }
  }

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Get time since created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
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
      return '${months[createdAt.month - 1]} ${createdAt.day}';
    }
  }

  /// Get formatted time
  String get formattedTime {
    final hour =
        createdAt.hour == 0
            ? 12
            : (createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour);
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Check if notification has action
  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;

  @override
  String toString() {
    return 'AppNotification{id: $id, title: $title, type: $notificationType, isRead: $isRead}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Notification types enum
enum NotificationType {
  success('SUCCESS'),
  error('ERROR'),
  warning('WARNING'),
  info('INFO'),
  appointmentReminder('APPOINTMENT_REMINDER'),
  medicationReminder('MEDICATION_REMINDER'),
  healthTip('HEALTH_TIP'),
  emergencyAlert('EMERGENCY_ALERT'),
  systemNotification('SYSTEM_NOTIFICATION'),
  messageReceived('MESSAGE_RECEIVED'),
  educationReminder('EDUCATION_REMINDER'),
  contraceptionReminder('CONTRACEPTION_REMINDER'),
  menstrualReminder('MENSTRUAL_REMINDER'),
  general('GENERAL');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

/// Notification priority enum
enum NotificationPriority {
  low(1, 'Low'),
  normal(2, 'Normal'),
  high(3, 'High'),
  critical(4, 'Critical');

  const NotificationPriority(this.value, this.label);
  final int value;
  final String label;

  static NotificationPriority fromValue(int value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}
