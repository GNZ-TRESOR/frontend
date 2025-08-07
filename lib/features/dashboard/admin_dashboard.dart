import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/client_management_screen.dart';
import '../admin/analytics_screen.dart';
import '../admin/content_management_screen.dart';
import '../admin/health_facilities_screen.dart';
import '../admin/system_settings_screen.dart';
import '../admin/reports_screen.dart';

/// Professional Admin Dashboard for Family Planning Platform
class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _dashboardStats;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getDashboardStats();

      if (response.success && response.data != null) {
        _dashboardStats = response.data as Map<String, dynamic>?;
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load dashboard stats';
      }
    } catch (e) {
      _error = 'Error loading dashboard stats: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.adminPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadDashboardStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
          Consumer(
            builder: (context, ref, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Admin Menu',
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context, ref);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(currentUserProvider);

          return RefreshIndicator(
            onRefresh: _loadDashboardStats,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(user),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    _buildErrorCard(),
                    const SizedBox(height: 24),
                  ],
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildAdminActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.adminPurple,
            AppColors.adminPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              user?.initials ?? 'A',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  user?.displayName ?? 'Administrator',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage the Ubuzima platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats =
        _dashboardStats != null
            ? [
              StatCard(
                title: 'Total Users',
                value: _dashboardStats!['totalUsers']?.toString() ?? '0',
                icon: Icons.people,
                color: AppColors.primary,
                change: '+12%',
              ),
              StatCard(
                title: 'Health Workers',
                value:
                    _dashboardStats!['totalHealthWorkers']?.toString() ?? '0',
                icon: Icons.medical_services,
                color: AppColors.healthWorkerBlue,
                change: '+5%',
              ),
              StatCard(
                title: 'Health Records',
                value:
                    _dashboardStats!['totalHealthRecords']?.toString() ?? '0',
                icon: Icons.health_and_safety,
                color: AppColors.healthRecordGreen,
                change: '+18%',
              ),
              StatCard(
                title: 'Appointments',
                value: _dashboardStats!['totalAppointments']?.toString() ?? '0',
                icon: Icons.calendar_today,
                color: AppColors.appointmentBlue,
                change: '+8%',
              ),
            ]
            : [
              StatCard(
                title: 'Total Users',
                value: '...',
                icon: Icons.people,
                color: AppColors.primary,
                change: '',
              ),
              StatCard(
                title: 'Health Workers',
                value: '...',
                icon: Icons.medical_services,
                color: AppColors.healthWorkerBlue,
                change: '',
              ),
              StatCard(
                title: 'Health Records',
                value: '...',
                icon: Icons.health_and_safety,
                color: AppColors.healthRecordGreen,
                change: '',
              ),
              StatCard(
                title: 'Appointments',
                value: '...',
                icon: Icons.calendar_today,
                color: AppColors.appointmentBlue,
                change: '',
              ),
            ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid layout
        int crossAxisCount = 2;
        double childAspectRatio = 1.3;

        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        } else if (constraints.maxWidth < 400) {
          crossAxisCount = 1;
          childAspectRatio = 2.5;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(stat);
          },
        );
      },
    );
  }

  Widget _buildStatCard(StatCard stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stat.change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.title,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error Loading Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  _error ?? 'Unknown error occurred',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _loadDashboardStats,
            child: Text('Retry', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    final actions = [
      AdminAction(
        title: 'User Management',
        subtitle: 'Manage users and roles',
        icon: Icons.people_outline,
        color: AppColors.primary,
      ),
      AdminAction(
        title: 'Client Management',
        subtitle: 'Manage client accounts',
        icon: Icons.person_outline,
        color: AppColors.success,
      ),
      AdminAction(
        title: 'Content Management',
        subtitle: 'Manage educational content',
        icon: Icons.article_outlined,
        color: AppColors.educationBlue,
      ),
      AdminAction(
        title: 'System Settings',
        subtitle: 'Configure platform settings',
        icon: Icons.settings,
        color: AppColors.textSecondary,
      ),
      AdminAction(
        title: 'Analytics',
        subtitle: 'View platform analytics',
        icon: Icons.analytics_outlined,
        color: AppColors.success,
      ),
      AdminAction(
        title: 'Health Facilities',
        subtitle: 'Manage health facilities',
        icon: Icons.local_hospital_outlined,
        color: AppColors.secondary,
      ),
      AdminAction(
        title: 'Reports',
        subtitle: 'Generate system reports',
        icon: Icons.assessment_outlined,
        color: AppColors.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildAdminActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildAdminActionCard(AdminAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _handleAdminAction(action),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAdminAction(AdminAction action) {
    switch (action.title) {
      case 'User Management':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserManagementScreen()),
        );
        break;
      case 'Client Management':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientManagementScreen(),
          ),
        );
        break;
      case 'Content Management':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContentManagementScreen(),
          ),
        );
        break;
      case 'Analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
        );
        break;
      case 'System Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SystemSettingsScreen()),
        );
        break;
      case 'Health Facilities':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HealthFacilitiesScreen(),
          ),
        );
        break;
      case 'Reports':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportsScreen()),
        );
        break;
      case 'View Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        );
        break;
      default:
        _showFeatureDialog(context, action.title);
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from the admin dashboard?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _performLogout(ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform logout
      await ref.read(authProvider.notifier).logout();

      // Close loading indicator
      if (mounted) Navigator.of(context).pop();

      // Navigate to login screen and clear navigation stack
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show feature dialog with role-appropriate messaging
  void _showFeatureDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(featureName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This feature is available in the full version.',
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Core functionality is implemented\n'
                  '• Advanced features are in development\n'
                  '• Will be available in future updates',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Could navigate to feedback or request feature screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Request Feature',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

/// Data classes for admin dashboard
class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });
}

class AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
