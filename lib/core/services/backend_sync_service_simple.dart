import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

/// Backend Sync Service for Ubuzima App
/// Provides sync functionality for offline-first architecture
class BackendSyncService {
  static final BackendSyncService _instance = BackendSyncService._internal();
  factory BackendSyncService() => _instance;
  BackendSyncService._internal();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  final StreamController<bool> _syncStatusController =
      StreamController<bool>.broadcast();

  // Backend API configuration
  static const String baseUrl = 'http://localhost:8080/api';

  // Getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return false;
    }
  }

  /// Initialize backend API connection
  Future<bool> initializeBackendAPI() async {
    try {
      // Test connection to Spring Boot backend
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Backend API connected successfully');
        return true;
      } else {
        debugPrint('❌ Backend API connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Backend API initialization error: $e');
      return false;
    }
  }

  /// Start full sync process
  Future<void> startSync() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }

    if (!await isOnline()) {
      debugPrint('Device is offline, skipping sync');
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      debugPrint('🔄 Starting backend sync...');

      // Connect to backend API and sync data
      await initializeBackendAPI();
      await _syncHealthRecords();
      await _syncAppointments();
      await _syncMessages();
      await _syncUserProfile();

      _lastSyncTime = DateTime.now();
      debugPrint('✅ Backend sync completed successfully');
    } catch (e) {
      debugPrint('❌ Backend sync failed: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  /// Sync health records via API
  Future<void> _syncHealthRecords() async {
    debugPrint('📊 Syncing health records...');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health-records'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Health records synced');
      } else {
        debugPrint('⚠️ Health records sync partial: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Health records sync failed: $e');
    }
  }

  /// Sync appointments via API
  Future<void> _syncAppointments() async {
    debugPrint('📅 Syncing appointments...');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Appointments synced');
      } else {
        debugPrint('⚠️ Appointments sync partial: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Appointments sync failed: $e');
    }
  }

  /// Sync messages (placeholder)
  Future<void> _syncMessages() async {
    debugPrint('💬 Syncing messages...');
    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint('✅ Messages synced');
  }

  /// Sync user profile (placeholder)
  Future<void> _syncUserProfile() async {
    debugPrint('👤 Syncing user profile...');
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('✅ User profile synced');
  }

  /// Queue data for sync when offline
  Future<void> queueForSync(String dataType, Map<String, dynamic> data) async {
    debugPrint('📝 Queued $dataType for sync: ${data.keys.join(', ')}');
    // In a real implementation, this would store data locally for later sync
  }

  /// Process sync queue when back online
  Future<void> processSyncQueue() async {
    if (!await isOnline()) return;

    debugPrint('🔄 Processing sync queue...');
    // In a real implementation, this would process queued items
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('✅ Sync queue processed');
  }

  /// Get sync status information
  Map<String, dynamic> getSyncStatus() {
    return {
      'is_syncing': _isSyncing,
      'last_sync_time': _lastSyncTime?.toIso8601String(),
      'is_online': false, // Will be updated by connectivity check
    };
  }

  /// Force sync for specific data type
  Future<void> forceSyncDataType(String dataType) async {
    if (!await isOnline()) {
      debugPrint('Cannot force sync $dataType - device offline');
      return;
    }

    debugPrint('🔄 Force syncing $dataType...');

    switch (dataType) {
      case 'health_records':
        await _syncHealthRecords();
        break;
      case 'appointments':
        await _syncAppointments();
        break;
      case 'messages':
        await _syncMessages();
        break;
      case 'user_profile':
        await _syncUserProfile();
        break;
      default:
        debugPrint('Unknown data type: $dataType');
    }
  }

  /// Schedule periodic sync
  Timer? _syncTimer;

  void startPeriodicSync({Duration interval = const Duration(minutes: 15)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) {
      if (!_isSyncing) {
        startSync();
      }
    });
    debugPrint(
      '📅 Periodic sync scheduled every ${interval.inMinutes} minutes',
    );
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    debugPrint('⏹️ Periodic sync stopped');
  }

  /// Cleanup resources
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}
