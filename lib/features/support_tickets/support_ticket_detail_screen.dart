import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/support_ticket.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class SupportTicketDetailScreen extends ConsumerWidget {
  final SupportTicket ticket;

  const SupportTicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: 'Ticket #${ticket.id ?? 'New'}'.at(),
        backgroundColor: AppColors.communityTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _shareTicket(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketHeader(),
            const SizedBox(height: 24),
            _buildTicketDetails(),
            const SizedBox(height: 24),
            _buildContactInfo(),
            const SizedBox(height: 24),
            if (ticket.resolutionNotes != null) _buildResolutionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ticket.subject.at(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(ticket.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPriorityChip(ticket.priority),
                const SizedBox(width: 8),
                _buildTypeChip(ticket.ticketType),
                const Spacer(),
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Description'.at(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ticket.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Created', _formatDate(ticket.createdAt)),
            if (ticket.updatedAt != null)
              _buildInfoRow(Icons.update, 'Last Updated', _formatDate(ticket.updatedAt!)),
            if (ticket.resolvedAt != null)
              _buildInfoRow(Icons.check_circle, 'Resolved', _formatDate(ticket.resolvedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    if (ticket.userEmail == null && ticket.userPhone == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Contact Information'.at(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (ticket.userEmail != null)
              _buildInfoRow(Icons.email, 'Email', ticket.userEmail!),
            if (ticket.userPhone != null)
              _buildInfoRow(Icons.phone, 'Phone', ticket.userPhone!),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                'Resolution'.at(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.resolutionNotes!,
              style: const TextStyle(fontSize: 16),
            ),
            if (ticket.resolvedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Resolved on ${_formatDate(ticket.resolvedAt!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          label.at(
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TicketStatus? status) {
    if (status == null) return const SizedBox.shrink();

    Color color;
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: status.name.toUpperCase().at(
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TicketPriority? priority) {
    if (priority == null) return const SizedBox.shrink();

    Color color;
    IconData icon;
    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
      case TicketPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case TicketPriority.high:
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case TicketPriority.urgent:
        color = Colors.purple;
        icon = Icons.priority_high;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          priority.name.toUpperCase().at(
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(TicketType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.communityTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: type.name.toUpperCase().at(
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.communityTeal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareTicket(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: 'Share functionality coming soon!'.at(),
      ),
    );
  }
}
