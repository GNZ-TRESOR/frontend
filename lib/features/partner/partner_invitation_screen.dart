import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class PartnerInvitationScreen extends StatefulWidget {
  const PartnerInvitationScreen({super.key});

  @override
  State<PartnerInvitationScreen> createState() => _PartnerInvitationScreenState();
}

class _PartnerInvitationScreenState extends State<PartnerInvitationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _invitationMethod = 'sms';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('ohereza') || lowerCommand.contains('send')) {
      _sendInvitation();
    } else if (lowerCommand.contains('sms')) {
      setState(() {
        _invitationMethod = 'sms';
      });
    } else if (lowerCommand.contains('email')) {
      setState(() {
        _invitationMethod = 'email';
      });
    } else if (lowerCommand.contains('whatsapp')) {
      setState(() {
        _invitationMethod = 'whatsapp';
      });
    }
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Send invitation via API
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kohereza ubutumwa');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubutumwa bwoherejwe'),
        content: Text('Ubutumwa bwoherejwe ${_nameController.text} neza. Azakwemera cyangwa akanze.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tuma umukunzi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction card
              _buildIntroductionCard(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Partner information
              _buildPartnerInfoSection(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Invitation method
              _buildInvitationMethodSection(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Custom message
              _buildCustomMessageSection(isTablet),
              
              SizedBox(height: AppTheme.spacing32),
              
              // Send button
              _buildSendButton(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Privacy notice
              _buildPrivacyNotice(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "SMS", "Email", cyangwa "WhatsApp" kugira ngo uhitemo uburyo, cyangwa "Ohereza" kugira ngo wohereze ubutumwa',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gutuma umukunzi',
      ),
    );
  }

  Widget _buildIntroductionCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: isTablet ? 32 : 24,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'Tuma umukunzi wawe',
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'Tuma umukunzi wawe kugira ngo mufatanye mu gufata ibyemezo bijyanye n\'ubuzima bw\'umuryango. Azashobora kugufasha gufata ibyemezo byiza.',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildPartnerInfoSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amakuru y\'umukunzi',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),
          
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Amazina y\'umukunzi *',
              hintText: 'Andika amazina y\'umukunzi wawe',
              prefixIcon: const Icon(Icons.person_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Andika amazina y\'umukunzi';
              }
              return null;
            },
          ),
          
          SizedBox(height: AppTheme.spacing16),
          
          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefoni *',
              hintText: '+250788123456',
              prefixIcon: const Icon(Icons.phone_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Andika nimero ya telefoni';
              }
              if (!value.startsWith('+250') && !value.startsWith('07')) {
                return 'Andika nimero y\'u Rwanda';
              }
              return null;
            },
          ),
          
          SizedBox(height: AppTheme.spacing16),
          
          // Email field (optional)
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email (optional)',
              hintText: 'example@email.com',
              prefixIcon: const Icon(Icons.email_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Andika email nyayo';
                }
              }
              return null;
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(
      begin: -0.3,
      duration: 600.ms,
    );
  }

  Widget _buildInvitationMethodSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hitamo uburyo bwo gutuma',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),
          
          // SMS option
          _buildMethodOption(
            'sms',
            'SMS',
            'Kohereza ubutumwa bwa SMS',
            Icons.sms_rounded,
            AppTheme.primaryColor,
            isTablet,
          ),
          
          SizedBox(height: AppTheme.spacing12),
          
          // Email option
          _buildMethodOption(
            'email',
            'Email',
            'Kohereza ubutumwa bwa email',
            Icons.email_rounded,
            AppTheme.accentColor,
            isTablet,
          ),
          
          SizedBox(height: AppTheme.spacing12),
          
          // WhatsApp option
          _buildMethodOption(
            'whatsapp',
            'WhatsApp',
            'Kohereza ubutumwa bwa WhatsApp',
            Icons.chat_rounded,
            AppTheme.successColor,
            isTablet,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildMethodOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    final isSelected = _invitationMethod == value;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isSelected ? color : AppTheme.primaryColor.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _invitationMethod = value;
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing16 : AppTheme.spacing12),
            child: Row(
              children: [
                Radio<String>(
                  value: value,
                  groupValue: _invitationMethod,
                  onChanged: (newValue) {
                    setState(() {
                      _invitationMethod = newValue!;
                    });
                  },
                  activeColor: color,
                ),
                Icon(
                  icon,
                  color: isSelected ? color : AppTheme.textSecondary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomMessageSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubutumwa bw\'inyongera (optional)',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Andika ubutumwa bw\'inyongera bwandikira umukunzi wawe...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildSendButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _sendInvitation,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          _isLoading ? 'Urohereza...' : 'Ohereza ubutumwa',
          style: AppTheme.labelLarge.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        style: AppTheme.primaryButtonStyle.copyWith(
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildPrivacyNotice(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.infoColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_rounded,
                color: AppTheme.infoColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Ibanga ry\'amakuru',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Amakuru y\'umukunzi wawe azabikwa mu buryo bw\'ibanga. Ntazashobora kubona amakuru yawe atamwemeye. Ashobora kwanga cyangwa kwemera ubufatanye.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }
}
