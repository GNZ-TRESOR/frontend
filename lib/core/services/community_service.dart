import '../models/support_group.dart';
import '../models/support_ticket.dart';
import '../models/message.dart';

class CommunityService {
  // Mock data for now - will be replaced with real API calls
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
    // Simulate network delay
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

  Future<void> leaveGroup(int groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - just simulate success
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
    await Future.delayed(const Duration(milliseconds: 300));

    var messages = List<Message>.from(_mockMessages);

    // Apply filters
    if (conversationId != null) {
      messages =
          messages
              .where((msg) => msg.conversationId == conversationId)
              .toList();
    }
    if (receiverId != null) {
      messages = messages.where((msg) => msg.receiverId == receiverId).toList();
    }
    if (senderId != null) {
      messages = messages.where((msg) => msg.senderId == senderId).toList();
    }
    if (unreadOnly == true) {
      messages = messages.where((msg) => msg.isRead != true).toList();
    }

    return messages;
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
    await Future.delayed(const Duration(milliseconds: 400));
    return List<Conversation>.from(_mockConversations);
  }
}
