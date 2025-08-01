import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/simple_translated_text.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/auto_translate_widget.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

import '../../core/widgets/tts_button.dart';
import '../../core/utils/tts_helpers.dart';
import '../health_records/health_records_screen.dart';
import '../menstrual_cycle/menstrual_cycle_screen.dart';
import '../pregnancy/pregnancy_planning_screen.dart';
import '../contraception/contraception_screen.dart';
import '../medications/medications_screen.dart';
import '../education/education_screen.dart';
import '../community_events/community_events_screen.dart';
import '../appointments/appointments_screen.dart';
import '../sti_testing/sti_testing_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../ai_chat/screens/chat_assistant_screen.dart';
import '../clinic_finder/clinic_finder_screen.dart';

/// Professional Client Dashboard for Family Planning Platform
class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<DashboardTab> _tabs = [
    DashboardTab(
      title: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    DashboardTab(
      title: 'Health',
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
    DashboardTab(
      title: 'Education',
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
    ),
    DashboardTab(
      title: 'Community',
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
    ),
    DashboardTab(
      title: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          _buildHealthTab(),
          _buildEducationTab(),
          _buildCommunityTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildHealthSummary(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(currentUserProvider);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
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
                  user?.initials ?? 'U',
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
                    'Welcome back,'.at(
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getFontSize(context, 14),
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    'Let\'s track your health journey'.at(
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getFontSize(context, 14),
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      QuickAction(
        title: 'Track Cycle',
        subtitle: 'Log your period',
        icon: Icons.calendar_month,
        color: AppColors.menstrualRed,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MenstrualCycleScreen(),
              ),
            ),
      ),
      QuickAction(
        title: 'Book Appointment',
        subtitle: 'See a doctor',
        icon: Icons.medical_services,
        color: AppColors.appointmentBlue,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppointmentsScreen(),
              ),
            ),
      ),
      QuickAction(
        title: 'Health Records',
        subtitle: 'View your data',
        icon: Icons.folder_outlined,
        color: AppColors.tertiary,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HealthRecordsScreen(),
              ),
            ),
      ),
      QuickAction(
        title: 'Learn',
        subtitle: 'Education hub',
        icon: Icons.school,
        color: AppColors.educationBlue,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EducationScreen()),
            ),
      ),
      QuickAction(
        title: 'Find Clinics',
        subtitle: 'Nearby facilities',
        icon: Icons.location_on,
        color: AppColors.secondary,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClinicFinderScreen(),
              ),
            ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'Quick Actions'.at(
          style: TextStyle(
            fontSize: ResponsiveLayout.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid layout
            int crossAxisCount = 2;
            double childAspectRatio = 1.2;

            if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 1.1;
            } else if (constraints.maxWidth < 350) {
              crossAxisCount = 1;
              childAspectRatio = 2.0;
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
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return _buildQuickActionCard(action);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 12),
              Flexible(
                child: action.title.str(
                  style: TextStyle(
                    fontSize: ResponsiveLayout.getFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: action.subtitle.str(
                  style: TextStyle(
                    fontSize: ResponsiveLayout.getFontSize(context, 11),
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Summary',
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
              _buildHealthSummaryItem(
                'Next Period',
                'In 5 days',
                Icons.calendar_today,
                AppColors.menstrualRed,
              ),
              const Divider(),
              _buildHealthSummaryItem(
                'Last Checkup',
                '2 weeks ago',
                Icons.medical_services,
                AppColors.appointmentBlue,
              ),
              const Divider(),
              _buildHealthSummaryItem(
                'Medications',
                '2 active',
                Icons.medication,
                AppColors.medicationPink,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
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
              _buildActivityItem(
                'Period logged',
                '2 hours ago',
                Icons.water_drop,
                AppColors.menstrualRed,
              ),
              const Divider(),
              _buildActivityItem(
                'Completed lesson',
                'Yesterday',
                Icons.school,
                AppColors.educationBlue,
              ),
              const Divider(),
              _buildActivityItem(
                'Appointment booked',
                '3 days ago',
                Icons.calendar_today,
                AppColors.appointmentBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Tracking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildHealthModules(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthModules() {
    final healthModules = [
      HealthModule(
        title: 'Menstrual Cycle',
        subtitle: 'Track your cycle and symptoms',
        icon: Icons.calendar_month,
        color: AppColors.menstrualRed,
        screen: const MenstrualCycleScreen(),
      ),
      HealthModule(
        title: 'Pregnancy Planning',
        subtitle: 'Plan and track pregnancy',
        icon: Icons.pregnant_woman,
        color: AppColors.pregnancyPurple,
        screen: const PregnancyPlanningScreen(),
      ),
      HealthModule(
        title: 'Contraception',
        subtitle: 'Manage birth control methods',
        icon: Icons.shield,
        color: AppColors.contraceptionOrange,
        screen: const ContraceptionScreen(),
      ),
      HealthModule(
        title: 'Medications',
        subtitle: 'Track medications and side effects',
        icon: Icons.medication,
        color: AppColors.medicationPink,
        screen: const MedicationsScreen(),
      ),
      HealthModule(
        title: 'STI Testing',
        subtitle: 'Manage STI test records',
        icon: Icons.medical_services,
        color: AppColors.appointmentBlue,
        screen: const StiTestingScreen(),
      ),
      HealthModule(
        title: 'Health Records',
        subtitle: 'View and manage health data',
        icon: Icons.folder_outlined,
        color: AppColors.tertiary,
        screen: const HealthRecordsScreen(),
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: healthModules.length,
      itemBuilder: (context, index) {
        final module = healthModules[index];
        return _buildHealthModuleCard(module);
      },
    );
  }

  Widget _buildHealthModuleCard(HealthModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => module.screen),
            ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(module.icon, color: module.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.subtitle,
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

  Widget _buildEducationTab() {
    return const EducationScreen();
  }

  Widget _buildCommunityTab() {
    return const CommunityEventsScreen();
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                _tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = _selectedIndex == index;

                  return Expanded(
                    child: InkWell(
                      onTap: () => _onTabSelected(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? tab.activeIcon : tab.icon,
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: tab.title.str(
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  /// Build floating action buttons (TTS and AI Chat)
  Widget _buildFloatingButtons() {
    final user = ref.watch(authProvider).user;

    // Create readable content for the current tab
    String getTabContent() {
      switch (_selectedIndex) {
        case 0: // Home
          return TTSHelpers.createReadableText(
            title: 'Welcome to Ubuzima Family Planning Dashboard',
            subtitle: 'Hello ${user?.name ?? 'User'}',
            content:
                'You are on the home screen. Here you can access quick actions for appointments, health tracking, and view your health summary.',
            bulletPoints: [
              'Book new appointments',
              'Track menstrual cycle',
              'View health records',
              'Access educational content',
            ],
          );
        case 1: // Health
          return TTSHelpers.createReadableText(
            title: 'Health Management Section',
            content:
                'Access your health records, medications, STI testing, and menstrual cycle tracking.',
          );
        case 2: // Education
          return TTSHelpers.createReadableText(
            title: 'Educational Resources',
            content:
                'Learn about family planning, contraception, and reproductive health.',
          );
        case 3: // Community
          return TTSHelpers.createReadableText(
            title: 'Community Support',
            content: 'Connect with support groups and community events.',
          );
        case 4: // Profile
          return TTSHelpers.createReadableText(
            title: 'Profile Settings',
            content: 'Manage your account settings and preferences.',
          );
        default:
          return 'Welcome to Ubuzima Family Planning Platform';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 100), // Position below status bar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Chat Button
          FloatingActionButton(
            heroTag: "ai_chat",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatAssistantScreen(),
                ),
              );
            },
            backgroundColor: AppColors.secondary,
            tooltip: 'AI Assistant',
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(height: 16),

          // Language Switcher Button
          FloatingActionButton(
            heroTag: "language_switcher",
            mini: true,
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: 'Select Language'.at(),
                      content: const QuickLanguageSwitcher(),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: 'Close'.at(),
                        ),
                      ],
                    ),
              );
            },
            backgroundColor: AppColors.tertiary,
            tooltip: 'Change Language',
            child: const Icon(Icons.language, color: Colors.white, size: 20),
          ),

          const SizedBox(height: 16),

          // TTS Button
          TTSFloatingButton(
            textToSpeak: getTabContent(),
            tooltip: 'Read screen content aloud',
            backgroundColor: AppColors.primary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

/// Data classes for dashboard components
class DashboardTab {
  final String title;
  final IconData icon;
  final IconData activeIcon;

  DashboardTab({
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class HealthModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  HealthModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
