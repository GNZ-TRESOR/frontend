import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/voice_button.dart';
import '../main/main_screen.dart';
import 'register_screen.dart';
import 'password_reset_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await _authService.login(email, password);
      
      if (mounted) {
        if (result.isSuccess) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                  const MainScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Email cyangwa ijambo ry\'ibanga ntibikwiye'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habaye ikosa mu kwinjira. Gerageza ukundi.'),
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
    if (lowerCommand.contains('login') || lowerCommand.contains('injira')) {
      _login();
    } else if (lowerCommand.contains('register') || lowerCommand.contains('iyandikishe')) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
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
          padding: EdgeInsets.all(isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isTablet ? AppTheme.spacing64 : AppTheme.spacing32),
              _buildHeader(isTablet),
              SizedBox(height: isTablet ? AppTheme.spacing48 : AppTheme.spacing32),
              _buildLoginForm(isTablet),
              SizedBox(height: AppTheme.spacing24),
              _buildNavigationLinks(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga "injira" kugira ngo winjire cyangwa "iyandikishe" kugira ngo wiyandikishe',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi kwinjira',
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Murakaza neza',
          style: AppTheme.headingLarge.copyWith(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
        SizedBox(height: AppTheme.spacing8),
        Text(
          'Injira kuri konti yawe',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
        SizedBox(height: AppTheme.spacing32),
        Container(
          width: isTablet ? 120 : 80,
          height: isTablet ? 120 : 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Icon(
            Icons.health_and_safety,
            size: isTablet ? 60 : 40,
            color: Colors.white,
          ),
        ).animate().scale(delay: 400.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildLoginForm(bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Andika email nyayo';
              }
              return null;
            },
          ).animate().slideX(begin: 0.3, delay: 600.ms),
          SizedBox(height: AppTheme.spacing20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Ijambo ry\'ibanga',
              hintText: 'Andika ijambo ry\'ibanga',
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
              if (value.length < 6) {
                return 'Ijambo ry\'ibanga rigomba kuba rifite byibura inyuguti 6';
              }
              return null;
            },
          ).animate().slideX(begin: 0.3, delay: 800.ms),
          SizedBox(height: AppTheme.spacing32),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: AppTheme.primaryButtonStyle,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Injira',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ).animate().slideY(begin: 0.3, delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildNavigationLinks(bool isTablet) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
            );
          },
          child: Text(
            'Wibagiriye ijambo ry\'ibanga?',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).animate().fadeIn(delay: 1200.ms),
        SizedBox(height: AppTheme.spacing16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nta konti ufite? ',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: Text(
                'Iyandikishe',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 1400.ms),
      ],
    );
  }
}
