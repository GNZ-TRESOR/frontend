import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
import 'user_model.dart';
import 'health_facility.dart';

part 'appointment_model.g.dart';

enum AppointmentType {
  @JsonValue('FAMILY_PLANNING')
  familyPlanning,
  @JsonValue('PRENATAL_CARE')
  prenatalCare,
  @JsonValue('POSTNATAL_CARE')
  postnatalCare,
  @JsonValue('CONTRACEPTION_CONSULTATION')
  contraceptionConsultation,
  @JsonValue('STI_SCREENING')
  stiScreening,
  @JsonValue('GENERAL_CONSULTATION')
  generalConsultation,
  @JsonValue('FOLLOW_UP')
  followUp,
  @JsonValue('EMERGENCY')
  emergency,
  @JsonValue('VACCINATION')
  vaccination,
  @JsonValue('HEALTH_EDUCATION')
  healthEducation,
  @JsonValue('COUNSELING')
  counseling,
  @JsonValue('LABORATORY_TESTS')
  laboratoryTests,
}

enum AppointmentStatus {
  @JsonValue('SCHEDULED')
  scheduled,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('CHECKED_IN')
  checkedIn,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('NO_SHOW')
  noShow,
  @JsonValue('RESCHEDULED')
  rescheduled,
}

@JsonSerializable()
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? reason;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.reason,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);
  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);

  String get formattedTime {
    final format = DateFormat('HH:mm');
    return '${format.format(startTime)} - ${format.format(endTime)}';
  }

  String get timeDisplay {
    final format = DateFormat('HH:mm');
    return format.format(startTime);
  }

  Duration get duration => endTime.difference(startTime);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode;
}

@JsonSerializable()
class Appointment {
  final String id;
  final User? client;
  final User? healthWorker;
  final HealthFacility? facility;
  final DateTime appointmentDate;
  final DateTime? endTime;
  final int? durationMinutes;
  final AppointmentType appointmentType;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final String? healthWorkerNotes;
  final bool isEmergency;
  final bool isFollowUp;
  final bool reminderSent;
  final DateTime? reminderSentAt;
  final DateTime? checkedInAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? rescheduledFrom;
  final String? rescheduleReason;
  final double? consultationFee;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    this.client,
    this.healthWorker,
    this.facility,
    required this.appointmentDate,
    this.endTime,
    this.durationMinutes,
    required this.appointmentType,
    required this.status,
    this.reason,
    this.notes,
    this.healthWorkerNotes,
    this.isEmergency = false,
    this.isFollowUp = false,
    this.reminderSent = false,
    this.reminderSentAt,
    this.checkedInAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    this.rescheduledFrom,
    this.rescheduleReason,
    this.consultationFee,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  // Utility methods
  bool get isUpcoming =>
      appointmentDate.isAfter(DateTime.now()) &&
      (status == AppointmentStatus.scheduled ||
          status == AppointmentStatus.confirmed);

  bool get isPast => appointmentDate.isBefore(DateTime.now());

  bool get canBeCancelled =>
      status == AppointmentStatus.scheduled ||
      status == AppointmentStatus.confirmed;

  bool get canBeRescheduled =>
      canBeCancelled &&
      appointmentDate.isAfter(DateTime.now().add(const Duration(hours: 2)));

  String get statusDisplayName {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.checkedIn:
        return 'Checked In';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  String get statusDisplayNameKinyarwanda {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Yateguwe';
      case AppointmentStatus.confirmed:
        return 'Yemejwe';
      case AppointmentStatus.checkedIn:
        return 'Yinjiye';
      case AppointmentStatus.inProgress:
        return 'Iragenda';
      case AppointmentStatus.completed:
        return 'Yarangiye';
      case AppointmentStatus.cancelled:
        return 'Yahagaritswe';
      case AppointmentStatus.noShow:
        return 'Ntiyaje';
      case AppointmentStatus.rescheduled:
        return 'Yahinduwe';
    }
  }

  String get typeDisplayName {
    switch (appointmentType) {
      case AppointmentType.familyPlanning:
        return 'Family Planning';
      case AppointmentType.prenatalCare:
        return 'Prenatal Care';
      case AppointmentType.postnatalCare:
        return 'Postnatal Care';
      case AppointmentType.contraceptionConsultation:
        return 'Contraception Consultation';
      case AppointmentType.stiScreening:
        return 'STI Screening';
      case AppointmentType.generalConsultation:
        return 'General Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.healthEducation:
        return 'Health Education';
      case AppointmentType.counseling:
        return 'Counseling';
      case AppointmentType.laboratoryTests:
        return 'Laboratory Tests';
    }
  }

  String get typeDisplayNameKinyarwanda {
    switch (appointmentType) {
      case AppointmentType.familyPlanning:
        return 'Kurinda inda';
      case AppointmentType.prenatalCare:
        return 'Kwita ku nda';
      case AppointmentType.postnatalCare:
        return 'Kwita nyuma yo kubyara';
      case AppointmentType.contraceptionConsultation:
        return 'Inama yo kurinda inda';
      case AppointmentType.stiScreening:
        return 'Gusuzuma indwara zandurira';
      case AppointmentType.generalConsultation:
        return 'Inama rusange';
      case AppointmentType.followUp:
        return 'Gukurikirana';
      case AppointmentType.emergency:
        return 'Byihutirwa';
      case AppointmentType.vaccination:
        return 'Gukingira';
      case AppointmentType.healthEducation:
        return 'Kwigisha ubuzima';
      case AppointmentType.counseling:
        return 'Ubujyanama';
      case AppointmentType.laboratoryTests:
        return 'Ibizamini bya laboratoire';
    }
  }

  String get formattedDuration {
    if (durationMinutes == null) return '';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Appointment copyWith({
    String? id,
    User? client,
    User? healthWorker,
    HealthFacility? facility,
    DateTime? appointmentDate,
    DateTime? endTime,
    int? durationMinutes,
    AppointmentType? appointmentType,
    AppointmentStatus? status,
    String? reason,
    String? notes,
    String? healthWorkerNotes,
    bool? isEmergency,
    bool? isFollowUp,
    bool? reminderSent,
    DateTime? reminderSentAt,
    DateTime? checkedInAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? rescheduledFrom,
    String? rescheduleReason,
    double? consultationFee,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentReference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      client: client ?? this.client,
      healthWorker: healthWorker ?? this.healthWorker,
      facility: facility ?? this.facility,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      healthWorkerNotes: healthWorkerNotes ?? this.healthWorkerNotes,
      isEmergency: isEmergency ?? this.isEmergency,
      isFollowUp: isFollowUp ?? this.isFollowUp,
      reminderSent: reminderSent ?? this.reminderSent,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      rescheduledFrom: rescheduledFrom ?? this.rescheduledFrom,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
      consultationFee: consultationFee ?? this.consultationFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Appointment(id: $id, type: $appointmentType, status: $status, date: $appointmentDate)';
}
