import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/education_lesson.dart';
import '../models/education_progress.dart';
import '../models/education_response.dart';
import '../services/education_service.dart';

/// Education State
class EducationState {
  final List<EducationLesson> lessons;
  final List<EducationLesson> featuredLessons;
  final List<EducationLesson> recommendedLessons;
  final List<EducationLesson> searchResults;
  final List<LessonWithProgress> categoryLessons;
  final List<EducationProgress> userProgress;
  final EducationDashboard? dashboard;
  final EducationLesson? selectedLesson;
  final EducationAnalytics? analytics;
  final bool isLoading;
  final bool isLoadingLessons;
  final bool isLoadingProgress;
  final bool isSearching;
  final String? error;
  final String searchQuery;
  final String selectedCategory;
  final String selectedLevel;
  final String selectedLanguage;

  const EducationState({
    this.lessons = const [],
    this.featuredLessons = const [],
    this.recommendedLessons = const [],
    this.searchResults = const [],
    this.categoryLessons = const [],
    this.userProgress = const [],
    this.dashboard,
    this.selectedLesson,
    this.analytics,
    this.isLoading = false,
    this.isLoadingLessons = false,
    this.isLoadingProgress = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.selectedLevel = 'all',
    this.selectedLanguage = 'rw',
  });

  EducationState copyWith({
    List<EducationLesson>? lessons,
    List<EducationLesson>? featuredLessons,
    List<EducationLesson>? recommendedLessons,
    List<EducationLesson>? searchResults,
    List<LessonWithProgress>? categoryLessons,
    List<EducationProgress>? userProgress,
    EducationDashboard? dashboard,
    EducationLesson? selectedLesson,
    EducationAnalytics? analytics,
    bool? isLoading,
    bool? isLoadingLessons,
    bool? isLoadingProgress,
    bool? isSearching,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    String? selectedLevel,
    String? selectedLanguage,
    bool clearError = false,
    bool clearSelectedLesson = false,
  }) {
    return EducationState(
      lessons: lessons ?? this.lessons,
      featuredLessons: featuredLessons ?? this.featuredLessons,
      recommendedLessons: recommendedLessons ?? this.recommendedLessons,
      searchResults: searchResults ?? this.searchResults,
      categoryLessons: categoryLessons ?? this.categoryLessons,
      userProgress: userProgress ?? this.userProgress,
      dashboard: dashboard ?? this.dashboard,
      selectedLesson:
          clearSelectedLesson ? null : (selectedLesson ?? this.selectedLesson),
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLessons: isLoadingLessons ?? this.isLoadingLessons,
      isLoadingProgress: isLoadingProgress ?? this.isLoadingProgress,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  /// Get lessons filtered by current filters
  List<EducationLesson> get filteredLessons {
    var filtered = lessons;

    if (selectedCategory != 'all') {
      filtered =
          filtered
              .where(
                (lesson) =>
                    lesson.category.toString().split('.').last.toLowerCase() ==
                    selectedCategory.toLowerCase(),
              )
              .toList();
    }

    if (selectedLevel != 'all') {
      filtered =
          filtered
              .where(
                (lesson) =>
                    lesson.level.toString().split('.').last.toLowerCase() ==
                    selectedLevel.toLowerCase(),
              )
              .toList();
    }

    return filtered;
  }

  /// Get completed lessons count
  int get completedLessonsCount {
    return userProgress.where((progress) => progress.isCompleted).length;
  }

  /// Get in-progress lessons count
  int get inProgressLessonsCount {
    return userProgress.where((progress) => progress.isInProgress).length;
  }

  /// Get total time spent in minutes
  int get totalTimeSpent {
    return userProgress.fold(
      0,
      (total, progress) => total + progress.timeSpentMinutes,
    );
  }

  /// Get average progress percentage
  double get averageProgress {
    if (userProgress.isEmpty) return 0.0;
    final totalProgress = userProgress.fold(
      0.0,
      (total, progress) => total + progress.progressPercentage,
    );
    return totalProgress / userProgress.length;
  }

  /// Check if has any loading state
  bool get hasAnyLoading =>
      isLoading || isLoadingLessons || isLoadingProgress || isSearching;
}

/// Education Notifier
class EducationNotifier extends StateNotifier<EducationState> {
  final EducationService _educationService;

  EducationNotifier(this._educationService) : super(const EducationState());

  /// Load all lessons
  Future<void> loadLessons({
    String? category,
    String? level,
    String? language,
  }) async {
    state = state.copyWith(isLoadingLessons: true, clearError: true);

    try {
      final lessons = await _educationService.getLessons(
        category: category,
        level: level,
        language: language,
      );

      // Get featured lessons (first 5 lessons)
      final featured = lessons.take(5).toList();

      state = state.copyWith(
        lessons: lessons,
        featuredLessons: featured,
        isLoadingLessons: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLessons: false,
        error: 'Failed to load lessons: $e',
      );
    }
  }

  /// Load lesson by ID
  Future<void> loadLessonById(int lessonId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final lesson = await _educationService.getLessonById(lessonId);
      state = state.copyWith(selectedLesson: lesson, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load lesson: $e',
      );
    }
  }

  /// Search lessons
  Future<void> searchLessons({
    required String query,
    String? category,
    String? level,
    String? language,
  }) async {
    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      clearError: true,
    );

    try {
      final results = await _educationService.searchLessons(
        query: query,
        category: category,
        level: level,
        language: language,
      );

      state = state.copyWith(searchResults: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: 'Failed to search lessons: $e',
      );
    }
  }

