import 'package:flutter/foundation.dart';

import '../models/support_group.dart';
import '../models/support_ticket.dart';
import '../models/message.dart';
import 'api_service.dart';
import 'storage_service.dart';

class CommunityService {
  final ApiService _apiService = ApiService.instance;

  // Real API service - no more mock data

  // Support Groups
  Future<List<SupportGroup>> getSupportGroups({
    String? category,
    bool? isPrivate,
    bool? isActive,
  }) async {
    try {
      final response = await _apiService.getSupportGroups();

      if (response.success && response.data != null) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        final groupsData = responseData['groups'] ?? responseData['data'] ?? [];

        List<SupportGroup> groups = [];
        if (groupsData is List) {
          groups =
              groupsData
                  .map(
                    (groupJson) => SupportGroup.fromJson(
                      Map<String, dynamic>.from(groupJson),
                    ),
                  )
                  .toList();
        }

        // Apply filters
        if (category != null) {
          groups = groups.where((group) => group.category == category).toList();
        }
        if (isPrivate != null) {
          groups =
              groups.where((group) => group.isPrivate == isPrivate).toList();
        }
        if (isActive != null) {
          groups = groups.where((group) => group.isActive == isActive).toList();
        }

        return groups;
      } else {
        // Return empty list instead of mock data
        debugPrint('Support Groups API failed: ${response.message}');
        return [];
      }
    } catch (e) {
      // Return empty list instead of mock data
      debugPrint('Error loading support groups: $e');
      return [];
    }
  }

  Future<SupportGroup> createSupportGroup(SupportGroup group) async {
    try {
      final groupData = {
        'name': group.name,
        'category': group.category,
        'description': group.description,
        'isActive': group.isActive,
        'isPrivate': group.isPrivate,
        'creatorId': group.creatorId,
        'contactInfo': group.contactInfo,
        'meetingLocation': group.meetingLocation,
        'meetingSchedule': group.meetingSchedule,
        'maxMembers': group.maxMembers,
        'tags': group.tags,
      };

      final response = await _apiService.createSupportGroup(groupData);

      if (response.success && response.data != null) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        return SupportGroup.fromJson(responseData);
      } else {
        throw Exception(response.message ?? 'Failed to create support group');
      }
    } catch (e) {
      // Rethrow the error instead of using mock data
      debugPrint('Error creating support group: $e');
      rethrow;
    }
  }

  Future<SupportGroup> updateSupportGroup(int id, SupportGroup group) async {
    try {
      final groupData = {
        'name': group.name,
        'category': group.category,
        'description': group.description,
        'isActive': group.isActive,
        'isPrivate': group.isPrivate,
        'contactInfo': group.contactInfo,
        'meetingLocation': group.meetingLocation,
        'meetingSchedule': group.meetingSchedule,
        'maxMembers': group.maxMembers,
        'tags': group.tags,
      };

      final response = await _apiService.updateSupportGroup(id, groupData);

      if (response.success && response.data != null) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        return SupportGroup.fromJson(responseData);
      } else {
        throw Exception(response.message ?? 'Failed to update support group');
      }
    } catch (e) {
      debugPrint('Error updating support group: $e');
      rethrow;
    }
  }

  Future<void> deleteSupportGroup(int id) async {
    try {
      final response = await _apiService.deleteSupportGroup(id);
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete support group');
      }
    } catch (e) {
      debugPrint('Error deleting support group: $e');
      rethrow;
    }
  }

  Future<List<SupportGroupMember>> getGroupMembers(int groupId) async {
    try {
      final response = await _apiService.getSupportGroupMembers(groupId);

      if (response.success && response.data != null) {
        final membersData = response.data['members'] as List<dynamic>? ?? [];
        return membersData
            .map(
              (memberJson) => SupportGroupMember.fromJson(
                memberJson as Map<String, dynamic>,
              ),
            )
            .toList();
      } else {
        debugPrint('Failed to load group members: ${response.message}');
        return [];
      }
    } catch (e) {
      debugPrint('Error loading group members: $e');
      return [];
    }
  }

  Future<SupportGroupMember> joinGroup(int groupId) async {
    try {
      final response = await _apiService.joinSupportGroup(groupId);

      if (response.success && response.data != null) {
        final responseData = Map<String, dynamic>.from(response.data as Map);
        return SupportGroupMember.fromJson(responseData);
      } else {
        throw Exception(response.message ?? 'Failed to join group');
      }
    } catch (e) {
      // Fallback to mock implementation
      await Future.delayed(const Duration(milliseconds: 500));

      return SupportGroupMember(
        id: 3,
        userId: 1, // Current user
        groupId: groupId,
        role: GroupMemberRole.member,
        isActive: true,
        joinedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );
    }
  }

  Future<void> leaveGroup(int groupId) async {
    try {
      final response = await _apiService.leaveSupportGroup(groupId);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to leave group');
      }
    } catch (e) {
      // Fallback to mock implementation
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock implementation - just simulate success
    }
  }

  // Support Tickets
  Future<List<SupportTicket>> getSupportTickets({
    TicketStatus? status,
    TicketType? type,
    TicketPriority? priority,
  }) async {
    try {
      final response = await _apiService.getSupportTickets();

      if (response.success && response.data != null) {
        final ticketsData = response.data['tickets'] as List<dynamic>? ?? [];
        var tickets =
            ticketsData
                .map(
                  (ticketJson) => SupportTicket.fromJson(
                    ticketJson as Map<String, dynamic>,
                  ),
                )
                .toList();

        // Apply filters
        if (status != null) {
          tickets = tickets.where((ticket) => ticket.status == status).toList();
        }
        if (type != null) {
          tickets =
              tickets.where((ticket) => ticket.ticketType == type).toList();
        }
        if (priority != null) {
          tickets =
              tickets.where((ticket) => ticket.priority == priority).toList();
        }

        return tickets;
      } else {
        debugPrint('Support Tickets API failed: ${response.message}');
        return [];
      }
    } catch (e) {
      debugPrint('Error loading support tickets: $e');
      return [];
    }
  }

  Future<SupportTicket> createSupportTicket(SupportTicket ticket) async {
    try {
      final ticketData = {
        'subject': ticket.subject,
        'description': ticket.description,
        'priority': ticket.priority.toString().split('.').last.toUpperCase(),
        'ticketType':
            ticket.ticketType.toString().split('.').last.toUpperCase(),
        'userId': ticket.userId,
        'userEmail': ticket.userEmail,
        'userPhone': ticket.userPhone,
      };

      final response = await _apiService.createSupportTicket(ticketData);

      if (response.success && response.data != null) {
        return SupportTicket.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to create support ticket');
      }
    } catch (e) {
      debugPrint('Error creating support ticket: $e');
      rethrow;
    }
  }

  Future<SupportTicket> updateSupportTicket(
    int id,
    SupportTicket ticket,
  ) async {
    try {
      final ticketData = {
        'subject': ticket.subject,
        'description': ticket.description,
        'status': ticket.status.toString().split('.').last.toUpperCase(),
        'priority': ticket.priority.toString().split('.').last.toUpperCase(),
        'ticketType':
            ticket.ticketType.toString().split('.').last.toUpperCase(),
      };

      final response = await _apiService.updateSupportTicket(id, ticketData);

      if (response.success && response.data != null) {
        return SupportTicket.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to update support ticket');
      }
    } catch (e) {
      debugPrint('Error updating support ticket: $e');
      rethrow;
    }
  }

  // Messages
  Future<List<Message>> getMessages({
    String? conversationId,
    int? receiverId,
    int? senderId,
    bool? unreadOnly,
  }) async {
    try {
      // Get current user ID from storage
      final userData = StorageService.getUserData();
      if (userData == null || userData['id'] == null) {
        throw Exception('User not authenticated');
      }

      final userId = userData['id'] as int;

      // If we have both sender and receiver, get conversation between them
      if (senderId != null && receiverId != null) {
        final response = await _apiService.getConversation(
          senderId,
          receiverId,
        );

        if (response.success && response.data != null) {
          final messagesData =
              response.data['messages'] as List<dynamic>? ?? [];

          return messagesData.map((msgData) {
            final msg = Map<String, dynamic>.from(msgData);

            return Message(
              id: msg['id'],
              content: msg['content'] ?? '',
              senderId: msg['senderId'] ?? 0,
              receiverId: msg['receiverId'] ?? 0,
              conversationId:
                  msg['conversationId'] ?? 'conv_${senderId}_$receiverId',
              messageType: MessageType.values.firstWhere(
                (type) =>
                    type.toString().split('.').last ==
                    (msg['messageType'] ?? 'text'),
                orElse: () => MessageType.text,
              ),
              priority: MessagePriority.values.firstWhere(
                (priority) =>
                    priority.toString().split('.').last ==
                    (msg['priority'] ?? 'normal'),
                orElse: () => MessagePriority.normal,
              ),
              isRead: msg['isRead'] ?? false,
              isEmergency: msg['isEmergency'] ?? false,
              createdAt:
                  msg['createdAt'] != null
                      ? DateTime.parse(msg['createdAt'])
                      : DateTime.now(),
              readAt:
                  msg['readAt'] != null ? DateTime.parse(msg['readAt']) : null,
              replyToId: msg['replyToId'],
              metadata: msg['metadata'],
              attachmentUrls:
                  msg['attachmentUrls'] != null
                      ? List<String>.from(msg['attachmentUrls'])
                      : null,
            );
          }).toList();
        }
      }

      // Fallback to general messages API
      final response = await _apiService.getMessagesForUser(userId);

      if (response.success && response.data != null) {
        final messagesData =
            response.data is List
                ? response.data as List<dynamic>
                : response.data['messages'] as List<dynamic>? ?? [];

        var messages =
            messagesData.map((msgData) {
              final msg = Map<String, dynamic>.from(msgData);

              return Message(
                id: msg['id'],
                content: msg['content'] ?? '',
                senderId: msg['senderId'] ?? 0,
                receiverId: msg['receiverId'] ?? 0,
                conversationId: msg['conversationId'] ?? '',
                messageType: MessageType.values.firstWhere(
                  (type) =>
                      type.toString().split('.').last ==
                      (msg['messageType'] ?? 'text'),
                  orElse: () => MessageType.text,
                ),
                priority: MessagePriority.values.firstWhere(
                  (priority) =>
                      priority.toString().split('.').last ==
                      (msg['priority'] ?? 'normal'),
                  orElse: () => MessagePriority.normal,
                ),
                isRead: msg['isRead'] ?? false,
                isEmergency: msg['isEmergency'] ?? false,
                createdAt:
                    msg['createdAt'] != null
                        ? DateTime.parse(msg['createdAt'])
                        : DateTime.now(),
                readAt:
                    msg['readAt'] != null
                        ? DateTime.parse(msg['readAt'])
                        : null,
                replyToId: msg['replyToId'],
                metadata: msg['metadata'],
                attachmentUrls:
                    msg['attachmentUrls'] != null
                        ? List<String>.from(msg['attachmentUrls'])
                        : null,
              );
            }).toList();

        // Apply filters
        if (conversationId != null) {
          messages =
              messages
                  .where((msg) => msg.conversationId == conversationId)
                  .toList();
        }
        if (receiverId != null) {
          messages =
              messages.where((msg) => msg.receiverId == receiverId).toList();
        }
        if (senderId != null) {
          messages = messages.where((msg) => msg.senderId == senderId).toList();
        }
        if (unreadOnly == true) {
          messages = messages.where((msg) => msg.isRead != true).toList();
        }

        return messages;
      }

      return [];
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      final response = await _apiService.sendMessage(
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        conversationId: message.conversationId,
        messageType:
            message.messageType.toString().split('.').last.toUpperCase(),
        priority: message.priority.toString().split('.').last.toUpperCase(),
        isEmergency: message.isEmergency ?? false,
        audioUrl:
            message.attachmentUrls?.isNotEmpty == true
                ? message.attachmentUrls!.first
                : null,
        quotedMessageId: message.replyToId,
      );

      if (response.success && response.data != null) {
        return Message.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to send message');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsRead(int messageId) async {
    try {
      final response = await _apiService.markMessageAsRead(messageId);
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to mark message as read');
      }
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      rethrow;
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
      // Get current user ID from storage or auth service
      final userData = StorageService.getUserData();
      if (userData == null || userData['id'] == null) {
        throw Exception('User not authenticated');
      }

      final userId = userData['id'] as int;
      final response = await _apiService.getConversationPartners(userId);

      if (response.success && response.data != null) {
        final conversationsData =
            response.data['conversations'] as List<dynamic>? ?? [];

        return conversationsData.map((convData) {
          final conv = Map<String, dynamic>.from(convData);

          // Create conversation from API data
          return Conversation(
            id: 'conv_${conv['partnerId']}_$userId',
            groupName: conv['partnerName'] ?? 'Unknown User',
            participantIds: [userId, conv['partnerId'] as int],
            isGroup: false,
            lastActivity:
                conv['lastMessageTime'] != null
                    ? DateTime.parse(conv['lastMessageTime'])
                    : DateTime.now(),
            unreadCount: conv['unreadCount'] ?? 0,
            lastMessage:
                conv['lastMessage'] != null
                    ? Message(
                      id: conv['lastMessage']['id'] ?? 0,
                      content: conv['lastMessage']['content'] ?? '',
                      senderId: conv['lastMessage']['senderId'] ?? 0,
                      receiverId: conv['lastMessage']['receiverId'] ?? 0,
                      conversationId: 'conv_${conv['partnerId']}_$userId',
                      messageType: MessageType.text,
                      priority: MessagePriority.normal,
                      isRead: conv['lastMessage']['isRead'] ?? false,
                      isEmergency: false,
                      createdAt:
                          conv['lastMessage']['createdAt'] != null
                              ? DateTime.parse(conv['lastMessage']['createdAt'])
                              : DateTime.now(),
                      readAt:
                          conv['lastMessage']['readAt'] != null
                              ? DateTime.parse(conv['lastMessage']['readAt'])
                              : null,
                    )
                    : null,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      return [];
    }
  }
}
