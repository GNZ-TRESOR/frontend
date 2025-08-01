import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

/// Education Module Role-Based Access Control
class EducationAccessControl {
  /// Admin-only education features
  static const List<String> adminEducationFeatures = [
    'lesson_management',
    'content_creation',
    'content_editing',
    'content_deletion',
    'analytics_viewing',
    'user_progress_viewing',
    'bulk_operations',
    'lesson_publishing',
    'category_management',
    'tag_management',
  ];

  /// Health Worker education features
  static const List<String> healthWorkerEducationFeatures = [
    'lesson_viewing',
    'progress_tracking',
    'client_progress_viewing',
    'content_recommendation',
    'lesson_assignment',
    'progress_reporting',
  ];

  /// Client education features
  static const List<String> clientEducationFeatures = [
    'lesson_viewing',
    'progress_tracking',
    'note_taking',
    'lesson_completion',
    'media_playback',
    'bookmark_lessons',
    'search_content',
  ];

  /// Check if user can access a specific education feature
  static bool canAccessEducationFeature(User? user, String feature) {
    if (user == null) return false;

    if (user.isAdmin) {
      return adminEducationFeatures.contains(feature) ||
          healthWorkerEducationFeatures.contains(feature) ||
          clientEducationFeatures.contains(feature);
    } else if (user.isHealthWorker) {
      return healthWorkerEducationFeatures.contains(feature) ||
          clientEducationFeatures.contains(feature);
    } else if (user.isClient) {
      return clientEducationFeatures.contains(feature);
    }

    return false;
  }

  /// Get accessible education features for user
  static List<String> getAccessibleEducationFeatures(User? user) {
    if (user == null) return [];

    if (user.isAdmin) {
      return [
        ...adminEducationFeatures,
        ...healthWorkerEducationFeatures,
        ...clientEducationFeatures,
      ];
    } else if (user.isHealthWorker) {
      return [...healthWorkerEducationFeatures, ...clientEducationFeatures];
    } else if (user.isClient) {
      return [...clientEducationFeatures];
    }

    return [];
  }

