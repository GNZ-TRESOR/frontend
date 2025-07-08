import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gemini_ai_service.dart';
import 'audio_content_service.dart';
import 'voice_service.dart';
import 'rural_optimization_service.dart';

/// Health Education Service for Ubuzima App
/// Provides comprehensive family planning education for rural Rwanda users
/// Integrates AI assistance, audio content, and voice interaction
class HealthEducationService extends ChangeNotifier {
  static final HealthEducationService _instance =
      HealthEducationService._internal();
  factory HealthEducationService() => _instance;
  HealthEducationService._internal();

  final GeminiAIService _aiService = GeminiAIService();
  final AudioContentService _audioService = AudioContentService();
  final VoiceService _voiceService = VoiceService();
  final RuralOptimizationService _ruralService = RuralOptimizationService();

  // Education progress tracking
  Map<String, bool> _completedTopics = {};
  final Map<String, DateTime> _topicProgress = {};
  String _currentLanguage = 'rw';
  bool _preferVoiceEducation = true;

  // Getters
  Map<String, bool> get completedTopics => _completedTopics;
  Map<String, DateTime> get topicProgress => _topicProgress;
  String get currentLanguage => _currentLanguage;
  bool get preferVoiceEducation => _preferVoiceEducation;

  /// Initialize health education service
  Future<void> initialize() async {
    await _loadProgress();
    await _audioService.initialize();
    debugPrint('✅ Health Education Service initialized');
  }

  /// Core health education topics for rural Rwanda
  static const Map<String, Map<String, String>> educationTopics = {
    'family_planning_basics': {
      'title_rw': 'Amahugurwa y\'ibanze ku kubana n\'ubwiyunge',
      'title_en': 'Basic Family Planning Education',
      'title_fr': 'Éducation de base en planification familiale',
      'category': 'family_planning',
      'difficulty': 'beginner',
      'duration_minutes': '15',
    },
    'contraceptive_methods': {
      'title_rw': 'Uburyo bwo kurinda inda',
      'title_en': 'Contraceptive Methods',
      'title_fr': 'Méthodes contraceptives',
      'category': 'contraception',
      'difficulty': 'intermediate',
      'duration_minutes': '20',
    },
    'menstrual_health': {
      'title_rw': 'Ubuzima bw\'imihango',
      'title_en': 'Menstrual Health',
      'title_fr': 'Santé menstruelle',
      'category': 'health',
      'difficulty': 'beginner',
      'duration_minutes': '12',
    },
    'pregnancy_planning': {
      'title_rw': 'Gutegura inda',
      'title_en': 'Pregnancy Planning',
      'title_fr': 'Planification de grossesse',
      'category': 'pregnancy',
      'difficulty': 'intermediate',
      'duration_minutes': '18',
    },
    'reproductive_health': {
      'title_rw': 'Ubuzima bw\'imyororokere',
      'title_en': 'Reproductive Health',
      'title_fr': 'Santé reproductive',
      'category': 'health',
      'difficulty': 'intermediate',
      'duration_minutes': '25',
    },
    'youth_education': {
      'title_rw': 'Amahugurwa y\'urubyiruko',
      'title_en': 'Youth Education',
      'title_fr': 'Éducation des jeunes',
      'category': 'youth',
      'difficulty': 'beginner',
      'duration_minutes': '16',
    },
    'sti_prevention': {
      'title_rw': 'Kurinda indwara zandurira mu mibonano',
      'title_en': 'STI Prevention',
      'title_fr': 'Prévention des IST',
      'category': 'prevention',
      'difficulty': 'intermediate',
      'duration_minutes': '14',
    },
    'male_involvement': {
      'title_rw': 'Uruhare rw\'abagabo mu kubana n\'ubwiyunge',
      'title_en': 'Male Involvement in Family Planning',
      'title_fr': 'Implication masculine dans la planification familiale',
      'category': 'family_planning',
      'difficulty': 'intermediate',
      'duration_minutes': '22',
    },
  };

  /// Get all available education topics
  List<String> getAvailableTopics() {
    return educationTopics.keys.toList();
  }

