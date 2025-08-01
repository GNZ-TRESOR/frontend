import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/time_slot.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/appointment_provider.dart';
import '../../core/widgets/loading_overlay.dart';

/// Time Slot Management Screen for Health Workers
class TimeSlotManagement extends ConsumerStatefulWidget {
  const TimeSlotManagement({super.key});

  @override
  ConsumerState<TimeSlotManagement> createState() => _TimeSlotManagementState();
}

class _TimeSlotManagementState extends ConsumerState<TimeSlotManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load time slots when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeSlots();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTimeSlots() {
    final user = ref.read(currentUserProvider);
    if (user?.role == 'HEALTH_WORKER') {
      ref
          .read(appointmentProvider.notifier)
          .loadTimeSlots(
            healthWorkerId: user!.id,
            date: _formatDateForApi(_selectedDate),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final appointmentState = ref.watch(appointmentProvider);
    final timeSlots = appointmentState.timeSlots;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Time Slots'),
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'All Slots'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showCreateTimeSlotDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Create Time Slot',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || appointmentState.isLoading,
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(),
                  _buildWeekTab(),
                  _buildAllSlotsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTimeSlotDialog,
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.schedule),
        label: const Text('Create Slot'),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.appointmentBlue),
          const SizedBox(width: 8),
          Text(
            'Selected Date: ${_formatDate(_selectedDate)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _selectDate,
            icon: const Icon(Icons.edit_calendar, size: 16),
            label: const Text('Change'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appointmentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return _buildTimeSlotsList(_getTodaySlots());
  }

  Widget _buildWeekTab() {
    return _buildTimeSlotsList(_getWeekSlots());
  }

  Widget _buildAllSlotsTab() {
    return _buildTimeSlotsList(_getAllSlots());
  }

  Widget _buildTimeSlotsList(List<TimeSlot> timeSlots) {
    if (timeSlots.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTimeSlots(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          final timeSlot = timeSlots[index];
          return _buildTimeSlotCard(timeSlot);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Time Slots',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create time slots to allow patients to book appointments',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateTimeSlotDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Time Slot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appointmentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot timeSlot) {
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        timeSlot.canBook
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    timeSlot.canBook ? Icons.schedule : Icons.schedule_outlined,
                    color:
                        timeSlot.canBook ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeSlot.formattedTimeRange,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        timeSlot.formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleTimeSlotAction(value, timeSlot),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
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
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(timeSlot.availabilityStatus, timeSlot.canBook),
                const SizedBox(width: 8),
                if (timeSlot.maxAppointments != null)
                  _buildInfoChip('Max: ${timeSlot.maxAppointments}'),
                const SizedBox(width: 8),
                if (timeSlot.currentAppointments != null)
                  _buildInfoChip('Booked: ${timeSlot.currentAppointments}'),
              ],
            ),
            if (timeSlot.reason != null && timeSlot.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${timeSlot.reason}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isAvailable
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isAvailable ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.appointmentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.appointmentBlue,
        ),
      ),
    );
  }

  // Filter time slots based on tab
  List<TimeSlot> _getTodaySlots() {
    final appointmentState = ref.read(appointmentProvider);
    final today = DateTime.now();
    return appointmentState.timeSlots.where((slot) {
      return slot.startTime.year == today.year &&
          slot.startTime.month == today.month &&
          slot.startTime.day == today.day;
    }).toList();
  }

  List<TimeSlot> _getWeekSlots() {
    final appointmentState = ref.read(appointmentProvider);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return appointmentState.timeSlots.where((slot) {
      return slot.startTime.isAfter(weekStart) &&
          slot.startTime.isBefore(weekEnd);
    }).toList();
  }

  List<TimeSlot> _getAllSlots() {
    final appointmentState = ref.read(appointmentProvider);
    return appointmentState.timeSlots;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
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

  void _showCreateTimeSlotDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateTimeSlotScreen(
              selectedDate: _selectedDate,
              onTimeSlotCreated: () {
                _loadTimeSlots();
              },
            ),
      ),
    );
  }

  void _handleTimeSlotAction(String action, TimeSlot timeSlot) {
    switch (action) {
      case 'edit':
        _editTimeSlot(timeSlot);
        break;
      case 'delete':
        _deleteTimeSlot(timeSlot);
        break;
    }
  }

  void _editTimeSlot(TimeSlot timeSlot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateTimeSlotScreen(
              selectedDate: timeSlot.startTime,
              existingTimeSlot: timeSlot,
              onTimeSlotCreated: () {
                _loadTimeSlots();
              },
            ),
      ),
    );
  }

  Future<void> _deleteTimeSlot(TimeSlot timeSlot) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Time Slot'),
            content: Text(
              'Are you sure you want to delete the time slot for ${timeSlot.formattedTimeRange}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (result == true) {
      setState(() => _isLoading = true);

      try {
        final success = await ref
            .read(appointmentProvider.notifier)
            .deleteTimeSlot(timeSlot.id!);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time slot deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete time slot'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          _loadTimeSlots();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
}

/// Create/Edit Time Slot Screen
class CreateTimeSlotScreen extends StatefulWidget {
  final DateTime selectedDate;
  final TimeSlot? existingTimeSlot;
  final VoidCallback onTimeSlotCreated;

  const CreateTimeSlotScreen({
    super.key,
    required this.selectedDate,
    this.existingTimeSlot,
    required this.onTimeSlotCreated,
  });

  @override
  State<CreateTimeSlotScreen> createState() => _CreateTimeSlotScreenState();
}

class _CreateTimeSlotScreenState extends State<CreateTimeSlotScreen> {
  // TODO: Implement create/edit time slot form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTimeSlot != null
              ? 'Edit Time Slot'
              : 'Create Time Slot',
        ),
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Time slot creation form coming soon')),
    );
  }
}
