import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/appointment_model.dart';
import '../../core/models/health_facility_model.dart';
import '../../core/models/user_model.dart';
import '../../widgets/voice_button.dart';
import 'appointment_confirmation_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final HealthFacility? selectedFacility;
  final User? selectedHealthWorker;

  const AppointmentBookingScreen({
    super.key,
    this.selectedFacility,
    this.selectedHealthWorker,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  HealthFacility? _selectedFacility;
  User? _selectedHealthWorker;
  AppointmentType? _selectedType;
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;

  bool _isLoading = false;
  List<HealthFacility> _facilities = [];
  List<User> _healthWorkers = [];
  List<TimeSlot> _availableSlots = [];

  final List<AppointmentType> _appointmentTypes = [
    AppointmentType.generalConsultation,
    AppointmentType.familyPlanning,
    AppointmentType.prenatalCare,
    AppointmentType.followUp,
    AppointmentType.vaccination,
  ];

  @override
  void initState() {
    super.initState();
    _selectedFacility = widget.selectedFacility;
    _selectedHealthWorker = widget.selectedHealthWorker;
    _loadFacilities();
    if (_selectedFacility != null) {
      _loadHealthWorkers();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      _facilities = [
        HealthFacility(
          id: '1',
          name: 'Kimisagara Health Center',
          facilityType: FacilityType.healthCenter,
          address: 'Kimisagara, Kigali',
          district: 'Nyarugenge',
          sector: 'Kimisagara',
          latitude: -1.9441,
          longitude: 30.0619,
          phoneNumber: '+250788111222',
          servicesOffered: [
            'Family Planning',
            'Maternal Health',
            'General Medicine',
          ],
          operatingHours: '08:00-17:00 (Mon-Fri), 08:00-12:00 (Sat)',
          hasFamilyPlanning: true,
          hasMaternityWard: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HealthFacility(
          id: '2',
          name: 'Kigali University Teaching Hospital',
          facilityType: FacilityType.hospital,
          address: 'Nyarugenge, Kigali',
          district: 'Nyarugenge',
          sector: 'Nyarugenge',
          latitude: -1.9536,
          longitude: 30.0606,
          phoneNumber: '+250788333444',
          servicesOffered: ['Emergency', 'Surgery', 'Maternity', 'Pediatrics'],
          operatingHours: '24/7',
          is24Hours: true,
          hasEmergencyServices: true,
          hasMaternityWard: true,
          hasFamilyPlanning: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amavuriro');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHealthWorkers() async {
    if (_selectedFacility == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      _healthWorkers = [
        User(
          id: '2',
          name: 'Dr. Uwimana Jean',
          email: 'uwimana@health.gov.rw',
          phone: '+250788234567',
          role: UserRole.healthWorker,
          facilityId: _selectedFacility!.id,
          createdAt: DateTime.now(),
        ),
        User(
          id: '3',
          name: 'Nurse Mukamana Marie',
          email: 'mukamana@health.gov.rw',
          phone: '+250788345678',
          role: UserRole.healthWorker,
          facilityId: _selectedFacility!.id,
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka abaganga');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedFacility == null ||
        _selectedHealthWorker == null ||
        _selectedDate == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      final slots = <TimeSlot>[];
      final startHour = 8;
      final endHour = 17;

      for (int hour = startHour; hour < endHour; hour++) {
        for (int minute = 0; minute < 60; minute += 30) {
          final startTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            hour,
            minute,
          );
          final endTime = startTime.add(const Duration(minutes: 30));

          // Simulate some slots being unavailable
          final isAvailable = !(hour == 12 || (hour == 14 && minute == 0));

          slots.add(
            TimeSlot(
              startTime: startTime,
              endTime: endTime,
              isAvailable: isAvailable,
            ),
          );
        }
      }

      _availableSlots = slots;
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka ibihe bihari');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gahunda') || lowerCommand.contains('book')) {
      _bookAppointment();
    } else if (lowerCommand.contains('subira') ||
        lowerCommand.contains('back')) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFacility == null ||
        _selectedHealthWorker == null ||
        _selectedType == null ||
        _selectedTimeSlot == null) {
      _showErrorSnackBar('Uzuza amakuru yose');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        client: User(
          id: 'current_user_id',
          name: 'Current User',
          email: 'user@example.com',
          phone: '+250788000000',
          role: UserRole.client,
          createdAt: DateTime.now(),
        ),
        healthWorker: _selectedHealthWorker,
        facility: _selectedFacility,
        appointmentDate: _selectedTimeSlot!.startTime,
        endTime: _selectedTimeSlot!.endTime,
        durationMinutes:
            _selectedTimeSlot!.endTime
                .difference(_selectedTimeSlot!.startTime)
                .inMinutes,
        appointmentType: _selectedType!,
        status: AppointmentStatus.scheduled,
        reason: _reasonController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save to API and local database

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) =>
                    AppointmentConfirmationScreen(appointment: appointment),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushyiraho gahunda');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gushyiraho gahunda'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(isTablet),
                      SizedBox(height: AppTheme.spacing32),
                      _buildFacilitySelection(isTablet),
                      SizedBox(height: AppTheme.spacing24),
                      _buildHealthWorkerSelection(isTablet),
                      SizedBox(height: AppTheme.spacing24),
                      _buildAppointmentTypeSelection(isTablet),
                      SizedBox(height: AppTheme.spacing24),
                      _buildDateSelection(isTablet),
                      SizedBox(height: AppTheme.spacing24),
                      _buildTimeSlotSelection(isTablet),
                      SizedBox(height: AppTheme.spacing24),
                      _buildReasonInput(isTablet),
                      SizedBox(height: AppTheme.spacing32),
                      _buildBookButton(isTablet),
                    ],
                  ),
                ),
              ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Gahunda" kugira ngo ushyireho gahunda, cyangwa "Subira" kugira ngo usubirire inyuma',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gushyiraho gahunda',
      ),
    );
  }

  Widget _buildStepIndicator(bool isTablet) {
    final steps = [
      'Hitamo ikigo',
      'Hitamo umuganga',
      'Hitamo ubwoko',
      'Hitamo itariki',
      'Hitamo igihe',
    ];

    int currentStep = 0;
    if (_selectedFacility != null) currentStep = 1;
    if (_selectedHealthWorker != null) currentStep = 2;
    if (_selectedType != null) currentStep = 3;
    if (_selectedDate != null) currentStep = 4;
    if (_selectedTimeSlot != null) currentStep = 5;

    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intambwe zo gushyiraho gahunda',
            style: AppTheme.headingSmall.copyWith(fontSize: isTablet ? 18 : 16),
          ),
          SizedBox(height: AppTheme.spacing16),
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: isTablet ? 32 : 24,
                      height: isTablet ? 32 : 24,
                      decoration: BoxDecoration(
                        color:
                            isCompleted || isCurrent
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: isTablet ? 16 : 12,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 12 : 10,
                                  ),
                                ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color:
                              isCompleted
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildFacilitySelection(bool isTablet) {
    return _buildSelectionCard(
      title: 'Hitamo ikigo cy\'ubuzima',
      isTablet: isTablet,
      child: Column(
        children:
            _facilities.map((facility) {
              final isSelected = _selectedFacility?.id == facility.id;
              return Container(
                margin: EdgeInsets.only(bottom: AppTheme.spacing8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.local_hospital_rounded,
                    color:
                        isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                  ),
                  title: Text(
                    facility.name,
                    style: AppTheme.labelLarge.copyWith(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${facility.facilityTypeDisplayName} • ${facility.address}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryColor,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedFacility = facility;
                      _selectedHealthWorker = null;
                      _selectedDate = null;
                      _selectedTimeSlot = null;
                      _availableSlots.clear();
                    });
                    _loadHealthWorkers();
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildHealthWorkerSelection(bool isTablet) {
    if (_selectedFacility == null) {
      return _buildDisabledCard('Hitamo ikigo mbere', isTablet);
    }

    return _buildSelectionCard(
      title: 'Hitamo umuganga',
      isTablet: isTablet,
      child: Column(
        children:
            _healthWorkers.map((worker) {
              final isSelected = _selectedHealthWorker?.id == worker.id;
              return Container(
                margin: EdgeInsets.only(bottom: AppTheme.spacing8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person_rounded,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    worker.name,
                    style: AppTheme.labelLarge.copyWith(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    worker.roleDisplayName,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryColor,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedHealthWorker = worker;
                      _selectedDate = null;
                      _selectedTimeSlot = null;
                      _availableSlots.clear();
                    });
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAppointmentTypeSelection(bool isTablet) {
    if (_selectedHealthWorker == null) {
      return _buildDisabledCard('Hitamo umuganga mbere', isTablet);
    }

    return _buildSelectionCard(
      title: 'Hitamo ubwoko bw\'inama',
      isTablet: isTablet,
      child: Wrap(
        spacing: AppTheme.spacing8,
        runSpacing: AppTheme.spacing8,
        children:
            _appointmentTypes.map((type) {
              final isSelected = _selectedType == type;
              return FilterChip(
                label: Text(_getAppointmentTypeLabel(type)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                    _selectedDate = null;
                    _selectedTimeSlot = null;
                    _availableSlots.clear();
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: AppTheme.bodySmall.copyWith(
                  color:
                      isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDateSelection(bool isTablet) {
    if (_selectedType == null) {
      return _buildDisabledCard('Hitamo ubwoko bw\'inama mbere', isTablet);
    }

    return _buildSelectionCard(
      title: 'Hitamo itariki',
      isTablet: isTablet,
      child: Column(
        children: [
          CalendarDatePicker(
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now().add(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null;
              });
              _loadAvailableSlots();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSelection(bool isTablet) {
    if (_selectedDate == null) {
      return _buildDisabledCard('Hitamo itariki mbere', isTablet);
    }

    if (_availableSlots.isEmpty) {
      return _buildSelectionCard(
        title: 'Hitamo igihe',
        isTablet: isTablet,
        child: const Center(child: Text('Nta bihe bihari kuri iyi tariki')),
      );
    }

    return _buildSelectionCard(
      title: 'Hitamo igihe',
      isTablet: isTablet,
      child: Wrap(
        spacing: AppTheme.spacing8,
        runSpacing: AppTheme.spacing8,
        children:
            _availableSlots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              final timeText =
                  '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}';

              return FilterChip(
                label: Text(timeText),
                selected: isSelected,
                onSelected:
                    slot.isAvailable
                        ? (selected) {
                          setState(() {
                            _selectedTimeSlot = selected ? slot : null;
                          });
                        }
                        : null,
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                backgroundColor:
                    slot.isAvailable
                        ? null
                        : AppTheme.textTertiary.withValues(alpha: 0.1),
                labelStyle: AppTheme.bodySmall.copyWith(
                  color:
                      slot.isAvailable
                          ? (isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary)
                          : AppTheme.textTertiary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildReasonInput(bool isTablet) {
    return _buildSelectionCard(
      title: 'Impamvu y\'inama (optional)',
      isTablet: isTablet,
      child: TextFormField(
        controller: _reasonController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Sobanura impamvu yo gusaba inama...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBookButton(bool isTablet) {
    final canBook =
        _selectedFacility != null &&
        _selectedHealthWorker != null &&
        _selectedType != null &&
        _selectedTimeSlot != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canBook ? _bookAppointment : null,
        style: AppTheme.primaryButtonStyle.copyWith(
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
          ),
        ),
        child: Text(
          'Emeza gahunda',
          style: AppTheme.labelLarge.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isTablet,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(fontSize: isTablet ? 18 : 16),
          ),
          SizedBox(height: AppTheme.spacing16),
          child,
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildDisabledCard(String message, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.textTertiary.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
        ),
      ),
    );
  }

  String _getAppointmentTypeLabel(AppointmentType type) {
    switch (type) {
      case AppointmentType.generalConsultation:
        return 'Inama rusange';
      case AppointmentType.familyPlanning:
        return 'Gahunda y\'umuryango';
      case AppointmentType.prenatalCare:
        return 'Gukurikirana inda';
      case AppointmentType.followUp:
        return 'Gukurikirana';
      case AppointmentType.vaccination:
        return 'Urukingo';
      case AppointmentType.emergency:
        return 'Ihutirwa';
      case AppointmentType.contraceptionConsultation:
        return 'Inama yo kurinda inda';
      case AppointmentType.stiScreening:
        return 'Gusuzuma indwara zandurira';
      case AppointmentType.postnatalCare:
        return 'Kwita nyuma yo kubyara';
      case AppointmentType.healthEducation:
        return 'Kwigisha ubuzima';
      case AppointmentType.counseling:
        return 'Ubujyanama';
      case AppointmentType.laboratoryTests:
        return 'Ibizamini bya laboratoire';
    }
  }
}
