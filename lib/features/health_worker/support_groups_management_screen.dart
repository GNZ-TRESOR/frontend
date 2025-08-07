import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class SupportGroupsManagementScreen extends ConsumerStatefulWidget {
  const SupportGroupsManagementScreen({super.key});

  @override
  ConsumerState<SupportGroupsManagementScreen> createState() =>
      _SupportGroupsManagementScreenState();
}

class _SupportGroupsManagementScreenState
    extends ConsumerState<SupportGroupsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Support groups data
  List<Map<String, dynamic>> _supportGroups = [];
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _myGroups = [];

  // Form controllers
  final _groupNameController = TextEditingController();
  final _groupDescriptionController = TextEditingController();
  final _ticketTitleController = TextEditingController();
  final _ticketDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    _ticketTitleController.dispose();
    _ticketDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadSupportGroups(),
        _loadTickets(),
        _loadMyGroups(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSupportGroups() async {
    try {
      final response = await ApiService.instance.dio.get('/support-groups');
      if (response.statusCode == 200) {
        setState(() {
          _supportGroups = List<Map<String, dynamic>>.from(
            response.data['supportGroups'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading support groups: $e');
    }
  }

  Future<void> _loadTickets() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/tickets',
      );
      if (response.statusCode == 200) {
        setState(() {
          _tickets = List<Map<String, dynamic>>.from(
            response.data['tickets'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading tickets: $e');
    }
  }

  Future<void> _loadMyGroups() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/support-groups',
      );
      if (response.statusCode == 200) {
        setState(() {
          _myGroups = List<Map<String, dynamic>>.from(
            response.data['supportGroups'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading my groups: $e');
    }
  }

  void _loadMockData() {
    // Mock data for development
    setState(() {
      _supportGroups = [
        {
          'id': 1,
          'name': 'Family Planning Support',
          'description':
              'Support group for family planning education and guidance',
          'memberCount': 15,
          'createdAt': '2025-07-15T10:00:00Z',
          'status': 'ACTIVE',
          'facilitator': 'Dr. Marie Uwimana',
        },
        {
          'id': 2,
          'name': 'Maternal Health Circle',
          'description': 'Support for expectant and new mothers',
          'memberCount': 8,
          'createdAt': '2025-07-20T14:30:00Z',
          'status': 'ACTIVE',
          'facilitator': 'Dr. Marie Uwimana',
        },
      ];

      _tickets = [
        {
          'id': 1,
          'title': 'Request for contraception consultation',
          'description': 'Client needs guidance on contraception options',
          'status': 'OPEN',
          'priority': 'HIGH',
          'clientName': 'Grace Mukamana',
          'createdAt': '2025-08-05T09:00:00Z',
          'category': 'CONSULTATION',
        },
        {
          'id': 2,
          'title': 'Follow-up appointment needed',
          'description': 'Client missed last appointment, needs rescheduling',
          'status': 'IN_PROGRESS',
          'priority': 'MEDIUM',
          'clientName': 'Grace Mukamana',
          'createdAt': '2025-08-04T15:30:00Z',
          'category': 'APPOINTMENT',
        },
      ];

      _myGroups = _supportGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Groups & Tickets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'create_group',
                    child: Row(
                      children: [
                        Icon(Icons.group_add),
                        SizedBox(width: 8),
                        Text('Create Group'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'create_ticket',
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number),
                        SizedBox(width: 8),
                        Text('Create Ticket'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Groups'),
            Tab(text: 'My Groups'),
            Tab(text: 'Tickets'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllGroupsTab(),
            _buildMyGroupsTab(),
            _buildTicketsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllGroupsTab() {
    return RefreshIndicator(
      onRefresh: _loadSupportGroups,
      child:
          _supportGroups.isEmpty
              ? _buildEmptyState(
                'No support groups found',
                'Create your first support group to get started',
                Icons.group,
                () => _showCreateGroupDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _supportGroups.length,
                itemBuilder: (context, index) {
                  final group = _supportGroups[index];
                  return _buildSupportGroupCard(group);
                },
              ),
    );
  }

  Widget _buildMyGroupsTab() {
    return RefreshIndicator(
      onRefresh: _loadMyGroups,
      child:
          _myGroups.isEmpty
              ? _buildEmptyState(
                'No groups managed',
                'You are not facilitating any support groups yet',
                Icons.group_work,
                () => _showCreateGroupDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myGroups.length,
                itemBuilder: (context, index) {
                  final group = _myGroups[index];
                  return _buildSupportGroupCard(group, isManaged: true);
                },
              ),
    );
  }

  Widget _buildTicketsTab() {
    return RefreshIndicator(
      onRefresh: _loadTickets,
      child:
          _tickets.isEmpty
              ? _buildEmptyState(
                'No tickets found',
                'No support tickets have been created yet',
                Icons.confirmation_number,
                () => _showCreateTicketDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  final ticket = _tickets[index];
                  return _buildTicketCard(ticket);
                },
              ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAction,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: const Text('Get Started'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGroupCard(
    Map<String, dynamic> group, {
    bool isManaged = false,
  }) {
    final memberCount = group['memberCount'] ?? 0;
    final status = group['status'] ?? 'ACTIVE';
    final createdAt = group['createdAt'];

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.group, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group['name'] ?? 'Unknown Group',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        group['facilitator'] ?? 'Unknown Facilitator',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isManaged)
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleGroupAction(value, group),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'view_members',
                            child: Row(
                              children: [
                                Icon(Icons.people),
                                SizedBox(width: 8),
                                Text('View Members'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit Group'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive),
                                SizedBox(width: 8),
                                Text('Archive'),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              group['description'] ?? 'No description available',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  '$memberCount members',
                  Icons.people,
                  AppColors.info,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  status,
                  Icons.circle,
                  status == 'ACTIVE' ? AppColors.success : Colors.grey,
                ),
                const SizedBox(width: 8),
                if (createdAt != null)
                  _buildInfoChip(
                    _formatDate(createdAt),
                    Icons.calendar_today,
                    Colors.grey,
                  ),
              ],
            ),
            if (!isManaged) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _joinGroup(group),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join Group'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewGroupDetails(group),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'OPEN';
    final priority = ticket['priority'] ?? 'MEDIUM';
    final createdAt = ticket['createdAt'];

    Color statusColor = AppColors.warning;
    Color priorityColor = AppColors.info;

    switch (status) {
      case 'OPEN':
        statusColor = AppColors.warning;
        break;
      case 'IN_PROGRESS':
        statusColor = AppColors.info;
        break;
      case 'RESOLVED':
        statusColor = AppColors.success;
        break;
      case 'CLOSED':
        statusColor = Colors.grey;
        break;
    }

    switch (priority) {
      case 'LOW':
        priorityColor = AppColors.success;
        break;
      case 'MEDIUM':
        priorityColor = AppColors.warning;
        break;
      case 'HIGH':
        priorityColor = AppColors.error;
        break;
    }

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.confirmation_number,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['title'] ?? 'Unknown Ticket',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (ticket['clientName'] != null)
                        Text(
                          'Client: ${ticket['clientName']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleTicketAction(value, ticket),
                  itemBuilder:
                      (context) => [
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
                          value: 'update_status',
                          child: Row(
                            children: [
                              Icon(Icons.update),
                              SizedBox(width: 8),
                              Text('Update Status'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'assign',
                          child: Row(
                            children: [
                              Icon(Icons.person_add),
                              SizedBox(width: 8),
                              Text('Assign'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket['description'] ?? 'No description available',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(status, Icons.circle, statusColor),
                const SizedBox(width: 8),
                _buildInfoChip(priority, Icons.priority_high, priorityColor),
                const SizedBox(width: 8),
                _buildInfoChip(
                  ticket['category'] ?? 'GENERAL',
                  Icons.category,
                  Colors.grey,
                ),
                const SizedBox(width: 8),
                if (createdAt != null)
                  _buildInfoChip(
                    _formatDate(createdAt),
                    Icons.calendar_today,
                    Colors.grey,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
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
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Action handlers
  void _handleMenuAction(String action) {
    switch (action) {
      case 'create_group':
        _showCreateGroupDialog();
        break;
      case 'create_ticket':
        _showCreateTicketDialog();
        break;
    }
  }

  void _handleGroupAction(String action, Map<String, dynamic> group) {
    switch (action) {
      case 'view_members':
        _viewGroupMembers(group);
        break;
      case 'edit':
        _editGroup(group);
        break;
      case 'archive':
        _archiveGroup(group);
        break;
    }
  }

  void _handleTicketAction(String action, Map<String, dynamic> ticket) {
    switch (action) {
      case 'view':
        _viewTicketDetails(ticket);
        break;
      case 'update_status':
        _updateTicketStatus(ticket);
        break;
      case 'assign':
        _assignTicket(ticket);
        break;
    }
  }

  // Dialog methods
  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Support Group'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'Enter group name',
                      prefixIcon: Icon(Icons.group),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _groupDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter group description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _createSupportGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showCreateTicketDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Support Ticket'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _ticketTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket Title',
                      hintText: 'Enter ticket title',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ticketDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter ticket description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _createTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  // Action implementation methods
  void _createSupportGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      await ApiService.instance.dio.post(
        '/support-groups',
        data: {
          'name': _groupNameController.text,
          'description': _groupDescriptionController.text,
          'facilitatorId': user!.id,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support group created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearGroupControllers();
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create support group: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createTicket() async {
    if (_ticketTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a ticket title')),
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      await ApiService.instance.dio.post(
        '/tickets',
        data: {
          'title': _ticketTitleController.text,
          'description': _ticketDescriptionController.text,
          'createdBy': user!.id,
          'priority': 'MEDIUM',
          'category': 'GENERAL',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support ticket created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearTicketControllers();
      _loadTickets();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ticket: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _joinGroup(Map<String, dynamic> group) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Joining group: ${group['name']}')));
  }

  void _viewGroupDetails(Map<String, dynamic> group) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for: ${group['name']}')),
    );
  }

  void _viewGroupMembers(Map<String, dynamic> group) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing members of: ${group['name']}')),
    );
  }

  void _editGroup(Map<String, dynamic> group) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editing group: ${group['name']}')));
  }

  void _archiveGroup(Map<String, dynamic> group) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archiving group: ${group['name']}')),
    );
  }

  void _viewTicketDetails(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ticket: ${ticket['title']}')),
    );
  }

  void _updateTicketStatus(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating status for: ${ticket['title']}')),
    );
  }

  void _assignTicket(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigning ticket: ${ticket['title']}')),
    );
  }

  void _clearGroupControllers() {
    _groupNameController.clear();
    _groupDescriptionController.clear();
  }

  void _clearTicketControllers() {
    _ticketTitleController.clear();
    _ticketDescriptionController.clear();
  }
}
