// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseApiResponse _$BaseApiResponseFromJson(Map<String, dynamic> json) =>
    BaseApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$BaseApiResponseToJson(BaseApiResponse instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};

EducationLessonsResponse _$EducationLessonsResponseFromJson(
  Map<String, dynamic> json,
) => EducationLessonsResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  lessons:
      (json['lessons'] as List<dynamic>?)
          ?.map((e) => EducationLesson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$EducationLessonsResponseToJson(
  EducationLessonsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'lessons': instance.lessons,
  'total': instance.total,
};

EducationLessonResponse _$EducationLessonResponseFromJson(
  Map<String, dynamic> json,
) => EducationLessonResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  lesson:
      json['lesson'] == null
          ? null
          : EducationLesson.fromJson(json['lesson'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EducationLessonResponseToJson(
  EducationLessonResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'lesson': instance.lesson,
};

EducationProgressResponse _$EducationProgressResponseFromJson(
  Map<String, dynamic> json,
) => EducationProgressResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  progress:
      (json['progress'] as List<dynamic>?)
          ?.map((e) => EducationProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  completedLessons:
      (json['completedLessons'] as List<dynamic>?)
          ?.map((e) => EducationProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
  inProgressLessons:
      (json['inProgressLessons'] as List<dynamic>?)
          ?.map((e) => EducationProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
  statistics:
      json['statistics'] == null
          ? null
          : EducationProgressStatistics.fromJson(
            json['statistics'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$EducationProgressResponseToJson(
  EducationProgressResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'progress': instance.progress,
  'completedLessons': instance.completedLessons,
  'inProgressLessons': instance.inProgressLessons,
  'statistics': instance.statistics,
};

SingleEducationProgressResponse _$SingleEducationProgressResponseFromJson(
  Map<String, dynamic> json,
) => SingleEducationProgressResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  progress:
      json['progress'] == null
          ? null
          : EducationProgress.fromJson(
            json['progress'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$SingleEducationProgressResponseToJson(
  SingleEducationProgressResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'progress': instance.progress,
};

EducationSearchResponse _$EducationSearchResponseFromJson(
  Map<String, dynamic> json,
) => EducationSearchResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  searchResults:
      (json['searchResults'] as List<dynamic>?)
          ?.map((e) => EducationLesson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$EducationSearchResponseToJson(
  EducationSearchResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'searchResults': instance.searchResults,
  'total': instance.total,
};

EducationRecommendationsResponse _$EducationRecommendationsResponseFromJson(
  Map<String, dynamic> json,
) => EducationRecommendationsResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map((e) => EducationLesson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$EducationRecommendationsResponseToJson(
  EducationRecommendationsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'recommendations': instance.recommendations,
};

EducationCategoryLessonsResponse _$EducationCategoryLessonsResponseFromJson(
  Map<String, dynamic> json,
) => EducationCategoryLessonsResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  category: json['category'] as String?,
  lessons:
      (json['lessons'] as List<dynamic>?)
          ?.map((e) => EducationLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
  lessonsWithProgress:
      (json['lessonsWithProgress'] as List<dynamic>?)
          ?.map((e) => LessonWithProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$EducationCategoryLessonsResponseToJson(
  EducationCategoryLessonsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'category': instance.category,
  'lessons': instance.lessons,
  'lessonsWithProgress': instance.lessonsWithProgress,
  'total': instance.total,
};

EducationDashboardResponse _$EducationDashboardResponseFromJson(
  Map<String, dynamic> json,
) => EducationDashboardResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  dashboard:
      json['dashboard'] == null
          ? null
          : EducationDashboard.fromJson(
            json['dashboard'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$EducationDashboardResponseToJson(
  EducationDashboardResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'dashboard': instance.dashboard,
};

EducationAnalyticsResponse _$EducationAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) => EducationAnalyticsResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  analytics:
      json['analytics'] == null
          ? null
          : EducationAnalytics.fromJson(
            json['analytics'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$EducationAnalyticsResponseToJson(
  EducationAnalyticsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'analytics': instance.analytics,
};

EducationAnalytics _$EducationAnalyticsFromJson(
  Map<String, dynamic> json,
) => EducationAnalytics(
  totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
  publishedLessons: (json['publishedLessons'] as num?)?.toInt() ?? 0,
  unpublishedLessons: (json['unpublishedLessons'] as num?)?.toInt() ?? 0,
  categoryBreakdown:
      (json['categoryBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  levelBreakdown:
      (json['levelBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  popularLessons:
      (json['popularLessons'] as List<dynamic>?)
          ?.map((e) => EducationLesson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalProgressRecords: (json['totalProgressRecords'] as num?)?.toInt() ?? 0,
  completedLessonsCount: (json['completedLessonsCount'] as num?)?.toInt() ?? 0,
  completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$EducationAnalyticsToJson(EducationAnalytics instance) =>
    <String, dynamic>{
      'totalLessons': instance.totalLessons,
      'publishedLessons': instance.publishedLessons,
      'unpublishedLessons': instance.unpublishedLessons,
      'categoryBreakdown': instance.categoryBreakdown,
      'levelBreakdown': instance.levelBreakdown,
      'popularLessons': instance.popularLessons,
      'totalProgressRecords': instance.totalProgressRecords,
      'completedLessonsCount': instance.completedLessonsCount,
      'completionRate': instance.completionRate,
    };

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      lesson:
          json['lesson'] == null
              ? null
              : EducationLesson.fromJson(
                json['lesson'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$FileUploadResponseToJson(FileUploadResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'mediaUrl': instance.mediaUrl,
      'lesson': instance.lesson,
    };

SimpleResponse _$SimpleResponseFromJson(Map<String, dynamic> json) =>
    SimpleResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SimpleResponseToJson(SimpleResponse instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};
