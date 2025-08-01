// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerInvitation _$PartnerInvitationFromJson(Map<String, dynamic> json) =>
    PartnerInvitation(
      id: (json['id'] as num?)?.toInt(),
      senderId: (json['senderId'] as num).toInt(),
      senderName: json['senderName'] as String?,
      recipientEmail: json['recipientEmail'] as String,
      recipientPhone: json['recipientPhone'] as String?,
      invitationType:
          $enumDecodeNullable(
            _$InvitationTypeEnumMap,
            json['invitationType'],
          ) ??
          InvitationType.partnerLink,
      invitationMessage: json['invitationMessage'] as String?,
      invitationCode: json['invitationCode'] as String,
      status:
          $enumDecodeNullable(_$InvitationStatusEnumMap, json['status']) ??
          InvitationStatus.sent,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      acceptedAt:
          json['acceptedAt'] == null
              ? null
              : DateTime.parse(json['acceptedAt'] as String),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PartnerInvitationToJson(PartnerInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'recipientEmail': instance.recipientEmail,
      'recipientPhone': instance.recipientPhone,
      'invitationType': _$InvitationTypeEnumMap[instance.invitationType]!,
      'invitationMessage': instance.invitationMessage,
      'invitationCode': instance.invitationCode,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$InvitationTypeEnumMap = {
  InvitationType.partnerLink: 'PARTNER_LINK',
  InvitationType.healthSharing: 'HEALTH_SHARING',
  InvitationType.decisionMaking: 'DECISION_MAKING',
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.sent: 'SENT',
  InvitationStatus.delivered: 'DELIVERED',
  InvitationStatus.accepted: 'ACCEPTED',
  InvitationStatus.declined: 'DECLINED',
  InvitationStatus.expired: 'EXPIRED',
};
