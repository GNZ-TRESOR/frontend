import 'package:json_annotation/json_annotation.dart';

part 'health_worker_reports.g.dart';

/// Contraception usage statistics for health workers
@JsonSerializable()
class ContraceptionUsageStats {
  final Map<String, Object> overallStats;
  final Map<String, ContraceptionTypeStats> usageByType;
  final DateRange dateRange;

  const ContraceptionUsageStats({
    required this.overallStats,
    required this.usageByType,
    required this.dateRange,
  });

  factory ContraceptionUsageStats.fromJson(Map<String, dynamic> json) =>
      _$ContraceptionUsageStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ContraceptionUsageStatsToJson(this);
}

/// Statistics for a specific contraception type
@JsonSerializable()
class ContraceptionTypeStats {
  final int totalUsers;
  final int activeUsers;
  final double averageUsageDays;
  final List<ContraceptionMethodSummary> methods;

  const ContraceptionTypeStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.averageUsageDays,
    required this.methods,
  });

  factory ContraceptionTypeStats.fromJson(Map<String, dynamic> json) =>
      _$ContraceptionTypeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ContraceptionTypeStatsToJson(this);
}

/// Summary of a contraception method for reports
@JsonSerializable()
class ContraceptionMethodSummary {
  final int id;
  final String name;
  final int userId;
  final String startDate;
  final String? endDate;
  final bool isActive;

