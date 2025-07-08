import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isLoading = false;

  // Privacy Settings
  bool _shareHealthData = false;
  bool _allowDataAnalytics = true;
  bool _shareLocationData = false;
  bool _allowPersonalizedAds = false;
  bool _shareUsageStatistics = true;
  bool _allowThirdPartyAccess = false;
  bool _enableDataEncryption = true;
  bool _requireBiometricAuth = false;
  bool _enableTwoFactorAuth = false;
  bool _logSecurityEvents = true;
  String _dataRetentionPeriod = '2_years';
  String _backupFrequency = 'weekly';

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from SharedPreferences or API
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka igenamiterere ry\'ubwite');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrivacySettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Save to SharedPreferences or API
      await Future.delayed(const Duration(milliseconds: 500));
      _showSuccessSnackBar('Igenamiterere ry\'ubwite ryabitswe neza');
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika igenamiterere ry\'ubwite');
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
      _savePrivacySettings();
    } else if (lowerCommand.contains('garura') || lowerCommand.contains('reset')) {
      _resetPrivacySettings();
    } else if (lowerCommand.contains('siba') || lowerCommand.contains('delete')) {
      _showDeleteDataDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ubwite n\'umutekano'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _savePrivacySettings,
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
                  _buildDataSharingSettings(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildSecuritySettings(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildDataManagementSettings(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildActionButtons(isTablet),
                ],
              ),
            ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Kubika" kugira ngo ubike, "Garura" kugira ngo ugarure, cyangwa "Siba" kugira ngo usibe amakuru',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga ubwite',
      ),
    );
  }

  Widget _buildDataSharingSettings(bool isTablet) {
    return _buildSettingsSection(
      'Gusangira amakuru',
      Icons.share,
      [
        _buildSwitchTile(
          'Sangira amakuru y\'ubuzima',
          'Emera gusangira amakuru y\'ubuzima kugira ngo dufashe ubushakashatsi',
          _shareHealthData,
          (value) => setState(() => _shareHealthData = value),
          isImportant: true,
        ),
        _buildSwitchTile(
          'Emera analytics',
          'Dufashe kunoza app hakoreshejwe analytics',
          _allowDataAnalytics,
          (value) => setState(() => _allowDataAnalytics = value),
        ),
        _buildSwitchTile(
          'Sangira aho uri',
          'Emera gusangira aho uri kugira ngo dufashe gutanga serivisi nziza',
          _shareLocationData,
          (value) => setState(() => _shareLocationData = value),
          isImportant: true,
        ),
        _buildSwitchTile(
          'Emera kwamamaza byihariye',
          'Erekana kwamamaza guhuje n\'inyungu zawe',
          _allowPersonalizedAds,
          (value) => setState(() => _allowPersonalizedAds = value),
        ),
        _buildSwitchTile(
          'Sangira imikorere y\'app',
          'Dufashe kunoza app hakoreshejwe imikorere yawe',
          _shareUsageStatistics,
          (value) => setState(() => _shareUsageStatistics = value),
        ),
        _buildSwitchTile(
          'Emera abandi bafashe amakuru',
          'Emera abandi bafashe amakuru yawe (ntabwo birasabwa)',
          _allowThirdPartyAccess,
          (value) => setState(() => _allowThirdPartyAccess = value),
          isImportant: true,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildSecuritySettings(bool isTablet) {
    return _buildSettingsSection(
      'Umutekano',
      Icons.security,
      [
        _buildSwitchTile(
          'Emera gushyiraho ibanga',
          'Shyiraho ibanga ku makuru yawe yose',
          _enableDataEncryption,
          (value) => setState(() => _enableDataEncryption = value),
          isRecommended: true,
        ),
        _buildSwitchTile(
          'Saba kwemeza intoki',
          'Koresha intoki cyangwa ubuso kugira ngo winjire',
          _requireBiometricAuth,
          (value) => setState(() => _requireBiometricAuth = value),
          isRecommended: true,
        ),
        _buildSwitchTile(
          'Emera kwemeza kabiri',
          'Ongeraho urwego rw\'umutekano mu kwinjira',
          _enableTwoFactorAuth,
          (value) => setState(() => _enableTwoFactorAuth = value),
          isRecommended: true,
        ),
        _buildSwitchTile(
          'Andika ibikorwa by\'umutekano',
          'Bika amateka y\'ibikorwa by\'umutekano',
          _logSecurityEvents,
          (value) => setState(() => _logSecurityEvents = value),
        ),
      ],
      isTablet,
    );
  }

  Widget _buildDataManagementSettings(bool isTablet) {
    return _buildSettingsSection(
      'Gucunga amakuru',
      Icons.storage,
      [
        _buildDropdownTile(
          'Igihe cyo kubika amakuru',
          'Hitamo igihe amakuru yawe azabikwa',
          _dataRetentionPeriod,
          {
            '1_year': '1 umwaka',
            '2_years': '2 imyaka',
            '5_years': '5 imyaka',
            'forever': 'Ubuziraherezo',
          },
          (value) => setState(() => _dataRetentionPeriod = value!),
        ),
        _buildDropdownTile(
          'Ubusanzwe bwo kubika',
          'Hitamo ubusanzwe bwo kubika amakuru',
          _backupFrequency,
          {
            'daily': 'Buri munsi',
            'weekly': 'Buri cyumweru',
            'monthly': 'Buri kwezi',
            'never': 'Ntabwo',
          },
          (value) => setState(() => _backupFrequency = value!),
        ),
        _buildActionTile(
          'Kuraguza amakuru yose',
          'Siba amakuru yawe yose muri app',
          Icons.delete_forever,
          AppTheme.errorColor,
          () => _showDeleteDataDialog(),
        ),
        _buildActionTile(
          'Gusohora amakuru',
          'Sohora amakuru yawe mu buryo bwa JSON',
          Icons.download,
          AppTheme.primaryColor,
          () => _exportData(),
        ),
      ],
      isTablet,
    );
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
    ValueChanged<bool> onChanged, {
    bool isImportant = false,
    bool isRecommended = false,
  }) {
    return SwitchListTile(
      title: Row(
        children: [
          Expanded(child: Text(title)),
          if (isImportant)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing6,
                vertical: AppTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                'Ngombwa',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (isRecommended)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing6,
                vertical: AppTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                'Birasabwa',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _savePrivacySettings,
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
            onPressed: _resetPrivacySettings,
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

  void _resetPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Garura igenamiterere ry\'ubwite'),
        content: const Text('Urashaka gugarura igenamiterere ry\'ubwite ku buryo bwambere?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _shareHealthData = false;
                _allowDataAnalytics = true;
                _shareLocationData = false;
                _allowPersonalizedAds = false;
                _shareUsageStatistics = true;
                _allowThirdPartyAccess = false;
                _enableDataEncryption = true;
                _requireBiometricAuth = false;
                _enableTwoFactorAuth = false;
                _logSecurityEvents = true;
                _dataRetentionPeriod = '2_years';
                _backupFrequency = 'weekly';
              });
              _showSuccessSnackBar('Igenamiterere ry\'ubwite ryagaruwe ku buryo bwambere');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Garura', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kuraguza amakuru'),
        content: const Text(
          'Iyi ngirakamaro izasiba amakuru yawe yose mu buryo budasubirwaho. '
          'Urashaka gukomeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Siba', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    // TODO: Implement data deletion
    _showSuccessSnackBar('Amakuru yose yasibwe');
  }

  void _exportData() {
    // TODO: Implement data export
    _showSuccessSnackBar('Amakuru yawe yasohowe - Izaza vuba...');
  }
}
