import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dynamic_translation_provider.dart';
import '../providers/unified_language_provider.dart';
import '../services/hybrid_translation_service.dart';

/// Widget that automatically translates text using LibreTranslate API
class DynamicTranslatedText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Widget? loadingWidget;
  final bool showLoadingIndicator;

  const DynamicTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.loadingWidget,
    this.showLoadingIndicator = false,
  });

  @override
  ConsumerState<DynamicTranslatedText> createState() =>
      _DynamicTranslatedTextState();
}

class _DynamicTranslatedTextState extends ConsumerState<DynamicTranslatedText> {
  String? _translatedText;
  bool _isLoading = false;
  String? _lastLanguage;

  @override
  void initState() {
    super.initState();
    // Delay translation to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _translateText();
    });
  }

  @override
  void didUpdateWidget(DynamicTranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translateText();
    }
  }

  void _translateText() async {
    final currentLanguage = ref.read(unifiedLanguageProvider);
    debugPrint('Translating "${widget.text}" to $currentLanguage');

    // Check if we need to retranslate
    if (_lastLanguage == currentLanguage && _translatedText != null) {
      return;
    }

    if (currentLanguage == 'en') {
      setState(() {
        _translatedText = widget.text;
        _isLoading = false;
        _lastLanguage = currentLanguage;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hybridService = HybridTranslationService.instance;
      final translation = await hybridService.translateText(
        widget.text,
        currentLanguage,
        context,
      );
      if (mounted) {
        debugPrint('Translation result: "${widget.text}" -> "$translation"');
        setState(() {
          _translatedText = translation;
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = widget.text; // Fallback to original text
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for language changes and rebuild when language changes
    final currentLanguage = ref.watch(unifiedLanguageProvider);

    // Trigger translation if language changed
    if (_lastLanguage != currentLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _translateText();
      });
    }

    // Show loading indicator if enabled and loading
    if (_isLoading && widget.showLoadingIndicator) {
      return widget.loadingWidget ??
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.style?.color ??
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black,
              ),
            ),
          );
    }

    return Text(
      _translatedText ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
    );
  }
}

/// Extension for easy translation of strings
extension DynamicStringTranslation on String {
  /// Convert this string to a DynamicTranslatedText widget
  Widget trd({
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Widget? loadingWidget,
    bool showLoadingIndicator = false,
  }) {
    return DynamicTranslatedText(
      this,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      loadingWidget: loadingWidget,
      showLoadingIndicator: showLoadingIndicator,
    );
  }
}

/// Batch translation widget for multiple texts
class DynamicBatchTranslatedWidget extends ConsumerStatefulWidget {
  final List<String> texts;
  final Widget Function(List<String> translatedTexts) builder;
  final Widget? loadingWidget;

  const DynamicBatchTranslatedWidget({
    super.key,
    required this.texts,
    required this.builder,
    this.loadingWidget,
  });

  @override
  ConsumerState<DynamicBatchTranslatedWidget> createState() =>
      _DynamicBatchTranslatedWidgetState();
}

class _DynamicBatchTranslatedWidgetState
    extends ConsumerState<DynamicBatchTranslatedWidget> {
  List<String>? _translatedTexts;
  bool _isLoading = false;
  String? _lastLanguage;

  @override
  void initState() {
    super.initState();
    _translateTexts();
  }

  @override
  void didUpdateWidget(DynamicBatchTranslatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.texts != widget.texts) {
      _translateTexts();
    }
  }

  void _translateTexts() async {
    final currentLanguage =
        ref.read(dynamicTranslationProvider).currentLanguage;

    // Check if we need to retranslate
    if (_lastLanguage == currentLanguage && _translatedTexts != null) {
      return;
    }

    if (currentLanguage == 'en') {
      setState(() {
        _translatedTexts = widget.texts;
        _isLoading = false;
        _lastLanguage = currentLanguage;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final translations = await ref
          .read(dynamicTranslationProvider.notifier)
          .translateBatch(widget.texts);
      if (mounted) {
        setState(() {
          _translatedTexts =
              widget.texts.map((text) => translations[text] ?? text).toList();
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedTexts = widget.texts; // Fallback to original texts
          _isLoading = false;
          _lastLanguage = currentLanguage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to language changes
    ref.listen<DynamicTranslationState>(dynamicTranslationProvider, (
      previous,
      next,
    ) {
      if (previous?.currentLanguage != next.currentLanguage) {
        _translateTexts();
      }
    });

    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    return widget.builder(_translatedTexts ?? widget.texts);
  }
}

/// Helper function to get translated text directly
Future<String> getTranslatedText(String text, WidgetRef ref) async {
  return await ref
      .read(dynamicTranslationProvider.notifier)
      .translateText(text);
}
