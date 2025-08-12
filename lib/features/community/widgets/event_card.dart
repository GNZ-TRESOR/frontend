import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/community_event.dart';

class EventCard extends StatelessWidget {
  final CommunityEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final bool showManageOptions;
  final bool isPastEvent;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onJoin,
    this.onLeave,
    this.showManageOptions = false,
    this.isPastEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and type
              Row(
                children: [
                  _buildStatusChip(),
                  const Spacer(),
                  _buildEventTypeChip(),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title and description
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Event details
              _buildEventDetails(),
              const SizedBox(height: 16),
              
              // Action buttons
              if (!isPastEvent) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (event.status) {
      case 'upcoming':
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        statusText = 'Upcoming';
        break;
      case 'ongoing':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        statusText = 'Ongoing';
        break;
      case 'past':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        statusText = 'Past';
        break;
      default:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        statusText = 'Event';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEventTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        event.eventTypeDisplayName,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Column(
      children: [
        // Date and time
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatEventDateTime(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Location
        if (event.location != null)
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        
        if (event.location != null) const SizedBox(height: 8),
        
        // Participants
        Row(
          children: [
            Icon(
              Icons.people,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              _getParticipantsText(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (event.organizerName != null)
              Text(
                'by ${event.organizerName}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        
        // Category
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.category,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              event.categoryDisplayName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Join/Leave button
        if (event.hasAvailableSpots)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Join'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onLeave,
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('Leave'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        
        const SizedBox(width: 12),
        
        // Details button
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.info_outline, size: 16),
          label: const Text('Details'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Manage options for health workers
        if (showManageOptions) ...[
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle manage actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'participants',
                child: Row(
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 8),
                    Text('Participants'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancel Event', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  String _formatEventDateTime() {
    final formatter = DateFormat('MMM dd, yyyy • HH:mm');
    if (event.endDate != null) {
      final endFormatter = DateFormat('HH:mm');
      return '${formatter.format(event.eventDate)} - ${endFormatter.format(event.endDate!)}';
    }
    return formatter.format(event.eventDate);
  }

  String _getParticipantsText() {
    if (event.maxParticipants != null) {
      return '${event.currentParticipants}/${event.maxParticipants} participants';
    }
    return '${event.currentParticipants} participants';
  }
}
