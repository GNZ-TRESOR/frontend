import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  final DateFormat _fullDateFormatter = DateFormat('MMM dd, yyyy \'at\' HH:mm');

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

      // Convert to int if it's a string
      final id =
          appointmentId is String
              ? int.parse(appointmentId)
              : appointmentId as int;

      // Load detailed appointment information using proper API service method
      final response = await ApiService.instance.getAppointmentDetails(id);

      if (response.success && response.data != null) {
        setState(() {
          _appointmentDetails = Map<String, dynamic>.from(
            response.data['appointment'] as Map? ?? response.data as Map,
          );
        });
      } else {
        throw Exception(
          response.message ?? 'Failed to load appointment details',
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAppointmentStatus(
    String newStatus, {
    String? reason,
  }) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointmentId = _appointmentDetails['id'];
      if (appointmentId == null) throw Exception('Appointment ID is required');

      // Update appointment status via health worker endpoint
      final response = await ApiService.instance.dio.put(
        '/health-worker/appointments/$appointmentId/status',
        data: {'status': newStatus, if (reason != null) 'reason': reason},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Appointment status updated to ${newStatus.toLowerCase()}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
        // Refresh details
        await _loadAppointmentDetails();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointmentDetails,
          ),
        ],
      ),
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
    if (_appointmentDetails.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildClientCard(),
          const SizedBox(height: 16),
          _buildAppointmentInfoCard(),
          const SizedBox(height: 16),
          _buildHealthWorkerCard(),
          const SizedBox(height: 16),
          _buildFacilityCard(),
          const SizedBox(height: 16),
          _buildNotesCard(),
          const SizedBox(height: 16),
          _buildTimelineCard(),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _appointmentDetails['status'] ?? 'UNKNOWN';
    final statusInfo = _getStatusInfo(status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusInfo['icon'], color: statusInfo['color'], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Appointment Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusInfo['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: statusInfo['color'], width: 1.5),
              ),
              child: Text(
                statusInfo['displayName'],
                style: TextStyle(
                  color: statusInfo['color'],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (statusInfo['description'] != null) ...[
              const SizedBox(height: 12),
              Text(
                statusInfo['description'],
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return {
          'displayName': 'Scheduled',
          'color': AppColors.info,
          'icon': Icons.schedule,
          'description': 'Appointment is scheduled and awaiting confirmation',
        };
      case 'CONFIRMED':
        return {
          'displayName': 'Confirmed',
          'color': AppColors.success,
          'icon': Icons.check_circle,
          'description': 'Appointment has been confirmed by health worker',
        };
      case 'IN_PROGRESS':
        return {
          'displayName': 'In Progress',
          'color': AppColors.warning,
          'icon': Icons.play_circle,
          'description': 'Appointment is currently in progress',
        };
      case 'COMPLETED':
        return {
          'displayName': 'Completed',
          'color': AppColors.success,
          'icon': Icons.check_circle_outline,
          'description': 'Appointment has been completed successfully',
        };
      case 'CANCELLED':
        return {
          'displayName': 'Cancelled',
          'color': AppColors.error,
          'icon': Icons.cancel,
          'description': 'Appointment has been cancelled',
        };
      case 'NO_SHOW':
        return {
          'displayName': 'No Show',
          'color': Colors.grey,
          'icon': Icons.person_off,
          'description': 'Client did not show up for the appointment',
        };
      case 'RESCHEDULED':
        return {
          'displayName': 'Rescheduled',
          'color': AppColors.warning,
          'icon': Icons.update,
          'description': 'Appointment has been rescheduled',
        };
      default:
        return {
          'displayName': 'Unknown',
          'color': Colors.grey,
          'icon': Icons.help,
          'description': null,
        };
    }
  }

  Widget _buildClientCard() {
    final client = _appointmentDetails['client'];
    if (client == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Client Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', client['name'] ?? 'N/A'),
            _buildInfoRow('Email', client['email'] ?? 'N/A'),
            _buildInfoRow('Phone', client['phone'] ?? 'N/A'),
            _buildInfoRow('Village', client['village'] ?? 'N/A'),
            if (client['dateOfBirth'] != null)
              _buildInfoRow(
                'Date of Birth',
                _formatDate(client['dateOfBirth']),
              ),
            if (client['gender'] != null)
              _buildInfoRow('Gender', client['gender']),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Appointment Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Date & Time',
              _formatDateTime(_appointmentDetails['scheduledDate']),
            ),
            _buildInfoRow(
              'Type',
              _formatAppointmentType(_appointmentDetails['appointmentType']),
            ),
            _buildInfoRow(
              'Duration',
              '${_appointmentDetails['durationMinutes'] ?? 30} minutes',
            ),
            if (_appointmentDetails['reason'] != null)
              _buildInfoRow('Reason', _appointmentDetails['reason']),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthWorkerCard() {
    final healthWorker = _appointmentDetails['healthWorker'];
    if (healthWorker == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Health Worker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', healthWorker['name'] ?? 'N/A'),
            _buildInfoRow('Email', healthWorker['email'] ?? 'N/A'),
            _buildInfoRow('Phone', healthWorker['phone'] ?? 'N/A'),
            if (healthWorker['specialization'] != null)
              _buildInfoRow('Specialization', healthWorker['specialization']),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard() {
    final facility = _appointmentDetails['facility'];
    if (facility == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Health Facility',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', facility['name'] ?? 'N/A'),
            _buildInfoRow('Address', facility['address'] ?? 'N/A'),
            _buildInfoRow('Phone', facility['phone'] ?? 'N/A'),
            _buildInfoRow('Type', facility['type'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    final notes = _appointmentDetails['notes'];
    final reason = _appointmentDetails['reason'];

    if (notes == null && reason == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Notes & Reason',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (reason != null) ...[
              const Text(
                'Reason for Visit:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(reason, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
            ],
            if (notes != null) ...[
              const Text(
                'Additional Notes:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(notes, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    final timeline = _appointmentDetails['timeline'] as List<dynamic>? ?? [];

    if (timeline.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Appointment Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...timeline.map((event) => _buildTimelineItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['event'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (event['description'] != null)
                  Text(
                    event['description'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                if (event['timestamp'] != null)
                  Text(
                    _formatDateTime(event['timestamp']),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime.toString());
      return _fullDateFormatter.format(dt);
    } catch (e) {
      return dateTime.toString();
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(date.toString());
      return _dateFormatter.format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatAppointmentType(dynamic type) {
    if (type == null) return 'N/A';
    return type
        .toString()
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
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
        _appointmentDetails['status']?.toString().toUpperCase() ?? '';

    // Don't show actions for final states
    if (currentStatus == 'COMPLETED' ||
        currentStatus == 'CANCELLED' ||
        currentStatus == 'NO_SHOW') {
      return const SizedBox.shrink();
    }

    List<Widget> buttons = [];

    // Confirm button for scheduled appointments
    if (currentStatus == 'SCHEDULED') {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => _showConfirmDialog(
                  'Confirm Appointment',
                  'Confirm this appointment with the client?',
                  'CONFIRMED',
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    // Complete button for confirmed/in-progress appointments
    if (currentStatus == 'CONFIRMED' || currentStatus == 'IN_PROGRESS') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => _showConfirmDialog(
                  'Complete Appointment',
                  'Mark this appointment as completed?',
                  'COMPLETED',
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
      );
    }

    // Cancel button (always available for non-final states)
    if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
    buttons.add(
      Expanded(
        child: OutlinedButton(
          onPressed: () => _showCancelDialog(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Cancel'),
        ),
      ),
    );

    // No Show button for scheduled/confirmed appointments
    if (currentStatus == 'SCHEDULED' || currentStatus == 'CONFIRMED') {
      buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed:
                () => _showConfirmDialog(
                  'Mark as No Show',
                  'Mark this appointment as no show? The client did not attend.',
                  'NO_SHOW',
                ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('No Show'),
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Row(children: buttons)],
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

  void _showCancelDialog() {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to cancel this appointment?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for cancellation (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Appointment'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateAppointmentStatus(
                    'CANCELLED',
                    reason: reasonController.text.trim(),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Cancel Appointment'),
              ),
            ],
          ),
    );
  }
}
