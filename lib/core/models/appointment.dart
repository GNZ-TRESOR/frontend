/// Appointment model for Ubuzima App
class Appointment {
  final int? id;
  final int? clientId;
  final int? healthWorkerId;
  final DateTime appointmentDate;
  final String type;
  final String status;
  final String? notes;
  final DateTime? createdAt;

  const Appointment({
    this.id,
    this.clientId,
    this.healthWorkerId,
    required this.appointmentDate,
    required this.type,
    this.status = 'scheduled',
    this.notes,
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int?,
      clientId: json['client_id'] as int?,
      healthWorkerId: json['health_worker_id'] as int?,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      type: json['type'] as String,
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'health_worker_id': healthWorkerId,
      'appointment_date': appointmentDate.toIso8601String(),
      'type': type,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Appointment copyWith({
    int? id,
    int? clientId,
    int? healthWorkerId,
    DateTime? appointmentDate,
    String? type,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      healthWorkerId: healthWorkerId ?? this.healthWorkerId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, clientId: $clientId, healthWorkerId: $healthWorkerId, appointmentDate: $appointmentDate, type: $type, status: $status, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Appointment &&
        other.id == id &&
        other.clientId == clientId &&
        other.healthWorkerId == healthWorkerId &&
        other.appointmentDate == appointmentDate &&
        other.type == type &&
        other.status == status &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        clientId.hashCode ^
        healthWorkerId.hashCode ^
        appointmentDate.hashCode ^
        type.hashCode ^
        status.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}

// Appointment types
class AppointmentType {
  static const String consultation = 'consultation';
  static const String checkup = 'checkup';
  static const String familyPlanning = 'family_planning';
  static const String prenatalCare = 'prenatal_care';
  static const String contraceptiveConsult = 'contraceptive_consult';
  static const String followUp = 'follow_up';
  static const String emergency = 'emergency';
  static const String vaccination = 'vaccination';

  static List<String> get all => [
    consultation,
    checkup,
    familyPlanning,
    prenatalCare,
    contraceptiveConsult,
    followUp,
    emergency,
    vaccination,
  ];

  static String getDisplayName(String type, String languageCode) {
    switch (type) {
      case consultation:
        switch (languageCode) {
          case 'rw':
            return 'Inama';
          case 'fr':
            return 'Consultation';
          default:
            return 'Consultation';
        }
      case checkup:
        switch (languageCode) {
          case 'rw':
            return 'Isuzuma';
          case 'fr':
            return 'Examen médical';
          default:
            return 'Medical Checkup';
        }
      case familyPlanning:
        switch (languageCode) {
          case 'rw':
            return 'Kubana n\'ubwiyunge';
          case 'fr':
            return 'Planification familiale';
          default:
            return 'Family Planning';
        }
      case prenatalCare:
        switch (languageCode) {
          case 'rw':
            return 'Kwita ku bafite inda';
          case 'fr':
            return 'Soins prénataux';
          default:
            return 'Prenatal Care';
        }
      case contraceptiveConsult:
        switch (languageCode) {
          case 'rw':
            return 'Inama yo kurinda inda';
          case 'fr':
            return 'Consultation contraceptive';
          default:
            return 'Contraceptive Consultation';
        }
      case followUp:
        switch (languageCode) {
          case 'rw':
            return 'Gukurikirana';
          case 'fr':
            return 'Suivi médical';
          default:
            return 'Follow-up';
        }
      case emergency:
        switch (languageCode) {
          case 'rw':
            return 'Ihutirwa';
          case 'fr':
            return 'Urgence';
          default:
            return 'Emergency';
        }
      case vaccination:
        switch (languageCode) {
          case 'rw':
            return 'Gukingira';
          case 'fr':
            return 'Vaccination';
          default:
            return 'Vaccination';
        }
      default:
        return type;
    }
  }
}

// Appointment status
class AppointmentStatus {
  static const String scheduled = 'scheduled';
  static const String confirmed = 'confirmed';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String noShow = 'no_show';
  static const String rescheduled = 'rescheduled';

  static List<String> get all => [
    scheduled,
    confirmed,
    inProgress,
    completed,
    cancelled,
    noShow,
    rescheduled,
  ];

  static String getDisplayName(String status, String languageCode) {
    switch (status) {
      case scheduled:
        switch (languageCode) {
          case 'rw':
            return 'Byateganijwe';
          case 'fr':
            return 'Programmé';
          default:
            return 'Scheduled';
        }
      case confirmed:
        switch (languageCode) {
          case 'rw':
            return 'Byemejwe';
          case 'fr':
            return 'Confirmé';
          default:
            return 'Confirmed';
        }
      case inProgress:
        switch (languageCode) {
          case 'rw':
            return 'Biragenda';
          case 'fr':
            return 'En cours';
          default:
            return 'In Progress';
        }
      case completed:
        switch (languageCode) {
          case 'rw':
            return 'Byarangiye';
          case 'fr':
            return 'Terminé';
          default:
            return 'Completed';
        }
      case cancelled:
        switch (languageCode) {
          case 'rw':
            return 'Byahagaritswe';
          case 'fr':
            return 'Annulé';
          default:
            return 'Cancelled';
        }
      case noShow:
        switch (languageCode) {
          case 'rw':
            return 'Ntabwo yaje';
          case 'fr':
            return 'Absent';
          default:
            return 'No Show';
        }
      case rescheduled:
        switch (languageCode) {
          case 'rw':
            return 'Byahinduwe';
          case 'fr':
            return 'Reprogrammé';
          default:
            return 'Rescheduled';
        }
      default:
        return status;
    }
  }
}
