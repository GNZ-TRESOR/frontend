import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

/// Language state model
class LanguageState {
  final Locale locale;
  final bool isLoading;

  const LanguageState({required this.locale, this.isLoading = false});

  LanguageState copyWith({Locale? locale, bool? isLoading}) {
    return LanguageState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Language provider for managing app language
class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(const LanguageState(locale: Locale('en'))) {
    _loadSavedLanguage();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(AppConstants.languageKey) ?? 'en';

      // Force reset Kinyarwanda to English until MaterialLocalizations support is added
      if (languageCode == 'rw') {
        await prefs.setString(AppConstants.languageKey, 'en');
        state = state.copyWith(locale: const Locale('en'));
        debugPrint(
          'Reset Kinyarwanda language to English due to MaterialLocalizations support',
        );
        return;
      }

      // Validate language code
      if (_isValidLanguageCode(languageCode)) {
        state = state.copyWith(locale: Locale(languageCode));
      } else {
        // Reset to English if invalid language code
        await prefs.setString(AppConstants.languageKey, 'en');
        state = state.copyWith(locale: const Locale('en'));
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      // Keep default English if error occurs
    }
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    if (!_isValidLanguageCode(languageCode)) {
      debugPrint('Invalid language code: $languageCode');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, languageCode);

      // Update state
      state = state.copyWith(locale: Locale(languageCode), isLoading: false);

      debugPrint('Language changed to: $languageCode');
    } catch (e) {
      debugPrint('Error changing language: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Check if language code is valid
  bool _isValidLanguageCode(String code) {
    const supportedCodes = [
      'en',
      'fr',
    ]; // 'rw' temporarily disabled due to MaterialLocalizations support
    return supportedCodes.contains(code);
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
      default:
        return code;
    }
  }

  /// Get all supported languages
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
      // {'code': 'rw', 'name': 'Kinyarwanda', 'nativeName': 'Ikinyarwanda'}, // Temporarily disabled
    ];
  }
}

/// Language provider instance
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>(
  (ref) => LanguageNotifier(),
);

/// Helper provider to get current locale
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).locale;
});

/// Helper provider to check if language is loading
final isLanguageLoadingProvider = Provider<bool>((ref) {
  return ref.watch(languageProvider).isLoading;
});
