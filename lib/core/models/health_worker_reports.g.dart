// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_worker_reports.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContraceptionUsageStats _$ContraceptionUsageStatsFromJson(
  Map<String, dynamic> json,
) => ContraceptionUsageStats(
  overallStats: (json['overallStats'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, e as Object),
  ),
  usageByType: (json['usageByType'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, ContraceptionTypeStats.fromJson(e as Map<String, dynamic>)),
  ),
  dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContraceptionUsageStatsToJson(
  ContraceptionUsageStats instance,
) => <String, dynamic>{
  'overallStats': instance.overallStats,
  'usageByType': instance.usageByType,
  'dateRange': instance.dateRange,
};

ContraceptionTypeStats _$ContraceptionTypeStatsFromJson(
  Map<String, dynamic> json,
) => ContraceptionTypeStats(
  totalUsers: (json['totalUsers'] as num).toInt(),
  activeUsers: (json['activeUsers'] as num).toInt(),
  averageUsageDays: (json['averageUsageDays'] as num).toDouble(),
  methods:
      (json['methods'] as List<dynamic>)
          .map(
            (e) =>
                ContraceptionMethodSummary.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$ContraceptionTypeStatsToJson(
  ContraceptionTypeStats instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'averageUsageDays': instance.averageUsageDays,
  'methods': instance.methods,
};

ContraceptionMethodSummary _$ContraceptionMethodSummaryFromJson(
  Map<String, dynamic> json,
) => ContraceptionMethodSummary(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  userId: (json['userId'] as num).toInt(),
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$ContraceptionMethodSummaryToJson(
  ContraceptionMethodSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'userId': instance.userId,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'isActive': instance.isActive,
};

SideEffectsStats _$SideEffectsStatsFromJson(
  Map<String, dynamic> json,
) => SideEffectsStats(
  totalReports: (json['totalReports'] as num).toInt(),
  affectedUsers: (json['affectedUsers'] as num).toInt(),
  sideEffectsByType: (json['sideEffectsByType'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, SideEffectTypeStats.fromJson(e as Map<String, dynamic>)),
  ),
  commonSideEffects: Map<String, int>.from(json['commonSideEffects'] as Map),
  dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SideEffectsStatsToJson(SideEffectsStats instance) =>
    <String, dynamic>{
      'totalReports': instance.totalReports,
      'affectedUsers': instance.affectedUsers,
      'sideEffectsByType': instance.sideEffectsByType,
      'commonSideEffects': instance.commonSideEffects,
      'dateRange': instance.dateRange,
    };

SideEffectTypeStats _$SideEffectTypeStatsFromJson(Map<String, dynamic> json) =>
    SideEffectTypeStats(
      totalReports: (json['totalReports'] as num).toInt(),
      affectedUsers: (json['affectedUsers'] as num).toInt(),
      sideEffectTypes: Map<String, int>.from(json['sideEffectTypes'] as Map),
      severityDistribution: Map<String, int>.from(
        json['severityDistribution'] as Map,
      ),
    );

Map<String, dynamic> _$SideEffectTypeStatsToJson(
  SideEffectTypeStats instance,
) => <String, dynamic>{
  'totalReports': instance.totalReports,
  'affectedUsers': instance.affectedUsers,
  'sideEffectTypes': instance.sideEffectTypes,
  'severityDistribution': instance.severityDistribution,
};

UserComplianceStats _$UserComplianceStatsFromJson(Map<String, dynamic> json) =>
    UserComplianceStats(
      totalActiveUsers: (json['totalActiveUsers'] as num).toInt(),
      userCompliance:
          (json['userCompliance'] as List<dynamic>)
              .map((e) => UserCompliance.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$UserComplianceStatsToJson(
  UserComplianceStats instance,
) => <String, dynamic>{
  'totalActiveUsers': instance.totalActiveUsers,
  'userCompliance': instance.userCompliance,
};

UserCompliance _$UserComplianceFromJson(Map<String, dynamic> json) =>
    UserCompliance(
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      methodId: (json['methodId'] as num).toInt(),
      methodName: json['methodName'] as String,
      methodType: json['methodType'] as String,
      startDate: json['startDate'] as String,
      daysSinceStart: (json['daysSinceStart'] as num).toInt(),
      nextAppointment: json['nextAppointment'] as String?,
      hasUpcomingAppointment: json['hasUpcomingAppointment'] as bool,
      sideEffectReports: (json['sideEffectReports'] as num).toInt(),
      hasSideEffects: json['hasSideEffects'] as bool,
    );

Map<String, dynamic> _$UserComplianceToJson(UserCompliance instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'methodId': instance.methodId,
      'methodName': instance.methodName,
      'methodType': instance.methodType,
      'startDate': instance.startDate,
      'daysSinceStart': instance.daysSinceStart,
      'nextAppointment': instance.nextAppointment,
      'hasUpcomingAppointment': instance.hasUpcomingAppointment,
      'sideEffectReports': instance.sideEffectReports,
      'hasSideEffects': instance.hasSideEffects,
    };

HealthWorkerDashboard _$HealthWorkerDashboardFromJson(
  Map<String, dynamic> json,
) => HealthWorkerDashboard(
  totalUsers: (json['totalUsers'] as num).toInt(),
  totalMethods: (json['totalMethods'] as num).toInt(),
  activeMethods: (json['activeMethods'] as num).toInt(),
  totalSideEffectReports: (json['totalSideEffectReports'] as num).toInt(),
  recentSideEffectReports: (json['recentSideEffectReports'] as num).toInt(),
  upcomingAppointments: (json['upcomingAppointments'] as num).toInt(),
);

Map<String, dynamic> _$HealthWorkerDashboardToJson(
  HealthWorkerDashboard instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'totalMethods': instance.totalMethods,
  'activeMethods': instance.activeMethods,
  'totalSideEffectReports': instance.totalSideEffectReports,
  'recentSideEffectReports': instance.recentSideEffectReports,
  'upcomingAppointments': instance.upcomingAppointments,
};

DateRange _$DateRangeFromJson(Map<String, dynamic> json) =>
    DateRange(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
};

UsageTrackingEntry _$UsageTrackingEntryFromJson(Map<String, dynamic> json) =>
    UsageTrackingEntry(
      id: (json['id'] as num?)?.toInt(),
      contraceptionMethodId: (json['contraceptionMethodId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      usageDate: json['usageDate'] as String,
      notes: json['notes'] as String?,
      missedDose: json['missedDose'] as bool? ?? false,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UsageTrackingEntryToJson(UsageTrackingEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contraceptionMethodId': instance.contraceptionMethodId,
      'userId': instance.userId,
      'usageDate': instance.usageDate,
      'notes': instance.notes,
      'missedDose': instance.missedDose,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

UsageStats _$UsageStatsFromJson(Map<String, dynamic> json) => UsageStats(
  totalActiveUsers: (json['totalActiveUsers'] as num).toInt(),
  totalMethodsInUse: (json['totalMethodsInUse'] as num).toInt(),
  averageUsageDuration: (json['averageUsageDuration'] as num).toDouble(),
  popularMethods:
      (json['popularMethods'] as List<dynamic>)
          .map((e) => PopularMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UsageStatsToJson(UsageStats instance) =>
    <String, dynamic>{
      'totalActiveUsers': instance.totalActiveUsers,
      'totalMethodsInUse': instance.totalMethodsInUse,
      'averageUsageDuration': instance.averageUsageDuration,
      'popularMethods': instance.popularMethods,
    };

PopularMethod _$PopularMethodFromJson(Map<String, dynamic> json) =>
    PopularMethod(
      methodName: json['methodName'] as String,
      userCount: (json['userCount'] as num).toInt(),
    );

Map<String, dynamic> _$PopularMethodToJson(PopularMethod instance) =>
    <String, dynamic>{
      'methodName': instance.methodName,
      'userCount': instance.userCount,
    };

ComplianceData _$ComplianceDataFromJson(Map<String, dynamic> json) =>
    ComplianceData(
      overallComplianceRate: (json['overallComplianceRate'] as num).toDouble(),
      highComplianceUsers: (json['highComplianceUsers'] as num).toInt(),
      lowComplianceUsers: (json['lowComplianceUsers'] as num).toInt(),
      complianceByMethod:
          (json['complianceByMethod'] as List<dynamic>)
              .map((e) => MethodCompliance.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ComplianceDataToJson(ComplianceData instance) =>
    <String, dynamic>{
      'overallComplianceRate': instance.overallComplianceRate,
      'highComplianceUsers': instance.highComplianceUsers,
      'lowComplianceUsers': instance.lowComplianceUsers,
      'complianceByMethod': instance.complianceByMethod,
    };

MethodCompliance _$MethodComplianceFromJson(Map<String, dynamic> json) =>
    MethodCompliance(
      methodName: json['methodName'] as String,
      complianceRate: (json['complianceRate'] as num).toDouble(),
    );

Map<String, dynamic> _$MethodComplianceToJson(MethodCompliance instance) =>
    <String, dynamic>{
      'methodName': instance.methodName,
      'complianceRate': instance.complianceRate,
    };

EnhancedSideEffectsStats _$EnhancedSideEffectsStatsFromJson(
  Map<String, dynamic> json,
) => EnhancedSideEffectsStats(
  totalReports: (json['totalReports'] as num).toInt(),
  reportsThisMonth: (json['reportsThisMonth'] as num).toInt(),
  severeCases: (json['severeCases'] as num).toInt(),
  commonSideEffects:
      (json['commonSideEffects'] as List<dynamic>)
          .map((e) => CommonSideEffect.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$EnhancedSideEffectsStatsToJson(
  EnhancedSideEffectsStats instance,
) => <String, dynamic>{
  'totalReports': instance.totalReports,
  'reportsThisMonth': instance.reportsThisMonth,
  'severeCases': instance.severeCases,
  'commonSideEffects': instance.commonSideEffects,
};

CommonSideEffect _$CommonSideEffectFromJson(Map<String, dynamic> json) =>
    CommonSideEffect(
      sideEffectType: json['sideEffectType'] as String,
      count: (json['count'] as num).toInt(),
      severity: json['severity'] as String,
    );

Map<String, dynamic> _$CommonSideEffectToJson(CommonSideEffect instance) =>
    <String, dynamic>{
      'sideEffectType': instance.sideEffectType,
      'count': instance.count,
      'severity': instance.severity,
    };