  /// Check if user can manage lessons (create, edit, delete)
  static bool canManageLessons(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can view analytics
  static bool canViewAnalytics(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can view other users' progress
  static bool canViewUserProgress(User? user) {
    return user?.isAdmin == true || user?.isHealthWorker == true;
  }

  /// Check if user can assign lessons to others
  static bool canAssignLessons(User? user) {
    return user?.isHealthWorker == true || user?.isAdmin == true;
  }

  /// Check if user can publish/unpublish lessons
  static bool canPublishLessons(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can upload media content
  static bool canUploadMedia(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can delete lessons
  static bool canDeleteLessons(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can view lesson in draft status
  static bool canViewDraftLessons(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can edit lesson content
  static bool canEditLessons(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can manage categories and tags
  static bool canManageCategories(User? user) {
    return user?.isAdmin == true;
  }
}

/// Education Role Access Guard Widget
class EducationRoleGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String? feature;
  final Widget? fallbackWidget;
  final String? errorMessage;

  const EducationRoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.feature,
    this.fallbackWidget,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return _buildAccessDenied(context, 'Authentication required');
    }

    // Check role-based access
    final hasRoleAccess = allowedRoles.any(
      (role) => role.toLowerCase() == user.role.toLowerCase(),
    );

    // Check feature-based access if specified
    bool hasFeatureAccess = true;
    if (feature != null) {
      hasFeatureAccess = EducationAccessControl.canAccessEducationFeature(
        user,
        feature!,
      );
    }

    if (!hasRoleAccess || !hasFeatureAccess) {
      return fallbackWidget ??
          _buildAccessDenied(
            context,
            errorMessage ?? 'Access denied for this education feature',
          );
    }

    return child;
  }

  Widget _buildAccessDenied(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Access Restricted',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

/// Education Feature Access Widget
class EducationFeatureAccess extends ConsumerWidget {
  final Widget child;
  final String feature;
  final Widget? fallbackWidget;
  final bool showFallback;

  const EducationFeatureAccess({
    super.key,
    required this.child,
    required this.feature,
    this.fallbackWidget,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (!EducationAccessControl.canAccessEducationFeature(user, feature)) {
      if (showFallback) {
        return fallbackWidget ?? const SizedBox.shrink();
      } else {
        return const SizedBox.shrink();
      }
    }

    return child;
  }
}

/// Education Admin Guard - Only for admin users
class EducationAdminGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallbackWidget;

  const EducationAdminGuard({
    super.key,
    required this.child,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EducationRoleGuard(
      allowedRoles: const ['admin'],
      fallbackWidget: fallbackWidget,
      errorMessage: 'Administrator access required for this education feature',
      child: child,
    );
  }
}

/// Education Health Worker Guard - For health workers and admins
class EducationHealthWorkerGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallbackWidget;

  const EducationHealthWorkerGuard({
    super.key,
    required this.child,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EducationRoleGuard(
      allowedRoles: const ['admin', 'healthWorker', 'health_worker'],
      fallbackWidget: fallbackWidget,
      errorMessage: 'Health worker access required for this education feature',
      child: child,
    );
  }
}

/// Education Client Guard - For all authenticated users
class EducationClientGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallbackWidget;

  const EducationClientGuard({
    super.key,
    required this.child,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EducationRoleGuard(
      allowedRoles: const [
        'admin',
        'healthWorker',
        'health_worker',
        'client',
        'user',
      ],
      fallbackWidget: fallbackWidget,
      errorMessage: 'User authentication required for this education feature',
      child: child,
    );
  }
}

/// Education Navigation Helper
class EducationNavigation {
  /// Navigate to appropriate education dashboard based on user role
  static void navigateToEducationDashboard(BuildContext context, User? user) {
    if (user == null) return;

    if (user.isAdmin) {
      Navigator.pushNamed(context, '/education/admin');
    } else if (user.isHealthWorker) {
      Navigator.pushNamed(context, '/education/health-worker');
    } else {
      Navigator.pushNamed(context, '/education/client');
    }
  }

  /// Check if user can navigate to education admin routes
  static bool canNavigateToEducationAdmin(User? user) {
    return user?.isAdmin == true;
  }

  /// Check if user can navigate to education health worker routes
  static bool canNavigateToEducationHealthWorker(User? user) {
    return user?.isHealthWorker == true || user?.isAdmin == true;
  }

  /// Get education menu items based on user role
  static List<EducationMenuItem> getEducationMenuItems(User? user) {
    final items = <EducationMenuItem>[];

    if (user == null) return items;

    // Client features (available to all)
    items.addAll([
      EducationMenuItem(
        title: 'Browse Lessons',
        icon: Icons.library_books,
        route: '/education/lessons',
        feature: 'lesson_viewing',
      ),
      EducationMenuItem(
        title: 'My Progress',
        icon: Icons.trending_up,
        route: '/education/progress',
        feature: 'progress_tracking',
      ),
    ]);

    // Health Worker features
    if (user.isHealthWorker || user.isAdmin) {
      items.addAll([
        EducationMenuItem(
          title: 'Client Progress',
          icon: Icons.people,
          route: '/education/client-progress',
          feature: 'client_progress_viewing',
        ),
        EducationMenuItem(
          title: 'Assign Lessons',
          icon: Icons.assignment,
          route: '/education/assign',
          feature: 'lesson_assignment',
        ),
      ]);
    }

    // Admin features
    if (user.isAdmin) {
      items.addAll([
        EducationMenuItem(
          title: 'Manage Lessons',
          icon: Icons.edit,
          route: '/education/admin/lessons',
          feature: 'lesson_management',
        ),
        EducationMenuItem(
          title: 'Analytics',
          icon: Icons.analytics,
          route: '/education/admin/analytics',
          feature: 'analytics_viewing',
        ),
        EducationMenuItem(
          title: 'Categories',
          icon: Icons.category,
          route: '/education/admin/categories',
          feature: 'category_management',
        ),
      ]);
    }

    return items;
  }
}

/// Education Menu Item Model
class EducationMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final String feature;

  const EducationMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.feature,
  });
}

/// Education Role-Based UI Helper
class EducationUIHelper {
  /// Get appropriate app bar title based on user role
  static String getEducationAppBarTitle(User? user) {
    if (user?.isAdmin == true) {
      return 'Education Management';
    } else if (user?.isHealthWorker == true) {
      return 'Education Center';
    } else {
      return 'Learning Center';
    }
  }

  /// Get role-appropriate empty state message
  static String getEmptyStateMessage(User? user, String context) {
    if (user?.isAdmin == true) {
      switch (context) {
        case 'lessons':
          return 'No lessons created yet. Create your first lesson to get started.';
        case 'analytics':
          return 'No analytics data available. Lessons need to be accessed by users first.';
        default:
          return 'No data available.';
      }
    } else if (user?.isHealthWorker == true) {
      switch (context) {
        case 'lessons':
          return 'No lessons available for your clients yet.';
        case 'progress':
          return 'No client progress data available.';
        default:
          return 'No data available.';
      }
    } else {
      switch (context) {
        case 'lessons':
          return 'No lessons available. Check back later for new content.';
        case 'progress':
          return 'Start learning to track your progress here.';
        default:
          return 'No data available.';
      }
    }
  }

  /// Get role-appropriate action button text
  static String getActionButtonText(User? user, String action) {
    if (user?.isAdmin == true) {
      switch (action) {
        case 'create_lesson':
          return 'Create New Lesson';
        case 'manage_content':
          return 'Manage Content';
        default:
          return 'Action';
      }
    } else if (user?.isHealthWorker == true) {
      switch (action) {
        case 'assign_lesson':
          return 'Assign to Client';
        case 'view_progress':
          return 'View Progress';
        default:
          return 'Action';
      }
    } else {
      switch (action) {
        case 'start_lesson':
          return 'Start Learning';
        case 'continue_lesson':
          return 'Continue';
        default:
          return 'Action';
      }
    }
  }
}
