import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/education_lesson.dart';
import '../models/education_progress.dart';
import '../models/education_response.dart';
import 'api_service.dart';

/// Education Service for managing education lessons and progress
class EducationService {
  final ApiService _apiService;

  EducationService(this._apiService);

  // ==================== CLIENT EDUCATION ENDPOINTS ====================

  /// Get published education lessons
  Future<List<EducationLesson>> getLessons({
    String? category,
    String? level,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (level != null) queryParams['level'] = level;
      if (language != null) queryParams['language'] = language;

      final response = await _apiService.dio.get(
        '/education/lessons',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final lessons = response.data['lessons'] as List<dynamic>? ?? [];
        return lessons
            .map(
              (json) => EducationLesson.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load education lessons: $e');
    }
  }

  /// Get lesson by ID
  Future<EducationLesson?> getLessonById(int lessonId) async {
    try {
      final response = await _apiService.dio.get(
        '/education/lessons/$lessonId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final lessonData = response.data['lesson'];
        if (lessonData != null) {
          return EducationLesson.fromJson(lessonData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load lesson: $e');
    }
  }

  /// Search lessons
  Future<List<EducationLesson>> searchLessons({
    required String query,
    String? category,
    String? level,
    String? language,
  }) async {
    try {
      final queryParams = <String, dynamic>{'query': query};
      if (category != null) queryParams['category'] = category;
      if (level != null) queryParams['level'] = level;
      if (language != null) queryParams['language'] = language;

      final response = await _apiService.dio.get(
        '/education/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final searchResults =
            response.data['searchResults'] as List<dynamic>? ?? [];
        return searchResults
            .map(
              (json) => EducationLesson.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search lessons: $e');
    }
  }

  /// Get recommended lessons for user
  Future<List<EducationLesson>> getRecommendedLessons(int userId) async {
    try {
      final response = await _apiService.dio.get(
        '/education/recommendations/$userId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final recommendations =
            response.data['recommendations'] as List<dynamic>? ?? [];
        return recommendations
            .map(
              (json) => EducationLesson.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load recommended lessons: $e');
    }
  }

  /// Get lessons by category with progress info
  Future<List<LessonWithProgress>> getLessonsByCategory({
    required String category,
    int? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;

      final response = await _apiService.dio.get(
        '/education/categories/$category/lessons',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Check if we have lessons with progress or just lessons
        if (response.data['lessonsWithProgress'] != null) {
          final lessonsWithProgress =
              response.data['lessonsWithProgress'] as List<dynamic>? ?? [];
          return lessonsWithProgress
              .map(
                (json) =>
                    LessonWithProgress.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else if (response.data['lessons'] != null) {
          final lessons = response.data['lessons'] as List<dynamic>? ?? [];
          return lessons
              .map(
                (json) => LessonWithProgress(
                  lesson: EducationLesson.fromJson(
                    json as Map<String, dynamic>,
                  ),
                  progress: null,
                ),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load lessons by category: $e');
    }
  }

  /// Get user's education progress
  Future<EducationProgressResponse> getUserProgress(int userId) async {
    try {
      print('🌐 API: Making request to /education/progress/$userId');
      final response = await _apiService.dio.get('/education/progress/$userId');

      print('🌐 API: Response status: ${response.statusCode}');
      print('🌐 API: Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        print('🌐 API: Response success field: ${response.data['success']}');

        if (response.data['success'] == true) {
          print('🌐 API: Parsing response...');
          final result = EducationProgressResponse.fromJson(response.data);
          print(
            '🌐 API: Parsed successfully with ${result.progress.length} progress items',
          );
          return result;
        }
      }

      print('🌐 API: Request failed or success=false');
      return const EducationProgressResponse(
        success: false,
        message: 'Failed to load progress',
      );
    } catch (e) {
      print('🌐 API: Exception occurred: $e');
      throw Exception('Failed to load user progress: $e');
    }
  }

  /// Get progress for a specific lesson
  Future<SingleEducationProgressResponse> getLessonProgress(
    int userId,
    int lessonId,
  ) async {
    try {
      print('🌐 API: Making request to /education/progress/$userId/$lessonId');
      final response = await _apiService.dio.get(
        '/education/progress/$userId/$lessonId',
      );

      print('🌐 API: Lesson progress response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('🌐 API: Parsing lesson progress response...');
        final result = SingleEducationProgressResponse.fromJson(response.data);
        print('🌐 API: Lesson progress parsed successfully');
        return result;
      }

      print('🌐 API: Lesson progress request failed or success=false');
      return const SingleEducationProgressResponse(
        success: false,
        message: 'Failed to load lesson progress',
      );
    } catch (e) {
      print('🌐 API: Exception occurred loading lesson progress: $e');
      throw Exception('Failed to load lesson progress: $e');
    }
  }

  /// Get user's learning dashboard
  Future<EducationDashboard?> getUserDashboard(int userId) async {
    try {
      final response = await _apiService.dio.get(
        '/education/dashboard/$userId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dashboardData = response.data['dashboard'];
        if (dashboardData != null) {
          return EducationDashboard.fromJson(
            dashboardData as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user dashboard: $e');
    }
  }

  /// Save lesson notes
  Future<bool> saveLessonNotes({
    required int lessonId,
    required int userId,
    required String notes,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/education/lessons/$lessonId/notes',
        data: {'userId': userId, 'notes': notes},
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to save lesson notes: $e');
    }
  }

  /// Mark lesson as completed
  Future<bool> markLessonComplete({
    required int lessonId,
    required int userId,
    int? timeSpentMinutes,
    double? quizScore,
  }) async {
    try {
      final data = <String, dynamic>{'userId': userId};
      if (timeSpentMinutes != null) data['timeSpentMinutes'] = timeSpentMinutes;
      if (quizScore != null) data['quizScore'] = quizScore;

      final response = await _apiService.dio.post(
        '/education/lessons/$lessonId/complete',
        data: data,
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to mark lesson as completed: $e');
    }
  }

  /// Update lesson progress
  Future<bool> updateLessonProgress({
    required int lessonId,
    required int userId,
    required double progressPercentage,
    int? timeSpentMinutes,
  }) async {
    try {
      final data = <String, dynamic>{
        'userId': userId,
        'progressPercentage': progressPercentage,
      };
      if (timeSpentMinutes != null) data['timeSpentMinutes'] = timeSpentMinutes;

      final response = await _apiService.dio.put(
        '/education/lessons/$lessonId/progress',
        data: data,
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to update lesson progress: $e');
    }
  }

  // ==================== ADMIN EDUCATION ENDPOINTS ====================

  /// Get all lessons (admin)
  Future<List<EducationLesson>> getAllLessons() async {
    try {
      final response = await _apiService.dio.get('/education/admin/lessons');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final lessons = response.data['lessons'] as List<dynamic>? ?? [];
        return lessons
            .map(
              (json) => EducationLesson.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load all lessons: $e');
    }
  }

  /// Create new lesson (admin)
  Future<EducationLesson?> createLesson(Map<String, dynamic> lessonData) async {
    try {
      final response = await _apiService.dio.post(
        '/education/admin/lessons',
        data: lessonData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final lessonData = response.data['lesson'];
        if (lessonData != null) {
          return EducationLesson.fromJson(lessonData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create lesson: $e');
    }
  }

  /// Update lesson (admin)
  Future<EducationLesson?> updateLesson(
    int lessonId,
    Map<String, dynamic> lessonData,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/education/admin/lessons/$lessonId',
        data: lessonData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final lessonData = response.data['lesson'];
        if (lessonData != null) {
          return EducationLesson.fromJson(lessonData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update lesson: $e');
    }
  }

  /// Delete lesson (admin)
  Future<bool> deleteLesson(int lessonId) async {
    try {
      final response = await _apiService.dio.delete(
        '/education/admin/lessons/$lessonId',
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }

  /// Get education analytics (admin)
  Future<EducationAnalytics?> getEducationAnalytics() async {
    try {
      final response = await _apiService.dio.get('/education/admin/analytics');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final analyticsData = response.data['analytics'];
        if (analyticsData != null) {
          return EducationAnalytics.fromJson(
            analyticsData as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load education analytics: $e');
    }
  }
}

/// Provider for EducationService
final educationServiceProvider = Provider<EducationService>((ref) {
  final apiService = ApiService.instance;
  return EducationService(apiService);
});
