import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/unified_language_provider.dart';
import '../services/hybrid_translation_service.dart';

/// Auto-translating widget that updates when language changes
class AutoTranslateWidget extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const AutoTranslateWidget(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  @override
  ConsumerState<AutoTranslateWidget> createState() => _AutoTranslateWidgetState();
}

class _AutoTranslateWidgetState extends ConsumerState<AutoTranslateWidget> {
  String? _translatedText;
  String? _lastLanguage;
  bool _isTranslating = false;

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(unifiedLanguageProvider);
    
    // Check if we need to translate
    if (currentLanguage != _lastLanguage) {
      _lastLanguage = currentLanguage;
      _translateText(currentLanguage);
    }

    return Text(
      _translatedText ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }

  Future<void> _translateText(String languageCode) async {
    if (languageCode == 'en') {
      setState(() {
        _translatedText = widget.text;
      });
      return;
    }

    if (_isTranslating) return;
    
    setState(() {
      _isTranslating = true;
    });

    try {
      final translationService = HybridTranslationService.instance;
      final translated = await translationService.translateText(
        widget.text,
        languageCode,
        null,
      );
      
      if (mounted && _lastLanguage == languageCode) {
        setState(() {
          _translatedText = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = widget.text; // Fallback to original
          _isTranslating = false;
        });
      }
    }
  }
}

/// Extension to make any string auto-translatable
extension AutoTranslateExtension on String {
  /// Convert string to auto-translating widget
  Widget at({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool softWrap = true,
  }) {
    return AutoTranslateWidget(
      this,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Global app translator that translates entire screens
class GlobalAppTranslator extends ConsumerWidget {
  final Widget child;
  final List<String> textsToTranslate;

  const GlobalAppTranslator({
    super.key,
    required this.child,
    this.textsToTranslate = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(unifiedLanguageProvider);
    
    // Pre-translate common texts when language changes
    if (currentLanguage != 'en' && textsToTranslate.isNotEmpty) {
      _preTranslateTexts(currentLanguage);
    }

    return child;
  }

  Future<void> _preTranslateTexts(String languageCode) async {
    final translationService = HybridTranslationService.instance;
    
    // Translate texts in background
    for (final text in textsToTranslate) {
      try {
        await translationService.translateText(text, languageCode, null);
      } catch (e) {
        // Ignore errors, fallback will handle it
      }
    }
  }
}

/// Language switcher button for easy access
class QuickLanguageSwitcher extends ConsumerWidget {
  final bool showLabel;
  final Color? iconColor;
  final double? iconSize;

  const QuickLanguageSwitcher({
    super.key,
    this.showLabel = false,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(unifiedLanguageProvider);
    final languageNotifier = ref.read(unifiedLanguageProvider.notifier);

    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            color: iconColor ?? Theme.of(context).iconTheme.color,
            size: iconSize ?? 24,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              currentLanguage.toUpperCase(),
              style: TextStyle(
                color: iconColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      onSelected: (languageCode) async {
        await languageNotifier.changeLanguage(languageCode);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language changed to ${_getLanguageName(languageCode)}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        _buildLanguageMenuItem('en', '🇺🇸', 'English', currentLanguage),
        _buildLanguageMenuItem('fr', '🇫🇷', 'Français', currentLanguage),
        _buildLanguageMenuItem('rw', '🇷🇼', 'Kinyarwanda', currentLanguage),
        _buildLanguageMenuItem('es', '🇪🇸', 'Español', currentLanguage),
        _buildLanguageMenuItem('de', '🇩🇪', 'Deutsch', currentLanguage),
      ],
    );
  }

  PopupMenuItem<String> _buildLanguageMenuItem(
    String code,
    String flag,
    String name,
    String currentLanguage,
  ) {
    final isSelected = code == currentLanguage;
    
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16),
          ],
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'fr': return 'Français';
      case 'rw': return 'Kinyarwanda';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      default: return code.toUpperCase();
    }
  }
}

/// Translation status indicator
class TranslationStatus extends ConsumerWidget {
  const TranslationStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(unifiedLanguageProvider);
    
    if (currentLanguage == 'en') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.translate,
            size: 12,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            currentLanguage.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Batch translator for multiple texts
class BatchTranslator {
  static final Map<String, Map<String, String>> _cache = {};
  
  static Future<void> preTranslateCommonTexts(String languageCode) async {
    if (languageCode == 'en') return;
    
    final commonTexts = [
      // Navigation
      'Home', 'Health', 'Education', 'Community', 'Profile',
      'Settings', 'Back', 'Next', 'Cancel', 'Save', 'Delete', 'Edit',
      
      // Dashboard
      'Welcome back,', 'Quick Actions', 'Health Summary', 'Recent Activity',
      'Book Appointment', 'Track Cycle', 'Health Records', 'Learn', 'Find Clinics',
      
      // Appointments
      'My Appointments', 'Today', 'Upcoming', 'Past', 'All',
      'Consultation', 'Emergency', 'Follow Up', 'Vaccination',
      
      // Health
      'Medications', 'Active', 'Reminders', 'Side Effects',
      'Health Education', 'Featured', 'Categories', 'My Learning', 'Search',
      
      // Common actions
      'Add', 'Remove', 'Update', 'Submit', 'Confirm', 'Close', 'Done',
      'Loading...', 'Success', 'Error', 'Warning', 'Filter', 'Sort',
    ];

    final translationService = HybridTranslationService.instance;
    
    for (final text in commonTexts) {
      try {
        final translated = await translationService.translateText(
          text,
          languageCode,
          null,
        );
        
        _cache[languageCode] ??= {};
        _cache[languageCode]![text] = translated;
        
        // Small delay to avoid overwhelming the API
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        // Continue with next text if one fails
      }
    }
  }
  
  static String? getCachedTranslation(String text, String languageCode) {
    return _cache[languageCode]?[text];
  }
}
