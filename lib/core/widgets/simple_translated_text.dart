import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/unified_language_provider.dart';
import '../services/hybrid_translation_service.dart';

/// Simple translated text widget that rebuilds when language changes
class SimpleTranslatedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SimpleTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(unifiedLanguageProvider);

    // Get translated text
    String translatedText = text;
    if (currentLanguage != 'en') {
      final hybridService = HybridTranslationService.instance;
      // Use synchronous mock translation for now
      translatedText = hybridService.getMockTranslation(text, currentLanguage);
      debugPrint(
        'Simple translation: "$text" -> "$translatedText" (lang: $currentLanguage)',
      );
    }

    return Text(
      translatedText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Extension for easy translation
extension SimpleStringTranslation on String {
  /// Convert to simple translated text widget
  Widget str({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return SimpleTranslatedText(
      this,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
