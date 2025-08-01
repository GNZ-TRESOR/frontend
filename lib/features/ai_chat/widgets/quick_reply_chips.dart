import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Quick reply chips widget
class QuickReplyChips extends StatelessWidget {
  final Function(String) onQuickReply;
  final List<String> quickReplies;

  const QuickReplyChips({
    super.key,
    required this.onQuickReply,
    required this.quickReplies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick questions:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickReplies.map((reply) {
              return _QuickReplyChip(
                text: reply,
                onTap: () => onQuickReply(reply),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickReplyChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
