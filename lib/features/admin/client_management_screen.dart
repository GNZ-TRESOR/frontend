import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';

/// Client Management Screen for Admins and Health Workers
class ClientManagementScreen extends ConsumerStatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  ConsumerState<ClientManagementScreen> createState() =>
      _ClientManagementScreenState();
}

class _ClientManagementScreenState
    extends ConsumerState<ClientManagementScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _filteredClients = [];

  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getAllUsers();

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final users = List<Map<String, dynamic>>.from(
          responseData['users'] ?? [],
        );
        // Filter only clients
        final clients =
            users
                .where(
                  (user) => user['role']?.toString().toLowerCase() == 'client',
                )
                .toList();

        setState(() {
          _clients = clients;
          _filteredClients = clients;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load clients';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading clients: $e';
        _isLoading = false;
      });
    }
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredClients =
          _clients.where((client) {
            final name = client['name']?.toString().toLowerCase() ?? '';
            final email = client['email']?.toString().toLowerCase() ?? '';
            final phone = client['phone']?.toString().toLowerCase() ?? '';

            final matchesSearch =
                query.isEmpty ||
                name.contains(query) ||
                email.contains(query) ||
                phone.contains(query);

            final matchesFilter =
                _selectedFilter == 'all' ||
                (_selectedFilter == 'active' && client['isActive'] == true) ||
                (_selectedFilter == 'inactive' && client['isActive'] == false);

            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  Future<void> _toggleClientStatus(Map<String, dynamic> client) async {
    final clientId = client['id'];
    final newStatus = !(client['isActive'] ?? true);

    try {
      final response = await ApiService.instance.updateUser(clientId, {
        'isActive': newStatus,
      });

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus
                    ? 'Client activated successfully'
                    : 'Client deactivated successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _loadClients();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Failed to update client status',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating client: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewClientDetails(Map<String, dynamic> client) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Client Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Name', client['name']),
                  _buildDetailRow('Email', client['email']),
                  _buildDetailRow('Phone', client['phone']),
                  _buildDetailRow('Gender', client['gender']),
                  _buildDetailRow('Date of Birth', client['dateOfBirth']),
                  _buildDetailRow('District', client['district']),
                  _buildDetailRow('Sector', client['sector']),
                  _buildDetailRow(
                    'Status',
                    client['isActive'] == true ? 'Active' : 'Inactive',
                  ),
                  _buildDetailRow('Created', client['createdAt']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Client Management'),
        backgroundColor: AppColors.adminPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadClients),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search clients by name, email, or phone...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _filterClients(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Filter: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Clients')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value ?? 'all');
                  _filterClients();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientStats() {
    final totalClients = _clients.length;
    final activeClients = _clients.where((c) => c['isActive'] == true).length;
    final inactiveClients = totalClients - activeClients;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total', totalClients, AppColors.primary),
          _buildStatCard('Active', activeClients, AppColors.success),
          _buildStatCard('Inactive', inactiveClients, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
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
            _error ?? 'An error occurred',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadClients, child: const Text('Retry')),
        ],
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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final isActive = client['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? AppColors.success : AppColors.error,
          child: Text(
            (client['name']?.toString().isNotEmpty == true)
                ? client['name'][0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          client['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client['email'] ?? 'No email'),
            Text(client['phone'] ?? 'No phone'),
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewClientDetails(client);
                break;
              case 'toggle':
                _toggleClientStatus(client);
                break;
            }
          },
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
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(isActive ? Icons.block : Icons.check_circle),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => _viewClientDetails(client),
      ),
    );
  }
}
