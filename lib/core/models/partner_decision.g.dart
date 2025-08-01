// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_decision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerDecision _$PartnerDecisionFromJson(Map<String, dynamic> json) =>
    PartnerDecision(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      partnerId: (json['partnerId'] as num?)?.toInt(),
      partnerName: json['partnerName'] as String?,
      decisionType: $enumDecode(_$DecisionTypeEnumMap, json['decisionType']),
      decisionTitle: json['decisionTitle'] as String,
      decisionDescription: json['decisionDescription'] as String?,
      decisionStatus:
          $enumDecodeNullable(
            _$DecisionStatusEnumMap,
            json['decisionStatus'],
          ) ??
          DecisionStatus.proposed,
      targetDate:
          json['targetDate'] == null
              ? null
              : DateTime.parse(json['targetDate'] as String),
      notes: json['notes'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PartnerDecisionToJson(PartnerDecision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'partnerId': instance.partnerId,
      'partnerName': instance.partnerName,
      'decisionType': _$DecisionTypeEnumMap[instance.decisionType]!,
      'decisionTitle': instance.decisionTitle,
      'decisionDescription': instance.decisionDescription,
      'decisionStatus': _$DecisionStatusEnumMap[instance.decisionStatus]!,
      'targetDate': instance.targetDate?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DecisionTypeEnumMap = {
  DecisionType.contraception: 'CONTRACEPTION',
  DecisionType.familyPlanning: 'FAMILY_PLANNING',
  DecisionType.healthGoal: 'HEALTH_GOAL',
  DecisionType.lifestyle: 'LIFESTYLE',
};

const _$DecisionStatusEnumMap = {
  DecisionStatus.proposed: 'PROPOSED',
  DecisionStatus.discussing: 'DISCUSSING',
  DecisionStatus.agreed: 'AGREED',
  DecisionStatus.disagreed: 'DISAGREED',
  DecisionStatus.postponed: 'POSTPONED',
};
