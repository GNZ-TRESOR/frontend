import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/retry_widget.dart';
import '../messages/whatsapp_chat_screen.dart';

/// Professional Client Detail Screen for Health Workers
class ClientDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> client;

  const ClientDetailScreen({required this.client, super.key});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  // Client data
  Map<String, dynamic> _clientDetails = {};
  List<Map<String, dynamic>> _healthRecords = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _stiTestResults = [];
  List<Map<String, dynamic>> _sideEffectReports = [];
  Map<String, dynamic> _healthSummary = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _clientDetails = widget.client;
    _loadClientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClientData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final clientId = widget.client['id'];
      if (clientId == null) throw Exception('Client ID is required');

      // Load client details
      final detailsResponse = await ApiService.instance.getClientDetails(
        clientId,
      );
      if (detailsResponse.success && detailsResponse.data != null) {
        _clientDetails = Map<String, dynamic>.from(
          detailsResponse.data['clientDetails'] as Map,
        );
      }

      // Load health records
      final recordsResponse = await ApiService.instance.getClientHealthRecords(
        clientId,
      );
      if (recordsResponse.success && recordsResponse.data != null) {
        _healthRecords = List<Map<String, dynamic>>.from(
          recordsResponse.data['records'] as List? ?? [],
        );
      }

      // Load appointments
      final appointmentsResponse = await ApiService.instance
          .getClientAppointments(clientId);
      if (appointmentsResponse.success && appointmentsResponse.data != null) {
        _appointments = List<Map<String, dynamic>>.from(
          appointmentsResponse.data['appointments'] as List? ?? [],
        );
      }

      // Load STI test results
      await _loadSTITestResults(clientId);

      // Load side effect reports
      await _loadSideEffectReports(clientId);

      // Load health summary
      await _loadHealthSummary(clientId);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSTITestResults(int clientId) async {
    try {
      final response = await ApiService.instance.getStiTestRecords();
      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        _stiTestResults = List<Map<String, dynamic>>.from(
          responseData['records'] ?? [],
        );
      }
    } catch (e) {
      debugPrint('Error loading STI test results: $e');
    }
  }

  Future<void> _loadSideEffectReports(int clientId) async {
    try {
      final response = await ApiService.instance.getUserSideEffects(clientId);
      if (response.success && response.data != null) {
        _sideEffectReports = List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error loading side effect reports: $e');
    }
  }

  Future<void> _loadHealthSummary(int clientId) async {
    try {
      // For now, create a summary from available data
      _healthSummary = {
        'totalRecords': _healthRecords.length,
        'totalAppointments': _appointments.length,
        'totalSTITests': _stiTestResults.length,
        'totalSideEffects': _sideEffectReports.length,
        'lastVisit':
            _appointments.isNotEmpty ? _appointments.first['date'] : null,
      };
    } catch (e) {
      debugPrint('Error loading health summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_clientDetails['name'] ?? 'Client Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_clientDetails['phone'] != null)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _makePhoneCall(_clientDetails['phone']),
              tooltip: 'Call Client',
            ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: _openChat,
            tooltip: 'Send Message',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Client'),
                  ),
                  const PopupMenuItem(
                    value: 'add_record',
                    child: Text('Add Health Record'),
                  ),
                  const PopupMenuItem(
                    value: 'schedule_appointment',
                    child: Text('Schedule Appointment'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Health Records'),
            Tab(text: 'Appointments'),
            Tab(text: 'STI Tests'),
            Tab(text: 'Side Effects'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _error != null
                ? RetryWidget.apiError(
                  message: _error!,
                  onRetry: _loadClientData,
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildHealthRecordsTab(),
                    _buildAppointmentsTab(),
                    _buildSTITestsTab(),
                    _buildSideEffectsTab(),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionsDialog(),
        backgroundColor: AppColors.primary,
        label: const Text('Take Action'),
        icon: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading client data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadClientData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final details = Map<String, dynamic>.from(_clientDetails);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(details),
          const SizedBox(height: 24),
          _buildContactCard(details),
          const SizedBox(height: 24),
          _buildStatisticsCard(details),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', details['name'] ?? 'N/A'),
            _buildInfoRow('Age', details['age']?.toString() ?? 'N/A'),
            _buildInfoRow('Gender', details['gender'] ?? 'N/A'),
            _buildInfoRow('Blood Type', details['bloodType'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Phone', details['phone'] ?? 'N/A'),
            _buildInfoRow('Email', details['email'] ?? 'N/A'),
            _buildInfoRow('District', details['district'] ?? 'N/A'),
            _buildInfoRow('Sector', details['sector'] ?? 'N/A'),
            _buildInfoRow('Cell', details['cell'] ?? 'N/A'),
            _buildInfoRow('Village', details['village'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Total Health Records',
              details['totalHealthRecords']?.toString() ?? '0',
            ),
            _buildInfoRow(
              'Total Appointments',
              details['totalAppointments']?.toString() ?? '0',
            ),
            _buildInfoRow('Last Visit', details['lastVisit'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordsTab() {
    return _healthRecords.isEmpty
        ? _buildEmptyState(
          'No Health Records',
          'Health records will appear here',
          Icons.folder_outlined,
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _healthRecords.length,
          itemBuilder: (context, index) {
            final record = _healthRecords[index];
            return _buildHealthRecordCard(record);
          },
        );
  }

  Widget _buildHealthRecordCard(Map<String, dynamic> record) {
    final date = record['date'] ?? 'N/A';
    final type = record['type'] ?? 'General';
    final notes = record['notes'] ?? 'No notes';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(30),
          child: Icon(Icons.medical_services, color: AppColors.primary),
        ),
        title: Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            Text(notes, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        onTap: () => _viewHealthRecord(record),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return _appointments.isEmpty
        ? _buildEmptyState(
          'No Appointments',
          'Appointments will appear here',
          Icons.calendar_today_outlined,
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            final appointment = _appointments[index];
            return _buildAppointmentCard(appointment);
          },
        );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final date = appointment['appointmentDate'] ?? 'N/A';
    final status = appointment['status'] ?? 'Pending';
    final type = appointment['type'] ?? 'General';

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withAlpha(30),
          child: Icon(Icons.calendar_today, color: AppColors.secondary),
        ),
        title: Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
        onTap: () => _viewAppointment(appointment),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withAlpha(150)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showActionsDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Schedule Appointment'),
                  onTap: () {
                    Navigator.pop(context);
                    _scheduleAppointment();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Add Health Record'),
                  onTap: () {
                    Navigator.pop(context);
                    _addHealthRecord();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('Send Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _scheduleAppointment() async {
    // TODO: Navigate to appointment scheduling screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schedule appointment')));
  }

  Future<void> _addHealthRecord() async {
    // TODO: Navigate to health record creation screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add health record')));
  }

  Future<void> _sendMessage() async {
    // TODO: Navigate to messaging screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Send message')));
  }

  void _viewHealthRecord(Map<String, dynamic> record) {
    // TODO: Show health record details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View health record from ${record['date']}')),
    );
  }

  void _viewAppointment(Map<String, dynamic> appointment) {
    // TODO: Show appointment details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View appointment on ${appointment['date']}')),
    );
  }

  /// Make a phone call to the client using the device's default phone app
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create the tel: URL
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      // Check if the device can handle phone calls
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make phone calls on this device'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make phone call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppChatScreen(otherUser: _clientDetails),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit client feature coming soon')),
        );
        break;
      case 'add_record':
        _addHealthRecord();
        break;
      case 'schedule_appointment':
        _scheduleAppointment();
        break;
    }
  }

  Widget _buildSTITestsTab() {
    if (_stiTestResults.isEmpty) {
      return _buildEmptyState(
        'No STI Tests',
        'No STI test results found for this client',
        Icons.science,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stiTestResults.length,
      itemBuilder: (context, index) {
        final test = _stiTestResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
              child: Icon(Icons.science, color: AppColors.warning),
            ),
            title: Text(test['testType'] ?? 'STI Test'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Result: ${test['result'] ?? 'Pending'}'),
                Text('Date: ${test['testDate'] ?? 'Unknown'}'),
              ],
            ),
            trailing: Icon(
              test['result'] == 'NEGATIVE' ? Icons.check_circle : Icons.warning,
              color:
                  test['result'] == 'NEGATIVE'
                      ? AppColors.success
                      : AppColors.warning,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideEffectsTab() {
    if (_sideEffectReports.isEmpty) {
      return _buildEmptyState(
        'No Side Effects',
        'No side effect reports found for this client',
        Icons.report_problem,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sideEffectReports.length,
      itemBuilder: (context, index) {
        final report = _sideEffectReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              child: Icon(Icons.report_problem, color: AppColors.error),
            ),
            title: Text(report['sideEffectName'] ?? 'Side Effect'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Severity: ${report['severity'] ?? 'Unknown'}'),
                Text('Date: ${report['dateReported'] ?? 'Unknown'}'),
                if (report['description'] != null)
                  Text('Description: ${report['description']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
