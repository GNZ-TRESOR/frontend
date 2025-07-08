import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../widgets/voice_button.dart';
import '../profile/profile_screen.dart';
import 'client_management_screen.dart';
import 'consultation_screen.dart';
import 'schedule_management_screen.dart';
import '../admin/health_reports_screen.dart';

class HealthWorkerDashboard extends StatefulWidget {
  final User user;

  const HealthWorkerDashboard({super.key, required this.user});

  @override
  State<HealthWorkerDashboard> createState() => _HealthWorkerDashboardState();
}

class _HealthWorkerDashboardState extends State<HealthWorkerDashboard> {
  int _selectedIndex = 0;

  final List<DashboardMetric> _metrics = [
    DashboardMetric(
      title: 'Abakiriya banjye',
      value: '127',
      subtitle: '+12 muri iki cyumweru',
      icon: Icons.people_rounded,
      color: AppTheme.primaryColor,
      trend: TrendType.up,
    ),
    DashboardMetric(
      title: 'Inama z\'uyu munsi',
      value: '8',
      subtitle: '3 zisigaye',
      icon: Icons.calendar_today_rounded,
      color: AppTheme.secondaryColor,
      trend: TrendType.stable,
    ),
    DashboardMetric(
      title: 'Ubutumwa bushya',
      value: '15',
      subtitle: '5 by\'ihutirwa',
      icon: Icons.message_rounded,
      color: AppTheme.accentColor,
      trend: TrendType.up,
    ),
    DashboardMetric(
      title: 'Raporo z\'uku kwezi',
      value: '24',
      subtitle: 'Byarangiye 95%',
      icon: Icons.assessment_rounded,
      color: AppTheme.successColor,
      trend: TrendType.up,
    ),
  ];

