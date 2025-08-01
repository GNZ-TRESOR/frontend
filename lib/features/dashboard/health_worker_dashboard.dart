import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../ai_chat/screens/chat_assistant_screen.dart';
import '../profile/profile_screen.dart';
import '../health_worker/assigned_clients_screen.dart';

/// Professional Health Worker Dashboard for Family Planning Platform
class HealthWorkerDashboard extends ConsumerStatefulWidget {
  const HealthWorkerDashboard({super.key});

  @override
  ConsumerState<HealthWorkerDashboard> createState() =>
      _HealthWorkerDashboardState();
}

class _HealthWorkerDashboardState extends ConsumerState<HealthWorkerDashboard> {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardStats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getHealthWorkerDashboardStats(
        user!.id!,
      );

      if (response.success && response.data != null) {
        setState(() {
          _dashboardStats = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load dashboard data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading dashboard: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      // Perform logout
      await ref.read(authProvider.notifier).logout();

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Worker Dashboard'),
        backgroundColor: AppColors.healthWorkerBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(currentUserProvider);

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return _buildErrorState();
          }

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(user),
                  const SizedBox(height: 24),
                  _buildTodaySchedule(),
                  const SizedBox(height: 24),
                  _buildPatientStats(),
                  const SizedBox(height: 24),
                  _buildHealthWorkerActions(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatAssistantScreen(),
            ),
          );
        },
        backgroundColor: AppColors.secondary,
        tooltip: 'AI Assistant',
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildWelcomeHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.healthWorkerBlue,
            AppColors.healthWorkerBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.healthWorkerBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user?.initials ?? 'HW',
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
                  'Good morning, Dr.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  user?.displayName ?? 'Health Worker',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Ready to help your patients today',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildScheduleItem(
                '09:00 AM',
                'Maria Uwimana',
                'Contraception Consultation',
              ),
              const Divider(),
              _buildScheduleItem(
                '10:30 AM',
                'Grace Mukamana',
                'Pregnancy Planning',
              ),
              const Divider(),
              _buildScheduleItem(
                '02:00 PM',
                'Alice Nyirahabimana',
                'STI Testing',
              ),
              const Divider(),
              _buildScheduleItem(
                '03:30 PM',
                'Jeanne Uwimana',
                'Follow-up Checkup',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(String time, String patient, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.healthWorkerBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.healthWorkerBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  type,
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
    );
  }

  Widget _buildPatientStats() {
    final dashboardData = _dashboardStats ?? {};

    final stats = [
      PatientStat(
        title: 'Total Clients',
        value: dashboardData['totalClients']?.toString() ?? '0',
        icon: Icons.people,
        color: AppColors.primary,
      ),
      PatientStat(
        title: 'Today\'s Appointments',
        value: dashboardData['todayAppointments']?.toString() ?? '0',
        icon: Icons.calendar_today,
        color: AppColors.appointmentBlue,
      ),
      PatientStat(
        title: 'Completed',
        value: dashboardData['completedAppointments']?.toString() ?? '0',
        icon: Icons.check_circle,
        color: AppColors.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children:
              stats
                  .map(
                    (stat) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: stat.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                stat.icon,
                                color: stat.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stat.value,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildHealthWorkerActions() {
    final actions = [
      HealthWorkerAction(
        title: 'Patient Records',
        subtitle: 'View and manage patient health records',
        icon: Icons.folder_shared_outlined,
        color: AppColors.primary,
      ),
      HealthWorkerAction(
        title: 'Appointments',
        subtitle: 'Manage patient appointments',
        icon: Icons.calendar_today_outlined,
        color: AppColors.appointmentBlue,
      ),
      HealthWorkerAction(
        title: 'Consultations',
        subtitle: 'Start or continue consultations',
        icon: Icons.chat_outlined,
        color: AppColors.success,
      ),
      HealthWorkerAction(
        title: 'Education Content',
        subtitle: 'Manage educational materials',
        icon: Icons.school_outlined,
        color: AppColors.educationBlue,
      ),
      HealthWorkerAction(
        title: 'Support Groups',
        subtitle: 'Moderate support group discussions',
        icon: Icons.group_outlined,
        color: AppColors.supportPurple,
      ),
      HealthWorkerAction(
        title: 'Reports',
        subtitle: 'Generate patient reports',
        icon: Icons.assessment_outlined,
        color: AppColors.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
            return _buildHealthWorkerActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildHealthWorkerActionCard(HealthWorkerAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _handleHealthWorkerAction(action),
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
                  color: action.color.withOpacity(0.1),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading dashboard',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.healthWorkerBlue,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleHealthWorkerAction(HealthWorkerAction action) {
    switch (action.title) {
      case 'My Clients':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AssignedClientsScreen(),
          ),
        );
        break;
      case 'Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'Profile':
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${action.title} - Coming Soon!')),
        );
    }
  }
}

/// Data classes for health worker dashboard
class PatientStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  PatientStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class HealthWorkerAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  HealthWorkerAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
