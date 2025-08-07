import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/tts_provider.dart';
import '../../core/utils/app_constants.dart';

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedSettingsScreen> createState() =>
      _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState
    extends ConsumerState<AdvancedSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _dataSyncEnabled = true;
  bool _offlineMode = false;
  bool _autoBackup = true;
  bool _analyticsEnabled = true;
  bool _crashReporting = true;
  String _syncFrequency = '15 minutes';
  String _backupFrequency = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildDataSettings(),
            const SizedBox(height: 24),
            _buildPrivacySettings(),
            const SizedBox(height: 24),
            _buildPerformanceSettings(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: _emailNotifications,
              onChanged:
                  _notificationsEnabled
                      ? (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      }
                      : null,
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _pushNotifications,
              onChanged:
                  _notificationsEnabled
                      ? (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      }
                      : null,
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              subtitle: const Text('Receive notifications via SMS'),
              value: _smsNotifications,
              onChanged:
                  _notificationsEnabled
                      ? (value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data & Sync',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Data Synchronization'),
              subtitle: const Text('Sync data with cloud'),
              value: _dataSyncEnabled,
              onChanged: (value) {
                setState(() {
                  _dataSyncEnabled = value;
                });
              },
            ),
            ListTile(
              title: const Text('Sync Frequency'),
              subtitle: Text(_syncFrequency),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _dataSyncEnabled ? () => _showSyncFrequencyDialog() : null,
            ),
            SwitchListTile(
              title: const Text('Offline Mode'),
              subtitle: const Text('Use app without internet'),
              value: _offlineMode,
              onChanged: (value) {
                setState(() {
                  _offlineMode = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Auto Backup'),
              subtitle: const Text('Automatically backup data'),
              value: _autoBackup,
              onChanged: (value) {
                setState(() {
                  _autoBackup = value;
                });
              },
            ),
            ListTile(
              title: const Text('Backup Frequency'),
              subtitle: Text(_backupFrequency),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _autoBackup ? () => _showBackupFrequencyDialog() : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy & Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app'),
              value: _analyticsEnabled,
              onChanged: (value) {
                setState(() {
                  _analyticsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Crash Reporting'),
              subtitle: const Text('Report app crashes'),
              value: _crashReporting,
              onChanged: (value) {
                setState(() {
                  _crashReporting = value;
                });
              },
            ),
            ListTile(
              title: const Text('Data Export'),
              subtitle: const Text('Export your health data'),
              trailing: const Icon(Icons.download),
              onTap: () => _exportData(),
            ),
            ListTile(
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: () => _showDeleteAccountDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.cleaning_services),
              onTap: () => _clearCache(),
            ),
            ListTile(
              title: const Text('Reset App'),
              subtitle: const Text('Reset all app settings'),
              trailing: const Icon(Icons.refresh),
              onTap: () => _showResetAppDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('Terms of Service'),
              subtitle: const Text('Read our terms'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _openTermsOfService(),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our privacy policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _openPrivacyPolicy(),
            ),
            ListTile(
              title: const Text('Contact Support'),
              subtitle: const Text('Get help and support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _contactSupport(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncFrequencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sync Frequency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['15 minutes', '30 minutes', '1 hour', '6 hours', 'Daily']
                      .map(
                        (frequency) => RadioListTile<String>(
                          title: Text(frequency),
                          value: frequency,
                          groupValue: _syncFrequency,
                          onChanged: (value) {
                            setState(() {
                              _syncFrequency = value!;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showBackupFrequencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Backup Frequency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['Daily', 'Weekly', 'Monthly']
                      .map(
                        (frequency) => RadioListTile<String>(
                          title: Text(frequency),
                          value: frequency,
                          groupValue: _backupFrequency,
                          onChanged: (value) {
                            setState(() {
                              _backupFrequency = value!;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: const Text(
              'Your health data will be exported and sent to your email address.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data export initiated. You will receive an email shortly.',
                      ),
                    ),
                  );
                },
                child: const Text('Export'),
              ),
            ],
          ),
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle account deletion
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cache'),
            content: const Text(
              'This will clear all cached data and free up storage space.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully.'),
                    ),
                  );
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showResetAppDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset App'),
            content: const Text(
              'This will reset all app settings to default values. Your data will not be affected.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('App settings reset successfully.'),
                    ),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _openTermsOfService() {
    // Navigate to terms of service
  }

  void _openPrivacyPolicy() {
    // Navigate to privacy policy
  }

  void _contactSupport() {
    // Navigate to support screen
  }
}
