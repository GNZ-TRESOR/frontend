import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/libre_translate_service.dart';
import '../services/hybrid_translation_service.dart';

/// Global translation state
class GlobalTranslationState {
  final String currentLanguage;
  final Map<String, String> translations;
  final bool isLoading;
  final String? error;
  final Set<String> translatedWidgets;

  const GlobalTranslationState({
    required this.currentLanguage,
    required this.translations,
    this.isLoading = false,
    this.error,
    this.translatedWidgets = const {},
  });

  GlobalTranslationState copyWith({
    String? currentLanguage,
    Map<String, String>? translations,
    bool? isLoading,
    String? error,
    Set<String>? translatedWidgets,
  }) {
    return GlobalTranslationState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      translations: translations ?? this.translations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      translatedWidgets: translatedWidgets ?? this.translatedWidgets,
    );
  }
}

/// Global translation notifier that handles app-wide translation
class GlobalTranslationNotifier extends StateNotifier<GlobalTranslationState> {
  static const String _languageKey = 'global_language';
  static const String _translationsKey = 'global_translations';

  final LibreTranslateService _libreTranslateService;
  final HybridTranslationService _hybridService;

  GlobalTranslationNotifier()
    : _libreTranslateService = LibreTranslateService.instance,
      _hybridService = HybridTranslationService.instance,
      super(
        const GlobalTranslationState(currentLanguage: 'en', translations: {}),
      ) {
    _initialize();
  }

  /// Initialize the translation system
  Future<void> _initialize() async {
    await _loadSavedLanguage();
    await _loadCachedTranslations();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? 'en';

      if (savedLanguage != state.currentLanguage) {
        state = state.copyWith(currentLanguage: savedLanguage);
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }

  /// Load cached translations from SharedPreferences
  Future<void> _loadCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(
        '${_translationsKey}_${state.currentLanguage}',
      );

      if (cachedData != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          Uri.splitQueryString(cachedData),
        );
        final translations = data.map(
          (key, value) => MapEntry(key, value.toString()),
        );

        state = state.copyWith(translations: translations);
      }
    } catch (e) {
      debugPrint('Error loading cached translations: $e');
    }
  }

  /// Change language and translate entire app
  Future<void> changeLanguage(String languageCode) async {
    if (state.currentLanguage == languageCode) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Save language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      // Update current language
      state = state.copyWith(currentLanguage: languageCode);

      // Load cached translations for this language
      await _loadCachedTranslations();

      // If not English, start background translation of common strings
      if (languageCode != 'en') {
        _translateCommonStrings(languageCode);
      }

      state = state.copyWith(isLoading: false);

      debugPrint('Global language changed to: $languageCode');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to change language: $e',
      );
      debugPrint('Error changing language: $e');
    }
  }

  /// Translate a single text string
  Future<String> translateText(String text, {String? targetLang}) async {
    final language = targetLang ?? state.currentLanguage;

    // Return original text if English
    if (language == 'en') return text;

    // Check if already translated
    final cacheKey = '${text}_$language';
    if (state.translations.containsKey(cacheKey)) {
      return state.translations[cacheKey]!;
    }

    try {
      // Use hybrid service for translation
      final translation = await _hybridService.translateText(
        text,
        language,
        null,
      );

      // Cache the translation
      final updatedTranslations = Map<String, String>.from(state.translations);
      updatedTranslations[cacheKey] = translation;

      state = state.copyWith(translations: updatedTranslations);

      // Save to persistent cache
      _saveCachedTranslations();

      return translation;
    } catch (e) {
      debugPrint('Translation error for "$text": $e');
      return text; // Fallback to original text
    }
  }

  /// Translate common app strings in background
  Future<void> _translateCommonStrings(String languageCode) async {
    final commonStrings = [
      // Navigation
      'Home', 'Health', 'Education', 'Community', 'Profile',
      'Settings', 'Back', 'Next', 'Cancel', 'Save', 'Delete', 'Edit',

      // Health specific
      'Appointments', 'My Appointments', 'Book Appointment', 'Health Records',
      'Medications',
      'Track Cycle',
      'Welcome back,',
      'Today',
      'Upcoming',
      'Past',

      // Common actions
      'Add', 'Remove', 'Update', 'Submit', 'Confirm', 'Close', 'Done',
      'Loading...', 'Success', 'Error', 'Warning', 'Search', 'Filter',

      // Medical terms
      'Consultation', 'Emergency', 'Vaccination', 'Family Planning',
      'Prenatal Care', 'Postnatal Care', 'Health Screening', 'Follow Up',
    ];

    // Translate in batches to avoid overwhelming the API
    for (int i = 0; i < commonStrings.length; i += 5) {
      final batch = commonStrings.skip(i).take(5).toList();

      for (final text in batch) {
        await translateText(text, targetLang: languageCode);

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Save cached translations to SharedPreferences
  Future<void> _saveCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_translationsKey}_${state.currentLanguage}';

      // Convert translations map to query string format for storage
      final queryString = state.translations.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      await prefs.setString(cacheKey, queryString);
    } catch (e) {
      debugPrint('Error saving cached translations: $e');
    }
  }

  /// Clear all cached translations
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_translationsKey),
      );

      for (final key in keys) {
        await prefs.remove(key);
      }

      state = state.copyWith(translations: {});
      debugPrint('Translation cache cleared');
    } catch (e) {
      debugPrint('Error clearing translation cache: $e');
    }
  }

  /// Get translation statistics
  Map<String, dynamic> getStats() {
    return {
      'currentLanguage': state.currentLanguage,
      'cachedTranslations': state.translations.length,
      'isLoading': state.isLoading,
      'hasError': state.error != null,
    };
  }

  /// Check if a text is already translated
  bool isTranslated(String text) {
    final cacheKey = '${text}_${state.currentLanguage}';
    return state.translations.containsKey(cacheKey);
  }

  /// Get available languages
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'rw', 'name': 'Kinyarwanda', 'flag': '🇷🇼'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
      {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    ];
  }
}

/// Global translation provider
final globalTranslationProvider =
    StateNotifierProvider<GlobalTranslationNotifier, GlobalTranslationState>(
      (ref) => GlobalTranslationNotifier(),
    );

/// Helper providers
final currentLanguageProvider = Provider<String>((ref) {
  return ref.watch(globalTranslationProvider).currentLanguage;
});

final isTranslationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(globalTranslationProvider).isLoading;
});

final translationErrorProvider = Provider<String?>((ref) {
  return ref.watch(globalTranslationProvider).error;
});

final availableLanguagesProvider = Provider<List<Map<String, String>>>((ref) {
  return ref.read(globalTranslationProvider.notifier).getAvailableLanguages();
});
