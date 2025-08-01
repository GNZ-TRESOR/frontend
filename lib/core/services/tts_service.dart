import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for reading content aloud
/// Integrates seamlessly with existing app architecture
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en-US';

  /// Initialize TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Configure TTS settings
      await _configureTTS();

      // Set up event listeners
      _setupEventListeners();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ TTS Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ TTS Service initialization failed: $e');
      }
    }
  }

  /// Configure TTS settings
  Future<void> _configureTTS() async {
    if (_flutterTts == null) return;

    try {
      // Set default language
      await _flutterTts!.setLanguage(_currentLanguage);

      // Set speech rate for clear, natural speech (0.0 to 1.0)
      await _flutterTts!.setSpeechRate(0.45); // Slightly slower for clarity

      // Set volume (0.0 to 1.0)
      await _flutterTts!.setVolume(0.9); // Higher volume for better audibility

      // Set pitch for natural voice (0.5 to 2.0)
      await _flutterTts!.setPitch(
        0.95,
      ); // Slightly lower for more natural sound

      // Set queue mode to flush (replace current speech)
      await _flutterTts!.setQueueMode(0);

      // Set shared instance for better performance
      await _flutterTts!.setSharedInstance(true);

      // Auto-detect device language
      await _autoDetectLanguage();
    } catch (e) {
      if (kDebugMode) {
        print('TTS configuration error: $e');
      }
    }
  }

  /// Auto-detect device language and set appropriate voice
  Future<void> _autoDetectLanguage() async {
    if (_flutterTts == null) return;

    try {
      // Get available languages
      List<dynamic> languages = await _flutterTts!.getLanguages;

      // Try to detect system locale and find matching language
      // Prioritize English as requested by user
      List<String> preferredLanguages = [
        'en-US', // English (US) - Primary choice
        'en-GB', // English (UK) - Secondary choice
        'rw-RW', // Kinyarwanda
        'sw-KE', // Swahili
        'fr-FR', // French
      ];

      for (String lang in preferredLanguages) {
        if (languages.contains(lang)) {
          await _flutterTts!.setLanguage(lang);
          _currentLanguage = lang;
          if (kDebugMode) {
            print('TTS language set to: $lang');
          }
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Language detection error: $e');
      }
      // Fallback to English
      await _flutterTts!.setLanguage('en-US');
      _currentLanguage = 'en-US';
    }
  }

  /// Set up event listeners
  void _setupEventListeners() {
    if (_flutterTts == null) return;

    _flutterTts!.setStartHandler(() {
      _isSpeaking = true;
      if (kDebugMode) {
        print('🔊 TTS started speaking');
      }
    });

    _flutterTts!.setCompletionHandler(() {
      _isSpeaking = false;
      if (kDebugMode) {
        print('✅ TTS completed speaking');
      }
    });

    _flutterTts!.setErrorHandler((msg) {
      _isSpeaking = false;
      if (kDebugMode) {
        print('❌ TTS error: $msg');
      }
    });

    _flutterTts!.setCancelHandler(() {
      _isSpeaking = false;
      if (kDebugMode) {
        print('⏹️ TTS cancelled');
      }
    });
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null || text.trim().isEmpty) return;

    try {
      // Stop any ongoing speech
      await stop();

      // Clean the text (remove excessive whitespace, special characters)
      String cleanText = _cleanText(text);

      if (kDebugMode) {
        print(
          '🔊 Speaking: ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...',
        );
      }

      // Speak the text
      await _flutterTts!.speak(cleanText);
    } catch (e) {
      if (kDebugMode) {
        print('TTS speak error: $e');
      }
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.stop();
      _isSpeaking = false;
    } catch (e) {
      if (kDebugMode) {
        print('TTS stop error: $e');
      }
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.pause();
    } catch (e) {
      if (kDebugMode) {
        print('TTS pause error: $e');
      }
    }
  }

  /// Clean text for better TTS pronunciation
  String _cleanText(String text) {
    return text
        // Replace common abbreviations with full words for better pronunciation
        .replaceAll('Dr.', 'Doctor')
        .replaceAll('Mr.', 'Mister')
        .replaceAll('Mrs.', 'Missus')
        .replaceAll('Ms.', 'Miss')
        .replaceAll('&', 'and')
        .replaceAll('@', 'at')
        .replaceAll('%', 'percent')
        .replaceAll('#', 'number')
        .replaceAll('STI', 'S T I')
        .replaceAll('HIV', 'H I V')
        .replaceAll('AIDS', 'A I D S')
        .replaceAll('COVID', 'COVID')
        .replaceAll('WHO', 'W H O')
        .replaceAll('FAQ', 'F A Q')
        .replaceAll('API', 'A P I')
        .replaceAll('UI', 'U I')
        .replaceAll('ID', 'I D')
        // Add natural pauses for better flow
        .replaceAll('.', '. ')
        .replaceAll(',', ', ')
        .replaceAll(';', '; ')
        .replaceAll(':', ': ')
        .replaceAll('!', '! ')
        .replaceAll('?', '? ')
        // Remove special characters except basic punctuation
        .replaceAll(RegExp(r'[^\w\s\.,!?;:\-]'), ' ')
        // Replace multiple spaces with single space
        .replaceAll(RegExp(r'\s+'), ' ')
        // Remove excessive punctuation
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .replaceAll(RegExp(r',{2,}'), ',')
        .trim();
  }

  /// Check if TTS is currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Check if TTS is initialized
  bool get isInitialized => _isInitialized;

  /// Get current language
  String get currentLanguage => _currentLanguage;

  /// Force set language to English
  Future<void> setEnglish() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) return;

    try {
      await _flutterTts!.setLanguage('en-US');
      _currentLanguage = 'en-US';
      if (kDebugMode) {
        print('🇺🇸 TTS language set to English (US)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to set English language: $e');
      }
    }
  }

  /// Force set language to Kinyarwanda
  Future<void> setKinyarwanda() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) return;

    try {
      await _flutterTts!.setLanguage('rw-RW');
      _currentLanguage = 'rw-RW';
      if (kDebugMode) {
        print('🇷🇼 TTS language set to Kinyarwanda');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to set Kinyarwanda language: $e');
      }
    }
  }

  /// Force set language to French
  Future<void> setFrench() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_flutterTts == null) return;

    try {
      await _flutterTts!.setLanguage('fr-FR');
      _currentLanguage = 'fr-FR';
      if (kDebugMode) {
        print('🇫🇷 TTS language set to French');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to set French language: $e');
      }
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts!.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        print('TTS setSpeechRate error: $e');
      }
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        print('TTS setVolume error: $e');
      }
    }
  }

  /// Dispose TTS service
  Future<void> dispose() async {
    try {
      await stop();
      _flutterTts = null;
      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('TTS dispose error: $e');
      }
    }
  }
}
