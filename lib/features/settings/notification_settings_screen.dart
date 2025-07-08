import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = false;

  // General Notifications
  bool _enableNotifications = true;
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = false;
  bool _enableSMSNotifications = false;

  // Health Notifications
  bool _medicationReminders = true;
  bool _appointmentReminders = true;
  bool _healthTips = true;
  bool _cycleReminders = true;
  bool _contraceptionReminders = true;

  // Community Notifications
  bool _newMessages = true;
  bool _groupUpdates = true;
  bool _eventNotifications = true;
  bool _forumReplies = true;

  // System Notifications
  bool _appUpdates = true;
  bool _securityAlerts = true;
  bool _maintenanceNotices = false;

  // Notification Times
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);
  bool _enableQuietHours = true;
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from SharedPreferences or API
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka igenamiterere ry\'amamenyo');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNotificationSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Save to SharedPreferences or API
      await Future.delayed(const Duration(milliseconds: 500));
      _showSuccessSnackBar('Igenamiterere ry\'amamenyo ryabitswe neza');
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika igenamiterere ry\'amamenyo');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('kubika') || lowerCommand.contains('save')) {
      _saveNotificationSettings();
    } else if (lowerCommand.contains('garura') || lowerCommand.contains('reset')) {
      _resetNotificationSettings();
    } else if (lowerCommand.contains('gerageza') || lowerCommand.contains('test')) {
      _testNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Amamenyo'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveNotificationSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Kubika igenamiterere',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralNotifications(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildHealthNotifications(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildCommunityNotifications(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildSystemNotifications(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildNotificationTiming(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildActionButtons(isTablet),
                ],
              ),
            ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Kubika" kugira ngo ubike, "Garura" kugira ngo ugarure, cyangwa "Gerageza" kugira ngo ugerageze amamenyo',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga amamenyo',
      ),
    );
  }

  Widget _buildGeneralNotifications(bool isTablet) {
    return _buildNotificationSection(
      'Amamenyo rusange',
      Icons.notifications,
      [
        _buildSwitchTile(
          'Emera amamenyo',
          'Emera amamenyo yose y\'app',
          _enableNotifications,
          (value) => setState(() => _enableNotifications = value),
        ),
        _buildSwitchTile(
          'Push notifications',
          'Emera amamenyo y\'app ku telefoni yawe',
          _enablePushNotifications,
          (value) => setState(() => _enablePushNotifications = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Email notifications',
          'Emera amamenyo kuri email yawe',
          _enableEmailNotifications,
          (value) => setState(() => _enableEmailNotifications = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'SMS notifications',
          'Emera amamenyo kuri telefoni yawe',
          _enableSMSNotifications,
          (value) => setState(() => _enableSMSNotifications = value),
          enabled: _enableNotifications,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildHealthNotifications(bool isTablet) {
    return _buildNotificationSection(
      'Amamenyo y\'ubuzima',
      Icons.health_and_safety,
      [
        _buildSwitchTile(
          'Ibirikwizera by\'imiti',
          'Kwibutsa igihe cyo gufata imiti',
          _medicationReminders,
          (value) => setState(() => _medicationReminders = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Ibirikwizera by\'inama',
          'Kwibutsa inama n\'isuzuma',
          _appointmentReminders,
          (value) => setState(() => _appointmentReminders = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Amakuru y\'ubuzima',
          'Emera amakuru n\'amabwiriza y\'ubuzima',
          _healthTips,
          (value) => setState(() => _healthTips = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Ibirikwizera by\'imihango',
          'Kwibutsa imihango yawe',
          _cycleReminders,
          (value) => setState(() => _cycleReminders = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Ibirikwizera by\'ubwiyunge',
          'Kwibutsa uburyo bwo kurinda inda',
          _contraceptionReminders,
          (value) => setState(() => _contraceptionReminders = value),
          enabled: _enableNotifications,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildCommunityNotifications(bool isTablet) {
    return _buildNotificationSection(
      'Amamenyo y\'umuryango',
      Icons.group,
      [
        _buildSwitchTile(
          'Ubutumwa bushya',
          'Menyesha iyo uhawe ubutumwa bushya',
          _newMessages,
          (value) => setState(() => _newMessages = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Amakuru y\'amatsinda',
          'Menyesha amakuru mashya mu matsinda yawe',
          _groupUpdates,
          (value) => setState(() => _groupUpdates = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Amamenyo y\'ibirori',
          'Menyesha ibirori bishya n\'amahinduka',
          _eventNotifications,
          (value) => setState(() => _eventNotifications = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Ibisubizo by\'ibiganiro',
          'Menyesha ibisubizo ku biganiro byawe',
          _forumReplies,
          (value) => setState(() => _forumReplies = value),
          enabled: _enableNotifications,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildSystemNotifications(bool isTablet) {
    return _buildNotificationSection(
      'Amamenyo ya sisitemu',
      Icons.system_update,
      [
        _buildSwitchTile(
          'Amavugurura y\'app',
          'Menyesha amavugurura mashya y\'app',
          _appUpdates,
          (value) => setState(() => _appUpdates = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Amamenyo y\'umutekano',
          'Menyesha ibibazo by\'umutekano',
          _securityAlerts,
          (value) => setState(() => _securityAlerts = value),
          enabled: _enableNotifications,
        ),
        _buildSwitchTile(
          'Amakuru y\'ubusugire',
          'Menyesha ubusugire bw\'app',
          _maintenanceNotices,
          (value) => setState(() => _maintenanceNotices = value),
          enabled: _enableNotifications,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildNotificationTiming(bool isTablet) {
    return _buildNotificationSection(
      'Igihe cy\'amamenyo',
      Icons.schedule,
      [
        _buildTimeTile(
          'Igihe cy\'igitondo',
          'Igihe cyo kohereza amamenyo y\'igitondo',
          _morningTime,
          (time) => setState(() => _morningTime = time),
        ),
        _buildTimeTile(
          'Igihe cy\'umugoroba',
          'Igihe cyo kohereza amamenyo y\'umugoroba',
          _eveningTime,
          (time) => setState(() => _eveningTime = time),
        ),
        _buildSwitchTile(
          'Emera igihe cy\'utuze',
          'Hagarika amamenyo mu gihe cy\'utuze',
          _enableQuietHours,
          (value) => setState(() => _enableQuietHours = value),
          enabled: _enableNotifications,
        ),
        if (_enableQuietHours) ...[
          _buildTimeTile(
            'Gutangira utuze',
            'Igihe cyo gutangira utuze',
            _quietStartTime,
            (time) => setState(() => _quietStartTime = time),
          ),
          _buildTimeTile(
            'Kurangiza utuze',
            'Igihe cyo kurangiza utuze',
            _quietEndTime,
            (time) => setState(() => _quietEndTime = time),
          ),
        ],
      ],
      isTablet,
    );
  }

  Widget _buildNotificationSection(
    String title,
    IconData icon,
    List<Widget> children,
    bool isTablet,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                SizedBox(width: AppTheme.spacing12),
                Text(
                  title,
                  style: AppTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : AppTheme.textTertiary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? AppTheme.textSecondary : AppTheme.textTertiary,
        ),
      ),
      value: enabled ? value : false,
      onChanged: enabled ? onChanged : null,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildTimeTile(
    String title,
    String subtitle,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: () async {
          final newTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (newTime != null) {
            onChanged(newTime);
          }
        },
        child: Text(time.format(context)),
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveNotificationSettings,
            icon: const Icon(Icons.save),
            label: const Text('Kubika igenamiterere'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetNotificationSettings,
                icon: const Icon(Icons.refresh),
                label: const Text('Garura'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Gerageza'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _resetNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Garura igenamiterere ry\'amamenyo'),
        content: const Text('Urashaka gugarura igenamiterere ry\'amamenyo ku buryo bwambere?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _enableNotifications = true;
                _enablePushNotifications = true;
                _enableEmailNotifications = false;
                _enableSMSNotifications = false;
                _medicationReminders = true;
                _appointmentReminders = true;
                _healthTips = true;
                _cycleReminders = true;
                _contraceptionReminders = true;
                _newMessages = true;
                _groupUpdates = true;
                _eventNotifications = true;
                _forumReplies = true;
                _appUpdates = true;
                _securityAlerts = true;
                _maintenanceNotices = false;
                _morningTime = const TimeOfDay(hour: 8, minute: 0);
                _eveningTime = const TimeOfDay(hour: 20, minute: 0);
                _enableQuietHours = true;
                _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
                _quietEndTime = const TimeOfDay(hour: 7, minute: 0);
              });
              _showSuccessSnackBar('Igenamiterere ry\'amamenyo ryagaruwe ku buryo bwambere');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Garura', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _testNotification() {
    // TODO: Implement test notification
    _showSuccessSnackBar('Amamenyo y\'ikizamini yoherejwe!');
  }
}