  /// Load recommended lessons for user
  Future<void> loadRecommendedLessons(int userId) async {
    try {
      final recommendations = await _educationService.getRecommendedLessons(
        userId,
      );
      state = state.copyWith(recommendedLessons: recommendations);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load recommendations: $e');
    }
  }

  /// Load lessons by category
  Future<void> loadLessonsByCategory({
    required String category,
    int? userId,
  }) async {
    state = state.copyWith(isLoadingLessons: true, clearError: true);

    try {
      final categoryLessons = await _educationService.getLessonsByCategory(
        category: category,
        userId: userId,
      );

      state = state.copyWith(
        categoryLessons: categoryLessons,
        selectedCategory: category,
        isLoadingLessons: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLessons: false,
        error: 'Failed to load category lessons: $e',
      );
    }
  }

  /// Load user progress
  Future<void> loadUserProgress(int userId) async {
    print('🔄 Loading user progress for user ID: $userId');
    state = state.copyWith(isLoadingProgress: true, clearError: true);

    try {
      print('📡 Calling education service...');

      // Add timeout to prevent infinite loading
      final progressResponse = await _educationService
          .getUserProgress(userId)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out after 30 seconds');
            },
          );

      print('📡 Response received: success=${progressResponse.success}');

      if (progressResponse.success) {
        print(
          '✅ Progress loaded successfully: ${progressResponse.progress.length} items',
        );
        state = state.copyWith(
          userProgress: progressResponse.progress,
          isLoadingProgress: false,
        );
      } else {
        print('❌ Progress loading failed: ${progressResponse.message}');
        state = state.copyWith(
          isLoadingProgress: false,
          error: progressResponse.message ?? 'Failed to load progress',
        );
      }
    } catch (e) {
      print('💥 Exception loading progress: $e');
      state = state.copyWith(
        isLoadingProgress: false,
        error: 'Failed to load user progress: $e',
      );
    }
  }

  /// Load progress for a specific lesson
  Future<void> loadLessonProgress(int userId, int lessonId) async {
    print('🔄 Loading lesson progress for user $userId, lesson $lessonId');
    state = state.copyWith(isLoadingProgress: true, clearError: true);

    try {
      print('📡 Calling education service for lesson progress...');
      final progressResponse = await _educationService.getLessonProgress(
        userId,
        lessonId,
      );
      print(
        '📡 Lesson progress response received: success=${progressResponse.success}',
      );

      if (progressResponse.success && progressResponse.progress != null) {
        print('✅ Lesson progress loaded successfully');
        // Update the user progress list with this specific lesson progress
        final currentProgress = List<EducationProgress>.from(
          state.userProgress,
        );
        final existingIndex = currentProgress.indexWhere(
          (p) => p.lesson?.id == lessonId,
        );

        if (existingIndex >= 0) {
          currentProgress[existingIndex] = progressResponse.progress!;
        } else {
          currentProgress.add(progressResponse.progress!);
        }

        state = state.copyWith(
          userProgress: currentProgress,
          isLoadingProgress: false,
        );
      } else {
        print('❌ Lesson progress loading failed: ${progressResponse.message}');
        state = state.copyWith(
          isLoadingProgress: false,
          error: progressResponse.message ?? 'Failed to load lesson progress',
        );
      }
    } catch (e) {
      print('💥 Exception loading lesson progress: $e');
      state = state.copyWith(
        isLoadingProgress: false,
        error: 'Failed to load lesson progress: $e',
      );
    }
  }

  /// Load user dashboard
  Future<void> loadUserDashboard(int userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final dashboard = await _educationService.getUserDashboard(userId);
      state = state.copyWith(dashboard: dashboard, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard: $e',
      );
    }
  }

  /// Save lesson notes
  Future<bool> saveLessonNotes({
    required int lessonId,
    required int userId,
    required String notes,
  }) async {
    try {
      final success = await _educationService.saveLessonNotes(
        lessonId: lessonId,
        userId: userId,
        notes: notes,
      );

      if (success) {
        // Reload user progress to reflect the updated notes
        await loadUserProgress(userId);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to save notes: $e');
      return false;
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
      final success = await _educationService.markLessonComplete(
        lessonId: lessonId,
        userId: userId,
        timeSpentMinutes: timeSpentMinutes,
        quizScore: quizScore,
      );

      if (success) {
        // Reload user progress and dashboard to reflect completion
        await Future.wait([
          loadUserProgress(userId),
          loadUserDashboard(userId),
        ]);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark lesson complete: $e');
      return false;
    }
  }

  /// Update filters
  void updateFilters({String? category, String? level, String? language}) {
    state = state.copyWith(
      selectedCategory: category ?? state.selectedCategory,
      selectedLevel: level ?? state.selectedLevel,
      selectedLanguage: language ?? state.selectedLanguage,
    );
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(searchResults: [], searchQuery: '');
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear selected lesson
  void clearSelectedLesson() {
    state = state.copyWith(clearSelectedLesson: true);
  }

  /// Refresh all data
  Future<void> refresh({int? userId}) async {
    await Future.wait([
      loadLessons(),
      if (userId != null) ...[
        loadUserProgress(userId),
        loadUserDashboard(userId),
        loadRecommendedLessons(userId),
      ],
    ]);
  }

  // ==================== ADMIN METHODS ====================

  /// Load all lessons (admin)
  Future<void> loadAllLessons() async {
    state = state.copyWith(isLoadingLessons: true, clearError: true);
    try {
      final lessons = await _educationService.getAllLessons();
      state = state.copyWith(lessons: lessons, isLoadingLessons: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingLessons: false,
        error: 'Failed to load all lessons: $e',
      );
    }
  }

  /// Load education analytics (admin)
  Future<void> loadEducationAnalytics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final analytics = await _educationService.getEducationAnalytics();
      state = state.copyWith(analytics: analytics, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load analytics: $e',
      );
    }
  }

  /// Create new lesson (admin)
  Future<EducationLesson?> createLesson(Map<String, dynamic> lessonData) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lesson = await _educationService.createLesson(lessonData);
      if (lesson != null) {
        // Add to current lessons list
        final updatedLessons = [...state.lessons, lesson];
        state = state.copyWith(lessons: updatedLessons, isLoading: false);
      }
      return lesson;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create lesson: $e',
      );
      return null;
    }
  }

  /// Update lesson (admin)
  Future<EducationLesson?> updateLesson(
    int lessonId,
    Map<String, dynamic> lessonData,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedLesson = await _educationService.updateLesson(
        lessonId,
        lessonData,
      );
      if (updatedLesson != null) {
        // Update in current lessons list
        final updatedLessons =
            state.lessons.map((lesson) {
              return lesson.id == lessonId ? updatedLesson : lesson;
            }).toList();
        state = state.copyWith(lessons: updatedLessons, isLoading: false);
      }
      return updatedLesson;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update lesson: $e',
      );
      return null;
    }
  }

  /// Delete lesson (admin)
  Future<bool> deleteLesson(int lessonId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await _educationService.deleteLesson(lessonId);
      if (success) {
        // Remove from current lessons list
        final updatedLessons =
            state.lessons.where((lesson) => lesson.id != lessonId).toList();
        state = state.copyWith(lessons: updatedLessons, isLoading: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete lesson: $e',
      );
      return false;
    }
  }

  /// Toggle lesson publish status (admin)
  Future<bool> toggleLessonPublishStatus(int lessonId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Find the lesson to get current status
      final lesson = state.lessons.firstWhere((l) => l.id == lessonId);
      final newStatus = !lesson.isPublished;

      final updatedLesson = await _educationService.updateLesson(lessonId, {
        'isPublished': newStatus,
      });

      if (updatedLesson != null) {
        // Update in current lessons list
        final updatedLessons =
            state.lessons.map((l) {
              return l.id == lessonId ? updatedLesson : l;
            }).toList();
        state = state.copyWith(lessons: updatedLessons, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle publish status: $e',
      );
      return false;
    }
  }
}

