import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/providers/contraception_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/auto_translate_widget.dart';
import '../../core/models/contraception_method.dart';
import '../../core/models/side_effect_report.dart';
import 'widgets/add_method_form.dart';

/// Redesigned Contraception Management Screen
/// Based on database schema where all contraception_methods have user_id NOT NULL
class ContraceptionScreen extends ConsumerStatefulWidget {
  const ContraceptionScreen({super.key});

  @override
  ConsumerState<ContraceptionScreen> createState() =>
      _ContraceptionScreenState();
}

class _ContraceptionScreenState extends ConsumerState<ContraceptionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form state variables
  Map<String, dynamic>? _selectedUser;
  ContraceptionType? _selectedContraceptionType;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _effectivenessController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Side effects form state
  final _sideEffectsFormKey = GlobalKey<FormState>();
  final _sideEffectController = TextEditingController();
  ContraceptionMethod? _selectedMethodForSideEffect;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    final isHealthWorker = user?.role == 'health_worker';

    // Different tab counts for different roles
    _tabController = TabController(
      length:
          isHealthWorker
              ? 3
              : 4, // Health Worker: Prescribe, Manage, Reports | User: My Methods, Add Method, Education, Side Effects
      vsync: this,
    );

    // Initialize contraception data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      final isHealthWorker = ref.read(isHealthWorkerProvider);

      if (isHealthWorker) {
        ref.read(contraceptionProvider.notifier).initializeForHealthWorker();
      } else if (user != null && user.id != null) {
        ref
            .read(contraceptionProvider.notifier)
            .initializeForUser(userId: user.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _effectivenessController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contraceptionState = ref.watch(contraceptionProvider);
    final user = ref.watch(currentUserProvider);
    final isHealthWorker = ref.watch(isHealthWorkerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AutoTranslateWidget(
          'Contraception Management',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.contraceptionOrange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs:
              isHealthWorker
                  ? [
                    Tab(
                      child: AutoTranslateWidget(
                        'Prescribe Methods',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Tab(
                      child: AutoTranslateWidget(
                        'Manage Users',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Tab(
                      child: AutoTranslateWidget(
                        'Reports',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ]
                  : [
                    Tab(
                      child: AutoTranslateWidget(
                        'My Methods',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Tab(
                      child: AutoTranslateWidget(
                        'Add Method',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Tab(
                      child: AutoTranslateWidget(
                        'Education',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Tab(
                      child: AutoTranslateWidget(
                        'Side Effects',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: contraceptionState.isLoading,
        child: TabBarView(
          controller: _tabController,
          children:
              isHealthWorker
                  ? [
                    _buildPrescribeMethodsTab(),
                    _buildManageUsersTab(),
                    _buildHealthWorkerReportsTab(),
                  ]
                  : [
                    _buildUserMyMethodsTab(),
                    _buildAddMethodTab(),
                    _buildEducationTab(),
                    _buildUserSideEffectsTab(),
                  ],
        ),
      ),
    );
  }

  // ==================== HEALTH WORKER TABS ====================

  /// Health Worker Tab 1: Prescribe Methods to Users
  Widget _buildPrescribeMethodsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'Prescribe Contraceptive Methods',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          AutoTranslateWidget(
            'Select a user and prescribe a contraceptive method:',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Prescribe Method Form
          _buildPrescribeMethodForm(),
        ],
      ),
    );
  }

  /// Health Worker Tab 2: Manage All Users and Their Methods
  Widget _buildManageUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'Manage User Methods',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          AutoTranslateWidget(
            'View and manage contraceptive methods for all users:',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Users and Methods List
          _buildUsersMethodsList(),
        ],
      ),
    );
  }

  /// Health Worker Tab 3: Reports and Statistics
  Widget _buildHealthWorkerReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'Health Worker Reports',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          AutoTranslateWidget(
            'Comprehensive statistics and reports:',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Reports Dashboard
          _buildReportsDashboard(),
        ],
      ),
    );
  }

  // ==================== USER TABS ====================

  /// User Tab 1: My Methods - View assigned contraception methods
  Widget _buildUserMyMethodsTab() {
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'My Contraceptive Methods',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          AutoTranslateWidget(
            'Methods prescribed by your health worker:',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // User's Methods List
          _buildUserMethodsList(),
        ],
      ),
    );
  }

  /// User Tab 2: Education - Educational content about contraception
  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'Contraception Education',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          AutoTranslateWidget(
            'Learn about different contraceptive methods:',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Educational Content
          _buildEducationalContent(),
        ],
      ),
    );
  }

  /// User Tab 2: Add Method - Add new contraception method
  Widget _buildAddMethodTab() {
    return const SingleChildScrollView(child: AddMethodForm());
  }

  /// User Tab 4: Side Effects - Report side effects for their methods
  Widget _buildUserSideEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTranslateWidget(
            'Report Side Effects',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          AutoTranslateWidget(
            'Report any side effects you experience:',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Side Effects Form
          _buildSideEffectsForm(),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// Health Worker: Prescribe Method Form
  Widget _buildPrescribeMethodForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoTranslateWidget(
              'Prescribe New Method',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Prescribe Method Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Selection Dropdown
                  AutoTranslateWidget(
                    'Select User:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // User Selection Dropdown
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _loadAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Loading users...'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Error loading users: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        );
                      }

                      final users = snapshot.data ?? [];
                      return DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedUser,
                        decoration: const InputDecoration(
                          labelText: 'Select User to Prescribe Method',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items:
                            users.map((user) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: user,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      user['email'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUser = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a user';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Method Type Selection
                  AutoTranslateWidget(
                    'Contraception Type:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Method Type Dropdown
                  DropdownButtonFormField<ContraceptionType>(
                    value: _selectedContraceptionType,
                    decoration: const InputDecoration(
                      labelText: 'Select Contraception Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items:
                        ContraceptionType.values.map((type) {
                          return DropdownMenuItem<ContraceptionType>(
                            value: type,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  type.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  type.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedContraceptionType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a contraception type';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Method Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Method Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                      hintText: 'e.g., Yasmin Pills, Mirena IUD',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a method name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Additional details about the method',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Effectiveness Field
                  TextFormField(
                    controller: _effectivenessController,
                    decoration: const InputDecoration(
                      labelText: 'Effectiveness % (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                      hintText: 'e.g., 99.7',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final effectiveness = double.tryParse(value);
                        if (effectiveness == null ||
                            effectiveness < 0 ||
                            effectiveness > 100) {
                          return 'Please enter a valid percentage (0-100)';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Instructions Field
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info),
                      hintText: 'Usage instructions for the patient',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Prescribe Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a user'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (_selectedContraceptionType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a contraception type',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            await ref
                                .read(contraceptionProvider.notifier)
                                .prescribeMethod(
                                  1, // methodId - you'll need to get this from selected method
                                  _selectedUser!['id'], // userId
                                );

                            // Clear form on success
                            setState(() {
                              _selectedUser = null;
                              _selectedContraceptionType = null;
                            });
                            _nameController.clear();
                            _descriptionController.clear();
                            _effectivenessController.clear();
                            _instructionsController.clear();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Method prescribed successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.contraceptionOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: AutoTranslateWidget(
                        'Prescribe Method',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Health Worker: Users and Methods List
  Widget _buildUsersMethodsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AutoTranslateWidget(
              'All Users and Their Methods',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Users and Methods List
            Consumer(
              builder: (context, ref, child) {
                final contraceptionState = ref.watch(contraceptionProvider);
                final userMethods = contraceptionState.userMethods;

                if (contraceptionState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (contraceptionState.error != null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${contraceptionState.error}',
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(contraceptionProvider.notifier)
                                .initializeForHealthWorker();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (userMethods.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        AutoTranslateWidget(
                          'No users with contraception methods found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children:
                      userMethods.map((method) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.contraceptionOrange,
                              child: Icon(
                                Icons.medical_services,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              method.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Type: ${method.type.name} • ${method.isActive == true ? "Active" : "Inactive"}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Health Worker: Reports Dashboard
  Widget _buildReportsDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AutoTranslateWidget(
              'Statistics Dashboard',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Reports Dashboard
            Consumer(
              builder: (context, ref, child) {
                final contraceptionState = ref.watch(contraceptionProvider);
                final userMethods = contraceptionState.userMethods;

                if (contraceptionState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (contraceptionState.error != null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading reports: ${contraceptionState.error}',
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Calculate statistics
                final totalMethods = userMethods.length;
                final allMethods = userMethods;
                final activeMethods =
                    allMethods.where((m) => m.isActive == true).toList();
                final inactiveMethods =
                    allMethods.where((m) => m.isActive != true).toList();

                // Method type statistics
                final methodTypeStats = <ContraceptionType, int>{};
                for (final method in activeMethods) {
                  methodTypeStats[method.type] =
                      (methodTypeStats[method.type] ?? 0) + 1;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Methods',
                            totalMethods.toString(),
                            Icons.medical_services,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Methods',
                            activeMethods.length.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Inactive Methods',
                            inactiveMethods.length.toString(),
                            Icons.cancel,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Total Methods',
                            allMethods.length.toString(),
                            Icons.medical_services,
                            AppColors.contraceptionOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Method Type Distribution
                    AutoTranslateWidget(
                      'Method Type Distribution',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (methodTypeStats.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            AutoTranslateWidget(
                              'No active methods to display statistics',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...methodTypeStats.entries.map((entry) {
                        final type = entry.key;
                        final count = entry.value;
                        final percentage = (count / activeMethods.length * 100)
                            .toStringAsFixed(1);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getMethodIcon(type),
                                color: AppColors.contraceptionOrange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$count users ($percentage%)',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.contraceptionOrange
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.contraceptionOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// User: Methods List
  Widget _buildUserMethodsList() {
    final user = ref.watch(currentUserProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AutoTranslateWidget(
              'Your Prescribed Methods',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // User's Methods List
            Consumer(
              builder: (context, ref, child) {
                final contraceptionState = ref.watch(contraceptionProvider);
                final userMethods = contraceptionState.userMethods;

                if (contraceptionState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (contraceptionState.error != null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${contraceptionState.error}',
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final user = ref.read(currentUserProvider);
                            if (user?.id != null) {
                              ref
                                  .read(contraceptionProvider.notifier)
                                  .initializeForUser(userId: user!.id!);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (userMethods.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        AutoTranslateWidget(
                          'No contraception methods prescribed yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AutoTranslateWidget(
                          'Contact your health worker to get a contraception method prescribed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Separate active and inactive methods
                final activeMethods =
                    userMethods.where((m) => m.isActive == true).toList();
                final inactiveMethods =
                    userMethods.where((m) => m.isActive != true).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Methods Section
                    if (activeMethods.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Active Methods',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...activeMethods.map(
                        (method) => _buildUserMethodCard(method, true),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Inactive Methods Section
                    if (inactiveMethods.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Previous Methods',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...inactiveMethods.map(
                        (method) => _buildUserMethodCard(method, false),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// User: Educational Content
  Widget _buildEducationalContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AutoTranslateWidget(
              'Educational Resources',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // TODO: Implement educational content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.school, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  AutoTranslateWidget(
                    'Educational content will be implemented',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// User: Side Effects Form
  Widget _buildSideEffectsForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AutoTranslateWidget(
              'Report Side Effects',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Side Effects Reporting Form
            Consumer(
              builder: (context, ref, child) {
                final contraceptionState = ref.watch(contraceptionProvider);
                final userMethods = contraceptionState.userMethods;
                final activeMethods =
                    userMethods.where((m) => m.isActive == true).toList();

                if (contraceptionState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (contraceptionState.error != null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${contraceptionState.error}',
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (activeMethods.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.report_problem_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        AutoTranslateWidget(
                          'No active contraception methods',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AutoTranslateWidget(
                          'You need an active contraception method to report side effects',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Form(
                  key: _sideEffectsFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Method Selection
                      AutoTranslateWidget(
                        'Select Contraception Method',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ContraceptionMethod>(
                        value: _selectedMethodForSideEffect,
                        decoration: const InputDecoration(
                          labelText:
                              'Choose the method you experienced side effects with',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items:
                            activeMethods.map((method) {
                              return DropdownMenuItem<ContraceptionMethod>(
                                value: method,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(method.name),
                                    Text(
                                      method.type.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMethodForSideEffect = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a contraception method';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Side Effect Description
                      AutoTranslateWidget(
                        'Describe the Side Effect',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _sideEffectController,
                        decoration: const InputDecoration(
                          labelText: 'Describe the side effect you experienced',
                          hintText:
                              'e.g., Nausea, Headache, Mood changes, etc.',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe the side effect';
                          }
                          if (value.trim().length < 3) {
                            return 'Please provide a more detailed description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_sideEffectsFormKey.currentState!.validate()) {
                              if (_selectedMethodForSideEffect == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a contraception method',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );

                              try {
                                final sideEffectReport = SideEffectReport(
                                  id: 0, // Will be set by backend
                                  userId: 1, // Current user ID
                                  contraceptionMethodId:
                                      _selectedMethodForSideEffect!.id,
                                  symptom: _sideEffectController.text.trim(),
                                  severity: 'Moderate', // Default severity
                                  reportedDate: DateTime.now(),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                );

                                await ref
                                    .read(contraceptionProvider.notifier)
                                    .addSideEffect(sideEffectReport);

                                // Clear form on success
                                setState(() {
                                  _selectedMethodForSideEffect = null;
                                });
                                _sideEffectController.clear();

                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Side effect reported successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                // Refresh user methods to show updated side effects
                                final user = ref.read(currentUserProvider);
                                if (user?.id != null) {
                                  ref
                                      .read(contraceptionProvider.notifier)
                                      .initializeForUser(userId: user!.id!);
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.contraceptionOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const AutoTranslateWidget(
                            'Report Side Effect',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// Load all users for health worker dropdown
  Future<List<Map<String, dynamic>>> _loadAllUsers() async {
    try {
      await ref.read(contraceptionProvider.notifier).getAllUsers();
      // Return empty list for now - this would be populated from a real API
      return [];
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  /// Build method tile for users list
  Widget _buildMethodTile(ContraceptionMethod method, bool isActive) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isActive ? Colors.green.shade100 : Colors.grey.shade100,
        child: Icon(
          _getMethodIcon(method.type),
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          size: 20,
        ),
      ),
      title: Text(
        method.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.black : Colors.grey.shade600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method.type.displayName,
            style: TextStyle(
              color: isActive ? Colors.grey.shade700 : Colors.grey.shade500,
            ),
          ),
          Text(
            method.startDate != null
                ? 'Started: ${method.startDate!.day}/${method.startDate!.month}/${method.startDate!.year}'
                : 'Start date not set',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
      trailing:
          isActive
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
    );
  }

  /// Get icon for contraception method type
  IconData _getMethodIcon(ContraceptionType type) {
    switch (type) {
      case ContraceptionType.pill:
        return Icons.medication;
      case ContraceptionType.injection:
        return Icons.vaccines;
      case ContraceptionType.implant:
        return Icons.healing;
      case ContraceptionType.iud:
        return Icons.device_hub;
      case ContraceptionType.condom:
        return Icons.shield;
      case ContraceptionType.patch:
        return Icons.medical_services;
      case ContraceptionType.ring:
        return Icons.circle;
      case ContraceptionType.diaphragm:
        return Icons.circle_outlined;
      case ContraceptionType.naturalFamilyPlanning:
        return Icons.calendar_today;
      case ContraceptionType.sterilization:
        return Icons.block;
      case ContraceptionType.emergencyContraception:
        return Icons.emergency;
      case ContraceptionType.other:
        return Icons.more_horiz;
    }
  }

  /// Build statistics card for reports dashboard
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build method card for user's methods display
  Widget _buildUserMethodCard(ContraceptionMethod method, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade50,
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isActive ? Colors.green.shade100 : Colors.grey.shade100,
                child: Icon(
                  _getMethodIcon(method.type),
                  color:
                      isActive ? Colors.green.shade700 : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.black : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      method.type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isActive
                                ? Colors.grey.shade700
                                : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isActive ? Colors.green.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isActive ? Colors.green.shade700 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Method Details
          if (method.description != null && method.description!.isNotEmpty) ...[
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              method.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
          ],

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Started:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      method.startDate != null
                          ? '${method.startDate!.day}/${method.startDate!.month}/${method.startDate!.year}'
                          : 'Start date not set',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (method.effectiveness != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Effectiveness:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '${method.effectiveness!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (method.instructions != null &&
              method.instructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              method.instructions!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],

          if (method.sideEffects?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              'Reported Side Effects:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  method.sideEffects!.map((sideEffect) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sideEffect,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],

          // Action Buttons
          const SizedBox(height: 16),
          Row(
            children: [
              // Toggle Active/Inactive Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleMethodActiveState(method),
                  icon: Icon(
                    isActive ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(isActive ? 'Deactivate' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete Button (only for inactive methods)
              if (!isActive)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteMethod(method),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Toggle method active state
  Future<void> _toggleMethodActiveState(ContraceptionMethod method) async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(contraceptionProvider.notifier)
          .toggleMethodActiveState(methodId: method.id, userId: user!.id!);

      // Success - show confirmation
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              method.isActive == true
                  ? 'Method deactivated successfully!'
                  : 'Method activated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Delete method (only if inactive)
  Future<void> _deleteMethod(ContraceptionMethod method) async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Method'),
            content: Text(
              'Are you sure you want to delete "${method.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(contraceptionProvider.notifier)
          .deleteMethod(methodId: method.id, userId: user!.id!);

      // Success - show confirmation
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Method deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
