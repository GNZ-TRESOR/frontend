import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/loading_overlay.dart';

class TimeSlotsManagementScreen extends ConsumerStatefulWidget {
  const TimeSlotsManagementScreen({super.key});

  @override
  ConsumerState<TimeSlotsManagementScreen> createState() =>
      _TimeSlotsManagementScreenState();
}

class _TimeSlotsManagementScreenState
    extends ConsumerState<TimeSlotsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Time slots data
  List<Map<String, dynamic>> _timeSlots = [];
  List<Map<String, dynamic>> _availableSlots = [];
  List<Map<String, dynamic>> _bookedSlots = [];

  // Selected date for viewing/managing slots
  DateTime _selectedDate = DateTime.now();

  // Form controllers for creating new time slots
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _maxPatientsController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTimeSlots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _durationController.dispose();
    _maxPatientsController.dispose();
    super.dispose();
  }

  Future<void> _loadTimeSlots() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() => _isLoading = true);

    try {
      // Load time slots for the selected date
      final response = await ApiService.instance.dio.get(
        '/health-worker/${user!.id}/time-slots',
        queryParameters: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _timeSlots = List<Map<String, dynamic>>.from(data['timeSlots'] ?? []);
          _availableSlots =
              _timeSlots
                  .where(
                    (slot) =>
                        slot['status'] == 'AVAILABLE' || slot['status'] == null,
                  )
                  .toList();
          _bookedSlots =
              _timeSlots.where((slot) => slot['status'] == 'BOOKED').toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading time slots: $e');
      // Show mock data for development
      _loadMockTimeSlots();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMockTimeSlots() {
    // Mock data for development
    final mockSlots = [
      {
        'id': 1,
        'startTime': '09:00',
        'endTime': '09:30',
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'status': 'AVAILABLE',
        'maxPatients': 1,
        'currentPatients': 0,
      },
      {
        'id': 2,
        'startTime': '09:30',
        'endTime': '10:00',
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'status': 'BOOKED',
        'maxPatients': 1,
        'currentPatients': 1,
        'patientName': 'Grace Mukamana',
      },
      {
        'id': 3,
        'startTime': '10:00',
        'endTime': '10:30',
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'status': 'AVAILABLE',
        'maxPatients': 1,
        'currentPatients': 0,
      },
    ];

    setState(() {
      _timeSlots = mockSlots;
      _availableSlots =
          mockSlots.where((slot) => slot['status'] == 'AVAILABLE').toList();
      _bookedSlots =
          mockSlots.where((slot) => slot['status'] == 'BOOKED').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Slots Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateSlotDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Time Slot',
          ),
          IconButton(
            onPressed: _showBulkCreateDialog,
            icon: const Icon(Icons.add_box),
            tooltip: 'Bulk Create Slots',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Slots'),
            Tab(text: 'Available'),
            Tab(text: 'Booked'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllSlotsTab(),
                  _buildAvailableSlotsTab(),
                  _buildBookedSlotsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Date',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(onPressed: _selectDate, child: const Text('Change')),
        ],
      ),
    );
  }

  Widget _buildAllSlotsTab() {
    return RefreshIndicator(
      onRefresh: _loadTimeSlots,
      child:
          _timeSlots.isEmpty
              ? _buildEmptyState('No time slots found for this date')
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = _timeSlots[index];
                  return _buildTimeSlotCard(slot);
                },
              ),
    );
  }

  Widget _buildAvailableSlotsTab() {
    return RefreshIndicator(
      onRefresh: _loadTimeSlots,
      child:
          _availableSlots.isEmpty
              ? _buildEmptyState('No available slots for this date')
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = _availableSlots[index];
                  return _buildTimeSlotCard(slot);
                },
              ),
    );
  }

  Widget _buildBookedSlotsTab() {
    return RefreshIndicator(
      onRefresh: _loadTimeSlots,
      child:
          _bookedSlots.isEmpty
              ? _buildEmptyState('No booked slots for this date')
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookedSlots.length,
                itemBuilder: (context, index) {
                  final slot = _bookedSlots[index];
                  return _buildTimeSlotCard(slot);
                },
              ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateSlotDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Time Slot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    final isBooked = slot['status'] == 'BOOKED';
    final isAvailable = slot['status'] == 'AVAILABLE' || slot['status'] == null;

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
                    color:
                        isBooked
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isBooked ? Icons.event_busy : Icons.event_available,
                    color: isBooked ? AppColors.error : AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot['startTime']} - ${slot['endTime']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isBooked ? 'Booked' : 'Available',
                        style: TextStyle(
                          color: isBooked ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleSlotAction(value, slot),
                  itemBuilder:
                      (context) => [
                        if (isAvailable) ...[
                          const PopupMenuItem(
                            value: 'book',
                            child: Row(
                              children: [
                                Icon(Icons.book_online),
                                SizedBox(width: 8),
                                Text('Book Slot'),
                              ],
                            ),
                          ),
                        ],
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
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            if (isBooked && slot['patientName'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Patient: ${slot['patientName']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  'Duration: ${_calculateDuration(slot['startTime'], slot['endTime'])} min',
                  Icons.timer,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  'Capacity: ${slot['currentPatients'] ?? 0}/${slot['maxPatients'] ?? 1}',
                  Icons.people,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  int _calculateDuration(String startTime, String endTime) {
    try {
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]),
      );

      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      return endMinutes - startMinutes;
    } catch (e) {
      return 30; // Default duration
    }
  }

  // Action handlers
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTimeSlots();
    }
  }

  void _handleSlotAction(String action, Map<String, dynamic> slot) {
    switch (action) {
      case 'book':
        _showBookSlotDialog(slot);
        break;
      case 'edit':
        _showEditSlotDialog(slot);
        break;
      case 'delete':
        _showDeleteConfirmation(slot);
        break;
    }
  }

  void _showCreateSlotDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Time Slot'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      hintText: 'HH:MM (e.g., 09:00)',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(_startTimeController),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      hintText: 'HH:MM (e.g., 09:30)',
                      prefixIcon: Icon(Icons.access_time_filled),
                    ),
                    onTap: () => _selectTime(_endTimeController),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxPatientsController,
                    decoration: const InputDecoration(
                      labelText: 'Max Patients',
                      hintText: '1',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
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
                onPressed: _createTimeSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showBulkCreateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bulk Create Time Slots'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      hintText: 'HH:MM (e.g., 09:00)',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(_startTimeController),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      hintText: 'HH:MM (e.g., 17:00)',
                      prefixIcon: Icon(Icons.access_time_filled),
                    ),
                    onTap: () => _selectTime(_endTimeController),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Slot Duration (minutes)',
                      hintText: '30',
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxPatientsController,
                    decoration: const InputDecoration(
                      labelText: 'Max Patients per Slot',
                      hintText: '1',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
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
                onPressed: _createBulkTimeSlots,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Slots'),
              ),
            ],
          ),
    );
  }

  void _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  void _createTimeSlot() async {
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
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
        '/health-worker/${user!.id}/time-slots',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'maxPatients': int.tryParse(_maxPatientsController.text) ?? 1,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearControllers();
      _loadTimeSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create time slot: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createBulkTimeSlots() async {
    if (_startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _durationController.text.isEmpty) {
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
        '/health-worker/${user!.id}/time-slots/bulk',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'duration': int.tryParse(_durationController.text) ?? 30,
          'maxPatients': int.tryParse(_maxPatientsController.text) ?? 1,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slots created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearControllers();
      _loadTimeSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create time slots: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBookSlotDialog(Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Book Time Slot'),
            content: Text(
              'Would you like to book the time slot ${slot['startTime']} - ${slot['endTime']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _bookTimeSlot(slot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Book'),
              ),
            ],
          ),
    );
  }

  void _showEditSlotDialog(Map<String, dynamic> slot) {
    _startTimeController.text = slot['startTime'] ?? '';
    _endTimeController.text = slot['endTime'] ?? '';
    _maxPatientsController.text = (slot['maxPatients'] ?? 1).toString();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Time Slot'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(_startTimeController),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      prefixIcon: Icon(Icons.access_time_filled),
                    ),
                    onTap: () => _selectTime(_endTimeController),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxPatientsController,
                    decoration: const InputDecoration(
                      labelText: 'Max Patients',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
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
                  _updateTimeSlot(slot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Time Slot'),
            content: Text(
              'Are you sure you want to delete the time slot ${slot['startTime']} - ${slot['endTime']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteTimeSlot(slot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _bookTimeSlot(Map<String, dynamic> slot) async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      await ApiService.instance.dio.post(
        '/health-worker/${user!.id}/time-slots/${slot['id']}/book',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot booked successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _loadTimeSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book time slot: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateTimeSlot(Map<String, dynamic> slot) async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      await ApiService.instance.dio.put(
        '/health-worker/${user!.id}/time-slots/${slot['id']}',
        data: {
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'maxPatients': int.tryParse(_maxPatientsController.text) ?? 1,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _clearControllers();
      _loadTimeSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update time slot: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteTimeSlot(Map<String, dynamic> slot) async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      await ApiService.instance.dio.delete(
        '/health-worker/${user!.id}/time-slots/${slot['id']}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time slot deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _loadTimeSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete time slot: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearControllers() {
    _startTimeController.clear();
    _endTimeController.clear();
    _durationController.text = '30';
    _maxPatientsController.text = '1';
  }
}
