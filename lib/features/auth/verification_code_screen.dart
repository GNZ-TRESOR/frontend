import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/voice_button.dart';
import 'new_password_screen.dart';
import 'login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final String
  verificationType; // 'password_reset', 'email_verification', 'phone_verification'
  final String? phoneNumber;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    this.verificationType = 'password_reset',
    this.phoneNumber,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _timer;
  String _verificationCode = '';

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    _updateVerificationCode();
  }

  void _onCodeDeleted(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }

    _updateVerificationCode();
  }

  void _updateVerificationCode() {
    _verificationCode =
        _controllers.map((controller) => controller.text).join();

    if (_verificationCode.length == 6) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationCode.length != 6) {
      _showErrorMessage('Andika kode yose y\'imibare 6');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool isValid = false;

      switch (widget.verificationType) {
        case 'password_reset':
          isValid = await _authService.verifyPasswordResetCode(
            widget.email,
            _verificationCode,
          );
          break;
        case 'email_verification':
          isValid = await _authService.verifyEmailCode(
            widget.email,
            _verificationCode,
          );
          break;
        case 'phone_verification':
          isValid = await _authService.verifyPhoneCode(
            widget.phoneNumber ?? '',
            _verificationCode,
          );
          break;
      }

      if (mounted) {
        if (isValid) {
          _handleVerificationSuccess();
        } else {
          _showErrorMessage('Kode ntiyemewe. Gerageza ukundi.');
          _clearCode();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Habaye ikosa mu kwemeza kode. Gerageza ukundi.');
        _clearCode();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleVerificationSuccess() {
    switch (widget.verificationType) {
      case 'password_reset':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => NewPasswordScreen(
                  email: widget.email,
                  verificationCode: _verificationCode,
                ),
          ),
        );
        break;
      case 'email_verification':
        _showSuccessMessage('Email yawe yemejwe neza!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        break;
      case 'phone_verification':
        _showSuccessMessage('Telefoni yawe yemejwe neza!');
        Navigator.of(context).pop(true);
        break;
    }
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _verificationCode = '';
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      bool sent = false;

      switch (widget.verificationType) {
        case 'password_reset':
          sent = await _authService.sendPasswordResetCode(widget.email);
          break;
        case 'email_verification':
          sent = await _authService.sendEmailVerificationCode(widget.email);
          break;
        case 'phone_verification':
          sent = await _authService.sendPhoneVerificationCode(
            widget.phoneNumber ?? '',
          );
          break;
      }

      if (mounted) {
        if (sent) {
          _showSuccessMessage('Kode nshya yoherejwe!');
          _startResendCountdown();
          _clearCode();
        } else {
          _showErrorMessage('Ntibyashobokaye kohereza kode. Gerageza ukundi.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Habaye ikosa mu kohereza kode. Gerageza ukundi.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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
    if (lowerCommand.contains('resend') || lowerCommand.contains('subira')) {
      _resendCode();
    } else if (lowerCommand.contains('back') ||
        lowerCommand.contains('subira inyuma')) {
      Navigator.of(context).pop();
    }
  }

  String get _getTitle {
    switch (widget.verificationType) {
      case 'email_verification':
        return 'Emeza Email';
      case 'phone_verification':
        return 'Emeza Telefoni';
      default:
        return 'Emeza Kode';
    }
  }

  String get _getSubtitle {
    switch (widget.verificationType) {
      case 'email_verification':
        return 'Twaguhaye kode kuri email yawe ${widget.email}';
      case 'phone_verification':
        return 'Twaguhaye kode kuri telefoni yawe ${widget.phoneNumber}';
      default:
        return 'Twaguhaye kode yo guhindura ijambo ry\'ibanga kuri email yawe ${widget.email}';
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: isTablet ? AppTheme.spacing64 : AppTheme.spacing32,
              ),
              _buildHeader(isTablet),
              SizedBox(
                height: isTablet ? AppTheme.spacing48 : AppTheme.spacing32,
              ),
              _buildCodeInput(isTablet),
              SizedBox(height: AppTheme.spacing32),
              _buildResendSection(isTablet),
              SizedBox(height: AppTheme.spacing24),
              _buildBackToLoginButton(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga "subira" kugira ngo usubire inyuma cyangwa "subira kohereza" kugira ngo usubire kohereza kode',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi',
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      children: [
        Container(
          width: isTablet ? 120 : 80,
          height: isTablet ? 120 : 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Icon(
            Icons.verified_user,
            size: isTablet ? 60 : 40,
            color: Colors.white,
          ),
        ).animate().scale(delay: 200.ms, duration: 600.ms),
        SizedBox(height: AppTheme.spacing24),
        Text(
          _getTitle,
          style: AppTheme.headingLarge.copyWith(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
        SizedBox(height: AppTheme.spacing12),
        Text(
          _getSubtitle,
          textAlign: TextAlign.center,
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
      ],
    );
  }

  Widget _buildCodeInput(bool isTablet) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: isTablet ? 60 : 45,
              height: isTablet ? 60 : 45,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _controllers[index].text.isNotEmpty
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (value) => _onCodeChanged(value, index),
                onTap: () {
                  if (_controllers[index].text.isNotEmpty) {
                    _controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index].text.length),
                    );
                  }
                },
                onEditingComplete: () {
                  if (_controllers[index].text.isEmpty && index > 0) {
                    _onCodeDeleted(index);
                  }
                },
              ),
            );
          }),
        ).animate().slideX(begin: 0.3, delay: 400.ms),
        if (_isLoading) ...[
          SizedBox(height: AppTheme.spacing24),
          const CircularProgressIndicator(),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Tugira ngo dukemeze kode...',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildResendSection(bool isTablet) {
    return Column(
      children: [
        if (_resendCountdown > 0) ...[
          Text(
            'Ushobora gusaba kode nshya nyuma y\'amasegonda $_resendCountdown',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ] else ...[
          Text(
            'Ntabwo wakiriye kode?',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.spacing8),
          TextButton(
            onPressed: _isResending ? null : _resendCode,
            child:
                _isResending
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      'Saba kode nshya',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildBackToLoginButton(bool isTablet) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Text(
        'Subira ku kwinjira',
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}
