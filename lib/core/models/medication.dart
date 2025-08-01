/// Medication model for the family planning platform
class Medication {
  final int? id;
  final String name;
  final String? genericName;
  final String dosage;
  final String frequency;
  final String? instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? purpose;
  final List<String>? sideEffects;
  final String? notes;
  final bool isActive;
  final List<MedicationReminder>? reminders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medication({
    this.id,
    required this.name,
    this.genericName,
    required this.dosage,
    required this.frequency,
    this.instructions,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.purpose,
    this.sideEffects,
    this.notes,
    this.isActive = true,
    this.reminders,
    this.createdAt,
    this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'] ?? '',
      genericName: json['genericName'],
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      instructions: json['instructions'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      prescribedBy: json['prescribedBy'],
      purpose: json['purpose'],
      sideEffects:
          json['sideEffects'] != null
              ? List<String>.from(json['sideEffects'])
              : null,
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      reminders:
          json['reminders'] != null
              ? (json['reminders'] as List)
                  .map((r) => MedicationReminder.fromJson(r))
                  .toList()
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
      'name': name,
      'genericName': genericName,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescribedBy': prescribedBy,
      'purpose': purpose,
      'sideEffects': sideEffects,
      'notes': notes,
      'isActive': isActive,
      'reminders': reminders?.map((r) => r.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    String? genericName,
    String? dosage,
    String? frequency,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? purpose,
    List<String>? sideEffects,
    String? notes,
    bool? isActive,
    List<MedicationReminder>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      purpose: purpose ?? this.purpose,
      sideEffects: sideEffects ?? this.sideEffects,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      reminders: reminders ?? this.reminders,
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

  /// Get medication status
  String get status {
    if (!isActive) return 'Inactive';
    if (endDate != null && DateTime.now().isAfter(endDate!)) {
      return 'Completed';
    }
    return 'Active';
  }

  /// Get display name (name or generic name)
  String get displayName {
    if (genericName != null && genericName!.isNotEmpty) {
      return '$name ($genericName)';
    }
    return name;
  }

  /// Get side effects as formatted string
  String get sideEffectsString {
    if (sideEffects == null || sideEffects!.isEmpty) {
      return 'No side effects recorded';
    }
    return sideEffects!.join(', ');
  }

  /// Check if medication has side effects
  bool get hasSideEffects => sideEffects != null && sideEffects!.isNotEmpty;

  /// Check if medication has reminders
  bool get hasReminders => reminders != null && reminders!.isNotEmpty;

  /// Get next dose time
  DateTime? get nextDoseTime {
    if (!hasReminders) return null;

    final now = DateTime.now();
    DateTime? nextTime;

    for (final reminder in reminders!) {
      final reminderTime = reminder.getNextReminderTime();
      if (reminderTime != null && reminderTime.isAfter(now)) {
        if (nextTime == null || reminderTime.isBefore(nextTime)) {
          nextTime = reminderTime;
        }
      }
    }

    return nextTime;
  }

  /// Get type display name
  String get typeDisplayName {
    switch (purpose?.toLowerCase()) {
      case 'contraception':
        return 'Contraceptive';
      case 'hormone':
        return 'Hormone Therapy';
      case 'supplement':
        return 'Supplement';
      case 'antibiotic':
        return 'Antibiotic';
      case 'pain_relief':
        return 'Pain Relief';
      default:
        return 'Medication';
    }
  }

  /// Get frequency display name
  String get frequencyDisplayName {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Once daily';
      case 'twice_daily':
        return 'Twice daily';
      case 'three_times_daily':
        return 'Three times daily';
      case 'weekly':
        return 'Once weekly';
      case 'as_needed':
        return 'As needed';
      default:
        return frequency;
    }
  }

  /// Get duration in days
  int get durationInDays {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays;
  }

  /// Get active reminders
  List<MedicationReminder> get activeReminders {
    if (!hasReminders) return [];
    return reminders!.where((r) => r.isActive).toList();
  }

  /// Check if medication is due for next dose
  bool get isDueForNextDose {
    if (!hasReminders) return false;
    final now = DateTime.now();
    return activeReminders.any((reminder) => reminder.isTimeForReminder(now));
  }

  /// Get days remaining
  int? get daysRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    final difference = endDate!.difference(now);
    return difference.inDays;
  }

  /// Check if medication is expiring soon (within 7 days)
  bool get isExpiringSoon {
    final days = daysRemaining;
    return days != null && days <= 7 && days > 0;
  }

  @override
  String toString() {
    return 'Medication{id: $id, name: $name, dosage: $dosage, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication &&
        other.id == id &&
        other.name == name &&
        other.dosage == dosage;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ dosage.hashCode;
  }
}

/// Medication Reminder model
class MedicationReminder {
  final int? id;
  final int medicationId;
  final String time; // Format: "HH:mm"
  final List<int> daysOfWeek; // 1-7 (Monday-Sunday)
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicationReminder({
    this.id,
    required this.medicationId,
    required this.time,
    required this.daysOfWeek,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'],
      medicationId: json['medicationId'],
      time: json['time'] ?? '08:00',
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'time': time,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Check if it's time for this reminder
  bool isTimeForReminder(DateTime now) {
    if (!isActive) return false;

    // Check if today is in the days of week
    final todayWeekday = now.weekday;
    if (!daysOfWeek.contains(todayWeekday)) return false;

    // Parse reminder time
    final timeParts = time.split(':');
    final reminderHour = int.parse(timeParts[0]);
    final reminderMinute = int.parse(timeParts[1]);

    // Check if current time matches reminder time (within 30 minutes)
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );

    final difference = now.difference(reminderTime).abs();
    return difference.inMinutes <= 30;
  }

  /// Get formatted time
  String get formattedTime {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get days of week as string
  String get daysOfWeekString {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = daysOfWeek.map((day) => dayNames[day - 1]).toList();

    if (selectedDays.length == 7) return 'Daily';
    if (selectedDays.length == 5 &&
        daysOfWeek.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays';
    }
    if (selectedDays.length == 2 &&
        daysOfWeek.contains(6) &&
        daysOfWeek.contains(7)) {
      return 'Weekends';
    }

    return selectedDays.join(', ');
  }

  /// Get next reminder time
  DateTime? getNextReminderTime() {
    if (!isActive) return null;

    final now = DateTime.now();
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Find the next occurrence of this reminder
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final weekday = checkDate.weekday; // 1 = Monday, 7 = Sunday

      if (daysOfWeek.contains(weekday)) {
        final reminderTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          hour,
          minute,
        );

        if (reminderTime.isAfter(now)) {
          return reminderTime;
        }
      }
    }

    return null;
  }

  /// Check if reminder is enabled
  bool get isEnabled => isActive;
}
