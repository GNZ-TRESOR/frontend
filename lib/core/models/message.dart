import 'user_model.dart';

/// Message type enum matching backend
enum MessageType {
  text('TEXT'),
  image('IMAGE'),
  audio('AUDIO'),
  video('VIDEO'),
  file('FILE'),
  location('LOCATION'),
  system('SYSTEM');

  const MessageType(this.value);
  final String value;

  static MessageType fromValue(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Inyandiko';
      case MessageType.image:
        return 'Ishusho';
      case MessageType.audio:
        return 'Ijwi';
      case MessageType.video:
        return 'Amashusho';
      case MessageType.file:
        return 'Dosiye';
      case MessageType.location:
        return 'Ahantu';
      case MessageType.system:
        return 'Sisitemu';
    }
  }
}

/// Message priority enum matching backend
enum MessagePriority {
  low('LOW'),
  normal('NORMAL'),
  high('HIGH'),
  urgent('URGENT');

  const MessagePriority(this.value);
  final String value;

  static MessagePriority fromValue(String value) {
    return MessagePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => MessagePriority.normal,
    );
  }

  String get displayName {
    switch (this) {
      case MessagePriority.low:
        return 'Ntoya';
      case MessagePriority.normal:
        return 'Bisanzwe';
      case MessagePriority.high:
        return 'Byingenzi';
      case MessagePriority.urgent:
        return 'Byihutirwa';
    }
  }
}

/// Message model matching backend entity
class Message {
  final String id;
  final User sender;
  final User? recipient;
  final String? conversationId;
  final MessageType type;
  final MessagePriority priority;
  final String content;
  final String? subject;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final bool isDelivered;
  final bool isEncrypted;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Message({
    required this.id,
    required this.sender,
    this.recipient,
    this.conversationId,
    required this.type,
    this.priority = MessagePriority.normal,
    required this.content,
    this.subject,
    this.metadata,
    this.isRead = false,
    this.isDelivered = false,
    this.isEncrypted = false,
    this.readAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      recipient: json['recipient'] != null
          ? User.fromJson(json['recipient'] as Map<String, dynamic>)
          : null,
      conversationId: json['conversationId'],
      type: MessageType.fromValue(json['type'] ?? 'TEXT'),
      priority: MessagePriority.fromValue(json['priority'] ?? 'NORMAL'),
      content: json['content'] ?? '',
      subject: json['subject'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] ?? json['read'] ?? false,
      isDelivered: json['isDelivered'] ?? json['delivered'] ?? false,
      isEncrypted: json['isEncrypted'] ?? json['encrypted'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? 
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? 
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'recipient': recipient?.toJson(),
      'conversationId': conversationId,
      'type': type.value,
      'priority': priority.value,
      'content': content,
      'subject': subject,
      'metadata': metadata,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isEncrypted': isEncrypted,
      'readAt': readAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    User? sender,
    User? recipient,
    String? conversationId,
    MessageType? type,
    MessagePriority? priority,
    String? content,
    String? subject,
    Map<String, dynamic>? metadata,
    bool? isRead,
    bool? isDelivered,
    bool? isEncrypted,
    DateTime? readAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      readAt: readAt ?? this.readAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if message is from today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  /// Check if message is recent (within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inMinutes;
    return difference <= 60;
  }

  /// Get formatted time string
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted date string
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get preview text (first 50 characters)
  String get preview {
    if (content.length <= 50) return content;
    return '${content.substring(0, 47)}...';
  }

  /// Check if message is sent by current user
  bool isSentByUser(String currentUserId) {
    return sender.id == currentUserId;
  }

  @override
  String toString() {
    return 'Message(id: $id, type: ${type.displayName}, content: $preview, sender: ${sender.name})';
  }
}

/// Conversation model for grouping messages
class Conversation {
  final String id;
  final List<User> participants;
  final Message? lastMessage;
  final String? title;
  final bool isGroup;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.title,
    this.isGroup = false,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => User.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      title: json['title'],
      isGroup: json['isGroup'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? 
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? 
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'title': title,
      'isGroup': isGroup,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get conversation display name
  String getDisplayName(String currentUserId) {
    if (title != null && title!.isNotEmpty) return title!;
    
    if (isGroup) {
      return participants.map((p) => p.name).join(', ');
    }
    
    // For direct messages, show the other participant's name
    final otherParticipant = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
    return otherParticipant.name;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, participants: ${participants.length}, isGroup: $isGroup)';
  }
}
