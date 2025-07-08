import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Murakaza neza ku Ubuzima',
      description: 'App ya Ubuzima ni app yagenewe gufasha abagore n\'abagabo mu buzima bw\'imyororokere n\'ubwiyunge.',
      icon: Icons.favorite_rounded,
      color: AppTheme.primaryColor,
      features: [
        'Gukurikirana ubuzima bwawe',
        'Kwiga ku buzima bw\'imyororokere',
        'Gusanga amavuriro hafi yawe',
        'Gusabana n\'abandi mu muryango',
      ],
    ),
    TutorialStep(
      title: 'Koresha ijwi',
      description: 'Ubuzima app ikoresha ijwi kugira ngo ukoreshe byoroshye. Kanda button y\'ijwi hanyuma uvuge icyo ushaka.',
      icon: Icons.mic_rounded,
      color: AppTheme.secondaryColor,
      features: [
        'Vuga "Gukurikirana ubuzima" kugira ngo ugere ku buzima',
        'Vuga "Amasomo" kugira ngo ugere ku masomo',
        'Vuga "Amavuriro" kugira ngo usange amavuriro',
        'Vuga "Ubufasha" kugira ngo usabe ubufasha',
      ],
    ),
    TutorialStep(
      title: 'Gukurikirana ubuzima',
      description: 'Koresha app kugira ngo ukurikire ubuzima bwawe, imihango yawe, n\'imiti yawe.',
      icon: Icons.health_and_safety_rounded,
      color: AppTheme.accentColor,
      features: [
        'Andika imihango yawe',
        'Kwibutsa imiti yawe',
        'Gukurikirana ubuzima bwawe',
        'Kubona raporo z\'ubuzima bwawe',
      ],
    ),
    TutorialStep(
      title: 'Kwiga n\'gusangira',
      description: 'Iga ku buzima bw\'imyororokere no gusangira n\'abandi mu muryango.',
      icon: Icons.school_rounded,
      color: AppTheme.warningColor,
      features: [
        'Soma amasomo y\'ubuzima',
        'Witabire ibiganiro',
        'Kwinjira mu matsinda y\'ubufasha',
        'Gusangira ubunararibonye bwawe',
      ],
    ),
    TutorialStep(
      title: 'Gukoresha offline',
      description: 'App ya Ubuzima ikora nta murandasi. Amakuru yawe abikwa ku telefoni yawe.',
      icon: Icons.offline_bolt_rounded,
      color: AppTheme.successColor,
      features: [
        'Soma amasomo nta murandasi',
        'Andika ubuzima bwawe',
        'Reba amakuru yawe',
        'Sync iyo murandasi ugarutse',
      ],
    ),
    TutorialStep(
      title: 'Wowe uri umutware',
      description: 'Amakuru yawe ni amahanga. Wowe gusa ushobora kubona amakuru yawe.',
      icon: Icons.security_rounded,
      color: AppTheme.errorColor,
      features: [
        'Amakuru yawe ni amahanga',
        'Encryption y\'amakuru yawe',
        'Ntabwo dusangira amakuru yawe',
        'Wowe ugena icyo usangira',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('komeza') || lowerCommand.contains('next')) {
      _nextPage();
    } else if (lowerCommand.contains('subira') || lowerCommand.contains('back')) {
      _previousPage();
    } else if (lowerCommand.contains('soza') || lowerCommand.contains('finish')) {
      _finishTutorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Amasomo'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishTutorial,
            child: const Text(
              'Siga',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(isTablet),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _tutorialSteps.length,
              itemBuilder: (context, index) {
                final step = _tutorialSteps[index];
                return _buildTutorialPage(step, isTablet, index);
              },
            ),
          ),
          _buildNavigationButtons(isTablet),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Komeza" kugira ngo ukomeze, "Subira" kugira ngo usubirire inyuma, cyangwa "Soza" kugira ngo usoza',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga amasomo',
      ),
    );
  }

  Widget _buildProgressIndicator(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: List.generate(_tutorialSteps.length, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step, bool isTablet, int index) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
      child: Column(
        children: [
          SizedBox(height: AppTheme.spacing32),
          
          // Icon
          Container(
            width: isTablet ? 120 : 100,
            height: isTablet ? 120 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [step.color, step.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isTablet ? 60 : 50),
              boxShadow: [
                BoxShadow(
                  color: step.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              step.icon,
              color: Colors.white,
              size: isTablet ? 60 : 50,
            ),
          ),
          
          SizedBox(height: AppTheme.spacing32),
          
          // Title
          Text(
            step.title,
            style: AppTheme.headingLarge.copyWith(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppTheme.spacing16),
          
          // Description
          Text(
            step.description,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppTheme.spacing32),
          
          // Features
          Container(
            padding: EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: step.features.map((feature) {
                final featureIndex = step.features.indexOf(feature);
                return Container(
                  margin: EdgeInsets.only(
                    bottom: featureIndex < step.features.length - 1 ? AppTheme.spacing12 : 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: step.color,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 200).ms).fadeIn().slideY(begin: 0.3, duration: 800.ms);
  }

  Widget _buildNavigationButtons(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Subira'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                  ),
                ),
              ),
            ),
          
          if (_currentPage > 0) SizedBox(width: AppTheme.spacing16),
          
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _currentPage < _tutorialSteps.length - 1 ? _nextPage : _finishTutorial,
              icon: Icon(_currentPage < _tutorialSteps.length - 1 ? Icons.arrow_forward : Icons.check),
              label: Text(_currentPage < _tutorialSteps.length - 1 ? 'Komeza' : 'Soza'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishTutorial() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Murakoze gukurikirana amasomo!')),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}
