// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PregnancyPlan _$PregnancyPlanFromJson(Map<String, dynamic> json) =>
    PregnancyPlan(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      partnerId: (json['partnerId'] as num?)?.toInt(),
      planName: json['planName'] as String,
      targetConceptionDate:
          json['targetConceptionDate'] == null
              ? null
              : DateTime.parse(json['targetConceptionDate'] as String),
      currentStatus:
          $enumDecodeNullable(
            _$PregnancyPlanStatusEnumMap,
            json['currentStatus'],
          ) ??
          PregnancyPlanStatus.planning,
      preconceptionGoals: json['preconceptionGoals'] as String?,
      healthPreparations: json['healthPreparations'] as String?,
      lifestyleChanges: json['lifestyleChanges'] as String?,
      medicalConsultations: json['medicalConsultations'] as String?,
      progressNotes: json['progressNotes'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PregnancyPlanToJson(PregnancyPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'partnerId': instance.partnerId,
      'planName': instance.planName,
      'targetConceptionDate': instance.targetConceptionDate?.toIso8601String(),
      'currentStatus': _$PregnancyPlanStatusEnumMap[instance.currentStatus]!,
      'preconceptionGoals': instance.preconceptionGoals,
      'healthPreparations': instance.healthPreparations,
      'lifestyleChanges': instance.lifestyleChanges,
      'medicalConsultations': instance.medicalConsultations,
      'progressNotes': instance.progressNotes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PregnancyPlanStatusEnumMap = {
  PregnancyPlanStatus.planning: 'PLANNING',
  PregnancyPlanStatus.trying: 'TRYING',
  PregnancyPlanStatus.pregnant: 'PREGNANT',
  PregnancyPlanStatus.paused: 'PAUSED',
  PregnancyPlanStatus.completed: 'COMPLETED',
};
