/// Notification model for the family planning platform
class AppNotification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final bool isRead;
  final String? actionType;
  final String? actionData;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;

  AppNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = 'normal',
    this.isRead = false,
    this.actionType,
    this.actionData,
    this.imageUrl,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      priority: json['priority'] ?? 'normal',
      isRead: json['isRead'] ?? false,
      actionType: json['actionType'],
      actionData: json['actionData'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'isRead': isRead,
      'actionType': actionType,
      'actionData': actionData,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    String? priority,
    bool? isRead,
    String? actionType,
    String? actionData,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Get notification type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'appointment':
        return 'Appointment';
      case 'medication':
        return 'Medication';
      case 'period':
        return 'Period Reminder';
      case 'health_tip':
        return 'Health Tip';
      case 'system':
        return 'System';
      case 'marketing':
        return 'Promotion';
      case 'emergency':
        return 'Emergency';
      default:
        return 'General';
    }
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  /// Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
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
    final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[createdAt.month - 1]} ${createdAt.day}';
    }
  }

  /// Get formatted time
  String get formattedTime {
    final hour = createdAt.hour == 0 ? 12 : (createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour);
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Check if notification has action
  bool get hasAction => actionType != null && actionType!.isNotEmpty;

  /// Get action display text
  String get actionDisplayText {
    switch (actionType?.toLowerCase()) {
      case 'view_appointment':
        return 'View Appointment';
      case 'take_medication':
        return 'Mark as Taken';
      case 'log_period':
        return 'Log Period';
      case 'read_tip':
        return 'Read More';
      case 'update_app':
        return 'Update Now';
      case 'book_appointment':
        return 'Book Now';
      default:
        return 'View';
    }
  }

  /// Mark notification as read
  AppNotification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AppNotification{id: $id, title: $title, type: $type, isRead: $isRead}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
