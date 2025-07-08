import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAutoAdvancing = true;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Murakaza neza ku Buzima!',
      subtitle: 'Ubuzima bw\'imyororokere',
      description:
          'Ubuzima ni porogaramu igufasha kubona amakuru yizewe ku buzima bw\'imyororokere. Tuzagufasha mu gufata ibyemezo byiza ku buzima bwawe.',
      icon: Icons.favorite_rounded,
      color: AppTheme.primaryColor,
      illustration: '💝',
    ),
    OnboardingPage(
      title: 'Amakuru y\'ingenzi mu ijwi',
      subtitle: 'Koresha ijwi ryawe',
      description:
          'Wumve amajwi y\'abaganga n\'abajyanama b\'ubuzima mu rurimi rwawe. Ntukeneye gusoma cyangwa kwandika - ijwi ryawe ni urufunguzo.',
      icon: Icons.record_voice_over_rounded,
      color: AppTheme.secondaryColor,
      illustration: '🎤',
    ),
    OnboardingPage(
      title: 'Gukurikirana ubuzima bwawe',
      subtitle: 'Koresha tekinoroji',
      description:
          'Koresha ijwi gukurikirana imihango yawe, gushyiraho kwibutsa, no kubona inama z\'ubuzima zinoze.',
      icon: Icons.health_and_safety_rounded,
      color: AppTheme.accentColor,
      illustration: '📊',
    ),
    OnboardingPage(
      title: 'Akazi k\'offline',
      subtitle: 'Utari ku murongo',
      description:
          'Koresha Ubuzima utari ku murongo. Amakuru yawe yose abikwa neza ku telefone yawe kandi arasigara ari amahirwe.',
      icon: Icons.offline_bolt_rounded,
      color: AppTheme.successColor,
      illustration: '📱',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    if (!_isAutoAdvancing) return;

    // Start auto-advance after 1 second delay
    Future.delayed(const Duration(seconds: 1), () {
      _autoAdvanceSlides();
    });
  }

  void _autoAdvanceSlides() {
    if (!mounted || !_isAutoAdvancing) return;

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || !_isAutoAdvancing) return;

      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: AppConstants.mediumAnimation,
          curve: Curves.easeInOut,
        );
        _autoAdvanceSlides(); // Continue to next slide
      } else {
        // All slides shown, wait a bit then navigate to login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _navigateToLogin();
          }
        });
      }
    });
  }

  void _stopAutoAdvance() {
    setState(() {
      _isAutoAdvancing = false;
    });
  }

  void _nextPage() {
    _stopAutoAdvance(); // Stop auto-advance when user interacts
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _previousPage() {
    _stopAutoAdvance(); // Stop auto-advance when user interacts
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: AppConstants.longAnimation,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isTablet),

            // Page Content
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isAutoAdvancing) {
                    _stopAutoAdvance();
                  }
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPageContent(_pages[index], isTablet);
                  },
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Title
          Row(
            children: [
              Container(
                width: isTablet ? 50 : 40,
                height: isTablet ? 50 : 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: AppTheme.spacing12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: AppTheme.headingSmall.copyWith(
                      fontSize: isTablet ? 22 : 18,
                    ),
                  ),
                  Text(
                    'Health Companion',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Progress Indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '${_currentPage + 1}/${_pages.length}',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing48 : AppTheme.spacing24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: isTablet ? 200 : 160,
            height: isTablet ? 200 : 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.color.withValues(alpha: 0.1),
                  page.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 100 : 80),
              border: Border.all(
                color: page.color.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  page.illustration,
                  style: TextStyle(fontSize: isTablet ? 80 : 60),
                ),
                Positioned(
                  bottom: isTablet ? 20 : 15,
                  right: isTablet ? 20 : 15,
                  child: Container(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 60 : 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [page.color, page.color.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                      boxShadow: AppTheme.mediumShadow,
                    ),
                    child: Icon(
                      page.icon,
                      color: Colors.white,
                      size: isTablet ? 32 : 28,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOut),

          SizedBox(height: AppTheme.spacing48),

          // Title
          Text(
                page.title,
                style: AppTheme.headingMedium.copyWith(
                  fontSize: isTablet ? 28 : 24,
                  color: page.color,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          SizedBox(height: AppTheme.spacing8),

          // Subtitle
          Text(
                page.subtitle,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          SizedBox(height: AppTheme.spacing24),

          // Description
          Text(
                page.description,
                style: AppTheme.bodyMedium.copyWith(height: 1.6),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.3, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildPageIndicator(index, isTablet),
            ),
          ),

          SizedBox(height: AppTheme.spacing24),

          // Auto-advance indicator
          if (_isAutoAdvancing)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Byihuse bizakomeza...',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: AppTheme.spacing24),

          // Skip/Manual Navigation
          Row(
            children: [
              // Skip button (always visible)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _stopAutoAdvance();
                    _navigateToLogin();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.textTertiary),
                    padding: EdgeInsets.symmetric(
                      vertical:
                          isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    'Simbuka',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),

              SizedBox(width: AppTheme.spacing16),

              // Manual navigation button (when auto-advance is stopped)
              if (!_isAutoAdvancing)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical:
                            isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Tangira' : 'Komeza',
                      style: AppTheme.labelLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, bool isTablet) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      width: isActive ? (isTablet ? 32 : 24) : (isTablet ? 12 : 8),
      height: isTablet ? 12 : 8,
      decoration: BoxDecoration(
        color:
            isActive
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.spacing4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String illustration;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.illustration,
  });
}
