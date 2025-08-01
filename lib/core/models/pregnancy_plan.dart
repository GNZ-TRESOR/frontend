import 'package:json_annotation/json_annotation.dart';

part 'pregnancy_plan.g.dart';

/// Pregnancy Plan Status enum
enum PregnancyPlanStatus {
  @JsonValue('PLANNING')
  planning,
  @JsonValue('TRYING')
  trying,
  @JsonValue('PREGNANT')
  pregnant,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('COMPLETED')
  completed,
}

/// Pregnancy Plan model for family planning
@JsonSerializable()
class PregnancyPlan {
  final int? id;
  final int userId;
  final int? partnerId;
  final String planName;
  final DateTime? targetConceptionDate;
  final PregnancyPlanStatus currentStatus;
  final String? preconceptionGoals;
  final String? healthPreparations;
  final String? lifestyleChanges;
  final String? medicalConsultations;
  final String? progressNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PregnancyPlan({
    this.id,
    required this.userId,
    this.partnerId,
    required this.planName,
    this.targetConceptionDate,
    this.currentStatus = PregnancyPlanStatus.planning,
    this.preconceptionGoals,
    this.healthPreparations,
    this.lifestyleChanges,
    this.medicalConsultations,
    this.progressNotes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory PregnancyPlan.fromJson(Map<String, dynamic> json) {
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
    if (json['partnerId'] != null) {
      partnerId = json['partnerId'] as int?;
    } else if (json['partner'] != null && json['partner'] is Map<String, dynamic>) {
      final partnerMap = json['partner'] as Map<String, dynamic>;
      partnerId = partnerMap['id'] as int?;
    }

    return PregnancyPlan(
      id: json['id'] as int?,
      userId: userId ?? 0,
      partnerId: partnerId,
      planName: json['planName'] as String? ?? '',
      targetConceptionDate: json['targetConceptionDate'] != null
          ? DateTime.parse(json['targetConceptionDate'] as String)
          : null,
      currentStatus: _parseStatus(json['currentStatus'] as String?),
      preconceptionGoals: json['preconceptionGoals'] as String?,
      healthPreparations: json['healthPreparations'] as String?,
      lifestyleChanges: json['lifestyleChanges'] as String?,
      medicalConsultations: json['medicalConsultations'] as String?,
      progressNotes: json['progressNotes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PregnancyPlanToJson(this);

  /// Parse status from string
  static PregnancyPlanStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PLANNING':
        return PregnancyPlanStatus.planning;
      case 'TRYING':
        return PregnancyPlanStatus.trying;
      case 'PREGNANT':
        return PregnancyPlanStatus.pregnant;
      case 'PAUSED':
        return PregnancyPlanStatus.paused;
      case 'COMPLETED':
        return PregnancyPlanStatus.completed;
      default:
        return PregnancyPlanStatus.planning;
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (currentStatus) {
      case PregnancyPlanStatus.planning:
        return 'Planning';
      case PregnancyPlanStatus.trying:
        return 'Trying to Conceive';
      case PregnancyPlanStatus.pregnant:
        return 'Pregnant';
      case PregnancyPlanStatus.paused:
        return 'Paused';
      case PregnancyPlanStatus.completed:
        return 'Completed';
    }
  }

  /// Get status color
  String get statusColor {
    switch (currentStatus) {
      case PregnancyPlanStatus.planning:
        return '#2196F3'; // Blue
      case PregnancyPlanStatus.trying:
        return '#FF9800'; // Orange
      case PregnancyPlanStatus.pregnant:
        return '#4CAF50'; // Green
      case PregnancyPlanStatus.paused:
        return '#9E9E9E'; // Grey
      case PregnancyPlanStatus.completed:
        return '#9C27B0'; // Purple
    }
  }

  /// Check if plan is active
  bool get isActive {
    return currentStatus == PregnancyPlanStatus.planning ||
        currentStatus == PregnancyPlanStatus.trying;
  }

  /// Get days until target conception
  int? get daysUntilTarget {
    if (targetConceptionDate == null) return null;
    final now = DateTime.now();
    final difference = targetConceptionDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Copy with method
  PregnancyPlan copyWith({
    int? id,
    int? userId,
    int? partnerId,
    String? planName,
    DateTime? targetConceptionDate,
    PregnancyPlanStatus? currentStatus,
    String? preconceptionGoals,
    String? healthPreparations,
    String? lifestyleChanges,
    String? medicalConsultations,
    String? progressNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PregnancyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      planName: planName ?? this.planName,
      targetConceptionDate: targetConceptionDate ?? this.targetConceptionDate,
      currentStatus: currentStatus ?? this.currentStatus,
      preconceptionGoals: preconceptionGoals ?? this.preconceptionGoals,
      healthPreparations: healthPreparations ?? this.healthPreparations,
      lifestyleChanges: lifestyleChanges ?? this.lifestyleChanges,
      medicalConsultations: medicalConsultations ?? this.medicalConsultations,
      progressNotes: progressNotes ?? this.progressNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PregnancyPlan(id: $id, planName: $planName, status: $currentStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PregnancyPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
