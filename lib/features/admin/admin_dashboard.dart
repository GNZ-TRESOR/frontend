import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../widgets/voice_button.dart';
import '../profile/profile_screen.dart';
import 'staff_management_screen.dart';
import 'health_reports_screen.dart';
import 'app_settings_screen.dart';
import 'facilities_management_screen.dart';
import 'content_management_screen.dart';
import 'research_data_screen.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<AdminMetric> _metrics = [
    AdminMetric(
      title: 'Abakozi b\'ubuzima',
      value: '45',
      subtitle: '+3 muri iki cyumweru',
      icon: Icons.medical_services_rounded,
      color: AppTheme.primaryColor,
      trend: TrendType.up,
    ),
    AdminMetric(
      title: 'Abakiriya bose',
      value: '2,847',
      subtitle: '+127 muri uku kwezi',
      icon: Icons.people_rounded,
      color: AppTheme.secondaryColor,
      trend: TrendType.up,
    ),
    AdminMetric(
      title: 'Amavuriro',
      value: '12',
      subtitle: '2 mashya azongera',
      icon: Icons.local_hospital_rounded,
      color: AppTheme.accentColor,
      trend: TrendType.stable,
    ),
    AdminMetric(
      title: 'Raporo z\'uku kwezi',
      value: '156',
      subtitle: '98% byarangiye',
      icon: Icons.assessment_rounded,
      color: AppTheme.successColor,
      trend: TrendType.up,
    ),
  ];

  final List<AdminAction> _adminActions = [
    AdminAction(
      title: 'Gucunga abakozi',
      subtitle: 'Ongeraho no gucunga abakozi b\'ubuzima',
      icon: Icons.admin_panel_settings_rounded,
      color: AppTheme.primaryColor,
      route: 'staff',
    ),
    AdminAction(
      title: 'Raporo z\'ubuzima',
      subtitle: 'Reba raporo z\'ubuzima bw\'igihugu',
      icon: Icons.analytics_rounded,
      color: AppTheme.secondaryColor,
      route: 'reports',
    ),
    AdminAction(
      title: 'Igenamiterere ry\'app',
      subtitle: 'Hindura igenamiterere ry\'app',
      icon: Icons.settings_applications_rounded,
      color: AppTheme.accentColor,
      route: 'settings',
    ),
    AdminAction(
      title: 'Amavuriro',
      subtitle: 'Gucunga amavuriro n\'ibikoresho',
      icon: Icons.domain_rounded,
      color: AppTheme.warningColor,
      route: 'facilities',
    ),
    AdminAction(
      title: 'Amasomo',
      subtitle: 'Gucunga ibikubiye mu masomo',
      icon: Icons.school_rounded,
      color: AppTheme.errorColor,
      route: 'content',
    ),
    AdminAction(
      title: 'Ubushakashatsi',
      subtitle: 'Reba amakuru y\'ubushakashatsi',
      icon: Icons.science_rounded,
      color: AppTheme.primaryColor,
      route: 'research',
    ),
  ];

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('abakozi') || lowerCommand.contains('staff')) {
      _navigateToScreen('staff');
    } else if (lowerCommand.contains('raporo') ||
        lowerCommand.contains('reports')) {
      _navigateToScreen('reports');
    } else if (lowerCommand.contains('igenamiterere') ||
        lowerCommand.contains('settings')) {
      _navigateToScreen('settings');
    } else if (lowerCommand.contains('amavuriro') ||
        lowerCommand.contains('facilities')) {
      _navigateToScreen('facilities');
    }
  }

  void _navigateToScreen(String route) {
    Widget screen;

    switch (route) {
      case 'staff':
        screen = const StaffManagementScreen();
        break;
      case 'reports':
        screen = const HealthReportsScreen();
        break;
      case 'settings':
        screen = const AppSettingsScreen();
        break;
      case 'facilities':
        screen = const FacilitiesManagementScreen();
        break;
      case 'content':
        screen = const ContentManagementScreen();
        break;
      case 'research':
        screen = const ResearchDataScreen();
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
        _navigateToScreen('staff');
        break;
      case 2:
        _navigateToScreen('reports');
        break;
      case 3:
        _navigateToScreen('settings');
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

          // System Overview
          SliverToBoxAdapter(child: _buildSystemOverview(isTablet)),

          // Admin Actions
          SliverToBoxAdapter(child: _buildAdminActions(isTablet)),

          // Recent System Activities
          SliverToBoxAdapter(child: _buildSystemActivities(isTablet)),

          // System Health Status
          SliverToBoxAdapter(child: _buildSystemHealth(isTablet)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Abakozi" kugira ngo ugere ku bakozi, "Raporo" kugira ngo ugere ku raporo, cyangwa "Igenamiterere" kugira ngo ugere ku genamiterere',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga sisiteme',
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 220 : 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: const BorderRadius.only(
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
                        width: isTablet ? 70 : 60,
                        height: isTablet ? 70 : 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 35 : 30,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: isTablet ? 36 : 32,
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
                                fontSize: isTablet ? 32 : 28,
                              ),
                            ),
                            Text(
                              'Umuyobozi Mukuru',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing12,
                                vertical: AppTheme.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall,
                                ),
                              ),
                              child: Text(
                                'Sisiteme ikora neza',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildSystemOverview(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incamake ya sisiteme',
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

  Widget _buildMetricCard(AdminMetric metric, bool isTablet, int index) {
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [metric.color, metric.color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: metric.color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
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
                    Icon(
                      metric.icon,
                      color: Colors.white,
                      size: isTablet ? 32 : 28,
                    ),
                    Icon(
                      metric.trend == TrendType.up
                          ? Icons.trending_up_rounded
                          : metric.trend == TrendType.down
                          ? Icons.trending_down_rounded
                          : Icons.trending_flat_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: isTablet ? 20 : 16,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  metric.value,
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 32 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  metric.title,
                  style: AppTheme.labelMedium.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  metric.subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildAdminActions(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ibikorwa by\'ubuyobozi',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: AppTheme.spacing16,
              mainAxisSpacing: AppTheme.spacing16,
              childAspectRatio: isTablet ? 1.1 : 0.9,
            ),
            itemCount: _adminActions.length,
            itemBuilder: (context, index) {
              final action = _adminActions[index];
              return _buildActionCard(action, isTablet, index);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildActionCard(AdminAction action, bool isTablet, int index) {
    return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.mediumShadow,
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
                        color: action.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                      ),
                      child: Icon(
                        action.icon,
                        color: action.color,
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

  Widget _buildSystemActivities(bool isTablet) {
    final activities = [
      'Dr. Uwimana Jean - Yinjiye mu sisiteme',
      'Raporo nshya - Yoherejwe na Kimisagara HC',
      'Umukiriya mushya - Yiyandikishije',
      'Sisiteme - Yakoze update',
      'Backup - Yarangiye neza',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ibikorwa bya vuba',
                style: AppTheme.headingMedium.copyWith(
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  'Live',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                  Text(
                    'Ubu',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildSystemHealth(bool isTablet) {
    final healthItems = [
      SystemHealthItem(
        title: 'Server Status',
        status: 'Online',
        color: AppTheme.successColor,
        percentage: 99.9,
      ),
      SystemHealthItem(
        title: 'Database',
        status: 'Healthy',
        color: AppTheme.successColor,
        percentage: 98.5,
      ),
      SystemHealthItem(
        title: 'API Response',
        status: 'Fast',
        color: AppTheme.primaryColor,
        percentage: 95.2,
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
            'Ubuzima bwa sisiteme',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          ...healthItems.map(
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
                    width: isTablet ? 50 : 40,
                    height: isTablet ? 50 : 40,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                    ),
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      color: item.color,
                      size: isTablet ? 24 : 20,
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
                          item.status,
                          style: AppTheme.bodySmall.copyWith(
                            color: item.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.percentage}%',
                    style: AppTheme.labelLarge.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.bold,
                    ),
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
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Abakozi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Raporo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Igenamiterere',
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

class AdminMetric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TrendType trend;

  AdminMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class SystemHealthItem {
  final String title;
  final String status;
  final Color color;
  final double percentage;

  SystemHealthItem({
    required this.title,
    required this.status,
    required this.color,
    required this.percentage,
  });
}

enum TrendType { up, down, stable }
