import 'package:flutter/material.dart';

class WhatsAppInputBar extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSendMessage;
  final Function(String)? onSendAudio;

  const WhatsAppInputBar({
    super.key,
    required this.textController,
    required this.onSendMessage,
    this.onSendAudio,
  });

  @override
  State<WhatsAppInputBar> createState() => _WhatsAppInputBarState();
}

class _WhatsAppInputBarState extends State<WhatsAppInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.textController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Emoji button
            IconButton(
              onPressed: _showEmojiPicker,
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey,
              ),
            ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: widget.textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Attachment button (when no text)
            if (!_hasText) ...[
              IconButton(
                onPressed: _showAttachmentOptions,
                icon: const Icon(Icons.attach_file, color: Colors.grey),
              ),

              // Camera/Video button
              IconButton(
                onPressed: _showCameraOptions,
                icon: const Icon(Icons.camera_alt, color: Colors.grey),
              ),

              // Voice message button
              IconButton(
                onPressed: _showVoiceMessageInfo,
                icon: const Icon(Icons.mic, color: Colors.grey),
              ),
            ],

            // Send button (when has text)
            if (_hasText)
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF25D366), // WhatsApp green
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = widget.textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      widget.textController.clear();
    }
  }

  void _showEmojiPicker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emoji picker coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showVoiceMessageInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice messages coming soon!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
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
                const Text(
                  'Send',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      color: Colors.pink,
                      onTap: () {
                        Navigator.pop(context);
                        _showFeatureComingSoon('Camera');
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.photo,
                      label: 'Gallery',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _showFeatureComingSoon('Gallery');
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.insert_drive_file,
                      label: 'Document',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _showFeatureComingSoon('Document');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showCameraOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Camera & Video',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.photo_camera,
                      label: 'Photo',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _showFeatureComingSoon('Photo capture');
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.videocam,
                      label: 'Video',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _showFeatureComingSoon('Video recording');
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.video_call,
                      label: 'Video Call',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _showFeatureComingSoon('Video call');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
