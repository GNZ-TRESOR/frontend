import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_provider.dart';
import 'dynamic_translation_provider.dart';

/// Unified language provider that synchronizes both language systems
class UnifiedLanguageNotifier extends StateNotifier<String> {
  static const String _languageKey = 'unified_language';

  final Ref _ref;

  UnifiedLanguageNotifier(this._ref) : super('en') {
    _initialize();
  }

  /// Initialize and sync both providers
  Future<void> _initialize() async {
    final savedLanguage = await _getSavedLanguage();
    state = savedLanguage;

    // Sync both providers
    await _syncProviders(savedLanguage);
  }

  /// Get saved language from SharedPreferences
  Future<String> _getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'en';
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      return 'en';
    }
  }

  /// Save language to SharedPreferences
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  /// Change language and sync all providers
  Future<void> changeLanguage(String languageCode) async {
    if (state == languageCode) return;

    debugPrint('UnifiedLanguageProvider: Changing language to $languageCode');

    // Update state
    state = languageCode;

    // Save to preferences
    await _saveLanguage(languageCode);

    // Sync both providers
    await _syncProviders(languageCode);

    debugPrint('UnifiedLanguageProvider: Language changed to $languageCode');
  }

  /// Sync both language providers
  Future<void> _syncProviders(String languageCode) async {
    try {
      // Sync original language provider (for MaterialApp locale)
      final languageNotifier = _ref.read(languageProvider.notifier);
      await languageNotifier.changeLanguage(languageCode);

      // Sync dynamic translation provider (for LibreTranslate)
      final dynamicNotifier = _ref.read(dynamicTranslationProvider.notifier);
      await dynamicNotifier.changeLanguage(languageCode);

      debugPrint('Language synchronized to: $languageCode');
    } catch (e) {
      debugPrint('Error syncing language providers: $e');
    }
  }

  /// Get language display name
  String getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'rw':
        return 'Kinyarwanda';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      default:
        return code.toUpperCase();
    }
  }

  /// Get language flag emoji
  String getLanguageFlag(String code) {
    const flags = {
      'en': '🇺🇸',
      'fr': '🇫🇷',
      'rw': '🇷🇼',
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
    };
    return flags[code] ?? '🌐';
  }

  /// Check if language is supported by LibreTranslate
  bool isLibreTranslateSupported(String code) {
    const supported = [
      'en',
      'ar',
      'az',
      'zh',
      'cs',
      'nl',
      'eo',
      'fi',
      'fr',
      'de',
      'el',
      'he',
      'hi',
      'hu',
      'id',
      'ga',
      'it',
      'ja',
      'ko',
      'fa',
      'pl',
      'pt',
      'ru',
      'sk',
      'es',
      'sv',
      'tr',
      'uk',
    ];
    return supported.contains(code);
  }

  /// Check if language is supported locally
  bool isLocallySupported(String code) {
    return code == 'rw'; // Kinyarwanda supported via .arb files
  }

  /// Get all available languages
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

  /// Get translation method for a language
  String getTranslationMethod(String code) {
    if (isLibreTranslateSupported(code)) {
      return 'LibreTranslate API';
    } else if (isLocallySupported(code)) {
      return 'Local .arb files';
    } else {
      return 'Not supported';
    }
  }
}

/// Unified language provider instance
final unifiedLanguageProvider =
    StateNotifierProvider<UnifiedLanguageNotifier, String>(
      (ref) => UnifiedLanguageNotifier(ref),
    );

/// Helper provider to get current language display name
final currentLanguageDisplayProvider = Provider<String>((ref) {
  final currentLang = ref.watch(unifiedLanguageProvider);
  final notifier = ref.read(unifiedLanguageProvider.notifier);
  return notifier.getLanguageDisplayName(currentLang);
});

/// Helper provider to get current language flag
final currentLanguageFlagProvider = Provider<String>((ref) {
  final currentLang = ref.watch(unifiedLanguageProvider);
  final notifier = ref.read(unifiedLanguageProvider.notifier);
  return notifier.getLanguageFlag(currentLang);
});

/// Helper provider to get available languages
final availableLanguagesProvider = Provider<List<Map<String, String>>>((ref) {
  final notifier = ref.read(unifiedLanguageProvider.notifier);
  return notifier.getAvailableLanguages();
});

/// Helper provider to check if current language is supported by LibreTranslate
final isCurrentLanguageLibreTranslateSupportedProvider = Provider<bool>((ref) {
  final currentLang = ref.watch(unifiedLanguageProvider);
  final notifier = ref.read(unifiedLanguageProvider.notifier);
  return notifier.isLibreTranslateSupported(currentLang);
});

/// Helper provider to get translation method for current language
final currentLanguageTranslationMethodProvider = Provider<String>((ref) {
  final currentLang = ref.watch(unifiedLanguageProvider);
  final notifier = ref.read(unifiedLanguageProvider.notifier);
  return notifier.getTranslationMethod(currentLang);
});
