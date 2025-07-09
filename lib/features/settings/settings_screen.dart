import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/language_service.dart';
import '../../core/providers/theme_provider.dart';
import '../../widgets/voice_button.dart';
import 'privacy_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'account_settings_screen.dart';
import 'language_selection_screen.dart';
import 'database_config_screen.dart';
import 'backend_test_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  // General Settings
  bool _enableNotifications = true;
  bool _enableVoiceCommands = true;
  bool _enableOfflineMode = true;

  String _selectedTheme = 'light';
  double _textSize = 1.0;

  // Privacy Settings
  bool _shareDataForResearch = false;
  bool _allowAnalytics = true;
  bool _showOnlineStatus = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load from SharedPreferences or API
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka igenamiterere');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Save to SharedPreferences or API
      await Future.delayed(const Duration(milliseconds: 500));
      _showSuccessSnackBar('Igenamiterere ryabitswe neza');
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika igenamiterere');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.successColor),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('kubika') || lowerCommand.contains('save')) {
      _saveSettings();
    } else if (lowerCommand.contains('garura') ||
        lowerCommand.contains('reset')) {
      _resetSettings();
    } else if (lowerCommand.contains('amamenyo') ||
        lowerCommand.contains('notification')) {
      _navigateToNotificationSettings();
    } else if (lowerCommand.contains('ubwite') ||
        lowerCommand.contains('privacy')) {
      _navigateToPrivacySettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Igenamiterere'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Kubika igenamiterere',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGeneralSettings(isTablet),
                    SizedBox(height: AppTheme.spacing32),
                    _buildAppearanceSettings(isTablet),
                    SizedBox(height: AppTheme.spacing32),
                    _buildQuickSettings(isTablet),
                    SizedBox(height: AppTheme.spacing32),
                    _buildAdvancedSettings(isTablet),
                    SizedBox(height: AppTheme.spacing32),
                    _buildActionButtons(isTablet),
                  ],
                ),
              ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Kubika" kugira ngo ubike, "Garura" kugira ngo ugarure, "Amamenyo" kugira ngo ugere ku mamenyo, cyangwa "Ubwite" kugira ngo ugere ku bwite',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga igenamiterere',
      ),
    );
  }

  Widget _buildGeneralSettings(bool isTablet) {
    return _buildSettingsSection('Igenamiterere rusange', Icons.settings, [
      _buildSwitchTile(
        'Emera amamenyo',
        'Emera amamenyo y\'app',
        _enableNotifications,
        (value) => setState(() => _enableNotifications = value),
      ),
      _buildSwitchTile(
        'Koresha ijwi',
        'Emera amabwiriza y\'ijwi',
        _enableVoiceCommands,
        (value) => setState(() => _enableVoiceCommands = value),
      ),
      _buildSwitchTile(
        'Gukora nta murandasi',
        'Emera gukora nta murandasi',
        _enableOfflineMode,
        (value) => setState(() => _enableOfflineMode = value),
      ),
      _buildLanguageSelector(isTablet),
    ], isTablet);
  }

  Widget _buildAppearanceSettings(bool isTablet) {
    return _buildSettingsSection('Isura', Icons.palette, [
      _buildThemeSelector(isTablet),
      _buildTextSizeSlider(isTablet),
    ], isTablet);
  }

  Widget _buildQuickSettings(bool isTablet) {
    return _buildSettingsSection('Igenamiterere ryihuse', Icons.flash_on, [
      _buildNavigationTile(
        'Amamenyo',
        'Gena amamenyo n\'ibimenyetso',
        Icons.notifications,
        () => _navigateToNotificationSettings(),
      ),
      _buildNavigationTile(
        'Ubwite',
        'Gena ubwite n\'umutekano',
        Icons.privacy_tip,
        () => _navigateToPrivacySettings(),
      ),
      _buildNavigationTile(
        'Konti',
        'Gena amakuru y\'konti yawe',
        Icons.account_circle,
        () => _navigateToAccountSettings(),
      ),
    ], isTablet);
  }

  Widget _buildAdvancedSettings(bool isTablet) {
    return _buildSettingsSection('Igenamiterere ryimbitse', Icons.tune, [
      _buildSwitchTile(
        'Gusangira amakuru y\'ubushakashatsi',
        'Emera gusangira amakuru kugira ngo dufashe ubushakashatsi',
        _shareDataForResearch,
        (value) => setState(() => _shareDataForResearch = value),
      ),
      _buildSwitchTile(
        'Emera analytics',
        'Dufashe kunoza app hakoreshejwe analytics',
        _allowAnalytics,
        (value) => setState(() => _allowAnalytics = value),
      ),
      _buildSwitchTile(
        'Erekana uko uri',
        'Abandi bashobora kubona niba uri online',
        _showOnlineStatus,
        (value) => setState(() => _showOnlineStatus = value),
      ),
      _buildNavigationTile(
        'Database Configuration',
        'Configure PostgreSQL database connection',
        Icons.storage,
        () => _navigateToDatabaseConfig(),
      ),
      _buildNavigationTile(
        'Backend Test',
        'Test backend services and connectivity',
        Icons.network_check,
        () => _navigateToBackendTest(),
      ),
    ], isTablet);
  }

  Widget _buildSettingsSection(
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
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSelector(bool isTablet) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.currentLanguageOption;

    return ListTile(
      leading: Icon(Icons.language, color: AppTheme.primaryColor),
      title: const Text('Ururimi'),
      subtitle: Text('${currentLanguage.nativeName} (${currentLanguage.name})'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToLanguageSelection(),
    );
  }

  Widget _buildThemeSelector(bool isTablet) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(
            themeProvider.currentThemeIcon,
            color: AppTheme.primaryColor,
          ),
          title: const Text('Igenamiterere'),
          subtitle: Text(themeProvider.currentThemeName),
          trailing: const Icon(Icons.chevron_right),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              ),
        );
      },
    );
  }

  Widget _buildTextSizeSlider(bool isTablet) {
    return ListTile(
      leading: Icon(Icons.text_fields, color: AppTheme.primaryColor),
      title: const Text('Ingano y\'inyandiko'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${(_textSize * 100).round()}%'),
          Slider(
            value: _textSize,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            onChanged: (value) => setState(() => _textSize = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.refresh),
            label: const Text('Garura ku buryo bwambere'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Urumuri';
      case 'dark':
        return 'Umwijima';
      case 'system':
        return 'Gukurikiza sisitemu';
      default:
        return 'Urumuri';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hitamo insanganyamatsiko'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['light', 'dark', 'system']
                      .map(
                        (theme) => RadioListTile<String>(
                          title: Text(_getThemeLabel(theme)),
                          value: theme,
                          groupValue: _selectedTheme,
                          onChanged: (value) {
                            setState(() => _selectedTheme = value!);
                            Navigator.pop(context);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Siga'),
              ),
            ],
          ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Garura igenamiterere'),
            content: const Text(
              'Urashaka gugarura igenamiterere ku buryo bwambere?',
            ),
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
                    _enableVoiceCommands = true;
                    _enableOfflineMode = true;
                    _selectedTheme = 'light';
                    _textSize = 1.0;
                    _shareDataForResearch = false;
                    _allowAnalytics = true;
                    _showOnlineStatus = true;
                  });
                  _showSuccessSnackBar(
                    'Igenamiterere ryagaruwe ku buryo bwambere',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Garura',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _navigateToPrivacySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }

  void _navigateToAccountSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
    );
  }

  void _navigateToLanguageSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
    );
  }

  void _navigateToDatabaseConfig() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DatabaseConfigScreen()),
    );
  }

  void _navigateToBackendTest() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const BackendTestScreen()));
  }
}
