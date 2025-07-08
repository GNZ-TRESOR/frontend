import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../widgets/voice_button.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Dummy login credentials for testing
  final Map<String, DummyUser> _dummyUsers = {
    'client@ubuzima.rw': DummyUser(
      email: 'client@ubuzima.rw',
      password: 'client123',
      user: User(
        id: '1',
        name: 'Mukamana Marie',
        email: 'client@ubuzima.rw',
        phone: '+250788123456',
        role: UserRole.client,
        district: 'Kigali',
        sector: 'Kimisagara',
        cell: 'Nyabugogo',
        village: 'Nyabugogo I',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      ),
    ),
    'healthworker@ubuzima.rw': DummyUser(
      email: 'healthworker@ubuzima.rw',
      password: 'health123',
      user: User(
        id: '2',
        name: 'Dr. Uwimana Jean',
        email: 'healthworker@ubuzima.rw',
        phone: '+250788234567',
        role: UserRole.healthWorker,
        facilityId: 'HC001',
        district: 'Kigali',
        sector: 'Kimisagara',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastLoginAt: DateTime.now(),
      ),
    ),
    'admin@ubuzima.rw': DummyUser(
      email: 'admin@ubuzima.rw',
      password: 'admin123',
      user: User(
        id: '3',
        name: 'Nkurunziza Paul',
        email: 'admin@ubuzima.rw',
        phone: '+250788345678',
        role: UserRole.admin,
        facilityId: 'ADMIN001',
        district: 'Kigali',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastLoginAt: DateTime.now(),
      ),
    ),
  };

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('client') || lowerCommand.contains('umunyangire')) {
      _fillCredentials('client@ubuzima.rw', 'client123');
    } else if (lowerCommand.contains('health') || lowerCommand.contains('umukozi')) {
      _fillCredentials('healthworker@ubuzima.rw', 'health123');
    } else if (lowerCommand.contains('admin') || lowerCommand.contains('umuyobozi')) {
      _fillCredentials('admin@ubuzima.rw', 'admin123');
    }
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final dummyUser = _dummyUsers[email];
    
    if (dummyUser != null && dummyUser.password == password) {
      // Successful login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                MainScreen(user: dummyUser.user),
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
      }
    } else {
      // Failed login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email cyangwa ijambo ry\'ibanga ntibikwiye'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              
              // Header
              _buildHeader(isTablet),
              
              SizedBox(height: isTablet ? AppTheme.spacing48 : AppTheme.spacing32),
              
              // Demo Credentials Info
              _buildDemoInfo(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Login Form
              _buildLoginForm(isTablet),
              
              SizedBox(height: AppTheme.spacing24),
              
              // Quick Login Buttons
              _buildQuickLoginButtons(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Client" kugira ngo winjire nk\'umunyangire, "Health" kugira ngo winjire nk\'umukozi w\'ubuzima, cyangwa "Admin" kugira ngo winjire nk\'umuyobozi',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi kwinjira',
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: isTablet ? 80 : 60,
          height: isTablet ? 80 : 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
            boxShadow: AppTheme.mediumShadow,
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: isTablet ? 40 : 30,
          ),
        ),
        
        SizedBox(height: AppTheme.spacing24),
        
        Text(
          'Murakaza neza',
          style: AppTheme.headingLarge.copyWith(
            fontSize: isTablet ? 36 : 32,
          ),
        ),
        
        SizedBox(height: AppTheme.spacing8),
        
        Text(
          'Injira kugira ngo ukomeze gukoresha Ubuzima',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildDemoInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primaryColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Demo Accounts',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildCredentialRow('👤 Client:', 'client@ubuzima.rw', 'client123', isTablet),
          _buildCredentialRow('🏥 Health Worker:', 'healthworker@ubuzima.rw', 'health123', isTablet),
          _buildCredentialRow('⚙️ Admin:', 'admin@ubuzima.rw', 'admin123', isTablet),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildCredentialRow(String role, String email, String password, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 12 : 10,
            ),
          ),
          Text(
            '$email / $password',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontFamily: 'monospace',
              fontSize: isTablet ? 11 : 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isTablet) {
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
              prefixIcon: const Icon(Icons.email_rounded),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Andika email yawe';
              }
              if (!value.contains('@')) {
                return 'Andika email nyayo';
              }
              return null;
            },
          ),
          
          SizedBox(height: AppTheme.spacing16),
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Ijambo ry\'ibanga',
              hintText: 'Andika ijambo ry\'ibanga',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Andika ijambo ry\'ibanga';
              }
              if (value.length < 6) {
                return 'Ijambo ry\'ibanga rigomba kuba rifite byibura inyuguti 6';
              }
              return null;
            },
          ),
          
          SizedBox(height: AppTheme.spacing24),
          
          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                  ),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Injira',
                      style: AppTheme.labelLarge.copyWith(
                        color: Colors.white,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildQuickLoginButtons(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Injira vuba:',
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildQuickLoginButton(
                'Client',
                Icons.person_rounded,
                AppTheme.primaryColor,
                () => _fillCredentials('client@ubuzima.rw', 'client123'),
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: _buildQuickLoginButton(
                'Health Worker',
                Icons.medical_services_rounded,
                AppTheme.secondaryColor,
                () => _fillCredentials('healthworker@ubuzima.rw', 'health123'),
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: _buildQuickLoginButton(
                'Admin',
                Icons.admin_panel_settings_rounded,
                AppTheme.accentColor,
                () => _fillCredentials('admin@ubuzima.rw', 'admin123'),
                isTablet,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 800.ms).slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }

  Widget _buildQuickLoginButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isTablet,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
              horizontal: AppTheme.spacing8,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 10 : 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DummyUser {
  final String email;
  final String password;
  final User user;

  DummyUser({
    required this.email,
    required this.password,
    required this.user,
  });
}
