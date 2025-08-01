import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ubuzima_app/core/models/education_lesson.dart';
import 'package:ubuzima_app/core/models/education_progress.dart';
import 'package:ubuzima_app/core/models/user.dart';
import 'package:ubuzima_app/features/education/education_access_control.dart';
import 'package:ubuzima_app/core/providers/education_provider.dart';

void main() {
  group('Education Module Tests', () {
    // Test data
    final adminUser = User(
      id: 1,
      firstName: 'Admin',
      lastName: 'User',
      email: 'admin@test.com',
      role: 'admin',
      status: 'ACTIVE',
    );

    final healthWorkerUser = User(
      id: 2,
      firstName: 'Health',
      lastName: 'Worker',
      email: 'hw@test.com',
      role: 'healthWorker',
      status: 'ACTIVE',
    );

    final clientUser = User(
      id: 3,
      firstName: 'Client',
      lastName: 'User',
      email: 'client@test.com',
      role: 'client',
      status: 'ACTIVE',
    );

    final testLesson = EducationLesson(
      id: 1,
      title: 'Test Lesson',
      description: 'A test lesson for unit testing',
      content: 'This is test content',
      category: EducationCategory.familyPlanning,
      level: EducationLevel.beginner,
      language: 'en',
      isPublished: true,
      durationMinutes: 30,
      orderIndex: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testProgress = EducationProgress(
      id: 1,
      lesson: testLesson,
      user: clientUser,
      progressPercentage: 50.0,
      isCompleted: false,
      timeSpentMinutes: 15,
      quizAttempts: 1,
      lastAccessedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('Education Models', () {
      test('EducationLesson model should serialize/deserialize correctly', () {
        final json = testLesson.toJson();
        final fromJson = EducationLesson.fromJson(json);

        expect(fromJson.title, equals(testLesson.title));
        expect(fromJson.category, equals(testLesson.category));
        expect(fromJson.level, equals(testLesson.level));
        expect(fromJson.isPublished, equals(testLesson.isPublished));
      });

      test('EducationProgress model should have correct properties', () {
        expect(testProgress.progressPercentage, equals(50.0));
        expect(testProgress.isCompleted, isFalse);
        expect(testProgress.timeSpentMinutes, equals(15));
        expect(testProgress.lesson?.title, equals('Test Lesson'));
        expect(testProgress.user?.firstName, equals('Client'));
      });

      test('EducationLesson should have correct properties', () {
        expect(testLesson.title, equals('Test Lesson'));
        expect(testLesson.category, equals(EducationCategory.familyPlanning));
        expect(testLesson.level, equals(EducationLevel.beginner));
        expect(testLesson.isPublished, isTrue);
        expect(testLesson.durationMinutes, equals(30));
      });
    });

    group('Role-Based Access Control', () {
      test('Admin should have access to all education features', () {
        expect(EducationAccessControl.canManageLessons(adminUser), isTrue);
        expect(EducationAccessControl.canViewAnalytics(adminUser), isTrue);
        expect(EducationAccessControl.canPublishLessons(adminUser), isTrue);
        expect(EducationAccessControl.canUploadMedia(adminUser), isTrue);
        expect(EducationAccessControl.canDeleteLessons(adminUser), isTrue);
        expect(EducationAccessControl.canEditLessons(adminUser), isTrue);
        expect(EducationAccessControl.canManageCategories(adminUser), isTrue);
      });

      test('Health Worker should have limited access', () {
        expect(
          EducationAccessControl.canManageLessons(healthWorkerUser),
          isFalse,
        );
        expect(
          EducationAccessControl.canViewAnalytics(healthWorkerUser),
          isFalse,
        );
        expect(
          EducationAccessControl.canPublishLessons(healthWorkerUser),
          isFalse,
        );
        expect(
          EducationAccessControl.canUploadMedia(healthWorkerUser),
          isFalse,
        );
        expect(
          EducationAccessControl.canDeleteLessons(healthWorkerUser),
          isFalse,
        );
        expect(
          EducationAccessControl.canEditLessons(healthWorkerUser),
          isFalse,
        );
        expect(
          EducationAccessControl.canManageCategories(healthWorkerUser),
          isFalse,
        );

        // But should have access to viewing and assignment features
        expect(
          EducationAccessControl.canViewUserProgress(healthWorkerUser),
          isTrue,
        );
        expect(
          EducationAccessControl.canAssignLessons(healthWorkerUser),
          isTrue,
        );
      });

      test('Client should have basic access only', () {
        expect(EducationAccessControl.canManageLessons(clientUser), isFalse);
        expect(EducationAccessControl.canViewAnalytics(clientUser), isFalse);
        expect(EducationAccessControl.canPublishLessons(clientUser), isFalse);
        expect(EducationAccessControl.canUploadMedia(clientUser), isFalse);
        expect(EducationAccessControl.canDeleteLessons(clientUser), isFalse);
        expect(EducationAccessControl.canEditLessons(clientUser), isFalse);
        expect(EducationAccessControl.canManageCategories(clientUser), isFalse);
        expect(EducationAccessControl.canViewUserProgress(clientUser), isFalse);
        expect(EducationAccessControl.canAssignLessons(clientUser), isFalse);
      });

      test('Feature-based access control should work correctly', () {
        expect(
          EducationAccessControl.canAccessEducationFeature(
            adminUser,
            'lesson_management',
          ),
          isTrue,
        );
        expect(
          EducationAccessControl.canAccessEducationFeature(
            healthWorkerUser,
            'lesson_management',
          ),
          isFalse,
        );
        expect(
          EducationAccessControl.canAccessEducationFeature(
            clientUser,
            'lesson_viewing',
          ),
          isTrue,
        );
        expect(
          EducationAccessControl.canAccessEducationFeature(
            clientUser,
            'content_creation',
          ),
          isFalse,
        );
      });

      test('Should get correct accessible features for each role', () {
        final adminFeatures =
            EducationAccessControl.getAccessibleEducationFeatures(adminUser);
        final healthWorkerFeatures =
            EducationAccessControl.getAccessibleEducationFeatures(
              healthWorkerUser,
            );
        final clientFeatures =
            EducationAccessControl.getAccessibleEducationFeatures(clientUser);

        expect(adminFeatures.contains('lesson_management'), isTrue);
        expect(adminFeatures.contains('analytics_viewing'), isTrue);
        expect(adminFeatures.contains('lesson_viewing'), isTrue);

        expect(healthWorkerFeatures.contains('lesson_management'), isFalse);
        expect(
          healthWorkerFeatures.contains('client_progress_viewing'),
          isTrue,
        );
        expect(healthWorkerFeatures.contains('lesson_viewing'), isTrue);

        expect(clientFeatures.contains('lesson_viewing'), isTrue);
        expect(clientFeatures.contains('progress_tracking'), isTrue);
        expect(clientFeatures.contains('lesson_management'), isFalse);
      });
    });

    group('Education Provider', () {
      late ProviderContainer container;

      setUp(() {
        container = ProviderContainer();
      });

      tearDown(() {
        container.dispose();
      });

      test('Initial state should be correct', () {
        final state = container.read(educationProvider);

        expect(state.lessons, isEmpty);
        expect(state.userProgress, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.selectedCategory, equals('all'));
        expect(state.selectedLevel, equals('all'));
        expect(state.searchQuery, isEmpty);
      });
    });

    group('Education Navigation', () {
      test(
        'Should determine correct navigation routes for different roles',
        () {
          expect(
            EducationNavigation.canNavigateToEducationAdmin(adminUser),
            isTrue,
          );
          expect(
            EducationNavigation.canNavigateToEducationAdmin(healthWorkerUser),
            isFalse,
          );
          expect(
            EducationNavigation.canNavigateToEducationAdmin(clientUser),
            isFalse,
          );

          expect(
            EducationNavigation.canNavigateToEducationHealthWorker(adminUser),
            isTrue,
          );
          expect(
            EducationNavigation.canNavigateToEducationHealthWorker(
              healthWorkerUser,
            ),
            isTrue,
          );
          expect(
            EducationNavigation.canNavigateToEducationHealthWorker(clientUser),
            isFalse,
          );
        },
      );

      test('Should get correct menu items for each role', () {
        final adminMenuItems = EducationNavigation.getEducationMenuItems(
          adminUser,
        );
        final healthWorkerMenuItems = EducationNavigation.getEducationMenuItems(
          healthWorkerUser,
        );
        final clientMenuItems = EducationNavigation.getEducationMenuItems(
          clientUser,
        );

        // Admin should have all menu items
        expect(
          adminMenuItems.any((item) => item.feature == 'lesson_management'),
          isTrue,
        );
        expect(
          adminMenuItems.any((item) => item.feature == 'analytics_viewing'),
          isTrue,
        );
        expect(
          adminMenuItems.any((item) => item.feature == 'lesson_viewing'),
          isTrue,
        );

        // Health worker should have some menu items
        expect(
          healthWorkerMenuItems.any(
            (item) => item.feature == 'client_progress_viewing',
          ),
          isTrue,
        );
        expect(
          healthWorkerMenuItems.any((item) => item.feature == 'lesson_viewing'),
          isTrue,
        );
        expect(
          healthWorkerMenuItems.any(
            (item) => item.feature == 'lesson_management',
          ),
          isFalse,
        );

        // Client should have basic menu items
        expect(
          clientMenuItems.any((item) => item.feature == 'lesson_viewing'),
          isTrue,
        );
        expect(
          clientMenuItems.any((item) => item.feature == 'progress_tracking'),
          isTrue,
        );
        expect(
          clientMenuItems.any((item) => item.feature == 'lesson_management'),
          isFalse,
        );
      });
    });

    group('Education UI Helper', () {
      test('Should get correct app bar titles for different roles', () {
        expect(
          EducationUIHelper.getEducationAppBarTitle(adminUser),
          equals('Education Management'),
        );
        expect(
          EducationUIHelper.getEducationAppBarTitle(healthWorkerUser),
          equals('Education Center'),
        );
        expect(
          EducationUIHelper.getEducationAppBarTitle(clientUser),
          equals('Learning Center'),
        );
      });

      test('Should get appropriate empty state messages', () {
        final adminMessage = EducationUIHelper.getEmptyStateMessage(
          adminUser,
          'lessons',
        );
        final clientMessage = EducationUIHelper.getEmptyStateMessage(
          clientUser,
          'lessons',
        );

        expect(adminMessage.contains('Create your first lesson'), isTrue);
        expect(clientMessage.contains('Check back later'), isTrue);
      });

      test('Should get appropriate action button text', () {
        final adminButtonText = EducationUIHelper.getActionButtonText(
          adminUser,
          'create_lesson',
        );
        final clientButtonText = EducationUIHelper.getActionButtonText(
          clientUser,
          'start_lesson',
        );

        expect(adminButtonText, equals('Create New Lesson'));
        expect(clientButtonText, equals('Start Learning'));
      });
    });
  });
}
