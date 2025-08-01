import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

/// Role-based access guard widget that restricts access based on user roles
class RoleAccessGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedRoles;
  final Widget? fallbackWidget;
  final String? errorMessage;

  const RoleAccessGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.fallbackWidget,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return _buildAccessDenied(context, 'User not authenticated');
    }

    final userRole = user.role.toLowerCase();
    final hasAccess = allowedRoles.any(
      (role) => role.toLowerCase() == userRole,
    );

    if (!hasAccess) {
      return fallbackWidget ??
          _buildAccessDenied(
            context,
            errorMessage ?? 'Access denied for role: ${user.role}',
          );
    }

    return child;
  }

  // Static helper methods for role checking

  /// Check if user can access health facilities (location-based feature)
  static bool canAccessHealthFacilities(String role) {
    return role.toLowerCase() == 'client' ||
        role.toLowerCase() == 'health_worker';
  }

  /// Check if user can access community events
  static bool canAccessCommunityEvents(String role) {
    return role.toLowerCase() == 'client' ||
        role.toLowerCase() == 'health_worker' ||
        role.toLowerCase() == 'admin';
  }

  /// Check if user can access admin features
  static bool canAccessAdminFeatures(String role) {
    return role.toLowerCase() == 'admin';
  }

  /// Check if user can access health worker features
  static bool canAccessHealthWorkerFeatures(String role) {
    return role.toLowerCase() == 'health_worker' ||
        role.toLowerCase() == 'admin';
  }

  Widget _buildAccessDenied(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
      ),
    );
  }
}

/// Role-based feature access helper
class RoleFeatureAccess {
  /// Admin-only features
  static const List<String> adminFeatures = [
    'user_management',
    'staff_management',
    'system_settings',
    'facility_management',
    'content_management',
    'research_data',
    'analytics_dashboard',
    'audit_logs',
  ];

  /// Health Worker features
  static const List<String> healthWorkerFeatures = [
    'client_management',
    'consultation',
    'health_reports',
    'schedule_management',
    'patient_records',
    'appointment_management',
  ];

  /// Client/User features
  static const List<String> clientFeatures = [
    'health_tracking',
    'menstrual_cycle',
    'pregnancy_planning',
    'contraception',
    'education',
    'appointments',
    'medications',
    'sti_testing',
    'support_groups',
    'messaging',
  ];

  /// Check if user can access a specific feature
  static bool canAccessFeature(String? userRole, String feature) {
    if (userRole == null) return false;

    final role = userRole.toLowerCase();

    switch (role) {
      case 'admin':
        return adminFeatures.contains(feature) ||
            healthWorkerFeatures.contains(feature) ||
            clientFeatures.contains(feature);
      case 'healthworker':
      case 'health_worker':
        return healthWorkerFeatures.contains(feature) ||
            clientFeatures.contains(feature);
      case 'client':
      case 'user':
        return clientFeatures.contains(feature);
      default:
        return false;
    }
  }

  /// Get all accessible features for a role
  static List<String> getAccessibleFeatures(String? userRole) {
    if (userRole == null) return [];

    final role = userRole.toLowerCase();

    switch (role) {
      case 'admin':
        return [...adminFeatures, ...healthWorkerFeatures, ...clientFeatures];
      case 'healthworker':
      case 'health_worker':
        return [...healthWorkerFeatures, ...clientFeatures];
      case 'client':
      case 'user':
        return [...clientFeatures];
      default:
        return [];
    }
  }
}

/// Role-based navigation helper
class RoleNavigation {
  /// Navigate to role-appropriate dashboard
  static void navigateToRoleDashboard(BuildContext context, String? userRole) {
    if (userRole == null) return;

    final role = userRole.toLowerCase();

    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'healthworker':
      case 'health_worker':
        Navigator.pushReplacementNamed(context, '/health-worker-dashboard');
        break;
      case 'client':
      case 'user':
      default:
        Navigator.pushReplacementNamed(context, '/client-dashboard');
        break;
    }
  }

  /// Check if user can navigate to a specific route
  static bool canNavigateToRoute(String? userRole, String route) {
    if (userRole == null) return false;

    final role = userRole.toLowerCase();

    // Admin routes
    if (route.startsWith('/admin') && role != 'admin') {
      return false;
    }

    // Health worker routes
    if (route.startsWith('/health-worker') &&
        role != 'admin' &&
        role != 'healthworker' &&
        role != 'health_worker') {
      return false;
    }

    return true;
  }
}

/// Role-based widget visibility
class RoleVisibility extends ConsumerWidget {
  final Widget child;
  final List<String> visibleForRoles;
  final Widget? fallback;

  const RoleVisibility({
    super.key,
    required this.child,
    required this.visibleForRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final userRole = user.role.toLowerCase();
    final isVisible = visibleForRoles.any(
      (role) => role.toLowerCase() == userRole,
    );

    return isVisible ? child : (fallback ?? const SizedBox.shrink());
  }
}
