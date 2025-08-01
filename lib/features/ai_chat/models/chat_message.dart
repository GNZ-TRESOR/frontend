import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Enum for message sender type
enum MessageSender {
  user,
  assistant,
  system,
}

/// Chat message model for AI assistant
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required MessageSender sender,
    required DateTime timestamp,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Create a user message
  factory ChatMessage.user({
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant({
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );
  }

  /// Create a loading message
  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// Create an error message
  factory ChatMessage.error({
    required String errorMessage,
  }) {
    return ChatMessage(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Sorry, I encountered an error. Please try again.',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      hasError: true,
      errorMessage: errorMessage,
    );
  }

  /// Create welcome message
  factory ChatMessage.welcome() {
    return ChatMessage(
      id: 'welcome_message',
      content: "Hi, I'm your Ubuzima Assistant. How can I help with family planning today?",
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );
  }
}

/// Chat session model
@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    required List<ChatMessage> messages,
    required DateTime createdAt,
    DateTime? lastMessageAt,
    @Default('Family Planning Chat') String title,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);

  /// Create a new chat session with welcome message
  factory ChatSession.newSession() {
    final welcomeMessage = ChatMessage.welcome();
    return ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messages: [welcomeMessage],
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );
  }
}
