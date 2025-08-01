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
@JsonSerializable()
class ContraceptionMethod {
  final int? id;
  @JsonKey(name: 'user', fromJson: _userIdFromJson)
  final int? userId;
  @JsonKey(
    fromJson: _contraceptionTypeFromJson,
    toJson: _contraceptionTypeToJson,
  )
  final ContraceptionType type;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final double? effectiveness;
  final List<String> sideEffects;
  final String? instructions;
  final DateTime? nextAppointment;
  final bool isActive;
  final String? prescribedBy;
  final String? additionalData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContraceptionMethod({
    this.id,
    this.userId,
    required this.type,
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
    this.effectiveness,
    this.sideEffects = const [],
    this.instructions,
    this.nextAppointment,
    this.isActive = true,
    this.prescribedBy,
    this.additionalData,
    this.createdAt,
    this.updatedAt,
  });

  factory ContraceptionMethod.fromJson(Map<String, dynamic> json) =>
      _$ContraceptionMethodFromJson(json);

  Map<String, dynamic> toJson() => _$ContraceptionMethodToJson(this);

  ContraceptionMethod copyWith({
    int? id,
    int? userId,
    ContraceptionType? type,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? effectiveness,
    List<String>? sideEffects,
    String? instructions,
    DateTime? nextAppointment,
    bool? isActive,
    String? prescribedBy,
    String? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContraceptionMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      effectiveness: effectiveness ?? this.effectiveness,
      sideEffects: sideEffects ?? this.sideEffects,
      instructions: instructions ?? this.instructions,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      isActive: isActive ?? this.isActive,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContraceptionMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ContraceptionMethod(id: $id, name: $name, type: $type, isActive: $isActive)';
  }
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
