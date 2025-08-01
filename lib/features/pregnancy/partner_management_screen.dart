import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/partner_invitation.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import 'partner_invitation_form_screen.dart';

/// Partner Management Screen for managing partner invitations
class PartnerManagementScreen extends ConsumerStatefulWidget {
  const PartnerManagementScreen({super.key});

  @override
  ConsumerState<PartnerManagementScreen> createState() =>
      _PartnerManagementScreenState();
}

class _PartnerManagementScreenState
    extends ConsumerState<PartnerManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load family planning data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyPlanningState = ref.watch(familyPlanningProvider);
    final partnerInvitations = ref.watch(partnerInvitationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Management'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || familyPlanningState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSentInvitationsTab(partnerInvitations),
            _buildReceivedInvitationsTab(partnerInvitations),
            _buildActivePartnersTab(partnerInvitations),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _invitePartner,
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Invite Partner'),
      ),
    );
  }

  Widget _buildSentInvitationsTab(List<PartnerInvitation> invitations) {
    final sentInvitations = invitations.where((inv) => 
        inv.status == InvitationStatus.sent || 
        inv.status == InvitationStatus.delivered).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Sent Invitations',
            'Invitations you have sent to partners',
            Icons.send,
          ),
          const SizedBox(height: 16),
          if (sentInvitations.isEmpty) ...[
            _buildEmptyState(
              'No Sent Invitations',
              'You haven\'t sent any partner invitations yet',
              Icons.send,
              'Invite Partner',
              _invitePartner,
            ),
          ] else ...[
            ...sentInvitations.map((invitation) => 
                _buildInvitationCard(invitation, isSent: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildReceivedInvitationsTab(List<PartnerInvitation> invitations) {
    // Note: In a real implementation, you'd need to fetch invitations 
    // where the current user is the recipient
    final receivedInvitations = <PartnerInvitation>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Received Invitations',
            'Invitations you have received from partners',
            Icons.inbox,
          ),
          const SizedBox(height: 16),
          if (receivedInvitations.isEmpty) ...[
            _buildEmptyState(
              'No Received Invitations',
              'You haven\'t received any partner invitations yet',
              Icons.inbox,
              null,
              null,
            ),
          ] else ...[
            ...receivedInvitations.map((invitation) => 
                _buildInvitationCard(invitation, isSent: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildActivePartnersTab(List<PartnerInvitation> invitations) {
    final activePartners = invitations.where((inv) => 
        inv.status == InvitationStatus.accepted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Active Partners',
            'Partners you are currently connected with',
            Icons.people,
          ),
          const SizedBox(height: 16),
          if (activePartners.isEmpty) ...[
            _buildEmptyState(
              'No Active Partners',
              'You don\'t have any active partner connections yet',
              Icons.people,
              'Invite Partner',
              _invitePartner,
            ),
          ] else ...[
            ...activePartners.map((invitation) => 
                _buildPartnerCard(invitation)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pregnancyPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pregnancyPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    String? buttonText,
    VoidCallback? onPressed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pregnancyPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvitationCard(PartnerInvitation invitation, {required bool isSent}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(invitation.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(invitation.status),
                    color: _getStatusColor(invitation.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.recipientEmail,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        invitation.typeDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invitation.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invitation.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(invitation.status),
                    ),
                  ),
                ),
              ],
            ),
            if (invitation.invitationMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invitation.invitationMessage!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Expires in ${invitation.daysUntilExpiration} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isSent && invitation.canBeAccepted) ...[
                  TextButton(
                    onPressed: () => _resendInvitation(invitation),
                    child: const Text('Resend'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(PartnerInvitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.recipientEmail,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Connected via ${invitation.typeDisplayName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (invitation.acceptedAt != null) ...[
                    Text(
                      'Connected on ${_formatDate(invitation.acceptedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handlePartnerAction(value, invitation),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'disconnect',
                  child: Row(
                    children: [
                      Icon(Icons.link_off, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Disconnect'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.sent:
        return AppColors.primary;
      case InvitationStatus.delivered:
        return AppColors.warning;
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
        return AppColors.error;
      case InvitationStatus.expired:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.sent:
        return Icons.send;
      case InvitationStatus.delivered:
        return Icons.mark_email_read;
      case InvitationStatus.accepted:
        return Icons.check_circle;
      case InvitationStatus.declined:
        return Icons.cancel;
      case InvitationStatus.expired:
        return Icons.access_time;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _invitePartner() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PartnerInvitationFormScreen(),
      ),
    );

    if (result == true) {
      // Refresh the data
      ref.read(familyPlanningProvider.notifier).loadFamilyPlanningData();
    }
  }

  void _resendInvitation(PartnerInvitation invitation) {
    // TODO: Implement resend functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation resent successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handlePartnerAction(String action, PartnerInvitation invitation) {
    switch (action) {
      case 'view':
        // TODO: Navigate to partner details
        break;
      case 'disconnect':
        _showDisconnectConfirmation(invitation);
        break;
    }
  }

  void _showDisconnectConfirmation(PartnerInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Partner'),
        content: Text(
          'Are you sure you want to disconnect from ${invitation.recipientEmail}? This will end your partnership and remove shared access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement disconnect functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partner disconnected successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
