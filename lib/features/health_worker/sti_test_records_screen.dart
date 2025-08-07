import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class STITestRecordsScreen extends ConsumerStatefulWidget {
  const STITestRecordsScreen({super.key});

  @override
  ConsumerState<STITestRecordsScreen> createState() =>
      _STITestRecordsScreenState();
}

class _STITestRecordsScreenState extends ConsumerState<STITestRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // STI test records data
  List<Map<String, dynamic>> _allTests = [];
  List<Map<String, dynamic>> _pendingTests = [];
  List<Map<String, dynamic>> _completedTests = [];
  List<Map<String, dynamic>> _clients = [];

  // Form controllers
  final _clientSearchController = TextEditingController();
  String? _selectedClientId;
  String? _selectedTestType;
  String? _selectedPriority;
  final _notesController = TextEditingController();

  // STI test types
  final List<String> _testTypes = [
    'HIV Test',
    'Syphilis Test',
    'Gonorrhea Test',
    'Chlamydia Test',
    'Hepatitis B Test',
    'Hepatitis C Test',
    'Herpes Test',
    'HPV Test',
  ];

  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientSearchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([_loadSTITests(), _loadClients()]);
    } catch (e) {
      debugPrint('Error loading data: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSTITests() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/sti-tests',
      );
      if (response.statusCode == 200) {
        final tests = List<Map<String, dynamic>>.from(
          response.data['tests'] ?? [],
        );
        setState(() {
          _allTests = tests;
          _pendingTests =
              tests
                  .where(
                    (test) =>
                        test['status'] == 'PENDING' ||
                        test['status'] == 'SCHEDULED',
                  )
                  .toList();
          _completedTests =
              tests
                  .where(
                    (test) =>
                        test['status'] == 'COMPLETED' ||
                        test['status'] == 'POSITIVE' ||
                        test['status'] == 'NEGATIVE',
                  )
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading STI tests: $e');
    }
  }

  Future<void> _loadClients() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/clients',
      );
      if (response.statusCode == 200) {
        setState(() {
          _clients = List<Map<String, dynamic>>.from(
            response.data['clients'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading clients: $e');
    }
  }

  void _loadMockData() {
    // Mock data for development
    setState(() {
      _allTests = [
        {
          'id': 1,
          'clientId': 3,
          'clientName': 'Grace Mukamana',
          'testType': 'HIV Test',
          'status': 'PENDING',
          'priority': 'HIGH',
          'scheduledDate': '2025-08-07T10:00:00Z',
          'requestedDate': '2025-08-05T14:30:00Z',
          'notes': 'Routine screening as requested by client',
          'requestedBy': 'Dr. Marie Uwimana',
        },
        {
          'id': 2,
          'clientId': 3,
          'clientName': 'Grace Mukamana',
          'testType': 'Syphilis Test',
          'status': 'COMPLETED',
          'priority': 'MEDIUM',
          'scheduledDate': '2025-08-01T09:00:00Z',
          'completedDate': '2025-08-01T09:30:00Z',
          'result': 'NEGATIVE',
          'notes': 'Test completed successfully, results normal',
          'requestedBy': 'Dr. Marie Uwimana',
        },
        {
          'id': 3,
          'clientId': 4,
          'clientName': 'John Doe',
          'testType': 'Chlamydia Test',
          'status': 'SCHEDULED',
          'priority': 'MEDIUM',
          'scheduledDate': '2025-08-08T11:00:00Z',
          'requestedDate': '2025-08-04T16:00:00Z',
          'notes': 'Follow-up test after treatment',
          'requestedBy': 'Dr. Marie Uwimana',
        },
      ];

      _clients = [
        {
          'id': 3,
          'name': 'Grace Mukamana',
          'phone': '+250788000003',
          'email': 'client@ubuzima.rw',
        },
        {
          'id': 4,
          'name': 'John Doe',
          'phone': '+250788000004',
          'email': 'john.doe@example.com',
        },
      ];

      _pendingTests =
          _allTests
              .where(
                (test) =>
                    test['status'] == 'PENDING' ||
                    test['status'] == 'SCHEDULED',
              )
              .toList();
      _completedTests =
          _allTests
              .where(
                (test) =>
                    test['status'] == 'COMPLETED' ||
                    test['status'] == 'POSITIVE' ||
                    test['status'] == 'NEGATIVE',
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STI Test Records'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateTestDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Schedule STI Test',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Records'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'statistics',
                    child: Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('View Statistics'),
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
            Tab(text: 'All Tests'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllTestsTab(),
            _buildPendingTestsTab(),
            _buildCompletedTestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTestsTab() {
    return RefreshIndicator(
      onRefresh: _loadSTITests,
      child:
          _allTests.isEmpty
              ? _buildEmptyState(
                'No STI tests found',
                'Schedule your first STI test to get started',
                Icons.medical_services,
                () => _showCreateTestDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allTests.length,
                itemBuilder: (context, index) {
                  final test = _allTests[index];
                  return _buildTestCard(test);
                },
              ),
    );
  }

  Widget _buildPendingTestsTab() {
    return RefreshIndicator(
      onRefresh: _loadSTITests,
      child:
          _pendingTests.isEmpty
              ? _buildEmptyState(
                'No pending tests',
                'All STI tests are up to date',
                Icons.check_circle,
                () => _showCreateTestDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingTests.length,
                itemBuilder: (context, index) {
                  final test = _pendingTests[index];
                  return _buildTestCard(test);
                },
              ),
    );
  }

  Widget _buildCompletedTestsTab() {
    return RefreshIndicator(
      onRefresh: _loadSTITests,
      child:
          _completedTests.isEmpty
              ? _buildEmptyState(
                'No completed tests',
                'Completed STI tests will appear here',
                Icons.history,
                () => _showCreateTestDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _completedTests.length,
                itemBuilder: (context, index) {
                  final test = _completedTests[index];
                  return _buildTestCard(test);
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
            label: const Text('Schedule Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    final status = test['status'] ?? 'PENDING';
    final priority = test['priority'] ?? 'MEDIUM';
    final testType = test['testType'] ?? 'Unknown Test';
    final clientName = test['clientName'] ?? 'Unknown Client';
    final scheduledDate = test['scheduledDate'];
    final completedDate = test['completedDate'];
    final result = test['result'];

    Color statusColor = AppColors.warning;
    IconData statusIcon = Icons.schedule;

    switch (status) {
      case 'PENDING':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case 'SCHEDULED':
        statusColor = AppColors.info;
        statusIcon = Icons.event;
        break;
      case 'COMPLETED':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'POSITIVE':
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        break;
      case 'NEGATIVE':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
    }

    Color priorityColor = AppColors.info;
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
      case 'URGENT':
        priorityColor = Colors.red[800]!;
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
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testType,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Client: $clientName',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleTestAction(value, test),
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
                        if (status == 'PENDING' || status == 'SCHEDULED')
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
                        if (status == 'SCHEDULED')
                          const PopupMenuItem(
                            value: 'mark_completed',
                            child: Row(
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 8),
                                Text('Mark Completed'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (test['notes'] != null && test['notes'].isNotEmpty)
              Text(
                test['notes'],
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(status, statusIcon, statusColor),
                const SizedBox(width: 8),
                _buildInfoChip(priority, Icons.priority_high, priorityColor),
                if (result != null) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    result,
                    result == 'POSITIVE' ? Icons.warning : Icons.check,
                    result == 'POSITIVE' ? AppColors.error : AppColors.success,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (scheduledDate != null)
                  _buildInfoChip(
                    'Scheduled: ${_formatDate(scheduledDate)}',
                    Icons.schedule,
                    Colors.grey,
                  ),
                if (completedDate != null) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    'Completed: ${_formatDate(completedDate)}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ],
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
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Action handlers
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportRecords();
        break;
      case 'statistics':
        _showStatistics();
        break;
    }
  }

  void _handleTestAction(String action, Map<String, dynamic> test) {
    switch (action) {
      case 'view':
        _viewTestDetails(test);
        break;
      case 'update_status':
        _updateTestStatus(test);
        break;
      case 'mark_completed':
        _markTestCompleted(test);
        break;
      case 'edit':
        _editTest(test);
        break;
    }
  }

  // Dialog methods
  void _showCreateTestDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Schedule STI Test'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Client selection
                  DropdownButtonFormField<String>(
                    value: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Select Client',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items:
                        _clients.map((client) {
                          return DropdownMenuItem<String>(
                            value: client['id'].toString(),
                            child: Text(client['name'] ?? 'Unknown'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedClientId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Test type selection
                  DropdownButtonFormField<String>(
                    value: _selectedTestType,
                    decoration: const InputDecoration(
                      labelText: 'Test Type',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items:
                        _testTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedTestType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Priority selection
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items:
                        _priorities.map((priority) {
                          return DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPriority = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Enter any additional notes',
                      prefixIcon: Icon(Icons.note),
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
                onPressed: _createSTITest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Schedule'),
              ),
            ],
          ),
    );
  }

  // Action implementation methods
  void _createSTITest() async {
    if (_selectedClientId == null ||
        _selectedTestType == null ||
        _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      await ApiService.instance.dio.post(
        '/sti-tests',
        data: {
          'clientId': int.parse(_selectedClientId!),
          'testType': _selectedTestType,
          'priority': _selectedPriority,
          'notes': _notesController.text,
          'requestedBy': user!.id,
          'status': 'PENDING',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('STI test scheduled successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearForm();
      _loadSTITests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule STI test: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _exportRecords() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting STI test records...')),
    );
  }

  void _showStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing STI test statistics...')),
    );
  }

  void _viewTestDetails(Map<String, dynamic> test) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(test['testType'] ?? 'STI Test Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Client', test['clientName'] ?? 'Unknown'),
                  _buildDetailRow('Test Type', test['testType'] ?? 'Unknown'),
                  _buildDetailRow('Status', test['status'] ?? 'Unknown'),
                  _buildDetailRow('Priority', test['priority'] ?? 'Unknown'),
                  if (test['result'] != null)
                    _buildDetailRow('Result', test['result']),
                  if (test['scheduledDate'] != null)
                    _buildDetailRow(
                      'Scheduled Date',
                      _formatDate(test['scheduledDate']),
                    ),
                  if (test['completedDate'] != null)
                    _buildDetailRow(
                      'Completed Date',
                      _formatDate(test['completedDate']),
                    ),
                  if (test['notes'] != null && test['notes'].isNotEmpty)
                    _buildDetailRow('Notes', test['notes']),
                  _buildDetailRow(
                    'Requested By',
                    test['requestedBy'] ?? 'Unknown',
                  ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateTestStatus(Map<String, dynamic> test) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating status for: ${test['testType']}')),
    );
  }

  void _markTestCompleted(Map<String, dynamic> test) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marking completed: ${test['testType']}')),
    );
  }

  void _editTest(Map<String, dynamic> test) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing test: ${test['testType']}')),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedClientId = null;
      _selectedTestType = null;
      _selectedPriority = null;
    });
    _notesController.clear();
  }
}
