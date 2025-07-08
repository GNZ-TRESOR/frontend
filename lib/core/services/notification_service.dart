import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_record_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _messaging = FirebaseMessaging.instance;
      
      // Request permission for notifications
      await _requestPermissions();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    if (_messaging == null) return;

    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  // Set up Firebase message handlers
  void _setupMessageHandlers() {
    if (_messaging == null) return;

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    // In a real app, you might show a local notification here
  }

  // Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    _navigateBasedOnNotification(message.data);
  }

  // Navigate based on notification data
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'medication_reminder':
        // Navigate to medication screen
        break;
      case 'appointment_reminder':
        // Navigate to appointments screen
        break;
      case 'cycle_tracking':
        // Navigate to cycle tracking screen
        break;
      default:
        // Navigate to home screen
        break;
    }
  }

  // Simplified notification methods (stubs for now)
  Future<void> scheduleMedicationReminder({
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    debugPrint('Medication reminder scheduled for $medicationName at $scheduledTime');
    // In a real implementation, this would schedule a local notification
  }

  Future<void> scheduleAppointmentReminder({
    required DateTime appointmentTime,
    required String healthWorkerName,
    required String facilityName,
  }) async {
    debugPrint('Appointment reminder scheduled for $appointmentTime');
    // In a real implementation, this would schedule a local notification
  }

  Future<void> scheduleCycleReminder({
    required String title,
    required String body,
    required DateTime reminderDate,
  }) async {
    debugPrint('Cycle reminder scheduled: $title');
    // In a real implementation, this would schedule a local notification
  }

  Future<void> showEmergencyAlert({
    required String title,
    required String body,
  }) async {
    debugPrint('Emergency alert: $title - $body');
    // In a real implementation, this would show an immediate notification
  }

  // Get FCM token for push notifications
  Future<String?> getToken() async {
    if (_messaging == null) return null;
    
    try {
      return await _messaging!.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    
    try {
      await _messaging!.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // Cancel all notifications (stub)
  Future<void> cancelAllNotifications() async {
    debugPrint('All notifications cancelled');
    // In a real implementation, this would cancel all local notifications
  }

  // Cancel specific notification (stub)
  Future<void> cancelNotification(int id) async {
    debugPrint('Notification $id cancelled');
    // In a real implementation, this would cancel a specific local notification
  }
}

// Background message handler (must be top-level function)
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
  // Handle background message processing
}
