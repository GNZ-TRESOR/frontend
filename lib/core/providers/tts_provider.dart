import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tts_service.dart';

/// TTS State class
class TTSState {
  final bool isInitialized;
  final bool isSpeaking;
  final String currentLanguage;
  final double speechRate;
  final double volume;
  final String? error;

  const TTSState({
    this.isInitialized = false,
    this.isSpeaking = false,
    this.currentLanguage = 'en-US',
    this.speechRate = 0.5,
    this.volume = 0.8,
    this.error,
  });

  TTSState copyWith({
    bool? isInitialized,
    bool? isSpeaking,
    String? currentLanguage,
    double? speechRate,
    double? volume,
    String? error,
  }) {
    return TTSState(
      isInitialized: isInitialized ?? this.isInitialized,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      error: error,
    );
  }
}

/// TTS Provider Notifier
class TTSNotifier extends StateNotifier<TTSState> {
  TTSNotifier() : super(const TTSState()) {
    _initialize();
  }

  final TTSService _ttsService = TTSService();

  /// Initialize TTS service
  Future<void> _initialize() async {
    try {
      await _ttsService.initialize();
      state = state.copyWith(
        isInitialized: _ttsService.isInitialized,
        currentLanguage: _ttsService.currentLanguage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isInitialized: false);
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!state.isInitialized) {
      await _initialize();
    }

    try {
      state = state.copyWith(error: null);
      await _ttsService.speak(text);

      // Update speaking state
      state = state.copyWith(isSpeaking: _ttsService.isSpeaking);

      // Monitor speaking state
      _monitorSpeakingState();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSpeaking: false);
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _ttsService.stop();
      state = state.copyWith(isSpeaking: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _ttsService.pause();
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    try {
      await _ttsService.setSpeechRate(rate);
      state = state.copyWith(speechRate: rate, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    try {
      await _ttsService.setVolume(volume);
      state = state.copyWith(volume: volume, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Monitor speaking state changes
  void _monitorSpeakingState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final currentlySpeaking = _ttsService.isSpeaking;
        if (state.isSpeaking != currentlySpeaking) {
          state = state.copyWith(isSpeaking: currentlySpeaking);

          // Continue monitoring if still speaking
          if (currentlySpeaking) {
            _monitorSpeakingState();
          }
        }
      }
    });
  }

  /// Set language to English
  Future<void> setEnglish() async {
    try {
      await _ttsService.setEnglish();
      state = state.copyWith(
        currentLanguage: _ttsService.currentLanguage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set language to Kinyarwanda
  Future<void> setKinyarwanda() async {
    try {
      await _ttsService.setKinyarwanda();
      state = state.copyWith(
        currentLanguage: _ttsService.currentLanguage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set language to French
  Future<void> setFrench() async {
    try {
      await _ttsService.setFrench();
      state = state.copyWith(
        currentLanguage: _ttsService.currentLanguage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}

/// TTS Provider
final ttsProvider = StateNotifierProvider<TTSNotifier, TTSState>((ref) {
  return TTSNotifier();
});

/// Convenience providers for specific state properties
final ttsIsInitializedProvider = Provider<bool>((ref) {
  return ref.watch(ttsProvider).isInitialized;
});

final ttsIsSpeakingProvider = Provider<bool>((ref) {
  return ref.watch(ttsProvider).isSpeaking;
});

final ttsCurrentLanguageProvider = Provider<String>((ref) {
  return ref.watch(ttsProvider).currentLanguage;
});

final ttsErrorProvider = Provider<String?>((ref) {
  return ref.watch(ttsProvider).error;
});
