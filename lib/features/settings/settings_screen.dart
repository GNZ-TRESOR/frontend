import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/unified_language_provider.dart';
import '../../core/providers/global_translation_provider.dart' as global;
import '../../core/widgets/global_translated_text.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/models/user_settings.dart';

/// Professional Settings & Preferences Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock settings - in real app, this would come from provider
  UserSettings _settings = UserSettings(userId: 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Notifications'),
            Tab(text: 'Privacy'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            _buildNotificationsTab(),
            _buildPrivacyTab(),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance'),
          _buildSettingCard(
            title: 'Language',
            subtitle: _getLanguageDisplayName(),
            icon: Icons.language,
            onTap: () => _showLanguageDialog(),
          ),
          _buildSettingCard(
            title: 'Theme',
            subtitle: _settings.themeDisplayName,
            icon: Icons.palette,
            onTap: () => _showThemeDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Format'),
          _buildSettingCard(
            title: 'Date Format',
            subtitle: _settings.dateFormatDisplayName,
            icon: Icons.date_range,
            onTap: () => _showDateFormatDialog(),
          ),
          _buildSettingCard(
            title: 'Time Format',
            subtitle: _settings.timeFormatDisplayName,
            icon: Icons.access_time,
            onTap: () => _showTimeFormatDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Security'),
          _buildSwitchCard(
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face recognition',
            icon: Icons.fingerprint,
            value: _settings.biometricLogin,
            onChanged: (value) => _updateSetting('biometricLogin', value),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('General Notifications'),
          _buildSwitchCard(
            title: 'Enable Notifications',
            subtitle: 'Turn on/off all notifications',
            icon: Icons.notifications,
            value: _settings.notificationsEnabled,
            onChanged: (value) => _updateSetting('notificationsEnabled', value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Notification Types'),
          _buildSwitchCard(
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on your device',
            icon: Icons.phone_android,
            value: _settings.pushNotificationsEnabled,
            onChanged:
                (value) => _updateSetting('pushNotificationsEnabled', value),
            enabled: _settings.notificationsEnabled,
          ),
          _buildSwitchCard(
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            icon: Icons.email,
            value: _settings.emailNotificationsEnabled,
            onChanged:
                (value) => _updateSetting('emailNotificationsEnabled', value),
            enabled: _settings.notificationsEnabled,
          ),
          _buildSwitchCard(
            title: 'SMS Notifications',
            subtitle: 'Receive notifications via SMS',
            icon: Icons.sms,
            value: _settings.smsNotificationsEnabled,
            onChanged:
                (value) => _updateSetting('smsNotificationsEnabled', value),
            enabled: _settings.notificationsEnabled,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Reminders'),
          _buildSwitchCard(
            title: 'Appointment Reminders',
            subtitle: 'Get reminded about upcoming appointments',
            icon: Icons.event,
            value: _settings.appointmentReminders,
            onChanged: (value) => _updateSetting('appointmentReminders', value),
            enabled: _settings.notificationsEnabled,
          ),
          _buildSwitchCard(
            title: 'Medication Reminders',
            subtitle: 'Get reminded to take your medications',
            icon: Icons.medication,
            value: _settings.medicationReminders,
            onChanged: (value) => _updateSetting('medicationReminders', value),
            enabled: _settings.notificationsEnabled,
          ),
          _buildSwitchCard(
            title: 'Period Reminders',
            subtitle: 'Get reminded about your menstrual cycle',
            icon: Icons.favorite,
            value: _settings.periodReminders,
            onChanged: (value) => _updateSetting('periodReminders', value),
            enabled: _settings.notificationsEnabled,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Content'),
          _buildSwitchCard(
            title: 'Health Tips',
            subtitle: 'Receive helpful health tips and advice',
            icon: Icons.lightbulb,
            value: _settings.healthTips,
            onChanged: (value) => _updateSetting('healthTips', value),
            enabled: _settings.notificationsEnabled,
          ),
          _buildSwitchCard(
            title: 'Marketing Emails',
            subtitle: 'Receive promotional content and updates',
            icon: Icons.campaign,
            value: _settings.marketingEmails,
            onChanged: (value) => _updateSetting('marketingEmails', value),
            enabled: _settings.notificationsEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Privacy Level'),
          _buildSettingCard(
            title: 'Privacy Settings',
            subtitle: _settings.privacyLevelDisplayName,
            icon: Icons.privacy_tip,
            onTap: () => _showPrivacyLevelDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Sharing'),
          _buildSwitchCard(
            title: 'Share Data for Research',
            subtitle: 'Help improve healthcare by sharing anonymous data',
            icon: Icons.science,
            value: _settings.shareDataForResearch,
            onChanged: (value) => _updateSetting('shareDataForResearch', value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildSettingCard(
            title: 'Export My Data',
            subtitle: 'Download a copy of your data',
            icon: Icons.download,
            onTap: () => _exportData(),
          ),
          _buildSettingCard(
            title: 'Delete My Account',
            subtitle: 'Permanently delete your account and data',
            icon: Icons.delete_forever,
            onTap: () => _showDeleteAccountDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('App Information'),
          _buildSettingCard(
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
            icon: Icons.info,
            onTap: null,
          ),
          _buildSettingCard(
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            icon: Icons.description,
            onTap: () => _openTermsOfService(),
          ),
          _buildSettingCard(
            title: 'Privacy Policy',
            subtitle: 'Learn how we protect your privacy',
            icon: Icons.policy,
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildSettingCard(
            title: 'Contact Support',
            subtitle: 'Get help or report issues',
            icon: Icons.support_agent,
            onTap: () => _contactSupport(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Legal'),
          _buildSettingCard(
            title: 'Licenses',
            subtitle: 'View open source licenses',
            icon: Icons.copyright,
            onTap: () => _showLicenses(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDestructive ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isDestructive
                                ? AppColors.error
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: enabled ? 0.1 : 0.05,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: enabled ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          enabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _updateSetting(String key, dynamic value) {
    setState(() {
      switch (key) {
        case 'notificationsEnabled':
          _settings = _settings.copyWith(notificationsEnabled: value);
          break;
        case 'pushNotificationsEnabled':
          _settings = _settings.copyWith(pushNotificationsEnabled: value);
          break;
        case 'emailNotificationsEnabled':
          _settings = _settings.copyWith(emailNotificationsEnabled: value);
          break;
        case 'smsNotificationsEnabled':
          _settings = _settings.copyWith(smsNotificationsEnabled: value);
          break;
        case 'appointmentReminders':
          _settings = _settings.copyWith(appointmentReminders: value);
          break;
        case 'medicationReminders':
          _settings = _settings.copyWith(medicationReminders: value);
          break;
        case 'periodReminders':
          _settings = _settings.copyWith(periodReminders: value);
          break;
        case 'healthTips':
          _settings = _settings.copyWith(healthTips: value);
          break;
        case 'marketingEmails':
          _settings = _settings.copyWith(marketingEmails: value);
          break;
        case 'shareDataForResearch':
          _settings = _settings.copyWith(shareDataForResearch: value);
          break;
        case 'biometricLogin':
          _settings = _settings.copyWith(biometricLogin: value);
          break;
      }
    });

    // TODO: Save to API
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    // TODO: Implement API call to save settings
    final currentLang = ref.read(unifiedLanguageProvider);
    final languageNotifier = ref.read(unifiedLanguageProvider.notifier);
    final languageName = languageNotifier.getLanguageDisplayName(currentLang);
    final translationMethod = languageNotifier.getTranslationMethod(
      currentLang,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $languageName ($translationMethod)'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: SizedBox(
              width: double.maxFinite,
              child: Consumer(
                builder: (context, ref, child) {
                  final currentLanguage = ref.watch(unifiedLanguageProvider);
                  final languageNotifier = ref.read(
                    unifiedLanguageProvider.notifier,
                  );
                  final availableLanguages = ref.watch(
                    availableLanguagesProvider,
                  );

                  // Also watch global translation provider
                  final globalTranslationState = ref.watch(
                    global.globalTranslationProvider,
                  );
                  final globalTranslationNotifier = ref.read(
                    global.globalTranslationProvider.notifier,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        availableLanguages.map((language) {
                          final code = language['code']!;
                          final name = language['name']!;
                          final flag = language['flag']!;

                          return RadioListTile<String>(
                            title: Row(
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(name),
                              ],
                            ),
                            value: code,
                            groupValue: currentLanguage,
                            onChanged: (value) async {
                              if (value != null) {
                                // Store context before async operation
                                final navigator = Navigator.of(context);

                                // Update both language providers
                                await languageNotifier.changeLanguage(value);
                                await globalTranslationNotifier.changeLanguage(
                                  value,
                                );

                                // Update the settings model for consistency
                                if (mounted) {
                                  setState(() {
                                    _settings = _settings.copyWith(
                                      language: value,
                                    );
                                  });

                                  navigator.pop();
                                  _saveSettings();
                                }
                              }
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  String _getLanguageDisplayName() {
    final currentLang = ref.watch(unifiedLanguageProvider);
    final languageNotifier = ref.read(unifiedLanguageProvider.notifier);
    return languageNotifier.getLanguageDisplayName(currentLang);
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption('Light', 'light'),
                _buildThemeOption('Dark', 'dark'),
                _buildThemeOption('System Default', 'system'),
              ],
            ),
          ),
    );
  }

  Widget _buildThemeOption(String name, String value) {
    return RadioListTile<String>(
      title: Text(name),
      value: value,
      groupValue: _settings.theme,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _settings = _settings.copyWith(theme: newValue);
          });
          Navigator.pop(context);
          _saveSettings();
        }
      },
    );
  }

  void _showDateFormatDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date format selection coming soon')),
    );
  }

  void _showTimeFormatDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time format selection coming soon')),
    );
  }

  void _showPrivacyLevelDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy level selection coming soon')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion feature coming soon'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _openTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Terms of Service...')),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening Privacy Policy...')));
  }

  void _contactSupport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening support contact...')));
  }

  void _showLicenses() {
    showLicensePage(context: context);
  }
}
