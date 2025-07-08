import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale(
    'en',
    '',
  ); // Default to English to avoid warnings

  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'rw',
      name: 'Kinyarwanda',
      nativeName: 'Ikinyarwanda',
      flag: '🇷🇼',
    ),
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
  ];

  LanguageService() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage, '');
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, keep default language
      debugPrint('Failed to load saved language: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      _currentLocale = Locale(languageCode, '');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
  }

  LanguageOption get currentLanguageOption {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  static LanguageOption getLanguageOption(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
