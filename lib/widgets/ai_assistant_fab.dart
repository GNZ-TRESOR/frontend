import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/language_service.dart';
import '../features/ai_assistant/ai_chat_screen.dart';

class AIAssistantFAB extends StatelessWidget {
  final String? contextualPrompt;
  final Map<String, dynamic>? contextData;

  const AIAssistantFAB({super.key, this.contextualPrompt, this.contextData});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return FloatingActionButton(
          onPressed: () => _openAIAssistant(context),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.psychology, color: Colors.white),
          tooltip: _getTooltip(languageService.currentLocale.languageCode),
        );
      },
    );
  }

  void _openAIAssistant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIChatScreen()),
    );
  }

  String _getTooltip(String language) {
    switch (language) {
      case 'rw':
        return 'Baza umujyanama w\'AI';
      case 'fr':
        return 'Demander à l\'assistant IA';
      default:
        return 'Ask AI Assistant';
    }
  }
}

class AIQuickHelp extends StatelessWidget {
  final String topic;
  final Map<String, dynamic>? contextData;

  const AIQuickHelp({super.key, required this.topic, this.contextData});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(Icons.psychology, color: AppTheme.primaryColor),
            title: Text(
              _getTitle(languageService.currentLocale.languageCode),
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _getSubtitle(languageService.currentLocale.languageCode),
              style: AppTheme.bodySmall,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textTertiary,
            ),
            onTap: () => _openAIWithContext(context),
          ),
        );
      },
    );
  }

  void _openAIWithContext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIChatScreen()),
    );
  }

  String _getTitle(String language) {
    switch (language) {
      case 'rw':
        return 'Baza AI ku $topic';
      case 'fr':
        return 'Demander à l\'IA sur $topic';
      default:
        return 'Ask AI about $topic';
    }
  }

  String _getSubtitle(String language) {
    switch (language) {
      case 'rw':
        return 'Bona inama z\'ubwoba ku $topic';
      case 'fr':
        return 'Obtenez des conseils d\'experts sur $topic';
      default:
        return 'Get expert advice on $topic';
    }
  }
}

class AIHealthTips extends StatefulWidget {
  const AIHealthTips({super.key});

  @override
  State<AIHealthTips> createState() => _AIHealthTipsState();
}

class _AIHealthTipsState extends State<AIHealthTips> {
  final List<String> _tips = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDailyTips();
  }

  void _loadDailyTips() async {
    setState(() {
      _isLoading = true;
    });

    // For now, show static tips. In a real implementation,
    // you would call the AI service to get personalized tips
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );

    List<String> tips;
    switch (languageService.currentLocale.languageCode) {
      case 'rw':
        tips = [
          'Nywa amazi menshi buri munsi',
          'Kurya ibirayi n\'amaboga',
          'Gukora siporo buri munsi',
          'Kuraguza neza mbere yo kuryama',
        ];
        break;
      case 'fr':
        tips = [
          'Buvez beaucoup d\'eau chaque jour',
          'Mangez des fruits et légumes',
          'Faites de l\'exercice quotidiennement',
          'Reposez-vous bien avant de dormir',
        ];
        break;
      default:
        tips = [
          'Drink plenty of water daily',
          'Eat fruits and vegetables',
          'Exercise regularly',
          'Get adequate rest',
        ];
    }

    setState(() {
      _tips.addAll(tips);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      _getHeaderTitle(
                        languageService.currentLocale.languageCode,
                      ),
                      style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children:
                        _tips
                            .map(
                              (tip) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppTheme.successColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: AppTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIChatScreen(),
                        ),
                      ),
                  icon: const Icon(Icons.psychology),
                  label: Text(
                    _getMoreTipsText(
                      languageService.currentLocale.languageCode,
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

  String _getHeaderTitle(String language) {
    switch (language) {
      case 'rw':
        return 'Inama z\'AI z\'ubuzima';
      case 'fr':
        return 'Conseils santé IA';
      default:
        return 'AI Health Tips';
    }
  }

  String _getMoreTipsText(String language) {
    switch (language) {
      case 'rw':
        return 'Bona indi nama';
      case 'fr':
        return 'Plus de conseils';
      default:
        return 'Get more tips';
    }
  }
}
