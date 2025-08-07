import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client['name'] ?? 'Client Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Health Records'),
            Tab(text: 'Appointments'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _error != null
                ? _buildErrorWidget()
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildHealthRecordsTab(),
                    _buildAppointmentsTab(),
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
}
