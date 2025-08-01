import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/global_translation_provider.dart';

/// Global translation widget that automatically translates text when language changes
class GlobalTranslatedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final double? textScaleFactor;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const GlobalTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(globalTranslationProvider);
    final translationNotifier = ref.read(globalTranslationProvider.notifier);

    // If English, return original text
    if (translationState.currentLanguage == 'en') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textScaleFactor: textScaleFactor,
        locale: locale,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      );
    }

    // Check if translation is cached
    final cacheKey = '${text}_${translationState.currentLanguage}';
    final cachedTranslation = translationState.translations[cacheKey];

    if (cachedTranslation != null) {
      return Text(
        cachedTranslation,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textScaleFactor: textScaleFactor,
        locale: locale,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      );
    }

    // If not cached, show original text and translate in background
    Future.microtask(() async {
      await translationNotifier.translateText(text);
    });

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Extension to make any string globally translatable
extension GlobalTranslationExtension on String {
  /// Convert string to globally translated widget
  Widget gt({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool softWrap = true,
    double? textScaleFactor,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return GlobalTranslatedText(
      this,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  /// Get translated string asynchronously
  Future<String> translate(WidgetRef ref, {String? targetLang}) async {
    final notifier = ref.read(globalTranslationProvider.notifier);
    return await notifier.translateText(this, targetLang: targetLang);
  }
}

/// Global translation builder for complex widgets
class GlobalTranslationBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, String Function(String) translate) builder;

  const GlobalTranslationBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(globalTranslationProvider);
    final translationNotifier = ref.read(globalTranslationProvider.notifier);

    String translate(String text) {
      // If English, return original
      if (translationState.currentLanguage == 'en') return text;

      // Check cache
      final cacheKey = '${text}_${translationState.currentLanguage}';
      final cached = translationState.translations[cacheKey];
      
      if (cached != null) return cached;

      // Translate in background
      Future.microtask(() async {
        await translationNotifier.translateText(text);
      });

      return text; // Return original while translating
    }

    return builder(context, translate);
  }
}

/// Language switcher widget
class LanguageSwitcher extends ConsumerWidget {
  final bool showFlags;
  final bool compact;
  final Color? backgroundColor;
  final Color? textColor;

  const LanguageSwitcher({
    super.key,
    this.showFlags = true,
    this.compact = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(globalTranslationProvider);
    final translationNotifier = ref.read(globalTranslationProvider.notifier);
    final availableLanguages = ref.watch(availableLanguagesProvider);

    if (compact) {
      return PopupMenuButton<String>(
        icon: Icon(
          Icons.language,
          color: textColor ?? Theme.of(context).iconTheme.color,
        ),
        onSelected: (languageCode) {
          translationNotifier.changeLanguage(languageCode);
        },
        itemBuilder: (context) => availableLanguages.map((lang) {
          final isSelected = lang['code'] == translationState.currentLanguage;
          return PopupMenuItem<String>(
            value: lang['code'],
            child: Row(
              children: [
                if (showFlags) ...[
                  Text(lang['flag']!),
                  const SizedBox(width: 8),
                ],
                Text(
                  lang['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: translationState.currentLanguage,
          isDense: true,
          onChanged: translationState.isLoading
              ? null
              : (languageCode) {
                  if (languageCode != null) {
                    translationNotifier.changeLanguage(languageCode);
                  }
                },
          items: availableLanguages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang['code'],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showFlags) ...[
                    Text(lang['flag']!),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    lang['name']!,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Translation status indicator
class TranslationStatusIndicator extends ConsumerWidget {
  const TranslationStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(globalTranslationProvider);
    final translationNotifier = ref.read(globalTranslationProvider.notifier);

    if (!translationState.isLoading && translationState.error == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: translationState.error != null
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (translationState.isLoading)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (translationState.error != null)
            const Icon(Icons.error, size: 12, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            translationState.isLoading
                ? 'Translating...'
                : 'Translation Error',
            style: const TextStyle(fontSize: 10),
          ),
          if (translationState.error != null)
            GestureDetector(
              onTap: () {
                // Retry translation
                translationNotifier.changeLanguage(translationState.currentLanguage);
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.refresh, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}
