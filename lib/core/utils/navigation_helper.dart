import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Navigation helper utility for consistent navigation behavior across the app
class NavigationHelper {
  /// Handle back navigation with proper fallback to appropriate dashboard
  static void handleBackNavigation(BuildContext context, WidgetRef ref) {
    try {
      // Check if we can safely pop
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      // If Navigator.canPop() throws an error, handle it gracefully
      debugPrint('Navigation error: $e');
    }

    // If we can't pop or there was an error, navigate to appropriate dashboard
    _navigateToUserDashboard(context, ref);
  }

  /// Navigate to the appropriate dashboard based on user role
  static void _navigateToUserDashboard(BuildContext context, WidgetRef ref) {
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        switch (user.role.toLowerCase()) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
            break;
          case 'health_worker':
            Navigator.pushReplacementNamed(context, '/health-worker/main');
            break;
          case 'client':
          case 'user':
            Navigator.pushReplacementNamed(context, '/client/dashboard');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        // If no user, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // If all else fails, try to go to splash screen
      debugPrint('Critical navigation error: $e');
      try {
        Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
      } catch (criticalError) {
        debugPrint('Critical navigation failure: $criticalError');
      }
    }
  }

  /// Navigate to appropriate dashboard based on user role
  static void navigateToDashboard(BuildContext context, WidgetRef ref) {
    _navigateToUserDashboard(context, ref);
  }

  /// Safe navigation that checks if the route exists
  static Future<void> safeNavigate(
    BuildContext context,
    String routeName,
  ) async {
    try {
      await Navigator.pushNamed(context, routeName);
    } catch (e) {
      // If route doesn't exist, show a message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Feature not available: ${routeName.replaceAll('/', '').replaceAll('-', ' ')}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Navigate with replacement to avoid stack buildup
  static Future<void> navigateAndReplace(
    BuildContext context,
    String routeName,
  ) async {
    try {
      await Navigator.pushReplacementNamed(context, routeName);
    } catch (e) {
      // Fallback to regular navigation
      if (context.mounted) {
        await Navigator.pushNamed(context, routeName);
      }
    }
  }

  /// Clear navigation stack and go to specific route
  static Future<void> navigateAndClearStack(
    BuildContext context,
    String routeName,
  ) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  /// Check if a route can be popped
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pop with fallback
  static void popWithFallback(
    BuildContext context,
    WidgetRef ref, {
    String? fallbackRoute,
  }) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      debugPrint('Pop navigation error: $e');
    }

    // If we can't pop, use fallback
    if (fallbackRoute != null) {
      try {
        Navigator.pushReplacementNamed(context, fallbackRoute);
      } catch (e) {
        debugPrint('Fallback navigation error: $e');
        _navigateToUserDashboard(context, ref);
      }
    } else {
      _navigateToUserDashboard(context, ref);
    }
  }
}
