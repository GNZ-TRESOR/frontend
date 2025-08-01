import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';
import '../../core/widgets/loading_overlay.dart';
import 'login_screen.dart';

/// Professional registration screen for Family Planning Platform
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Additional fields for complete user profile
  final _districtController = TextEditingController();
  final _sectorController = TextEditingController();
  final _cellController = TextEditingController();
  final _villageController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String _selectedGender = 'FEMALE';
  // Role will be determined by backend based on email domain
  String _selectedLanguage = 'rw'; // Default language
  DateTime? _selectedDateOfBirth;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _districtController.dispose();
    _sectorController.dispose();
    _cellController.dispose();
    _villageController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Backend will automatically determine role based on email domain:
    // - .rw emails -> ADMIN
    // - Other emails -> CLIENT
    // - Health workers are created by admins only
    final email = _emailController.text.trim().toLowerCase();

    final userData = {
      'name':
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      'email': email,
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      // Role will be determined by backend based on email domain
      'gender': _selectedGender,
      'dateOfBirth':
          _selectedDateOfBirth?.toIso8601String().split(
            'T',
          )[0], // Send as date only
      'district':
          _districtController.text.trim().isNotEmpty
              ? _districtController.text.trim()
              : null,
      'sector':
          _sectorController.text.trim().isNotEmpty
              ? _sectorController.text.trim()
              : null,
      'cell':
          _cellController.text.trim().isNotEmpty
              ? _cellController.text.trim()
              : null,
      'village':
          _villageController.text.trim().isNotEmpty
              ? _villageController.text.trim()
              : null,
      'emergencyContact':
          _emergencyContactController.text.trim().isNotEmpty
              ? _emergencyContactController.text.trim()
              : null,
      'preferredLanguage': _selectedLanguage,
    };

    final success = await ref.read(authProvider.notifier).register(userData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login to continue.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildRegistrationForm(),
                        const SizedBox(height: 24),
                        _buildTermsAndConditions(),
                        const SizedBox(height: 24),
                        _buildRegisterButton(),
                        const SizedBox(height: 24),
                        _buildLoginSection(),
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
          width: 80,
          height: 80,
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
          child: const Icon(Icons.favorite, size: 40, color: Colors.white),
        ),

        const SizedBox(height: 24),

        // Welcome text
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Join Ubuzima to start your health journey',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Name and Last Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter first name',
                    prefixIcon: Icon(
                      Icons.person_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter last name',
                    prefixIcon: Icon(
                      Icons.person_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!AppConstants.isValidEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Gender and Date of Birth
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(
                      Icons.wc_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  onTap: _selectDateOfBirth,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select date',
                    prefixIcon: Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  controller: TextEditingController(
                    text:
                        _selectedDateOfBirth != null
                            ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                            : '',
                  ),
                  validator: (value) {
                    if (_selectedDateOfBirth == null) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
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
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: Icon(Icons.lock_outlined, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Account Type Information (Read-only)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Account type will be automatically determined based on your email domain',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Preferred Language
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: InputDecoration(
              labelText: 'Preferred Language',
              hintText: 'Select language',
              prefixIcon: Icon(
                Icons.language_outlined,
                color: AppColors.primary,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'rw', child: Text('Kinyarwanda')),
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'fr', child: Text('French')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),

          const SizedBox(height: 20),

          // Location Information Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Information (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // District and Sector
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _districtController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'District',
                          hintText: 'e.g., Kigali',
                          prefixIcon: Icon(
                            Icons.location_city_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _sectorController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Sector',
                          hintText: 'e.g., Kicukiro',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Cell and Village
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cellController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Cell',
                          hintText: 'e.g., Gahanga',
                          prefixIcon: Icon(
                            Icons.place_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _villageController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Village',
                          hintText: 'e.g., Gahanga',
                          prefixIcon: Icon(
                            Icons.home_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Emergency Contact
          TextFormField(
            controller: _emergencyContactController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Emergency Contact (Optional)',
              hintText: 'Enter emergency contact number',
              prefixIcon: Icon(
                Icons.emergency_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final authState = ref.watch(authProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _handleRegister,
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
                : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
