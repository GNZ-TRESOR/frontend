import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';

/// Admin System Settings Screen with comprehensive tabs
class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() =>
      _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  // System settings data
  Map<String, dynamic> _systemSettings = {};
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSystemData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSystemData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService.instance;

      // Load system settings
      final settingsResponse = await apiService.getSystemSettings();
      if (settingsResponse.success && settingsResponse.data != null) {
        _systemSettings = settingsResponse.data['settings'] ?? {};
      }

      // Load notifications for admin management
      final notificationsResponse = await apiService.getAllNotifications();
      if (notificationsResponse.success && notificationsResponse.data != null) {
        _notifications = List<Map<String, dynamic>>.from(
          notificationsResponse.data['notifications'] ?? [],
        );
      }

      // Load users for user management
      final usersResponse = await apiService.getAllUsers();
      if (usersResponse.success && usersResponse.data != null) {
        _users = List<Map<String, dynamic>>.from(
          usersResponse.data['users'] ?? [],
        );
      }
    } catch (e) {
      _error = e.toString();
      // Load default settings for demo
      _systemSettings = {
        'general': {
          'appName': 'Ubuzima',
          'appVersion': '1.0.0',
          'maintenanceMode': false,
          'registrationEnabled': true,
          'maxUsersPerHealthWorker': 50,
        },
        'notifications': {
          'emailNotifications': true,
          'smsNotifications': true,
          'pushNotifications': true,
          'appointmentReminders': true,
          'healthReminders': true,
        },
        'security': {
          'passwordMinLength': 8,
          'sessionTimeout': 30,
          'twoFactorAuth': false,
          'loginAttempts': 5,
          'accountLockoutTime': 15,
        },
        'features': {
          'pregnancyPlanning': true,
          'appointmentBooking': true,
          'healthRecords': true,
          'communityEvents': true,
          'educationalContent': true,
        },
      };
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: AppColors.textSecondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSystemData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Notifications'),
            Tab(text: 'Users'),
            Tab(text: 'Security'),
            Tab(text: 'Features'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _error != null
                ? _buildErrorState()
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(),
                    _buildNotificationsTab(),
                    _buildUsersTab(),
                    _buildSecurityTab(),
                    _buildFeaturesTab(),
                    _buildReportsTab(),
                  ],
                ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    final general = _systemSettings['general'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Application Settings', Icons.settings),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'App Name',
            subtitle: general['appName']?.toString() ?? 'Ubuzima Health App',
            icon: Icons.apps,
            onTap: () => _editTextSetting('appName', 'App Name'),
          ),
          _buildSettingCard(
            title: 'App Version',
            subtitle: general['appVersion']?.toString() ?? '1.0.0',
            icon: Icons.info,
            onTap: () => _editTextSetting('appVersion', 'App Version'),
          ),
          _buildSettingCard(
            title: 'Max Users per Health Worker',
            subtitle: '${general['maxUsersPerHealthWorker']?.toInt() ?? 50}',
            icon: Icons.people,
            onTap:
                () => _editNumberSetting(
                  'maxUsersPerHealthWorker',
                  'Max Users per Health Worker',
                ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('System Control', Icons.admin_panel_settings),
          const SizedBox(height: 16),
          _buildSwitchCard(
            title: 'Maintenance Mode',
            subtitle: 'Enable maintenance mode to restrict access',
            icon: Icons.build,
            value: general['maintenanceMode'] ?? false,
            onChanged:
                (value) => _updateSetting('general', 'maintenanceMode', value),
          ),
          _buildSwitchCard(
            title: 'Registration Enabled',
            subtitle: 'Allow new user registrations',
            icon: Icons.person_add,
            value: general['registrationEnabled'] ?? true,
            onChanged:
                (value) =>
                    _updateSetting('general', 'registrationEnabled', value),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    final notifications =
        _systemSettings['notifications'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader(
                  'Notification Management',
                  Icons.notifications,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createNotification,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification Settings
          _buildSectionHeader('Settings', Icons.settings),
          const SizedBox(height: 8),
          _buildSwitchCard(
            title: 'Enable Push Notifications',
            subtitle: 'Allow the app to send push notifications',
            icon: Icons.notifications_active,
            value: (notifications['pushNotifications'] ?? true),
            onChanged:
                (value) =>
                    _updateSetting('notifications', 'pushNotifications', value),
          ),
          _buildSwitchCard(
            title: 'Enable Email Notifications',
            subtitle: 'Send notifications via email',
            icon: Icons.email,
            value: (notifications['emailNotifications'] ?? true),
            onChanged:
                (value) => _updateSetting(
                  'notifications',
                  'emailNotifications',
                  value,
                ),
          ),
          _buildSwitchCard(
            title: 'Enable SMS Notifications',
            subtitle: 'Send notifications via SMS',
            icon: Icons.sms,
            value: (notifications['smsNotifications'] ?? false),
            onChanged:
                (value) =>
                    _updateSetting('notifications', 'smsNotifications', value),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Notification List', Icons.list),
          const SizedBox(height: 8),
          _buildNotificationsList(),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    final security = _systemSettings['security'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Security Settings', Icons.security),
          _buildSwitchCard(
            title: 'Require Two-Factor Authentication',
            subtitle: 'Force all users to enable 2FA',
            icon: Icons.security,
            value: security['requireTwoFactor'] ?? false,
            onChanged:
                (value) =>
                    _updateSetting('security', 'requireTwoFactor', value),
          ),
          _buildSettingCard(
            title: 'Password Minimum Length',
            subtitle: '${security['passwordMinLength'] ?? 8} characters',
            icon: Icons.lock,
            onTap:
                () => _editNumberSetting(
                  'passwordMinLength',
                  'Password Min Length',
                ),
          ),
          _buildSettingCard(
            title: 'Session Duration (hours)',
            subtitle: '${security['sessionDuration'] ?? 24}',
            icon: Icons.access_time,
            onTap:
                () => _editNumberSetting('sessionDuration', 'Session Duration'),
          ),
          _buildSettingCard(
            title: 'Max Login Attempts',
            subtitle: '${security['maxLoginAttempts'] ?? 5}',
            icon: Icons.warning,
            onTap:
                () => _editNumberSetting(
                  'maxLoginAttempts',
                  'Max Login Attempts',
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    final features = _systemSettings['features'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Feature Toggles', Icons.featured_play_list),
          _buildSwitchCard(
            title: 'Family Planning Module',
            subtitle: 'Enable family planning features',
            icon: Icons.family_restroom,
            value: features['enableFamilyPlanning'] ?? true,
            onChanged:
                (value) =>
                    _updateSetting('features', 'enableFamilyPlanning', value),
          ),
          _buildSwitchCard(
            title: 'Education Module',
            subtitle: 'Enable educational content',
            icon: Icons.school,
            value: features['enableEducationModule'] ?? true,
            onChanged:
                (value) =>
                    _updateSetting('features', 'enableEducationModule', value),
          ),
          _buildSwitchCard(
            title: 'Appointments',
            subtitle: 'Enable appointment booking',
            icon: Icons.event,
            value: features['enableAppointments'] ?? true,
            onChanged:
                (value) =>
                    _updateSetting('features', 'enableAppointments', value),
          ),
          _buildSwitchCard(
            title: 'Messaging',
            subtitle: 'Enable user messaging',
            icon: Icons.message,
            value: features['enableMessaging'] ?? true,
            onChanged:
                (value) => _updateSetting('features', 'enableMessaging', value),
          ),
          _buildSwitchCard(
            title: 'Reports',
            subtitle: 'Enable reporting features',
            icon: Icons.analytics,
            value: features['enableReports'] ?? true,
            onChanged:
                (value) => _updateSetting('features', 'enableReports', value),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader('User Management', Icons.people),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUsersList(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('System Reports', Icons.analytics),
          _buildSettingCard(
            title: 'User Activity Report',
            subtitle: 'Generate user activity analytics',
            icon: Icons.people_alt,
            onTap: () => _generateReport('user_activity'),
          ),
          _buildSettingCard(
            title: 'Health Records Report',
            subtitle: 'Generate health records summary',
            icon: Icons.medical_services,
            onTap: () => _generateReport('health_records'),
          ),
          _buildSettingCard(
            title: 'Appointment Statistics',
            subtitle: 'Generate appointment analytics',
            icon: Icons.event_note,
            onTap: () => _generateReport('appointments'),
          ),
          _buildSettingCard(
            title: 'System Performance',
            subtitle: 'Generate system performance metrics',
            icon: Icons.speed,
            onTap: () => _generateReport('performance'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    String description,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSetting(
    String title,
    String value,
    String description,
    Function(String) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSetting(
    String title,
    int value,
    String description,
    Function(int) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (val) {
                final intVal = int.tryParse(val);
                if (intVal != null) onChanged(intVal);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading settings',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSystemData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateSetting(String category, String key, dynamic value) {
    setState(() {
      if (_systemSettings[category] == null) {
        _systemSettings[category] = <String, dynamic>{};
      }
      _systemSettings[category][key] = value;
    });
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final response = await ApiService.instance.updateSystemSettings(
        _systemSettings,
      );

      if (response.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to save settings'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Placeholder methods for missing functionality
  void _editTextSetting(String key, String title) {
    // TODO: Implement text setting editor dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit $title - Coming Soon')));
  }

  void _editNumberSetting(String key, String title) {
    // TODO: Implement number setting editor dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit $title - Coming Soon')));
  }

  void _createNotification() {
    // TODO: Implement notification creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Notification - Coming Soon')),
    );
  }

  void _createUser() {
    // TODO: Implement user creation dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Create User - Coming Soon')));
  }

  void _generateReport(String reportType) {
    // TODO: Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generate $reportType Report - Coming Soon')),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return const Center(child: Text('No notifications found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          child: ListTile(
            title: Text(
              notification['title'] ?? 'No Title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              notification['message'] ?? 'No Message',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Edit notification
                } else if (value == 'delete') {
                  // TODO: Delete notification
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          child: ListTile(
            title: Text(
              user['name'] ?? 'No Name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              user['email'] ?? 'No Email',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Edit user
                } else if (value == 'delete') {
                  // TODO: Delete user
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
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
                        color: AppColors.textPrimary,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
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
                      color: AppColors.textPrimary,
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
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
