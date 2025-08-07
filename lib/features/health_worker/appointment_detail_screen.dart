import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

/// Professional Appointment Detail Screen for Health Workers
class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailScreen({required this.appointment, super.key});

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _appointmentDetails = {};

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  Future<void> _loadAppointmentDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointmentId = widget.appointment['id'];
      if (appointmentId == null) throw Exception('Appointment ID is required');

      // Load appointment details
      final response = await ApiService.instance.getAppointmentDetails(
        appointmentId,
      );
      if (response.success && response.data != null) {
        setState(() {
          _appointmentDetails = Map<String, dynamic>.from(
            response.data['appointmentDetails'] as Map,
          );
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAppointmentStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointmentId = widget.appointment['id'];
      if (appointmentId == null) throw Exception('Appointment ID is required');

      // Update appointment status
      final response = await ApiService.instance.updateAppointmentStatus(
        appointmentId,
        newStatus,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment marked as $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh details
        _loadAppointmentDetails();
      } else {
        throw Exception(response.message ?? 'Failed to update status');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _error != null ? _buildErrorWidget() : _buildAppointmentDetails(),
      ),
      bottomNavigationBar: _buildActionButtons(),
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
            'Error loading appointment data',
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
            onPressed: _loadAppointmentDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    final details = Map<String, dynamic>.from(_appointmentDetails);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(details),
          const SizedBox(height: 24),
          _buildDetailsCard(details),
          const SizedBox(height: 24),
          _buildClientCard(details),
          const SizedBox(height: 24),
          _buildNotesCard(details),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> details) {
    final status = details['status'] ?? 'Pending';
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'rescheduled':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailsCard(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date', details['appointmentDate'] ?? 'N/A'),
            _buildInfoRow('Time', details['appointmentTime'] ?? 'N/A'),
            _buildInfoRow('Type', details['appointmentType'] ?? 'N/A'),
            _buildInfoRow('Location', details['location'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> details) {
    final client = details['client'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', client['name'] ?? 'N/A'),
            _buildInfoRow('Phone', client['phone'] ?? 'N/A'),
            _buildInfoRow('Email', client['email'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              details['notes'] ?? 'No notes available',
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
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

  Widget _buildActionButtons() {
    final currentStatus =
        _appointmentDetails['status']?.toString().toLowerCase() ?? '';

    if (currentStatus == 'completed' || currentStatus == 'cancelled') {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    () => _showConfirmDialog(
                      'Cancel Appointment',
                      'Are you sure you want to cancel this appointment?',
                      'cancelled',
                    ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    () => _showConfirmDialog(
                      'Complete Appointment',
                      'Mark this appointment as completed?',
                      'completed',
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Complete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(String title, String message, String status) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateAppointmentStatus(status);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}
