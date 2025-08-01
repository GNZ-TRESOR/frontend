import 'package:json_annotation/json_annotation.dart';

part 'partner_invitation.g.dart';

/// Invitation Type enum
enum InvitationType {
  @JsonValue('PARTNER_LINK')
  partnerLink,
  @JsonValue('HEALTH_SHARING')
  healthSharing,
  @JsonValue('DECISION_MAKING')
  decisionMaking,
}

/// Invitation Status enum
enum InvitationStatus {
  @JsonValue('SENT')
  sent,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('DECLINED')
  declined,
  @JsonValue('EXPIRED')
  expired,
}

/// Partner Invitation model for family planning
@JsonSerializable()
class PartnerInvitation {
  final int? id;
  final int senderId;
  final String? senderName;
  final String recipientEmail;
  final String? recipientPhone;
  final InvitationType invitationType;
  final String? invitationMessage;
  final String invitationCode;
  final InvitationStatus status;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartnerInvitation({
    this.id,
    required this.senderId,
    this.senderName,
    required this.recipientEmail,
    this.recipientPhone,
    this.invitationType = InvitationType.partnerLink,
    this.invitationMessage,
    required this.invitationCode,
    this.status = InvitationStatus.sent,
    required this.expiresAt,
    this.acceptedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory PartnerInvitation.fromJson(Map<String, dynamic> json) {
    // Handle nested sender object for senderId
    int? senderId;
    String? senderName;
    if (json['senderId'] != null) {
      senderId = json['senderId'] as int?;
    } else if (json['sender'] != null && json['sender'] is Map<String, dynamic>) {
      final senderMap = json['sender'] as Map<String, dynamic>;
      senderId = senderMap['id'] as int?;
      senderName = senderMap['name'] as String?;
    }

    return PartnerInvitation(
      id: json['id'] as int?,
      senderId: senderId ?? 0,
      senderName: senderName ?? json['senderName'] as String?,
      recipientEmail: json['recipientEmail'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String?,
      invitationType: _parseInvitationType(json['invitationType'] as String?),
      invitationMessage: json['invitationMessage'] as String?,
      invitationCode: json['invitationCode'] as String? ?? '',
      status: _parseInvitationStatus(json['status'] as String?),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PartnerInvitationToJson(this);

  /// Parse invitation type from string
  static InvitationType _parseInvitationType(String? type) {
    switch (type?.toUpperCase()) {
      case 'PARTNER_LINK':
        return InvitationType.partnerLink;
      case 'HEALTH_SHARING':
        return InvitationType.healthSharing;
      case 'DECISION_MAKING':
        return InvitationType.decisionMaking;
      default:
        return InvitationType.partnerLink;
    }
  }

  /// Parse invitation status from string
  static InvitationStatus _parseInvitationStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SENT':
        return InvitationStatus.sent;
      case 'DELIVERED':
        return InvitationStatus.delivered;
      case 'ACCEPTED':
        return InvitationStatus.accepted;
      case 'DECLINED':
        return InvitationStatus.declined;
      case 'EXPIRED':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.sent;
    }
  }

  /// Get invitation type display name
  String get typeDisplayName {
    switch (invitationType) {
      case InvitationType.partnerLink:
        return 'Partner Link';
      case InvitationType.healthSharing:
        return 'Health Sharing';
      case InvitationType.decisionMaking:
        return 'Decision Making';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case InvitationStatus.sent:
        return 'Sent';
      case InvitationStatus.delivered:
        return 'Delivered';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case InvitationStatus.sent:
        return '#2196F3'; // Blue
      case InvitationStatus.delivered:
        return '#FF9800'; // Orange
      case InvitationStatus.accepted:
        return '#4CAF50'; // Green
      case InvitationStatus.declined:
        return '#F44336'; // Red
      case InvitationStatus.expired:
        return '#9E9E9E'; // Grey
    }
  }

  /// Check if invitation is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if invitation can be accepted
  bool get canBeAccepted {
    return status == InvitationStatus.sent && !isExpired;
  }

  /// Get days until expiration
  int get daysUntilExpiration {
    final now = DateTime.now();
    final difference = expiresAt.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Copy with method
  PartnerInvitation copyWith({
    int? id,
    int? senderId,
    String? senderName,
    String? recipientEmail,
    String? recipientPhone,
    InvitationType? invitationType,
    String? invitationMessage,
    String? invitationCode,
    InvitationStatus? status,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerInvitation(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      invitationType: invitationType ?? this.invitationType,
      invitationMessage: invitationMessage ?? this.invitationMessage,
      invitationCode: invitationCode ?? this.invitationCode,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PartnerInvitation(id: $id, recipientEmail: $recipientEmail, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PartnerInvitation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
