import 'package:json_annotation/json_annotation.dart';

part 'contraception_method.g.dart';

/// Custom enum decoder that handles both string and integer values
ContraceptionType _contraceptionTypeFromJson(dynamic value) {
  if (value is String) {
    // Handle string values from backend
    switch (value.toUpperCase()) {
      case 'PILL':
        return ContraceptionType.pill;
      case 'INJECTION':
        return ContraceptionType.injection;
      case 'IMPLANT':
        return ContraceptionType.implant;
      case 'IUD':
        return ContraceptionType.iud;
      case 'CONDOM':
        return ContraceptionType.condom;
      case 'DIAPHRAGM':
        return ContraceptionType.diaphragm;
      case 'PATCH':
        return ContraceptionType.patch;
      case 'RING':
        return ContraceptionType.ring;
      case 'NATURAL_FAMILY_PLANNING':
        return ContraceptionType.naturalFamilyPlanning;
      case 'STERILIZATION':
        return ContraceptionType.sterilization;
      case 'EMERGENCY_CONTRACEPTION':
        return ContraceptionType.emergencyContraception;
      case 'OTHER':
        return ContraceptionType.other;
      default:
        return ContraceptionType.other;
    }
  } else if (value is int) {
    // Handle integer values (enum index)
    final values = ContraceptionType.values;
    if (value >= 0 && value < values.length) {
      return values[value];
    }
    return ContraceptionType.other;
  } else if (value is String && int.tryParse(value) != null) {
    // Handle string numbers (enum index as string)
    final intValue = int.parse(value);
    final values = ContraceptionType.values;
    if (intValue >= 0 && intValue < values.length) {
      return values[intValue];
    }
    return ContraceptionType.other;
  }
  return ContraceptionType.other;
}

String _contraceptionTypeToJson(ContraceptionType type) {
  switch (type) {
    case ContraceptionType.pill:
      return 'PILL';
    case ContraceptionType.injection:
      return 'INJECTION';
    case ContraceptionType.implant:
      return 'IMPLANT';
    case ContraceptionType.iud:
      return 'IUD';
    case ContraceptionType.condom:
      return 'CONDOM';
    case ContraceptionType.diaphragm:
      return 'DIAPHRAGM';
    case ContraceptionType.patch:
      return 'PATCH';
    case ContraceptionType.ring:
      return 'RING';
    case ContraceptionType.naturalFamilyPlanning:
      return 'NATURAL_FAMILY_PLANNING';
    case ContraceptionType.sterilization:
      return 'STERILIZATION';
    case ContraceptionType.emergencyContraception:
      return 'EMERGENCY_CONTRACEPTION';
    case ContraceptionType.other:
      return 'OTHER';
  }
}

/// Extract user ID from nested user object
int? _userIdFromJson(dynamic value) {
  if (value is Map<String, dynamic>) {
    return (value['id'] as num?)?.toInt();
  } else if (value is int) {
    return value;
  }
  return null;
}

/// Contraception Type Enum
enum ContraceptionType {
  @JsonValue('PILL')
  pill,
  @JsonValue('INJECTION')
  injection,
  @JsonValue('IMPLANT')
  implant,
  @JsonValue('IUD')
  iud,
  @JsonValue('CONDOM')
  condom,
  @JsonValue('DIAPHRAGM')
  diaphragm,
  @JsonValue('PATCH')
  patch,
  @JsonValue('RING')
  ring,
  @JsonValue('NATURAL_FAMILY_PLANNING')
  naturalFamilyPlanning,
  @JsonValue('STERILIZATION')
  sterilization,
  @JsonValue('EMERGENCY_CONTRACEPTION')
  emergencyContraception,
  @JsonValue('OTHER')
  other,
}

/// Extension for ContraceptionType display names
extension ContraceptionTypeExtension on ContraceptionType {
  String get displayName {
    switch (this) {
      case ContraceptionType.pill:
        return 'Birth Control Pills';
      case ContraceptionType.injection:
        return 'Injection';
      case ContraceptionType.implant:
        return 'Implant';
      case ContraceptionType.iud:
        return 'IUD';
      case ContraceptionType.condom:
        return 'Condoms';
      case ContraceptionType.diaphragm:
        return 'Diaphragm';
      case ContraceptionType.patch:
        return 'Patch';
      case ContraceptionType.ring:
        return 'Ring';
      case ContraceptionType.naturalFamilyPlanning:
        return 'Natural Family Planning';
      case ContraceptionType.sterilization:
        return 'Sterilization';
      case ContraceptionType.emergencyContraception:
        return 'Emergency Contraception';
      case ContraceptionType.other:
        return 'Other';
    }
  }

  String get category {
    switch (this) {
      case ContraceptionType.pill:
      case ContraceptionType.injection:
      case ContraceptionType.implant:
      case ContraceptionType.iud:
      case ContraceptionType.patch:
      case ContraceptionType.ring:
        return 'Hormonal Methods';
      case ContraceptionType.condom:
      case ContraceptionType.diaphragm:
        return 'Barrier Methods';
      case ContraceptionType.naturalFamilyPlanning:
        return 'Natural Methods';
      case ContraceptionType.sterilization:
        return 'Permanent Methods';
      case ContraceptionType.emergencyContraception:
      case ContraceptionType.other:
        return 'Other Methods';
    }
  }
}

/// Contraception Method Model
class ContraceptionMethod {
  final int id;
  final String name;
  final ContraceptionType type;
  final String? description;
  final double? effectiveness;
  final String? duration;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  final String? notes;
  final String? prescribedBy;
  final DateTime? nextAppointment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? userId;
  final List<String>? sideEffects;
  final String? instructions;
  final Map<String, dynamic>? additionalData;

