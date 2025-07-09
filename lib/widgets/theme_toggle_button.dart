import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return InkWell(
          onTap: () => themeProvider.toggleTheme(),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing8),
            child: showLabel
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProvider.currentThemeIcon,
                        size: iconSize ?? 24,
                        color: AppTheme.primaryColor,
                      ).animate().rotate(duration: 300.ms),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        themeProvider.currentThemeName,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    themeProvider.currentThemeIcon,
                    size: iconSize ?? 24,
                    color: AppTheme.primaryColor,
                  ).animate().rotate(duration: 300.ms),
          ),
        );
      },
    );
  }
}

class ThemeToggleFAB extends StatelessWidget {
  const ThemeToggleFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return FloatingActionButton.small(
          onPressed: () => themeProvider.toggleTheme(),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          tooltip: 'Hindura igenamiterere (${themeProvider.currentThemeName})',
          child: Icon(themeProvider.currentThemeIcon)
              .animate()
              .rotate(duration: 300.ms),
        );
      },
    );
  }
}

class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: InkWell(
            onTap: () => themeProvider.toggleTheme(),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      themeProvider.currentThemeIcon,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ).animate().rotate(duration: 300.ms),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Igenamiterere',
                          style: AppTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          themeProvider.currentThemeName,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.touch_app,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideX(begin: 0.3, duration: 400.ms);
      },
    );
  }
}

class AnimatedThemeIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AnimatedThemeIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: child,
            );
          },
          child: Icon(
            themeProvider.currentThemeIcon,
            key: ValueKey(themeProvider.themeMode),
            size: size,
            color: color ?? AppTheme.primaryColor,
          ),
        );
      },
    );
  }
}

class ThemeStatusIndicator extends StatelessWidget {
  const ThemeStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing12,
            vertical: AppTheme.spacing6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedThemeIcon(size: 16),
              const SizedBox(width: AppTheme.spacing6),
              Text(
                themeProvider.currentThemeName,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }
}
