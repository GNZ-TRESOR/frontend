import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/message.dart';
import 'widgets/whatsapp_message_bubble.dart';
import 'widgets/whatsapp_input_bar.dart';
import 'widgets/typing_indicator.dart';

/// WhatsApp-like chat screen with modern UI and features
class WhatsAppChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> otherUser;
  final String? conversationId;

  const WhatsAppChatScreen({
    super.key,
    required this.otherUser,
    this.conversationId,
  });

  @override
  ConsumerState<WhatsAppChatScreen> createState() {
    debugPrint('🏭 WhatsApp Chat Screen createState() called');
    return _WhatsAppChatScreenState();
  }
}

class _WhatsAppChatScreenState extends ConsumerState<WhatsAppChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  String? _conversationId;

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    debugPrint('🚀🚀🚀 INIT STATE CALLED 🚀🚀🚀');
    super.initState();
    debugPrint('🔍 Other user: ${widget.otherUser}');
    debugPrint('🔍 Conversation ID: ${widget.conversationId}');

    _conversationId = widget.conversationId;
    _setupAnimations();
    debugPrint('🔄 About to call _loadMessages()');
    _loadMessages();
    _setupMessageListener();
    debugPrint('✅ WhatsApp Chat Screen initState() completed');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setupMessageListener() {
    _messageController.addListener(() {
      final isTyping = _messageController.text.trim().isNotEmpty;
      if (isTyping != _isTyping) {
        setState(() => _isTyping = isTyping);
        // TODO: Send typing indicator via WebSocket
      }
    });
  }

  /// Parse message from API response, handling Java LocalDateTime arrays
  Message _parseMessage(Map<String, dynamic> data) {
    debugPrint('🔍 Parsing message data: ${data.keys.toList()}');

    // Convert Java LocalDateTime arrays to DateTime objects
    DateTime parseJavaDateTime(dynamic dateArray) {
      if (dateArray is List && dateArray.length >= 3) {
        final year = dateArray[0] as int;
        final month = dateArray[1] as int;
        final day = dateArray[2] as int;
        final hour = dateArray.length > 3 ? dateArray[3] as int : 0;
        final minute = dateArray.length > 4 ? dateArray[4] as int : 0;
        final second = dateArray.length > 5 ? dateArray[5] as int : 0;
        final microsecond =
            dateArray.length > 6 ? (dateArray[6] as int) ~/ 1000 : 0;

        return DateTime(year, month, day, hour, minute, second, 0, microsecond);
      }
      return DateTime.now();
    }

    // Parse sender and receiver info
    final senderData = data['sender'] as Map<String, dynamic>? ?? {};
    final receiverData = data['receiver'] as Map<String, dynamic>? ?? {};

    // Extract message content - try multiple possible field names
    String? messageContent =
        data['content'] as String? ??
        data['message'] as String? ??
        data['text'] as String? ??
        data['messageContent'] as String? ??
        'Test message content';

    debugPrint('🔍 Message content: $messageContent');
    debugPrint(
      '🔍 Sender ID: ${senderData['id']}, Receiver ID: ${receiverData['id']}',
    );

    return Message(
      id: data['id'] as int?,
      createdAt: parseJavaDateTime(data['createdAt']),
      updatedAt:
          data['updatedAt'] != null
              ? parseJavaDateTime(data['updatedAt'])
              : null,
      version: data['version'] as int?,
      content: messageContent,
      senderId: senderData['id'] as int? ?? 0,
      receiverId: receiverData['id'] as int? ?? 0,
      messageType: _parseMessageType(
        data['type'] as String? ?? data['messageType'] as String?,
      ),
      isRead: data['isRead'] as bool? ?? false,
      deliveredAt:
          data['deliveredAt'] != null
              ? parseJavaDateTime(data['deliveredAt'])
              : null,
      readAt: data['readAt'] != null ? parseJavaDateTime(data['readAt']) : null,
      audioUrl: data['audioUrl'] as String?,
      audioDuration: data['audioDuration'] as int?,
      attachmentUrls:
          data['attachmentUrls'] != null
              ? List<String>.from(data['attachmentUrls'] as List)
              : null,
    );
  }

  /// Parse message type from string
  MessageType _parseMessageType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'audio':
        return MessageType.audio;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'document':
        return MessageType.document;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  Future<void> _loadMessages() async {
    debugPrint('🔥🔥🔥 LOAD MESSAGES CALLED 🔥🔥🔥');
    try {
      setState(() => _isLoading = true);
      debugPrint('🔄 Loading state set to true');

      final user = ref.read(currentUserProvider);
      debugPrint('👤 Current user: ${user?.id}');
      if (user?.id == null) {
        debugPrint('❌ No user ID found, returning');
        return;
      }

      final otherUserId = widget.otherUser['id'];
      final response = await ApiService.instance.getConversation(
        user!.id!,
        otherUserId,
      );

      debugPrint('🔍 API Response success: ${response.success}');
      debugPrint('🔍 API Response data: ${response.data}');
      debugPrint('🔍 API Response data type: ${response.data?.runtimeType}');

      if (response.success && response.data != null) {
        debugPrint('✅ Response is successful and has data');
        final messagesData = response.data['messages'] as List<dynamic>? ?? [];
        debugPrint('📨 Raw messages data: ${messagesData.length} messages');
        debugPrint('📨 Messages data type: ${messagesData.runtimeType}');
        debugPrint(
          '📨 First message sample: ${messagesData.isNotEmpty ? messagesData.first : 'No messages'}',
        );

        final parsedMessages = <Message>[];

        for (int i = 0; i < messagesData.length; i++) {
          try {
            final data = messagesData[i] as Map<String, dynamic>;
            debugPrint('🔍 Processing message $i: ${data.keys.toList()}');

            // Parse the real message from database
            final message = _parseMessage(data);
            parsedMessages.add(message);
            debugPrint(
              '✅ Added real message: ${message.id} - ${message.content}',
            );
          } catch (e) {
            debugPrint('❌ Failed to process message $i: $e');
            debugPrint('❌ Message data: ${messagesData[i]}');
          }
        }

        debugPrint('📨 Successfully parsed ${parsedMessages.length} messages');

        setState(() {
          _messages = parsedMessages;
        });

        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    } finally {
      debugPrint('🏁 Setting loading state to false');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage({
    String? text,
    String? audioUrl,
    int? audioDuration,
  }) async {
    if (_isSending) return;

    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty && audioUrl == null) return;

    setState(() => _isSending = true);
    if (text == null) _messageController.clear();

    try {
      final user = ref.read(currentUserProvider);
      if (user?.id == null) return;

      final response = await ApiService.instance.sendMessage(
        senderId: user!.id!,
        receiverId: widget.otherUser['id'],
        content: messageText,
        conversationId: _conversationId,
        messageType: audioUrl != null ? 'AUDIO' : 'TEXT',
        audioUrl: audioUrl,
        audioDuration: audioDuration,
      );

      if (response.success) {
        await _loadMessages(); // Refresh messages
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// Handle audio message upload and sending
  Future<void> _sendAudioMessage(String audioPath, int duration) async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user?.id == null) {
        throw Exception('User not authenticated');
      }

      // Upload audio file to backend
      debugPrint('🎤 Uploading audio file: $audioPath');
      final uploadResponse = await ApiService.instance.uploadAudioMessage(
        filePath: audioPath,
        senderId: user!.id!,
        receiverId: widget.otherUser['id'],
        duration: duration,
        conversationId: _conversationId,
      );

      if (uploadResponse.success && uploadResponse.data != null) {
        final audioUrl = uploadResponse.data['audioUrl'] as String?;
        if (audioUrl != null) {
          debugPrint('✅ Audio uploaded successfully: $audioUrl');
          // Send the audio message
          await _sendMessage(audioUrl: audioUrl, audioDuration: duration);
        } else {
          throw Exception('Audio URL not received from server');
        }
      } else {
        throw Exception(uploadResponse.message ?? 'Failed to upload audio');
      }
    } catch (e) {
      debugPrint('❌ Error sending audio message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send audio message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
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
    debugPrint('🎨 WhatsApp Chat Screen build() called');
    debugPrint('🎨 Messages count: ${_messages.length}');
    debugPrint('🎨 Is loading: $_isLoading');

    final user = ref.watch(currentUserProvider);
    final otherUserName = widget.otherUser['name'] ?? 'Unknown User';
    final isOnline = widget.otherUser['isOnline'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // WhatsApp background color
      appBar: _buildAppBar(otherUserName, isOnline),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessagesList(user?.id),
          ),

          // Typing indicator
          if (_otherUserTyping) TypingIndicator(userName: otherUserName),

          // Input bar
          WhatsAppInputBar(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSendText: (text) => _sendMessage(text: text),
            onSendAudio:
                (audioPath, duration) => _sendAudioMessage(audioPath, duration),
            isSending: _isSending,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String otherUserName, bool isOnline) {
    return AppBar(
      backgroundColor: const Color(0xFF075E54), // WhatsApp green
      foregroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      title: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              otherUserName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Last seen recently',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _initiateVideoCall(),
          icon: const Icon(Icons.videocam, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _initiateVoiceCall(),
          icon: const Icon(Icons.call, color: Colors.white),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view_contact',
                  child: Text('View contact'),
                ),
                const PopupMenuItem(
                  value: 'media',
                  child: Text('Media, links, and docs'),
                ),
                const PopupMenuItem(value: 'search', child: Text('Search')),
                const PopupMenuItem(
                  value: 'mute',
                  child: Text('Mute notifications'),
                ),
                const PopupMenuItem(
                  value: 'wallpaper',
                  child: Text('Wallpaper'),
                ),
                const PopupMenuItem(
                  value: 'clear_chat',
                  child: Text('Clear chat'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildMessagesList(int? currentUserId) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == currentUserId;
        final showDateHeader = _shouldShowDateHeader(index);

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.createdAt),
            WhatsAppMessageBubble(
              message: message,
              isMe: isMe,
              onReply: () => _replyToMessage(message),
              onReact: (emoji) => _reactToMessage(message, emoji),
              onForward: () => _forwardMessage(message),
              onDelete: () => _deleteMessage(message),
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];

    final currentDate = DateTime(
      currentMessage.createdAt.year,
      currentMessage.createdAt.month,
      currentMessage.createdAt.day,
    );

    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );

    return !currentDate.isAtSameMomentAs(previousDate);
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (messageDate.isAtSameMomentAs(
      today.subtract(const Duration(days: 1)),
    )) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _initiateVideoCall() {
    final otherUserName = widget.otherUser['name'] ?? 'Unknown User';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📹 Video calling $otherUserName...'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implement actual video call functionality
  }

  void _initiateVoiceCall() async {
    final otherUserName = widget.otherUser['name'] ?? 'Unknown User';
    final phoneNumber =
        widget.otherUser['phone'] ?? widget.otherUser['phoneNumber'];

    if (phoneNumber == null || phoneNumber.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No phone number available for $otherUserName'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.toString().replaceAll(
        RegExp(r'[^\d+]'),
        '',
      );

      // Create the tel: URL
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      // Check if the device can handle phone calls
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📞 Calling $otherUserName...'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Fallback: show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot make phone calls on this device'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to make phone call: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action feature coming soon!')));
  }

  void _replyToMessage(Message message) {
    // TODO: Implement reply functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reply feature coming soon!')));
  }

  void _reactToMessage(Message message, String emoji) {
    // TODO: Implement reaction functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reacted with $emoji')));
  }

  void _forwardMessage(Message message) {
    // TODO: Implement forward functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forward feature coming soon!')),
    );
  }

  void _deleteMessage(Message message) {
    // TODO: Implement delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete feature coming soon!')),
    );
  }
}
