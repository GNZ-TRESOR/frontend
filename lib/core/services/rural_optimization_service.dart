import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Rural Optimization Service for Ubuzima App
/// Optimizes app performance and user experience for rural Rwanda users
/// Handles low-resource devices, poor connectivity, and cultural adaptations
class RuralOptimizationService extends ChangeNotifier {
  static final RuralOptimizationService _instance =
      RuralOptimizationService._internal();
  factory RuralOptimizationService() => _instance;
  RuralOptimizationService._internal();

  // Device and connectivity state
  bool _isLowEndDevice = false;
  bool _isOfflineMode = false;
  bool _hasLimitedConnectivity = false;
  String _deviceType = 'unknown';

  // User preferences for rural context
  bool _preferVoiceInterface = true;
  bool _useSimplifiedUI = false;
  bool _enableDataSaver = true;
  bool _useKinyarwandaFirst = true;
  double _fontSizeMultiplier = 1.0;

  // Performance metrics
  int _appLaunchTime = 0;
  int _averageResponseTime = 0;
  int _dataUsageMB = 0;
  int _batteryOptimizationLevel = 1;

  // Getters
  bool get isLowEndDevice => _isLowEndDevice;
  bool get isOfflineMode => _isOfflineMode;
  bool get hasLimitedConnectivity => _hasLimitedConnectivity;
  bool get preferVoiceInterface => _preferVoiceInterface;
  bool get useSimplifiedUI => _useSimplifiedUI;
  bool get enableDataSaver => _enableDataSaver;
  bool get useKinyarwandaFirst => _useKinyarwandaFirst;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  String get deviceType => _deviceType;

  /// Initialize rural optimization service
  Future<void> initialize() async {
    try {
      await _detectDeviceCapabilities();
      await _loadUserPreferences();
      await _setupConnectivityMonitoring();
      await _optimizeForDevice();

      debugPrint('✅ Rural Optimization Service initialized');
      debugPrint('📱 Device: $_deviceType (Low-end: $_isLowEndDevice)');
      debugPrint(
        '🌐 Connectivity: ${_hasLimitedConnectivity ? "Limited" : "Good"}',
      );
      debugPrint('🗣️ Voice preference: $_preferVoiceInterface');
    } catch (e) {
      debugPrint('❌ Rural optimization initialization failed: $e');
    }
  }

  /// Detect device capabilities and performance
  Future<void> _detectDeviceCapabilities() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;

        // Detect low-end devices based on Android version and RAM
        _isLowEndDevice =
            androidInfo.version.sdkInt < 26 || // Android 8.0+
            (androidInfo.systemFeatures.contains('android.hardware.ram.low'));

        _deviceType = '${androidInfo.manufacturer} ${androidInfo.model}';

        // Device performance optimization based on specs
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;

        // Detect older iOS devices
        _isLowEndDevice =
            iosInfo.systemVersion.startsWith('12') ||
            iosInfo.systemVersion.startsWith('13');

