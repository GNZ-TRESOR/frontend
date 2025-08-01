import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/message.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class ComposeMessageScreen extends ConsumerStatefulWidget {
  const ComposeMessageScreen({super.key});

  @override
  ConsumerState<ComposeMessageScreen> createState() => _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends ConsumerState<ComposeMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  MessageType _selectedType = MessageType.text;
  MessagePriority _selectedPriority = MessagePriority.normal;
  bool _isEmergency = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Compose Message'.at(),
        backgroundColor: AppColors.communityTeal,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _sendMessage,
            child: 'Send'.at(
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipientField(),
              const SizedBox(height: 16),
              _buildSubjectField(),
              const SizedBox(height: 16),
              _buildMessageTypeField(),
              const SizedBox(height: 16),
              _buildPriorityField(),
              const SizedBox(height: 16),
              _buildEmergencySwitch(),
              const SizedBox(height: 16),
              _buildMessageField(),
              const SizedBox(height: 16),
              _buildAttachmentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientField() {
    return TextFormField(
      controller: _recipientController,
      decoration: InputDecoration(
        labelText: 'To *',
        hintText: 'Enter recipient ID or email',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a recipient';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      decoration: InputDecoration(
        labelText: 'Subject',
        hintText: 'Message subject (optional)',
        prefixIcon: const Icon(Icons.subject),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildMessageTypeField() {
    return DropdownButtonFormField<MessageType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Message Type',
        prefixIcon: const Icon(Icons.message),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: MessageType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              _getTypeIcon(type),
              const SizedBox(width: 8),
              type.name.toUpperCase().at(),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  Widget _buildPriorityField() {
    return DropdownButtonFormField<MessagePriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priority',
        prefixIcon: const Icon(Icons.priority_high),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: MessagePriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              _getPriorityIcon(priority),
              const SizedBox(width: 8),
              priority.name.toUpperCase().at(),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildEmergencySwitch() {
    return Card(
      color: _isEmergency ? Colors.red.withValues(alpha: 0.1) : null,
      child: SwitchListTile(
        title: 'Emergency Message'.at(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isEmergency ? Colors.red : null,
          ),
        ),
        subtitle: 'Mark this message as urgent/emergency'.at(
          style: TextStyle(
            color: _isEmergency ? Colors.red[700] : Colors.grey,
          ),
        ),
        value: _isEmergency,
        onChanged: (value) {
          setState(() {
            _isEmergency = value;
            if (value) {
              _selectedPriority = MessagePriority.urgent;
            }
          });
        },
        activeColor: Colors.red,
        secondary: Icon(
          Icons.warning,
          color: _isEmergency ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 8,
      decoration: InputDecoration(
        labelText: 'Message *',
        hintText: 'Type your message here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a message';
        }
        return null;
      },
    );
  }

  Widget _buildAttachmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Attachments'.at(
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAttachmentButton(
                  Icons.photo,
                  'Photo',
                  () => _attachFile('photo'),
                ),
                const SizedBox(width: 12),
                _buildAttachmentButton(
                  Icons.videocam,
                  'Video',
                  () => _attachFile('video'),
                ),
                const SizedBox(width: 12),
                _buildAttachmentButton(
                  Icons.insert_drive_file,
                  'Document',
                  () => _attachFile('document'),
                ),
                const SizedBox(width: 12),
                _buildAttachmentButton(
                  Icons.location_on,
                  'Location',
                  () => _attachFile('location'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.communityTeal),
              const SizedBox(height: 4),
              label.at(
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return const Icon(Icons.text_fields, size: 16);
      case MessageType.voice:
        return const Icon(Icons.mic, size: 16);
      case MessageType.image:
        return const Icon(Icons.image, size: 16);
      case MessageType.audio:
        return const Icon(Icons.audiotrack, size: 16);
      case MessageType.video:
        return const Icon(Icons.videocam, size: 16);
      case MessageType.document:
        return const Icon(Icons.description, size: 16);
      case MessageType.location:
        return const Icon(Icons.location_on, size: 16);
    }
  }

  Widget _getPriorityIcon(MessagePriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case MessagePriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
      case MessagePriority.normal:
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case MessagePriority.high:
        color = Colors.orange;
        icon = Icons.arrow_upward;
        break;
      case MessagePriority.urgent:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
    }

    return Icon(icon, color: color, size: 16);
  }

  void _attachFile(String type) {
    // TODO: Implement file attachment based on type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: '$type attachment coming soon!'.at(),
      ),
    );
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      // Parse recipient ID (simplified)
      final recipientId = int.tryParse(_recipientController.text.trim()) ?? 2;

      final message = Message(
        createdAt: DateTime.now(),
        content: _messageController.text.trim(),
        conversationId: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        isEmergency: _isEmergency,
        isRead: false,
        messageType: _selectedType,
        priority: _selectedPriority,
        receiverId: recipientId,
        senderId: 1, // TODO: Get from auth provider
        metadata: _subjectController.text.trim().isEmpty 
            ? null 
            : '{"subject": "${_subjectController.text.trim()}"}',
      );

      ref.read(messagesProvider.notifier).sendMessage(message);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: 'Message sent successfully!'.at(),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
