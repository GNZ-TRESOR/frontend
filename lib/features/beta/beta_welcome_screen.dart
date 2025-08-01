import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/config/beta_config.dart';
import '../../core/services/storage_service.dart';

/// Beta welcome screen shown to first-time beta users
class BetaWelcomeScreen extends ConsumerStatefulWidget {
  const BetaWelcomeScreen({super.key});

  @override
  ConsumerState<BetaWelcomeScreen> createState() => _BetaWelcomeScreenState();
}

class _BetaWelcomeScreenState extends ConsumerState<BetaWelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasAgreedToTerms = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Ubuzima Beta',
      'subtitle': 'Family Planning Made Simple',
      'description': 'You\'re part of an exclusive group testing the future of family planning in Rwanda.',
      'icon': Icons.favorite,
      'color': AppColors.primary,
    },
    {
      'title': 'Beta Testing Guidelines',
      'subtitle': 'Help Us Improve',
      'description': 'Test all features, report bugs, and share your feedback to help us create the best experience.',
      'icon': Icons.bug_report,
      'color': AppColors.secondary,
    },
    {
      'title': 'Your Privacy Matters',
      'subtitle': 'Secure & Confidential',
      'description': 'All your data is encrypted and secure. Beta testing data will not be used for any other purpose.',
      'icon': Icons.security,
      'color': AppColors.tertiary,
    },
    {
      'title': 'Ready to Start?',
      'subtitle': 'Let\'s Begin Testing',
      'description': 'Explore all features and help us make Ubuzima the best family planning app for everyone.',
      'icon': Icons.rocket_launch,
      'color': AppColors.appointmentBlue,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.science,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'BETA ${BetaConfig.betaVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${_currentPage + 1} / ${_pages.length}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> pageData) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (pageData['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pageData['icon'] as IconData,
              size: 60,
              color: pageData['color'] as Color,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            pageData['title'] as String,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            pageData['subtitle'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: pageData['color'] as Color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            pageData['description'] as String,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentPage == _pages.length - 1) ...[
            const SizedBox(height: 32),
            _buildTermsAgreement(),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _hasAgreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _hasAgreedToTerms = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  'I agree to participate in beta testing and understand this is a test version',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'By participating, you agree to test features, report issues, and provide feedback to help improve the app.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 24),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? AppColors.primary 
                : AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentPage > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Previous'),
            ),
          ),
        if (_currentPage > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _currentPage == _pages.length - 1
                ? (_hasAgreedToTerms ? _completeBetaWelcome : null)
                : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentPage == _pages.length - 1 ? 'Start Testing' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completeBetaWelcome() async {
    try {
      // Mark beta welcome as completed
      await StorageService.setBool('beta_welcome_completed', true);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Ubuzima Beta! Happy testing!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate back to main app
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