  const ContraceptionMethodSummary({
    required this.id,
    required this.name,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory ContraceptionMethodSummary.fromJson(Map<String, dynamic> json) =>
      _$ContraceptionMethodSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ContraceptionMethodSummaryToJson(this);
}

/// Side effects statistics for health workers
@JsonSerializable()
class SideEffectsStats {
  final int totalReports;
  final int affectedUsers;
  final Map<String, SideEffectTypeStats> sideEffectsByType;
  final Map<String, int> commonSideEffects;
  final DateRange dateRange;

  const SideEffectsStats({
    required this.totalReports,
    required this.affectedUsers,
    required this.sideEffectsByType,
    required this.commonSideEffects,
    required this.dateRange,
  });

  factory SideEffectsStats.fromJson(Map<String, dynamic> json) =>
      _$SideEffectsStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SideEffectsStatsToJson(this);
}

/// Side effect statistics for a specific contraception type
@JsonSerializable()
class SideEffectTypeStats {
  final int totalReports;
  final int affectedUsers;
  final Map<String, int> sideEffectTypes;
  final Map<String, int> severityDistribution;

  const SideEffectTypeStats({
    required this.totalReports,
    required this.affectedUsers,
    required this.sideEffectTypes,
    required this.severityDistribution,
  });

  factory SideEffectTypeStats.fromJson(Map<String, dynamic> json) =>
      _$SideEffectTypeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SideEffectTypeStatsToJson(this);
}

/// User compliance statistics
@JsonSerializable()
class UserComplianceStats {
  final int totalActiveUsers;
  final List<UserCompliance> userCompliance;

  const UserComplianceStats({
    required this.totalActiveUsers,
    required this.userCompliance,
  });

  factory UserComplianceStats.fromJson(Map<String, dynamic> json) =>
      _$UserComplianceStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserComplianceStatsToJson(this);
}

/// Individual user compliance data
@JsonSerializable()
class UserCompliance {
  final int userId;
  final String userName;
  final int methodId;
  final String methodName;
  final String methodType;
  final String startDate;
  final int daysSinceStart;
  final String? nextAppointment;
  final bool hasUpcomingAppointment;
  final int sideEffectReports;
  final bool hasSideEffects;

  const UserCompliance({
    required this.userId,
    required this.userName,
    required this.methodId,
    required this.methodName,
    required this.methodType,
    required this.startDate,
    required this.daysSinceStart,
    this.nextAppointment,
    required this.hasUpcomingAppointment,
    required this.sideEffectReports,
    required this.hasSideEffects,
  });

  factory UserCompliance.fromJson(Map<String, dynamic> json) =>
      _$UserComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$UserComplianceToJson(this);
}

/// Dashboard data for health workers
@JsonSerializable()
class HealthWorkerDashboard {
  final int totalUsers;
  final int totalMethods;
  final int activeMethods;
  final int totalSideEffectReports;
  final int recentSideEffectReports;
  final int upcomingAppointments;

  const HealthWorkerDashboard({
    required this.totalUsers,
    required this.totalMethods,
    required this.activeMethods,
    required this.totalSideEffectReports,
    required this.recentSideEffectReports,
    required this.upcomingAppointments,
  });

  factory HealthWorkerDashboard.fromJson(Map<String, dynamic> json) =>
      _$HealthWorkerDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$HealthWorkerDashboardToJson(this);
}

/// Date range for filtering reports
@JsonSerializable()
class DateRange {
  final String start;
  final String end;

  const DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}

/// Usage tracking entry for contraceptive methods
@JsonSerializable()
class UsageTrackingEntry {
  final int? id;
  final int contraceptionMethodId;
  final int userId;
  final String usageDate;
  final String? notes;
  final bool missedDose;
  final DateTime? createdAt;

  const UsageTrackingEntry({
    this.id,
    required this.contraceptionMethodId,
    required this.userId,
    required this.usageDate,
    this.notes,
    this.missedDose = false,
    this.createdAt,
  });

  factory UsageTrackingEntry.fromJson(Map<String, dynamic> json) =>
      _$UsageTrackingEntryFromJson(json);

  Map<String, dynamic> toJson() => _$UsageTrackingEntryToJson(this);

  UsageTrackingEntry copyWith({
    int? id,
    int? contraceptionMethodId,
    int? userId,
    String? usageDate,
    String? notes,
    bool? missedDose,
    DateTime? createdAt,
  }) {
    return UsageTrackingEntry(
      id: id ?? this.id,
      contraceptionMethodId:
          contraceptionMethodId ?? this.contraceptionMethodId,
      userId: userId ?? this.userId,
      usageDate: usageDate ?? this.usageDate,
      notes: notes ?? this.notes,
      missedDose: missedDose ?? this.missedDose,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Simple usage statistics for widgets
@JsonSerializable()
class UsageStats {
  final int totalActiveUsers;
  final int totalMethodsInUse;
  final double averageUsageDuration;
  final List<PopularMethod> popularMethods;

  const UsageStats({
    required this.totalActiveUsers,
    required this.totalMethodsInUse,
    required this.averageUsageDuration,
    required this.popularMethods,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) =>
      _$UsageStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UsageStatsToJson(this);
}

@JsonSerializable()
class PopularMethod {
  final String methodName;
  final int userCount;

  const PopularMethod({required this.methodName, required this.userCount});

  factory PopularMethod.fromJson(Map<String, dynamic> json) =>
      _$PopularMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PopularMethodToJson(this);
}

/// Compliance data for widgets
@JsonSerializable()
class ComplianceData {
  final double overallComplianceRate;
  final int highComplianceUsers;
  final int lowComplianceUsers;
  final List<MethodCompliance> complianceByMethod;

  const ComplianceData({
    required this.overallComplianceRate,
    required this.highComplianceUsers,
    required this.lowComplianceUsers,
    required this.complianceByMethod,
  });

  factory ComplianceData.fromJson(Map<String, dynamic> json) =>
      _$ComplianceDataFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceDataToJson(this);
}

@JsonSerializable()
class MethodCompliance {
  final String methodName;
  final double complianceRate;

  const MethodCompliance({
    required this.methodName,
    required this.complianceRate,
  });

  factory MethodCompliance.fromJson(Map<String, dynamic> json) =>
      _$MethodComplianceFromJson(json);
  Map<String, dynamic> toJson() => _$MethodComplianceToJson(this);
}

/// Enhanced side effects stats for widgets
@JsonSerializable()
class EnhancedSideEffectsStats {
  final int totalReports;
  final int reportsThisMonth;
  final int severeCases;
  final List<CommonSideEffect> commonSideEffects;

  const EnhancedSideEffectsStats({
    required this.totalReports,
    required this.reportsThisMonth,
    required this.severeCases,
    required this.commonSideEffects,
  });

  factory EnhancedSideEffectsStats.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSideEffectsStatsFromJson(json);
  Map<String, dynamic> toJson() => _$EnhancedSideEffectsStatsToJson(this);
}

@JsonSerializable()
class CommonSideEffect {
  final String sideEffectType;
  final int count;
  final String severity;

  const CommonSideEffect({
    required this.sideEffectType,
    required this.count,
    required this.severity,
  });

  factory CommonSideEffect.fromJson(Map<String, dynamic> json) =>
      _$CommonSideEffectFromJson(json);
  Map<String, dynamic> toJson() => _$CommonSideEffectToJson(this);
}
