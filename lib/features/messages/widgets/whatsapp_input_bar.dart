import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// WhatsApp-style input bar with text and audio recording
class WhatsAppInputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSendText;
  final Function(String, int) onSendAudio;
  final bool isSending;

  const WhatsAppInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendText,
    required this.onSendAudio,
    required this.isSending,
  });

  @override
  State<WhatsAppInputBar> createState() => _WhatsAppInputBarState();
}

class _WhatsAppInputBarState extends State<WhatsAppInputBar>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasText = false;
  late FlutterSoundRecorder _audioRecorder;
  String? _recordingPath;
  DateTime? _recordingStartTime;

  late AnimationController _recordingController;
  late Animation<double> _recordingAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _initializeRecorder();
    _setupAnimations();
    _setupTextListener();
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }

  @override
  void dispose() {
    _recordingController.dispose();
    _pulseController.dispose();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  void _setupAnimations() {
    _recordingController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _recordingAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _recordingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupTextListener() {
    widget.controller.addListener(() {
      final hasText = widget.controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required for voice messages',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Initialize recorder if needed
      await _audioRecorder.openRecorder();

      // Get temporary directory for recording
      final directory = await getTemporaryDirectory();
      final fileName =
          'voice_message_${DateTime.now().millisecondsSinceEpoch}.aac';
      _recordingPath = '${directory.path}/$fileName';

      // Start recording
      await _audioRecorder.startRecorder(
        toFile: _recordingPath!,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
      });

      _recordingController.forward();
      _pulseController.repeat(reverse: true);

      // Provide haptic feedback
      // HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stopRecorder();

      if (path != null && _recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);

        // Only send if recording is longer than 1 second
        if (duration.inSeconds >= 1) {
          widget.onSendAudio(path, duration.inSeconds);
        } else {
          // Delete short recording
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice message too short'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordingPath = null;
      });

      _recordingController.reverse();
      _pulseController.stop();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stopRecorder();

      // Delete the recording file
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordingPath = null;
      });

      _recordingController.reverse();
      _pulseController.stop();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  void _sendTextMessage() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && !widget.isSending) {
      widget.onSendText(text);
    }
  }

  void _showEmojiPicker() {
    // TODO: Implement emoji picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emoji picker coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _getRecordingDuration() {
    if (_recordingStartTime == null) return '0:00';

    final duration = DateTime.now().difference(_recordingStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: _isRecording ? _buildRecordingBar() : _buildInputBar(),
    );
  }

  Widget _buildInputBar() {
    return Row(
      children: [
        // Attachment button
        IconButton(
          onPressed: _showAttachmentOptions,
          icon: Icon(Icons.attach_file, color: Colors.grey[600]),
        ),

        // Text input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
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

                // Emoji button
                IconButton(
                  onPressed: _showEmojiPicker,
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Send/Mic button
        GestureDetector(
          onTap: _hasText ? _sendTextMessage : null,
          onLongPressStart: _hasText ? null : (_) => _startRecording(),
          onLongPressEnd: _hasText ? null : (_) => _stopRecording(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF075E54), // WhatsApp green
              shape: BoxShape.circle,
            ),
            child: Icon(
              _hasText ? Icons.send : Icons.mic,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Row(
      children: [
        // Cancel button
        IconButton(
          onPressed: _cancelRecording,
          icon: const Icon(Icons.close, color: Colors.red),
        ),

        // Recording indicator
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // Recording text and duration
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Recording...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              Text(
                _getRecordingDuration(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Stop recording button
        AnimatedBuilder(
          animation: _recordingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _recordingAnimation.value,
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF075E54),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            );
          },
        ),
      ],
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
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement camera
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement gallery
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.orange),
                  title: const Text('Document'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement document picker
                  },
                ),
              ],
            ),
          ),
    );
  }
}
