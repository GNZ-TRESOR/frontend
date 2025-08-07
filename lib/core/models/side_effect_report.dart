class SideEffectReport {
  final int id;
  final int userId;
  final int? contraceptionMethodId;
  final String symptom;
  final String severity;
  final String? notes;
  final DateTime reportedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SideEffectReport({
    required this.id,
    required this.userId,
    this.contraceptionMethodId,
    required this.symptom,
    required this.severity,
    this.notes,
    required this.reportedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SideEffectReport.fromJson(Map<String, dynamic> json) {
    return SideEffectReport(
      id: json['id'] as int,
      userId: json['userId'] as int,
      contraceptionMethodId: json['contraceptionMethodId'] as int?,
      symptom: json['symptom'] as String,
      severity: json['severity'] as String,
      notes: json['notes'] as String?,
      reportedDate: DateTime.parse(json['reportedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contraceptionMethodId': contraceptionMethodId,
      'symptom': symptom,
      'severity': severity,
      'notes': notes,
      'reportedDate': reportedDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SideEffectReport copyWith({
    int? id,
    int? userId,
    int? contraceptionMethodId,
    String? symptom,
    String? severity,
    String? notes,
    DateTime? reportedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SideEffectReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contraceptionMethodId:
          contraceptionMethodId ?? this.contraceptionMethodId,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      reportedDate: reportedDate ?? this.reportedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SideEffectReport(id: $id, symptom: $symptom, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SideEffectReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
