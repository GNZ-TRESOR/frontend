import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_record_model.dart';

class EnhancedChatScreen extends StatelessWidget {
  final HealthWorker contact;
  final String? conversationId;

  const EnhancedChatScreen({
    super.key,
    required this.contact,
    this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Enhanced Chat - Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
