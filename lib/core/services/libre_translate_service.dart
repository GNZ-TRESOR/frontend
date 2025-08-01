import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for translating text using LibreTranslate API
class LibreTranslateService {
  static const String _baseUrl = 'https://libretranslate.de/translate';
  static const String _cachePrefix = 'translation_cache_';
  static const Duration _cacheExpiry = Duration(days: 7); // Cache for 7 days

  static LibreTranslateService? _instance;
  static LibreTranslateService get instance =>
      _instance ??= LibreTranslateService._();

  LibreTranslateService._();

  /// Translate text from source language to target language
  /// [text] - Text to translate
  /// [targetLang] - Target language code (e.g., 'fr', 'es', 'de')
  /// [sourceLang] - Source language code (default: 'en')
  Future<String> translateText(
    String text,
    String targetLang, {
    String sourceLang = 'en',
  }) async {
    // Return original text if target is same as source
    if (targetLang == sourceLang) {
      return text;
    }

    // Check cache first
    final cachedTranslation = await _getCachedTranslation(
      text,
      targetLang,
      sourceLang,
    );
    if (cachedTranslation != null) {
      return cachedTranslation;
    }

    try {
      // Make API request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['translatedText'] as String;

        // Cache the translation
        await _cacheTranslation(text, targetLang, sourceLang, translatedText);

        return translatedText;
      } else {
        print(
          'Translation API error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Translation error: $e');
      rethrow; // Re-throw to trigger fallback
    }
  }

  /// Batch translate multiple texts
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLang, {
    String sourceLang = 'en',
  }) async {
    final results = <String, String>{};

    // Process in parallel but limit concurrent requests
    const batchSize = 5;
    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();
      final futures = batch.map(
        (text) => translateText(
          text,
          targetLang,
          sourceLang: sourceLang,
        ).then((translation) => MapEntry(text, translation)),
      );

      final batchResults = await Future.wait(futures);
      for (final entry in batchResults) {
        results[entry.key] = entry.value;
      }
    }

    return results;
  }

  /// Get cached translation if available and not expired
  Future<String?> _getCachedTranslation(
    String text,
    String targetLang,
    String sourceLang,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(text, targetLang, sourceLang);
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        final timestamp = DateTime.parse(data['timestamp']);
        final translation = data['translation'] as String;

        // Check if cache is still valid
        if (DateTime.now().difference(timestamp) < _cacheExpiry) {
          return translation;
        } else {
          // Remove expired cache
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      print('Cache read error: $e');
    }

    return null;
  }

  /// Cache translation with timestamp
  Future<void> _cacheTranslation(
    String text,
    String targetLang,
    String sourceLang,
    String translation,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(text, targetLang, sourceLang);
      final cacheData = jsonEncode({
        'translation': translation,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(cacheKey, cacheData);
    } catch (e) {
      print('Cache write error: $e');
    }
  }

  /// Generate cache key for translation
  String _getCacheKey(String text, String targetLang, String sourceLang) {
    final key = '${sourceLang}_${targetLang}_${text.hashCode}';
    return '$_cachePrefix$key';
  }

  /// Clear all cached translations
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  /// Get cache size (number of cached translations)
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs
          .getKeys()
          .where((key) => key.startsWith(_cachePrefix))
          .length;
    } catch (e) {
      print('Cache size error: $e');
      return 0;
    }
  }

  /// Check if LibreTranslate service is available
  Future<bool> isServiceAvailable() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://libretranslate.de/languages'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Service availability check error: $e');
      return false;
    }
  }

  /// Get available languages from LibreTranslate
  Future<List<Map<String, String>>> getAvailableLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('https://libretranslate.de/languages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> languages = jsonDecode(response.body);
        final supportedLanguages =
            languages
                .map(
                  (lang) => {
                    'code': lang['code'] as String,
                    'name': lang['name'] as String,
                  },
                )
                .toList();

        // Check if Kinyarwanda is supported
        final hasKinyarwanda = supportedLanguages.any(
          (lang) => lang['code'] == 'rw',
        );
        print('LibreTranslate supports Kinyarwanda: $hasKinyarwanda');
        print(
          'Supported languages: ${supportedLanguages.map((l) => l['code']).join(', ')}',
        );

        return supportedLanguages;
      }
    } catch (e) {
      print('Get languages error: $e');
    }

    // Return default languages if API fails (based on LibreTranslate's actual support)
    return [
      {'code': 'en', 'name': 'English'},
      {'code': 'ar', 'name': 'Arabic'},
      {'code': 'az', 'name': 'Azerbaijani'},
      {'code': 'zh', 'name': 'Chinese'},
      {'code': 'cs', 'name': 'Czech'},
      {'code': 'nl', 'name': 'Dutch'},
      {'code': 'eo', 'name': 'Esperanto'},
      {'code': 'fi', 'name': 'Finnish'},
      {'code': 'fr', 'name': 'French'},
      {'code': 'de', 'name': 'German'},
      {'code': 'el', 'name': 'Greek'},
      {'code': 'he', 'name': 'Hebrew'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'hu', 'name': 'Hungarian'},
      {'code': 'id', 'name': 'Indonesian'},
      {'code': 'ga', 'name': 'Irish'},
      {'code': 'it', 'name': 'Italian'},
      {'code': 'ja', 'name': 'Japanese'},
      {'code': 'ko', 'name': 'Korean'},
      {'code': 'fa', 'name': 'Persian'},
      {'code': 'pl', 'name': 'Polish'},
      {'code': 'pt', 'name': 'Portuguese'},
      {'code': 'ru', 'name': 'Russian'},
      {'code': 'sk', 'name': 'Slovak'},
      {'code': 'es', 'name': 'Spanish'},
      {'code': 'sv', 'name': 'Swedish'},
      {'code': 'tr', 'name': 'Turkish'},
      {'code': 'uk', 'name': 'Ukrainian'},
      // Note: Kinyarwanda (rw) is NOT supported by LibreTranslate as of 2024
    ];
  }
}
