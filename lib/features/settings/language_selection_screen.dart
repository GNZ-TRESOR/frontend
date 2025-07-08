import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/language_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/voice_button.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final languageService = Provider.of<LanguageService>(context, listen: false);
    _selectedLanguage = languageService.currentLocale.languageCode;
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('kinyarwanda') || lowerCommand.contains('ikinyarwanda')) {
      _changeLanguage('rw');
    } else if (lowerCommand.contains('english') || lowerCommand.contains('icyongereza')) {
      _changeLanguage('en');
    } else if (lowerCommand.contains('french') || lowerCommand.contains('igifaransa')) {
      _changeLanguage('fr');
    } else if (lowerCommand.contains('bika') || lowerCommand.contains('save')) {
      _saveAndExit();
    }
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    final languageService = Provider.of<LanguageService>(context, listen: false);
    languageService.changeLanguage(languageCode);
  }

  void _saveAndExit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          _buildAppBar(isTablet, l10n),
          
          // Language Options
          SliverToBoxAdapter(child: _buildLanguageOptions(isTablet, l10n)),
          
          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Kinyarwanda", "English", cyangwa "French" guhitamo ururimi. Vuga "Bika" kubika.',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi guhitamo ururimi',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: isTablet ? 200 : 160,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l10n.changeLanguage,
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                top: isTablet ? 60 : 40,
                right: isTablet ? 40 : 20,
                child: Icon(
                  Icons.language_rounded,
                  size: isTablet ? 120 : 80,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOptions(bool isTablet, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.all(isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            'Hitamo ururimi / Choose language / Choisissez la langue',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.spacing32),
          
          // Language Options
          ...LanguageService.supportedLanguages.map((language) {
            return _buildLanguageOption(language, isTablet);
          }).toList(),
          
          SizedBox(height: AppTheme.spacing48),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndExit,
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                  ),
                ),
              ),
              child: Text(
                l10n.save,
                style: AppTheme.labelLarge.copyWith(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(LanguageOption language, bool isTablet) {
    final isSelected = _selectedLanguage == language.code;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeLanguage(language.code),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? AppTheme.mediumShadow : AppTheme.softShadow,
            ),
            child: Row(
              children: [
                // Flag
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Center(
                    child: Text(
                      language.flag,
                      style: TextStyle(fontSize: isTablet ? 28 : 24),
                    ),
                  ),
                ),
                
                SizedBox(width: AppTheme.spacing16),
                
                // Language Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.nativeName,
                        style: AppTheme.headingSmall.copyWith(
                          fontSize: isTablet ? 20 : 18,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        language.name,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isTablet ? 32 : 28,
                  height: isTablet ? 32 : 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: isTablet ? 20 : 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (LanguageService.supportedLanguages.indexOf(language) * 100).ms)
     .slideX(begin: 0.3, duration: 600.ms);
  }
}
