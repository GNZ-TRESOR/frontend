// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTicket _$SupportTicketFromJson(Map<String, dynamic> json) =>
    SupportTicket(
      id: (json['id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      version: (json['version'] as num?)?.toInt(),
      description: json['description'] as String,
      priority: $enumDecodeNullable(_$TicketPriorityEnumMap, json['priority']),
      resolutionNotes: json['resolutionNotes'] as String?,
      resolvedAt:
          json['resolvedAt'] == null
              ? null
              : DateTime.parse(json['resolvedAt'] as String),
      status: $enumDecodeNullable(_$TicketStatusEnumMap, json['status']),
      subject: json['subject'] as String,
      ticketType: $enumDecode(_$TicketTypeEnumMap, json['ticketType']),
      userEmail: json['userEmail'] as String?,
      userPhone: json['userPhone'] as String?,
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SupportTicketToJson(SupportTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'version': instance.version,
      'description': instance.description,
      'priority': _$TicketPriorityEnumMap[instance.priority],
      'resolutionNotes': instance.resolutionNotes,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'status': _$TicketStatusEnumMap[instance.status],
      'subject': instance.subject,
      'ticketType': _$TicketTypeEnumMap[instance.ticketType]!,
      'userEmail': instance.userEmail,
      'userPhone': instance.userPhone,
      'assignedTo': instance.assignedTo,
      'userId': instance.userId,
    };

const _$TicketPriorityEnumMap = {
  TicketPriority.low: 'LOW',
  TicketPriority.medium: 'MEDIUM',
  TicketPriority.high: 'HIGH',
  TicketPriority.urgent: 'URGENT',
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'OPEN',
  TicketStatus.inProgress: 'IN_PROGRESS',
  TicketStatus.resolved: 'RESOLVED',
  TicketStatus.closed: 'CLOSED',
};

const _$TicketTypeEnumMap = {
  TicketType.technical: 'TECHNICAL',
  TicketType.medical: 'MEDICAL',
  TicketType.account: 'ACCOUNT',
  TicketType.feedback: 'FEEDBACK',
  TicketType.complaint: 'COMPLAINT',
  TicketType.suggestion: 'SUGGESTION',
};
