// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  isAvailable: json['isAvailable'] as bool,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'isAvailable': instance.isAvailable,
  'reason': instance.reason,
};

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: json['id'] as String,
  client:
      json['client'] == null
          ? null
          : User.fromJson(json['client'] as Map<String, dynamic>),
  healthWorker:
      json['healthWorker'] == null
          ? null
          : User.fromJson(json['healthWorker'] as Map<String, dynamic>),
  facility:
      json['facility'] == null
          ? null
          : HealthFacility.fromJson(json['facility'] as Map<String, dynamic>),
  appointmentDate: DateTime.parse(json['appointmentDate'] as String),
  endTime:
      json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  appointmentType: $enumDecode(
    _$AppointmentTypeEnumMap,
    json['appointmentType'],
  ),
  status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
  reason: json['reason'] as String?,
  notes: json['notes'] as String?,
  healthWorkerNotes: json['healthWorkerNotes'] as String?,
  isEmergency: json['isEmergency'] as bool? ?? false,
  isFollowUp: json['isFollowUp'] as bool? ?? false,
  reminderSent: json['reminderSent'] as bool? ?? false,
  reminderSentAt:
      json['reminderSentAt'] == null
          ? null
          : DateTime.parse(json['reminderSentAt'] as String),
  checkedInAt:
      json['checkedInAt'] == null
          ? null
          : DateTime.parse(json['checkedInAt'] as String),
  startedAt:
      json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
  cancelledAt:
      json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  cancelledBy: json['cancelledBy'] as String?,
  rescheduledFrom:
      json['rescheduledFrom'] == null
          ? null
          : DateTime.parse(json['rescheduledFrom'] as String),
  rescheduleReason: json['rescheduleReason'] as String?,
  consultationFee: (json['consultationFee'] as num?)?.toDouble(),
  paymentStatus: json['paymentStatus'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  paymentReference: json['paymentReference'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client': instance.client,
      'healthWorker': instance.healthWorker,
      'facility': instance.facility,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'appointmentType': _$AppointmentTypeEnumMap[instance.appointmentType]!,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'reason': instance.reason,
      'notes': instance.notes,
      'healthWorkerNotes': instance.healthWorkerNotes,
      'isEmergency': instance.isEmergency,
      'isFollowUp': instance.isFollowUp,
      'reminderSent': instance.reminderSent,
      'reminderSentAt': instance.reminderSentAt?.toIso8601String(),
      'checkedInAt': instance.checkedInAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'cancelledBy': instance.cancelledBy,
      'rescheduledFrom': instance.rescheduledFrom?.toIso8601String(),
      'rescheduleReason': instance.rescheduleReason,
      'consultationFee': instance.consultationFee,
      'paymentStatus': instance.paymentStatus,
      'paymentMethod': instance.paymentMethod,
      'paymentReference': instance.paymentReference,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AppointmentTypeEnumMap = {
  AppointmentType.familyPlanning: 'FAMILY_PLANNING',
  AppointmentType.prenatalCare: 'PRENATAL_CARE',
  AppointmentType.postnatalCare: 'POSTNATAL_CARE',
  AppointmentType.contraceptionConsultation: 'CONTRACEPTION_CONSULTATION',
  AppointmentType.stiScreening: 'STI_SCREENING',
  AppointmentType.generalConsultation: 'GENERAL_CONSULTATION',
  AppointmentType.followUp: 'FOLLOW_UP',
  AppointmentType.emergency: 'EMERGENCY',
  AppointmentType.vaccination: 'VACCINATION',
  AppointmentType.healthEducation: 'HEALTH_EDUCATION',
  AppointmentType.counseling: 'COUNSELING',
  AppointmentType.laboratoryTests: 'LABORATORY_TESTS',
};

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'SCHEDULED',
  AppointmentStatus.confirmed: 'CONFIRMED',
  AppointmentStatus.checkedIn: 'CHECKED_IN',
  AppointmentStatus.inProgress: 'IN_PROGRESS',
  AppointmentStatus.completed: 'COMPLETED',
  AppointmentStatus.cancelled: 'CANCELLED',
  AppointmentStatus.noShow: 'NO_SHOW',
  AppointmentStatus.rescheduled: 'RESCHEDULED',
};
