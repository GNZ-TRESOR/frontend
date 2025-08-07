import 'package:flutter/foundation.dart';

import '../models/support_group.dart';
import '../models/support_ticket.dart';
import '../models/message.dart';
import 'api_service.dart';
import 'storage_service.dart';

class CommunityService {
  final ApiService _apiService = ApiService.instance;

  // Mock data for fallback - will be replaced with real API calls
  static final List<SupportGroup> _mockGroups = [
    SupportGroup(
      id: 1,
      name: 'First Time Mothers',
      category: 'Pregnancy & Parenting',
      description: 'Support for new mothers navigating pregnancy',
      memberCount: 245,
      isActive: true,
      isPrivate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      creatorId: 1,
    ),
    SupportGroup(
      id: 2,
      name: 'Family Planning Support',
      category: 'General Health',
      description: 'Discussing contraception and family planning',
      memberCount: 189,
      isActive: true,
      isPrivate: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      creatorId: 2,
    ),
  ];

  static final List<SupportTicket> _mockTickets = [
    SupportTicket(
      id: 1,
      subject: 'App Login Issue',
      description: 'Cannot log into the app with my credentials',
      status: TicketStatus.open,
      priority: TicketPriority.medium,
      ticketType: TicketType.technical,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      userId: 1,
    ),
    SupportTicket(
      id: 2,
      subject: 'Medication Reminder Not Working',
      description: 'The medication reminder notifications are not appearing',
      status: TicketStatus.inProgress,
      priority: TicketPriority.high,
      ticketType: TicketType.technical,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      userId: 1,
    ),
  ];

  static final List<Message> _mockMessages = [
    Message(
      id: 1,
      content: 'Thanks for the advice about morning sickness!',
      senderId: 1,
      receiverId: 2,
      conversationId: 'conv_1',
      messageType: MessageType.text,
      priority: MessagePriority.normal,
      isRead: true,
      isEmergency: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      readAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Message(
      id: 2,
      content: 'Your test results look great. Keep up the good work!',
      senderId: 2,
      receiverId: 1,
      conversationId: 'conv_1',
      messageType: MessageType.text,
      priority: MessagePriority.normal,
      isRead: false,
      isEmergency: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  static final List<Conversation> _mockConversations = [
    Conversation(
      id: 'conv_1',
      groupName: 'First Time Mothers',
      participantIds: [1, 2],
      isGroup: true,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 1,
      lastMessage: _mockMessages[1],
    ),
    Conversation(
      id: 'conv_2',
      groupName: 'Dr. Emily Johnson',
      participantIds: [1, 3],
      isGroup: false,
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      lastMessage: Message(
        id: 3,
        content: 'Your test results look great. Keep up the good work!',
        senderId: 3,
        receiverId: 1,
        conversationId: 'conv_2',
        messageType: MessageType.text,
        priority: MessagePriority.normal,
        isRead: true,
        isEmergency: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        readAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ),
  ];

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
        // Fallback to mock data if API fails
        return _getMockGroups(
          category: category,
          isPrivate: isPrivate,
          isActive: isActive,
        );
      }
    } catch (e) {
      // Fallback to mock data on error
      return _getMockGroups(
        category: category,
        isPrivate: isPrivate,
        isActive: isActive,
      );
    }
  }

  // Fallback method for mock data
  Future<List<SupportGroup>> _getMockGroups({
    String? category,
    bool? isPrivate,
    bool? isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var groups = List<SupportGroup>.from(_mockGroups);

    // Apply filters
    if (category != null) {
      groups = groups.where((group) => group.category == category).toList();
    }
    if (isPrivate != null) {
      groups = groups.where((group) => group.isPrivate == isPrivate).toList();
    }
    if (isActive != null) {
      groups = groups.where((group) => group.isActive == isActive).toList();
    }

    return groups;
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
      // Fallback to mock implementation
      await Future.delayed(const Duration(milliseconds: 500));

      final newGroup = SupportGroup(
        id: _mockGroups.length + 1,
        name: group.name,
        category: group.category,
        description: group.description,
        memberCount: 1,
        isActive: group.isActive,
        isPrivate: group.isPrivate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        creatorId: group.creatorId,
        contactInfo: group.contactInfo,
        meetingLocation: group.meetingLocation,
        meetingSchedule: group.meetingSchedule,
        maxMembers: group.maxMembers,
        tags: group.tags,
      );

      _mockGroups.add(newGroup);
      return newGroup;
    }
  }

  Future<SupportGroup> updateSupportGroup(int id, SupportGroup group) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockGroups.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updatedGroup = group.copyWith(id: id, updatedAt: DateTime.now());
      _mockGroups[index] = updatedGroup;
      return updatedGroup;
    }
    throw Exception('Support group not found');
  }

  Future<void> deleteSupportGroup(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockGroups.removeWhere((group) => group.id == id);
  }

  Future<List<SupportGroupMember>> getGroupMembers(int groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Return mock members
    return [
      SupportGroupMember(
        id: 1,
        userId: 1,
        groupId: groupId,
        role: GroupMemberRole.member,
        isActive: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 10)),
        lastActivityAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SupportGroupMember(
        id: 2,
        userId: 2,
        groupId: groupId,
        role: GroupMemberRole.admin,
        isActive: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActivityAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
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
    await Future.delayed(const Duration(milliseconds: 500));

    var tickets = List<SupportTicket>.from(_mockTickets);

    // Apply filters
    if (status != null) {
      tickets = tickets.where((ticket) => ticket.status == status).toList();
    }
    if (type != null) {
      tickets = tickets.where((ticket) => ticket.ticketType == type).toList();
    }
    if (priority != null) {
      tickets = tickets.where((ticket) => ticket.priority == priority).toList();
    }

    return tickets;
  }

  Future<SupportTicket> createSupportTicket(SupportTicket ticket) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newTicket = SupportTicket(
      id: _mockTickets.length + 1,
      subject: ticket.subject,
      description: ticket.description,
      status: TicketStatus.open,
      priority: ticket.priority,
      ticketType: ticket.ticketType,
      createdAt: DateTime.now(),
      userId: ticket.userId,
      userEmail: ticket.userEmail,
      userPhone: ticket.userPhone,
    );

    _mockTickets.add(newTicket);
    return newTicket;
  }

  Future<SupportTicket> updateSupportTicket(
    int id,
    SupportTicket ticket,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockTickets.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updatedTicket = ticket.copyWith(id: id, updatedAt: DateTime.now());
      _mockTickets[index] = updatedTicket;
      return updatedTicket;
    }
    throw Exception('Support ticket not found');
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
      // Fallback to mock data if API fails
      var messages = List<Message>.from(_mockMessages);

      // Apply filters to mock data
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
  }

  Future<Message> sendMessage(Message message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newMessage = Message(
      id: _mockMessages.length + 1,
      content: message.content,
      senderId: message.senderId,
      receiverId: message.receiverId,
      conversationId: message.conversationId,
      messageType: message.messageType,
      priority: message.priority,
      isRead: false,
      isEmergency: message.isEmergency,
      createdAt: DateTime.now(),
      metadata: message.metadata,
      attachmentUrls: message.attachmentUrls,
      replyToId: message.replyToId,
    );

    _mockMessages.add(newMessage);
    return newMessage;
  }

  Future<void> markMessageAsRead(int messageId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockMessages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _mockMessages[index] = _mockMessages[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
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
      // Fallback to mock data if API fails
      return List<Conversation>.from(_mockConversations);
    }
  }
}
