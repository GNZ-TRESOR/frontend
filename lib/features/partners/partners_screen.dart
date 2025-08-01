import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/partner.dart';
import '../../core/widgets/loading_overlay.dart';

/// Professional Partners Management Screen
class PartnersScreen extends ConsumerStatefulWidget {
  const PartnersScreen({super.key});

  @override
  ConsumerState<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends ConsumerState<PartnersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partners'),
        backgroundColor: AppColors.supportPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'My Partner'),
            Tab(text: 'Invitations'),
            Tab(text: 'Decisions'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMyPartnerTab(),
            _buildInvitationsTab(),
            _buildDecisionsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInvitePartnerDialog,
        backgroundColor: AppColors.supportPurple,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildMyPartnerTab() {
    // Mock data - check if user has a partner
    final hasPartner = true; // This would come from API

    if (!hasPartner) {
      return _buildNoPartnerState();
    }

    final partner = _getMockPartner();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPartnerCard(partner),
          const SizedBox(height: 16),
          _buildPartnerStats(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildRecentDecisions(),
        ],
      ),
    );
  }

  Widget _buildNoPartnerState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.supportPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people, size: 60, color: AppColors.supportPurple),
          ),
          const SizedBox(height: 24),
          Text(
            'No Partner Connected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Invite your partner to make family planning decisions together',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showInvitePartnerDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.supportPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Invite Partner'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(Partner partner) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.supportPurple.withOpacity(0.1),
                  child:
                      partner.profileImageUrl != null
                          ? ClipOval(
                            child: Image.network(
                              partner.profileImageUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Text(
                            partner.initials,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.supportPurple,
                            ),
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        partner.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Connected ${partner.timeSinceConnected}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _messagePartner(partner),
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _disconnectPartner(partner),
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partnership Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Decisions Made',
                    '12',
                    Icons.how_to_vote,
                  ),
                ),
                Expanded(
                  child: _buildStatItem('Agreements', '9', Icons.handshake),
                ),
                Expanded(child: _buildStatItem('Discussions', '3', Icons.chat)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.supportPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.supportPurple, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Make Decision',
                Icons.how_to_vote,
                AppColors.primary,
                () => _makeDecision(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Plan Together',
                Icons.calendar_month,
                AppColors.secondary,
                () => _planTogether(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDecisions() {
    final recentDecisions = _getMockDecisions().take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Decisions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...recentDecisions
            .map((decision) => _buildDecisionCard(decision, isCompact: true))
            .toList(),
      ],
    );
  }

  Widget _buildInvitationsTab() {
    final invitations = _getMockInvitations();

    if (invitations.isEmpty) {
      return _buildEmptyState(
        'No invitations',
        'Partner invitations will appear here',
        Icons.mail_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh from API
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final invitation = invitations[index];
          return _buildInvitationCard(invitation);
        },
      ),
    );
  }

  Widget _buildInvitationCard(PartnerInvitation invitation) {
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getInvitationStatusColor(
                      invitation.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getInvitationIcon(invitation.status),
                    color: _getInvitationStatusColor(invitation.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.inviteeName ?? invitation.inviteeEmail,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sent ${invitation.timeSinceSent}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getInvitationStatusColor(
                      invitation.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invitation.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getInvitationStatusColor(invitation.status),
                    ),
                  ),
                ),
              ],
            ),
            if (invitation.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _resendInvitation(invitation),
                      child: const Text('Resend'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelInvitation(invitation),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionsTab() {
    final decisions = _getMockDecisions();

    if (decisions.isEmpty) {
      return _buildEmptyState(
        'No decisions made',
        'Partner decisions will appear here',
        Icons.how_to_vote,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh from API
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: decisions.length,
        itemBuilder: (context, index) {
          final decision = decisions[index];
          return _buildDecisionCard(decision);
        },
      ),
    );
  }

  Widget _buildDecisionCard(
    PartnerDecision decision, {
    bool isCompact = false,
  }) {
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
                    color: _getDecisionColor(
                      decision.decision,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDecisionIcon(decision.decision),
                    color: _getDecisionColor(decision.decision),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        decision.decisionTypeDisplayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        decision.timeSinceDecided,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDecisionColor(
                      decision.decision,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    decision.decisionDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getDecisionColor(decision.decision),
                    ),
                  ),
                ),
              ],
            ),
            if (!isCompact && decision.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  decision.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getInvitationStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'ACCEPTED':
        return AppColors.success;
      case 'DECLINED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getInvitationIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'DECLINED':
        return Icons.cancel;
      default:
        return Icons.mail;
    }
  }

  Color _getDecisionColor(String decision) {
    switch (decision.toLowerCase()) {
      case 'agreed':
        return AppColors.success;
      case 'disagreed':
        return AppColors.error;
      case 'needs_discussion':
        return AppColors.warning;
      case 'postponed':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getDecisionIcon(String decision) {
    switch (decision.toLowerCase()) {
      case 'agreed':
        return Icons.thumb_up;
      case 'disagreed':
        return Icons.thumb_down;
      case 'needs_discussion':
        return Icons.chat;
      case 'postponed':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  // Mock data methods
  Partner _getMockPartner() {
    return Partner(
      id: 1,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+250 788 123 456',
      relationshipStatus: 'CONNECTED',
      connectedAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  List<PartnerInvitation> _getMockInvitations() {
    return [
      PartnerInvitation(
        id: 1,
        inviterId: 1,
        inviterName: 'Current User',
        inviteeEmail: 'partner@example.com',
        inviteeName: 'Jane Smith',
        status: 'PENDING',
        message: 'Let\'s plan our family together!',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PartnerInvitation(
        id: 2,
        inviterId: 1,
        inviterName: 'Current User',
        inviteeEmail: 'old.partner@example.com',
        status: 'DECLINED',
        sentAt: DateTime.now().subtract(const Duration(days: 5)),
        respondedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  List<PartnerDecision> _getMockDecisions() {
    return [
      PartnerDecision(
        id: 1,
        userId: 1,
        partnerId: 2,
        partnerName: 'John Doe',
        decisionType: 'contraception',
        decision: 'agreed',
        notes: 'We both agree on using IUD for long-term contraception',
        decidedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PartnerDecision(
        id: 2,
        userId: 1,
        partnerId: 2,
        partnerName: 'John Doe',
        decisionType: 'pregnancy_planning',
        decision: 'needs_discussion',
        notes: 'Need to discuss timing for having children',
        decidedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  // Action methods
  void _showInvitePartnerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Invite Partner'),
            content: const Text(
              'Enter your partner\'s email to send an invitation',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendInvitation();
                },
                child: const Text('Send Invitation'),
              ),
            ],
          ),
    );
  }

  void _sendInvitation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partner invitation sent successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _messagePartner(Partner partner) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with ${partner.displayName}')),
    );
  }

  void _disconnectPartner(Partner partner) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Disconnect Partner'),
            content: Text(
              'Are you sure you want to disconnect from ${partner.displayName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partner disconnected')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Disconnect'),
              ),
            ],
          ),
    );
  }

  void _makeDecision() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Make decision feature coming soon')),
    );
  }

  void _planTogether() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan together feature coming soon')),
    );
  }

  void _resendInvitation(PartnerInvitation invitation) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invitation resent successfully')),
    );
  }

  void _cancelInvitation(PartnerInvitation invitation) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invitation cancelled')));
  }
}
