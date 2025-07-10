import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import 'http_client.dart';

/// Education lesson model
class EducationLesson {
  final String id;
  final String title;
  final String titleKinyarwanda;
  final String content;
  final String contentKinyarwanda;
  final String category;
  final String difficulty;
  final int estimatedDuration;
  final List<String> tags;
  final String? videoUrl;
  final String? audioUrl;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationLesson({
    required this.id,
    required this.title,
    required this.titleKinyarwanda,
    required this.content,
    required this.contentKinyarwanda,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.tags,
    this.videoUrl,
    this.audioUrl,
    required this.imageUrls,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EducationLesson.fromJson(Map<String, dynamic> json) {
    return EducationLesson(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      titleKinyarwanda: json['titleKinyarwanda'] ?? '',
      content: json['content'] ?? '',
      contentKinyarwanda: json['contentKinyarwanda'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'BEGINNER',
      estimatedDuration: json['estimatedDuration'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleKinyarwanda': titleKinyarwanda,
      'content': content,
      'contentKinyarwanda': contentKinyarwanda,
      'category': category,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Education progress model
class EducationProgress {
  final String id;
  final String userId;
  final String lessonId;
  final double progressPercentage;
  final bool isCompleted;
  final DateTime? completedAt;
  final int timeSpent;
  final Map<String, dynamic>? quizResults;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.progressPercentage,
    this.isCompleted = false,
    this.completedAt,
    this.timeSpent = 0,
    this.quizResults,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EducationProgress.fromJson(Map<String, dynamic> json) {
    return EducationProgress(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      lessonId: json['lessonId']?.toString() ?? '',
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      timeSpent: json['timeSpent'] ?? 0,
      quizResults: json['quizResults'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'progressPercentage': progressPercentage,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'timeSpent': timeSpent,
      'quizResults': quizResults,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Service for managing health education content
class EducationService {
  final HttpClient _httpClient = HttpClient();

  /// Get all education lessons
  Future<List<EducationLesson>> getEducationLessons({
    int page = 0,
    int limit = 20,
    String? category,
    String? difficulty,
    List<String>? tags,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (tags != null) queryParams['tags'] = tags.join(',');
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final response = await _httpClient.get(
        '/education',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final lessonsData = apiResponse.data as Map<String, dynamic>;
          final lessonsList = lessonsData['lessons'] as List<dynamic>;

          return lessonsList
              .map(
                (json) =>
                    EducationLesson.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching education lessons: $e');
      return [];
    }
  }

  /// Get education lesson by ID
  Future<EducationLesson?> getEducationLessonById(String lessonId) async {
    try {
      final response = await _httpClient.get('/education/$lessonId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return EducationLesson.fromJson(
            apiResponse.data as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching education lesson: $e');
      return null;
    }
  }

  /// Search education lessons
  Future<List<EducationLesson>> searchEducationLessons(String query) async {
    try {
      final response = await _httpClient.get(
        '/education/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final lessonsData = apiResponse.data as Map<String, dynamic>;
          final lessonsList = lessonsData['lessons'] as List<dynamic>;

          return lessonsList
              .map(
                (json) =>
                    EducationLesson.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching education lessons: $e');
      return [];
    }
  }

  /// Get lessons by category
  Future<List<EducationLesson>> getLessonsByCategory(String category) async {
    return getEducationLessons(category: category);
  }

  /// Get user's education progress
  Future<List<EducationProgress>> getUserProgress(String userId) async {
    try {
      final response = await _httpClient.get(
        '/education/progress',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final progressData = apiResponse.data as Map<String, dynamic>;
          final progressList = progressData['progress'] as List<dynamic>;

          return progressList
              .map(
                (json) =>
                    EducationProgress.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching user progress: $e');
      return [];
    }
  }

  /// Update lesson progress
  Future<EducationProgress?> updateLessonProgress({
    required String userId,
    required String lessonId,
    required double progressPercentage,
    int? timeSpent,
    bool? isCompleted,
    Map<String, dynamic>? quizResults,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'lessonId': lessonId,
        'progressPercentage': progressPercentage,
        'timeSpent': timeSpent,
        'isCompleted': isCompleted,
        'quizResults': quizResults,
      };

      final response = await _httpClient.post(
        '/education/progress',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return EducationProgress.fromJson(
            apiResponse.data as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error updating lesson progress: $e');
      return null;
    }
  }

  /// Mark lesson as completed
  Future<bool> markLessonCompleted(String userId, String lessonId) async {
    final progress = await updateLessonProgress(
      userId: userId,
      lessonId: lessonId,
      progressPercentage: 100.0,
      isCompleted: true,
    );
    return progress != null;
  }

  /// Get education categories
  Future<List<String>> getEducationCategories() async {
    try {
      final response = await _httpClient.get('/education/categories');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final categoriesData = apiResponse.data as Map<String, dynamic>;
          final categoriesList = categoriesData['categories'] as List<dynamic>;

          return categoriesList.map((category) => category.toString()).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching education categories: $e');
      return [];
    }
  }

  /// Get recommended lessons for user
  Future<List<EducationLesson>> getRecommendedLessons(String userId) async {
    try {
      final response = await _httpClient.get(
        '/education/recommendations/$userId',
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final lessonsData = apiResponse.data as Map<String, dynamic>;
          final lessonsList = lessonsData['recommendations'] as List<dynamic>;

          return lessonsList
              .map(
                (json) =>
                    EducationLesson.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching recommended lessons: $e');
      return [];
    }
  }

  /// Get education statistics
  Future<Map<String, dynamic>> getEducationStatistics(String userId) async {
    try {
      final response = await _httpClient.get('/education/statistics/$userId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return apiResponse.data as Map<String, dynamic>;
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error fetching education statistics: $e');
      return {};
    }
  }
}