/// Education Provider
final educationProvider =
    StateNotifierProvider<EducationNotifier, EducationState>((ref) {
      final educationService = ref.watch(educationServiceProvider);
      return EducationNotifier(educationService);
    });

/// Convenience providers for specific data
final educationLessonsProvider = Provider<List<EducationLesson>>((ref) {
  return ref.watch(educationProvider).lessons;
});

final featuredLessonsProvider = Provider<List<EducationLesson>>((ref) {
  return ref.watch(educationProvider).featuredLessons;
});

final recommendedLessonsProvider = Provider<List<EducationLesson>>((ref) {
  return ref.watch(educationProvider).recommendedLessons;
});

final searchResultsProvider = Provider<List<EducationLesson>>((ref) {
  return ref.watch(educationProvider).searchResults;
});

final categoryLessonsProvider = Provider<List<LessonWithProgress>>((ref) {
  return ref.watch(educationProvider).categoryLessons;
});

final userProgressProvider = Provider<List<EducationProgress>>((ref) {
  return ref.watch(educationProvider).userProgress;
});

final educationDashboardProvider = Provider<EducationDashboard?>((ref) {
  return ref.watch(educationProvider).dashboard;
});

final selectedLessonProvider = Provider<EducationLesson?>((ref) {
  return ref.watch(educationProvider).selectedLesson;
});

final filteredLessonsProvider = Provider<List<EducationLesson>>((ref) {
  return ref.watch(educationProvider).filteredLessons;
});
