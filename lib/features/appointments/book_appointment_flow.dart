import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/health_facility.dart';
import '../../core/models/health_worker.dart';
import '../../core/models/time_slot.dart';
import '../../core/providers/appointment_provider.dart';
import '../../core/services/health_facility_service.dart';
import '../../core/services/api_service.dart';

/// Enhanced Book Appointment Flow with Health Worker and Time Slot Selection
class BookAppointmentFlow extends ConsumerStatefulWidget {
  final HealthFacility? preSelectedFacility;
  final HealthWorker? preSelectedHealthWorker;

  const BookAppointmentFlow({
    super.key,
    this.preSelectedFacility,
    this.preSelectedHealthWorker,
  });

  @override
  ConsumerState<BookAppointmentFlow> createState() =>
      _BookAppointmentFlowState();
}

class _BookAppointmentFlowState extends ConsumerState<BookAppointmentFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Booking data
  HealthFacility? _selectedFacility;
  HealthWorker? _selectedHealthWorker;
  TimeSlot? _selectedTimeSlot;
  String _appointmentType = 'CONSULTATION';
  final String _reason = '';
  // final String _notes = '';

  // Data lists
  List<HealthFacility> _facilities = [];
  List<HealthWorker> _healthWorkers = [];
  List<TimeSlot> _timeSlots = [];

  // Loading states
  bool _isLoadingFacilities = false;
  bool _isLoadingHealthWorkers = false;
  bool _isLoadingTimeSlots = false;
  bool _isBooking = false;

  // Controllers
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Services
  late HealthFacilityService _healthFacilityService;

  final List<String> _stepTitles = [
    'Select Facility',
    'Choose Health Worker',
    'Pick Time Slot',
    'Appointment Details',
    'Confirm Booking',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFacility = widget.preSelectedFacility;
    _selectedHealthWorker = widget.preSelectedHealthWorker;

    // Initialize service
    _healthFacilityService = HealthFacilityService(ApiService.instance);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFacilities();
    });

    // Skip facility selection if pre-selected
    if (_selectedFacility != null) {
      _currentStep = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _loadHealthWorkers();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[_currentStep]),
        backgroundColor: AppColors.appointmentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildFacilitySelectionStep(),
                _buildHealthWorkerSelectionStep(),
                _buildTimeSlotSelectionStep(),
                _buildAppointmentDetailsStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.appointmentBlue.withOpacity(0.1),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color:
                    isActive
                        ? AppColors.appointmentBlue
                        : AppColors.appointmentBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFacilitySelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Health Facility',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the facility where you want to book your appointment',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildFacilityList()),
        ],
      ),
    );
  }

  Widget _buildHealthWorkerSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Health Worker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a health worker for your appointment',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildHealthWorkerList()),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Time Slots',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred appointment time',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildTimeSlotList()),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide additional information about your appointment',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildAppointmentDetailsForm()),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Appointment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your appointment details before booking',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildConfirmationDetails()),
        ],
      ),
    );
  }

  Widget _buildFacilityList() {
    if (_isLoadingFacilities) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_facilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Health Facilities Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFacilities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _facilities.length,
      itemBuilder: (context, index) {
        final facility = _facilities[index];
        final isSelected = _selectedFacility?.id == facility.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.appointmentBlue
                        : AppColors.appointmentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_hospital,
                color: isSelected ? Colors.white : AppColors.appointmentBlue,
                size: 24,
              ),
            ),
            title: Text(
              facility.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  facility.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  facility.facilityTypeDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.appointmentBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing:
                isSelected
                    ? Icon(Icons.check_circle, color: AppColors.appointmentBlue)
                    : null,
            onTap: () {
              setState(() {
                _selectedFacility = facility;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildHealthWorkerList() {
    if (_isLoadingHealthWorkers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_healthWorkers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Health Workers Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try selecting a different facility',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _healthWorkers.length,
      itemBuilder: (context, index) {
        final healthWorker = _healthWorkers[index];
        final isSelected = _selectedHealthWorker?.id == healthWorker.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  isSelected ? AppColors.appointmentBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.appointmentBlue.withOpacity(0.1),
              backgroundImage:
                  healthWorker.profileImageUrl != null
                      ? NetworkImage(healthWorker.profileImageUrl!)
                      : null,
              child:
                  healthWorker.profileImageUrl == null
                      ? Icon(
                        Icons.person,
                        color: AppColors.appointmentBlue,
                        size: 30,
                      )
                      : null,
            ),
            title: Text(
              healthWorker.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  healthWorker.specializationDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.appointmentBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (healthWorker.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        healthWorker.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (healthWorker.totalAppointments != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${healthWorker.totalAppointments} appointments',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
            trailing:
                isSelected
                    ? Icon(Icons.check_circle, color: AppColors.appointmentBlue)
                    : null,
            onTap: () {
              setState(() {
                _selectedHealthWorker = healthWorker;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotList() {
    if (_isLoadingTimeSlots) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_timeSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Time Slots Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try selecting a different date or health worker',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _timeSlots[index];
        final isSelected = _selectedTimeSlot?.id == timeSlot.id;
        final isAvailable = timeSlot.isAvailable ?? true;

        // Format time display
        final startTime = timeSlot.startTime;
        final endTime = timeSlot.endTime;
        String timeDisplay = 'Invalid Time';

        final startFormatted =
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        final endFormatted =
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
        timeDisplay = '$startFormatted - $endFormatted';

        return GestureDetector(
          onTap:
              isAvailable
                  ? () {
                    setState(() {
                      _selectedTimeSlot = timeSlot;
                    });
                  }
                  : null,
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.appointmentBlue.withOpacity(0.1)
                      : isAvailable
                      ? Colors.white
                      : Colors.grey.withOpacity(0.1),
              border: Border.all(
                color:
                    isSelected
                        ? AppColors.appointmentBlue
                        : isAvailable
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isAvailable
                            ? (isSelected
                                ? AppColors.appointmentBlue
                                : AppColors.textPrimary)
                            : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isAvailable
                            ? (isSelected
                                ? AppColors.appointmentBlue
                                : AppColors.textSecondary)
                            : Colors.grey,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.appointmentBlue,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentDetailsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Facility',
                    _selectedFacility?.name ?? 'Not selected',
                  ),
                  _buildSummaryRow(
                    'Health Worker',
                    _selectedHealthWorker?.name ?? 'Not selected',
                  ),
                  _buildSummaryRow(
                    'Date & Time',
                    _selectedTimeSlot != null
                        ? '${_selectedTimeSlot!.formattedDate} at ${_selectedTimeSlot!.formattedTimeRange}'
                        : 'Not selected',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Appointment Type
          Text(
            'Appointment Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _appointmentType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            items:
                [
                      'CONSULTATION',
                      'HEALTH_SCREENING',
                      'FOLLOW_UP',
                      'EMERGENCY',
                      'VACCINATION',
                      'FAMILY_PLANNING',
                      'PRENATAL_CARE',
                      'POSTNATAL_CARE',
                      'COUNSELING',
                      'OTHER',
                    ]
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type
                              .replaceAll('_', ' ')
                              .toLowerCase()
                              .split(' ')
                              .map(
                                (word) =>
                                    word[0].toUpperCase() + word.substring(1),
                              )
                              .join(' '),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _appointmentType = value ?? 'CONSULTATION';
              });
            },
          ),
          const SizedBox(height: 24),

          // Reason for Visit
          Text(
            'Reason for Visit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Please describe the reason for your appointment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),

          // Additional Notes
          Text(
            'Additional Notes (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any additional information you\'d like to share...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),

          // Book Appointment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _canBookAppointment() ? _bookAppointmentAndProceed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appointmentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child:
                  _isBooking
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Book Appointment',
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
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 50, color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),

          // Success Message
          Center(
            child: Text(
              'Appointment Booked Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Your appointment has been confirmed and scheduled.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),

          // Appointment Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationRow(
                    'Facility',
                    _selectedFacility?.name ?? 'Not selected',
                  ),
                  _buildConfirmationRow(
                    'Health Worker',
                    _selectedHealthWorker?.name ?? 'Not selected',
                  ),
                  _buildConfirmationRow(
                    'Date & Time',
                    _selectedTimeSlot != null
                        ? '${_selectedTimeSlot!.formattedDate} at ${_selectedTimeSlot!.formattedTimeRange}'
                        : 'Not selected',
                  ),
                  _buildConfirmationRow(
                    'Appointment Type',
                    _appointmentType
                        .replaceAll('_', ' ')
                        .toLowerCase()
                        .split(' ')
                        .map(
                          (word) => word[0].toUpperCase() + word.substring(1),
                        )
                        .join(' '),
                  ),
                  _buildConfirmationRow(
                    'Reason',
                    _reasonController.text.trim(),
                  ),
                  if (_notesController.text.trim().isNotEmpty)
                    _buildConfirmationRow(
                      'Notes',
                      _notesController.text.trim(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Next Steps Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.appointmentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.appointmentBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.appointmentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Next Steps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appointmentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Your appointment has been successfully booked\n'
                  '• You will receive a confirmation notification\n'
                  '• Please arrive 15 minutes before your appointment\n'
                  '• Bring any relevant medical documents',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appointmentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appointmentBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentStep == 4 ? 'Book Appointment' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedFacility != null;
      case 1:
        return _selectedHealthWorker != null;
      case 2:
        return _selectedTimeSlot != null;
      case 3:
        return _reason.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextStep() {
    if (_currentStep < 4) {
      // Load data for next step
      if (_currentStep == 0 && _selectedFacility != null) {
        _loadHealthWorkers();
      } else if (_currentStep == 1 && _selectedHealthWorker != null) {
        _loadTimeSlots();
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // At step 4, book the appointment and only proceed if successful
      _bookAppointmentAndProceed();
    }
  }

  Future<void> _bookAppointmentAndProceed() async {
    if (!_canBookAppointment() || _isBooking) return;

    setState(() => _isBooking = true);

    try {
      print('DEBUG: Starting appointment booking process...');

      // Book the appointment via API
      final success = await ref
          .read(appointmentProvider.notifier)
          .createAppointment(
            healthFacilityId: _selectedFacility!.id!,
            healthWorkerId: _selectedHealthWorker!.id,
            appointmentType: _appointmentType,
            scheduledDate: _selectedTimeSlot!.startTime,
            durationMinutes: _selectedTimeSlot!.durationMinutes,
            reason: _reasonController.text.trim(),
            notes:
                _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
          );

      print('DEBUG: Appointment booking result: $success');

      if (success) {
        print(
          'DEBUG: Appointment booked successfully, proceeding to confirmation...',
        );
        // Only proceed to confirmation screen if booking was successful
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        print('DEBUG: Appointment booking failed');
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to book appointment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Exception during appointment booking: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      // Always reset booking state
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  // ==================== DATA LOADING METHODS ====================

  Future<void> _loadFacilities() async {
    print('DEBUG: Starting to load facilities...');
    setState(() => _isLoadingFacilities = true);

    try {
      print('DEBUG: Calling health facility service...');
      final facilities =
          await _healthFacilityService.getActiveHealthFacilities();
      print('DEBUG: Received ${facilities.length} facilities from service');

      setState(() {
        _facilities = facilities;
        _isLoadingFacilities = false;
      });

      print('DEBUG: State updated with ${_facilities.length} facilities');
    } catch (e) {
      print('DEBUG: Error loading facilities: $e');
      setState(() => _isLoadingFacilities = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load facilities: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadHealthWorkers() async {
    if (_selectedFacility == null || _selectedFacility!.id == null) return;

    setState(() => _isLoadingHealthWorkers = true);

    try {
      final healthWorkers = await _healthFacilityService
          .getAvailableHealthWorkers(_selectedFacility!.id!);
      setState(() {
        _healthWorkers = healthWorkers;
        _isLoadingHealthWorkers = false;
      });
    } catch (e) {
      setState(() => _isLoadingHealthWorkers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load health workers: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedFacility == null || _selectedFacility!.id == null) return;

    print(
      'DEBUG: Loading time slots for facility ${_selectedFacility!.id} and health worker ${_selectedHealthWorker?.id}',
    );
    setState(() => _isLoadingTimeSlots = true);

    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      print('DEBUG: Requesting time slots for date: $dateStr');

      final timeSlots = await ref
          .read(appointmentProvider.notifier)
          .getAvailableTimeSlots(
            healthFacilityId: _selectedFacility!.id!,
            healthWorkerId: _selectedHealthWorker?.id,
            date: dateStr,
          );

      print('DEBUG: Received ${timeSlots.length} time slots');

      setState(() {
        _timeSlots = timeSlots;
        _isLoadingTimeSlots = false;
      });
    } catch (e) {
      print('DEBUG: Error loading time slots: $e');
      setState(() => _isLoadingTimeSlots = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load time slots: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Check if all required fields are filled for booking
  bool _canBookAppointment() {
    final canBook =
        _selectedFacility != null &&
        _selectedHealthWorker != null &&
        _selectedTimeSlot != null &&
        _reasonController.text.trim().isNotEmpty &&
        !_isBooking;

    // Debug information
    print('DEBUG: _canBookAppointment() = $canBook');
    print('  - _selectedFacility: ${_selectedFacility?.name}');
    print('  - _selectedHealthWorker: ${_selectedHealthWorker?.name}');
    print('  - _selectedTimeSlot: ${_selectedTimeSlot?.formattedTimeRange}');
    print('  - _reasonController.text: "${_reasonController.text.trim()}"');
    print('  - _isBooking: $_isBooking');

    return canBook;
  }
}
