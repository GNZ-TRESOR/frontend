/// STI Test Record model for the family planning platform
class StiTestRecord {
  final int? id;
  final int? userId;
  final String testType;
  final DateTime testDate;
  final String? testLocation;
  final String? testProvider;
  final String resultStatus;
  final DateTime? resultDate;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final String? notes;
  final bool isConfidential;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StiTestRecord({
    this.id,
    this.userId,
    required this.testType,
    required this.testDate,
    this.testLocation,
    this.testProvider,
    this.resultStatus = 'PENDING',
    this.resultDate,
    this.followUpRequired = false,
    this.followUpDate,
    this.notes,
    this.isConfidential = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory StiTestRecord.fromJson(Map<String, dynamic> json) {
    // Handle userId - backend returns nested user object, we need just the ID
    int? userId;
    if (json['userId'] != null) {
      userId = json['userId'] as int?;
    } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final userMap = json['user'] as Map<String, dynamic>;
      userId = userMap['id'] as int?;
    }

    return StiTestRecord(
      id: json['id'],
      userId: userId,
      testType: json['testType'] ?? '',
      testDate:
          json['testDate'] != null
              ? DateTime.parse(json['testDate'])
              : DateTime.now(),
      testLocation: json['testLocation'],
      testProvider: json['testProvider'],
      resultStatus: json['resultStatus'] ?? 'PENDING',
      resultDate:
          json['resultDate'] != null
              ? DateTime.parse(json['resultDate'])
              : null,
      followUpRequired: json['followUpRequired'] ?? false,
      followUpDate:
          json['followUpDate'] != null
              ? DateTime.parse(json['followUpDate'])
              : null,
      notes: json['notes'],
      isConfidential: json['isConfidential'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'testType': testType,
      'testDate': testDate.toIso8601String().split('T')[0], // Date only
      'testLocation': testLocation,
      'testProvider': testProvider,
      'resultStatus': resultStatus,
      'resultDate': resultDate?.toIso8601String().split('T')[0], // Date only
      'followUpRequired': followUpRequired,
      'followUpDate':
          followUpDate?.toIso8601String().split('T')[0], // Date only
      'notes': notes,
      'isConfidential': isConfidential,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  StiTestRecord copyWith({
    int? id,
    int? userId,
    String? testType,
    DateTime? testDate,
    String? testLocation,
    String? testProvider,
    String? resultStatus,
    DateTime? resultDate,
    bool? followUpRequired,
    DateTime? followUpDate,
    String? notes,
    bool? isConfidential,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StiTestRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testType: testType ?? this.testType,
      testDate: testDate ?? this.testDate,
      testLocation: testLocation ?? this.testLocation,
      testProvider: testProvider ?? this.testProvider,
      resultStatus: resultStatus ?? this.resultStatus,
      resultDate: resultDate ?? this.resultDate,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      isConfidential: isConfidential ?? this.isConfidential,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get test type display name
  String get testTypeDisplayName {
    switch (testType.toUpperCase()) {
      case 'HIV':
        return 'HIV Test';
      case 'SYPHILIS':
        return 'Syphilis Test';
      case 'GONORRHEA':
        return 'Gonorrhea Test';
      case 'CHLAMYDIA':
        return 'Chlamydia Test';
      case 'HEPATITIS_B':
        return 'Hepatitis B Test';
      case 'HERPES':
        return 'Herpes Test';
      case 'COMPREHENSIVE':
        return 'Comprehensive STI Panel';
      default:
        return testType;
    }
  }

  /// Get result status display name
  String get resultStatusDisplayName {
    switch (resultStatus.toUpperCase()) {
      case 'NEGATIVE':
        return 'Negative';
      case 'POSITIVE':
        return 'Positive';
      case 'INCONCLUSIVE':
        return 'Inconclusive';
      case 'PENDING':
        return 'Pending';
      default:
        return resultStatus;
    }
  }

  /// Get result status color
  String get resultStatusColor {
    switch (resultStatus.toUpperCase()) {
      case 'NEGATIVE':
        return 'success'; // Green
      case 'POSITIVE':
        return 'error'; // Red
      case 'INCONCLUSIVE':
        return 'warning'; // Orange
      case 'PENDING':
        return 'info'; // Blue
      default:
        return 'info';
    }
  }

  /// Check if test is overdue for follow-up
  bool get isFollowUpOverdue {
    if (!followUpRequired || followUpDate == null) return false;
    return DateTime.now().isAfter(followUpDate!);
  }

  /// Get days until follow-up
  int? get daysUntilFollowUp {
    if (!followUpRequired || followUpDate == null) return null;
    return followUpDate!.difference(DateTime.now()).inDays;
  }

  /// Check if test is recent (within last 6 months)
  bool get isRecent {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return testDate.isAfter(sixMonthsAgo);
  }

  /// Get formatted test date
  String get formattedTestDate {
    return '${testDate.day}/${testDate.month}/${testDate.year}';
  }

  /// Get formatted result date
  String? get formattedResultDate {
    if (resultDate == null) return null;
    return '${resultDate!.day}/${resultDate!.month}/${resultDate!.year}';
  }

  /// Get formatted follow-up date
  String? get formattedFollowUpDate {
    if (followUpDate == null) return null;
    return '${followUpDate!.day}/${followUpDate!.month}/${followUpDate!.year}';
  }

  @override
  String toString() {
    return 'StiTestRecord(id: $id, testType: $testType, testDate: $testDate, resultStatus: $resultStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StiTestRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// STI Test Types enum for easy access
class StiTestType {
  static const String hiv = 'HIV';
  static const String syphilis = 'SYPHILIS';
  static const String gonorrhea = 'GONORRHEA';
  static const String chlamydia = 'CHLAMYDIA';
  static const String hepatitisB = 'HEPATITIS_B';
  static const String herpes = 'HERPES';
  static const String comprehensive = 'COMPREHENSIVE';

  static const List<String> all = [
    hiv,
    syphilis,
    gonorrhea,
    chlamydia,
    hepatitisB,
    herpes,
    comprehensive,
  ];

  static String getDisplayName(String type) {
    switch (type.toUpperCase()) {
      case hiv:
        return 'HIV Test';
      case syphilis:
        return 'Syphilis Test';
      case gonorrhea:
        return 'Gonorrhea Test';
      case chlamydia:
        return 'Chlamydia Test';
      case hepatitisB:
        return 'Hepatitis B Test';
      case herpes:
        return 'Herpes Test';
      case comprehensive:
        return 'Comprehensive STI Panel';
      default:
        return type;
    }
  }
}

/// Test Result Status enum for easy access
class TestResultStatus {
  static const String negative = 'NEGATIVE';
  static const String positive = 'POSITIVE';
  static const String inconclusive = 'INCONCLUSIVE';
  static const String pending = 'PENDING';

  static const List<String> all = [negative, positive, inconclusive, pending];

  static String getDisplayName(String status) {
    switch (status.toUpperCase()) {
      case negative:
        return 'Negative';
      case positive:
        return 'Positive';
      case inconclusive:
        return 'Inconclusive';
      case pending:
        return 'Pending';
      default:
        return status;
    }
  }
}
