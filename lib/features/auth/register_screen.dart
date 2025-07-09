import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/voice_button.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String _selectedRole = AppConstants.roleClient;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ugomba kwemera amabwiriza n\'amategeko')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        if (result.isSuccess) {
          // Successful registration - navigate to main screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konti yawe yarakozwe neza!'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const MainScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          // Failed registration
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Habaye ikosa mu gukora konti'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Registration error details: $e'); // Debug logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habaye ikosa mu gukora konti: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Emeza ijambo ry\'ibanga';
    }
    if (value != _passwordController.text) {
      return 'Amagambo y\'ibanga ntabwo ahura';
    }
    return null;
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
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Iyandikishe', style: AppTheme.headingSmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(isTablet),

              SizedBox(height: AppTheme.spacing32),

              // Registration Form
              _buildRegistrationForm(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Login Link
              _buildLoginLink(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      children: [
        Text(
          'Kora konti nshya',
          style: AppTheme.headingLarge.copyWith(fontSize: isTablet ? 32 : 28),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),

        SizedBox(height: AppTheme.spacing8),

        Text(
          'Uzuza amakuru akurikira kugira ngo ukore konti yawe',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms),
      ],
    );
  }

  Widget _buildRegistrationForm(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name Field
            TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Amazina yawe',
                    hintText: 'Shyiramo amazina yawe yose',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: AppValidation.validateName,
                )
                .animate()
                .fadeIn(delay: 600.ms)
                .slideX(begin: -0.3, duration: 600.ms),

            SizedBox(height: AppTheme.spacing20),

            // Email Field
            TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Imeyili',
                    hintText: 'Shyiramo imeyili yawe',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: AppValidation.validateEmail,
                )
                .animate()
                .fadeIn(delay: 700.ms)
                .slideX(begin: -0.3, duration: 600.ms),

            SizedBox(height: AppTheme.spacing20),

            // Phone Field
            TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nimero ya telefone',
                    hintText: 'Shyiramo nimero ya telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: AppValidation.validatePhone,
                )
                .animate()
                .fadeIn(delay: 800.ms)
                .slideX(begin: -0.3, duration: 600.ms),

            SizedBox(height: AppTheme.spacing20),

            // Role Selection
            DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Uruhare rwawe',
                    prefixIcon: Icon(Icons.work_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.roleClient,
                      child: Text('Umukiliya'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.roleWorker,
                      child: Text('Umukozi w\'ubuzima'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                )
                .animate()
                .fadeIn(delay: 900.ms)
                .slideX(begin: -0.3, duration: 600.ms),

            SizedBox(height: AppTheme.spacing20),

            // Password Field
            TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Ijambo ry\'ibanga',
                    hintText: 'Shyiramo ijambo ry\'ibanga',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: AppValidation.validatePassword,
                )
                .animate()
                .fadeIn(delay: 1000.ms)
                .slideX(begin: -0.3, duration: 600.ms),

            SizedBox(height: AppTheme.spacing20),

            // Confirm Password Field
            TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Emeza ijambo ry\'ibanga',
                    hintText: 'Ongera ushyire ijambo ry\'ibanga',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _validateConfirmPassword,
                )
                .animate()
                .fadeIn(delay: 1100.ms)
                .slideX(begin: -0.3, duration: 600.ms),

            SizedBox(height: AppTheme.spacing20),

            // Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTheme.bodySmall,
                      children: [
                        const TextSpan(text: 'Ndemeye '),
                        TextSpan(
                          text: 'amabwiriza n\'amategeko',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' n\''),
                        TextSpan(
                          text: 'politiki y\'ubwoba',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1200.ms),

            SizedBox(height: AppTheme.spacing24),

            // Register Button
            SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: AppTheme.primaryButtonStyle.copyWith(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical:
                              isTablet
                                  ? AppTheme.spacing20
                                  : AppTheme.spacing16,
                        ),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              AppStrings.register,
                              style: AppTheme.labelLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                  ),
                )
                .animate()
                .fadeIn(delay: 1300.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 800.ms);
  }

  Widget _buildLoginLink(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Usanzwe ufite konti? ', style: AppTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.login,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1500.ms);
  }
}
