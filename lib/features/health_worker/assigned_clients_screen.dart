import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';

/// Health Worker Assigned Clients Screen
class AssignedClientsScreen extends ConsumerStatefulWidget {
  const AssignedClientsScreen({super.key});

  @override
  ConsumerState<AssignedClientsScreen> createState() =>
      _AssignedClientsScreenState();
}

class _AssignedClientsScreenState extends ConsumerState<AssignedClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _clients = [];
  List<User> _filteredClients = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAssignedClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedClients() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getAssignedClients(user!.id!);

      if (response.success && response.data != null) {
        final clientsData = response.data['clients'] as List<dynamic>? ?? [];
        _clients =
            clientsData
                .map((json) => User.fromJson(json as Map<String, dynamic>))
                .toList();
        _filterClients();
      } else {
        _error = response.message ?? 'Failed to load assigned clients';
      }
    } catch (e) {
      _error = 'Error loading clients: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterClients() {
    String query = _searchController.text.toLowerCase();

    _filteredClients =
        _clients.where((client) {
          final matchesSearch =
              client.name.toLowerCase().contains(query) ||
              client.email.toLowerCase().contains(query);

          // Add filter logic based on client status, health conditions, etc.
          bool matchesFilter = true;
          switch (_selectedFilter) {
            case 'Active':
              matchesFilter = client.isActive;
              break;
            case 'Inactive':
              matchesFilter = !client.isActive;
              break;
            case 'All':
            default:
              matchesFilter = true;
          }

          return matchesSearch && matchesFilter;
        }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Clients'),
        backgroundColor: AppColors.healthWorkerBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignedClients,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildClientStats(),
            Expanded(
              child: _error != null ? _buildErrorState() : _buildClientsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search clients...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.healthWorkerBlue),
              ),
            ),
            onChanged: (_) => _filterClients(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  items:
                      ['All', 'Active', 'Inactive', 'High Priority', 'Recent']
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    _filterClients();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientStats() {
    final totalClients = _clients.length;
    final activeClients = _clients.where((c) => c.isActive).length;
    final inactiveClients = totalClients - activeClients;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          _buildStatCard('Total', totalClients, AppColors.primary),
          _buildStatCard('Active', activeClients, AppColors.success),
          _buildStatCard('Inactive', inactiveClients, AppColors.warning),
          _buildStatCard(
            'High Priority',
            0,
            AppColors.error,
          ), // TODO: Add priority logic
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    if (_filteredClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No clients found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Clients assigned to you will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignedClients,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredClients.length,
        itemBuilder: (context, index) {
          final client = _filteredClients[index];
          return _buildClientCard(client);
        },
      ),
    );
  }

  Widget _buildClientCard(User client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.healthWorkerBlue,
          child: Text(
            client.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        client.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    client.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          client.isActive
                              ? AppColors.success
                              : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Last visit: ${_getLastVisitText(client)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleClientAction(client, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Profile')),
                const PopupMenuItem(
                  value: 'health_records',
                  child: Text('Health Records'),
                ),
                const PopupMenuItem(
                  value: 'appointments',
                  child: Text('Appointments'),
                ),
                const PopupMenuItem(value: 'call', child: Text('Call Client')),
                const PopupMenuItem(
                  value: 'message',
                  child: Text('Send Message'),
                ),
              ],
        ),
        onTap: () => _viewClientDetails(client),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading clients',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAssignedClients,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.healthWorkerBlue,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getLastVisitText(User client) {
    // TODO: Get actual last visit date from API
    return 'N/A';
  }

  void _handleClientAction(User client, String action) {
    switch (action) {
      case 'view':
        _viewClientDetails(client);
        break;
      case 'health_records':
        _viewHealthRecords(client);
        break;
      case 'appointments':
        _viewAppointments(client);
        break;
      case 'call':
        _callClient(client);
        break;
      case 'message':
        _messageClient(client);
        break;
    }
  }

  void _viewClientDetails(User client) {
    // TODO: Navigate to client details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for ${client.name} - Coming Soon')),
    );
  }

  void _viewHealthRecords(User client) {
    // Navigate to health records screen with client filter
    Navigator.pushNamed(
      context,
      '/health-records',
      arguments: {'clientId': client.id, 'clientName': client.name},
    );
  }

  void _viewAppointments(User client) {
    // Navigate to appointments screen with client filter
    Navigator.pushNamed(
      context,
      '/appointments',
      arguments: {'clientId': client.id, 'clientName': client.name},
    );
  }

  void _callClient(User client) {
    // Show call options dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Call ${client.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (client.phoneNumber?.isNotEmpty == true) ...[
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.success),
                    title: Text(client.phoneNumber!),
                    subtitle: const Text('Primary phone'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _makePhoneCall(client.phoneNumber!);
                    },
                  ),
                ] else ...[
                  const ListTile(
                    leading: Icon(Icons.phone_disabled, color: Colors.grey),
                    title: Text('No phone number available'),
                    subtitle: Text('Contact information not provided'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // In a real app, this would use url_launcher to make a call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _messageClient(User client) {
    // Navigate to messaging screen with client conversation
    Navigator.pushNamed(
      context,
      '/messaging',
      arguments: {'recipientId': client.id, 'recipientName': client.name},
    );
  }
}
