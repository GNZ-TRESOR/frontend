import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/libre_translate_service.dart';
import '../services/hybrid_translation_service.dart';

/// State for dynamic translation
@immutable
class DynamicTranslationState {
  final String currentLanguage;
  final bool isTranslating;
  final Map<String, String> translationCache;
  final List<Map<String, String>> availableLanguages;
  final bool isServiceAvailable;

  const DynamicTranslationState({
    this.currentLanguage = 'en',
    this.isTranslating = false,
    this.translationCache = const {},
    this.availableLanguages = const [],
    this.isServiceAvailable = true,
  });

  DynamicTranslationState copyWith({
    String? currentLanguage,
    bool? isTranslating,
    Map<String, String>? translationCache,
    List<Map<String, String>>? availableLanguages,
    bool? isServiceAvailable,
  }) {
    return DynamicTranslationState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isTranslating: isTranslating ?? this.isTranslating,
      translationCache: translationCache ?? this.translationCache,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      isServiceAvailable: isServiceAvailable ?? this.isServiceAvailable,
    );
  }
}

/// Provider for dynamic translation using LibreTranslate
class DynamicTranslationNotifier
    extends StateNotifier<DynamicTranslationState> {
  static const String _languageKey = 'selected_language';
  final LibreTranslateService _translateService =
      LibreTranslateService.instance;
  final HybridTranslationService _hybridService =
      HybridTranslationService.instance;

  DynamicTranslationNotifier() : super(const DynamicTranslationState()) {
    _initialize();
  }

  /// Initialize the translation provider
  Future<void> _initialize() async {
    // Load saved language
    final savedLanguage = await _getSavedLanguage();

    // Check service availability
    final isAvailable = await _translateService.isServiceAvailable();

    // Load available languages (hybrid: LibreTranslate + Local)
    final languages = await _hybridService.getAllSupportedLanguages();

    state = state.copyWith(
      currentLanguage: savedLanguage,
      availableLanguages: languages,
      isServiceAvailable: isAvailable,
    );
  }

  /// Get saved language from SharedPreferences
  Future<String> _getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'en';
    } catch (e) {
      print('Error loading saved language: $e');
      return 'en';
    }
  }

  /// Save language to SharedPreferences
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// Change the current language
  Future<void> changeLanguage(String languageCode) async {
    if (state.currentLanguage == languageCode) return;

    state = state.copyWith(currentLanguage: languageCode);
    await _saveLanguage(languageCode);
  }

  /// Translate a single text
  Future<String> translateText(String text) async {
    if (state.currentLanguage == 'en' || text.trim().isEmpty) {
      return text;
    }

    // Check local cache first
    final cacheKey = '${state.currentLanguage}_$text';
    if (state.translationCache.containsKey(cacheKey)) {
      return state.translationCache[cacheKey]!;
    }

    try {
      state = state.copyWith(isTranslating: true);

      final translation = await _translateService.translateText(
        text,
        state.currentLanguage,
      );

      // Update cache
      final newCache = Map<String, String>.from(state.translationCache);
      newCache[cacheKey] = translation;

      state = state.copyWith(translationCache: newCache, isTranslating: false);

      return translation;
    } catch (e) {
      print('Translation error: $e');
      state = state.copyWith(isTranslating: false);
      return text; // Return original text on error
    }
  }

  /// Translate multiple texts in batch
  Future<Map<String, String>> translateBatch(List<String> texts) async {
    if (state.currentLanguage == 'en') {
      return {for (String text in texts) text: text};
    }

    try {
      state = state.copyWith(isTranslating: true);

      final translations = await _translateService.translateBatch(
        texts,
        state.currentLanguage,
      );

      // Update cache
      final newCache = Map<String, String>.from(state.translationCache);
      for (final entry in translations.entries) {
        final cacheKey = '${state.currentLanguage}_${entry.key}';
        newCache[cacheKey] = entry.value;
      }

      state = state.copyWith(translationCache: newCache, isTranslating: false);

      return translations;
    } catch (e) {
      print('Batch translation error: $e');
      state = state.copyWith(isTranslating: false);
      return {for (String text in texts) text: text};
    }
  }

  /// Clear translation cache
  Future<void> clearCache() async {
    await _translateService.clearCache();
    state = state.copyWith(translationCache: {});
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final cacheSize = await _translateService.getCacheSize();
    return {
      'cacheSize': cacheSize,
      'currentLanguage': state.currentLanguage,
      'isServiceAvailable': state.isServiceAvailable,
      'memoryCache': state.translationCache.length,
    };
  }

  /// Refresh service availability
  Future<void> refreshServiceAvailability() async {
    final isAvailable = await _translateService.isServiceAvailable();
    state = state.copyWith(isServiceAvailable: isAvailable);
  }

  /// Get language name by code
  String getLanguageName(String code) {
    final language = state.availableLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code.toUpperCase()},
    );
    return language['name'] ?? code.toUpperCase();
  }

  /// Get language flag emoji
  String getLanguageFlag(String code) {
    const flags = {
      'en': '🇺🇸',
      'fr': '🇫🇷',
      'es': '🇪🇸',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ru': '🇷🇺',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'zh': '🇨🇳',
      'ar': '🇸🇦',
      'hi': '🇮🇳',
      'nl': '🇳🇱',
      'sv': '🇸🇪',
      'no': '🇳🇴',
      'da': '🇩🇰',
      'fi': '🇫🇮',
      'pl': '🇵🇱',
      'tr': '🇹🇷',
      'uk': '🇺🇦',
      'cs': '🇨🇿',
      'hu': '🇭🇺',
      'ro': '🇷🇴',
      'bg': '🇧🇬',
      'hr': '🇭🇷',
      'sk': '🇸🇰',
      'sl': '🇸🇮',
      'et': '🇪🇪',
      'lv': '🇱🇻',
      'lt': '🇱🇹',
      'mt': '🇲🇹',
      'ga': '🇮🇪',
      'cy': '🏴󠁧󠁢󠁷󠁬󠁳󠁿',
    };
    return flags[code] ?? '🌐';
  }
}

/// Provider instance
final dynamicTranslationProvider =
    StateNotifierProvider<DynamicTranslationNotifier, DynamicTranslationState>(
      (ref) => DynamicTranslationNotifier(),
    );

/// Helper function to translate text (for easy access)
Future<String> translateText(String text, WidgetRef ref) async {
  return await ref
      .read(dynamicTranslationProvider.notifier)
      .translateText(text);
}