  /// Get topics by category
  List<String> getTopicsByCategory(String category) {
    return educationTopics.entries
        .where((entry) => entry.value['category'] == category)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get recommended topics for user
  List<String> getRecommendedTopics() {
    final incomplete =
        educationTopics.keys
            .where((topic) => !(_completedTopics[topic] ?? false))
            .toList();

    // Prioritize beginner topics for new users
    incomplete.sort((a, b) {
      final aDifficulty = educationTopics[a]?['difficulty'] ?? 'intermediate';
      final bDifficulty = educationTopics[b]?['difficulty'] ?? 'intermediate';

      if (aDifficulty == 'beginner' && bDifficulty != 'beginner') return -1;
      if (bDifficulty == 'beginner' && aDifficulty != 'beginner') return 1;
      return 0;
    });

    return incomplete.take(3).toList();
  }

  /// Start education session for a topic
  Future<void> startEducationSession(String topicId) async {
    if (!educationTopics.containsKey(topicId)) {
      throw ArgumentError('Unknown topic: $topicId');
    }

    debugPrint('🎓 Starting education session: $topicId');

    // Record session start
    _topicProgress[topicId] = DateTime.now();
    await _saveProgress();

    // Determine delivery method based on user preferences
    if (_preferVoiceEducation && _ruralService.preferVoiceInterface) {
      await _deliverVoiceEducation(topicId);
    } else {
      await _deliverTextEducation(topicId);
    }

    notifyListeners();
  }

  /// Deliver education through voice/audio
  Future<void> _deliverVoiceEducation(String topicId) async {
    try {
      // Play audio content if available
      await _audioService.playAudio(topicId);

      // Provide voice introduction
      final title = getTopicTitle(topicId, _currentLanguage);
      await _voiceService.speak(
        'Ubu tuziga ku $title. Umva neza.',
        language: _currentLanguage,
      );
    } catch (e) {
      debugPrint('Voice education error: $e');
      // Fallback to text education
      await _deliverTextEducation(topicId);
    }
  }

  /// Deliver education through text/AI
  Future<void> _deliverTextEducation(String topicId) async {
    try {
      final title = getTopicTitle(topicId, _currentLanguage);
      final question = 'Mbarize ku $title'; // Tell me about...

      final response = await _aiService.getHealthAdvice(
        question,
        language: _getLanguageForAI(_currentLanguage),
      );

      debugPrint('📚 Education content delivered for $topicId');

      // If voice is preferred, also speak the response
      if (_preferVoiceEducation) {
        await _voiceService.speak(response, language: _currentLanguage);
      }
    } catch (e) {
      debugPrint('Text education error: $e');
    }
  }

  /// Ask AI assistant a question about health topic
  Future<String> askHealthQuestion(String question) async {
    try {
      final response = await _aiService.getHealthAdvice(
        question,
        language: _getLanguageForAI(_currentLanguage),
      );

      // Speak response if voice is preferred
      if (_preferVoiceEducation && _voiceService.isInitialized) {
        _voiceService.speak(response, language: _currentLanguage);
      }

      return response;
    } catch (e) {
      debugPrint('Health question error: $e');
      return _ruralService.getLocalizedErrorMessage('ai_error');
    }
  }

  /// Mark topic as completed
  Future<void> markTopicCompleted(String topicId) async {
    _completedTopics[topicId] = true;
    await _saveProgress();
    notifyListeners();

    debugPrint('✅ Topic completed: $topicId');

    // Provide completion feedback
    if (_preferVoiceEducation) {
      await _voiceService.speak(
        'Mwiriwe! Mwarangije iki gice. Komeza gutyo!',
        language: _currentLanguage,
      );
    }
  }

  /// Get topic title in specified language
  String getTopicTitle(String topicId, String languageCode) {
    final topic = educationTopics[topicId];
    if (topic == null) return topicId;

    switch (languageCode) {
      case 'rw':
        return topic['title_rw'] ?? topic['title_en'] ?? topicId;
      case 'fr':
        return topic['title_fr'] ?? topic['title_en'] ?? topicId;
      default:
        return topic['title_en'] ?? topicId;
    }
  }

  /// Get education progress percentage
  double getProgressPercentage() {
    if (educationTopics.isEmpty) return 0.0;
    final completed = _completedTopics.values.where((v) => v).length;
    return completed / educationTopics.length;
  }

  /// Set language preference
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _saveProgress();
    notifyListeners();
  }

  /// Set voice education preference
  Future<void> setVoiceEducationPreference(bool prefer) async {
    _preferVoiceEducation = prefer;
    await _saveProgress();
    notifyListeners();
  }

  /// Convert language code for AI service
  String _getLanguageForAI(String languageCode) {
    switch (languageCode) {
      case 'rw':
        return 'kinyarwanda';
      case 'fr':
        return 'french';
      default:
        return 'english';
    }
  }

  /// Load education progress from storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load completed topics
      _completedTopics = Map<String, bool>.from(
        Map<String, dynamic>.from(
          // Simple parsing since we're storing boolean values
          prefs
              .getKeys()
              .where((key) => key.startsWith('topic_completed_'))
              .fold<Map<String, bool>>({}, (map, key) {
                final topicId = key.replaceFirst('topic_completed_', '');
                map[topicId] = prefs.getBool(key) ?? false;
                return map;
              }),
        ),
      );

      // Load preferences
      _currentLanguage = prefs.getString('education_language') ?? 'rw';
      _preferVoiceEducation = prefs.getBool('prefer_voice_education') ?? true;
    } catch (e) {
      debugPrint('Failed to load education progress: $e');
    }
  }

  /// Save education progress to storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save completed topics
      for (final entry in _completedTopics.entries) {
        await prefs.setBool('topic_completed_${entry.key}', entry.value);
      }

      // Save preferences
      await prefs.setString('education_language', _currentLanguage);
      await prefs.setBool('prefer_voice_education', _preferVoiceEducation);
    } catch (e) {
      debugPrint('Failed to save education progress: $e');
    }
  }
}
