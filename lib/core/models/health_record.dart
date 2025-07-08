/// Health Record model for Ubuzima App
class HealthRecord {
  final int? id;
  final int? userId;
  final String recordType;
  final DateTime date;
  final double? weight;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final double? temperature;
  final String? notes;
  final DateTime? createdAt;

  const HealthRecord({
    this.id,
    this.userId,
    required this.recordType,
    required this.date,
    this.weight,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.temperature,
    this.notes,
    this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      recordType: json['record_type'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as double?,
      bloodPressureSystolic: json['blood_pressure_systolic'] as int?,
      bloodPressureDiastolic: json['blood_pressure_diastolic'] as int?,
      temperature: json['temperature'] as double?,
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
      'user_id': userId,
      'record_type': recordType,
      'date': date.toIso8601String(),
      'weight': weight,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'temperature': temperature,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  HealthRecord copyWith({
    int? id,
    int? userId,
    String? recordType,
    DateTime? date,
    double? weight,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? temperature,
    String? notes,
    DateTime? createdAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recordType: recordType ?? this.recordType,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      temperature: temperature ?? this.temperature,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'HealthRecord(id: $id, userId: $userId, recordType: $recordType, date: $date, weight: $weight, bloodPressureSystolic: $bloodPressureSystolic, bloodPressureDiastolic: $bloodPressureDiastolic, temperature: $temperature, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthRecord &&
        other.id == id &&
        other.userId == userId &&
        other.recordType == recordType &&
        other.date == date &&
        other.weight == weight &&
        other.bloodPressureSystolic == bloodPressureSystolic &&
        other.bloodPressureDiastolic == bloodPressureDiastolic &&
        other.temperature == temperature &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        recordType.hashCode ^
        date.hashCode ^
        weight.hashCode ^
        bloodPressureSystolic.hashCode ^
        bloodPressureDiastolic.hashCode ^
        temperature.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}

// Health record types
class HealthRecordType {
  static const String weight = 'weight';
  static const String bloodPressure = 'blood_pressure';
  static const String temperature = 'temperature';
  static const String menstrualCycle = 'menstrual_cycle';
  static const String contraceptive = 'contraceptive';
  static const String checkup = 'checkup';
  static const String symptoms = 'symptoms';
  static const String medication = 'medication';

  static List<String> get all => [
    weight,
    bloodPressure,
    temperature,
    menstrualCycle,
    contraceptive,
    checkup,
    symptoms,
    medication,
  ];

  static String getDisplayName(String type, String languageCode) {
    switch (type) {
      case weight:
        switch (languageCode) {
          case 'rw':
            return 'Uburemere';
          case 'fr':
            return 'Poids';
          default:
            return 'Weight';
        }
      case bloodPressure:
        switch (languageCode) {
          case 'rw':
            return 'Umuvuduko w\'amaraso';
          case 'fr':
            return 'Tension artérielle';
          default:
            return 'Blood Pressure';
        }
      case temperature:
        switch (languageCode) {
          case 'rw':
            return 'Ubushyuhe';
          case 'fr':
            return 'Température';
          default:
            return 'Temperature';
        }
      case menstrualCycle:
        switch (languageCode) {
          case 'rw':
            return 'Imihango';
          case 'fr':
            return 'Cycle menstruel';
          default:
            return 'Menstrual Cycle';
        }
      case contraceptive:
        switch (languageCode) {
          case 'rw':
            return 'Kurinda inda';
          case 'fr':
            return 'Contraceptif';
          default:
            return 'Contraceptive';
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
      case symptoms:
        switch (languageCode) {
          case 'rw':
            return 'Ibimenyetso';
          case 'fr':
            return 'Symptômes';
          default:
            return 'Symptoms';
        }
      case medication:
        switch (languageCode) {
          case 'rw':
            return 'Imiti';
          case 'fr':
            return 'Médicaments';
          default:
            return 'Medication';
        }
      default:
        return type;
    }
  }
}
