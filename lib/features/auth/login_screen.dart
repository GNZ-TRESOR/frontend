import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';

import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/language_selector.dart';
import '../dashboard/role_dashboard.dart';
import 'register_screen.dart';

/// Professional login screen for Family Planning Platform
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref
        .read(authProvider.notifier)
        .login(email, password);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleDashboard()),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageSelector(isCompact: true, showLabel: false),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        _buildHeader(),
                        const SizedBox(height: 60),
                        _buildLoginForm(),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                        const SizedBox(height: 16),
                        _buildForgotPassword(),
                        const SizedBox(height: 40),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildRegisterSection(),
                        const SizedBox(height: 40),
                        _buildFooter(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, size: 50, color: Colors.white),
        ),

        const SizedBox(height: 24),

        // Welcome text
        Text(
          AppLocalizations.of(context)!.welcomeBack,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          AppLocalizations.of(context)!.signInToContinue,
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.emailAddress,
              hintText: AppLocalizations.of(context)!.enterEmail,
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterEmail;
              }
              if (!AppConstants.isValidEmail(value)) {
                return AppLocalizations.of(context)!.pleaseEnterValidEmail;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              hintText: AppLocalizations.of(context)!.enterPassword,
              prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterPassword;
              }
              if (value.length < 6) {
                return AppLocalizations.of(context)!.passwordTooShort;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              Text(
                AppLocalizations.of(context)!.rememberMe,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    final authState = ref.watch(authProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child:
            authState.isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  AppLocalizations.of(context)!.signIn,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        // TODO: Implement forgot password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forgot password feature coming soon')),
        );
      },
      child: Text(
        AppLocalizations.of(context)!.forgotPassword,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.or,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.dontHaveAccount,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _navigateToRegister,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            AppLocalizations.of(context)!.createAccount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.bySigningIn,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show terms of service
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context)!.termsOfService,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.and,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
