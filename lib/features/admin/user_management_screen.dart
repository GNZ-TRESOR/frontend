import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';
import '../../core/models/user.dart';

/// Admin User Management Screen
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getAllUsers();

      if (response.success && response.data != null) {
        // The API service now transforms the response to put everything in data
        final responseData = response.data as Map<String, dynamic>;
        final usersData = responseData['users'] as List<dynamic>? ?? [];
        _users =
            usersData
                .map((json) => User.fromJson(json as Map<String, dynamic>))
                .toList();
        _filterUsers();
      } else {
        _error = response.message ?? 'Failed to load users';
      }
    } catch (e) {
      _error = 'Error loading users: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();

    _filteredUsers =
        _users.where((user) {
          final matchesSearch =
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);

          bool matchesRole = _selectedRole == 'All';
          if (!matchesRole) {
            // Handle different role formats
            final userRole = user.role.toLowerCase();
            final selectedRole = _selectedRole.toLowerCase();

            if (selectedRole == 'healthworker') {
              matchesRole =
                  userRole == 'healthworker' || userRole == 'health_worker';
            } else {
              matchesRole = userRole == selectedRole;
            }
          }

          return matchesSearch && matchesRole;
        }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.adminPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildUserStats(),
            Expanded(
              child: _error != null ? _buildErrorState() : _buildUsersList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        backgroundColor: AppColors.adminPurple,
        child: const Icon(Icons.add, color: Colors.white),
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
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.adminPurple),
              ),
            ),
            onChanged: (_) => _filterUsers(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Filter by role: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  items:
                      ['All', 'Admin', 'HealthWorker', 'Client']
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedRole = value!);
                    _filterUsers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    final totalUsers = _users.length;
    final adminCount =
        _users.where((u) => u.role.toLowerCase() == 'admin').length;
    final healthWorkerCount =
        _users.where((u) => u.role.toLowerCase() == 'healthworker').length;
    final clientCount =
        _users.where((u) => u.role.toLowerCase() == 'client').length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          _buildStatCard('Total', totalUsers, AppColors.primary),
          _buildStatCard('Admins', adminCount, AppColors.adminPurple),
          _buildStatCard(
            'Health Workers',
            healthWorkerCount,
            AppColors.healthWorkerBlue,
          ),
          _buildStatCard('Clients', clientCount, AppColors.clientPink),
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
                fontSize: 20,
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

  Widget _buildUsersList() {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        user.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          user.isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(user, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                PopupMenuItem(
                  value: user.isActive ? 'deactivate' : 'activate',
                  child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete User'),
                ),
              ],
        ),
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
            'Error loading users',
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
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPurple,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.adminPurple;
      case 'healthworker':
      case 'health_worker':
        return AppColors.healthWorkerBlue;
      case 'client':
        return AppColors.clientPink;
      default:
        return Colors.grey;
    }
  }

  /// Convert backend role format to dropdown format
  String _convertRoleToDropdownFormat(String backendRole) {
    switch (backendRole.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'healthworker':
      case 'health_worker':
        return 'HEALTH_WORKER';
      case 'client':
        return 'CLIENT';
      default:
        return 'CLIENT';
    }
  }

  /// Convert dropdown role format to backend format
  String _convertRoleToBackendFormat(String dropdownRole) {
    switch (dropdownRole) {
      case 'ADMIN':
        return 'admin';
      case 'HEALTH_WORKER':
        return 'healthWorker';
      case 'CLIENT':
        return 'client';
      default:
        return 'client';
    }
  }

  void _handleUserAction(User user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('User Details: ${user.name}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Name', user.name),
                  _buildDetailRow('Email', user.email),
                  _buildDetailRow('Phone', user.phoneNumber ?? 'Not provided'),
                  _buildDetailRow('Role', user.roleDisplayName),
                  _buildDetailRow(
                    'Status',
                    user.isActive ? 'Active' : 'Inactive',
                  ),
                  _buildDetailRow('Gender', user.genderDisplayName),
                  _buildDetailRow(
                    'Date of Birth',
                    user.dateOfBirth?.toString() ?? 'Not provided',
                  ),
                  _buildDetailRow(
                    'Created',
                    user.createdAt?.toString() ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    'Updated',
                    user.updatedAt?.toString() ?? 'Never',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditUserDialog(user);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    String selectedRole = _convertRoleToDropdownFormat(user.role);
    String selectedGender = user.gender ?? 'Not specified';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit User: ${user.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['CLIENT', 'HEALTH_WORKER', 'ADMIN']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedRole = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Not specified', 'MALE', 'FEMALE', 'OTHER']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedGender = value!,
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
                onPressed: () {
                  Navigator.pop(context);
                  _updateUser(
                    user,
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                    selectedRole,
                    selectedGender,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'CLIENT';
    String selectedGender = 'Not specified';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['CLIENT', 'HEALTH_WORKER', 'ADMIN']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedRole = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Not specified', 'MALE', 'FEMALE', 'OTHER']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedGender = value!,
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
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _createUser(
                      nameController.text,
                      emailController.text,
                      phoneController.text,
                      passwordController.text,
                      selectedRole,
                      selectedGender,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _updateUser(
    User user,
    String name,
    String email,
    String phone,
    String role,
    String gender,
  ) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.instance.updateUser(user.id!, {
        'name': name,
        'email': email,
        'phone': phone,
        'role': _convertRoleToBackendFormat(role),
        'gender': gender == 'Not specified' ? null : gender,
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to update user'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createUser(
    String name,
    String email,
    String phone,
    String password,
    String role,
    String gender,
  ) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.instance.createUser({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': _convertRoleToBackendFormat(role),
        'gender': gender == 'Not specified' ? null : gender,
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to create user'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.instance.updateUserStatus(
        user.id!.toString(),
        !user.isActive,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${user.isActive ? 'deactivated' : 'activated'} successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to update user status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete User'),
            content: Text(
              'Are you sure you want to delete ${user.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(user);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteUser(User user) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.instance.deleteUser(user.id.toString());

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name} deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _loadUsers(); // Refresh the user list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to delete user'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