  final List<QuickAction> _quickActions = [
    QuickAction(
      title: 'Gucunga abakiriya',
      subtitle: 'Reba no gucunga abakiriya bawe',
      icon: Icons.people_alt_rounded,
      color: AppTheme.primaryColor,
      route: 'clients',
    ),
    QuickAction(
      title: 'Inama n\'ubujyanama',
      subtitle: 'Tanga inama z\'ubuzima',
      icon: Icons.medical_services_rounded,
      color: AppTheme.secondaryColor,
      route: 'consultation',
    ),
    QuickAction(
      title: 'Raporo z\'ubuzima',
      subtitle: 'Kora no kohereza raporo',
      icon: Icons.analytics_rounded,
      color: AppTheme.accentColor,
      route: 'reports',
    ),
    QuickAction(
      title: 'Gahunda y\'igihe',
      subtitle: 'Gena gahunda yawe',
      icon: Icons.schedule_rounded,
      color: AppTheme.warningColor,
      route: 'schedule',
    ),
  ];

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('abakiriya') ||
        lowerCommand.contains('clients')) {
      _navigateToScreen('clients');
    } else if (lowerCommand.contains('inama') ||
        lowerCommand.contains('consultation')) {
      _navigateToScreen('consultation');
    } else if (lowerCommand.contains('raporo') ||
        lowerCommand.contains('reports')) {
      _navigateToScreen('reports');
    } else if (lowerCommand.contains('gahunda') ||
        lowerCommand.contains('schedule')) {
      _navigateToScreen('schedule');
    }
  }

  void _navigateToScreen(String route) {
    Widget screen;

    switch (route) {
      case 'clients':
        screen = ClientManagementScreen(healthWorker: widget.user);
        break;
      case 'consultation':
        screen = ConsultationScreen(healthWorker: widget.user);
        break;
      case 'reports':
        screen = const HealthReportsScreen();
        break;
      case 'schedule':
        screen = ScheduleManagementScreen(healthWorker: widget.user);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iyi fonctionnalité izaza vuba...')),
        );
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        _navigateToScreen('clients');
        break;
      case 2:
        _navigateToScreen('consultation');
        break;
      case 3:
        _navigateToScreen('reports');
        break;
      case 4:
        // Navigate to profile
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildAppBar(isTablet),

          // Metrics Overview
          SliverToBoxAdapter(child: _buildMetricsOverview(isTablet)),

          // Quick Actions
          SliverToBoxAdapter(child: _buildQuickActions(isTablet)),

          // Recent Activities
          SliverToBoxAdapter(child: _buildRecentActivities(isTablet)),

          // Today's Schedule
          SliverToBoxAdapter(child: _buildTodaySchedule(isTablet)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Abakiriya" kugira ngo ugere ku bakiriya, "Inama" kugira ngo utange ubujyanama, cyangwa "Raporo" kugira ngo ukore raporo',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gukora akazi',
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 200 : 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isTablet ? 60 : 50,
                        height: isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 30 : 25,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Muraho, ${widget.user.name.split(' ').first}',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 28 : 24,
                              ),
                            ),
                            Text(
                              widget.user.roleDisplayName,
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing12,
                          vertical: AppTheme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusRound,
                          ),
                        ),
                        child: Text(
                          '5 bishya',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsOverview(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incamake y\'uyu munsi',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: AppTheme.spacing16,
              mainAxisSpacing: AppTheme.spacing16,
              childAspectRatio: isTablet ? 1.2 : 1.1,
            ),
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              final metric = _metrics[index];
              return _buildMetricCard(metric, isTablet, index);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildMetricCard(DashboardMetric metric, bool isTablet, int index) {
    return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: metric.color.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: isTablet ? 50 : 40,
                      height: isTablet ? 50 : 40,
                      decoration: BoxDecoration(
                        color: metric.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                      ),
                      child: Icon(
                        metric.icon,
                        color: metric.color,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    Icon(
                      metric.trend == TrendType.up
                          ? Icons.trending_up_rounded
                          : metric.trend == TrendType.down
                          ? Icons.trending_down_rounded
                          : Icons.trending_flat_rounded,
                      color:
                          metric.trend == TrendType.up
                              ? AppTheme.successColor
                              : metric.trend == TrendType.down
                              ? AppTheme.errorColor
                              : AppTheme.textTertiary,
                      size: isTablet ? 20 : 16,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  metric.value,
                  style: AppTheme.headingLarge.copyWith(
                    color: metric.color,
                    fontSize: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  metric.title,
                  style: AppTheme.labelMedium.copyWith(
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  metric.subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: isTablet ? 12 : 10,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn()
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms);
  }

  Widget _buildQuickActions(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ibikorwa byihuse',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: AppTheme.spacing16,
              mainAxisSpacing: AppTheme.spacing16,
              childAspectRatio: isTablet ? 1.0 : 0.9,
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return _buildQuickActionCard(action, isTablet, index);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildQuickActionCard(QuickAction action, bool isTablet, int index) {
    return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: action.color.withValues(alpha: 0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToScreen(action.route),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isTablet ? 60 : 50,
                      height: isTablet ? 60 : 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            action.color,
                            action.color.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                        boxShadow: [
                          BoxShadow(
                            color: action.color.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        action.icon,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing12),
                    Text(
                      action.title,
                      style: AppTheme.labelLarge.copyWith(
                        fontSize: isTablet ? 16 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      action.subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: isTablet ? 12 : 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (index * 150).ms)
        .fadeIn()
        .slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildRecentActivities(bool isTablet) {
    final activities = [
      'Mukamana Marie - Inama yarangiye',
      'Uwimana Jean - Ubutumwa bushya',
      'Gasana Paul - Raporo yoherejwe',
      'Nyirahabimana Alice - Gahunda yashyizweho',
    ];

    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ibikorwa bya vuba',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          ...activities.map(
            (activity) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing12),
                  Expanded(child: Text(activity, style: AppTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildTodaySchedule(bool isTablet) {
    final schedule = [
      ScheduleItem(
        time: '08:00',
        title: 'Inama na Mukamana Marie',
        type: 'Consultation',
        color: AppTheme.primaryColor,
      ),
      ScheduleItem(
        time: '10:30',
        title: 'Raporo y\'uku kwezi',
        type: 'Report',
        color: AppTheme.secondaryColor,
      ),
      ScheduleItem(
        time: '14:00',
        title: 'Inama n\'itsinda',
        type: 'Group Session',
        color: AppTheme.accentColor,
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gahunda y\'uyu munsi',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          ...schedule.map(
            (item) => Container(
              margin: EdgeInsets.only(bottom: AppTheme.spacing12),
              padding: EdgeInsets.all(
                isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.softShadow,
                border: Border.all(color: item.color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 60 : 50,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                    ),
                    child: Center(
                      child: Text(
                        item.time,
                        style: AppTheme.labelMedium.copyWith(
                          color: item.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 12 : 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTheme.labelLarge.copyWith(
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        Text(
                          item.type,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textTertiary,
                    size: isTablet ? 24 : 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleBottomNavigation(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        selectedLabelStyle: AppTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.bodySmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Ahabanza',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Abakiriya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_rounded),
            label: 'Inama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Raporo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Umwirondoro',
          ),
        ],
      ),
    );
  }
}

class DashboardMetric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TrendType trend;

  DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class ScheduleItem {
  final String time;
  final String title;
  final String type;
  final Color color;

  ScheduleItem({
    required this.time,
    required this.title,
    required this.type,
    required this.color,
  });
}

enum TrendType { up, down, stable }
