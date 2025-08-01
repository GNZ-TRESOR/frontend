import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';

/// Chat message bubble widget
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isAssistant = message.sender == MessageSender.assistant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant avatar
          if (isAssistant) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                color: message.hasError ? Colors.red : AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                message.isLoading
                    ? Icons.more_horiz
                    : message.hasError
                        ? Icons.error_outline
                        : Icons.smart_toy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(isUser, message),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  if (message.isLoading)
                    _buildLoadingIndicator()
                  else
                    _buildMessageContent(context, isUser),

                  // Timestamp and actions
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isUser ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (message.hasError && onRetry != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onRetry,
                          child: Icon(
                            Icons.refresh,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (isAssistant && !message.isLoading && !message.hasError) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(context, message.content),
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // User avatar
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(bool isUser, ChatMessage message) {
    if (isUser) {
      return AppColors.primary;
    } else if (message.hasError) {
      return Colors.red[50]!;
    } else {
      return Colors.white;
    }
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Thinking...',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    return SelectableText(
      message.content,
      style: TextStyle(
        fontSize: 15,
        color: isUser ? Colors.white : Colors.grey[800],
        height: 1.4,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
