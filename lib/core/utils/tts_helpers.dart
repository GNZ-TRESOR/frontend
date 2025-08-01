import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tts_service.dart';
import '../widgets/tts_button.dart';

/// TTS Helper Functions
/// Provides easy-to-use functions for TTS integration
class TTSHelpers {
  /// Speak text using the global TTS service
  static Future<void> speak(String text) async {
    final ttsService = TTSService();
    await ttsService.speak(text);
  }

  /// Stop current speech
  static Future<void> stop() async {
    final ttsService = TTSService();
    await ttsService.stop();
  }

  /// Set TTS language to English
  static Future<void> setEnglish() async {
    final ttsService = TTSService();
    await ttsService.setEnglish();
  }

  /// Set TTS language to Kinyarwanda
  static Future<void> setKinyarwanda() async {
    final ttsService = TTSService();
    await ttsService.setKinyarwanda();
  }

  /// Set TTS language to French
  static Future<void> setFrench() async {
    final ttsService = TTSService();
    await ttsService.setFrench();
  }

  /// Extract readable text from a widget tree
  static String extractTextFromWidget(Widget widget) {
    final buffer = StringBuffer();
    _extractTextRecursive(widget, buffer);
    return buffer.toString().trim();
  }

  /// Recursively extract text from widget tree
  static void _extractTextRecursive(Widget widget, StringBuffer buffer) {
    if (widget is Text) {
      if (widget.data != null) {
        buffer.write('${widget.data} ');
      }
    } else if (widget is RichText) {
      _extractTextFromTextSpan(widget.text, buffer);
    } else if (widget is StatelessWidget || widget is StatefulWidget) {
      // For custom widgets, we can't easily extract text without building
      // This is a limitation, but we can work around it by passing text explicitly
    }
  }

  /// Extract text from TextSpan
  static void _extractTextFromTextSpan(InlineSpan span, StringBuffer buffer) {
    if (span is TextSpan) {
      if (span.text != null) {
        buffer.write('${span.text} ');
      }
      if (span.children != null) {
        for (final child in span.children!) {
          _extractTextFromTextSpan(child, buffer);
        }
      }
    }
  }

