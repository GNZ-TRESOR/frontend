/// Health Record model for the family planning platform
class HealthRecord {
  final int? id;
  final int? userId;
  final String? notes;

  // Heart rate
  final int? heartRateValue;
  final String? heartRateUnit;

  // Blood pressure
  final String? bpValue;
  final String? bpUnit;

  // Weight
  final double? kgValue;
  final String? kgUnit;

  // Temperature
  final double? tempValue;
  final String? tempUnit;

  // Height
  final double? heightValue;
  final String? heightUnit;

  // Computed fields
  final double? bmi;
  final String? healthStatus;
  final bool? isVerified;
  final String? recordedBy;
  final int? assignedHealthWorkerId;

  final DateTime? lastUpdated;

  // Legacy fields for backward compatibility
  final String? title;
  final String? recordType;
  final DateTime? recordDate;
  final String? description;
  final String? diagnosis;
  final String? treatment;
  final String? doctorName;
  final String? facilityName;
  final List<String>? attachments;
  final Map<String, dynamic>? vitals;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthRecord({
    this.id,
    this.userId,
    this.notes,
    this.heartRateValue,
    this.heartRateUnit,
    this.bpValue,
    this.bpUnit,
    this.kgValue,
    this.kgUnit,
    this.tempValue,
    this.tempUnit,
    this.heightValue,
    this.heightUnit,
    this.bmi,
    this.healthStatus,
    this.isVerified,
    this.recordedBy,
    this.assignedHealthWorkerId,
    this.lastUpdated,
    // Legacy fields
    this.title,
    this.recordType,
    this.recordDate,
    this.description,
    this.diagnosis,
    this.treatment,
    this.doctorName,
    this.facilityName,
    this.attachments,
    this.vitals,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      userId: json['userId'],
      notes: json['notes'],

      // Health vitals
      heartRateValue: json['heartRateValue'],
      heartRateUnit: json['heartRateUnit'],
      bpValue: json['bpValue'],
      bpUnit: json['bpUnit'],
      kgValue: json['kgValue']?.toDouble(),
      kgUnit: json['kgUnit'],
      tempValue: json['tempValue']?.toDouble(),
      tempUnit: json['tempUnit'],
      heightValue: json['heightValue']?.toDouble(),
      heightUnit: json['heightUnit'],
      bmi: json['bmi']?.toDouble(),
      healthStatus: json['healthStatus'],
      isVerified: json['isVerified'],
      recordedBy: json['recordedBy'],
      assignedHealthWorkerId: json['assignedHealthWorkerId'],

      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'])
              : null,

      // Legacy fields for backward compatibility
      title: json['title'] ?? _generateTitle(json),
      recordType: json['recordType'] ?? 'Health Record',
      recordDate:
          json['recordDate'] != null
              ? DateTime.parse(json['recordDate'])
              : (json['lastUpdated'] != null
                  ? DateTime.parse(json['lastUpdated'])
                  : DateTime.now()),
      description: json['description'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      doctorName: json['doctorName'],
      facilityName: json['facilityName'],
      attachments:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : null,
      vitals: json['vitals'] ?? _generateVitalsMap(json),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Helper method to generate title from health data
  static String _generateTitle(Map<String, dynamic> json) {
    if (json['healthStatus'] != null) {
      return 'Health Record - ${json['healthStatus']}';
    }
    return 'Health Record';
  }

  // Helper method to generate vitals map from individual fields
  static Map<String, dynamic> _generateVitalsMap(Map<String, dynamic> json) {
    final vitals = <String, dynamic>{};

    if (json['heartRateValue'] != null) {
      vitals['Heart Rate'] =
          '${json['heartRateValue']} ${json['heartRateUnit'] ?? 'bpm'}';
    }
    if (json['bpValue'] != null) {
      vitals['Blood Pressure'] =
          '${json['bpValue']} ${json['bpUnit'] ?? 'mmHg'}';
    }
    if (json['kgValue'] != null) {
      vitals['Weight'] = '${json['kgValue']} ${json['kgUnit'] ?? 'kg'}';
    }
    if (json['tempValue'] != null) {
      vitals['Temperature'] =
          '${json['tempValue']} ${json['tempUnit'] ?? '°C'}';
    }
    if (json['heightValue'] != null) {
      vitals['Height'] = '${json['heightValue']} ${json['heightUnit'] ?? 'cm'}';
    }
    if (json['bmi'] != null) {
      vitals['BMI'] = json['bmi'].toString();
    }

    return vitals;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'heartRateValue': heartRateValue,
      'heartRateUnit': heartRateUnit,
      'bpValue': bpValue,
      'bpUnit': bpUnit,
      'kgValue': kgValue,
      'kgUnit': kgUnit,
      'tempValue': tempValue,
      'tempUnit': tempUnit,
      'heightValue': heightValue,
      'heightUnit': heightUnit,
      'bmi': bmi,
      'healthStatus': healthStatus,
      'isVerified': isVerified,
      'recordedBy': recordedBy,
      'assignedHealthWorkerId': assignedHealthWorkerId,
      'notes': notes,
      'lastUpdated': lastUpdated?.toIso8601String(),
      // Legacy fields
      'title': title,
      'recordType': recordType,
      'recordDate': recordDate?.toIso8601String(),
      'description': description,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'doctorName': doctorName,
      'facilityName': facilityName,
      'attachments': attachments,
      'vitals': vitals,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  HealthRecord copyWith({
    int? id,
    String? title,
    String? recordType,
    DateTime? recordDate,
    String? description,
    String? diagnosis,
    String? treatment,
    String? notes,
    String? doctorName,
    String? facilityName,
    List<String>? attachments,
    Map<String, dynamic>? vitals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      recordType: recordType ?? this.recordType,
      recordDate: recordDate ?? this.recordDate,
      description: description ?? this.description,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      doctorName: doctorName ?? this.doctorName,
      facilityName: facilityName ?? this.facilityName,
      attachments: attachments ?? this.attachments,
      vitals: vitals ?? this.vitals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted record date
  String get formattedDate {
    if (recordDate != null) {
      return '${recordDate!.day}/${recordDate!.month}/${recordDate!.year}';
    } else if (lastUpdated != null) {
      return '${lastUpdated!.day}/${lastUpdated!.month}/${lastUpdated!.year}';
    }
    return 'No date';
  }

  /// Get record type display name
  String get recordTypeDisplayName {
    if (recordType == null) return 'Health Record';
    switch (recordType!.toLowerCase()) {
      case 'general':
        return 'General Checkup';
      case 'laboratory':
        return 'Lab Results';
      case 'consultation':
        return 'Consultation';
      case 'prescription':
        return 'Prescription';
      case 'vaccination':
        return 'Vaccination';
      case 'emergency':
        return 'Emergency Visit';
      case 'health record':
        return 'Health Record';
      default:
        return recordType!;
    }
  }

  /// Check if record has attachments
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  /// Check if record has vitals
  bool get hasVitals => vitals != null && vitals!.isNotEmpty;

  /// Get vital signs as formatted string
  String get vitalsString {
    if (!hasVitals) return 'No vitals recorded';

    final List<String> vitalsList = [];
    vitals!.forEach((key, value) {
      vitalsList.add('$key: $value');
    });

    return vitalsList.join(', ');
  }

  /// Check if record is recent (within last 30 days)
  bool get isRecent {
    final now = DateTime.now();
    final dateToCheck = recordDate ?? lastUpdated;
    if (dateToCheck == null) return false;
    final difference = now.difference(dateToCheck);
    return difference.inDays <= 30;
  }

  /// Get record priority based on type
  int get priority {
    if (recordType == null) return 6;
    switch (recordType!.toLowerCase()) {
      case 'emergency':
        return 1;
      case 'laboratory':
        return 2;
      case 'consultation':
        return 3;
      case 'prescription':
        return 4;
      case 'vaccination':
        return 5;
      case 'general':
      case 'health record':
      default:
        return 6;
    }
  }

  @override
  String toString() {
    return 'HealthRecord{id: $id, title: $title, recordType: $recordType, recordDate: $recordDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthRecord &&
        other.id == id &&
        other.title == title &&
        other.recordType == recordType &&
        other.recordDate == recordDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        recordType.hashCode ^
        recordDate.hashCode;
  }
}
