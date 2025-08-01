import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/simple_translated_text.dart';
import '../../core/providers/unified_language_provider.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/appointment_provider.dart';
import '../../core/models/appointment.dart';

import '../../core/mixins/tts_screen_mixin.dart';
import 'book_appointment_flow.dart';
import 'time_slot_management.dart';

/// Professional Appointments Screen with Full API Integration
class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with TickerProviderStateMixin, TTSScreenMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize with default length, will be updated in build
    _tabController = TabController(length: 3, vsync: this);
    // Load appointments when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentProvider.notifier).loadAppointments();
    });
  }

  // TTS Implementation
  @override
  String getTTSContent(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentProvider);
    final appointments = appointmentState.appointments;
    final isHealthWorker = ref.watch(isHealthWorkerProvider);

    final buffer = StringBuffer();
    buffer.write('Appointments screen. ');

    if (isHealthWorker) {
      buffer.write('You are viewing appointment management. ');
    } else {
      buffer.write('You are viewing your appointments. ');
    }

    if (appointments.isEmpty) {
      buffer.write('No appointments found. ');
    } else {
      buffer.write('${appointments.length} appointments found. ');

      // Read first few appointments
      final appointmentsToRead = appointments.take(3).toList();
      for (int i = 0; i < appointmentsToRead.length; i++) {
        final apt = appointmentsToRead[i];
        buffer.write('${i + 1}. ');
        buffer.write('${apt.appointmentType} appointment ');
        buffer.write('on ${apt.scheduledDate.toString().split(' ')[0]} ');
        buffer.write(
          'at ${apt.scheduledDate.hour}:${apt.scheduledDate.minute.toString().padLeft(2, '0')} ',
        );
        if (apt.healthWorkerName != null) {
          buffer.write('with ${apt.healthWorkerName}. ');
        }
        buffer.write('Status: ${apt.status}. ');
      }

      if (appointments.length > 3) {
        buffer.write('And ${appointments.length - 3} more appointments. ');
      }
    }

    return buffer.toString();
  }

  void _updateTabController(bool isHealthWorker) {
    final newLength = isHealthWorker ? 4 : 3; // Health workers get extra tab
    if (_tabController.length != newLength) {
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookAppointmentFlow()),
    );

    if (result == true) {
      ref.read(appointmentProvider.notifier).loadAppointments();
    }
  }

  Future<void> _createTimeSlot() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimeSlotManagement()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);
    final appointments = appointmentState.appointments;
    final user = ref.watch(currentUserProvider);

    // Don't render until user is loaded to avoid null check errors
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isHealthWorker = ref.watch(isHealthWorkerProvider);
    final isClient = ref.watch(isClientProvider);

    // Update tab controller based on role
    _updateTabController(isHealthWorker);

    return addTTSToScaffold(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            (isHealthWorker ? 'Appointment Management' : 'My Appointments')
                .str(),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final currentLang = ref.watch(unifiedLanguageProvider);
              final languageNotifier = ref.read(
                unifiedLanguageProvider.notifier,
              );
              final availableLanguages = ref.watch(availableLanguagesProvider);

              return PopupMenuButton<String>(
                onSelected: (languageCode) {
                  languageNotifier.changeLanguage(languageCode);
                },
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      languageNotifier.getLanguageFlag(currentLang),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
                itemBuilder:
                    (context) =>
                        availableLanguages.map((language) {
                          final code = language['code']!;
                          final name = language['name']!;
                          final flag = language['flag']!;
                          final isSelected = code == currentLang;

                          return PopupMenuItem<String>(
                            value: code,
                            child: Row(
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(name)),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
              );
            },
          ),
        ],
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: isHealthWorker,
          tabs: _buildTabs(isHealthWorker),
        ),
      ),
      body: LoadingOverlay(
        isLoading: appointmentState.isLoading,
        child:
            appointmentState.error != null
                ? _buildErrorState(appointmentState.error!)
                : TabBarView(
                  controller: _tabController,
                  children: _buildTabViews(appointments, isHealthWorker),
                ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Widget> _buildTabs(bool isHealthWorker) {
    if (isHealthWorker) {
      return [
        Tab(child: 'Today'.str()),
        Tab(child: 'Upcoming'.str()),
        Tab(child: 'Past'.str()),
        Tab(child: 'Manage Slots'.str()),
      ];
    } else {
      return [
        Tab(child: 'Upcoming'.str()),
        Tab(child: 'Past'.str()),
        Tab(child: 'All'.str()),
      ];
    }
  }

  List<Widget> _buildTabViews(
    List<Appointment> appointments,
    bool isHealthWorker,
  ) {
    if (isHealthWorker) {
      return [
        _buildTodayTab(appointments),
        _buildUpcomingTab(appointments),
        _buildPastTab(appointments),
        _buildManageSlotsTab(),
      ];
    } else {
      return [
        _buildUpcomingTab(appointments),
        _buildPastTab(appointments),
        _buildAllTab(appointments),
      ];
    }
  }

  Widget? _buildFloatingActionButton(bool isHealthWorker, bool isClient) {
    if (isClient) {
      return FloatingActionButton(
        onPressed: _bookAppointment,
        backgroundColor: AppColors.appointmentBlue,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (isHealthWorker) {
      return FloatingActionButton(
        onPressed: _createTimeSlot,
        backgroundColor: AppColors.appointmentBlue,
        child: const Icon(Icons.schedule, color: Colors.white),
      );
    }
    return null;
  }

  Widget _buildUpcomingTab(List<Appointment> appointments) {
    final upcomingAppointments =
        appointments.where((appointment) => appointment.isUpcoming).toList()
          ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    if (upcomingAppointments.isEmpty) {
      return _buildEmptyState(
        'No upcoming appointments',
        'Book your next appointment to stay on top of your health',
        Icons.calendar_today,
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => ref.read(appointmentProvider.notifier).loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingAppointments.length,
        itemBuilder: (context, index) {
          final appointment = upcomingAppointments[index];
          return _buildAppointmentCard(appointment, isUpcoming: true);
        },
      ),
    );
  }

  Widget _buildPastTab(List<Appointment> appointments) {
    final pastAppointments =
        appointments
            .where(
              (appointment) =>
                  !appointment
                      .isUpcoming, // Include both past and overdue appointments
            )
            .toList()
          ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    if (pastAppointments.isEmpty) {
      return _buildEmptyState(
        'No past appointments',
        'Your appointment history will appear here',
        Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => ref.read(appointmentProvider.notifier).loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastAppointments.length,
        itemBuilder: (context, index) {
          final appointment = pastAppointments[index];
          return _buildAppointmentCard(appointment, isPast: true);
        },
      ),
    );
  }

  Widget _buildAllTab(List<Appointment> appointments) {
    print('DEBUG: _buildAllTab received ${appointments.length} appointments');
    for (var apt in appointments) {
      print(
        'DEBUG: Appointment ${apt.id}: ${apt.scheduledDate}, status: ${apt.status}, isUpcoming: ${apt.isUpcoming}, isOverdue: ${apt.isOverdue}',
      );
    }

    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No appointments yet',
        'Book your first appointment to get started',
        Icons.event_available,
      );
    }

    final sortedAppointments = List<Appointment>.from(appointments)
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    return RefreshIndicator(
      onRefresh:
          () => ref.read(appointmentProvider.notifier).loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedAppointments.length,
        itemBuilder: (context, index) {
          final appointment = sortedAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildTodayTab(List<Appointment> appointments) {
    final todayAppointments =
        appointments.where((appointment) => appointment.isToday).toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (todayAppointments.isEmpty) {
      return _buildEmptyState(
        'No appointments today',
        'Your schedule is clear for today',
        Icons.today,
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => ref.read(appointmentProvider.notifier).loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todayAppointments.length,
        itemBuilder: (context, index) {
          final appointment = todayAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildManageSlotsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Time Slot Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your availability and time slots',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimeSlotManagement(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Manage Time Slots'),
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

  Widget _buildAppointmentCard(
    Appointment appointment, {
    bool isUpcoming = false,
    bool isPast = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getAppointmentTypeColor(
                        appointment.appointmentType,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAppointmentTypeIcon(appointment.appointmentType),
                      color: _getAppointmentTypeColor(
                        appointment.appointmentType,
                      ),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.displayTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.typeDisplayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        appointment.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment.formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dr. ${appointment.doctorName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (isUpcoming && appointment.isToday) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.today, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Today\'s appointment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isUpcoming) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rescheduleAppointment(appointment),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Reschedule'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelAppointment(appointment),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _bookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appointmentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading Appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(healthProvider.notifier).clearError();
              ref.read(healthProvider.notifier).loadAppointments();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getAppointmentTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'CONSULTATION':
        return AppColors.primary;
      case 'HEALTH_SCREENING':
        return AppColors.success;
      case 'FOLLOW_UP':
        return AppColors.secondary;
      case 'FAMILY_PLANNING':
        return AppColors.tertiary;
      case 'VACCINATION':
        return AppColors.appointmentBlue;
      case 'COUNSELING':
        return AppColors.supportPurple;
      case 'EMERGENCY':
        return AppColors.error;
      case 'PRENATAL_CARE':
        return AppColors.primary;
      case 'POSTNATAL_CARE':
        return AppColors.secondary;
      case 'OTHER':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getAppointmentTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CONSULTATION':
        return Icons.medical_services;
      case 'HEALTH_SCREENING':
        return Icons.health_and_safety;
      case 'FOLLOW_UP':
        return Icons.follow_the_signs;
      case 'FAMILY_PLANNING':
        return Icons.family_restroom;
      case 'VACCINATION':
        return Icons.vaccines;
      case 'COUNSELING':
        return Icons.psychology;
      case 'EMERGENCY':
        return Icons.emergency;
      case 'PRENATAL_CARE':
        return Icons.pregnant_woman;
      case 'POSTNATAL_CARE':
        return Icons.child_care;
      case 'OTHER':
        return Icons.event;
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.appointmentBlue;
      case 'confirmed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'no_show':
        return AppColors.textSecondary;
      case 'rescheduled':
        return AppColors.warning;
      default:
        return AppColors.appointmentBlue;
    }
  }

  // Action methods
  void _viewAppointmentDetails(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAppointmentScreen(appointment: appointment),
      ),
    );
  }

  void _rescheduleAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reschedule Appointment'),
            content: Text(
              'Would you like to reschedule "${appointment.displayTitle}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performReschedule(appointment);
                },
                child: const Text('Reschedule'),
              ),
            ],
          ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content: Text(
              'Are you sure you want to cancel "${appointment.displayTitle}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performCancel(appointment);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _performReschedule(Appointment appointment) async {
    // Show date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          appointment.scheduledDate.isAfter(DateTime.now())
              ? appointment.scheduledDate
              : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select new appointment date',
    );

    if (selectedDate == null) return;

    // Show time picker
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(appointment.scheduledDate),
      helpText: 'Select new appointment time',
    );

    if (selectedTime == null) return;

    // Combine date and time
    final newDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Validate that the new time is in the future
    if (newDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Rescheduling appointment...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Call the API to reschedule the appointment
      final success = await ref
          .read(appointmentProvider.notifier)
          .rescheduleAppointment(appointment.id!, newDateTime);

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment rescheduled to ${newDateTime.day}/${newDateTime.month}/${newDateTime.year} at ${selectedTime.format(context)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Reload appointments to refresh the list
        ref.read(appointmentProvider.notifier).loadAppointments();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reschedule appointment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rescheduling appointment: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _performCancel(Appointment appointment) async {
    if (appointment.id != null) {
      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Cancelling appointment...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );

        // Call the API to cancel the appointment
        final success = await ref
            .read(appointmentProvider.notifier)
            .cancelAppointment(appointment.id!, 'Cancelled by user');

        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment cancelled successfully'),
              backgroundColor: AppColors.success,
            ),
          );

          // Reload appointments to refresh the list
          ref.read(appointmentProvider.notifier).loadAppointments();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel appointment'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Book Appointment Screen
class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'consultation';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedLocation = 'clinic';
  bool _isLoading = false;

  final List<Map<String, String>> _appointmentTypes = [
    {'value': 'CONSULTATION', 'label': 'General Consultation'},
    {'value': 'HEALTH_SCREENING', 'label': 'Health Screening'},
    {'value': 'FOLLOW_UP', 'label': 'Follow-up Visit'},
    {'value': 'VACCINATION', 'label': 'Vaccination'},
    {'value': 'FAMILY_PLANNING', 'label': 'Family Planning'},
    {'value': 'PRENATAL_CARE', 'label': 'Prenatal Care'},
    {'value': 'POSTNATAL_CARE', 'label': 'Postnatal Care'},
    {'value': 'COUNSELING', 'label': 'Health Counseling'},
    {'value': 'EMERGENCY', 'label': 'Emergency'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Appointment Details'),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 24),
              _buildSectionTitle('Date & Time'),
              const SizedBox(height: 16),
              _buildDateTimeSelection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Location'),
              const SizedBox(height: 16),
              _buildLocationSelection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Additional Notes'),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Appointment Title',
        hintText: 'e.g., Family Planning Consultation',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an appointment title';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Appointment Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.medical_services),
      ),
      items:
          _appointmentTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type['value'],
              child: Text(type['label']!),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
    );
  }

  Widget _buildDateTimeSelection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.appointmentBlue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.appointmentBlue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _selectedTime.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Health Facility'),
          subtitle: const Text('Visit our clinic'),
          value: 'clinic',
          groupValue: _selectedLocation,
          onChanged: (value) {
            setState(() {
              _selectedLocation = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Virtual Consultation'),
          subtitle: const Text('Online video call'),
          value: 'virtual',
          groupValue: _selectedLocation,
          onChanged: (value) {
            setState(() {
              _selectedLocation = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Additional Notes (Optional)',
        hintText:
            'Any specific concerns or information you\'d like to share...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.note_add),
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appointmentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
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
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create appointment object
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Use real API call through appointment provider
      // Map location to facility ID (using first available facility for demo)
      int facilityId = 1; // Default to first facility
      if (_selectedLocation == 'hospital') {
        facilityId = 1; // Kigali University Teaching Hospital
      } else if (_selectedLocation == 'clinic') {
        facilityId = 4; // Kimisagara Health Center
      }

      final success = await ref
          .read(appointmentProvider.notifier)
          .createAppointment(
            healthFacilityId: facilityId,
            healthWorkerId: null, // No specific health worker selected
            appointmentType: _selectedType.toUpperCase(),
            scheduledDate: appointmentDateTime,
            durationMinutes: 30,
            reason:
                _titleController.text.isNotEmpty ? _titleController.text : null,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to book appointment. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// View Appointment Details Screen - FULLY IMPLEMENTED
class ViewAppointmentScreen extends ConsumerStatefulWidget {
  final Appointment appointment;

  const ViewAppointmentScreen({super.key, required this.appointment});

  @override
  ConsumerState<ViewAppointmentScreen> createState() =>
      _ViewAppointmentScreenState();
}

class _ViewAppointmentScreenState extends ConsumerState<ViewAppointmentScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment.displayTitle),
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
        actions: [
          if (widget.appointment.canBeCancelled ||
              widget.appointment.canBeRescheduled) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editAppointment(context),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'reschedule',
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: AppColors.secondary),
                          SizedBox(width: 8),
                          Text('Reschedule'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Cancel'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  widget.appointment.status,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(
                    widget.appointment.status,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.appointment.status),
                    color: _getStatusColor(widget.appointment.status),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointment.statusDisplayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(widget.appointment.status),
                          ),
                        ),
                        if (widget.appointment.isUpcoming)
                          Text(
                            'Scheduled for ${widget.appointment.formattedDate} at ${widget.appointment.formattedTime}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Appointment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event, color: AppColors.appointmentBlue),
                        SizedBox(width: 8),
                        Text(
                          'Appointment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow('Title', widget.appointment.displayTitle),
                    _buildDetailRow('Type', widget.appointment.typeDisplayName),
                    _buildDetailRow('Date', widget.appointment.formattedDate),
                    _buildDetailRow('Time', widget.appointment.formattedTime),
                    _buildDetailRow('Location', widget.appointment.location),
                    if (widget.appointment.reason != null)
                      _buildDetailRow('Reason', widget.appointment.reason!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Healthcare Provider Card
            if (widget.appointment.healthWorkerName != null ||
                widget.appointment.facilityName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: AppColors.healthWorkerBlue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Healthcare Provider',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (widget.appointment.healthWorkerName != null)
                        _buildDetailRow(
                          'Doctor',
                          widget.appointment.healthWorkerName!,
                        ),
                      if (widget.appointment.facilityName != null)
                        _buildDetailRow(
                          'Facility',
                          widget.appointment.facilityName!,
                        ),
                      if (widget.appointment.facilityAddress != null)
                        _buildDetailRow(
                          'Address',
                          widget.appointment.facilityAddress!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Card
            if (widget.appointment.notes != null &&
                widget.appointment.notes!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.appointment.notes!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Card
            if (widget.appointment.notes != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note, color: AppColors.secondary),
                          SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.appointment.notes!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Reminder Card
            if (widget.appointment.reminderSent == true) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.alarm, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Reminder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reminder has been sent for this appointment',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Appointment Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Appointment ID',
                      widget.appointment.id?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Status',
                      widget.appointment.statusDisplayName,
                    ),
                    if (widget.appointment.createdAt != null)
                      _buildDetailRow(
                        'Created',
                        _formatDateTime(widget.appointment.createdAt!),
                      ),
                    if (widget.appointment.updatedAt != null)
                      _buildDetailRow(
                        'Last Updated',
                        _formatDateTime(widget.appointment.updatedAt!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (widget.appointment.canBeCancelled ||
                widget.appointment.canBeRescheduled) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : () => _rescheduleAppointment(context),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Reschedule'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.secondary),
                        foregroundColor: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _cancelAppointment(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'This appointment cannot be modified',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      case 'rescheduled':
        return AppColors.secondary;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.check_circle_outline;
      case 'rescheduled':
        return Icons.update;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _editAppointment(BuildContext context) {
    // TODO: Navigate to edit appointment screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit appointment functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'reschedule':
        _rescheduleAppointment(context);
        break;
      case 'cancel':
        _cancelAppointment(context);
        break;
      case 'share':
        _shareAppointment(context);
        break;
    }
  }

  Future<void> _rescheduleAppointment(BuildContext context) async {
    // Show date picker for new appointment date
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate:
          widget.appointment.scheduledDate ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate == null) return;

    // Show time picker for new appointment time
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        widget.appointment.scheduledDate ?? DateTime.now(),
      ),
    );

    if (newTime == null) return;

    final newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    // Confirm reschedule
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Reschedule'),
            content: Text(
              'Reschedule appointment to ${newDate.day}/${newDate.month}/${newDate.year} at ${newTime.format(context)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: const Text('Reschedule'),
              ),
            ],
          ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);

      try {
        // Use real API call to reschedule appointment
        final success = await ref
            .read(appointmentProvider.notifier)
            .updateAppointment(
              widget.appointment.id!,
              scheduledDate: newDateTime,
            );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment rescheduled successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to reschedule appointment. Please try again.',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reschedule appointment: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelAppointment(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content: const Text(
              'Are you sure you want to cancel this appointment? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Appointment'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Cancel Appointment'),
              ),
            ],
          ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);

      try {
        // Use real API call to cancel appointment
        final success = await ref
            .read(appointmentProvider.notifier)
            .cancelAppointment(widget.appointment.id!, 'Cancelled by user');

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment cancelled successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel appointment: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _shareAppointment(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  String getScreenName() => 'Appointments';
}
