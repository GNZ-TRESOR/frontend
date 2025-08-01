// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'side_effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SideEffectReport _$SideEffectReportFromJson(Map<String, dynamic> json) =>
    SideEffectReport(
      id: (json['id'] as num?)?.toInt(),
      contraceptionMethodId: (json['contraception_method_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      sideEffectName: json['side_effect_name'] as String,
      severity: $enumDecode(_$SideEffectSeverityEnumMap, json['severity']),
      frequency: $enumDecode(_$SideEffectFrequencyEnumMap, json['frequency']),
      description: json['description'] as String?,
      dateReported: DateTime.parse(json['date_reported'] as String),
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SideEffectReportToJson(SideEffectReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contraception_method_id': instance.contraceptionMethodId,
      'user_id': instance.userId,
      'side_effect_name': instance.sideEffectName,
      'severity': _$SideEffectSeverityEnumMap[instance.severity]!,
      'frequency': _$SideEffectFrequencyEnumMap[instance.frequency]!,
      'description': instance.description,
      'date_reported': instance.dateReported.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$SideEffectSeverityEnumMap = {
  SideEffectSeverity.mild: 'MILD',
  SideEffectSeverity.moderate: 'MODERATE',
  SideEffectSeverity.severe: 'SEVERE',
};

const _$SideEffectFrequencyEnumMap = {
  SideEffectFrequency.rare: 'RARE',
  SideEffectFrequency.occasional: 'OCCASIONAL',
  SideEffectFrequency.common: 'COMMON',
  SideEffectFrequency.frequent: 'FREQUENT',
};
