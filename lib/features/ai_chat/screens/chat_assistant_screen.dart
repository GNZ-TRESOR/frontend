import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/quick_reply_chips.dart';

/// AI Chat Assistant Screen
class ChatAssistantScreen extends ConsumerStatefulWidget {
  const ChatAssistantScreen({super.key});

  @override
  ConsumerState<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends ConsumerState<ChatAssistantScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(message);
      _messageController.clear();
      
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _sendQuickReply(String message) {
    ref.read(chatProvider.notifier).sendMessage(message);
    
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final isLoading = chatState.isLoading;
    final isConnected = chatState.isConnected;

    // Auto-scroll when messages change
    ref.listen<List<ChatMessage>>(chatMessagesProvider, (previous, next) {
      if (next.length > (previous?.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubuzima Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearChatDialog();
                  break;
                case 'retry':
                  ref.read(chatProvider.notifier).retryLastMessage();
                  break;
                case 'connection':
                  ref.read(chatProvider.notifier).checkConnection();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'retry',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Retry Last'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'connection',
                child: Row(
                  children: [
                    Icon(Icons.wifi, size: 20),
                    SizedBox(width: 8),
                    Text('Check Connection'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[800], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Limited connectivity - responses may be delayed',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatMessageBubble(
                        message: message,
                        onRetry: message.hasError
                            ? () => ref.read(chatProvider.notifier).retryLastMessage()
                            : null,
                      );
                    },
                  ),
          ),

          // Quick reply chips (show only if no messages or after welcome)
          if (messages.length <= 1)
            QuickReplyChips(
              onQuickReply: _sendQuickReply,
              quickReplies: ref.read(chatProvider.notifier).getQuickReplies(),
            ),

          // Input bar
          ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: isLoading,
            isConnected: isConnected,
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
