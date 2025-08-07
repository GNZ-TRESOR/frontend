// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contraception_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
