import 'package:json_annotation/json_annotation.dart';

part 'side_effect.g.dart';

/// Severity levels for side effects
enum SideEffectSeverity {
  @JsonValue('MILD')
  mild,
  @JsonValue('MODERATE')
  moderate,
  @JsonValue('SEVERE')
  severe,
}

/// Frequency levels for side effects
enum SideEffectFrequency {
  @JsonValue('RARE')
  rare,
  @JsonValue('OCCASIONAL')
  occasional,
  @JsonValue('COMMON')
  common,
  @JsonValue('FREQUENT')
  frequent,
}

/// Side Effect Report Model
@JsonSerializable()
class SideEffectReport {
  final int? id;
  
  @JsonKey(name: 'contraception_method_id')
  final int contraceptionMethodId;
  
  @JsonKey(name: 'user_id')
  final int userId;
  
  @JsonKey(name: 'side_effect_name')
  final String sideEffectName;
  
  final SideEffectSeverity severity;
  final SideEffectFrequency frequency;
  final String? description;
  
  @JsonKey(name: 'date_reported')
  final DateTime dateReported;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const SideEffectReport({
    this.id,
    required this.contraceptionMethodId,
    required this.userId,
    required this.sideEffectName,
    required this.severity,
    required this.frequency,
    this.description,
    required this.dateReported,
    this.createdAt,
    this.updatedAt,
  });

  factory SideEffectReport.fromJson(Map<String, dynamic> json) =>
      _$SideEffectReportFromJson(json);

  Map<String, dynamic> toJson() => _$SideEffectReportToJson(this);

  SideEffectReport copyWith({
    int? id,
    int? contraceptionMethodId,
    int? userId,
    String? sideEffectName,
    SideEffectSeverity? severity,
    SideEffectFrequency? frequency,
    String? description,
    DateTime? dateReported,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SideEffectReport(
      id: id ?? this.id,
      contraceptionMethodId: contraceptionMethodId ?? this.contraceptionMethodId,
      userId: userId ?? this.userId,
      sideEffectName: sideEffectName ?? this.sideEffectName,
      severity: severity ?? this.severity,
      frequency: frequency ?? this.frequency,
      description: description ?? this.description,
      dateReported: dateReported ?? this.dateReported,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SideEffectReport &&
        other.id == id &&
        other.contraceptionMethodId == contraceptionMethodId &&
        other.userId == userId &&
        other.sideEffectName == sideEffectName &&
        other.severity == severity &&
        other.frequency == frequency &&
        other.description == description &&
        other.dateReported == dateReported;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      contraceptionMethodId,
      userId,
      sideEffectName,
      severity,
      frequency,
      description,
      dateReported,
    );
  }

  @override
  String toString() {
    return 'SideEffectReport(id: $id, contraceptionMethodId: $contraceptionMethodId, userId: $userId, sideEffectName: $sideEffectName, severity: $severity, frequency: $frequency, description: $description, dateReported: $dateReported)';
  }
}

/// Extensions for display names
extension SideEffectSeverityExtension on SideEffectSeverity {
  String get displayName {
    switch (this) {
      case SideEffectSeverity.mild:
        return 'Mild';
      case SideEffectSeverity.moderate:
        return 'Moderate';
      case SideEffectSeverity.severe:
        return 'Severe';
    }
  }
}

extension SideEffectFrequencyExtension on SideEffectFrequency {
  String get displayName {
    switch (this) {
      case SideEffectFrequency.rare:
        return 'Rare';
      case SideEffectFrequency.occasional:
        return 'Occasional';
      case SideEffectFrequency.common:
        return 'Common';
      case SideEffectFrequency.frequent:
        return 'Frequent';
    }
  }
}
