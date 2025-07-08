import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_record_model.dart';
import '../../core/services/voice_service.dart';
import '../../widgets/voice_button.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Chat Message Model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isFromMe;
  final String? voiceFilePath;
  final int? voiceDuration;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isFromMe,
    this.voiceFilePath,
    this.voiceDuration,
    this.isRead = false,
  });
}

// Waveform Painter for voice messages
class WaveformPainter extends CustomPainter {
  final Color color;

  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final barWidth = size.width / 20;
    for (int i = 0; i < 20; i++) {
      final height = (i % 3 + 1) * size.height / 4;
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatScreen extends StatefulWidget {
  final HealthWorker contact;

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    setState(() {
      _messages.addAll([
        ChatMessage(
          id: '1',
          senderId: widget.contact.id,
          senderName: widget.contact.name,
          content: 'Muraho! Ni gute ubuzima bwawe?',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isFromMe: false,
        ),
        ChatMessage(
          id: '2',
          senderId: 'current_user',
          senderName: 'Wowe',
          content:
              'Muraho muganga. Ubuzima bwanjye ni bwiza. Ariko nfite ibibazo bimwe ku mihango yanjye.',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 45),
          ),
          isFromMe: true,
        ),
        ChatMessage(
          id: '3',
          senderId: widget.contact.id,
          senderName: widget.contact.name,
          content: 'Ni byiza ko wambwiye. Ni iki gibazo cyane?',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 30),
          ),
          isFromMe: false,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(isTablet),
      body: Column(
        children: [
          // Messages List
          Expanded(child: _buildMessagesList(isTablet)),

          // Message Input
          _buildMessageInput(isTablet),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 24 : 20,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: AppTheme.headingSmall.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
                Text(
                  widget.contact.specialization,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Voice Call Button
        IconButton(
          onPressed: _startVoiceCall,
          icon: const Icon(Icons.phone),
          tooltip: 'Guhamagara',
        ),

        // Video Call Button
        IconButton(
          onPressed: _startVideoCall,
          icon: const Icon(Icons.videocam),
          tooltip: 'Video call',
        ),

        // Emergency Button
        IconButton(
          onPressed: _showEmergencyOptions,
          icon: const Icon(Icons.emergency),
          tooltip: 'Ihutirwa',
        ),
      ],
    );
  }

  Widget _buildMessagesList(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message, isTablet, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isTablet, int index) {
    final isFromMe = message.isFromMe;

    return Container(
          margin: EdgeInsets.only(
            bottom: AppTheme.spacing8,
            left: isFromMe ? (isTablet ? 80 : 60) : 0,
            right: isFromMe ? 0 : (isTablet ? 80 : 60),
          ),
          child: Column(
            crossAxisAlignment:
                isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
                decoration: BoxDecoration(
                  color: isFromMe ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isFromMe ? 16 : 4),
                    bottomRight: Radius.circular(isFromMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.type == MessageType.voice)
                      _buildVoiceMessageContent(message, isFromMe, isTablet)
                    else
                      _buildTextMessageContent(message, isFromMe, isTablet),

                    SizedBox(height: AppTheme.spacing4),

                    Text(
                      _formatTime(message.timestamp),
                      style: AppTheme.bodySmall.copyWith(
                        color:
                            isFromMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppTheme.textSecondary,
                        fontSize: isTablet ? 12 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 300.ms)
        .slideX(begin: isFromMe ? 0.3 : -0.3, duration: 300.ms);
  }

  Widget _buildTextMessageContent(
    ChatMessage message,
    bool isFromMe,
    bool isTablet,
  ) {
    return Text(
      message.content,
      style: AppTheme.bodyMedium.copyWith(
        color: isFromMe ? Colors.white : AppTheme.textPrimary,
        fontSize: isTablet ? 16 : 14,
        height: 1.4,
      ),
    );
  }

  Widget _buildVoiceMessageContent(
    ChatMessage message,
    bool isFromMe,
    bool isTablet,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _playVoiceMessage(message),
          icon: Icon(
            Icons.play_arrow,
            color: isFromMe ? Colors.white : AppTheme.primaryColor,
          ),
        ),

        Expanded(
          child: Container(
            height: 30,
            child: CustomPaint(
              painter: WaveformPainter(
                color: isFromMe ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ),

        Text(
          '0:${message.voiceDuration ?? 15}',
          style: AppTheme.bodySmall.copyWith(
            color:
                isFromMe
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice Recording Button
          Consumer<VoiceService>(
            builder: (context, voiceService, child) {
              return GestureDetector(
                onTapDown: (_) => _startVoiceRecording(),
                onTapUp: (_) => _stopVoiceRecording(),
                onTapCancel: () => _cancelVoiceRecording(),
                child: Container(
                  width: isTablet ? 50 : 45,
                  height: isTablet ? 50 : 45,
                  decoration: BoxDecoration(
                    color:
                        _isRecording
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              );
            },
          ),

          SizedBox(width: AppTheme.spacing12),

          // Text Input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Andika ubutumwa...',
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    _isTyping = text.isNotEmpty;
                  });
                },
                onSubmitted: (_) => _sendTextMessage(),
              ),
            ),
          ),

          SizedBox(width: AppTheme.spacing12),

          // Send Button
          GestureDetector(
            onTap: _isTyping ? _sendTextMessage : _showMessageOptions,
            child: Container(
              width: isTablet ? 50 : 45,
              height: isTablet ? 50 : 45,
              decoration: BoxDecoration(
                color:
                    _isTyping ? AppTheme.primaryColor : AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _isTyping ? Icons.send : Icons.add,
                color: Colors.white,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Voice Recording Methods
  Future<void> _startVoiceRecording() async {
    setState(() {
      _isRecording = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final voiceService = Provider.of<VoiceService>(context, listen: false);
      await voiceService.startRecording(filePath);

      // Provide haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showError('Habaye ikosa mu gufata ijwi: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopVoiceRecording() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
    });

    try {
      final voiceService = Provider.of<VoiceService>(context, listen: false);
      final filePath = await voiceService.stopRecording();

      if (filePath != null) {
        _sendVoiceMessage(filePath);
      }
    } catch (e) {
      _showError('Habaye ikosa mu guhagarika gufata ijwi: $e');
    }
  }

  void _cancelVoiceRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });

      final voiceService = Provider.of<VoiceService>(context, listen: false);
      voiceService.stopRecording();
    }
  }

  // Message Sending Methods
  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'Wowe',
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _isTyping = false;
    });

    _scrollToBottom();
    _simulateResponse();
  }

  void _sendVoiceMessage(String filePath) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'Wowe',
      content: 'Ubutumwa bw\'ijwi',
      type: MessageType.voice,
      timestamp: DateTime.now(),
      isFromMe: true,
      voiceFilePath: filePath,
      voiceDuration: 15, // Placeholder duration
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
    _simulateResponse();
  }

  // Communication Methods
  void _startVoiceCall() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.phone, color: AppTheme.primaryColor),
                SizedBox(width: AppTheme.spacing8),
                Text('Guhamagara'),
              ],
            ),
            content: Text('Ushaka guhamagara ${widget.contact.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kuraguza'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initiateVoiceCall();
                },
                child: Text('Hamagara'),
              ),
            ],
          ),
    );
  }

  void _startVideoCall() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.videocam, color: AppTheme.primaryColor),
                SizedBox(width: AppTheme.spacing8),
                Text('Video Call'),
              ],
            ),
            content: Text(
              'Ushaka gukora video call na ${widget.contact.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kuraguza'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initiateVideoCall();
                },
                child: Text('Tangira'),
              ),
            ],
          ),
    );
  }

  void _showEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ubufasha bw\'ihutirwa', style: AppTheme.headingMedium),
                SizedBox(height: AppTheme.spacing20),

                ListTile(
                  leading: Icon(Icons.emergency, color: AppTheme.errorColor),
                  title: Text('Hamagara ihutirwa'),
                  subtitle: Text('Guhamagara kuri 912'),
                  onTap: () {
                    Navigator.pop(context);
                    _callEmergency();
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.local_hospital,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text('Saba ubufasha bw\'ihutirwa'),
                  subtitle: Text('Kohereza ubutumwa bw\'ihutirwa ku muganga'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendEmergencyMessage();
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: AppTheme.successColor,
                  ),
                  title: Text('Shakisha ikigo cy\'ubuzima hafi'),
                  subtitle: Text('Reba ikigo cy\'ubuzima hafi yawe'),
                  onTap: () {
                    Navigator.pop(context);
                    _findNearestHealthFacility();
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Utility Methods
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo, color: AppTheme.primaryColor),
                  title: Text('Kohereza ifoto'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendImage();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.attach_file,
                    color: AppTheme.secondaryColor,
                  ),
                  title: Text('Kohereza dosiye'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendFile();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: AppTheme.successColor,
                  ),
                  title: Text('Kohereza aho uri'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendLocation();
                  },
                ),
              ],
            ),
          ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  void _playVoiceMessage(ChatMessage message) {
    if (message.voiceFilePath != null) {
      final voiceService = Provider.of<VoiceService>(context, listen: false);
      voiceService.playAudio(message.voiceFilePath!);
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

  void _simulateResponse() {
    // Simulate health worker response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final responses = [
          'Murakoze ku kubaza. Ni byiza gukurikirana ubuzima bwawe.',
          'Ese hari ikindi ushaka kubaza?',
          'Ni byiza ko wambwiye. Komeza gutyo.',
          'Uzajya ku kigo cy\'ubuzima mu minsi itatu iri imbere.',
        ];

        final response = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: widget.contact.id,
          senderName: widget.contact.name,
          content: responses[DateTime.now().millisecond % responses.length],
          type: MessageType.text,
          timestamp: DateTime.now(),
          isFromMe: false,
        );

        setState(() {
          _messages.add(response);
        });

        _scrollToBottom();
      }
    });
  }

  // Communication Implementation Methods
  void _initiateVoiceCall() {
    // In a real app, this would integrate with calling services
    _showError('Guhamagara bizashyirwa mu bikorwa vuba...');
  }

  void _initiateVideoCall() {
    // In a real app, this would integrate with video calling services
    _showError('Video call izashyirwa mu bikorwa vuba...');
  }

  void _callEmergency() {
    // In a real app, this would call emergency services
    _showError('Guhamagara ihutirwa bizashyirwa mu bikorwa vuba...');
  }

  void _sendEmergencyMessage() {
    final emergencyMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'Wowe',
      content:
          '🚨 IHUTIRWA: Nkeneye ubufasha bw\'ihutirwa. Nyamuneka mfashe vuba.',
      type: MessageType.text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );

    setState(() {
      _messages.add(emergencyMessage);
    });

    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ubutumwa bw\'ihutirwa bwoherejwe'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _findNearestHealthFacility() {
    _showError('Gushakisha ikigo cy\'ubuzima bizashyirwa mu bikorwa vuba...');
  }

  void _sendImage() {
    _showError('Kohereza amafoto bizashyirwa mu bikorwa vuba...');
  }

  void _sendFile() {
    _showError('Kohereza amadosiye bizashyirwa mu bikorwa vuba...');
  }

  void _sendLocation() {
    _showError('Kohereza aho uri bizashyirwa mu bikorwa vuba...');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
