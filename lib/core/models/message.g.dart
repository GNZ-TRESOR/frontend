// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  version: (json['version'] as num?)?.toInt(),
  content: json['content'] as String?,
  conversationId: json['conversationId'] as String?,
  isEmergency: json['isEmergency'] as bool?,
  isRead: json['isRead'] as bool?,
  messageType: $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']),
  metadata: json['metadata'] as String?,
  priority: $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']),
  readAt:
      json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String),
  replyToId: (json['replyToId'] as num?)?.toInt(),
  receiverId: (json['receiverId'] as num).toInt(),
  senderId: (json['senderId'] as num).toInt(),
  attachmentUrls:
      (json['attachmentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  deliveredAt:
      json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
  audioDuration: (json['audioDuration'] as num?)?.toInt(),
  audioUrl: json['audioUrl'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
  mimeType: json['mimeType'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  isForwarded: json['isForwarded'] as bool?,
  forwardedFrom: json['forwardedFrom'] as String?,
  editedAt:
      json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  deletedForEveryone: json['deletedForEveryone'] as bool?,
  quotedMessageId: (json['quotedMessageId'] as num?)?.toInt(),
  messageStatus: json['messageStatus'] as String?,
  reaction: json['reaction'] as String?,
  starred: json['starred'] as bool?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'version': instance.version,
  'content': instance.content,
  'conversationId': instance.conversationId,
  'isEmergency': instance.isEmergency,
  'isRead': instance.isRead,
  'messageType': _$MessageTypeEnumMap[instance.messageType],
  'metadata': instance.metadata,
  'priority': _$MessagePriorityEnumMap[instance.priority],
  'readAt': instance.readAt?.toIso8601String(),
  'replyToId': instance.replyToId,
  'receiverId': instance.receiverId,
  'senderId': instance.senderId,
  'attachmentUrls': instance.attachmentUrls,
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'audioDuration': instance.audioDuration,
  'audioUrl': instance.audioUrl,
  'fileSize': instance.fileSize,
  'mimeType': instance.mimeType,
  'thumbnailUrl': instance.thumbnailUrl,
  'isForwarded': instance.isForwarded,
  'forwardedFrom': instance.forwardedFrom,
  'editedAt': instance.editedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'deletedForEveryone': instance.deletedForEveryone,
  'quotedMessageId': instance.quotedMessageId,
  'messageStatus': instance.messageStatus,
  'reaction': instance.reaction,
  'starred': instance.starred,
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'TEXT',
  MessageType.voice: 'VOICE',
  MessageType.image: 'IMAGE',
  MessageType.audio: 'AUDIO',
  MessageType.video: 'VIDEO',
  MessageType.document: 'DOCUMENT',
  MessageType.location: 'LOCATION',
};

const _$MessagePriorityEnumMap = {
  MessagePriority.low: 'LOW',
  MessagePriority.normal: 'NORMAL',
  MessagePriority.high: 'HIGH',
  MessagePriority.urgent: 'URGENT',
};

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  participantIds:
      (json['participantIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  lastMessage:
      json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
  lastActivity:
      json['lastActivity'] == null
          ? null
          : DateTime.parse(json['lastActivity'] as String),
  unreadCount: (json['unreadCount'] as num).toInt(),
  isGroup: json['isGroup'] as bool,
  groupName: json['groupName'] as String?,
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participantIds': instance.participantIds,
      'lastMessage': instance.lastMessage,
      'lastActivity': instance.lastActivity?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'isGroup': instance.isGroup,
      'groupName': instance.groupName,
    };
