import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/support_group.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class SupportGroupDetailScreen extends ConsumerStatefulWidget {
  final SupportGroup group;

  const SupportGroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  ConsumerState<SupportGroupDetailScreen> createState() => _SupportGroupDetailScreenState();
}

class _SupportGroupDetailScreenState extends ConsumerState<SupportGroupDetailScreen> {
  List<SupportGroupMember> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    if (widget.group.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final members = await ref.read(communityServiceProvider).getGroupMembers(widget.group.id!);
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.group.name.at(),
        backgroundColor: AppColors.communityTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shareGroup,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(),
            const SizedBox(height: 24),
            _buildGroupInfo(),
            const SizedBox(height: 24),
            _buildMembersSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: widget.group.name.at(
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.group.isPrivate)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: 'Private'.at(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.communityTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.group.category.at(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.communityTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.group.description != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.group.description!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Group Information'.at(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.people, 'Members', '${widget.group.memberCount}'),
            if (widget.group.maxMembers != null)
              _buildInfoRow(Icons.group_add, 'Max Members', '${widget.group.maxMembers}'),
            if (widget.group.meetingLocation != null)
              _buildInfoRow(Icons.location_on, 'Location', widget.group.meetingLocation!),
            if (widget.group.meetingSchedule != null)
              _buildInfoRow(Icons.schedule, 'Schedule', widget.group.meetingSchedule!),
            if (widget.group.contactInfo != null)
              _buildInfoRow(Icons.contact_mail, 'Contact', widget.group.contactInfo!),
            _buildInfoRow(
              Icons.visibility,
              'Privacy',
              widget.group.isPrivate ? 'Private' : 'Public',
            ),
            _buildInfoRow(
              Icons.circle,
              'Status',
              widget.group.isActive ? 'Active' : 'Inactive',
            ),
            if (widget.group.tags != null && widget.group.tags!.isNotEmpty) ...[
              const SizedBox(height: 16),
              'Tags'.at(style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.group.tags!.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: AppColors.communityTeal.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
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

  Widget _buildMembersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                'Members'.at(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_members.isEmpty && !_isLoading)
              Center(
                child: 'No members to display'.at(
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.communityTeal,
                      child: Text(
                        member.userId.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: 'Member ${member.userId}'.at(),
                    subtitle: member.roleDisplayName.at(),
                    trailing: member.isActive
                        ? const Icon(Icons.circle, color: Colors.green, size: 12)
                        : const Icon(Icons.circle, color: Colors.grey, size: 12),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.group.isFull ? null : _joinGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.communityTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.group.isFull ? 'Group is Full'.at() : 'Join Group'.at(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _reportGroup,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: 'Report Group'.at(),
          ),
        ),
      ],
    );
  }

  void _joinGroup() {
    if (widget.group.id != null) {
      ref.read(supportGroupsProvider.notifier).joinGroup(widget.group.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: 'Joined ${widget.group.name} successfully!'.at(),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareGroup() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: 'Share functionality coming soon!'.at(),
      ),
    );
  }

  void _reportGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: 'Report Group'.at(),
        content: 'Are you sure you want to report this group for inappropriate content?'.at(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: 'Cancel'.at(),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: 'Group reported. Thank you for your feedback.'.at(),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: 'Report'.at(),
          ),
        ],
      ),
    );
  }
}
