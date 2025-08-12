/// Message type enumeration for different types of messages
enum MessageType {
  TEXT,
  AUDIO,
  IMAGE,
  VIDEO,
  DOCUMENT,
  LOCATION,
  CONTACT,
  STICKER,
  GIF,
}

/// Message priority enumeration
enum MessagePriority {
  LOW,
  NORMAL,
  HIGH,
  URGENT,
}

/// Message status enumeration for delivery tracking
enum MessageStatus {
  SENDING,
  SENT,
  DELIVERED,
  READ,
  FAILED,
}

/// Extension methods for MessageType
extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.TEXT:
        return 'Text';
      case MessageType.AUDIO:
        return 'Audio';
      case MessageType.IMAGE:
        return 'Image';
      case MessageType.VIDEO:
        return 'Video';
      case MessageType.DOCUMENT:
        return 'Document';
      case MessageType.LOCATION:
        return 'Location';
      case MessageType.CONTACT:
        return 'Contact';
      case MessageType.STICKER:
        return 'Sticker';
      case MessageType.GIF:
        return 'GIF';
    }
  }

  String get apiValue {
    return name;
  }
}

/// Extension methods for MessagePriority
extension MessagePriorityExtension on MessagePriority {
  String get displayName {
    switch (this) {
      case MessagePriority.LOW:
        return 'Low';
      case MessagePriority.NORMAL:
        return 'Normal';
      case MessagePriority.HIGH:
        return 'High';
      case MessagePriority.URGENT:
        return 'Urgent';
    }
  }

  String get apiValue {
    return name;
  }
}

/// Extension methods for MessageStatus
extension MessageStatusExtension on MessageStatus {
  String get displayName {
    switch (this) {
      case MessageStatus.SENDING:
        return 'Sending';
      case MessageStatus.SENT:
        return 'Sent';
      case MessageStatus.DELIVERED:
        return 'Delivered';
      case MessageStatus.READ:
        return 'Read';
      case MessageStatus.FAILED:
        return 'Failed';
    }
  }

  String get apiValue {
    return name;
  }
}
