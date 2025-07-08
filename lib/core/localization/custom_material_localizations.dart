import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom MaterialLocalizations delegate that handles Kinyarwanda
/// by falling back to English for Material components
class CustomMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CustomMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support English, French, and Kinyarwanda (using English fallback)
    return ['en', 'fr', 'rw'].contains(locale.languageCode);
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // For Kinyarwanda, use English Material localizations
    if (locale.languageCode == 'rw') {
      return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
    }

    // For other locales, use the global delegate
    return GlobalMaterialLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(CustomMaterialLocalizationsDelegate old) => false;
}

/// Custom CupertinoLocalizations delegate that handles Kinyarwanda
/// by falling back to English for Cupertino components
class CustomCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const CustomCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support English, French, and Kinyarwanda (using English fallback)
    return ['en', 'fr', 'rw'].contains(locale.languageCode);
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    // For Kinyarwanda, use English Cupertino localizations
    if (locale.languageCode == 'rw') {
      return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
    }

    // For other locales, use the global delegate
    return GlobalCupertinoLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(CustomCupertinoLocalizationsDelegate old) => false;
}
