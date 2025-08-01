import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int? id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? content;
  final String? conversationId;
  final bool? isEmergency;
  final bool? isRead;
  final MessageType? messageType;
  final String? metadata;
  final MessagePriority? priority;
  final DateTime? readAt;
  final int? replyToId;
  final int receiverId;
  final int senderId;
  final List<String>? attachmentUrls;

  const Message({
    this.id,
    required this.createdAt,
    this.updatedAt,
    this.version,
    this.content,
    this.conversationId,
    this.isEmergency,
    this.isRead,
    this.messageType,
    this.metadata,
    this.priority,
    this.readAt,
    this.replyToId,
    required this.receiverId,
    required this.senderId,
    this.attachmentUrls,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? content,
    String? conversationId,
    bool? isEmergency,
    bool? isRead,
    MessageType? messageType,
    String? metadata,
    MessagePriority? priority,
    DateTime? readAt,
    int? replyToId,
    int? receiverId,
    int? senderId,
    List<String>? attachmentUrls,
  }) {
    return Message(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      content: content ?? this.content,
      conversationId: conversationId ?? this.conversationId,
      isEmergency: isEmergency ?? this.isEmergency,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      readAt: readAt ?? this.readAt,
      replyToId: replyToId ?? this.replyToId,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }

  String get typeDisplayName {
    switch (messageType) {
      case MessageType.text:
        return 'Text';
      case MessageType.voice:
        return 'Voice';
      case MessageType.image:
        return 'Image';
      case MessageType.audio:
        return 'Audio';
      case MessageType.video:
        return 'Video';
      case MessageType.document:
        return 'Document';
      case MessageType.location:
        return 'Location';
      default:
        return 'Text';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case MessagePriority.low:
        return 'Low';
      case MessagePriority.normal:
        return 'Normal';
      case MessagePriority.high:
        return 'High';
      case MessagePriority.urgent:
        return 'Urgent';
      default:
        return 'Normal';
    }
  }

  bool get hasAttachments => attachmentUrls != null && attachmentUrls!.isNotEmpty;
  
  String get displayContent {
    if (content != null && content!.isNotEmpty) {
      return content!;
    }
    
    switch (messageType) {
      case MessageType.image:
        return '📷 Image';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.document:
        return '📄 Document';
      case MessageType.location:
        return '📍 Location';
      default:
        return 'Message';
    }
  }
}

enum MessageType {
  @JsonValue('TEXT')
  text,
  @JsonValue('VOICE')
  voice,
  @JsonValue('IMAGE')
  image,
  @JsonValue('AUDIO')
  audio,
  @JsonValue('VIDEO')
  video,
  @JsonValue('DOCUMENT')
  document,
  @JsonValue('LOCATION')
  location,
}

enum MessagePriority {
  @JsonValue('LOW')
  low,
  @JsonValue('NORMAL')
  normal,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
}

@JsonSerializable()
class Conversation {
  final String id;
  final List<int> participantIds;
  final Message? lastMessage;
  final DateTime? lastActivity;
  final int unreadCount;
  final bool isGroup;
  final String? groupName;

  const Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastActivity,
    required this.unreadCount,
    required this.isGroup,
    this.groupName,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  String get displayName {
    if (isGroup && groupName != null) {
      return groupName!;
    }
    return 'Conversation';
  }
}
