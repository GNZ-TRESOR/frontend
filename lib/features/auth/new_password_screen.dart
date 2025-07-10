import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/voice_button.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordStrong {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  double get _passwordStrength {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score / 5.0;
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.3) return AppTheme.errorColor;
    if (_passwordStrength < 0.6) return Colors.orange;
    if (_passwordStrength < 0.8) return Colors.yellow[700]!;
    return AppTheme.successColor;
  }

  String get _strengthText {
    if (_passwordStrength < 0.3) return 'Ijambo ry\'ibanga ni ryoroshye';
    if (_passwordStrength < 0.6) return 'Ijambo ry\'ibanga ni ryo hagati';
    if (_passwordStrength < 0.8) return 'Ijambo ry\'ibanga ni ryiza';
    return 'Ijambo ry\'ibanga ni ryuzuye';
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPasswordStrong) {
      _showErrorMessage('Ijambo ry\'ibanga rigomba kuba rifite imbaraga zose');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.resetPasswordWithCode(
        widget.email,
        widget.verificationCode,
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccessMessage('Ijambo ry\'ibanga ryahinduwe neza!');

          // Navigate to login screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          });
        } else {
          _showErrorMessage(
            'Ntibyashobokaye guhindura ijambo ry\'ibanga. Gerageza ukundi.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Habaye ikosa. Gerageza ukundi.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('save') || lowerCommand.contains('bika')) {
      _resetPassword();
    } else if (lowerCommand.contains('back') ||
        lowerCommand.contains('subira inyuma')) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: isTablet ? AppTheme.spacing64 : AppTheme.spacing32,
              ),
              _buildHeader(isTablet),
              SizedBox(
                height: isTablet ? AppTheme.spacing48 : AppTheme.spacing32,
              ),
              _buildPasswordForm(isTablet),
              SizedBox(height: AppTheme.spacing24),
              _buildPasswordStrengthIndicator(),
              SizedBox(height: AppTheme.spacing32),
              _buildResetButton(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga "bika" kugira ngo ubike ijambo ry\'ibanga rishya',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi',
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isTablet ? 120 : 80,
          height: isTablet ? 120 : 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Icon(
            Icons.lock_reset,
            size: isTablet ? 60 : 40,
            color: Colors.white,
          ),
        ).animate().scale(delay: 200.ms, duration: 600.ms),
        SizedBox(height: AppTheme.spacing24),
        Text(
          'Ijambo ry\'ibanga rishya',
          style: AppTheme.headingLarge.copyWith(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
        SizedBox(height: AppTheme.spacing12),
        Text(
          'Andika ijambo ry\'ibanga rishya rifite imbaraga',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
      ],
    );
  }

  Widget _buildPasswordForm(bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Ijambo ry\'ibanga rishya',
              hintText: 'Andika ijambo ry\'ibanga rishya',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ijambo ry\'ibanga ni ngombwa';
              }
              if (value.length < 8) {
                return 'Ijambo ry\'ibanga rigomba kuba rifite byibura inyuguti 8';
              }
              return null;
            },
          ).animate().slideX(begin: 0.3, delay: 400.ms),
          SizedBox(height: AppTheme.spacing20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Emeza ijambo ry\'ibanga',
              hintText: 'Ongera wandike ijambo ry\'ibanga',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Emeza ijambo ry\'ibanga';
              }
              if (value != _passwordController.text) {
                return 'Amagambo y\'ibanga ntabwo ahura';
              }
              return null;
            },
          ).animate().slideX(begin: 0.3, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Imbaraga z\'ijambo ry\'ibanga: ',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              _strengthText,
              style: AppTheme.bodyMedium.copyWith(
                color: _strengthColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing8),
        LinearProgressIndicator(
          value: _passwordStrength,
          backgroundColor: AppTheme.borderColor,
          valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
        ),
        SizedBox(height: AppTheme.spacing16),
        Column(
          children: [
            _buildRequirementItem('Byibura inyuguti 8', _hasMinLength),
            _buildRequirementItem('Inyuguti nkuru', _hasUppercase),
            _buildRequirementItem('Inyuguti nto', _hasLowercase),
            _buildRequirementItem('Umubare', _hasNumber),
            _buildRequirementItem(
              'Ikimenyetso kidasanzwe (!@#\$%)',
              _hasSpecialChar,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? AppTheme.successColor : AppTheme.textSecondary,
          ),
          SizedBox(width: AppTheme.spacing8),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: isMet ? AppTheme.successColor : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: AppTheme.primaryButtonStyle,
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Bika ijambo ry\'ibanga rishya',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    ).animate().slideY(begin: 0.3, delay: 1000.ms);
  }
}
