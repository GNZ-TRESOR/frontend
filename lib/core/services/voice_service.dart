import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:speech_to_text/speech_to_text.dart'; // Temporarily disabled
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:record/record.dart'; // Temporarily disabled
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Voice Service for Ubuzima App
/// Provides comprehensive voice-first functionality for rural Rwanda users
/// Supports Kinyarwanda, English, and French languages
class VoiceService extends ChangeNotifier {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  // Core voice services
  // final SpeechToText _speechToText = SpeechToText(); // Temporarily disabled
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  // final AudioRecorder _audioRecorder = AudioRecorder(); // Temporarily disabled

  // State management
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isRecording = false;
  bool _isInitialized = false;
  String _currentLanguage = 'rw'; // Default to Kinyarwanda
  double _speechRate = 0.5; // Slower for rural users
  double _volume = 0.8;

  // Voice recognition results
  String _lastRecognizedText = '';
  double _confidence = 0.0;

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  String get currentLanguage => _currentLanguage;
  String get lastRecognizedText => _lastRecognizedText;
  double get confidence => _confidence;

  /// Initialize voice services
  Future<bool> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Initialize Speech-to-Text
      // TODO: Re-enable when speech_to_text package is compatible
      debugPrint('Speech-to-text initialization (placeholder)');

      // Initialize Text-to-Speech
      await _initializeTts();

      // Load saved preferences
      await _loadPreferences();

      _isInitialized = true; // Placeholder initialization
      notifyListeners();

      debugPrint('✅ Voice Service initialized (placeholder mode)');
      return true;
    } catch (e) {
      debugPrint('❌ Voice Service initialization failed: $e');
      return false;
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    final permissions = [Permission.microphone, Permission.speech];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status != PermissionStatus.granted) {
        debugPrint('⚠️ Permission denied: $permission');
      }
    }
  }

  /// Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_getLanguageCode(_currentLanguage));
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(1.0);

    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// Load user preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('voice_language') ?? 'rw';
      _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
      _volume = prefs.getDouble('voice_volume') ?? 0.8;
    } catch (e) {
      debugPrint('Failed to load voice preferences: $e');
    }
  }

  /// Save user preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('voice_language', _currentLanguage);
      await prefs.setDouble('speech_rate', _speechRate);
      await prefs.setDouble('voice_volume', _volume);
    } catch (e) {
      debugPrint('Failed to save voice preferences: $e');
    }
  }

  /// Start listening for voice input (placeholder - speech recognition temporarily disabled)
  Future<void> startListening({
    String? language,
    Function(String)? onResult,
    Function(String)? onError,
  }) async {
    if (!_isInitialized || _isListening) return;

    try {
      // TODO: Re-enable when speech_to_text package is compatible
      debugPrint('Voice listening started (placeholder mode)');

      _isListening = true;
      notifyListeners();

      // Simulate voice recognition for demo purposes
      await Future.delayed(const Duration(seconds: 2));
      _lastRecognizedText = 'Murabeho'; // Sample Kinyarwanda greeting
      _confidence = 0.95;

      _isListening = false;
      onResult?.call(_lastRecognizedText);
      notifyListeners();
    } catch (e) {
      debugPrint('Speech recognition error: $e');
      onError?.call(e.toString());
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stop listening (placeholder - speech recognition temporarily disabled)
  Future<void> stopListening() async {
    if (_isListening) {
      // TODO: Re-enable when speech_to_text package is compatible
      debugPrint('Voice listening stopped (placeholder)');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Speak text using TTS
  Future<void> speak(String text, {String? language}) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }

    try {
      final lang = language ?? _currentLanguage;
      await _flutterTts.setLanguage(_getLanguageCode(lang));

      _isSpeaking = true;
      notifyListeners();

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Play audio file (for offline content)
  Future<void> playAudio(String audioPath) async {
    try {
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  /// Start recording voice message
  Future<void> startRecording(String filePath) async {
    if (_isRecording) return;

    try {
      // TODO: Implement recording when record package is compatible
      debugPrint('Recording started (placeholder): $filePath');
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  /// Stop recording (placeholder - recording temporarily disabled)
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      // TODO: Implement stop recording when record package is compatible
      debugPrint('Recording stopped (placeholder)');
      _isRecording = false;
      notifyListeners();
      return 'placeholder_recording_path.m4a';
    } catch (e) {
      debugPrint('Stop recording error: $e');
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  /// Change language
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _flutterTts.setLanguage(_getLanguageCode(languageCode));
    await _savePreferences();
    notifyListeners();
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
    await _savePreferences();
    notifyListeners();
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
    await _savePreferences();
    notifyListeners();
  }

  /// Get language code for TTS/STT
  String _getLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'rw':
        return 'en-US'; // Fallback to English for Kinyarwanda (limited TTS support)
      case 'en':
        return 'en-US';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }

  // Speech recognition error and status handlers removed (temporarily disabled)

  /// Dispose resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    // _audioRecorder.dispose(); // Temporarily disabled
    super.dispose();
  }
}
