// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: $enumDecode(_$MessageSenderEnumMap, json['sender']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
      hasError: json['hasError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isLoading': instance.isLoading,
      'hasError': instance.hasError,
      'errorMessage': instance.errorMessage,
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.assistant: 'assistant',
  MessageSender.system: 'system',
};

_$ChatSessionImpl _$$ChatSessionImplFromJson(Map<String, dynamic> json) =>
    _$ChatSessionImpl(
      id: json['id'] as String,
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageAt:
          json['lastMessageAt'] == null
              ? null
              : DateTime.parse(json['lastMessageAt'] as String),
      title: json['title'] as String? ?? 'Family Planning Chat',
    );

Map<String, dynamic> _$$ChatSessionImplToJson(_$ChatSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messages': instance.messages,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'title': instance.title,
    };
