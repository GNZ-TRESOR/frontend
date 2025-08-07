import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard.dart';
import '../health_worker/health_worker_main_screen.dart';
import 'client_dashboard.dart';

/// Role-based dashboard that routes users to appropriate interface based on their role
class RoleDashboard extends ConsumerStatefulWidget {
  const RoleDashboard({super.key});

  @override
  ConsumerState<RoleDashboard> createState() => _RoleDashboardState();
}

class _RoleDashboardState extends ConsumerState<RoleDashboard> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      // Add a small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize dashboard: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      debugPrint('[RoleDashboard] Loading...');
      return _buildLoadingScreen();
    }

    if (_error != null) {
      debugPrint('[RoleDashboard] Error: $_error');
      return _buildErrorScreen();
    }

    final authState = ref.watch(authProvider);
    debugPrint(
      '[RoleDashboard] isAuthenticated=${authState.isAuthenticated}, user=${authState.user}',
    );

    if (!authState.isAuthenticated) {
      debugPrint('[RoleDashboard] Not authenticated, navigating to login.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToLogin();
      });
      return _buildLoadingScreen();
    }

    final user = authState.user;
    if (user == null) {
      debugPrint('[RoleDashboard] User is null!');
      return _buildErrorScreen();
    }

    debugPrint('[RoleDashboard] Routing to dashboard for role: ${user.role}');
    // Route to appropriate dashboard based on user role
    switch (user.role.toLowerCase()) {
      case 'admin':
        return const AdminDashboard();
      case 'healthworker':
      case 'health_worker':
        return const HealthWorkerMainScreen();
      case 'client':
      case 'user':
      default:
        return const ClientDashboard();
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 30),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: 20),

            // Loading text
            Text(
              'Loading your dashboard...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Setting up your personalized experience',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 30),

              // Error title
              Text(
                'Dashboard Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 15),

              // Error message
              Text(
                _error ?? 'An unexpected error occurred',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeDashboard();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    _navigateToLogin();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Role-based access control helper
class RoleBasedAccess {
  static const String adminRole = 'admin';
  static const String healthWorkerRole = 'healthWorker';
  static const String clientRole = 'client';

  /// Check if user has admin access
  static bool isAdmin(String? role) {
    return role?.toLowerCase() == adminRole.toLowerCase();
  }

  /// Check if user has health worker access
  static bool isHealthWorker(String? role) {
    return role?.toLowerCase() == healthWorkerRole.toLowerCase() ||
        role?.toLowerCase() == 'health_worker';
  }

  /// Check if user has client access
  static bool isClient(String? role) {
    return role?.toLowerCase() == clientRole.toLowerCase() ||
        role?.toLowerCase() == 'user';
  }

  /// Get available features based on user role
  static List<String> getAvailableFeatures(String? role) {
    if (isAdmin(role)) {
      return [
        'user_management',
        'health_records',
        'appointments',
        'education_management',
        'support_groups',
        'analytics',
        'system_settings',
        'facility_management',
        'content_management',
      ];
    } else if (isHealthWorker(role)) {
      return [
        'health_records',
        'appointments',
        'patient_management',
        'education_content',
        'support_groups',
        'consultations',
        'reports',
      ];
    } else {
      return [
        'health_tracking',
        'menstrual_cycle',
        'pregnancy_planning',
        'contraception',
        'education',
        'support_groups',
        'appointments',
        'medications',
        'sti_testing',
      ];
    }
  }

  /// Check if user can access a specific feature
  static bool canAccessFeature(String? role, String feature) {
    final availableFeatures = getAvailableFeatures(role);
    return availableFeatures.contains(feature);
  }

  /// Get dashboard title based on role
  static String getDashboardTitle(String? role) {
    if (isAdmin(role)) {
      return 'Admin Dashboard';
    } else if (isHealthWorker(role)) {
      return 'Health Worker Dashboard';
    } else {
      return 'My Health Dashboard';
    }
  }

  /// Get welcome message based on role
  static String getWelcomeMessage(String? role, String? userName) {
    final name = userName ?? 'User';

    if (isAdmin(role)) {
      return 'Welcome back, $name! Manage the Ubuzima platform.';
    } else if (isHealthWorker(role)) {
      return 'Welcome, Dr. $name! Ready to help your patients today.';
    } else {
      return 'Welcome back, $name! Let\'s track your health journey.';
    }
  }

  /// Get primary color based on role
  static Color getPrimaryColor(String? role) {
    if (isAdmin(role)) {
      return AppColors.adminPurple;
    } else if (isHealthWorker(role)) {
      return AppColors.healthWorkerBlue;
    } else {
      return AppColors.clientPink;
    }
  }
}
