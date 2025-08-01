import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/chat_message.dart';
import '../services/ai_chat_service.dart';

part 'chat_provider.freezed.dart';

/// Chat state model
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    String? error,
    @Default(true) bool isConnected,
  }) = _ChatState;
}

/// Chat provider notifier
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _initialize();
  }

  final AIChatService _aiService = AIChatService();

  /// Initialize chat with welcome message
  Future<void> _initialize() async {
    try {
      // Test connection
      final isConnected = await _aiService.testConnection();
      
      // Create welcome message
      final welcomeMessage = ChatMessage.welcome();
      
      state = state.copyWith(
        messages: [welcomeMessage],
        isInitialized: true,
        isConnected: isConnected,
        error: null,
      );
      
      if (kDebugMode) {
        print('✅ AI Chat initialized successfully');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize chat: $e',
        isInitialized: true,
        isConnected: false,
      );
      
      if (kDebugMode) {
        print('❌ AI Chat initialization failed: $e');
      }
    }
  }

  /// Send a message to the AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      // Add user message
      final userMessage = ChatMessage.user(content: content.trim());
      state = state.copyWith(
        messages: [...state.messages, userMessage],
        error: null,
      );

      // Add loading message
      final loadingMessage = ChatMessage.loading();
      state = state.copyWith(
        messages: [...state.messages, loadingMessage],
        isLoading: true,
      );

      // Get AI response
      final aiResponse = await _aiService.sendMessage(
        content.trim(),
        state.messages.where((msg) => !msg.isLoading).toList(),
      );

      // Remove loading message and add AI response
      final messagesWithoutLoading = state.messages
          .where((msg) => !msg.isLoading)
          .toList();

      final assistantMessage = ChatMessage.assistant(content: aiResponse);

      state = state.copyWith(
        messages: [...messagesWithoutLoading, assistantMessage],
        isLoading: false,
        error: null,
      );

      if (kDebugMode) {
        print('✅ AI response received: ${aiResponse.substring(0, 50)}...');
      }
    } catch (e) {
      // Remove loading message and add error message
      final messagesWithoutLoading = state.messages
          .where((msg) => !msg.isLoading)
          .toList();

      final errorMessage = ChatMessage.error(errorMessage: e.toString());

      state = state.copyWith(
        messages: [...messagesWithoutLoading, errorMessage],
        isLoading: false,
        error: e.toString(),
      );

      if (kDebugMode) {
        print('❌ AI chat error: $e');
      }
    }
  }

  /// Clear chat history
  void clearChat() {
    final welcomeMessage = ChatMessage.welcome();
    state = state.copyWith(
      messages: [welcomeMessage],
      error: null,
      isLoading: false,
    );
  }

  /// Retry last message
  Future<void> retryLastMessage() async {
    final messages = state.messages;
    if (messages.length < 2) return;

    // Find the last user message
    ChatMessage? lastUserMessage;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].sender == MessageSender.user) {
        lastUserMessage = messages[i];
        break;
      }
    }

    if (lastUserMessage != null) {
      // Remove messages after the last user message
      final messagesUpToUser = <ChatMessage>[];
      for (final message in messages) {
        messagesUpToUser.add(message);
        if (message.id == lastUserMessage.id) break;
      }

      state = state.copyWith(messages: messagesUpToUser);

      // Resend the message
      await sendMessage(lastUserMessage.content);
    }
  }

  /// Check connection status
  Future<void> checkConnection() async {
    try {
      final isConnected = await _aiService.testConnection();
      state = state.copyWith(isConnected: isConnected);
    } catch (e) {
      state = state.copyWith(isConnected: false);
    }
  }

  /// Get quick reply suggestions
  List<String> getQuickReplies() {
    return [
      "What contraceptive methods are available?",
      "How do birth control pills work?",
      "Tell me about family planning",
      "What is the safest contraception?",
      "How to prevent pregnancy naturally?",
      "What are the side effects of IUDs?",
    ];
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

/// Convenience providers
final chatMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(chatProvider).messages;
});

final chatIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isLoading;
});

final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatProvider).error;
});

final chatIsConnectedProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isConnected;
});

final chatIsInitializedProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isInitialized;
});
