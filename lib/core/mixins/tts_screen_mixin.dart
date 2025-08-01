import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tts_button.dart';
import '../utils/tts_helpers.dart';
import '../theme/app_colors.dart';

/// Mixin to easily add TTS functionality to any screen
/// Usage: class MyScreen extends ConsumerWidget with TTSScreenMixin
mixin TTSScreenMixin {
  /// Get the screen-specific content for TTS
  String getTTSContent(BuildContext context, WidgetRef ref);

  /// Get the screen name for TTS
  String getScreenName() => 'Screen';

  /// Build TTS floating action button for the screen
  Widget buildTTSFloatingButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: TTSFloatingButton(
        textToSpeak: getTTSContent(context, ref),
        tooltip: 'Read ${getScreenName()} content aloud',
        backgroundColor: AppColors.primary,
        size: 24,
      ),
    );
  }

  /// Add TTS floating button to a Scaffold
  Widget addTTSToScaffold({
    required BuildContext context,
    required WidgetRef ref,
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? drawer,
    Widget? endDrawer,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Color? backgroundColor,
    Widget? additionalFAB,
  }) {
    Widget floatingActionButton;

    if (additionalFAB != null) {
      // Create a column with both FABs
      floatingActionButton = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTTSFloatingButton(context, ref),
          const SizedBox(height: 16),
          additionalFAB,
        ],
      );
    } else {
      floatingActionButton = buildTTSFloatingButton(context, ref);
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation:
          floatingActionButtonLocation ?? FloatingActionButtonLocation.endTop,
    );
  }

  /// Create TTS content for list screens
  String createListScreenTTS({
    required String screenName,
    required List<String> items,
    String? description,
    String? emptyMessage,
  }) {
    final buffer = StringBuffer();

    buffer.write('$screenName screen. ');

    if (description != null) {
      buffer.write('$description. ');
    }

    if (items.isEmpty) {
      buffer.write(emptyMessage ?? 'No items available. ');
    } else {
      buffer.write('${items.length} items available. ');

      // Read first few items
      final itemsToRead = items.take(5).toList();
      for (int i = 0; i < itemsToRead.length; i++) {
        buffer.write('${i + 1}. ${itemsToRead[i]}. ');
      }

      if (items.length > 5) {
        buffer.write('And ${items.length - 5} more items. ');
      }
    }

    return buffer.toString();
  }

  /// Create TTS content for form screens
  String createFormScreenTTS({
    required String formName,
    required List<String> fieldLabels,
    String? instructions,
    String? currentStep,
  }) {
    return TTSHelpers.createFormText(
      formTitle: formName,
      fieldLabels: fieldLabels,
      instructions:
          instructions != null
              ? '${instructions}${currentStep != null ? ' Current step: $currentStep.' : ''}'
              : currentStep,
    );
  }

  /// Create TTS content for detail screens
  String createDetailScreenTTS({
    required String title,
    required Map<String, String> details,
    String? description,
    List<String>? actions,
  }) {
    final buffer = StringBuffer();

    buffer.write('Details for $title. ');

    if (description != null) {
      buffer.write('$description. ');
    }

    details.forEach((key, value) {
      buffer.write('$key: $value. ');
    });

    if (actions != null && actions.isNotEmpty) {
      buffer.write('Available actions: ');
      for (int i = 0; i < actions.length; i++) {
        buffer.write('${i + 1}. ${actions[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Create TTS content for dashboard screens
  String createDashboardScreenTTS({
    required String userName,
    required List<String> quickActions,
    required Map<String, String> summaryCards,
    String? welcomeMessage,
  }) {
    final buffer = StringBuffer();

    buffer.write(welcomeMessage ?? 'Welcome to your dashboard, $userName. ');

    if (summaryCards.isNotEmpty) {
      buffer.write('Summary: ');
      summaryCards.forEach((title, value) {
        buffer.write('$title: $value. ');
      });
    }

    if (quickActions.isNotEmpty) {
      buffer.write('Quick actions available: ');
      for (int i = 0; i < quickActions.length; i++) {
        buffer.write('${i + 1}. ${quickActions[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Create TTS content for settings screens
  String createSettingsScreenTTS({
    required List<String> settingCategories,
    String? currentSection,
  }) {
    final buffer = StringBuffer();

    buffer.write('Settings screen. ');

    if (currentSection != null) {
      buffer.write('Current section: $currentSection. ');
    }

    buffer.write('Available settings: ');
    for (int i = 0; i < settingCategories.length; i++) {
      buffer.write('${i + 1}. ${settingCategories[i]}. ');
    }

    return buffer.toString();
  }

  /// Create TTS content for appointment screens
  String createAppointmentScreenTTS({
    required List<Map<String, String>> appointments,
    String? filterType,
  }) {
    final buffer = StringBuffer();

    buffer.write('Appointments screen. ');

    if (filterType != null) {
      buffer.write('Showing $filterType appointments. ');
    }

    if (appointments.isEmpty) {
      buffer.write('No appointments found. ');
    } else {
      buffer.write('${appointments.length} appointments found. ');

      // Read first few appointments
      final appointmentsToRead = appointments.take(3).toList();
      for (int i = 0; i < appointmentsToRead.length; i++) {
        final apt = appointmentsToRead[i];
        buffer.write('${i + 1}. ');
        buffer.write('${apt['type'] ?? 'Appointment'} ');
        buffer.write('on ${apt['date'] ?? 'unknown date'} ');
        if (apt['time'] != null) {
          buffer.write('at ${apt['time']} ');
        }
        buffer.write('with ${apt['doctor'] ?? 'healthcare provider'}. ');
        if (apt['status'] != null) {
          buffer.write('Status: ${apt['status']}. ');
        }
      }

      if (appointments.length > 3) {
        buffer.write('And ${appointments.length - 3} more appointments. ');
      }
    }

    return buffer.toString();
  }

  /// Create TTS content for health record screens
  String createHealthRecordScreenTTS({
    required Map<String, String> basicInfo,
    required List<String> recentEntries,
    String? lastUpdate,
  }) {
    final buffer = StringBuffer();

    buffer.write('Health records screen. ');

    if (lastUpdate != null) {
      buffer.write('Last updated: $lastUpdate. ');
    }

    buffer.write('Basic information: ');
    basicInfo.forEach((key, value) {
      buffer.write('$key: $value. ');
    });

    if (recentEntries.isNotEmpty) {
      buffer.write('Recent entries: ');
      final entriesToRead = recentEntries.take(3).toList();
      for (int i = 0; i < entriesToRead.length; i++) {
        buffer.write('${i + 1}. ${entriesToRead[i]}. ');
      }

      if (recentEntries.length > 3) {
        buffer.write('And ${recentEntries.length - 3} more entries. ');
      }
    }

    return buffer.toString();
  }

  /// Create TTS content for medication screens
  String createMedicationScreenTTS({
    required List<Map<String, String>> medications,
    String? filterType,
  }) {
    final buffer = StringBuffer();

    buffer.write('Medications screen. ');

    if (filterType != null) {
      buffer.write('Showing $filterType medications. ');
    }

    if (medications.isEmpty) {
      buffer.write('No medications found. ');
    } else {
      buffer.write('${medications.length} medications found. ');

      final medsToRead = medications.take(3).toList();
      for (int i = 0; i < medsToRead.length; i++) {
        final med = medsToRead[i];
        buffer.write('${i + 1}. ${med['name'] ?? 'Medication'}. ');
        if (med['dosage'] != null) {
          buffer.write('Dosage: ${med['dosage']}. ');
        }
        if (med['frequency'] != null) {
          buffer.write('Frequency: ${med['frequency']}. ');
        }
      }

      if (medications.length > 3) {
        buffer.write('And ${medications.length - 3} more medications. ');
      }
    }

    return buffer.toString();
  }
}
