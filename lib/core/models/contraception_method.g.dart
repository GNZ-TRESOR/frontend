// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contraception_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContraceptionMethod _$ContraceptionMethodFromJson(Map<String, dynamic> json) =>
    ContraceptionMethod(
      id: (json['id'] as num?)?.toInt(),
      userId: _userIdFromJson(json['user']),
      type: _contraceptionTypeFromJson(json['type']),
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      effectiveness: (json['effectiveness'] as num?)?.toDouble(),
      sideEffects:
          (json['sideEffects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      instructions: json['instructions'] as String?,
      nextAppointment:
          json['nextAppointment'] == null
              ? null
              : DateTime.parse(json['nextAppointment'] as String),
      isActive: json['isActive'] as bool? ?? true,
      prescribedBy: json['prescribedBy'] as String?,
      additionalData: json['additionalData'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ContraceptionMethodToJson(
  ContraceptionMethod instance,
) => <String, dynamic>{
  'id': instance.id,
  'user': instance.userId,
  'type': _contraceptionTypeToJson(instance.type),
  'name': instance.name,
  'description': instance.description,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'effectiveness': instance.effectiveness,
  'sideEffects': instance.sideEffects,
  'instructions': instance.instructions,
  'nextAppointment': instance.nextAppointment?.toIso8601String(),
  'isActive': instance.isActive,
  'prescribedBy': instance.prescribedBy,
  'additionalData': instance.additionalData,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

AvailableContraceptionMethod _$AvailableContraceptionMethodFromJson(
  Map<String, dynamic> json,
) => AvailableContraceptionMethod(
  id: (json['id'] as num).toInt(),
  type: _contraceptionTypeFromJson(json['contraception_type']),
  name: json['name'] as String,
  description: json['description'] as String?,
  effectiveness: (json['effectiveness'] as num?)?.toDouble(),
  instructions: json['instructions'] as String?,
  additionalData: json['additional_data'] as String?,
);

Map<String, dynamic> _$AvailableContraceptionMethodToJson(
  AvailableContraceptionMethod instance,
) => <String, dynamic>{
  'id': instance.id,
  'contraception_type': _contraceptionTypeToJson(instance.type),
  'name': instance.name,
  'description': instance.description,
  'effectiveness': instance.effectiveness,
  'instructions': instance.instructions,
  'additional_data': instance.additionalData,
};
