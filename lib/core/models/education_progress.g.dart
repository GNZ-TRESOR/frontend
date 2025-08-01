// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationProgress _$EducationProgressFromJson(
  Map<String, dynamic> json,
) => EducationProgress(
  id: (json['id'] as num?)?.toInt(),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  lesson:
      json['lesson'] == null
          ? null
          : EducationLesson.fromJson(json['lesson'] as Map<String, dynamic>),
  progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
  timeSpentMinutes: (json['timeSpentMinutes'] as num?)?.toInt() ?? 0,
  quizScore: (json['quizScore'] as num?)?.toDouble(),
  quizAttempts: (json['quizAttempts'] as num?)?.toInt() ?? 0,
  lastAccessedAt:
      json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
  notes: json['notes'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EducationProgressToJson(EducationProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'lesson': instance.lesson,
      'progressPercentage': instance.progressPercentage,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'timeSpentMinutes': instance.timeSpentMinutes,
      'quizScore': instance.quizScore,
      'quizAttempts': instance.quizAttempts,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

EducationProgressStatistics _$EducationProgressStatisticsFromJson(
  Map<String, dynamic> json,
) => EducationProgressStatistics(
  averageProgress: (json['averageProgress'] as num?)?.toDouble() ?? 0.0,
  completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
  totalTimeSpent: (json['totalTimeSpent'] as num?)?.toInt() ?? 0,
  inProgressCount: (json['inProgressCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EducationProgressStatisticsToJson(
  EducationProgressStatistics instance,
) => <String, dynamic>{
  'averageProgress': instance.averageProgress,
  'completedLessons': instance.completedLessons,
  'totalTimeSpent': instance.totalTimeSpent,
  'inProgressCount': instance.inProgressCount,
};

LessonWithProgress _$LessonWithProgressFromJson(Map<String, dynamic> json) =>
    LessonWithProgress(
      lesson: EducationLesson.fromJson(json['lesson'] as Map<String, dynamic>),
      progress:
          json['progress'] == null
              ? null
              : EducationProgress.fromJson(
                json['progress'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$LessonWithProgressToJson(LessonWithProgress instance) =>
    <String, dynamic>{'lesson': instance.lesson, 'progress': instance.progress};

EducationDashboard _$EducationDashboardFromJson(
  Map<String, dynamic> json,
) => EducationDashboard(
  recentProgress:
      (json['recentProgress'] as List<dynamic>?)
          ?.map((e) => EducationProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  completedLessons:
      (json['completedLessons'] as List<dynamic>?)
          ?.map((e) => EducationProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  inProgressLessons:
      (json['inProgressLessons'] as List<dynamic>?)
          ?.map((e) => EducationProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recommendedLessons:
      (json['recommendedLessons'] as List<dynamic>?)
          ?.map((e) => EducationLesson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  statistics: EducationProgressStatistics.fromJson(
    json['statistics'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$EducationDashboardToJson(EducationDashboard instance) =>
    <String, dynamic>{
      'recentProgress': instance.recentProgress,
      'completedLessons': instance.completedLessons,
      'inProgressLessons': instance.inProgressLessons,
      'recommendedLessons': instance.recommendedLessons,
      'statistics': instance.statistics,
    };
