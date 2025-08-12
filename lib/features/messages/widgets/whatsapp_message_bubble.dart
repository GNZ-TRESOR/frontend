import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/message.dart';
import 'audio_message_player.dart';

/// WhatsApp-style message bubble with modern design
class WhatsAppMessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onReply;
  final Function(String)? onReact;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;

  const WhatsAppMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onReact,
    this.onForward,
    this.onDelete,
  });

  @override
  State<WhatsAppMessageBubble> createState() => _WhatsAppMessageBubbleState();
}

class _WhatsAppMessageBubbleState extends State<WhatsAppMessageBubble>
    with SingleTickerProviderStateMixin {
  bool _showReactions = false;
  late AnimationController _reactionController;
  late Animation<double> _reactionAnimation;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _reactionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _reactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showMessageOptions,
      child: Container(
        margin: EdgeInsets.only(
          left: widget.isMe ? 64 : 8,
          right: widget.isMe ? 8 : 64,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment:
              widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? const Color(
                          0xFFDCF8C6,
                        ) // WhatsApp green for sent messages
                        : Colors.white, // White for received messages
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(widget.isMe ? 12 : 4),
                  bottomRight: Radius.circular(widget.isMe ? 4 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Message content
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Forwarded indicator
                        if (widget.message.isForwarded == true)
                          _buildForwardedIndicator(),

                        // Quoted message
                        if (widget.message.quotedMessageId != null)
                          _buildQuotedMessage(),

                        // Message content
                        _buildMessageContent(),

                        // Message info (time, status)
                        _buildMessageInfo(),
                      ],
                    ),
                  ),

                  // Reaction
                  if (widget.message.reaction != null) _buildReaction(),
                ],
              ),
            ),

            // Reaction picker
            if (_showReactions) _buildReactionPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildForwardedIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forward, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            'Forwarded',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: widget.isMe ? Colors.green : Colors.blue,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original Sender', // TODO: Get actual sender name
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isMe ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Original message content...', // TODO: Get actual quoted content
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.message.messageType) {
      case MessageType.audio:
        return AudioMessagePlayer(
          audioUrl: widget.message.audioUrl ?? '',
          duration: widget.message.audioDuration ?? 0,
          isMe: widget.isMe,
        );

      case MessageType.image:
        return _buildImageMessage();

      case MessageType.video:
        return _buildVideoMessage();

      case MessageType.document:
        return _buildDocumentMessage();

      case MessageType.text:
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      child: Text(
        widget.message.content ?? '',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Image', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Video', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description, color: Colors.blue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Document',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(widget.message.fileSize ?? 0) / 1024} KB',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Edited indicator
          if (widget.message.editedAt != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'edited',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Time
          Text(
            DateFormat('HH:mm').format(widget.message.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),

          // Message status (for sent messages)
          if (widget.isMe) ...[const SizedBox(width: 4), _buildMessageStatus()],
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color = Colors.grey[600]!;

    switch (widget.message.messageStatus?.toUpperCase()) {
      case 'SENT':
        icon = Icons.check;
        break;
      case 'DELIVERED':
        icon = Icons.done_all;
        break;
      case 'READ':
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      default:
        icon = Icons.schedule;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildReaction() {
    return Positioned(
      bottom: -8,
      right: widget.isMe ? 8 : null,
      left: widget.isMe ? null : 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          widget.message.reaction!,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildReactionPicker() {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    return AnimatedBuilder(
      animation: _reactionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _reactionAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  reactions.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        widget.onReact?.call(emoji);
                        _hideReactions();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showMessageOptions() {
    setState(() => _showReactions = true);
    _reactionController.forward();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _hideReactions();
    });
  }

  void _hideReactions() {
    _reactionController.reverse().then((_) {
      if (mounted) {
        setState(() => _showReactions = false);
      }
    });
  }
}
