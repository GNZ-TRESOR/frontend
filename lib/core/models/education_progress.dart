import 'package:json_annotation/json_annotation.dart';
import 'education_lesson.dart';
import 'user.dart';

part 'education_progress.g.dart';

/// Education Progress Model
@JsonSerializable()
class EducationProgress {
  final int? id;
  @JsonKey(name: 'user')
  final User? user;
  @JsonKey(name: 'lesson')
  final EducationLesson? lesson;
  final double progressPercentage;
  final bool isCompleted;
  final DateTime? completedAt;
  final int timeSpentMinutes;
  final double? quizScore;
  final int quizAttempts;
  final DateTime? lastAccessedAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EducationProgress({
    this.id,
    this.user,
    this.lesson,
    this.progressPercentage = 0.0,
    this.isCompleted = false,
    this.completedAt,
    this.timeSpentMinutes = 0,
    this.quizScore,
    this.quizAttempts = 0,
    this.lastAccessedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationProgress.fromJson(Map<String, dynamic> json) =>
      _$EducationProgressFromJson(json);

  Map<String, dynamic> toJson() => _$EducationProgressToJson(this);

  EducationProgress copyWith({
    int? id,
    User? user,
    EducationLesson? lesson,
    double? progressPercentage,
    bool? isCompleted,
    DateTime? completedAt,
    int? timeSpentMinutes,
    double? quizScore,
    int? quizAttempts,
    DateTime? lastAccessedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationProgress(
      id: id ?? this.id,
      user: user ?? this.user,
      lesson: lesson ?? this.lesson,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      quizScore: quizScore ?? this.quizScore,
      quizAttempts: quizAttempts ?? this.quizAttempts,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted time spent string
  String get formattedTimeSpent {
    if (timeSpentMinutes < 60) {
      return '${timeSpentMinutes} min';
    } else {
      final hours = timeSpentMinutes ~/ 60;
      final minutes = timeSpentMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}m';
      }
    }
  }

  /// Get progress status
  String get progressStatus {
    if (isCompleted) return 'Completed';
    if (progressPercentage > 0) return 'In Progress';
    return 'Not Started';
  }

  /// Get progress percentage as integer
  int get progressPercentageInt => progressPercentage.round();

  /// Check if progress is in progress (started but not completed)
  bool get isInProgress => progressPercentage > 0 && !isCompleted;

  /// Check if progress is not started
  bool get isNotStarted => progressPercentage == 0;

  /// Get quiz score percentage
  String get quizScorePercentage {
    if (quizScore == null) return 'No quiz taken';
    return '${(quizScore! * 100).round()}%';
  }

  /// Get formatted completion date
  String get formattedCompletionDate {
    if (completedAt == null) return 'Not completed';
    return '${completedAt!.day}/${completedAt!.month}/${completedAt!.year}';
  }

  /// Get formatted last accessed date
  String get formattedLastAccessedDate {
    if (lastAccessedAt == null) return 'Never accessed';
    final now = DateTime.now();
    final difference = now.difference(lastAccessedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if has notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Check if has quiz score
  bool get hasQuizScore => quizScore != null;

  /// Get lesson title (safe access)
  String get lessonTitle => lesson?.title ?? 'Unknown Lesson';

  /// Get lesson category (safe access)
  String get lessonCategory => lesson?.categoryDisplayName ?? 'Unknown Category';
}

/// Education Progress Statistics Model
@JsonSerializable()
class EducationProgressStatistics {
  final double averageProgress;
  final int completedLessons;
  final int totalTimeSpent;
  final int inProgressCount;

  const EducationProgressStatistics({
    this.averageProgress = 0.0,
    this.completedLessons = 0,
    this.totalTimeSpent = 0,
    this.inProgressCount = 0,
  });

  factory EducationProgressStatistics.fromJson(Map<String, dynamic> json) =>
      _$EducationProgressStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$EducationProgressStatisticsToJson(this);

  /// Get formatted total time spent
  String get formattedTotalTimeSpent {
    if (totalTimeSpent < 60) {
      return '${totalTimeSpent} min';
    } else {
      final hours = totalTimeSpent ~/ 60;
      final minutes = totalTimeSpent % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}m';
      }
    }
  }

  /// Get average progress percentage as integer
  int get averageProgressInt => averageProgress.round();
}

/// Lesson with Progress Model (for combined data)
@JsonSerializable()
class LessonWithProgress {
  final EducationLesson lesson;
  final EducationProgress? progress;

  const LessonWithProgress({
    required this.lesson,
    this.progress,
  });

  factory LessonWithProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonWithProgressFromJson(json);

  Map<String, dynamic> toJson() => _$LessonWithProgressToJson(this);

  /// Get progress percentage (0 if no progress)
  double get progressPercentage => progress?.progressPercentage ?? 0.0;

  /// Check if lesson is completed
  bool get isCompleted => progress?.isCompleted ?? false;

  /// Check if lesson is in progress
  bool get isInProgress => progress?.isInProgress ?? false;

  /// Check if lesson is not started
  bool get isNotStarted => progress?.isNotStarted ?? true;

  /// Get progress status
  String get progressStatus => progress?.progressStatus ?? 'Not Started';

  /// Get time spent
  int get timeSpentMinutes => progress?.timeSpentMinutes ?? 0;

  /// Get formatted time spent
  String get formattedTimeSpent => progress?.formattedTimeSpent ?? '0 min';
}

/// Education Dashboard Model
@JsonSerializable()
class EducationDashboard {
  final List<EducationProgress> recentProgress;
  final List<EducationProgress> completedLessons;
  final List<EducationProgress> inProgressLessons;
  final List<EducationLesson> recommendedLessons;
  final EducationProgressStatistics statistics;

  const EducationDashboard({
    this.recentProgress = const [],
    this.completedLessons = const [],
    this.inProgressLessons = const [],
    this.recommendedLessons = const [],
    required this.statistics,
  });

  factory EducationDashboard.fromJson(Map<String, dynamic> json) =>
      _$EducationDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$EducationDashboardToJson(this);
}
