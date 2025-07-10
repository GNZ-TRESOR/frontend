import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/message.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'http_client.dart';

/// Service for managing messages and conversations with complete CRUD operations
class MessageService {
  final HttpClient _httpClient = HttpClient();

  /// Get all messages with filtering and pagination
  Future<List<Message>> getMessages({
    int page = 0,
    int limit = 10,
    String? conversationId,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (conversationId != null) queryParams['conversationId'] = conversationId;
      if (userId != null) queryParams['userId'] = userId;

      final response = await _httpClient.get(
        '/messages',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final messagesData = apiResponse.data as Map<String, dynamic>;
          final messagesList = messagesData['messages'] as List<dynamic>;
          
          return messagesList
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  /// Get conversation messages
  Future<List<Message>> getConversationMessages(String conversationId) async {
    return getMessages(conversationId: conversationId);
  }

  /// Send a new message
  Future<Message?> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
    MessagePriority priority = MessagePriority.normal,
    String? subject,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestData = {
        'recipientId': recipientId,
        'content': content,
        'type': type.value,
        'priority': priority.value,
        'subject': subject,
        'conversationId': conversationId,
        'metadata': metadata,
      };

      final response = await _httpClient.post(
        '/messages',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Message.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  /// Send message to multiple recipients (broadcast)
  Future<List<Message>> sendBroadcastMessage({
    required List<String> recipientIds,
    required String content,
    MessageType type = MessageType.text,
    MessagePriority priority = MessagePriority.normal,
    String? subject,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestData = {
        'recipientIds': recipientIds,
        'content': content,
        'type': type.value,
        'priority': priority.value,
        'subject': subject,
        'metadata': metadata,
      };

      final response = await _httpClient.post(
        '/messages/broadcast',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final messagesData = apiResponse.data as Map<String, dynamic>;
          final messagesList = messagesData['messages'] as List<dynamic>;
          
          return messagesList
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error sending broadcast message: $e');
      return [];
    }
  }

  /// Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      final response = await _httpClient.put(
        '/messages/$messageId/read',
        data: {},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      return false;
    }
  }

  /// Mark all messages in conversation as read
  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      final response = await _httpClient.put(
        '/messages/conversation/$conversationId/read',
        data: {},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
      return false;
    }
  }

  /// Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await _httpClient.delete('/messages/$messageId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  /// Get conversations
  Future<List<Conversation>> getConversations({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '/messages/conversations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final conversationsData = apiResponse.data as Map<String, dynamic>;
          final conversationsList = conversationsData['conversations'] as List<dynamic>;
          
          return conversationsList
              .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      return [];
    }
  }

  /// Create or get conversation between users
  Future<Conversation?> getOrCreateConversation({
    required List<String> participantIds,
    String? title,
    bool isGroup = false,
  }) async {
    try {
      final requestData = {
        'participantIds': participantIds,
        'title': title,
        'isGroup': isGroup,
      };

      final response = await _httpClient.post(
        '/messages/conversations',
        data: requestData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return Conversation.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error creating/getting conversation: $e');
      return null;
    }
  }

  /// Search messages
  Future<List<Message>> searchMessages(String query) async {
    try {
      final response = await _httpClient.get(
        '/messages/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final messagesData = apiResponse.data as Map<String, dynamic>;
          final messagesList = messagesData['messages'] as List<dynamic>;
          
          return messagesList
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching messages: $e');
      return [];
    }
  }

  /// Get unread message count
  Future<int> getUnreadMessageCount() async {
    try {
      final response = await _httpClient.get('/messages/unread-count');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final countData = apiResponse.data as Map<String, dynamic>;
          return countData['unreadCount'] as int? ?? 0;
        }
      }

      return 0;
    } catch (e) {
      debugPrint('Error fetching unread message count: $e');
      return 0;
    }
  }

  /// Send system message (for notifications, alerts, etc.)
  Future<Message?> sendSystemMessage({
    required String recipientId,
    required String content,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? metadata,
  }) async {
    return sendMessage(
      recipientId: recipientId,
      content: content,
      type: MessageType.system,
      priority: priority,
      metadata: metadata,
    );
  }

  /// Send urgent message
  Future<Message?> sendUrgentMessage({
    required String recipientId,
    required String content,
    String? subject,
    MessageType type = MessageType.text,
  }) async {
    return sendMessage(
      recipientId: recipientId,
      content: content,
      type: type,
      priority: MessagePriority.urgent,
      subject: subject,
    );
  }

  /// Get message statistics
  Future<Map<String, int>> getMessageStatistics() async {
    try {
      final response = await _httpClient.get('/messages/statistics');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final statsData = apiResponse.data as Map<String, dynamic>;
          return Map<String, int>.from(statsData);
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error fetching message statistics: $e');
      return {};
    }
  }
}
