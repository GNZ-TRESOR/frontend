import '../models/notification.dart';
import 'api_service.dart';

/// Comprehensive Notification Service with Role-Based Operations
class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  // ==================== NOTIFICATION CRUD OPERATIONS ====================

  /// Get notifications for current user
  Future<List<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
    bool? unreadOnly,
    String? type,
  }) async {
    try {
      final response = await _apiService.getNotifications(
        page: page,
        size: size,
        unreadOnly: unreadOnly,
        type: type,
      );

      if (response.success && response.data != null) {
        List<dynamic> notificationsJson;
        if (response.data is Map<String, dynamic>) {
          notificationsJson =
              response.data['notifications'] ??
              response.data['data'] ??
              response.data['content'] ??
              [];
        } else if (response.data is List) {
          notificationsJson = response.data;
        } else {
          notificationsJson = [];
        }

        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _apiService.getUnreadNotificationsCount();

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data['count'] ?? 0;
        } else if (response.data is int) {
          return response.data;
        }
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to get unread notifications count: $e');
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);
      return response.success;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();
      return response.success;
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.deleteNotification(notificationId);
      return response.success;
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // ==================== NOTIFICATION MANAGEMENT (Health Worker & Admin) ====================

  /// Create notification for a specific user (Health Worker and Admin only)
  Future<AppNotification> createNotificationForUser({
    required int userId,
    required String title,
    required String message,
    String type = 'GENERAL',
    int priority = 2,
    String? actionUrl,
    String? icon,
    DateTime? scheduledFor,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.createNotificationForUser(
        userId: userId,
        title: title,
        message: message,
        type: type,
        priority: priority,
        actionUrl: actionUrl,
        icon: icon,
        scheduledFor: scheduledFor,
        metadata: metadata,
      );

      if (response.success && response.data != null) {
        Map<String, dynamic> notificationJson;
        if (response.data is Map<String, dynamic>) {
          notificationJson = response.data['notification'] ?? response.data;
        } else {
          notificationJson = response.data;
        }

        return AppNotification.fromJson(notificationJson);
      } else {
        throw Exception(response.message ?? 'Failed to create notification');
      }
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Send notification to multiple users (Health Worker and Admin only)
  Future<bool> sendNotificationToUsers({
    required List<int> userIds,
    required String title,
    required String message,
    String type = 'GENERAL',
    int priority = 2,
    String? actionUrl,
    String? icon,
    DateTime? scheduledFor,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.sendNotificationToUsers(
        userIds: userIds,
        title: title,
        message: message,
        type: type,
        priority: priority,
        actionUrl: actionUrl,
        icon: icon,
        scheduledFor: scheduledFor,
        metadata: metadata,
      );

      return response.success;
    } catch (e) {
      throw Exception('Failed to send notifications: $e');
    }
  }

  /// Get notifications by type
  Future<List<AppNotification>> getNotificationsByType(String type) async {
    try {
      final response = await _apiService.getNotificationsByType(type);

      if (response.success && response.data != null) {
        List<dynamic> notificationsJson;
        if (response.data is Map<String, dynamic>) {
          notificationsJson =
              response.data['notifications'] ??
              response.data['data'] ??
              response.data['content'] ??
              [];
        } else if (response.data is List) {
          notificationsJson = response.data;
        } else {
          notificationsJson = [];
        }

        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load notifications by type: $e');
    }
  }

  /// Get sent notifications (Health Worker and Admin only)
  Future<List<AppNotification>> getSentNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiService.getSentNotifications(
        page: page,
        size: size,
      );

      if (response.success && response.data != null) {
        List<dynamic> notificationsJson;
        if (response.data is Map<String, dynamic>) {
          notificationsJson =
              response.data['notifications'] ??
              response.data['data'] ??
              response.data['content'] ??
              [];
        } else if (response.data is List) {
          notificationsJson = response.data;
        } else {
          notificationsJson = [];
        }

        return notificationsJson
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load sent notifications: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Send appointment reminder notification
  Future<bool> sendAppointmentReminder({
    required int userId,
    required String appointmentDetails,
    required DateTime appointmentDate,
  }) async {
    return await sendNotificationToUsers(
      userIds: [userId],
      title: 'Appointment Reminder',
      message: 'You have an upcoming appointment: $appointmentDetails',
      type: 'APPOINTMENT_REMINDER',
      priority: 3,
      scheduledFor: appointmentDate.subtract(const Duration(hours: 24)),
      metadata: {
        'appointmentDate': appointmentDate.toIso8601String(),
        'details': appointmentDetails,
      },
    );
  }

  /// Send medication reminder notification
  Future<bool> sendMedicationReminder({
    required int userId,
    required String medicationName,
    required DateTime reminderTime,
  }) async {
    return await sendNotificationToUsers(
      userIds: [userId],
      title: 'Medication Reminder',
      message: 'Time to take your medication: $medicationName',
      type: 'MEDICATION_REMINDER',
      priority: 3,
      scheduledFor: reminderTime,
      metadata: {
        'medicationName': medicationName,
        'reminderTime': reminderTime.toIso8601String(),
      },
    );
  }

  /// Send health tip notification
  Future<bool> sendHealthTip({
    required List<int> userIds,
    required String tip,
    String? actionUrl,
  }) async {
    return await sendNotificationToUsers(
      userIds: userIds,
      title: 'Health Tip',
      message: tip,
      type: 'HEALTH_TIP',
      priority: 1,
      actionUrl: actionUrl,
    );
  }

  /// Send emergency alert
  Future<bool> sendEmergencyAlert({
    required List<int> userIds,
    required String alertMessage,
    String? actionUrl,
  }) async {
    return await sendNotificationToUsers(
      userIds: userIds,
      title: 'Emergency Alert',
      message: alertMessage,
      type: 'EMERGENCY_ALERT',
      priority: 4,
      actionUrl: actionUrl,
    );
  }
}
