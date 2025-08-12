import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

/// Notification state
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Notification provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationNotifier(this._notificationService)
    : super(const NotificationState());

  /// Load notifications
  Future<void> loadNotifications({
    bool refresh = false,
    bool? unreadOnly,
    String? type,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 0,
        hasMore: true,
      );
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final page = refresh ? 0 : state.currentPage;
      final notifications = await _notificationService.getNotifications(
        page: page,
        size: 20,
        unreadOnly: unreadOnly,
        type: type,
      );

      if (refresh) {
        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          currentPage: 1,
          hasMore: notifications.length >= 20,
        );
      } else {
        state = state.copyWith(
          notifications: [...state.notifications, ...notifications],
          isLoading: false,
          currentPage: state.currentPage + 1,
          hasMore: notifications.length >= 20,
        );
      }

      // Also update unread count
      await loadUnreadCount();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load unread notifications count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadNotificationsCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // Don't update error state for unread count failures
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        final updatedNotifications =
            state.notifications.map((notification) {
              if (notification.id == notificationId && !notification.isRead) {
                return notification.markAsRead();
              }
              return notification;
            }).toList();

        final newUnreadCount =
            state.unreadCount > 0 ? state.unreadCount - 1 : 0;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        final updatedNotifications =
            state.notifications.map((notification) {
              if (!notification.isRead) {
                return notification.markAsRead();
              }
              return notification;
            }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(
        notificationId,
      );
      if (success) {
        final notification = state.notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => throw Exception('Notification not found'),
        );

        final updatedNotifications =
            state.notifications.where((n) => n.id != notificationId).toList();

        final newUnreadCount =
            !notification.isRead && state.unreadCount > 0
                ? state.unreadCount - 1
                : state.unreadCount;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Create notification for user (Health Worker and Admin only)
  Future<bool> createNotificationForUser({
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
      await _notificationService.createNotificationForUser(
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
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
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
      final success = await _notificationService.sendNotificationToUsers(
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
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const NotificationState();
  }
}

/// Providers
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ApiService.instance);
});

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final notificationService = ref.watch(notificationServiceProvider);
      return NotificationNotifier(notificationService);
    });

/// Unread notifications count provider
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

/// Filtered notifications providers
final unreadNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.where((notification) => !notification.isRead).toList();
});

final readNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.where((notification) => notification.isRead).toList();
});
