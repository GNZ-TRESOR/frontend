import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';
import 'reports_screen.dart';

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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Generate comprehensive reports with real-time data and insights',
                    style: TextStyle(color: AppColors.info, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            title: 'User Activity Report',
            subtitle: 'Comprehensive user statistics and engagement analytics',
            icon: Icons.people_alt,
            color: AppColors.primary,
            onTap: () => _generateReport('user_activity'),
          ),
          _buildReportCard(
            title: 'Health Records Report',
            subtitle: 'Health records statistics and completion trends',
            icon: Icons.medical_services,
            color: AppColors.success,
            onTap: () => _generateReport('health_records'),
          ),
          _buildReportCard(
            title: 'Appointment Analytics',
            subtitle: 'Appointment booking and completion statistics',
            icon: Icons.event_note,
            color: AppColors.info,
            onTap: () => _generateReport('appointments'),
          ),
          _buildReportCard(
            title: 'System Performance',
            subtitle: 'Platform performance and system health metrics',
            icon: Icons.speed,
            color: AppColors.warning,
            onTap: () => _generateReport('performance'),
          ),
          const SizedBox(height: 24),
          _buildQuickActionsSection(),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
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
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions', Icons.flash_on),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                title: 'View All Reports',
                icon: Icons.assessment,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                title: 'Export Data',
                icon: Icons.download,
                color: AppColors.success,
                onTap: () => _showExportDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

  Future<void> _generateReport(String reportType) async {
    setState(() => _isLoading = true);

    try {
      // Set default date range (last 30 days)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      // Fetch comprehensive report data using real APIs
      final reportData = await _fetchDetailedReportData(
        reportType,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );

      if (reportData != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getReportDisplayName(reportType)} generated successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Show comprehensive report preview dialog
        _showDetailedReportPreviewDialog(reportType, reportData);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate report'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getReportDisplayName(String reportType) {
    switch (reportType) {
      case 'user_activity':
        return 'User Activity Report';
      case 'health_records':
        return 'Health Records Report';
      case 'appointments':
        return 'Appointment Statistics';
      default:
        return 'Report';
    }
  }

  /// Fetch detailed report data using real APIs
  Future<Map<String, dynamic>?> _fetchDetailedReportData(
    String reportType,
    String startDate,
    String endDate,
  ) async {
    try {
      // First try to get data from dedicated report API endpoints
      final detailsResponse = await ApiService.instance.getReportDetails(
        reportType,
        startDate,
        endDate,
      );

      final summaryResponse = await ApiService.instance.getReportSummary(
        reportType,
      );

      final insightsResponse = await ApiService.instance.getReportInsights(
        reportType,
      );

      Map<String, dynamic> reportData = {
        'title': _getReportDisplayName(reportType),
        'generatedAt': DateTime.now().toIso8601String(),
        'period': '${startDate.split('T')[0]} to ${endDate.split('T')[0]}',
      };

      // Add summary data if available
      if (summaryResponse.success && summaryResponse.data != null) {
        reportData['summary'] = summaryResponse.data['summary'];
      }

      // Add detailed data if available
      if (detailsResponse.success && detailsResponse.data != null) {
        reportData.addAll(detailsResponse.data['details'] ?? {});
      }

      // Add insights if available
      if (insightsResponse.success && insightsResponse.data != null) {
        reportData['insights'] = insightsResponse.data['insights'];
      }

      // Always fetch additional data from existing methods to ensure comprehensive reports
      Map<String, dynamic>? additionalData;
      switch (reportType) {
        case 'user_activity':
          additionalData = await _fetchUserActivityData(startDate, endDate);
          break;
        case 'health_records':
          additionalData = await _fetchHealthRecordsData(startDate, endDate);
          break;
        case 'appointments':
          additionalData = await _fetchAppointmentData(startDate, endDate);
          break;
      }

      // Merge additional data if available
      if (additionalData != null) {
        // If we don't have summary from API, use the one from additional data
        if (!reportData.containsKey('summary') &&
            additionalData.containsKey('summary')) {
          reportData['summary'] = additionalData['summary'];
        }

        // If we don't have insights from API, use the ones from additional data
        if (!reportData.containsKey('insights') &&
            additionalData.containsKey('insights')) {
          reportData['insights'] = additionalData['insights'];
        }

        // Add any other data that's not already present
        additionalData.forEach((key, value) {
          if (!reportData.containsKey(key)) {
            reportData[key] = value;
          }
        });
      }

      return reportData;
    } catch (e) {
      print('Error fetching report data: $e');
      // Fallback to existing methods
      switch (reportType) {
        case 'user_activity':
          return await _fetchUserActivityData(startDate, endDate);
        case 'health_records':
          return await _fetchHealthRecordsData(startDate, endDate);
        case 'appointments':
          return await _fetchAppointmentData(startDate, endDate);
        default:
          return null;
      }
    }
  }

  /// Fetch user activity report data
  Future<Map<String, dynamic>> _fetchUserActivityData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch analytics data
      final analyticsResponse = await ApiService.instance.getAnalytics(
        days: 30,
      );

      Map<String, dynamic> dashboardData = {};
      Map<String, dynamic> analyticsData = {};

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (analyticsResponse.success && analyticsResponse.data != null) {
        analyticsData = analyticsResponse.data['analytics'] ?? {};
      }

      final totalUsers = dashboardData['totalUsers'] ?? 0;
      final activeUsers = analyticsData['activeUsers'] ?? 0;
      final newUsers = analyticsData['newUsersThisMonth'] ?? 0;
      final usersByRole = analyticsData['usersByRole'] ?? [];

      // Calculate engagement metrics
      final engagementRate =
          totalUsers > 0 ? (activeUsers / totalUsers * 100) : 0.0;

      return {
        'title': 'User Activity Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': '${startDate.split('T')[0]} to ${endDate.split('T')[0]}',
        'summary': {
          'totalUsers': totalUsers,
          'activeUsers': activeUsers,
          'newUsers': newUsers,
          'engagementRate': engagementRate.toStringAsFixed(1),
        },
        'usersByRole': usersByRole,
        'insights': [
          'Total registered users: $totalUsers',
          'Currently active users: $activeUsers',
          'New users this month: $newUsers',
          'User engagement rate: ${engagementRate.toStringAsFixed(1)}%',
          'User distribution: ${usersByRole.map((role) => '${role[0]}: ${role[1]}').join(', ')}',
        ],
        'recommendations': _getUserActivityRecommendations(
          engagementRate,
          newUsers,
        ),
      };
    } catch (e) {
      return {
        'title': 'User Activity Report',
        'error': 'Failed to fetch user activity data: $e',
      };
    }
  }

  /// Generate user activity recommendations
  List<String> _getUserActivityRecommendations(
    double engagementRate,
    int newUsers,
  ) {
    List<String> recommendations = [];

    if (engagementRate < 50) {
      recommendations.add(
        'Consider implementing user engagement campaigns to increase activity',
      );
      recommendations.add(
        'Review user onboarding process to improve retention',
      );
    } else if (engagementRate > 80) {
      recommendations.add(
        'Excellent user engagement! Consider expanding platform features',
      );
    }

    if (newUsers < 5) {
      recommendations.add(
        'Focus on user acquisition strategies to grow the user base',
      );
    } else if (newUsers > 20) {
      recommendations.add(
        'Strong user growth! Ensure infrastructure can handle increased load',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'User activity levels are healthy and within normal ranges',
      );
    }

    return recommendations;
  }

  /// Fetch health records report data
  Future<Map<String, dynamic>> _fetchHealthRecordsData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch users data to get health worker information
      final usersResponse = await ApiService.instance.getAdminUsers();

      Map<String, dynamic> dashboardData = {};
      List<dynamic> usersData = [];

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (usersResponse.success && usersResponse.data != null) {
        usersData = usersResponse.data['users'] ?? [];
      }

      final totalRecords = dashboardData['totalHealthRecords'] ?? 0;
      final totalClients = dashboardData['totalClients'] ?? 0;
      final totalHealthWorkers = dashboardData['totalHealthWorkers'] ?? 0;

      // Calculate metrics
      final recordsPerClient =
          totalClients > 0 ? (totalRecords / totalClients) : 0.0;
      final recordsPerHealthWorker =
          totalHealthWorkers > 0 ? (totalRecords / totalHealthWorkers) : 0.0;

      return {
        'title': 'Health Records Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': '${startDate.split('T')[0]} to ${endDate.split('T')[0]}',
        'summary': {
          'totalRecords': totalRecords,
          'totalClients': totalClients,
          'totalHealthWorkers': totalHealthWorkers,
          'recordsPerClient': recordsPerClient.toStringAsFixed(1),
          'recordsPerHealthWorker': recordsPerHealthWorker.toStringAsFixed(1),
        },
        'insights': [
          'Total health records: $totalRecords',
          'Total clients with records: $totalClients',
          'Active health workers: $totalHealthWorkers',
          'Average records per client: ${recordsPerClient.toStringAsFixed(1)}',
          'Average records per health worker: ${recordsPerHealthWorker.toStringAsFixed(1)}',
        ],
        'recommendations': _getHealthRecordsRecommendations(
          recordsPerClient,
          totalRecords,
        ),
      };
    } catch (e) {
      return {
        'title': 'Health Records Report',
        'error': 'Failed to fetch health records data: $e',
      };
    }
  }

  /// Generate health records recommendations
  List<String> _getHealthRecordsRecommendations(
    double recordsPerClient,
    int totalRecords,
  ) {
    List<String> recommendations = [];

    if (recordsPerClient < 1) {
      recommendations.add(
        'Encourage clients to complete their health profiles',
      );
      recommendations.add(
        'Provide training to health workers on record keeping',
      );
    } else if (recordsPerClient > 3) {
      recommendations.add(
        'Excellent record keeping! Consider implementing advanced analytics',
      );
    }

    if (totalRecords < 10) {
      recommendations.add(
        'Focus on onboarding more clients to build health record database',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Health record management is performing well');
    }

    return recommendations;
  }

  /// Fetch appointment report data
  Future<Map<String, dynamic>> _fetchAppointmentData(
    String startDate,
    String endDate,
  ) async {
    try {
      // Fetch dashboard stats
      final dashboardResponse = await ApiService.instance.getDashboardStats();

      // Fetch health facilities data for appointment distribution
      final facilitiesResponse =
          await ApiService.instance.getHealthFacilities();

      Map<String, dynamic> dashboardData = {};
      List<dynamic> facilitiesData = [];

      if (dashboardResponse.success && dashboardResponse.data != null) {
        dashboardData = dashboardResponse.data['stats'] ?? {};
      }

      if (facilitiesResponse.success && facilitiesResponse.data != null) {
        if (facilitiesResponse.data is Map<String, dynamic>) {
          facilitiesData = facilitiesResponse.data['data'] ?? [];
        }
      }

      final totalAppointments = dashboardData['totalAppointments'] ?? 0;
      final totalFacilities = dashboardData['totalFacilities'] ?? 0;
      final totalClients = dashboardData['totalClients'] ?? 0;

      // Calculate metrics
      final appointmentsPerFacility =
          totalFacilities > 0 ? (totalAppointments / totalFacilities) : 0.0;
      final appointmentsPerClient =
          totalClients > 0 ? (totalAppointments / totalClients) : 0.0;

      // Get facility distribution
      final facilityNames =
          facilitiesData.map((f) => f['name'] ?? 'Unknown').take(5).toList();

      return {
        'title': 'Appointment Analytics Report',
        'generatedAt': DateTime.now().toIso8601String(),
        'period': '${startDate.split('T')[0]} to ${endDate.split('T')[0]}',
        'summary': {
          'totalAppointments': totalAppointments,
          'totalFacilities': totalFacilities,
          'totalClients': totalClients,
          'appointmentsPerFacility': appointmentsPerFacility.toStringAsFixed(1),
          'appointmentsPerClient': appointmentsPerClient.toStringAsFixed(1),
        },
        'facilityDistribution': facilityNames,
        'insights': [
          'Total appointments scheduled: $totalAppointments',
          'Active health facilities: $totalFacilities',
          'Clients with appointments: $totalClients',
          'Average appointments per facility: ${appointmentsPerFacility.toStringAsFixed(1)}',
          'Average appointments per client: ${appointmentsPerClient.toStringAsFixed(1)}',
          'Top facilities: ${facilityNames.join(', ')}',
        ],
        'recommendations': _getAppointmentRecommendations(
          appointmentsPerFacility,
          totalAppointments,
        ),
      };
    } catch (e) {
      return {
        'title': 'Appointment Analytics Report',
        'error': 'Failed to fetch appointment data: $e',
      };
    }
  }

  /// Generate appointment recommendations
  List<String> _getAppointmentRecommendations(
    double appointmentsPerFacility,
    int totalAppointments,
  ) {
    List<String> recommendations = [];

    if (appointmentsPerFacility < 1) {
      recommendations.add(
        'Consider promoting appointment booking to increase facility utilization',
      );
      recommendations.add(
        'Review appointment scheduling process for efficiency',
      );
    } else if (appointmentsPerFacility > 10) {
      recommendations.add(
        'High appointment volume! Consider expanding facility capacity',
      );
    }

    if (totalAppointments < 5) {
      recommendations.add(
        'Focus on encouraging clients to schedule regular appointments',
      );
    } else if (totalAppointments > 50) {
      recommendations.add(
        'Excellent appointment engagement! Monitor for scheduling conflicts',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Appointment scheduling is performing well');
    }

    return recommendations;
  }

  void _showDetailedReportPreviewDialog(
    String reportType,
    Map<String, dynamic> reportData,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              reportData['title'] ?? _getReportDisplayName(reportType),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reportData.containsKey('error')) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reportData['error'],
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Report Header
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generated: ${_formatDateTime(reportData['generatedAt'])}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Period: ${reportData['period'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Summary Section
                      if (reportData.containsKey('summary')) ...[
                        const Text(
                          '📊 Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children:
                                (reportData['summary'] as Map<String, dynamic>)
                                    .entries
                                    .map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatSummaryKey(entry.key),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              entry.value.toString(),
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Insights Section
                      if (reportData.containsKey('insights')) ...[
                        const Text(
                          '💡 Key Insights',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(reportData['insights'] as List<dynamic>).map(
                          (insight) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(insight.toString())),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Recommendations Section
                      if (reportData.containsKey('recommendations')) ...[
                        const Text(
                          '🎯 Recommendations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children:
                                (reportData['recommendations'] as List<dynamic>)
                                    .map(
                                      (rec) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline,
                                              color: AppColors.success,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(rec.toString()),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              OutlinedButton.icon(
                onPressed:
                    () => _exportSystemReport(context, reportType, reportData),
                icon: const Icon(Icons.download),
                label: const Text('Export PDF'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to full reports screen for more options
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsScreen(),
                    ),
                  );
                },
                child: const Text('View Full Reports'),
              ),
            ],
          ),
    );
  }

  /// Export system report as PDF
  Future<void> _exportSystemReport(
    BuildContext context,
    String reportType,
    Map<String, dynamic> reportData,
  ) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Generating PDF report...'),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 3),
        ),
      );

      // Extract date range from report data
      final period = reportData['period'] as String? ?? '';
      final dates = period.split(' to ');
      final startDate = dates.isNotEmpty ? dates[0] : '';
      final endDate = dates.length > 1 ? dates[1] : '';

      // Call export API
      final response = await ApiService.instance.exportReportPDF(
        reportType,
        startDate,
        endDate,
      );

      if (response.success && response.data != null && mounted) {
        final pdfUrl = response.data['pdfUrl'] as String?;

        if (pdfUrl != null) {
          // Show success message with download link
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF report generated successfully!'),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'Download',
                textColor: Colors.white,
                onPressed: () {
                  // In a real app, this would open the PDF URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Download URL: $pdfUrl'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          throw Exception('No PDF URL received');
        }
      } else if (mounted) {
        throw Exception(response.message ?? 'Failed to generate PDF');
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show export dialog for bulk data export
  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select data to export:'),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('User Data'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Health Records'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Appointments'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('System Logs'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Export started! You will be notified when complete.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  /// Format DateTime for display
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// Format summary keys for display
  String _formatSummaryKey(String key) {
    switch (key) {
      case 'totalUsers':
        return 'Total Users';
      case 'activeUsers':
        return 'Active Users';
      case 'newUsers':
        return 'New Users';
      case 'engagementRate':
        return 'Engagement Rate';
      case 'totalRecords':
        return 'Total Records';
      case 'totalClients':
        return 'Total Clients';
      case 'totalHealthWorkers':
        return 'Health Workers';
      case 'recordsPerClient':
        return 'Records/Client';
      case 'recordsPerHealthWorker':
        return 'Records/Worker';
      case 'totalAppointments':
        return 'Total Appointments';
      case 'totalFacilities':
        return 'Total Facilities';
      case 'appointmentsPerFacility':
        return 'Appointments/Facility';
      case 'appointmentsPerClient':
        return 'Appointments/Client';
      default:
        return key
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}',
            )
            .trim();
    }
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
