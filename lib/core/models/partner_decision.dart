import 'package:json_annotation/json_annotation.dart';

part 'partner_decision.g.dart';

/// Decision Type enum
enum DecisionType {
  @JsonValue('CONTRACEPTION')
  contraception,
  @JsonValue('FAMILY_PLANNING')
  familyPlanning,
  @JsonValue('HEALTH_GOAL')
  healthGoal,
  @JsonValue('LIFESTYLE')
  lifestyle,
}

/// Decision Status enum
enum DecisionStatus {
  @JsonValue('PROPOSED')
  proposed,
  @JsonValue('DISCUSSING')
  discussing,
  @JsonValue('AGREED')
  agreed,
  @JsonValue('DISAGREED')
  disagreed,
  @JsonValue('POSTPONED')
  postponed,
}

/// Partner Decision model for family planning
@JsonSerializable()
class PartnerDecision {
  final int? id;
  final int userId;
  final int? partnerId;
  final String? partnerName;
  final DecisionType decisionType;
  final String decisionTitle;
  final String? decisionDescription;
  final DecisionStatus decisionStatus;
  final DateTime? targetDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartnerDecision({
    this.id,
    required this.userId,
    this.partnerId,
    this.partnerName,
    required this.decisionType,
    required this.decisionTitle,
    this.decisionDescription,
    this.decisionStatus = DecisionStatus.proposed,
    this.targetDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory PartnerDecision.fromJson(Map<String, dynamic> json) {
    // Handle nested user object for userId
    int? userId;
    if (json['userId'] != null) {
      userId = json['userId'] as int?;
    } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final userMap = json['user'] as Map<String, dynamic>;
      userId = userMap['id'] as int?;
    }

    // Handle nested partner object for partnerId
    int? partnerId;
    String? partnerName;
    if (json['partnerId'] != null) {
      partnerId = json['partnerId'] as int?;
    } else if (json['partner'] != null && json['partner'] is Map<String, dynamic>) {
      final partnerMap = json['partner'] as Map<String, dynamic>;
      partnerId = partnerMap['id'] as int?;
      partnerName = partnerMap['name'] as String?;
    }

    return PartnerDecision(
      id: json['id'] as int?,
      userId: userId ?? 0,
      partnerId: partnerId,
      partnerName: partnerName ?? json['partnerName'] as String?,
      decisionType: _parseDecisionType(json['decisionType'] as String?),
      decisionTitle: json['decisionTitle'] as String? ?? '',
      decisionDescription: json['decisionDescription'] as String?,
      decisionStatus: _parseDecisionStatus(json['decisionStatus'] as String?),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PartnerDecisionToJson(this);

  /// Parse decision type from string
  static DecisionType _parseDecisionType(String? type) {
    switch (type?.toUpperCase()) {
      case 'CONTRACEPTION':
        return DecisionType.contraception;
      case 'FAMILY_PLANNING':
        return DecisionType.familyPlanning;
      case 'HEALTH_GOAL':
        return DecisionType.healthGoal;
      case 'LIFESTYLE':
        return DecisionType.lifestyle;
      default:
        return DecisionType.familyPlanning;
    }
  }

  /// Parse decision status from string
  static DecisionStatus _parseDecisionStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PROPOSED':
        return DecisionStatus.proposed;
      case 'DISCUSSING':
        return DecisionStatus.discussing;
      case 'AGREED':
        return DecisionStatus.agreed;
      case 'DISAGREED':
        return DecisionStatus.disagreed;
      case 'POSTPONED':
        return DecisionStatus.postponed;
      default:
        return DecisionStatus.proposed;
    }
  }

  /// Get decision type display name
  String get typeDisplayName {
    switch (decisionType) {
      case DecisionType.contraception:
        return 'Contraception';
      case DecisionType.familyPlanning:
        return 'Family Planning';
      case DecisionType.healthGoal:
        return 'Health Goal';
      case DecisionType.lifestyle:
        return 'Lifestyle';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (decisionStatus) {
      case DecisionStatus.proposed:
        return 'Proposed';
      case DecisionStatus.discussing:
        return 'Discussing';
      case DecisionStatus.agreed:
        return 'Agreed';
      case DecisionStatus.disagreed:
        return 'Disagreed';
      case DecisionStatus.postponed:
        return 'Postponed';
    }
  }

  /// Get status color
  String get statusColor {
    switch (decisionStatus) {
      case DecisionStatus.proposed:
        return '#2196F3'; // Blue
      case DecisionStatus.discussing:
        return '#FF9800'; // Orange
      case DecisionStatus.agreed:
        return '#4CAF50'; // Green
      case DecisionStatus.disagreed:
        return '#F44336'; // Red
      case DecisionStatus.postponed:
        return '#9E9E9E'; // Grey
    }
  }

  /// Check if decision is pending
  bool get isPending {
    return decisionStatus == DecisionStatus.proposed ||
        decisionStatus == DecisionStatus.discussing;
  }

  /// Check if decision is resolved
  bool get isResolved {
    return decisionStatus == DecisionStatus.agreed ||
        decisionStatus == DecisionStatus.disagreed;
  }

  /// Get days until target date
  int? get daysUntilTarget {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final difference = targetDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Copy with method
  PartnerDecision copyWith({
    int? id,
    int? userId,
    int? partnerId,
    String? partnerName,
    DecisionType? decisionType,
    String? decisionTitle,
    String? decisionDescription,
    DecisionStatus? decisionStatus,
    DateTime? targetDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerDecision(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      decisionType: decisionType ?? this.decisionType,
      decisionTitle: decisionTitle ?? this.decisionTitle,
      decisionDescription: decisionDescription ?? this.decisionDescription,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PartnerDecision(id: $id, title: $decisionTitle, status: $decisionStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PartnerDecision && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
