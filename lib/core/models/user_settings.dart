/// User Settings model for the family planning platform
class UserSettings {
  final int? id;
  final int userId;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final bool appointmentReminders;
  final bool medicationReminders;
  final bool periodReminders;
  final bool healthTips;
  final bool marketingEmails;
  final String privacyLevel;
  final bool shareDataForResearch;
  final bool biometricLogin;
  final int reminderFrequency;
  final String timeZone;
  final String dateFormat;
  final String timeFormat;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserSettings({
    this.id,
    required this.userId,
    this.language = 'en',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.appointmentReminders = true,
    this.medicationReminders = true,
    this.periodReminders = true,
    this.healthTips = true,
    this.marketingEmails = false,
    this.privacyLevel = 'standard',
    this.shareDataForResearch = false,
    this.biometricLogin = false,
    this.reminderFrequency = 1,
    this.timeZone = 'Africa/Kigali',
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = '24h',
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      userId: json['userId'],
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] ?? true,
      smsNotificationsEnabled: json['smsNotificationsEnabled'] ?? false,
      appointmentReminders: json['appointmentReminders'] ?? true,
      medicationReminders: json['medicationReminders'] ?? true,
      periodReminders: json['periodReminders'] ?? true,
      healthTips: json['healthTips'] ?? true,
      marketingEmails: json['marketingEmails'] ?? false,
      privacyLevel: json['privacyLevel'] ?? 'standard',
      shareDataForResearch: json['shareDataForResearch'] ?? false,
      biometricLogin: json['biometricLogin'] ?? false,
      reminderFrequency: json['reminderFrequency'] ?? 1,
      timeZone: json['timeZone'] ?? 'Africa/Kigali',
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      timeFormat: json['timeFormat'] ?? '24h',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'appointmentReminders': appointmentReminders,
      'medicationReminders': medicationReminders,
      'periodReminders': periodReminders,
      'healthTips': healthTips,
      'marketingEmails': marketingEmails,
      'privacyLevel': privacyLevel,
      'shareDataForResearch': shareDataForResearch,
      'biometricLogin': biometricLogin,
      'reminderFrequency': reminderFrequency,
      'timeZone': timeZone,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserSettings copyWith({
    int? id,
    int? userId,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? appointmentReminders,
    bool? medicationReminders,
    bool? periodReminders,
    bool? healthTips,
    bool? marketingEmails,
    String? privacyLevel,
    bool? shareDataForResearch,
    bool? biometricLogin,
    int? reminderFrequency,
    String? timeZone,
    String? dateFormat,
    String? timeFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      medicationReminders: medicationReminders ?? this.medicationReminders,
      periodReminders: periodReminders ?? this.periodReminders,
      healthTips: healthTips ?? this.healthTips,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      shareDataForResearch: shareDataForResearch ?? this.shareDataForResearch,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      timeZone: timeZone ?? this.timeZone,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get language display name
  String get languageDisplayName {
    switch (language.toLowerCase()) {
      case 'en':
        return 'English';
      case 'rw':
        return 'Kinyarwanda';
      case 'fr':
        return 'Français';
      default:
        return language;
    }
  }

  /// Get theme display name
  String get themeDisplayName {
    switch (theme.toLowerCase()) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System Default';
      default:
        return theme;
    }
  }

  /// Get privacy level display name
  String get privacyLevelDisplayName {
    switch (privacyLevel.toLowerCase()) {
      case 'minimal':
        return 'Minimal';
      case 'standard':
        return 'Standard';
      case 'enhanced':
        return 'Enhanced';
      default:
        return privacyLevel;
    }
  }

  /// Get reminder frequency display name
  String get reminderFrequencyDisplayName {
    switch (reminderFrequency) {
      case 1:
        return 'Daily';
      case 7:
        return 'Weekly';
      case 30:
        return 'Monthly';
      default:
        return '$reminderFrequency days';
    }
  }

  /// Get date format display name
  String get dateFormatDisplayName {
    switch (dateFormat) {
      case 'dd/MM/yyyy':
        return 'DD/MM/YYYY';
      case 'MM/dd/yyyy':
        return 'MM/DD/YYYY';
      case 'yyyy-MM-dd':
        return 'YYYY-MM-DD';
      default:
        return dateFormat;
    }
  }

  /// Get time format display name
  String get timeFormatDisplayName {
    switch (timeFormat) {
      case '12h':
        return '12 Hour';
      case '24h':
        return '24 Hour';
      default:
        return timeFormat;
    }
  }

  /// Check if any notifications are enabled
  bool get hasNotificationsEnabled {
    return notificationsEnabled && 
           (pushNotificationsEnabled || 
            emailNotificationsEnabled || 
            smsNotificationsEnabled);
  }

  /// Check if any reminders are enabled
  bool get hasRemindersEnabled {
    return appointmentReminders || 
           medicationReminders || 
           periodReminders;
  }

  /// Get notification summary
  String get notificationSummary {
    if (!notificationsEnabled) return 'All notifications disabled';
    
    final enabledTypes = <String>[];
    if (pushNotificationsEnabled) enabledTypes.add('Push');
    if (emailNotificationsEnabled) enabledTypes.add('Email');
    if (smsNotificationsEnabled) enabledTypes.add('SMS');
    
    if (enabledTypes.isEmpty) return 'No notification types enabled';
    return enabledTypes.join(', ');
  }

  /// Get privacy summary
  String get privacySummary {
    final features = <String>[];
    if (shareDataForResearch) features.add('Research sharing');
    if (biometricLogin) features.add('Biometric login');
    
    if (features.isEmpty) return 'Standard privacy settings';
    return features.join(', ');
  }

  @override
  String toString() {
    return 'UserSettings{id: $id, userId: $userId, language: $language, theme: $theme}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
