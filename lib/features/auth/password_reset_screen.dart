import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/voice_button.dart';
import 'login_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _emailSent = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ubutumwa bwo guhindura ijambo ry\'ibanga bwoherejwe kuri email yawe',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorData['message'] ?? 'Habaye ikosa mu kohereza email',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habaye ikosa mu kohereza email. Gerageza ukundi.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('email') || lowerCommand.contains('kohereza')) {
      _sendResetEmail();
    } else if (lowerCommand.contains('garuka') ||
        lowerCommand.contains('login')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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

              // Back Button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ).animate().slideX(begin: -0.3, duration: 600.ms),

              SizedBox(height: AppTheme.spacing24),

              // Header
              _buildHeader(isTablet),

              SizedBox(
                height: isTablet ? AppTheme.spacing48 : AppTheme.spacing32,
              ),

              // Reset Form or Success Message
              _emailSent
                  ? _buildSuccessMessage(isTablet)
                  : _buildResetForm(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga email yawe cyangwa "kohereza" kugira ukohereze email yo guhindura ijambo ry\'ibanga',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi',
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wibagiriye Ijambo ry\'Ibanga?',
          style: AppTheme.headingLarge.copyWith(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),

        SizedBox(height: AppTheme.spacing16),

        Text(
          'Ntago ari ikibazo! Andika email yawe hanyuma tuzagukohereza ubutumwa bwo guhindura ijambo ry\'ibanga.',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
      ],
    );
  }

  Widget _buildResetForm(bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Andika email yawe',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email ni ngombwa';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Andika email nyayo';
              }
              return null;
            },
          ).animate().slideX(begin: 0.3, delay: 400.ms),

          SizedBox(height: AppTheme.spacing32),

          // Send Reset Email Button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: AppTheme.primaryButtonStyle,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Kohereza Email',
                        style: AppTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ).animate().slideY(begin: 0.3, delay: 600.ms),

          SizedBox(height: AppTheme.spacing24),

          // Back to Login
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Garuka ku kwinjira',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(bool isTablet) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read,
                size: isTablet ? 80 : 64,
                color: AppTheme.successColor,
              ).animate().scale(duration: 600.ms),

              SizedBox(height: AppTheme.spacing16),

              Text(
                'Email Yoherejwe!',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),

              SizedBox(height: AppTheme.spacing12),

              Text(
                'Reba email yawe ugire urebe ubutumwa bwo guhindura ijambo ry\'ibanga. Niba utabubona, reba na muri spam.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ).animate().slideY(begin: 0.3, duration: 800.ms),

        SizedBox(height: AppTheme.spacing32),

        // Back to Login Button
        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 48,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Garuka ku kwinjira',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ).animate().slideY(begin: 0.3, delay: 600.ms),
      ],
    );
  }
}
