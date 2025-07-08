import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_rw.dart';
import 'app_localizations_fr.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'rw', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'rw':
        return AppLocalizationsRw();
      case 'fr':
        return AppLocalizationsFr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('rw', ''), // Kinyarwanda
    Locale('fr', ''), // French
  ];
}
