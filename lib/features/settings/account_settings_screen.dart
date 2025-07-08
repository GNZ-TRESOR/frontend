import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isLoading = false;
  bool _isEditing = false;

  // Account Information
  final TextEditingController _nameController = TextEditingController(text: 'Mukamana Marie');
  final TextEditingController _emailController = TextEditingController(text: 'marie@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+250788123456');
  final TextEditingController _locationController = TextEditingController(text: 'Kigali, Rwanda');
  
  // Personal Information
  String _selectedGender = 'female';
  DateTime _dateOfBirth = DateTime(1990, 5, 15);
  String _maritalStatus = 'married';
  String _occupation = 'teacher';

  // Emergency Contact
  final TextEditingController _emergencyNameController = TextEditingController(text: 'Uwimana Jean');
  final TextEditingController _emergencyPhoneController = TextEditingController(text: '+250788654321');
  String _emergencyRelationship = 'spouse';

  @override
  void initState() {
    super.initState();
    _loadAccountSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amakuru y\'konti');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAccountSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Save to API
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isEditing = false);
      _showSuccessSnackBar('Amakuru y\'konti yabitswe neza');
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika amakuru y\'konti');
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
    if (lowerCommand.contains('guhindura') || lowerCommand.contains('edit')) {
      setState(() => _isEditing = !_isEditing);
    } else if (lowerCommand.contains('kubika') || lowerCommand.contains('save')) {
      if (_isEditing) _saveAccountSettings();
    } else if (lowerCommand.contains('siga') || lowerCommand.contains('cancel')) {
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Konti yanjye'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _saveAccountSettings,
              icon: const Icon(Icons.save),
              tooltip: 'Kubika amahinduka',
            )
          else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: 'Guhindura amakuru',
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
                  _buildProfileHeader(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildBasicInformation(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildPersonalInformation(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildEmergencyContact(isTablet),
                  SizedBox(height: AppTheme.spacing32),
                  _buildAccountActions(isTablet),
                ],
              ),
            ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Guhindura" kugira ngo uhindure, "Kubika" kugira ngo ubike, cyangwa "Siga" kugira ngo usige',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga konti',
      ),
    );
  }

  Widget _buildProfileHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: isTablet ? 50 : 40,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: isTablet ? 50 : 40,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _changeProfilePicture,
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      iconSize: 16,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text,
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  _emailController.text,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  'Umunyangire',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildBasicInformation(bool isTablet) {
    return _buildSection(
      'Amakuru y\'ibanze',
      Icons.person,
      [
        _buildTextField(
          'Amazina',
          _nameController,
          Icons.person_outline,
          enabled: _isEditing,
        ),
        _buildTextField(
          'Email',
          _emailController,
          Icons.email_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildTextField(
          'Telefoni',
          _phoneController,
          Icons.phone_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        _buildTextField(
          'Aho utuye',
          _locationController,
          Icons.location_on_outlined,
          enabled: _isEditing,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildPersonalInformation(bool isTablet) {
    return _buildSection(
      'Amakuru y\'umuntu',
      Icons.info,
      [
        _buildDropdownField(
          'Igitsina',
          _selectedGender,
          {
            'female': 'Umugore',
            'male': 'Umugabo',
            'other': 'Ikindi',
          },
          (value) => setState(() => _selectedGender = value!),
          enabled: _isEditing,
        ),
        _buildDateField(
          'Itariki y\'amavuko',
          _dateOfBirth,
          (date) => setState(() => _dateOfBirth = date),
          enabled: _isEditing,
        ),
        _buildDropdownField(
          'Ubushakanye',
          _maritalStatus,
          {
            'single': 'Ingaragu',
            'married': 'Washakanye',
            'divorced': 'Watandukanyije',
            'widowed': 'Wapfakaye',
          },
          (value) => setState(() => _maritalStatus = value!),
          enabled: _isEditing,
        ),
        _buildTextField(
          'Umurimo',
          TextEditingController(text: _occupation),
          Icons.work_outline,
          enabled: _isEditing,
          onChanged: (value) => _occupation = value,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildEmergencyContact(bool isTablet) {
    return _buildSection(
      'Uwo guhamagara mu bihe by\'ihutirwa',
      Icons.emergency,
      [
        _buildTextField(
          'Amazina',
          _emergencyNameController,
          Icons.person_outline,
          enabled: _isEditing,
        ),
        _buildTextField(
          'Telefoni',
          _emergencyPhoneController,
          Icons.phone_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        _buildDropdownField(
          'Ubusabane',
          _emergencyRelationship,
          {
            'spouse': 'Umukunzi',
            'parent': 'Umubyeyi',
            'sibling': 'Umuvandimwe',
            'friend': 'Inshuti',
            'other': 'Ikindi',
          },
          (value) => setState(() => _emergencyRelationship = value!),
          enabled: _isEditing,
        ),
      ],
      isTablet,
    );
  }

  Widget _buildSection(
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Column(children: children),
          ),
          SizedBox(height: AppTheme.spacing16),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          filled: !enabled,
          fillColor: enabled ? null : AppTheme.backgroundColor,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          filled: !enabled,
          fillColor: enabled ? null : AppTheme.backgroundColor,
        ),
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: TextField(
        readOnly: true,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: enabled ? const Icon(Icons.arrow_drop_down) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          filled: !enabled,
          fillColor: enabled ? null : AppTheme.backgroundColor,
        ),
        controller: TextEditingController(
          text: '${date.day}/${date.month}/${date.year}',
        ),
        onTap: enabled ? () => _selectDate(onChanged) : null,
      ),
    );
  }

  Widget _buildAccountActions(bool isTablet) {
    return Column(
      children: [
        if (_isEditing) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveAccountSettings,
              icon: const Icon(Icons.save),
              label: const Text('Kubika amahinduka'),
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
              onPressed: () => setState(() => _isEditing = false),
              icon: const Icon(Icons.cancel),
              label: const Text('Siga'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor),
                foregroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text('Guhindura amakuru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: AppTheme.spacing24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _changePassword,
            icon: const Icon(Icons.lock),
            label: const Text('Guhindura ijambo ry\'ibanga'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.warningColor),
              foregroundColor: AppTheme.warningColor,
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
            onPressed: _deleteAccount,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Gusiba konti'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.errorColor),
              foregroundColor: AppTheme.errorColor,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(ValueChanged<DateTime> onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      onChanged(date);
    }
  }

  void _changeProfilePicture() {
    // TODO: Implement profile picture change
    _showSuccessSnackBar('Guhindura ifoto - Izaza vuba...');
  }

  void _changePassword() {
    // TODO: Implement password change
    _showSuccessSnackBar('Guhindura ijambo ry\'ibanga - Izaza vuba...');
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gusiba konti'),
        content: const Text(
          'Iyi ngirakamaro izasiba konti yawe mu buryo budasubirwaho. '
          'Amakuru yawe yose azasibwa. Urashaka gukomeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              _showSuccessSnackBar('Konti yasibwe');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Siba', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
