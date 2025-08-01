import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/dynamic_translated_text.dart';
import '../../core/widgets/dynamic_language_selector.dart';
import '../../core/providers/dynamic_translation_provider.dart';
import '../../core/theme/app_colors.dart';

/// Demo screen showcasing LibreTranslate API integration
class LibreTranslateDemoScreen extends ConsumerStatefulWidget {
  const LibreTranslateDemoScreen({super.key});

  @override
  ConsumerState<LibreTranslateDemoScreen> createState() => _LibreTranslateDemoScreenState();
}

class _LibreTranslateDemoScreenState extends ConsumerState<LibreTranslateDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  String _customText = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(dynamicTranslationProvider);
    final translationNotifier = ref.read(dynamicTranslationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: 'LibreTranslate Demo'.trd(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: const [
          DynamicLanguageAppBarAction(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Status Card
            _buildServiceStatusCard(translationState, translationNotifier),
            
            const SizedBox(height: 24),

            // Language Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'Language Selection'.trd(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const DynamicLanguageSelector(
                      showServiceStatus: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sample Translations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'Sample Translations'.trd(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSampleTranslations(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Custom Text Translation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'Custom Text Translation'.trd(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: 'Enter text to translate'.trd(),
                        hintText: 'Type something in English...'.trd(),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          _customText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_customText.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            'Translation:'.trd(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _customText.trd(
                              style: const TextStyle(fontSize: 16),
                              showLoadingIndicator: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Batch Translation Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'Batch Translation Demo'.trd(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBatchTranslationDemo(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cache Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'Cache Statistics'.trd(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCacheStats(translationNotifier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const DynamicLanguageFAB(),
    );
  }

  Widget _buildServiceStatusCard(
    DynamicTranslationState state,
    DynamicTranslationNotifier notifier,
  ) {
    return Card(
      color: state.isServiceAvailable ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              state.isServiceAvailable ? Icons.cloud_done : Icons.cloud_off,
              color: state.isServiceAvailable ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (state.isServiceAvailable 
                    ? 'LibreTranslate Service Online' 
                    : 'LibreTranslate Service Offline').trd(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.isServiceAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  (state.isServiceAvailable 
                    ? 'Real-time translation available' 
                    : 'Using cached translations only').trd(
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => notifier.refreshServiceAvailability(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh status'.trd(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTranslations() {
    final sampleTexts = [
      'Welcome to our health app',
      'Book an appointment',
      'View your medical records',
      'Track your medications',
      'Emergency contact',
      'Health screening results',
      'Family planning consultation',
      'Vaccination schedule',
    ];

    return Column(
      children: sampleTexts.map((text) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original: $text',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                text.trd(
                  style: const TextStyle(fontSize: 16),
                  showLoadingIndicator: true,
                ),
              ],
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildBatchTranslationDemo() {
    final batchTexts = [
      'Save',
      'Cancel',
      'Delete',
      'Edit',
      'Refresh',
    ];

    return DynamicBatchTranslatedWidget(
      texts: batchTexts,
      loadingWidget: const Center(
        child: CircularProgressIndicator(),
      ),
      builder: (translatedTexts) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: translatedTexts.map((text) => 
            Chip(
              label: Text(text),
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ).toList(),
        );
      },
    );
  }

  Widget _buildCacheStats(DynamicTranslationNotifier notifier) {
    return FutureBuilder<Map<String, dynamic>>(
      future: notifier.getCacheStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final stats = snapshot.data!;
        return Column(
          children: [
            _buildStatRow('Cache Size', '${stats['cacheSize']} translations'),
            _buildStatRow('Current Language', stats['currentLanguage']),
            _buildStatRow('Service Status', stats['isServiceAvailable'] ? 'Online' : 'Offline'),
            _buildStatRow('Memory Cache', '${stats['memoryCache']} items'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await notifier.clearCache();
                setState(() {}); // Refresh stats
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: 'Clear Cache'.trd(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          label.trd(style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
