/// Menstrual Cycle model for the family planning platform
class MenstrualCycle {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? flow;
  final List<String>? symptoms;
  final String? mood;
  final String? notes;
  final bool isPredicted;
  final DateTime? ovulationDate;
  final DateTime? nextPeriodDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenstrualCycle({
    this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.flow,
    this.symptoms,
    this.mood,
    this.notes,
    this.isPredicted = false,
    this.ovulationDate,
    this.nextPeriodDate,
    this.createdAt,
    this.updatedAt,
  });

  factory MenstrualCycle.fromJson(Map<String, dynamic> json) {
    return MenstrualCycle(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      cycleLength: json['cycleLength'],
      periodLength: json['flowDuration'], // Backend uses flowDuration
      flow:
          json['flowIntensity']?.toString(), // Backend uses flowIntensity enum
      symptoms:
          json['symptoms'] != null ? List<String>.from(json['symptoms']) : null,
      mood: json['mood'],
      notes: json['notes'],
      isPredicted: json['isPredicted'] ?? false,
      ovulationDate:
          json['ovulationDate'] != null
              ? DateTime.parse(json['ovulationDate'])
              : null,
      nextPeriodDate:
          json['nextPeriodDate'] != null
              ? DateTime.parse(json['nextPeriodDate'])
              : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate':
          startDate.toIso8601String().split('T')[0], // Send as date only
      'endDate': endDate?.toIso8601String().split('T')[0], // Send as date only
      'cycleLength': cycleLength,
      'flowDuration':
          periodLength, // Map periodLength to flowDuration for backend
      'flowIntensity': flow, // Map flow to flowIntensity for backend
      'notes': notes,
      'isPredicted': isPredicted,
      'ovulationDate':
          ovulationDate?.toIso8601String().split('T')[0], // Send as date only
      // Note: symptoms, mood, nextPeriodDate are not in the backend schema
      // createdAt and updatedAt are handled by the backend
    };
  }

  MenstrualCycle copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    String? flow,
    List<String>? symptoms,
    String? mood,
    String? notes,
    bool? isPredicted,
    DateTime? ovulationDate,
    DateTime? nextPeriodDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenstrualCycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      isPredicted: isPredicted ?? this.isPredicted,
      ovulationDate: ovulationDate ?? this.ovulationDate,
      nextPeriodDate: nextPeriodDate ?? this.nextPeriodDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted start date
  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  /// Get formatted end date
  String get formattedEndDate {
    if (endDate == null) return 'Ongoing';
    return '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }

  /// Get cycle status
  String get cycleStatus {
    if (isPredicted) return 'Predicted';
    if (endDate == null) return 'Active';
    return 'Completed';
  }

  /// Get flow intensity display
  String get flowDisplay {
    switch (flow?.toLowerCase()) {
      case 'light':
        return 'Light Flow';
      case 'medium':
        return 'Medium Flow';
      case 'heavy':
        return 'Heavy Flow';
      case 'spotting':
        return 'Spotting';
      default:
        return flow ?? 'Not specified';
    }
  }

  /// Get symptoms as formatted string
  String get symptomsString {
    if (symptoms == null || symptoms!.isEmpty) return 'No symptoms recorded';
    return symptoms!.join(', ');
  }

  /// Check if cycle is current
  bool get isCurrent {
    final now = DateTime.now();
    if (endDate == null) {
      // If no end date, check if start date is within reasonable period length
      final daysSinceStart = now.difference(startDate).inDays;
      return daysSinceStart >= 0 && daysSinceStart <= 10;
    }
    return now.isAfter(startDate) && now.isBefore(endDate!);
  }

  /// Check if in fertile window
  bool get isInFertileWindow {
    if (ovulationDate == null) return false;
    final now = DateTime.now();
    final fertileStart = ovulationDate!.subtract(const Duration(days: 5));
    final fertileEnd = ovulationDate!.add(const Duration(days: 1));
    return now.isAfter(fertileStart) && now.isBefore(fertileEnd);
  }

  /// Get days until next period
  int? get daysUntilNextPeriod {
    if (nextPeriodDate == null) return null;
    final now = DateTime.now();
    final difference = nextPeriodDate!.difference(now);
    return difference.inDays;
  }

  /// Get cycle phase
  String get cyclePhase {
    if (ovulationDate == null) return 'Unknown';

    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    final daysSinceOvulation =
        ovulationDate != null ? now.difference(ovulationDate!).inDays : null;

    if (daysSinceStart <= (periodLength ?? 5)) {
      return 'Menstrual';
    } else if (daysSinceOvulation != null && daysSinceOvulation.abs() <= 1) {
      return 'Ovulation';
    } else if (daysSinceOvulation != null && daysSinceOvulation > 0) {
      return 'Luteal';
    } else {
      return 'Follicular';
    }
  }

  /// Get cycle length or default
  int get effectiveCycleLength => cycleLength ?? 28;

  /// Get period length or default
  int get effectivePeriodLength => periodLength ?? 5;

  @override
  String toString() {
    return 'MenstrualCycle{id: $id, startDate: $startDate, cycleLength: $cycleLength, status: $cycleStatus}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenstrualCycle &&
        other.id == id &&
        other.startDate == startDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ startDate.hashCode;
  }
}
