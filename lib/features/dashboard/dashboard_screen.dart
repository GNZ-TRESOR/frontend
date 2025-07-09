import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/ai_assistant_fab.dart';
import '../../widgets/backend_status_widget.dart';
import '../../widgets/theme_toggle_button.dart';
import '../contraception/contraception_management_screen.dart';
import '../health/health_tracking_screen.dart';
import '../appointments/appointment_booking_screen.dart';
import '../clinics/clinic_locator_screen.dart';
import '../messaging/messaging_screen.dart';
import '../education/education_screen.dart';
import '../profile/profile_screen.dart';
import '../partner/partner_involvement_screen.dart';
import '../sti_prevention/sti_prevention_screen.dart';
import '../pregnancy_planning/pregnancy_planning_screen.dart';
import '../community/community_screen.dart';
import '../ai_assistant/ai_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;

  const DashboardScreen({super.key, this.userRole = AppConstants.roleClient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<DashboardItem> _getDashboardItems(AppLocalizations l10n) {
    return [
      DashboardItem(
        title: l10n.education,
        subtitle: l10n.lessons,
        icon: Icons.school_rounded,
        color: AppTheme.primaryColor,
        count: '12',
        description: l10n.lessons,
      ),
      DashboardItem(
        title: l10n.contraception,
        subtitle: l10n.birthControl,
        icon: Icons.medical_services_rounded,
        color: AppTheme.secondaryColor,
        count: '99%',
        description: l10n.effectiveness,
      ),
      DashboardItem(
        title: l10n.relationships,
        subtitle: l10n.communication,
        icon: Icons.favorite_rounded,
        color: AppTheme.accentColor,
        count: '2',
        description: l10n.messages,
      ),
      DashboardItem(
        title: l10n.sexualHealth,
        subtitle: l10n.safety,
        icon: Icons.health_and_safety_rounded,
        color: AppTheme.warningColor,
        count: l10n.info,
        description: l10n.safety,
      ),
      DashboardItem(
        title: l10n.pregnancy,
        subtitle: l10n.familyPlanning,
        icon: Icons.pregnant_woman_rounded,
        color: AppTheme.successColor,
        count: '365',
        description: l10n.today,
      ),
      DashboardItem(
        title: l10n.messaging,
        subtitle: l10n.healthWorker,
        icon: Icons.chat_rounded,
        color: AppTheme.infoColor,
        count: '3',
        description: l10n.messages,
      ),
      DashboardItem(
        title: l10n.clinics,
        subtitle: l10n.nearbyFacilities,
        icon: Icons.local_hospital_rounded,
        color: AppTheme.primaryColor,
        count: '5',
        description: l10n.nearbyFacilities,
      ),
      DashboardItem(
        title: l10n.appointments,
        subtitle: l10n.bookAppointment,
        icon: Icons.calendar_today_rounded,
        color: AppTheme.accentColor,
        count: '2',
        description: l10n.upcomingAppointments,
      ),
      DashboardItem(
        title: 'Umujyanama w\'AI',
        subtitle: 'Baza ibibazo',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF9C27B0), // Purple color for AI
        count: '24/7',
        description: 'Ubufasha',
      ),
    ];
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return '${l10n.morning}!';
    if (hour < 17) return '${l10n.afternoon}!';
    return '${l10n.evening}!';
  }

  String _getRoleDisplayName(AppLocalizations l10n) {
    switch (widget.userRole) {
      case AppConstants.roleClient:
        return l10n.profile;
      case AppConstants.roleWorker:
        return l10n.healthWorker;
      case AppConstants.roleAdmin:
        return l10n.settings;
      case AppConstants.roleAnonymous:
        return l10n.profile;
      default:
        return l10n.profile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildAppBar(isTablet, l10n),

          // Welcome Section
          SliverToBoxAdapter(child: _buildWelcomeSection(isTablet, l10n)),

          // Backend Status
          const SliverToBoxAdapter(child: BackendStatusWidget()),

          // Quick Stats
          SliverToBoxAdapter(child: _buildQuickStats(isTablet, l10n)),

          // Main Features
          SliverToBoxAdapter(child: _buildMainFeatures(isTablet, l10n)),

          // Recent Activity
          SliverToBoxAdapter(child: _buildRecentActivity(isTablet, l10n)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: _buildVoiceButton(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildAppBar(bool isTablet, AppLocalizations l10n) {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Info
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
                          Icons.person_rounded,
                          color: Colors.white,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          Text(
                            _getRoleDisplayName(l10n),
                            style: AppTheme.headingSmall.copyWith(
                              color: Colors.white,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      ThemeToggleButton(
                        iconSize: isTablet ? 24 : 20,
                        padding: EdgeInsets.all(isTablet ? 12 : 10),
                      ),
                      SizedBox(width: AppTheme.spacing8),
                      _buildActionButton(
                        Icons.notifications_rounded,
                        onPressed: () {},
                        isTablet: isTablet,
                      ),
                      SizedBox(width: AppTheme.spacing8),
                      _buildActionButton(
                        Icons.settings_rounded,
                        onPressed: () {},
                        isTablet: isTablet,
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

  Widget _buildActionButton(
    IconData icon, {
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return Container(
      width: isTablet ? 48 : 40,
      height: isTablet ? 48 : 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildWelcomeSection(bool isTablet, AppLocalizations l10n) {
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
      child: Row(
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
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
                  l10n.welcome,
                  style: AppTheme.headingSmall.copyWith(
                    fontSize: isTablet ? 20 : 16,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  l10n.quickActions,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildQuickStats(bool isTablet, AppLocalizations l10n) {
    final dashboardItems = _getDashboardItems(l10n);
    return Container(
      height: isTablet ? 140 : 120,
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dashboardItems.length,
        itemBuilder: (context, index) {
          final item = dashboardItems[index];
          return Container(
                width: isTablet ? 180 : 160,
                margin: EdgeInsets.only(
                  right:
                      index < dashboardItems.length - 1
                          ? AppTheme.spacing16
                          : 0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [item.color, item.color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
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
                            item.icon,
                            color: Colors.white,
                            size: isTablet ? 32 : 28,
                          ),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing8,
                                vertical: AppTheme.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall,
                                ),
                              ),
                              child: Text(
                                item.description,
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        item.count,
                        style: AppTheme.headingLarge.copyWith(
                          color: Colors.white,
                          fontSize: isTablet ? 32 : 28,
                        ),
                      ),
                      Text(
                        item.title,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(delay: (index * 100).ms)
              .fadeIn()
              .slideX(begin: 0.3, duration: 600.ms);
        },
      ),
    );
  }

  Widget _buildMainFeatures(bool isTablet, AppLocalizations l10n) {
    final dashboardItems = _getDashboardItems(l10n);
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacing16,
              mainAxisSpacing: AppTheme.spacing16,
              childAspectRatio: isTablet ? 1.2 : 1.1,
            ),
            itemCount: dashboardItems.length,
            itemBuilder: (context, index) {
              final item = dashboardItems[index];
              return _buildFeatureCard(item, isTablet, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(DashboardItem item, bool isTablet, int index) {
    return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: item.color.withValues(alpha: 0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _navigateToFeature(item.title);
              },
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
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                        border: Border.all(
                          color: item.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: isTablet ? 32 : 28,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing12),
                    Text(
                      item.title,
                      style: AppTheme.labelLarge.copyWith(
                        fontSize: isTablet ? 16 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      item.subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (index * 150).ms)
        .fadeIn()
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms);
  }

  Widget _buildRecentActivity(bool isTablet, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivity,
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          Container(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  l10n.lessons,
                  l10n.education,
                  Icons.school_rounded,
                  AppTheme.primaryColor,
                  l10n.today,
                  isTablet,
                ),
                Divider(height: AppTheme.spacing24),
                _buildActivityItem(
                  l10n.healthTracking,
                  l10n.menstrualCycle,
                  Icons.favorite_rounded,
                  AppTheme.secondaryColor,
                  l10n.yesterday,
                  isTablet,
                ),
                Divider(height: AppTheme.spacing24),
                _buildActivityItem(
                  l10n.messages,
                  l10n.healthWorker,
                  Icons.chat_rounded,
                  AppTheme.accentColor,
                  l10n.today,
                  isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
    bool isTablet,
  ) {
    return Row(
      children: [
        Container(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
          ),
          child: Icon(icon, color: color, size: isTablet ? 24 : 20),
        ),
        SizedBox(width: AppTheme.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.labelLarge.copyWith(
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildVoiceButton() {
    return VoiceButton(
      prompt:
          'Vuga: "Amasomo" kugira ngo ugere ku masomo, "Ubuzima" kugira ngo ugere ku buzima, cyangwa "Amavuriro" kugira ngo ugere ku mavuriro',
      onResult: _handleVoiceCommand,
      tooltip: 'Koresha ijwi kugenda imbere',
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('amasomo') ||
        lowerCommand.contains('education')) {
      // Navigate to education
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ugiye mu masomo...')));
    } else if (lowerCommand.contains('ubuzima') ||
        lowerCommand.contains('health')) {
      // Navigate to health tracking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ugiye mu gukurikirana ubuzima...')),
      );
    } else if (lowerCommand.contains('amavuriro') ||
        lowerCommand.contains('clinic')) {
      // Navigate to clinics
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ugiye mu mavuriro...')));
    }
  }

  void _navigateToFeature(String featureName) {
    Widget screen;

    switch (featureName) {
      case 'Amasomo':
        screen = const EducationScreen();
        break;
      case 'Gukurikirana':
        screen = const HealthTrackingScreen();
        break;
      case 'Ubutumwa':
        screen = const MessagingScreen();
        break;
      case 'Amavuriro':
        screen = const ClinicLocatorScreen();
        break;
      case 'Kurinda inda':
        screen = const ContraceptionManagementScreen();
        break;
      case 'Gahunda':
        screen = const AppointmentBookingScreen();
        break;
      case 'Umukunzi':
        screen = const PartnerInvolvementScreen();
        break;
      case 'Indwara':
        screen = const STIPreventionScreen();
        break;
      case 'Inda':
        screen = const PregnancyPlanningScreen();
        break;
      case 'Umujyanama w\'AI':
        screen = const AIChatScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: AppConstants.mediumAnimation,
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const EducationScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const HealthTrackingScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
        break;
      case 3:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const CommunityScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
        break;
      case 4:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const MessagingScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
        break;
      case 5:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const ProfileScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
        break;
    }
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
            icon: Icon(Icons.home_rounded),
            label: 'Ahabanza',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Amasomo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Ubuzima',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            label: 'Umuryango',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Ubutumwa',
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

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String count;
  final String description;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.count,
    required this.description,
  });
}
