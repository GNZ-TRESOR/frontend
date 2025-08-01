import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/support_group.dart';
import '../models/support_ticket.dart';
import '../models/message.dart';
import '../services/community_service.dart';

// Community Service Provider
final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService();
});

// Support Groups State
class SupportGroupsState {
  final List<SupportGroup> groups;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const SupportGroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  SupportGroupsState copyWith({
    List<SupportGroup>? groups,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return SupportGroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// Support Groups Notifier
class SupportGroupsNotifier extends StateNotifier<SupportGroupsState> {
  final CommunityService _communityService;

  SupportGroupsNotifier(this._communityService) : super(const SupportGroupsState());

  Future<void> loadSupportGroups({
    String? category,
    bool? isPrivate,
    bool? isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final groups = await _communityService.getSupportGroups(
        category: category,
        isPrivate: isPrivate,
        isActive: isActive,
      );
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createGroup(SupportGroup group) async {
    try {
      final newGroup = await _communityService.createSupportGroup(group);
      state = state.copyWith(
        groups: [...state.groups, newGroup],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> joinGroup(int groupId) async {
    try {
      await _communityService.joinGroup(groupId);
      // Reload groups to update member count
      await loadSupportGroups(category: state.selectedCategory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> leaveGroup(int groupId) async {
    try {
      await _communityService.leaveGroup(groupId);
      // Reload groups to update member count
      await loadSupportGroups(category: state.selectedCategory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadSupportGroups(category: category);
  }
}

// Support Groups Provider
final supportGroupsProvider = StateNotifierProvider<SupportGroupsNotifier, SupportGroupsState>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  return SupportGroupsNotifier(communityService);
});

// Support Tickets State
class SupportTicketsState {
  final List<SupportTicket> tickets;
  final bool isLoading;
  final String? error;
  final TicketStatus? selectedStatus;

  const SupportTicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
  });

  SupportTicketsState copyWith({
    List<SupportTicket>? tickets,
    bool? isLoading,
    String? error,
    TicketStatus? selectedStatus,
  }) {
    return SupportTicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

// Support Tickets Notifier
class SupportTicketsNotifier extends StateNotifier<SupportTicketsState> {
  final CommunityService _communityService;

  SupportTicketsNotifier(this._communityService) : super(const SupportTicketsState());

  Future<void> loadSupportTickets({
    TicketStatus? status,
    TicketType? type,
    TicketPriority? priority,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tickets = await _communityService.getSupportTickets(
        status: status,
        type: type,
        priority: priority,
      );
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createTicket(SupportTicket ticket) async {
    try {
      final newTicket = await _communityService.createSupportTicket(ticket);
      state = state.copyWith(
        tickets: [...state.tickets, newTicket],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTicket(int id, SupportTicket ticket) async {
    try {
      final updatedTicket = await _communityService.updateSupportTicket(id, ticket);
      final updatedTickets = state.tickets.map((t) {
        return t.id == id ? updatedTicket : t;
      }).toList();
      state = state.copyWith(tickets: updatedTickets);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setSelectedStatus(TicketStatus? status) {
    state = state.copyWith(selectedStatus: status);
    loadSupportTickets(status: status);
  }
}

// Support Tickets Provider
final supportTicketsProvider = StateNotifierProvider<SupportTicketsNotifier, SupportTicketsState>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  return SupportTicketsNotifier(communityService);
});

// Messages State
class MessagesState {
  final List<Message> messages;
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;
  final String? selectedConversationId;

  const MessagesState({
    this.messages = const [],
    this.conversations = const [],
    this.isLoading = false,
    this.error,
    this.selectedConversationId,
  });

  MessagesState copyWith({
    List<Message>? messages,
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
    String? selectedConversationId,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedConversationId: selectedConversationId ?? this.selectedConversationId,
    );
  }
}

// Messages Notifier
class MessagesNotifier extends StateNotifier<MessagesState> {
  final CommunityService _communityService;

  MessagesNotifier(this._communityService) : super(const MessagesState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final conversations = await _communityService.getConversations();
      state = state.copyWith(conversations: conversations, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadMessages({
    String? conversationId,
    int? receiverId,
    int? senderId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final messages = await _communityService.getMessages(
        conversationId: conversationId,
        receiverId: receiverId,
        senderId: senderId,
      );
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      final sentMessage = await _communityService.sendMessage(message);
      state = state.copyWith(
        messages: [...state.messages, sentMessage],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      await _communityService.markMessageAsRead(messageId);
      final updatedMessages = state.messages.map((m) {
        return m.id == messageId ? m.copyWith(isRead: true, readAt: DateTime.now()) : m;
      }).toList();
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectConversation(String conversationId) {
    state = state.copyWith(selectedConversationId: conversationId);
    loadMessages(conversationId: conversationId);
  }
}

// Messages Provider
final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  return MessagesNotifier(communityService);
});
