import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio Content Service for Ubuzima App
/// Manages offline Kinyarwanda audio content for voice-first experience
/// Provides family planning education through culturally appropriate audio
class AudioContentService extends ChangeNotifier {
  static final AudioContentService _instance = AudioContentService._internal();
  factory AudioContentService() => _instance;
  AudioContentService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudio;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  bool get isPlaying => _isPlaying;
  String? get currentAudio => _currentAudio;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// Initialize audio service
  Future<void> initialize() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });
  }

  /// Family Planning Audio Content Library
  /// Organized by categories for easy navigation
  static const Map<String, Map<String, String>> audioLibrary = {
    'family_planning_basics': {
      'title_rw': 'Amahugurwa y\'ibanze ku kubana n\'ubwiyunge',
      'title_en': 'Basic Family Planning Education',
      'title_fr': 'Éducation de base en planification familiale',
      'description_rw': 'Amahugurwa y\'ibanze ku kubana n\'ubwiyunge',
      'audio_path': 'audio/family_planning_basics_rw.mp3',
      'duration': '5:30',
    },
    'contraceptive_methods': {
      'title_rw': 'Uburyo bwo kurinda inda',
      'title_en': 'Contraceptive Methods',
      'title_fr': 'Méthodes contraceptives',
      'description_rw': 'Uburyo butandukanye bwo kurinda inda',
      'audio_path': 'audio/contraceptive_methods_rw.mp3',
      'duration': '8:15',
    },
    'menstrual_health': {
      'title_rw': 'Ubuzima bw\'imihango',
      'title_en': 'Menstrual Health',
      'title_fr': 'Santé menstruelle',
      'description_rw': 'Amakuru ku buzima bw\'imihango',
      'audio_path': 'audio/menstrual_health_rw.mp3',
      'duration': '6:45',
    },
    'pregnancy_planning': {
      'title_rw': 'Gutegura inda',
      'title_en': 'Pregnancy Planning',
      'title_fr': 'Planification de grossesse',
      'description_rw': 'Amakuru yo gutegura inda neza',
      'audio_path': 'audio/pregnancy_planning_rw.mp3',
      'duration': '7:20',
    },
    'reproductive_health': {
      'title_rw': 'Ubuzima bw\'imyororokere',
      'title_en': 'Reproductive Health',
      'title_fr': 'Santé reproductive',
      'description_rw': 'Amakuru ku buzima bw\'imyororokere',
      'audio_path': 'audio/reproductive_health_rw.mp3',
      'duration': '9:10',
    },
    'male_involvement': {
      'title_rw': 'Uruhare rw\'abagabo mu kubana n\'ubwiyunge',
      'title_en': 'Male Involvement in Family Planning',
      'title_fr': 'Implication masculine dans la planification familiale',
      'description_rw': 'Uruhare rw\'abagabo mu kubana n\'ubwiyunge',
      'audio_path': 'audio/male_involvement_rw.mp3',
      'duration': '6:30',
    },
    'youth_education': {
      'title_rw': 'Amahugurwa y\'urubyiruko',
      'title_en': 'Youth Education',
      'title_fr': 'Éducation des jeunes',
      'description_rw': 'Amahugurwa y\'urubyiruko ku buzima bw\'imyororokere',
      'audio_path': 'audio/youth_education_rw.mp3',
      'duration': '8:45',
    },
    'emergency_contraception': {
      'title_rw': 'Kurinda inda mu bihe by\'ihutirwa',
      'title_en': 'Emergency Contraception',
      'title_fr': 'Contraception d\'urgence',
      'description_rw': 'Amakuru ku kurinda inda mu bihe by\'ihutirwa',
      'audio_path': 'audio/emergency_contraception_rw.mp3',
      'duration': '4:15',
    },
  };

  /// Voice Navigation Commands in Kinyarwanda
  static const Map<String, String> voiceCommands = {
    'komeza': 'continue',
    'hagarika': 'stop',
    'subiramo': 'repeat',
    'subira inyuma': 'go back',
    'komeza mbere': 'go forward',
    'vuga cyane': 'speak louder',
    'vuga buhoro': 'speak slower',
    'ahabanza': 'home',
    'amahugurwa': 'education',
    'ubuzima': 'health',
    'ubutumwa': 'messages',
    'gahunda': 'planning',
  };

  /// Get audio content by category
  Map<String, String>? getAudioContent(String category) {
    return audioLibrary[category];
  }

  /// Get all audio categories
  List<String> getAudioCategories() {
    return audioLibrary.keys.toList();
  }

  /// Play audio content
  Future<void> playAudio(String category) async {
    try {
      final content = audioLibrary[category];
      if (content == null) {
        debugPrint('Audio content not found: $category');
        return;
      }

      final audioPath = content['audio_path']!;
      _currentAudio = category;
      
      // For now, we'll use a placeholder since actual audio files aren't available
      // In production, this would play the actual Kinyarwanda audio files
      debugPrint('🎵 Playing audio: ${content['title_rw']} ($audioPath)');
      
      // Simulate audio playback for demo purposes
      _isPlaying = true;
      notifyListeners();
      
      // In real implementation, uncomment this:
      // await _audioPlayer.play(AssetSource(audioPath));
      
    } catch (e) {
      debugPrint('Audio playback error: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentAudio = null;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  /// Pause audio playback
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume audio playback
  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Process voice command
  String? processVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    
    // Check for exact matches first
    if (voiceCommands.containsKey(lowerCommand)) {
      return voiceCommands[lowerCommand];
    }
    
    // Check for partial matches
    for (final entry in voiceCommands.entries) {
      if (lowerCommand.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Get audio content for current language
  String getLocalizedTitle(String category, String languageCode) {
    final content = audioLibrary[category];
    if (content == null) return category;
    
    switch (languageCode) {
      case 'rw':
        return content['title_rw'] ?? content['title_en'] ?? category;
      case 'fr':
        return content['title_fr'] ?? content['title_en'] ?? category;
      default:
        return content['title_en'] ?? category;
    }
  }

  /// Get audio description for current language
  String getLocalizedDescription(String category, String languageCode) {
    final content = audioLibrary[category];
    if (content == null) return '';
    
    switch (languageCode) {
      case 'rw':
        return content['description_rw'] ?? '';
      case 'fr':
        return content['description_fr'] ?? '';
      default:
        return content['description_en'] ?? '';
    }
  }

  /// Save listening progress
  Future<void> saveProgress(String category, Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('audio_${category}_position', position.inSeconds);
    } catch (e) {
      debugPrint('Failed to save audio progress: $e');
    }
  }

  /// Load listening progress
  Future<Duration> loadProgress(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seconds = prefs.getInt('audio_${category}_position') ?? 0;
      return Duration(seconds: seconds);
    } catch (e) {
      debugPrint('Failed to load audio progress: $e');
      return Duration.zero;
    }
  }

  /// Mark content as completed
  Future<void> markCompleted(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_${category}_completed', true);
    } catch (e) {
      debugPrint('Failed to mark audio as completed: $e');
    }
  }

  /// Check if content is completed
  Future<bool> isCompleted(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('audio_${category}_completed') ?? false;
    } catch (e) {
      debugPrint('Failed to check audio completion: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
