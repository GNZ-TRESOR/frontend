import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/support_ticket.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';
import 'create_support_ticket_form.dart';
import 'support_ticket_detail_screen.dart';

class SupportTicketsTab extends ConsumerStatefulWidget {
  const SupportTicketsTab({super.key});

  @override
  ConsumerState<SupportTicketsTab> createState() => _SupportTicketsTabState();
}

class _SupportTicketsTabState extends ConsumerState<SupportTicketsTab> {
  TicketStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportTicketsProvider.notifier).loadSupportTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportTicketsState = ref.watch(supportTicketsProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child:
                supportTicketsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : supportTicketsState.error != null
                    ? _buildErrorWidget(supportTicketsState.error!)
                    : _buildTicketsList(supportTicketsState.tickets),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "create_support_ticket",
        onPressed: () => _showCreateTicketDialog(),
        backgroundColor: AppColors.communityTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      null, // All
      TicketStatus.open,
      TicketStatus.inProgress,
      TicketStatus.resolved,
      TicketStatus.closed,
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status;
          final label = status?.name.toUpperCase() ?? 'ALL';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: label.at(),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
                ref
                    .read(supportTicketsProvider.notifier)
                    .setSelectedStatus(_selectedStatus);
              },
              selectedColor: AppColors.communityTeal.withValues(alpha: 0.2),
              checkmarkColor: AppColors.communityTeal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          'Error loading support tickets'.at(
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(supportTicketsProvider.notifier)
                  .loadSupportTickets(status: _selectedStatus);
            },
            child: 'Retry'.at(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            'No support tickets found'.at(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            'Create a ticket if you need help!'.at(
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToTicketDetail(ticket),
        borderRadius: BorderRadius.circular(12),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPriorityChip(ticket.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.description,
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusChip(ticket.status),
                  const SizedBox(width: 8),
                  _buildTypeChip(ticket.ticketType),
                  const Spacer(),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TicketPriority? priority) {
    if (priority == null) return const SizedBox.shrink();

    Color color;
    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        break;
      case TicketPriority.medium:
        color = Colors.orange;
        break;
      case TicketPriority.high:
        color = Colors.red;
        break;
      case TicketPriority.urgent:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: priority.name.toUpperCase().at(
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToTicketDetail(SupportTicket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportTicketDetailScreen(ticket: ticket),
      ),
    );
  }

  void _showCreateTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateSupportTicketForm(),
    );
  }
}