  ContraceptionMethod({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.effectiveness,
    this.duration,
    this.startDate,
    this.endDate,
    this.isActive,
    this.notes,
    this.prescribedBy,
    this.nextAppointment,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.sideEffects,
    this.instructions,
    this.additionalData,
  });

  factory ContraceptionMethod.fromJson(Map<String, dynamic> json) {
    return ContraceptionMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      type: _parseContraceptionType(json['type'] as String),
      description: json['description'] as String?,
      effectiveness: json['effectiveness']?.toDouble(),
      duration: json['duration'] as String?,
      startDate:
          json['startDate'] != null
              ? DateTime.parse(json['startDate'] as String)
              : null,
      endDate:
          json['endDate'] != null
              ? DateTime.parse(json['endDate'] as String)
              : null,
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      prescribedBy: json['prescribedBy'] as String?,
      nextAppointment:
          json['nextAppointment'] != null
              ? DateTime.parse(json['nextAppointment'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as int?,
      sideEffects:
          json['sideEffects'] != null
              ? List<String>.from(json['sideEffects'] as List)
              : null,
      instructions: json['instructions'] as String?,
      additionalData:
          json['additionalData'] != null
              ? Map<String, dynamic>.from(json['additionalData'] as Map)
              : null,
    );
  }

  static ContraceptionType _parseContraceptionType(String type) {
    switch (type.toUpperCase()) {
      case 'PILL':
        return ContraceptionType.pill;
      case 'IUD':
        return ContraceptionType.iud;
      case 'IMPLANT':
        return ContraceptionType.implant;
      case 'INJECTION':
        return ContraceptionType.injection;
      case 'CONDOM':
        return ContraceptionType.condom;
      case 'PATCH':
        return ContraceptionType.patch;
      case 'RING':
        return ContraceptionType.ring;
      case 'DIAPHRAGM':
        return ContraceptionType.diaphragm;
      case 'NATURAL_FAMILY_PLANNING':
        return ContraceptionType.naturalFamilyPlanning;
      case 'STERILIZATION':
        return ContraceptionType.sterilization;
      case 'EMERGENCY_CONTRACEPTION':
        return ContraceptionType.emergencyContraception;
      default:
        return ContraceptionType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'effectiveness': effectiveness,
      'duration': duration,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'prescribedBy': prescribedBy,
      'nextAppointment': nextAppointment?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ContraceptionMethod copyWith({
    int? id,
    String? name,
    ContraceptionType? type,
    String? description,
    double? effectiveness,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? notes,
    String? prescribedBy,
    DateTime? nextAppointment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userId,
    List<String>? sideEffects,
    String? instructions,
    Map<String, dynamic>? additionalData,
  }) {
    return ContraceptionMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      effectiveness: effectiveness ?? this.effectiveness,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      sideEffects: sideEffects ?? this.sideEffects,
      instructions: instructions ?? this.instructions,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'ContraceptionMethod(id: $id, name: $name, type: $type, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContraceptionMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Available Contraception Method (for selection)
@JsonSerializable()
class AvailableContraceptionMethod {
  final int id;
  @JsonKey(
    name: 'contraception_type',
    fromJson: _contraceptionTypeFromJson,
    toJson: _contraceptionTypeToJson,
  )
  final ContraceptionType type;
  final String name;
  final String? description;
  final double? effectiveness;
  final String? instructions;
  @JsonKey(name: 'additional_data')
  final String? additionalData;

  const AvailableContraceptionMethod({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.effectiveness,
    this.instructions,
    this.additionalData,
  });

  // Helper getter for category based on type
  String get category {
    switch (type) {
      case ContraceptionType.pill:
      case ContraceptionType.injection:
      case ContraceptionType.implant:
      case ContraceptionType.patch:
      case ContraceptionType.ring:
        return 'Hormonal Methods';
      case ContraceptionType.iud:
        return 'Long-Acting Methods';
      case ContraceptionType.condom:
      case ContraceptionType.diaphragm:
        return 'Barrier Methods';
      case ContraceptionType.naturalFamilyPlanning:
        return 'Natural Methods';
      case ContraceptionType.sterilization:
        return 'Permanent Methods';
      case ContraceptionType.emergencyContraception:
        return 'Emergency Methods';
      case ContraceptionType.other:
        return 'Other Methods';
    }
  }

  // Helper getter for common side effects based on type
  List<String> get commonSideEffects {
    switch (type) {
      case ContraceptionType.pill:
        return ['Nausea', 'Breast tenderness', 'Mood changes'];
      case ContraceptionType.injection:
        return ['Weight gain', 'Irregular bleeding', 'Mood changes'];
      case ContraceptionType.implant:
        return ['Irregular bleeding', 'Weight gain', 'Headaches'];
      case ContraceptionType.iud:
        return ['Cramping', 'Irregular bleeding', 'Spotting'];
      case ContraceptionType.patch:
        return ['Skin irritation', 'Breast tenderness', 'Nausea'];
      case ContraceptionType.ring:
        return ['Vaginal discharge', 'Irritation', 'Nausea'];
      case ContraceptionType.condom:
        return ['Allergic reactions', 'Reduced sensation'];
      case ContraceptionType.diaphragm:
        return ['Urinary tract infections', 'Irritation'];
      case ContraceptionType.naturalFamilyPlanning:
        return ['Requires discipline', 'Less effective'];
      case ContraceptionType.sterilization:
        return ['Surgical risks', 'Permanent'];
      case ContraceptionType.emergencyContraception:
        return ['Nausea', 'Fatigue', 'Irregular bleeding'];
      case ContraceptionType.other:
        return ['Varies by method'];
    }
  }

  factory AvailableContraceptionMethod.fromJson(Map<String, dynamic> json) =>
      _$AvailableContraceptionMethodFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableContraceptionMethodToJson(this);
}
