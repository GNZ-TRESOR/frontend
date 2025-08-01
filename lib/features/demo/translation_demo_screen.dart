import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/translated_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';

/// Demo screen to showcase automatic translation functionality
class TranslationDemoScreen extends ConsumerWidget {
  const TranslationDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: 'Translation Demo'.tr(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (languageCode) {
              languageNotifier.setLanguage(languageCode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem(
                value: 'fr',
                child: Text('Français'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                children: [
                  'Current Language'.tr(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageState.currentLocale.languageCode.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Basic UI Elements
            'Basic UI Elements'.tr(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDemoButton('Save'),
                _buildDemoButton('Cancel'),
                _buildDemoButton('Delete'),
                _buildDemoButton('Edit'),
                _buildDemoButton('Add'),
                _buildDemoButton('Search'),
                _buildDemoButton('Filter'),
                _buildDemoButton('Sort'),
                _buildDemoButton('Refresh'),
              ],
            ),

            const SizedBox(height: 24),

            // Health-specific terms
            'Health Terms'.tr(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDemoCard('Welcome back,'),
                _buildDemoCard('Let\'s track your health journey'),
                _buildDemoCard('Appointment Management'),
                _buildDemoCard('My Appointments'),
                _buildDemoCard('Health Overview'),
                _buildDemoCard('Total Records'),
                _buildDemoCard('Recent (30d)'),
              ],
            ),

            const SizedBox(height: 24),

            // Appointment types
            'Appointment Types'.tr(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDemoCard('Consultation'),
                _buildDemoCard('Family Planning'),
                _buildDemoCard('Prenatal Care'),
                _buildDemoCard('Postnatal Care'),
                _buildDemoCard('Vaccination'),
                _buildDemoCard('Health Screening'),
                _buildDemoCard('Follow Up'),
                _buildDemoCard('Emergency'),
                _buildDemoCard('Counseling'),
              ],
            ),

            const SizedBox(height: 24),

            // Status indicators
            'Status Indicators'.tr(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip('Scheduled', AppColors.primary),
                _buildStatusChip('Confirmed', AppColors.success),
                _buildStatusChip('Completed', AppColors.success),
                _buildStatusChip('Cancelled', AppColors.error),
                _buildStatusChip('Pending', AppColors.warning),
                _buildStatusChip('In Progress', AppColors.secondary),
              ],
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'Instructions'.tr(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  'Use the menu button in the top-right corner to switch between English and French. All text should automatically translate.'.tr(),
                  const SizedBox(height: 8),
                  'This demonstrates how the entire app can be automatically translated without changing any existing code.'.tr(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      child: text.tr(),
    );
  }

  Widget _buildDemoCard(String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: text.tr(
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.translate,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Chip(
      label: text.tr(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }
}
