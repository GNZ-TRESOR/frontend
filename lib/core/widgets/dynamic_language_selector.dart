import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dynamic_translation_provider.dart';
import '../theme/app_colors.dart';

/// Dynamic language selector widget with LibreTranslate integration
class DynamicLanguageSelector extends ConsumerWidget {
  final bool showLabel;
  final bool isCompact;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showFlags;
  final bool showServiceStatus;

  const DynamicLanguageSelector({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
    this.backgroundColor,
    this.textColor,
    this.showFlags = true,
    this.showServiceStatus = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(dynamicTranslationProvider);
    final translationNotifier = ref.read(dynamicTranslationProvider.notifier);

    if (isCompact) {
      return _buildCompactSelector(context, translationState, translationNotifier);
    }

    return _buildFullSelector(context, translationState, translationNotifier);
  }

  Widget _buildCompactSelector(
    BuildContext context,
    DynamicTranslationState state,
    DynamicTranslationNotifier notifier,
  ) {
    return PopupMenuButton<String>(
      onSelected: (languageCode) {
        notifier.changeLanguage(languageCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: textColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlags) ...[
              Text(
                notifier.getLanguageFlag(state.currentLanguage),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              state.currentLanguage.toUpperCase(),
              style: TextStyle(
                color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
              size: 16,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => state.availableLanguages.map((language) {
        final code = language['code']!;
        final name = language['name']!;
        final isSelected = code == state.currentLanguage;

        return PopupMenuItem<String>(
          value: code,
          child: Row(
            children: [
              if (showFlags) ...[
                Text(
                  notifier.getLanguageFlag(code),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 16,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFullSelector(
    BuildContext context,
    DynamicTranslationState state,
    DynamicTranslationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            'Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.currentLanguage,
              isExpanded: true,
              onChanged: (languageCode) {
                if (languageCode != null) {
                  notifier.changeLanguage(languageCode);
                }
              },
              items: state.availableLanguages.map((language) {
                final code = language['code']!;
                final name = language['name']!;

                return DropdownMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      if (showFlags) ...[
                        Text(
                          notifier.getLanguageFlag(code),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (showServiceStatus) ...[
          const SizedBox(height: 8),
          _buildServiceStatus(context, state, notifier),
        ],
      ],
    );
  }

  Widget _buildServiceStatus(
    BuildContext context,
    DynamicTranslationState state,
    DynamicTranslationNotifier notifier,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: state.isServiceAvailable ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            state.isServiceAvailable 
              ? 'Translation service online'
              : 'Translation service offline',
            style: TextStyle(
              fontSize: 12,
              color: state.isServiceAvailable ? Colors.green : Colors.red,
            ),
          ),
        ),
        if (state.isTranslating) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
        IconButton(
          onPressed: () => notifier.refreshServiceAvailability(),
          icon: const Icon(Icons.refresh, size: 16),
          tooltip: 'Refresh service status',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      ],
    );
  }
}

/// Floating action button for quick language switching
class DynamicLanguageFAB extends ConsumerWidget {
  final VoidCallback? onPressed;

  const DynamicLanguageFAB({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(dynamicTranslationProvider);
    final translationNotifier = ref.read(dynamicTranslationProvider.notifier);

    return FloatingActionButton.small(
      onPressed: onPressed ?? () => _showLanguageDialog(context, ref),
      backgroundColor: AppColors.primary,
      child: Text(
        translationNotifier.getLanguageFlag(translationState.currentLanguage),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: DynamicLanguageSelector(
            showLabel: false,
            showServiceStatus: true,
          ),
        ),
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

/// App bar action for language selection
class DynamicLanguageAppBarAction extends ConsumerWidget {
  const DynamicLanguageAppBarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(dynamicTranslationProvider);
    final translationNotifier = ref.read(dynamicTranslationProvider.notifier);

    return PopupMenuButton<String>(
      onSelected: (languageCode) {
        translationNotifier.changeLanguage(languageCode);
      },
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translationNotifier.getLanguageFlag(translationState.currentLanguage),
            style: const TextStyle(fontSize: 18),
          ),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      itemBuilder: (context) => translationState.availableLanguages.map((language) {
        final code = language['code']!;
        final name = language['name']!;
        final isSelected = code == translationState.currentLanguage;

        return PopupMenuItem<String>(
          value: code,
          child: Row(
            children: [
              Text(
                translationNotifier.getLanguageFlag(code),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(name)),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 16,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
