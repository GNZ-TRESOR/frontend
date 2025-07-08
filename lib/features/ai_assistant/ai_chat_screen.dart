import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/gemini_ai_service.dart';
import '../../core/services/language_service.dart';
import '../../widgets/voice_button.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiAIService _aiService = GeminiAIService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final currentLanguage = languageService.currentLocale.languageCode;

    String welcomeMessage;
    switch (currentLanguage) {
      case 'rw':
        welcomeMessage = '''Muraho! Ndi umujyanama w'AI w'ubuzima bw'ababyeyi.

Ndashobora kugufasha mu:
• Ibibazo by'ubuzima bw'ababyeyi
• Amakuru ku buryo bwo kurinda inda
• Inama z'ubuzima bw'abagore
• Gutegura umuryango

Baza ikibazo cyawe!''';
        break;
      case 'fr':
        welcomeMessage =
            '''Bonjour! Je suis un assistant IA pour la santé reproductive.

Je peux vous aider avec:
• Questions de santé reproductive
• Informations sur la contraception
• Conseils de santé féminine
• Planification familiale

Posez votre question!''';
        break;
      default:
        welcomeMessage = '''Hello! I'm an AI assistant for reproductive health.

I can help you with:
• Reproductive health questions
• Contraception information
• Women's health advice
• Family planning

Ask me anything!''';
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: welcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _sendMessage([String? text]) async {
    final message = text ?? _controller.text.trim();
    if (message.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final languageService = Provider.of<LanguageService>(
        context,
        listen: false,
      );
      final currentLanguage = languageService.currentLocale.languageCode;

      String languageCode;
      switch (currentLanguage) {
        case 'rw':
          languageCode = 'kinyarwanda';
          break;
        case 'fr':
          languageCode = 'french';
          break;
        default:
          languageCode = 'english';
      }

      final aiResponse = await _aiService.getHealthAdvice(
        message,
        language: languageCode,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _getErrorMessage(),
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getErrorMessage() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    switch (languageService.currentLocale.languageCode) {
      case 'rw':
        return 'Ntabwo nashoboye gusubiza. Reba ko ufite internet hanyuma ongera ugerageze.';
      case 'fr':
        return 'Je n\'ai pas pu répondre. Vérifiez votre connexion internet et réessayez.';
      default:
        return 'I couldn\'t respond. Please check your internet connection and try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              languageService.currentLocale.languageCode == 'rw'
                  ? 'Umujyanama w\'AI'
                  : languageService.currentLocale.languageCode == 'fr'
                  ? 'Assistant IA'
                  : 'AI Assistant',
              style: AppTheme.headingMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                  });
                  _addWelcomeMessage();
                },
                tooltip:
                    languageService.currentLocale.languageCode == 'rw'
                        ? 'Tangira ukindi kiganiro'
                        : languageService.currentLocale.languageCode == 'fr'
                        ? 'Nouvelle conversation'
                        : 'New conversation',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
              ),
              if (_isLoading) _buildLoadingIndicator(),
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? AppTheme.primaryColor
                  : message.isError
                  ? Colors.red.shade100
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTheme.bodyMedium.copyWith(
                color:
                    message.isUser
                        ? Colors.white
                        : message.isError
                        ? Colors.red.shade700
                        : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: AppTheme.bodySmall.copyWith(
                color: message.isUser ? Colors.white70 : AppTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Provider.of<LanguageService>(context).currentLocale.languageCode ==
                    'rw'
                ? 'AI irimo gusubiza...'
                : Provider.of<LanguageService>(
                      context,
                    ).currentLocale.languageCode ==
                    'fr'
                ? 'L\'IA répond...'
                : 'AI is responding...',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText:
                    Provider.of<LanguageService>(
                              context,
                            ).currentLocale.languageCode ==
                            'rw'
                        ? 'Andika ikibazo cyawe...'
                        : Provider.of<LanguageService>(
                              context,
                            ).currentLocale.languageCode ==
                            'fr'
                        ? 'Tapez votre question...'
                        : 'Type your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          VoiceButton(
            prompt: 'Baza ikibazo cyawe...',
            onResult: (text) => _sendMessage(text),
            tooltip: 'Koresha ijwi kubaza',
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _isLoading ? null : () => _sendMessage(),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
