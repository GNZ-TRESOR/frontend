import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import '../../widgets/voice_button.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Igenamiterere ry\'Ubuzima'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        themeProvider.currentThemeIcon,
                        size: 64,
                        color: Colors.white,
                      ).animate().scale(duration: 600.ms),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        'Hitamo Igenamiterere',
                        style: AppTheme.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Hindura igenamiterere ry\'app ukurikije ibyo ukunda',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ).animate().slideY(begin: -0.3, duration: 600.ms),

                const SizedBox(height: AppTheme.spacing32),

                // Current Theme Display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Icon(
                            themeProvider.currentThemeIcon,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Igenamiterere Rikoreshwa',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                themeProvider.currentThemeName,
                                style: AppTheme.headingMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideX(begin: -0.3, delay: 200.ms),

                const SizedBox(height: AppTheme.spacing24),

                // Theme Options
                Text(
                  'Hitamo Igenamiterere',
                  style: AppTheme.headingMedium,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: AppTheme.spacing16),

                // Light Theme Option
                _buildThemeOption(
                  context: context,
                  themeProvider: themeProvider,
                  themeMode: ThemeMode.light,
                  title: 'Urumuri (Light)',
                  subtitle: 'Igenamiterere ryera kandi ryoroshye',
                  icon: Icons.light_mode,
                  delay: 600,
                ),

                const SizedBox(height: AppTheme.spacing12),

                // Dark Theme Option
                _buildThemeOption(
                  context: context,
                  themeProvider: themeProvider,
                  themeMode: ThemeMode.dark,
                  title: 'Umwijima (Dark)',
                  subtitle: 'Igenamiterere ryijimye kandi ryoroshye ku maso',
                  icon: Icons.dark_mode,
                  delay: 800,
                ),

                const SizedBox(height: AppTheme.spacing12),

                // System Theme Option
                _buildThemeOption(
                  context: context,
                  themeProvider: themeProvider,
                  themeMode: ThemeMode.system,
                  title: 'Sisitemu (System)',
                  subtitle: 'Gukurikiza igenamiterere rya sisitemu yawe',
                  icon: Icons.brightness_auto,
                  delay: 1000,
                ),

                const SizedBox(height: AppTheme.spacing32),

                // Theme Preview Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Igaragaza ry\'Igenamiterere',
                          style: AppTheme.headingMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        _buildThemePreview(context),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 1200.ms),

                const SizedBox(height: AppTheme.spacing32),

                // Voice Button
                Center(
                  child: VoiceButton(
                    prompt: 'Hitamo igenamiterere',
                    onResult: (result) {
                      // Handle voice command for theme
                      print('Voice result: $result');
                    },
                    tooltip: 'Vuga kugira uhindure igenamiterere',
                  ).animate().scale(delay: 1400.ms),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required ThemeMode themeMode,
    required String title,
    required String subtitle,
    required IconData icon,
    required int delay,
  }) {
    final isSelected = themeProvider.themeMode == themeMode;

    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: () => themeProvider.setThemeMode(themeMode),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border:
                isSelected
                    ? Border.all(color: AppTheme.primaryColor, width: 2)
                    : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    ).animate().slideX(begin: 0.3, delay: delay.ms);
  }

  Widget _buildThemePreview(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          // App Bar Preview
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  bottomLeft: Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content Preview
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppTheme.radiusMedium),
                  bottomRight: Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 70,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
