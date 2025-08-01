import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/tts_button.dart';
import '../core/utils/tts_helpers.dart';
import '../core/theme/app_colors.dart';

/// Examples of TTS integration in different scenarios
/// Copy these patterns to integrate TTS into your existing widgets
class TTSIntegrationExamples extends ConsumerWidget {
  const TTSIntegrationExamples({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS Integration Examples'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Simple text with inline TTS button
            _buildExample1(),
            const SizedBox(height: 24),

            // Example 2: Card with floating TTS button
            _buildExample2(),
            const SizedBox(height: 24),

            // Example 3: List item with TTS
            _buildExample3(),
            const SizedBox(height: 24),

            // Example 4: Using TTSText widget
            _buildExample4(),
            const SizedBox(height: 24),

            // Example 5: Custom TTS integration
            _buildExample5(),
            const SizedBox(height: 24),

            // Example 6: TTS Control Panel
            _buildExample6(),
          ],
        ),
      ),
    );
  }

  /// Example 1: Simple text with inline TTS button
  Widget _buildExample1() {
    const text =
        'Welcome to Ubuzima Family Planning Platform. This is an example of text that can be read aloud.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Example 1: Inline TTS Button',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(text, style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 8),
                TTSInlineButton(
                  textToSpeak: text,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Code: Add TTSInlineButton next to any text',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 2: Card with floating TTS button
  Widget _buildExample2() {
    final cardText = TTSHelpers.createReadableText(
      title: 'Health Tip of the Day',
      content:
          'Regular exercise and a balanced diet are essential for reproductive health. Aim for at least 30 minutes of moderate exercise daily.',
      bulletPoints: [
        'Walk for 30 minutes daily',
        'Eat plenty of fruits and vegetables',
        'Stay hydrated',
        'Get adequate sleep',
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Example 2: Card with TTS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                TTSFloatingButton(textToSpeak: cardText, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Health Tip of the Day',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Regular exercise and a balanced diet are essential for reproductive health. Aim for at least 30 minutes of moderate exercise daily.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Code: Use TTSFloatingButton in card headers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 3: List item with TTS
  Widget _buildExample3() {
    final appointments = [
      'Consultation appointment on Monday at 9:00 AM with Dr. Smith',
      'Follow-up visit on Wednesday at 2:00 PM with Dr. Johnson',
      'Health screening on Friday at 10:30 AM at Main Clinic',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Example 3: List Items with TTS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...appointments.map(
              (appointment) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TTSInlineButton(textToSpeak: appointment, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Code: Add TTSInlineButton to each list item',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 4: Using TTSText widget
  Widget _buildExample4() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Example 4: TTSText Widget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const TTSText(
              'This is a TTSText widget that automatically includes a TTS button. It\'s the easiest way to make any text readable.',
              style: TextStyle(fontSize: 16),
              showTTSButton: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Code: Replace Text() with TTSText()',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 5: Custom TTS integration
  Widget _buildExample5() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Example 5: Custom Integration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Medication: Birth Control Pills',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text('Dosage: One pill daily'),
            const Text('Instructions: Take at the same time each day'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Custom TTS call using helper function
                final medicationText = TTSHelpers.createMedicationText(
                  name: 'Birth Control Pills',
                  dosage: 'One pill daily',
                  instructions: 'Take at the same time each day',
                  purpose: 'Contraception',
                );
                TTSHelpers.speak(medicationText);
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('Read Medication Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Code: Use TTSHelpers.speak() for custom integration',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 6: TTS Control Panel
  Widget _buildExample6() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example 6: TTS Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12),
            TTSControlPanel(),
            SizedBox(height: 8),
            Text(
              'Code: Add TTSControlPanel() to settings screens',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
