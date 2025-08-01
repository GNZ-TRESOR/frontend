import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/language_provider.dart';
import '../theme/app_colors.dart';

/// Language selector dropdown widget
class LanguageSelector extends ConsumerWidget {
  final bool showLabel;
  final bool isCompact;
  final Color? backgroundColor;
  final Color? textColor;

  const LanguageSelector({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    final supportedLanguages = languageNotifier.getSupportedLanguages();

    if (isCompact) {
      return _buildCompactSelector(
        context,
        languageState,
        languageNotifier,
        supportedLanguages,
      );
    }

    return _buildFullSelector(
      context,
      languageState,
      languageNotifier,
      supportedLanguages,
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    LanguageState languageState,
    LanguageNotifier languageNotifier,
    List<Map<String, String>> supportedLanguages,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: languageState.locale.languageCode,
          isDense: true,
          icon: Icon(
            Icons.language,
            size: 16,
            color: textColor ?? AppColors.textSecondary,
          ),
          style: TextStyle(
            color: textColor ?? AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: supportedLanguages.map((language) {
            return DropdownMenuItem<String>(
              value: language['code'],
              child: Text(
                language['code']!.toUpperCase(),
                style: TextStyle(
                  color: textColor ?? AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
          onChanged: languageState.isLoading
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    languageNotifier.changeLanguage(newValue);
                  }
                },
        ),
      ),
    );
  }

  Widget _buildFullSelector(
    BuildContext context,
    LanguageState languageState,
    LanguageNotifier languageNotifier,
    List<Map<String, String>> supportedLanguages,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 20,
                  color: textColor ?? AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Language',
                  style: TextStyle(
                    color: textColor ?? AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<String>(
            value: languageState.locale.languageCode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: languageState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            style: TextStyle(
              color: textColor ?? AppColors.textPrimary,
              fontSize: 14,
            ),
            items: supportedLanguages.map((language) {
              return DropdownMenuItem<String>(
                value: language['code'],
                child: Row(
                  children: [
                    _getLanguageFlag(language['code']!),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            language['nativeName']!,
                            style: TextStyle(
                              color: textColor ?? AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            language['name']!,
                            style: TextStyle(
                              color: textColor ?? AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: languageState.isLoading
                ? null
                : (String? newValue) {
                    if (newValue != null) {
                      languageNotifier.changeLanguage(newValue);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _getLanguageFlag(String languageCode) {
    String flag;
    switch (languageCode) {
      case 'en':
        flag = '🇺🇸';
        break;
      case 'fr':
        flag = '🇫🇷';
        break;
      case 'rw':
        flag = '🇷🇼';
        break;
      default:
        flag = '🌐';
    }

    return Text(
      flag,
      style: const TextStyle(fontSize: 20),
    );
  }
}

/// Simple language selector for app bars and menus
class SimpleLanguageSelector extends ConsumerWidget {
  const SimpleLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: () => _showLanguageDialog(context, ref),
      tooltip: 'Select Language',
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.language, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Select Language'),
          ],
        ),
        content: const LanguageSelector(showLabel: false),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
