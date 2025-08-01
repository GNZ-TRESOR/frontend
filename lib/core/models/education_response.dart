import 'package:json_annotation/json_annotation.dart';
import 'education_lesson.dart';
import 'education_progress.dart';

part 'education_response.g.dart';

/// Base API Response Model (removed generic to avoid build issues)
@JsonSerializable()
class BaseApiResponse {
  final bool success;
  final String? message;

  const BaseApiResponse({required this.success, this.message});

  factory BaseApiResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseApiResponseToJson(this);
}

/// Education Lessons Response
@JsonSerializable()
class EducationLessonsResponse {
  final bool success;
  final String? message;
  final List<EducationLesson> lessons;
  final int? total;

  const EducationLessonsResponse({
    required this.success,
    this.message,
    this.lessons = const [],
    this.total,
  });

  factory EducationLessonsResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationLessonsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationLessonsResponseToJson(this);
}

/// Single Education Lesson Response
@JsonSerializable()
class EducationLessonResponse {
  final bool success;
  final String? message;
  final EducationLesson? lesson;

  const EducationLessonResponse({
    required this.success,
    this.message,
    this.lesson,
  });

  factory EducationLessonResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationLessonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationLessonResponseToJson(this);
}

/// Education Progress Response
@JsonSerializable()
class EducationProgressResponse {
  final bool success;
  final String? message;
  final List<EducationProgress> progress;
  final List<EducationProgress>? completedLessons;
  final List<EducationProgress>? inProgressLessons;
  final EducationProgressStatistics? statistics;

  const EducationProgressResponse({
    required this.success,
    this.message,
    this.progress = const [],
    this.completedLessons,
    this.inProgressLessons,
    this.statistics,
  });

  factory EducationProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationProgressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationProgressResponseToJson(this);
}

/// Single Education Progress Response
@JsonSerializable()
class SingleEducationProgressResponse {
  final bool success;
  final String? message;
  final EducationProgress? progress;

  const SingleEducationProgressResponse({
    required this.success,
    this.message,
    this.progress,
  });

  factory SingleEducationProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$SingleEducationProgressResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SingleEducationProgressResponseToJson(this);
}

/// Education Search Response
@JsonSerializable()
class EducationSearchResponse {
  final bool success;
  final String? message;
  final List<EducationLesson> searchResults;
  final int? total;

  const EducationSearchResponse({
    required this.success,
    this.message,
    this.searchResults = const [],
    this.total,
  });

  factory EducationSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationSearchResponseToJson(this);
}

/// Education Recommendations Response
@JsonSerializable()
class EducationRecommendationsResponse {
  final bool success;
  final String? message;
  final List<EducationLesson> recommendations;

  const EducationRecommendationsResponse({
    required this.success,
    this.message,
    this.recommendations = const [],
  });

  factory EducationRecommendationsResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$EducationRecommendationsResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EducationRecommendationsResponseToJson(this);
}

/// Education Category Lessons Response
@JsonSerializable()
class EducationCategoryLessonsResponse {
  final bool success;
  final String? message;
  final String? category;
  final List<EducationLesson>? lessons;
  final List<LessonWithProgress>? lessonsWithProgress;
  final int? total;

  const EducationCategoryLessonsResponse({
    required this.success,
    this.message,
    this.category,
    this.lessons,
    this.lessonsWithProgress,
    this.total,
  });

  factory EducationCategoryLessonsResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$EducationCategoryLessonsResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EducationCategoryLessonsResponseToJson(this);
}

/// Education Dashboard Response
@JsonSerializable()
class EducationDashboardResponse {
  final bool success;
  final String? message;
  final EducationDashboard? dashboard;

  const EducationDashboardResponse({
    required this.success,
    this.message,
    this.dashboard,
  });

  factory EducationDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationDashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationDashboardResponseToJson(this);
}

/// Education Analytics Response (for admin)
@JsonSerializable()
class EducationAnalyticsResponse {
  final bool success;
  final String? message;
  final EducationAnalytics? analytics;

  const EducationAnalyticsResponse({
    required this.success,
    this.message,
    this.analytics,
  });

  factory EducationAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$EducationAnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EducationAnalyticsResponseToJson(this);
}

/// Education Analytics Model (for admin)
@JsonSerializable()
class EducationAnalytics {
  final int totalLessons;
  final int publishedLessons;
  final int unpublishedLessons;
  final Map<String, int> categoryBreakdown;
  final Map<String, int> levelBreakdown;
  final List<EducationLesson> popularLessons;
  final int totalProgressRecords;
  final int completedLessonsCount;
  final double completionRate;

  const EducationAnalytics({
    this.totalLessons = 0,
    this.publishedLessons = 0,
    this.unpublishedLessons = 0,
    this.categoryBreakdown = const {},
    this.levelBreakdown = const {},
    this.popularLessons = const [],
    this.totalProgressRecords = 0,
    this.completedLessonsCount = 0,
    this.completionRate = 0.0,
  });

  factory EducationAnalytics.fromJson(Map<String, dynamic> json) =>
      _$EducationAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$EducationAnalyticsToJson(this);
}

/// File Upload Response
@JsonSerializable()
class FileUploadResponse {
  final bool success;
  final String? message;
  final String? mediaUrl;
  final EducationLesson? lesson;

  const FileUploadResponse({
    required this.success,
    this.message,
    this.mediaUrl,
    this.lesson,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);
}

/// Simple Success Response
@JsonSerializable()
class SimpleResponse {
  final bool success;
  final String? message;

  const SimpleResponse({required this.success, this.message});

  factory SimpleResponse.fromJson(Map<String, dynamic> json) =>
      _$SimpleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleResponseToJson(this);
}
