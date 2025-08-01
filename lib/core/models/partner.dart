/// Partner models for the family planning platform

/// Partner Invitation model
class PartnerInvitation {
  final int? id;
  final int inviterId;
  final String inviterName;
  final String inviteeEmail;
  final String? inviteeName;
  final String status;
  final String? message;
  final DateTime? sentAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;

  PartnerInvitation({
    this.id,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeEmail,
    this.inviteeName,
    required this.status,
    this.message,
    this.sentAt,
    this.respondedAt,
    this.expiresAt,
  });

  factory PartnerInvitation.fromJson(Map<String, dynamic> json) {
    return PartnerInvitation(
      id: json['id'],
      inviterId: json['inviterId'],
      inviterName: json['inviterName'] ?? '',
      inviteeEmail: json['inviteeEmail'] ?? '',
      inviteeName: json['inviteeName'],
      status: json['status'] ?? 'PENDING',
      message: json['message'],
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail,
      'inviteeName': inviteeName,
      'status': status,
      'message': message,
      'sentAt': sentAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Check if invitation is pending
  bool get isPending => status.toUpperCase() == 'PENDING';

  /// Check if invitation is accepted
  bool get isAccepted => status.toUpperCase() == 'ACCEPTED';

  /// Check if invitation is declined
  bool get isDeclined => status.toUpperCase() == 'DECLINED';

  /// Check if invitation is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'ACCEPTED':
        return 'Accepted';
      case 'DECLINED':
        return 'Declined';
      case 'EXPIRED':
        return 'Expired';
      default:
        return status;
    }
  }

  /// Get time since sent
  String get timeSinceSent {
    if (sentAt == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(sentAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

/// Partner Decision model
class PartnerDecision {
  final int? id;
  final int userId;
  final int partnerId;
  final String partnerName;
  final String decisionType;
  final String decision;
  final String? notes;
  final DateTime? decidedAt;
  final DateTime? createdAt;

  PartnerDecision({
    this.id,
    required this.userId,
    required this.partnerId,
    required this.partnerName,
    required this.decisionType,
    required this.decision,
    this.notes,
    this.decidedAt,
    this.createdAt,
  });

  factory PartnerDecision.fromJson(Map<String, dynamic> json) {
    return PartnerDecision(
      id: json['id'],
      userId: json['userId'],
      partnerId: json['partnerId'],
      partnerName: json['partnerName'] ?? '',
      decisionType: json['decisionType'] ?? '',
      decision: json['decision'] ?? '',
      notes: json['notes'],
      decidedAt: json['decidedAt'] != null ? DateTime.parse(json['decidedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'decisionType': decisionType,
      'decision': decision,
      'notes': notes,
      'decidedAt': decidedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Get decision type display name
  String get decisionTypeDisplayName {
    switch (decisionType.toLowerCase()) {
      case 'contraception':
        return 'Contraception Method';
      case 'pregnancy_planning':
        return 'Pregnancy Planning';
      case 'family_size':
        return 'Family Size';
      case 'health_goals':
        return 'Health Goals';
      default:
        return decisionType;
    }
  }

  /// Get decision display name
  String get decisionDisplayName {
    switch (decision.toLowerCase()) {
      case 'agreed':
        return 'Agreed';
      case 'disagreed':
        return 'Disagreed';
      case 'needs_discussion':
        return 'Needs Discussion';
      case 'postponed':
        return 'Postponed';
      default:
        return decision;
    }
  }

  /// Get time since decided
  String get timeSinceDecided {
    if (decidedAt == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(decidedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

/// Partner model (simplified user representation)
class Partner {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String relationshipStatus;
  final DateTime? connectedAt;

  Partner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.relationshipStatus,
    this.connectedAt,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      relationshipStatus: json['relationshipStatus'] ?? 'CONNECTED',
      connectedAt: json['connectedAt'] != null ? DateTime.parse(json['connectedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'relationshipStatus': relationshipStatus,
      'connectedAt': connectedAt?.toIso8601String(),
    };
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name
  String get displayName => firstName.isNotEmpty ? firstName : fullName;

  /// Get initials for avatar
  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Check if partner is active
  bool get isActive => relationshipStatus.toUpperCase() == 'CONNECTED';

  /// Get time since connected
  String get timeSinceConnected {
    if (connectedAt == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(connectedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}
