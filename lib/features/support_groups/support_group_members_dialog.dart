import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class SupportGroupMembersDialog extends StatefulWidget {
  final Map<String, dynamic> group;

  const SupportGroupMembersDialog({
    super.key,
    required this.group,
  });

  @override
  State<SupportGroupMembersDialog> createState() => _SupportGroupMembersDialogState();
}

class _SupportGroupMembersDialogState extends State<SupportGroupMembersDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _availableClients = [];
  bool _isLoadingMembers = true;
  bool _isLoadingClients = true;
  bool _isAddingMember = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMembers();
    _loadAvailableClients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      setState(() => _isLoadingMembers = true);
      final response = await ApiService.instance.getSupportGroupMembers(
        widget.group['id'],
      );
      
      if (response.success && response.data != null) {
        setState(() {
          _members = List<Map<String, dynamic>>.from(
            response.data['members'] ?? response.data ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading members: $e');
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _loadAvailableClients() async {
    try {
      setState(() => _isLoadingClients = true);
      // Get health worker ID from current user context (you may need to adjust this)
      final response = await ApiService.instance.getAssignedClients(2); // TODO: Get actual health worker ID
      
      if (response.success && response.data != null) {
        final clients = List<Map<String, dynamic>>.from(
          response.data['clients'] ?? response.data ?? [],
        );
        
        // Filter out clients who are already members
        final memberUserIds = _members.map((m) => m['userId'] ?? m['user']?['id']).toSet();
        
        setState(() {
          _availableClients = clients.where((client) {
            final clientId = client['id'];
            return !memberUserIds.contains(clientId);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading clients: $e');
    } finally {
      setState(() => _isLoadingClients = false);
    }
  }

  Future<void> _addMember(Map<String, dynamic> client) async {
    try {
      setState(() => _isAddingMember = true);
      final response = await ApiService.instance.addSupportGroupMember(
        widget.group['id'],
        client['id'],
      );
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${client['name']} added to group successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadMembers();
        await _loadAvailableClients();
      } else {
        throw Exception(response.message ?? 'Failed to add member');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isAddingMember = false);
    }
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: 'Remove Member'.at(),
        content: Text(
          'Are you sure you want to remove ${member['user']?['name'] ?? member['name'] ?? 'this member'} from the group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: 'Cancel'.at(),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: 'Remove'.at(),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = member['userId'] ?? member['user']?['id'];
        final response = await ApiService.instance.removeSupportGroupMember(
          widget.group['id'],
          userId,
        );
        
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Member removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadMembers();
          await _loadAvailableClients();
        } else {
          throw Exception(response.message ?? 'Failed to remove member');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.supportPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.group, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group['name'] ?? 'Support Group',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Manage Members',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              color: Colors.grey[100],
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.supportPurple,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColors.supportPurple,
                tabs: [
                  Tab(text: 'Members (${_members.length})'),
                  Tab(text: 'Add Members'),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersTab(),
                  _buildAddMembersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_isLoadingMembers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add members to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildAddMembersTab() {
    if (_isLoadingClients) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No available clients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your clients are already members',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableClients.length,
      itemBuilder: (context, index) {
        final client = _availableClients[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final user = member['user'] ?? member;
    final name = user['name'] ?? 'Unknown Member';
    final role = member['role'] ?? 'MEMBER';
    final joinedAt = member['joinedAt'];
    final isActive = member['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.supportPurple.withOpacity(0.1),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.supportPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role.toLowerCase().replaceAll('_', ' ').toUpperCase()),
            if (joinedAt != null)
              Text(
                'Joined: ${DateTime.tryParse(joinedAt)?.toString().split(' ')[0] ?? joinedAt}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (role != 'ADMIN') // Don't allow removing admins
              IconButton(
                onPressed: () => _removeMember(member),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                tooltip: 'Remove member',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final name = client['name'] ?? 'Unknown Client';
    final email = client['email'];
    final phone = client['phone'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email != null) Text(email),
            if (phone != null) Text(phone),
          ],
        ),
        trailing: _isAddingMember
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                onPressed: () => _addMember(client),
                icon: const Icon(Icons.add_circle, color: Colors.green),
                tooltip: 'Add to group',
              ),
      ),
    );
  }
}
