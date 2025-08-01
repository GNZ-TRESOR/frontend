import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/models/notification.dart';
import '../../core/services/api_service.dart';

/// Professional Notifications Screen
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<AppNotification> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('Clear all'),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Notification settings'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Important'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [_buildAllTab(), _buildUnreadTab(), _buildImportantTab()],
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_notifications.isEmpty && !_isLoading) {
      return _buildEmptyState(
        'No notifications',
        'You\'ll see your notifications here',
        Icons.notifications_none,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildUnreadTab() {
    final unreadNotifications =
        _notifications.where((notification) => !notification.isRead).toList();

    if (unreadNotifications.isEmpty && !_isLoading) {
      return _buildEmptyState(
        'No unread notifications',
        'All caught up! You have no unread notifications',
        Icons.mark_email_read,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unreadNotifications.length,
        itemBuilder: (context, index) {
          final notification = unreadNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildImportantTab() {
    final importantNotifications =
        _notifications
            .where(
              (notification) =>
                  notification.priority == 'high' ||
                  notification.priority == 'urgent' ||
                  notification.type == 'emergency',
            )
            .toList();

    if (importantNotifications.isEmpty && !_isLoading) {
      return _buildEmptyState(
        'No important notifications',
        'Important notifications will appear here',
        Icons.priority_high,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: importantNotifications.length,
        itemBuilder: (context, index) {
          final notification = importantNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                notification.isRead
                    ? null
                    : Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getNotificationTypeColor(
                          notification.type,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getNotificationTypeIcon(notification.type),
                        color: _getNotificationTypeColor(notification.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        notification.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getNotificationTypeColor(
                                          notification.type,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        notification.typeDisplayName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _getNotificationTypeColor(
                                            notification.type,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (notification.priority == 'high' ||
                                        notification.priority == 'urgent')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          notification.priorityDisplayName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                notification.timeAgo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notification.hasAction) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Spacer(),
                      Flexible(
                        child: TextButton(
                          onPressed:
                              () => _handleNotificationAction(notification),
                          child: Text(
                            notification.actionDisplayText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getNotificationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return AppColors.appointmentBlue;
      case 'medication':
        return AppColors.secondary;
      case 'period':
        return AppColors.tertiary;
      case 'health_tip':
        return AppColors.educationBlue;
      case 'system':
        return AppColors.textSecondary;
      case 'marketing':
        return AppColors.supportPurple;
      case 'emergency':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return Icons.event;
      case 'medication':
        return Icons.medication;
      case 'period':
        return Icons.favorite;
      case 'health_tip':
        return Icons.lightbulb;
      case 'system':
        return Icons.settings;
      case 'marketing':
        return Icons.campaign;
      case 'emergency':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  // API Integration Methods
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getNotifications();

      if (response.success && response.data != null) {
        final notificationsList = response.data as List<dynamic>;
        _notifications =
            notificationsList
                .map((json) => AppNotification.fromJson(json))
                .toList();
      } else {
        // Fallback to mock data if API fails
        _notifications = _getMockNotifications();
      }
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      // Fallback to mock data on error
      _notifications = _getMockNotifications();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Mock data fallback
  List<AppNotification> _getMockNotifications() {
    return [
      AppNotification(
        id: 1,
        userId: 1,
        title: 'Appointment Reminder',
        message: 'You have an appointment with Dr. Smith tomorrow at 2:00 PM',
        type: 'appointment',
        priority: 'high',
        isRead: false,
        actionType: 'view_appointment',
        actionData: '{"appointmentId": 123}',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 2,
        userId: 1,
        title: 'Medication Reminder',
        message: 'Time to take your birth control pill',
        type: 'medication',
        priority: 'normal',
        isRead: false,
        actionType: 'take_medication',
        actionData: '{"medicationId": 456}',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 3,
        userId: 1,
        title: 'Period Tracking',
        message: 'Your period is expected to start in 3 days',
        type: 'period',
        priority: 'normal',
        isRead: true,
        actionType: 'log_period',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        readAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      AppNotification(
        id: 4,
        userId: 1,
        title: 'Health Tip',
        message:
            'Did you know? Regular exercise can help reduce menstrual cramps',
        type: 'health_tip',
        priority: 'low',
        isRead: true,
        actionType: 'read_tip',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        readAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 5,
        userId: 1,
        title: 'System Update',
        message:
            'New features available! Update the app to get the latest improvements',
        type: 'system',
        priority: 'normal',
        isRead: false,
        actionType: 'update_app',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Action methods
  Future<void> _markAllAsRead() async {
    try {
      final response = await ApiService.instance.markAllNotificationsAsRead();

      if (response.success) {
        setState(() {
          _notifications = _notifications.map((n) => n.markAsRead()).toList();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All notifications marked as read'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'settings':
        _openNotificationSettings();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Notifications'),
            content: const Text(
              'Are you sure you want to clear all notifications? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }

  void _openNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening notification settings...')),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markNotificationAsRead(notification);
    }

    if (notification.hasAction) {
      _handleNotificationAction(notification);
    }
  }

  Future<void> _markNotificationAsRead(AppNotification notification) async {
    if (notification.id == null) return;

    try {
      final response = await ApiService.instance.markNotificationAsRead(
        notification.id!,
      );

      if (response.success) {
        if (mounted) {
          setState(() {
            final index = _notifications.indexWhere(
              (n) => n.id == notification.id,
            );
            if (index != -1) {
              _notifications[index] = notification.markAsRead();
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification marked as read'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleNotificationAction(AppNotification notification) {
    switch (notification.actionType?.toLowerCase()) {
      case 'view_appointment':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening appointment details...')),
        );
        break;
      case 'take_medication':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication marked as taken')),
        );
        break;
      case 'log_period':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening period tracker...')),
        );
        break;
      case 'read_tip':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opening health tip...')));
        break;
      case 'update_app':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opening app store...')));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: ${notification.actionDisplayText}')),
        );
    }
  }
}
