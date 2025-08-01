import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';
import '../../core/config/app_config.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../dashboard/role_dashboard.dart';

/// Professional splash screen with slideshow for Family Planning Platform
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _slideController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _slideAnimation;
  
  PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  
  int _currentSlide = 0;
  bool _isLoading = true;
  bool _showSlideshow = false;
  
  final List<FamilyPlanningSlide> _slides = [
    FamilyPlanningSlide(
      title: 'Ubuzima Family Planning',
      subtitle: 'Your comprehensive reproductive health companion',
      icon: Icons.favorite,
      color: AppColors.primary,
      description: 'Track your menstrual cycle, plan pregnancy, and access expert guidance for your family planning journey',
    ),
    FamilyPlanningSlide(
      title: 'Expert Health Guidance',
      subtitle: 'Connect with certified health workers and specialists',
      icon: Icons.medical_services,
      color: AppColors.healthWorkerBlue,
      description: 'Get personalized advice from healthcare professionals specialized in reproductive health',
    ),
    FamilyPlanningSlide(
      title: 'Comprehensive Tracking',
      subtitle: 'Monitor your reproductive health with precision',
      icon: Icons.analytics,
      color: AppColors.tertiary,
      description: 'Track menstrual cycles, symptoms, medications, and health records in one secure platform',
    ),
    FamilyPlanningSlide(
      title: 'Community Support',
      subtitle: 'Join support groups and connect with others',
      icon: Icons.group,
      color: AppColors.supportPurple,
      description: 'Share experiences and get support from a caring community on similar journeys',
    ),
    FamilyPlanningSlide(
      title: 'Secure & Private',
      subtitle: 'Your health data is protected with enterprise-grade security',
      icon: Icons.security,
      color: AppColors.adminPurple,
      description: 'Complete privacy and confidentiality for all your reproductive health information',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation with elastic effect
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startInitialization() async {
    // Start logo animation
    _logoController.forward();
    
    // Initialize app services
    await _initializeServices();
    
    // Show slideshow after initialization
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      setState(() {
        _showSlideshow = true;
        _isLoading = false;
      });
      
      _slideController.forward();
      _startAutoSlide();
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize app configuration
      await AppConfig.initialize();
      
      // Add artificial delay for better UX
      await Future.delayed(const Duration(milliseconds: 2000));
      
    } catch (e) {
      debugPrint('🔴 Initialization error: $e');
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _currentSlide < _slides.length - 1) {
        _nextSlide();
      } else {
        _finishSplash();
      }
    });
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      setState(() {
        _currentSlide++;
      });
      _pageController.animateToPage(
        _currentSlide,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSplash();
    }
  }

  void _finishSplash() {
    _autoSlideTimer?.cancel();
    
    final authState = ref.read(authProvider);
    
    if (authState.isAuthenticated && authState.user != null) {
      _navigateToRoleDashboard();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToRoleDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RoleDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: _showSlideshow ? _buildSlideshow() : _buildInitialSplash(),
      ),
    );
  }

  Widget _buildInitialSplash() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryLight.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // App name
            FadeTransition(
              opacity: _logoAnimation,
              child: Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Tagline
            FadeTransition(
              opacity: _logoAnimation,
              child: Text(
                'Family Planning & Reproductive Health',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Subtitle
            FadeTransition(
              opacity: _logoAnimation,
              child: Text(
                'Empowering your reproductive health journey',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Loading indicator
            if (_isLoading)
              Column(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Initializing your health platform...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideshow() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _slideAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _slides[_currentSlide].color,
                  _slides[_currentSlide].color.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                // Header with skip button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome to ${AppConstants.appName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: _finishSplash,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Slideshow content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSlide = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(_slides[index]);
                    },
                  ),
                ),
                
                // Page indicators
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                ),
                
                // Continue button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentSlide == _slides.length - 1 
                          ? _finishSplash 
                          : _nextSlide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _slides[_currentSlide].color,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        _currentSlide == _slides.length - 1 ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlide(FamilyPlanningSlide slide) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 25),
          
          // Subtitle
          Text(
            slide.subtitle,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 35),
          
          // Description
          Text(
            slide.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentSlide == index ? 28 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: _currentSlide == index 
            ? Colors.white 
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

/// Data class for family planning splash slides
class FamilyPlanningSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  FamilyPlanningSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
