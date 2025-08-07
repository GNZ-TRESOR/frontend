import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class SideEffectReportsScreen extends ConsumerStatefulWidget {
  const SideEffectReportsScreen({super.key});

  @override
  ConsumerState<SideEffectReportsScreen> createState() =>
      _SideEffectReportsScreenState();
}

class _SideEffectReportsScreenState
    extends ConsumerState<SideEffectReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Side effect reports data
  List<Map<String, dynamic>> _allReports = [];
  List<Map<String, dynamic>> _activeReports = [];
  List<Map<String, dynamic>> _resolvedReports = [];
  List<Map<String, dynamic>> _clients = [];

  // Form controllers
  String? _selectedClientId;
  String? _selectedContraceptiveMethod;
  String? _selectedSeverity;
  String? _selectedCategory;
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _actionTakenController = TextEditingController();

  // Contraceptive methods
  final List<String> _contraceptiveMethods = [
    'Birth Control Pills',
    'IUD (Copper)',
    'IUD (Hormonal)',
    'Contraceptive Injection',
    'Contraceptive Implant',
    'Contraceptive Patch',
    'Vaginal Ring',
    'Condoms',
    'Emergency Contraception',
    'Other',
  ];

  // Severity levels
  final List<String> _severityLevels = [
    'MILD',
    'MODERATE',
    'SEVERE',
    'CRITICAL',
  ];

  // Side effect categories
  final List<String> _categories = [
    'Hormonal',
    'Gastrointestinal',
    'Cardiovascular',
    'Neurological',
    'Dermatological',
    'Reproductive',
    'Psychological',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([_loadSideEffectReports(), _loadClients()]);
    } catch (e) {
      debugPrint('Error loading data: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSideEffectReports() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    try {
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/side-effect-reports',
      );
      if (response.statusCode == 200) {
        final reports = List<Map<String, dynamic>>.from(
          response.data['reports'] ?? [],
        );
        setState(() {
          _allReports = reports;
          _activeReports =
              reports
                  .where(
                    (report) =>
                        report['status'] == 'ACTIVE' ||
                        report['status'] == 'MONITORING',
                  )
                  .toList();
          _resolvedReports =
              reports
                  .where(
                    (report) =>
                        report['status'] == 'RESOLVED' ||
                        report['status'] == 'CLOSED',
                  )
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading side effect reports: $e');
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
      _allReports = [
        {
          'id': 1,
          'clientId': 3,
          'clientName': 'Grace Mukamana',
          'contraceptiveMethod': 'Birth Control Pills',
          'symptoms': 'Nausea, headaches, mood swings',
          'severity': 'MODERATE',
          'category': 'Hormonal',
          'status': 'ACTIVE',
          'reportedDate': '2025-08-05T10:00:00Z',
          'lastUpdated': '2025-08-05T10:00:00Z',
          'notes':
              'Client reports symptoms started 2 weeks after starting pills',
          'actionTaken':
              'Advised to monitor for another week, scheduled follow-up',
          'reportedBy': 'Dr. Marie Uwimana',
        },
        {
          'id': 2,
          'clientId': 3,
          'clientName': 'Grace Mukamana',
          'contraceptiveMethod': 'Contraceptive Injection',
          'symptoms': 'Irregular bleeding, weight gain',
          'severity': 'MILD',
          'category': 'Reproductive',
          'status': 'MONITORING',
          'reportedDate': '2025-07-20T14:30:00Z',
          'lastUpdated': '2025-08-01T09:00:00Z',
          'notes': 'Common side effects for injection method',
          'actionTaken': 'Provided counseling on expected side effects',
          'reportedBy': 'Dr. Marie Uwimana',
        },
        {
          'id': 3,
          'clientId': 4,
          'clientName': 'John Doe',
          'contraceptiveMethod': 'IUD (Copper)',
          'symptoms': 'Heavy menstrual bleeding, cramping',
          'severity': 'SEVERE',
          'category': 'Reproductive',
          'status': 'RESOLVED',
          'reportedDate': '2025-07-10T11:00:00Z',
          'lastUpdated': '2025-07-25T16:00:00Z',
          'notes': 'Symptoms resolved after adjustment period',
          'actionTaken': 'Prescribed pain management, symptoms improved',
          'reportedBy': 'Dr. Marie Uwimana',
          'resolvedDate': '2025-07-25T16:00:00Z',
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

      _activeReports =
          _allReports
              .where(
                (report) =>
                    report['status'] == 'ACTIVE' ||
                    report['status'] == 'MONITORING',
              )
              .toList();
      _resolvedReports =
          _allReports
              .where(
                (report) =>
                    report['status'] == 'RESOLVED' ||
                    report['status'] == 'CLOSED',
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Side Effect Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateReportDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Report Side Effect',
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
                        Text('Export Reports'),
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
                  const PopupMenuItem(
                    value: 'guidelines',
                    child: Row(
                      children: [
                        Icon(Icons.book),
                        SizedBox(width: 8),
                        Text('Side Effect Guidelines'),
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
            Tab(text: 'All Reports'),
            Tab(text: 'Active'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllReportsTab(),
            _buildActiveReportsTab(),
            _buildResolvedReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadSideEffectReports,
      child:
          _allReports.isEmpty
              ? _buildEmptyState(
                'No side effect reports found',
                'Create your first side effect report to get started',
                Icons.report_problem,
                () => _showCreateReportDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allReports.length,
                itemBuilder: (context, index) {
                  final report = _allReports[index];
                  return _buildReportCard(report);
                },
              ),
    );
  }

  Widget _buildActiveReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadSideEffectReports,
      child:
          _activeReports.isEmpty
              ? _buildEmptyState(
                'No active reports',
                'All side effect reports are resolved',
                Icons.check_circle,
                () => _showCreateReportDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _activeReports.length,
                itemBuilder: (context, index) {
                  final report = _activeReports[index];
                  return _buildReportCard(report);
                },
              ),
    );
  }

  Widget _buildResolvedReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadSideEffectReports,
      child:
          _resolvedReports.isEmpty
              ? _buildEmptyState(
                'No resolved reports',
                'Resolved side effect reports will appear here',
                Icons.history,
                () => _showCreateReportDialog(),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _resolvedReports.length,
                itemBuilder: (context, index) {
                  final report = _resolvedReports[index];
                  return _buildReportCard(report);
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
            label: const Text('Report Side Effect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] ?? 'ACTIVE';
    final severity = report['severity'] ?? 'MILD';
    final category = report['category'] ?? 'Other';
    final clientName = report['clientName'] ?? 'Unknown Client';
    final contraceptiveMethod =
        report['contraceptiveMethod'] ?? 'Unknown Method';
    final symptoms = report['symptoms'] ?? 'No symptoms listed';
    final reportedDate = report['reportedDate'];
    final lastUpdated = report['lastUpdated'];

    Color statusColor = AppColors.warning;
    IconData statusIcon = Icons.warning;

    switch (status) {
      case 'ACTIVE':
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        break;
      case 'MONITORING':
        statusColor = AppColors.warning;
        statusIcon = Icons.visibility;
        break;
      case 'RESOLVED':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'CLOSED':
        statusColor = Colors.grey;
        statusIcon = Icons.archive;
        break;
    }

    Color severityColor = AppColors.info;
    switch (severity) {
      case 'MILD':
        severityColor = AppColors.success;
        break;
      case 'MODERATE':
        severityColor = AppColors.warning;
        break;
      case 'SEVERE':
        severityColor = AppColors.error;
        break;
      case 'CRITICAL':
        severityColor = Colors.red[800]!;
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
                        contraceptiveMethod,
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
                  onSelected: (value) => _handleReportAction(value, report),
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
                        if (status == 'ACTIVE' || status == 'MONITORING')
                          const PopupMenuItem(
                            value: 'update',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Update Report'),
                              ],
                            ),
                          ),
                        if (status == 'ACTIVE' || status == 'MONITORING')
                          const PopupMenuItem(
                            value: 'resolve',
                            child: Row(
                              children: [
                                Icon(Icons.check),
                                SizedBox(width: 8),
                                Text('Mark Resolved'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'follow_up',
                          child: Row(
                            children: [
                              Icon(Icons.schedule),
                              SizedBox(width: 8),
                              Text('Schedule Follow-up'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Symptoms: $symptoms',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            if (report['notes'] != null && report['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${report['notes']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(status, statusIcon, statusColor),
                const SizedBox(width: 8),
                _buildInfoChip(severity, Icons.priority_high, severityColor),
                const SizedBox(width: 8),
                _buildInfoChip(category, Icons.category, Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (reportedDate != null)
                  _buildInfoChip(
                    'Reported: ${_formatDate(reportedDate)}',
                    Icons.calendar_today,
                    Colors.grey,
                  ),
                if (lastUpdated != null && lastUpdated != reportedDate) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    'Updated: ${_formatDate(lastUpdated)}',
                    Icons.update,
                    Colors.grey,
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
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  // Action handlers
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportReports();
        break;
      case 'statistics':
        _showStatistics();
        break;
      case 'guidelines':
        _showGuidelines();
        break;
    }
  }

  void _handleReportAction(String action, Map<String, dynamic> report) {
    switch (action) {
      case 'view':
        _viewReportDetails(report);
        break;
      case 'update':
        _updateReport(report);
        break;
      case 'resolve':
        _resolveReport(report);
        break;
      case 'follow_up':
        _scheduleFollowUp(report);
        break;
    }
  }

  // Dialog methods
  void _showCreateReportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Side Effect'),
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
                  // Contraceptive method selection
                  DropdownButtonFormField<String>(
                    value: _selectedContraceptiveMethod,
                    decoration: const InputDecoration(
                      labelText: 'Contraceptive Method',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items:
                        _contraceptiveMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                method,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedContraceptiveMethod = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Severity selection
                  DropdownButtonFormField<String>(
                    value: _selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items:
                        _severityLevels.map((severity) {
                          return DropdownMenuItem<String>(
                            value: severity,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                severity,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSeverity = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category selection
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Symptoms
                  TextField(
                    controller: _symptomsController,
                    decoration: const InputDecoration(
                      labelText: 'Symptoms',
                      hintText: 'Describe the symptoms experienced',
                      prefixIcon: Icon(Icons.sick),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional notes or observations',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
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
                onPressed: _createSideEffectReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Report'),
              ),
            ],
          ),
    );
  }

  // Action implementation methods
  void _createSideEffectReport() async {
    if (_selectedClientId == null ||
        _selectedContraceptiveMethod == null ||
        _selectedSeverity == null ||
        _selectedCategory == null ||
        _symptomsController.text.isEmpty) {
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
        '/side-effect-reports',
        data: {
          'clientId': int.parse(_selectedClientId!),
          'contraceptiveMethod': _selectedContraceptiveMethod,
          'symptoms': _symptomsController.text,
          'severity': _selectedSeverity,
          'category': _selectedCategory,
          'notes': _notesController.text,
          'reportedBy': user!.id,
          'status': 'ACTIVE',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Side effect report created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearForm();
      _loadSideEffectReports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create side effect report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _exportReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting side effect reports...')),
    );
  }

  void _showStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing side effect statistics...')),
    );
  }

  void _showGuidelines() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening side effect guidelines...')),
    );
  }

  void _viewReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Side Effect Report Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Client', report['clientName'] ?? 'Unknown'),
                  _buildDetailRow(
                    'Contraceptive Method',
                    report['contraceptiveMethod'] ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    'Symptoms',
                    report['symptoms'] ?? 'None listed',
                  ),
                  _buildDetailRow('Severity', report['severity'] ?? 'Unknown'),
                  _buildDetailRow('Category', report['category'] ?? 'Unknown'),
                  _buildDetailRow('Status', report['status'] ?? 'Unknown'),
                  if (report['reportedDate'] != null)
                    _buildDetailRow(
                      'Reported Date',
                      _formatDate(report['reportedDate']),
                    ),
                  if (report['lastUpdated'] != null)
                    _buildDetailRow(
                      'Last Updated',
                      _formatDate(report['lastUpdated']),
                    ),
                  if (report['notes'] != null && report['notes'].isNotEmpty)
                    _buildDetailRow('Notes', report['notes']),
                  if (report['actionTaken'] != null &&
                      report['actionTaken'].isNotEmpty)
                    _buildDetailRow('Action Taken', report['actionTaken']),
                  _buildDetailRow(
                    'Reported By',
                    report['reportedBy'] ?? 'Unknown',
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
            width: 120,
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

  void _updateReport(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating report for: ${report['clientName']}')),
    );
  }

  void _resolveReport(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resolving report for: ${report['clientName']}')),
    );
  }

  void _scheduleFollowUp(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduling follow-up for: ${report['clientName']}'),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedClientId = null;
      _selectedContraceptiveMethod = null;
      _selectedSeverity = null;
      _selectedCategory = null;
    });
    _symptomsController.clear();
    _notesController.clear();
    _actionTakenController.clear();
  }
}
