import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // App Settings
  bool _enableNotifications = true;
  bool _enableVoiceCommands = true;
  bool _enableOfflineMode = true;
  bool _enableDataSync = true;
  String _selectedLanguage = 'kinyarwanda';
  String _selectedTheme = 'light';
  double _voiceSensitivity = 0.7;

  // Security Settings
  bool _requireBiometric = false;
  bool _enableTwoFactor = false;
  bool _enableSessionTimeout = true;
  int _sessionTimeoutMinutes = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API/SharedPreferences
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka igenamiterere');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Save to API/SharedPreferences
      await Future.delayed(const Duration(seconds: 1));
      _showSuccessSnackBar('Igenamiterere ryabitswe neza');
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika igenamiterere');
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
      _saveSettings();
    } else if (lowerCommand.contains('kugarura') || lowerCommand.contains('reset')) {
      _showResetDialog();
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kugarura igenamiterere'),
        content: const Text('Urashaka kugarura igenamiterere ryose ku buryo bwambere?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            child: const Text('Emeza'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _enableNotifications = true;
      _enableVoiceCommands = true;
      _enableOfflineMode = true;
      _enableDataSync = true;
      _selectedLanguage = 'kinyarwanda';
      _selectedTheme = 'light';
      _voiceSensitivity = 0.7;
      _requireBiometric = false;
      _enableTwoFactor = false;
      _enableSessionTimeout = true;
      _sessionTimeoutMinutes = 30;
    });
    _showSuccessSnackBar('Igenamiterere ryagaruwe ku buryo bwambere');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTab(isTablet),
                  _buildSecurityTab(isTablet),
                  _buildDataTab(isTablet),
                  _buildAboutTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'save_settings',
            onPressed: _saveSettings,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.save, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Kubika" kugira ngo ubike igenamiterere, cyangwa "Kugarura" kugira ngo ugarure ku buryo bwambere',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga igenamiterere',
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 120 : 100,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Igenamiterere ry\'app',
          style: AppTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textTertiary,
        indicatorColor: AppTheme.primaryColor,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Rusange', icon: Icon(Icons.settings)),
          Tab(text: 'Umutekano', icon: Icon(Icons.security)),
          Tab(text: 'Amakuru', icon: Icon(Icons.storage)),
          Tab(text: 'Kuri app', icon: Icon(Icons.info)),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ururimi n\'insanganyamatsiko'),
          _buildLanguageSelector(isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildThemeSelector(isTablet),
          SizedBox(height: AppTheme.spacing32),
          
          _buildSectionTitle('Amamenyo'),
          _buildSwitchTile(
            'Emera amamenyo',
            'Emera amamenyo y\'app',
            _enableNotifications,
            (value) => setState(() => _enableNotifications = value),
          ),
          SizedBox(height: AppTheme.spacing32),
          
          _buildSectionTitle('Ijwi'),
          _buildSwitchTile(
            'Emera amategeko y\'ijwi',
            'Koresha ijwi gucunga app',
            _enableVoiceCommands,
            (value) => setState(() => _enableVoiceCommands = value),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildVoiceSensitivitySlider(isTablet),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Kwinjira'),
          _buildSwitchTile(
            'Emera biometric',
            'Koresha intoki cyangwa ubuso kwinjira',
            _requireBiometric,
            (value) => setState(() => _requireBiometric = value),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildSwitchTile(
            'Emera two-factor authentication',
            'Ongeraho umutekano mu kwinjira',
            _enableTwoFactor,
            (value) => setState(() => _enableTwoFactor = value),
          ),
          SizedBox(height: AppTheme.spacing32),
          
          _buildSectionTitle('Session'),
          _buildSwitchTile(
            'Session timeout',
            'Sohora nyuma y\'igihe runaka',
            _enableSessionTimeout,
            (value) => setState(() => _enableSessionTimeout = value),
          ),
          if (_enableSessionTimeout) ...[
            SizedBox(height: AppTheme.spacing16),
            _buildSessionTimeoutSelector(isTablet),
          ],
        ],
      ),
    );
  }

  Widget _buildDataTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Sync n\'Offline'),
          _buildSwitchTile(
            'Emera offline mode',
            'Koresha app nta internet',
            _enableOfflineMode,
            (value) => setState(() => _enableOfflineMode = value),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildSwitchTile(
            'Emera data sync',
            'Sync amakuru n\'server',
            _enableDataSync,
            (value) => setState(() => _enableDataSync = value),
          ),
          SizedBox(height: AppTheme.spacing32),
          
          _buildSectionTitle('Gucunga amakuru'),
          _buildActionTile(
            'Gusiba cache',
            'Siba amakuru y\'agateganyo',
            Icons.delete_sweep,
            () => _showClearCacheDialog(),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildActionTile(
            'Export amakuru',
            'Sohora amakuru yawe',
            Icons.download,
            () => _exportData(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppTheme.spacing16),
                Text(
                  'Ubuzima',
                  style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version 1.0.0',
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing32),
          
          _buildSectionTitle('Kuri app'),
          _buildInfoTile('Uwayikoreye', 'Ubuzima Team'),
          _buildInfoTile('Itariki y\'gusohora', '2024'),
          _buildInfoTile('License', 'MIT License'),
          
          SizedBox(height: AppTheme.spacing32),
          _buildSectionTitle('Ubufasha'),
          _buildActionTile(
            'Ubufasha',
            'Bona ubufasha bw\'app',
            Icons.help,
            () => _showHelp(),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildActionTile(
            'Tanga igitekerezo',
            'Tanga igitekerezo cyangwa ikibazo',
            Icons.feedback,
            () => _sendFeedback(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildLanguageSelector(bool isTablet) {
    return Card(
      child: ListTile(
        title: const Text('Ururimi'),
        subtitle: Text(_getLanguageName(_selectedLanguage)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildThemeSelector(bool isTablet) {
    return Card(
      child: ListTile(
        title: const Text('Insanganyamatsiko'),
        subtitle: Text(_getThemeName(_selectedTheme)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showThemeDialog(),
      ),
    );
  }

  Widget _buildVoiceSensitivitySlider(bool isTablet) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ubwoba bw\'ijwi'),
            Slider(
              value: _voiceSensitivity,
              onChanged: (value) => setState(() => _voiceSensitivity = value),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTimeoutSelector(bool isTablet) {
    return Card(
      child: ListTile(
        title: const Text('Igihe cyo gusohoka'),
        subtitle: Text('$_sessionTimeoutMinutes iminota'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showTimeoutDialog(),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary)),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'kinyarwanda':
        return 'Ikinyarwanda';
      case 'english':
        return 'English';
      case 'french':
        return 'Français';
      default:
        return 'Ikinyarwanda';
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Urumuri';
      case 'dark':
        return 'Umwijima';
      case 'auto':
        return 'Byikora';
      default:
        return 'Urumuri';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hitamo ururimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Ikinyarwanda'),
              value: 'kinyarwanda',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'english',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'french',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hitamo insanganyamatsiko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Urumuri'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Umwijima'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Byikora'),
              value: 'auto',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hitamo igihe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 60, 120].map((minutes) => RadioListTile<int>(
            title: Text('$minutes iminota'),
            value: minutes,
            groupValue: _sessionTimeoutMinutes,
            onChanged: (value) {
              setState(() => _sessionTimeoutMinutes = value!);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gusiba cache'),
        content: const Text('Urashaka gusiba cache yose?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Cache yasibwe');
            },
            child: const Text('Emeza'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    _showSuccessSnackBar('Export amakuru - Izaza vuba...');
  }

  void _showHelp() {
    _showSuccessSnackBar('Ubufasha - Izaza vuba...');
  }

  void _sendFeedback() {
    _showSuccessSnackBar('Tanga igitekerezo - Izaza vuba...');
  }
}
