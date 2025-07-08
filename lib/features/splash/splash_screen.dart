import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../onboarding/onboarding_screen.dart';

class SplashSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  SplashSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentSlide = 0;

  final List<SplashSlide> _slides = [
    SplashSlide(
      icon: Icons.favorite_rounded,
      title: 'UBUZIMA',
      subtitle: 'Ubuzima bw\'imyororokere',
      description:
          'Your trusted companion for family planning and reproductive health',
      color: AppTheme.primaryColor,
    ),
    SplashSlide(
      icon: Icons.health_and_safety_rounded,
      title: 'HEALTH TRACKING',
      subtitle: 'Gukurikirana ubuzima',
      description:
          'Track your health journey with personalized insights and reminders',
      color: AppTheme.secondaryColor,
    ),
    SplashSlide(
      icon: Icons.people_rounded,
      title: 'COMMUNITY SUPPORT',
      subtitle: 'Ubufasha bw\'abaturage',
      description:
          'Connect with health workers and join supportive communities',
      color: AppTheme.accentColor,
    ),
    SplashSlide(
      icon: Icons.school_rounded,
      title: 'EDUCATION',
      subtitle: 'Kwiga no guteza imbere',
      description: 'Access comprehensive health education in your language',
      color: AppTheme.successColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSlideshow();
  }

  void _initializeAnimations() {
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  void _startSlideshow() {
    // Auto-advance slides every 3 seconds
    Future.delayed(const Duration(milliseconds: 1000), () {
      _autoAdvanceSlides();
    });
  }

  void _autoAdvanceSlides() {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (_currentSlide < _slides.length - 1) {
        _currentSlide++;
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _autoAdvanceSlides(); // Continue to next slide
      } else {
        // All slides shown, navigate to onboarding
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const OnboardingScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (index) {
            setState(() {
              _currentSlide = index;
            });
          },
          itemBuilder: (context, index) {
            final slide = _slides[index];
            return _buildSlide(slide, size, isTablet);
          },
        ),
      ),
    );
  }

  Widget _buildSlide(SplashSlide slide, Size size, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            slide.color,
            slide.color.withValues(alpha: 0.8),
            slide.color.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPatternPainter()),
          ),

          // Main Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? AppTheme.spacing48 : AppTheme.spacing32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container
                  Container(
                    width: isTablet ? 180 : 140,
                    height: isTablet ? 180 : 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 90 : 70),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      slide.icon,
                      size: isTablet ? 80 : 60,
                      color: slide.color,
                    ),
                  ).animate().scale(
                    delay: 200.ms,
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Title
                  Text(
                        slide.title,
                        style: AppTheme.headingLarge.copyWith(
                          color: Colors.white,
                          fontSize: isTablet ? 42 : 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(
                        begin: 0.3,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),

                  SizedBox(height: AppTheme.spacing16),

                  // Subtitle (Kinyarwanda)
                  Text(
                        slide.subtitle,
                        style: AppTheme.headingSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(
                        begin: 0.3,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),

                  SizedBox(height: AppTheme.spacing24),

                  // Description
                  Text(
                        slide.description,
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isTablet ? 18 : 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .slideY(
                        begin: 0.3,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
          ),

          // Progress Indicators
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentSlide == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentSlide == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 1200.ms),
          ),

          // Version Info
          Positioned(
            bottom: AppTheme.spacing24,
            left: 0,
            right: 0,
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 1400.ms),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill;

    // Draw floating circles
    for (int i = 0; i < 20; i++) {
      final x = (i * 0.3 * size.width) % size.width;
      final y = (i * 0.4 * size.height) % size.height;
      final radius = (i % 3 + 1) * 15.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw curved lines
    final linePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(path, linePaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
