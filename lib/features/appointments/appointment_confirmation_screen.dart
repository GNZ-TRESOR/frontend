import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/appointment_model.dart';
import '../../core/models/health_facility_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/voice_button.dart';

class AppointmentConfirmationScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentConfirmationScreen({super.key, required this.appointment});

  @override
  State<AppointmentConfirmationScreen> createState() =>
      _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState
    extends State<AppointmentConfirmationScreen> {
  bool _reminderSet = false;

  @override
  void initState() {
    super.initState();
    _scheduleReminder();
  }

  Future<void> _scheduleReminder() async {
    try {
      await NotificationService().scheduleAppointmentReminder(
        appointmentTime: widget.appointment.appointmentDate,
        healthWorkerName:
            widget.appointment.healthWorker?.name ?? 'Health Worker',
        facilityName: widget.appointment.facility?.name ?? 'Health Facility',
      );

      setState(() {
        _reminderSet = true;
      });
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('ahabanza') || lowerCommand.contains('home')) {
      _goToHome();
    } else if (lowerCommand.contains('gahunda') ||
        lowerCommand.contains('appointments')) {
      _goToAppointments();
    }
  }

  void _goToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goToAppointments() {
    // TODO: Navigate to appointments list
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          child: Column(
            children: [
              SizedBox(
                height: isTablet ? AppTheme.spacing64 : AppTheme.spacing32,
              ),

              // Success Animation
              _buildSuccessAnimation(isTablet),

              SizedBox(height: AppTheme.spacing32),

              // Confirmation Message
              _buildConfirmationMessage(isTablet),

              SizedBox(height: AppTheme.spacing32),

              // Appointment Details
              _buildAppointmentDetails(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Facility Details
              _buildFacilityDetails(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Health Worker Details
              _buildHealthWorkerDetails(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Reminder Status
              _buildReminderStatus(isTablet),

              SizedBox(height: AppTheme.spacing32),

              // Action Buttons
              _buildActionButtons(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Important Notes
              _buildImportantNotes(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Ahabanza" kugira ngo usubirire ahabanza, cyangwa "Gahunda" kugira ngo ugere ku gahunda zawe',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi kugenda',
      ),
    );
  }

  Widget _buildSuccessAnimation(bool isTablet) {
    return Container(
          width: isTablet ? 120 : 100,
          height: isTablet ? 120 : 100,
          decoration: BoxDecoration(
            gradient: AppTheme.successGradient,
            borderRadius: BorderRadius.circular(isTablet ? 60 : 50),
            boxShadow: AppTheme.largeShadow,
          ),
          child: Icon(
            Icons.check_rounded,
            size: isTablet ? 60 : 50,
            color: Colors.white,
          ),
        )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .then(delay: 200.ms)
        .shake(duration: 400.ms);
  }

  Widget _buildConfirmationMessage(bool isTablet) {
    return Column(
      children: [
        Text(
          'Gahunda yawe yarateguwe neza!',
          style: AppTheme.headingLarge.copyWith(
            fontSize: isTablet ? 28 : 24,
            color: AppTheme.successColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          'Uzabona ubutumwa bw\'ikwibutsa mbere y\'igihe cy\'inama',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildAppointmentDetails(bool isTablet) {
    final dateFormat = DateFormat('EEEE, MMMM d, y', 'rw');
    final timeFormat = DateFormat('HH:mm');

    return _buildDetailCard(
      title: 'Amakuru y\'inama',
      icon: Icons.event_rounded,
      color: AppTheme.primaryColor,
      isTablet: isTablet,
      children: [
        _buildDetailRow(
          'Itariki:',
          dateFormat.format(widget.appointment.appointmentDate),
          Icons.calendar_today_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Igihe:',
          timeFormat.format(widget.appointment.appointmentDate),
          Icons.access_time_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Igihe cy\'inama:',
          '${widget.appointment.durationMinutes ?? 30} iminota',
          Icons.timer_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Ubwoko:',
          _getAppointmentTypeLabel(widget.appointment.appointmentType),
          Icons.medical_services_rounded,
          isTablet,
        ),
        if (widget.appointment.reason != null &&
            widget.appointment.reason!.isNotEmpty)
          _buildDetailRow(
            'Impamvu:',
            widget.appointment.reason!,
            Icons.description_rounded,
            isTablet,
          ),
      ],
    );
  }

  Widget _buildFacilityDetails(bool isTablet) {
    return _buildDetailCard(
      title: 'Ikigo cy\'ubuzima',
      icon: Icons.local_hospital_rounded,
      color: AppTheme.secondaryColor,
      isTablet: isTablet,
      children: [
        _buildDetailRow(
          'Izina:',
          widget.appointment.facility?.name ?? 'N/A',
          Icons.business_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Ubwoko:',
          widget.appointment.facility?.type.displayName ?? 'N/A',
          Icons.category_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Aderesi:',
          widget.appointment.facility?.address ?? 'N/A',
          Icons.location_on_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Telefoni:',
          widget.appointment.facility?.phone ?? 'N/A',
          Icons.phone_rounded,
          isTablet,
        ),
      ],
    );
  }

  Widget _buildHealthWorkerDetails(bool isTablet) {
    return _buildDetailCard(
      title: 'Umuganga',
      icon: Icons.person_rounded,
      color: AppTheme.accentColor,
      isTablet: isTablet,
      children: [
        _buildDetailRow(
          'Izina:',
          widget.appointment.healthWorker?.name ?? 'N/A',
          Icons.person_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Umwuga:',
          widget.appointment.healthWorker?.roleDisplayName ?? 'N/A',
          Icons.work_rounded,
          isTablet,
        ),
        _buildDetailRow(
          'Telefoni:',
          widget.appointment.healthWorker?.phone ?? 'N/A',
          Icons.phone_rounded,
          isTablet,
        ),
      ],
    );
  }

  Widget _buildReminderStatus(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color:
            _reminderSet
                ? AppTheme.successColor.withValues(alpha: 0.1)
                : AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color:
              _reminderSet
                  ? AppTheme.successColor.withValues(alpha: 0.3)
                  : AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _reminderSet
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: _reminderSet ? AppTheme.successColor : AppTheme.warningColor,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reminderSet
                      ? 'Ikwibutsa ryashyizweho'
                      : 'Ikwibutsa ntirishobora gushyirwaho',
                  style: AppTheme.labelMedium.copyWith(
                    color:
                        _reminderSet
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  _reminderSet
                      ? 'Uzabona ubutumwa bw\'ikwibutsa isaha imwe mbere y\'inama'
                      : 'Wibuke guhaguruka kuri inama yawe',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _goToHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('Subira ahabanza'),
            style: AppTheme.primaryButtonStyle.copyWith(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacing12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _goToAppointments,
            icon: const Icon(Icons.event_note_rounded),
            label: const Text('Reba gahunda zose'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildImportantNotes(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.infoColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Ibintu by\'ingenzi',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildNoteItem(
            'Gera ku kigo 15 iminota mbere y\'igihe cy\'inama',
            isTablet,
          ),
          _buildNoteItem(
            'Zana indangamuntu yawe n\'ibyangombwa by\'ubuzima',
            isTablet,
          ),
          _buildNoteItem(
            'Niba udashobora kuza, hamagara ikigo mbere y\'igihe',
            isTablet,
          ),
          _buildNoteItem('Uzana ibibazo byose ufite ku buzima bwawe', isTablet),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isTablet,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Icon(icon, color: color, size: isTablet ? 24 : 20),
              ),
              SizedBox(width: AppTheme.spacing12),
              Text(
                title,
                style: AppTheme.headingSmall.copyWith(
                  fontSize: isTablet ? 18 : 16,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          ...children,
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isTablet ? 16 : 14, color: AppTheme.textSecondary),
          SizedBox(width: AppTheme.spacing8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 6 : 4,
            height: isTablet ? 6 : 4,
            margin: EdgeInsets.only(
              top: isTablet ? 8 : 6,
              right: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.infoColor,
              borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _getAppointmentTypeLabel(AppointmentType type) {
    switch (type) {
      case AppointmentType.generalConsultation:
        return 'Inama rusange';
      case AppointmentType.familyPlanning:
        return 'Kurinda inda';
      case AppointmentType.prenatalCare:
        return 'Kwita ku nda';
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
