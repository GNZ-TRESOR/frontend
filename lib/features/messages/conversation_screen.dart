import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/message.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ConversationScreen({super.key, required this.conversation});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    await ref
        .read(messagesProvider.notifier)
        .loadMessages(conversationId: widget.conversation.id);

    setState(() {
      _isLoading = false;
    });

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

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: widget.conversation.displayName.at(),
        backgroundColor: AppColors.communityTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showConversationInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessagesList(messagesState.messages),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    if (messages.isEmpty) {
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
            'No messages yet'.at(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            'Start the conversation!'.at(
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == 1; // TODO: Get current user ID
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.communityTeal,
              child: Text(
                message.senderId.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isMe
                        ? AppColors.communityTeal
                        : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft:
                      isMe
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                  bottomRight:
                      isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isEmergency == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: 'EMERGENCY'.at(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    message.displayContent,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color:
                              isMe
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead == true ? Icons.done_all : Icons.done,
                          size: 16,
                          color:
                              message.isRead == true
                                  ? Colors.blue[300]
                                  : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          ],
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
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: const Icon(Icons.attach_file),
            color: AppColors.communityTeal,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "send_message",
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: AppColors.communityTeal,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = Message(
      createdAt: DateTime.now(),
      content: content,
      conversationId: widget.conversation.id,
      isEmergency: false,
      isRead: false,
      messageType: MessageType.text,
      priority: MessagePriority.normal,
      receiverId:
          widget
              .conversation
              .participantIds
              .first, // TODO: Get correct receiver
      senderId: 1, // TODO: Get current user ID
    );

    ref.read(messagesProvider.notifier).sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                'Attach File'.at(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.photo,
                    color: AppColors.communityTeal,
                  ),
                  title: 'Photo'.at(),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement photo attachment
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.videocam,
                    color: AppColors.communityTeal,
                  ),
                  title: 'Video'.at(),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement video attachment
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: AppColors.communityTeal,
                  ),
                  title: 'Document'.at(),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement document attachment
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: AppColors.communityTeal,
                  ),
                  title: 'Location'.at(),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement location sharing
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showConversationInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: 'Conversation Info'.at(),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                'Participants: ${widget.conversation.participantIds.length}'
                    .at(),
                const SizedBox(height: 8),
                'Type: ${widget.conversation.isGroup ? 'Group' : 'Direct'}'
                    .at(),
                if (widget.conversation.unreadCount > 0) ...[
                  const SizedBox(height: 8),
                  'Unread messages: ${widget.conversation.unreadCount}'.at(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: 'Close'.at(),
              ),
            ],
          ),
    );
  }
}