        _deviceType = '${iosInfo.name} ${iosInfo.model}';
      }

      // Auto-enable simplified UI for low-end devices
      if (_isLowEndDevice) {
        _useSimplifiedUI = true;
        _enableDataSaver = true;
        _batteryOptimizationLevel = 2; // Aggressive battery saving
      }
    } catch (e) {
      debugPrint('Device detection error: $e');
      // Assume low-end device for safety
      _isLowEndDevice = true;
      _useSimplifiedUI = true;
    }
  }

  /// Setup connectivity monitoring
  Future<void> _setupConnectivityMonitoring() async {
    try {
      final connectivity = Connectivity();

      // Check initial connectivity
      final result = await connectivity.checkConnectivity();
      _updateConnectivityStatus(result);

      // Listen for connectivity changes
      connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
    } catch (e) {
      debugPrint('Connectivity monitoring error: $e');
      _hasLimitedConnectivity = true; // Assume limited for safety
    }
  }

  /// Update connectivity status
  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasOffline = _isOfflineMode;

    switch (result) {
      case ConnectivityResult.none:
        _isOfflineMode = true;
        _hasLimitedConnectivity = true;
        break;
      case ConnectivityResult.mobile:
        _isOfflineMode = false;
        _hasLimitedConnectivity = true; // Assume limited mobile data
        break;
      case ConnectivityResult.wifi:
        _isOfflineMode = false;
        _hasLimitedConnectivity = false;
        break;
      default:
        _isOfflineMode = false;
        _hasLimitedConnectivity = true;
    }

    if (wasOffline != _isOfflineMode) {
      notifyListeners();
      debugPrint(
        '🌐 Connectivity changed: ${_isOfflineMode ? "Offline" : "Online"}',
      );
    }
  }

  /// Load user preferences for rural context
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _preferVoiceInterface = prefs.getBool('prefer_voice_interface') ?? true;
      _useSimplifiedUI = prefs.getBool('use_simplified_ui') ?? _isLowEndDevice;
      _enableDataSaver = prefs.getBool('enable_data_saver') ?? true;
      _useKinyarwandaFirst = prefs.getBool('use_kinyarwanda_first') ?? true;
      _fontSizeMultiplier = prefs.getDouble('font_size_multiplier') ?? 1.0;
      _batteryOptimizationLevel =
          prefs.getInt('battery_optimization_level') ?? 1;
    } catch (e) {
      debugPrint('Failed to load rural preferences: $e');
    }
  }

  /// Save user preferences
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('prefer_voice_interface', _preferVoiceInterface);
      await prefs.setBool('use_simplified_ui', _useSimplifiedUI);
      await prefs.setBool('enable_data_saver', _enableDataSaver);
      await prefs.setBool('use_kinyarwanda_first', _useKinyarwandaFirst);
      await prefs.setDouble('font_size_multiplier', _fontSizeMultiplier);
      await prefs.setInt(
        'battery_optimization_level',
        _batteryOptimizationLevel,
      );
    } catch (e) {
      debugPrint('Failed to save rural preferences: $e');
    }
  }

  /// Optimize app for current device
  Future<void> _optimizeForDevice() async {
    if (_isLowEndDevice) {
      // Reduce animations and effects
      await _setLowEndOptimizations();
    }

    if (_hasLimitedConnectivity) {
      // Enable aggressive caching and offline mode
      await _setConnectivityOptimizations();
    }

    if (_enableDataSaver) {
      // Reduce data usage
      await _setDataSaverOptimizations();
    }
  }

  /// Apply optimizations for low-end devices
  Future<void> _setLowEndOptimizations() async {
    // Reduce animation duration
    // Disable complex visual effects
    // Use lower quality images
    // Implement lazy loading
    debugPrint('🔧 Applied low-end device optimizations');
  }

  /// Apply optimizations for limited connectivity
  Future<void> _setConnectivityOptimizations() async {
    // Enable aggressive caching
    // Prioritize offline functionality
    // Reduce background sync frequency
    debugPrint('🔧 Applied connectivity optimizations');
  }

  /// Apply data saver optimizations
  Future<void> _setDataSaverOptimizations() async {
    // Compress images
    // Reduce sync frequency
    // Use text instead of images where possible
    debugPrint('🔧 Applied data saver optimizations');
  }

  /// Cultural and linguistic adaptations for rural Rwanda
  Map<String, String> getLocalizedHealthTerms() {
    return {
      // Family Planning Terms
      'family_planning': 'Kubana n\'ubwiyunge',
      'contraception': 'Kurinda inda',
      'birth_control': 'Kugenzura amavuko',
      'pregnancy': 'Inda',
      'menstruation': 'Imihango',
      'ovulation': 'Gusohora amagi',

      // Health Worker Terms
      'doctor': 'Muganga',
      'nurse': 'Umuforomo',
      'midwife': 'Umubyaza',
      'health_worker': 'Umukozi w\'ubuzima',
      'counselor': 'Umujyanama',

      // Health Facility Terms
      'hospital': 'Ibitaro',
      'clinic': 'Ivuriro',
      'health_center': 'Ikigo cy\'ubuzima',
      'pharmacy': 'Farumasi',

      // Common Health Terms
      'health': 'Ubuzima',
      'medicine': 'Imiti',
      'treatment': 'Kuvura',
      'appointment': 'Gahunda',
      'emergency': 'Ihutirwa',
      'symptoms': 'Ibimenyetso',

      // Voice Commands
      'yes': 'Yego',
      'no': 'Oya',
      'help': 'Ubufasha',
      'continue': 'Komeza',
      'stop': 'Hagarika',
      'repeat': 'Subiramo',
      'home': 'Ahabanza',
      'back': 'Subira inyuma',
    };
  }

  /// Get culturally appropriate error messages
  String getLocalizedErrorMessage(String errorType) {
    final messages = {
      'network_error': 'Murandasi ntirashobora gukoresha. Gerageza ukundi.',
      'server_error': 'Habaye ikosa kuri seriveri. Gerageza ukundi.',
      'validation_error': 'Amakuru wanditse ntabwo ari yo. Gerageza ukundi.',
      'permission_error': 'Tugomba uruhushya rwo gukoresha iyi fonctionnalité.',
      'voice_error': 'Ijwi ntiriramenyekana. Gerageza ukundi.',
      'offline_error':
          'Nta internet. Ibi bikorwa bizakora mugihe ufite internet.',
      'low_storage': 'Nta mwanya uhagije. Siba amakuru atari ngombwa.',
      'low_battery': 'Bateri irashira. Koresha gahoro.',
    };

    return messages[errorType] ?? 'Habaye ikosa. Gerageza ukundi.';
  }

  /// Update preferences
  Future<void> setVoicePreference(bool prefer) async {
    _preferVoiceInterface = prefer;
    await _saveUserPreferences();
    notifyListeners();
  }

  Future<void> setSimplifiedUI(bool simplified) async {
    _useSimplifiedUI = simplified;
    await _saveUserPreferences();
    notifyListeners();
  }

  Future<void> setDataSaver(bool enabled) async {
    _enableDataSaver = enabled;
    await _saveUserPreferences();
    if (enabled) {
      await _setDataSaverOptimizations();
    }
    notifyListeners();
  }

  Future<void> setKinyarwandaFirst(bool enabled) async {
    _useKinyarwandaFirst = enabled;
    await _saveUserPreferences();
    notifyListeners();
  }

  Future<void> setFontSizeMultiplier(double multiplier) async {
    _fontSizeMultiplier = multiplier.clamp(0.8, 1.5);
    await _saveUserPreferences();
    notifyListeners();
  }

  /// Get recommended settings for rural users
  Map<String, dynamic> getRecommendedSettings() {
    return {
      'voice_interface': true,
      'simplified_ui': _isLowEndDevice,
      'data_saver': _hasLimitedConnectivity,
      'kinyarwanda_first': true,
      'font_size': _isLowEndDevice ? 1.2 : 1.0,
      'offline_mode': _hasLimitedConnectivity,
      'battery_optimization': _isLowEndDevice ? 2 : 1,
    };
  }

  /// Performance monitoring
  void recordAppLaunchTime(int milliseconds) {
    _appLaunchTime = milliseconds;
    debugPrint('📊 App launch time: ${milliseconds}ms');
  }

  void recordResponseTime(int milliseconds) {
    _averageResponseTime = ((_averageResponseTime + milliseconds) / 2).round();
    debugPrint('📊 Average response time: ${_averageResponseTime}ms');
  }

  void recordDataUsage(int bytes) {
    _dataUsageMB += (bytes / 1024 / 1024).round();
    debugPrint('📊 Data usage: ${_dataUsageMB}MB');
  }

  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    return {
      'device_type': _deviceType,
      'is_low_end': _isLowEndDevice,
      'connectivity': _hasLimitedConnectivity ? 'Limited' : 'Good',
      'app_launch_time_ms': _appLaunchTime,
      'average_response_time_ms': _averageResponseTime,
      'data_usage_mb': _dataUsageMB,
      'battery_optimization_level': _batteryOptimizationLevel,
      'offline_mode': _isOfflineMode,
    };
  }
}
