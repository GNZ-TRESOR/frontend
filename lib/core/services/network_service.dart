import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network service for dynamic API endpoint detection
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  static NetworkService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  String? _currentBaseUrl;
  bool _isInitialized = false;

  /// List of possible backend URLs to try
  static const List<String> _possibleUrls = [
    'http://10.0.2.2:8080/api/v1', // Android emulator localhost
    'http://localhost:8080/api/v1', // Direct localhost
    'http://127.0.0.1:8080/api/v1', // Loopback
    'http://192.168.1.254:8080/api/v1', // Your current IP
    'http://192.168.88.68:8080/api/v1', // Previous IP
    'http://192.168.0.1:8080/api/v1', // Common router IP
    'http://192.168.1.1:8080/api/v1', // Another common router IP
  ];

  /// Initialize network service and find working endpoint
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🌐 Initializing Network Service...');

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Find working endpoint
    await _findWorkingEndpoint();

    _isInitialized = true;
    debugPrint('✅ Network Service initialized with URL: $_currentBaseUrl');
  }

  /// Get current working base URL
  String? get currentBaseUrl => _currentBaseUrl;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    debugPrint('🌐 Connectivity changed: $results');

    if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      // Network is available, try to find working endpoint
      _findWorkingEndpoint();
    }
  }

  /// Find a working backend endpoint
  Future<void> _findWorkingEndpoint() async {
    debugPrint('🔍 Searching for working backend endpoint...');

    for (String url in _possibleUrls) {
      if (await _testEndpoint(url)) {
        _currentBaseUrl = url;
        debugPrint('✅ Found working endpoint: $url');
        return;
      }
    }

    debugPrint('❌ No working endpoint found');
    _currentBaseUrl = _possibleUrls.first; // Fallback to first URL
  }

  /// Test if an endpoint is reachable
  Future<bool> _testEndpoint(String url) async {
    try {
      debugPrint('🧪 Testing endpoint: $url');

      final uri = Uri.parse(url.replaceAll('/api/v1', '/health'));
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      final request = await client.getUrl(uri);
      final response = await request.close();

      client.close();

      final isWorking =
          response.statusCode == 200 || response.statusCode == 404;
      debugPrint('🧪 Endpoint $url: ${isWorking ? "✅ Working" : "❌ Failed"}');

      return isWorking;
    } catch (e) {
      debugPrint('🧪 Endpoint $url: ❌ Failed - $e');
      return false;
    }
  }

  /// Force refresh endpoint detection
  Future<void> refreshEndpoint() async {
    debugPrint('🔄 Refreshing endpoint detection...');
    await _findWorkingEndpoint();
  }

  /// Get connectivity status
  Future<List<ConnectivityResult>> getConnectivityStatus() async {
    return await _connectivity.checkConnectivity();
  }

  /// Check if device is connected to internet
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get network info for debugging
  Map<String, dynamic> getNetworkInfo() {
    return {
      'currentBaseUrl': _currentBaseUrl,
      'isInitialized': _isInitialized,
      'possibleUrls': _possibleUrls,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