  /// Create a TTS-enabled version of any text
  static String createReadableText({
    required String title,
    String? subtitle,
    String? content,
    List<String>? bulletPoints,
  }) {
    final buffer = StringBuffer();

    buffer.write('$title. ');

    if (subtitle != null && subtitle.isNotEmpty) {
      buffer.write('$subtitle. ');
    }

    if (content != null && content.isNotEmpty) {
      buffer.write('$content. ');
    }

    if (bulletPoints != null && bulletPoints.isNotEmpty) {
      buffer.write('Key points: ');
      for (int i = 0; i < bulletPoints.length; i++) {
        buffer.write('${i + 1}. ${bulletPoints[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Create screen reader text for dashboard cards
  static String createDashboardCardText({
    required String title,
    String? value,
    String? description,
    String? action,
  }) {
    final buffer = StringBuffer();

    buffer.write('$title card. ');

    if (value != null && value.isNotEmpty) {
      buffer.write('Value: $value. ');
    }

    if (description != null && description.isNotEmpty) {
      buffer.write('$description. ');
    }

    if (action != null && action.isNotEmpty) {
      buffer.write('Action available: $action. ');
    }

    return buffer.toString();
  }

  /// Create readable text for appointment information
  static String createAppointmentText({
    required String type,
    required String date,
    required String time,
    String? facility,
    String? doctor,
    String? status,
  }) {
    final buffer = StringBuffer();

    buffer.write('$type appointment. ');
    buffer.write('Scheduled for $date at $time. ');

    if (facility != null) {
      buffer.write('Location: $facility. ');
    }

    if (doctor != null) {
      buffer.write('With $doctor. ');
    }

    if (status != null) {
      buffer.write('Status: $status. ');
    }

    return buffer.toString();
  }

  /// Create readable text for health information
  static String createHealthInfoText({
    required String title,
    String? category,
    String? summary,
    List<String>? keyPoints,
  }) {
    final buffer = StringBuffer();

    buffer.write('$title. ');

    if (category != null) {
      buffer.write('Category: $category. ');
    }

    if (summary != null) {
      buffer.write('$summary. ');
    }

    if (keyPoints != null && keyPoints.isNotEmpty) {
      buffer.write('Important information: ');
      for (int i = 0; i < keyPoints.length; i++) {
        buffer.write('${i + 1}. ${keyPoints[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Create readable text for medication information
  static String createMedicationText({
    required String name,
    String? dosage,
    String? frequency,
    String? instructions,
    String? purpose,
  }) {
    final buffer = StringBuffer();

    buffer.write('Medication: $name. ');

    if (dosage != null) {
      buffer.write('Dosage: $dosage. ');
    }

    if (frequency != null) {
      buffer.write('Frequency: $frequency. ');
    }

    if (instructions != null) {
      buffer.write('Instructions: $instructions. ');
    }

    if (purpose != null) {
      buffer.write('Purpose: $purpose. ');
    }

    return buffer.toString();
  }

  /// Create readable text for event information
  static String createEventText({
    required String title,
    required String date,
    String? time,
    String? location,
    String? description,
  }) {
    final buffer = StringBuffer();

    buffer.write('Event: $title. ');
    buffer.write('Date: $date. ');

    if (time != null) {
      buffer.write('Time: $time. ');
    }

    if (location != null) {
      buffer.write('Location: $location. ');
    }

    if (description != null) {
      buffer.write('Description: $description. ');
    }

    return buffer.toString();
  }

  /// Create readable text for education content
  static String createEducationText({
    required String title,
    String? category,
    String? content,
    List<String>? keyPoints,
    String? author,
  }) {
    final buffer = StringBuffer();

    buffer.write('Educational content: $title. ');

    if (category != null) {
      buffer.write('Category: $category. ');
    }

    if (author != null) {
      buffer.write('By $author. ');
    }

    if (content != null) {
      buffer.write('$content. ');
    }

    if (keyPoints != null && keyPoints.isNotEmpty) {
      buffer.write('Key points: ');
      for (int i = 0; i < keyPoints.length; i++) {
        buffer.write('${i + 1}. ${keyPoints[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Create readable text for profile information
  static String createProfileText({
    required String name,
    String? email,
    String? phone,
    String? location,
    String? role,
  }) {
    final buffer = StringBuffer();

    buffer.write('Profile for $name. ');

    if (role != null) {
      buffer.write('Role: $role. ');
    }

    if (email != null) {
      buffer.write('Email: $email. ');
    }

    if (phone != null) {
      buffer.write('Phone: $phone. ');
    }

    if (location != null) {
      buffer.write('Location: $location. ');
    }

    return buffer.toString();
  }

  /// Create readable text for settings screen
  static String createSettingsText({
    required String title,
    List<String>? options,
    String? currentValue,
  }) {
    final buffer = StringBuffer();

    buffer.write('Settings: $title. ');

    if (currentValue != null) {
      buffer.write('Current value: $currentValue. ');
    }

    if (options != null && options.isNotEmpty) {
      buffer.write('Available options: ');
      for (int i = 0; i < options.length; i++) {
        buffer.write('${i + 1}. ${options[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Create readable text for form fields
  static String createFormText({
    required String formTitle,
    required List<String> fieldLabels,
    String? instructions,
  }) {
    final buffer = StringBuffer();

    buffer.write('Form: $formTitle. ');

    if (instructions != null) {
      buffer.write('Instructions: $instructions. ');
    }

    buffer.write('Fields: ');
    for (int i = 0; i < fieldLabels.length; i++) {
      buffer.write('${i + 1}. ${fieldLabels[i]}. ');
    }

    return buffer.toString();
  }

  /// Create readable text for navigation
  static String createNavigationText({
    required String currentScreen,
    required List<String> availableOptions,
  }) {
    final buffer = StringBuffer();

    buffer.write('You are on the $currentScreen screen. ');
    buffer.write('Available options: ');

    for (int i = 0; i < availableOptions.length; i++) {
      buffer.write('${i + 1}. ${availableOptions[i]}. ');
    }

    return buffer.toString();
  }
}

/// Extension methods for easy TTS integration
extension TTSExtensions on String {
  /// Speak this string using TTS
  Future<void> speak() async {
    await TTSHelpers.speak(this);
  }

  /// Create a clean version of this string for TTS
  String get ttsClean {
    return this
        .replaceAll(RegExp(r'[^\w\s\.,!?;:]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// Widget extension for TTS integration
extension WidgetTTSExtensions on Widget {
  /// Wrap this widget with TTS functionality
  Widget withTTS(String textToSpeak) {
    return Consumer(
      builder: (context, ref, child) {
        return Stack(
          children: [
            this,
            Positioned(
              top: 8,
              right: 8,
              child: TTSInlineButton(textToSpeak: textToSpeak),
            ),
          ],
        );
      },
    );
  }
}
