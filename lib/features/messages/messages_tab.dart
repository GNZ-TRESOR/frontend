import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/message.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';
import 'conversation_screen.dart';
import 'compose_message_screen.dart';

class MessagesTab extends ConsumerStatefulWidget {
  const MessagesTab({super.key});

  @override
  ConsumerState<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<MessagesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider);

    return Scaffold(
      body:
          messagesState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : messagesState.error != null
              ? _buildErrorWidget(messagesState.error!)
              : _buildConversationsList(messagesState.conversations),
      floatingActionButton: FloatingActionButton(
        heroTag: "compose_message",
        onPressed: () => _navigateToComposeMessage(),
        backgroundColor: AppColors.communityTeal,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          'Error loading conversations'.at(
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(messagesProvider.notifier).loadConversations();
            },
            child: 'Retry'.at(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            'No conversations yet'.at(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            'Start a conversation with someone!'.at(
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.communityTeal,
        child:
            conversation.isGroup
                ? const Icon(Icons.group, color: Colors.white)
                : const Icon(Icons.person, color: Colors.white),
      ),
      title: conversation.displayName.at(
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle:
          conversation.lastMessage != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.lastMessage!.displayContent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(conversation.lastActivity),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              )
              : 'No messages yet'.at(
                style: const TextStyle(color: Colors.grey),
              ),
      trailing:
          conversation.unreadCount > 0
              ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.communityTeal,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
      onTap: () => _navigateToConversation(conversation),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToConversation(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(conversation: conversation),
      ),
    );
  }

  void _navigateToComposeMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComposeMessageScreen()),
    );
  }
}
