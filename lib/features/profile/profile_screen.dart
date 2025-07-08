import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/voice_button.dart';
import '../settings/settings_screen.dart';
import '../help/help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _userName = 'Mukamana Marie';
  final String _userRole = 'Umunyangire';
  final String _userLocation = 'Kigali, Rwanda';

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('guhindura') || lowerCommand.contains('edit')) {
      _showEditProfileDialog();
    } else if (lowerCommand.contains('igenamiterere') ||
        lowerCommand.contains('settings')) {
      _navigateToSettings();
    } else if (lowerCommand.contains('gusohoka') ||
        lowerCommand.contains('logout')) {
      _showLogoutDialog();
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
          // Custom App Bar with Profile Header
          _buildProfileHeader(isTablet),

          // Profile Stats
          SliverToBoxAdapter(child: _buildProfileStats(isTablet)),

          // Menu Options
          SliverToBoxAdapter(child: _buildMenuOptions(isTablet)),

          // Settings Section
          SliverToBoxAdapter(child: _buildSettingsSection(isTablet)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Guhindura" kugira ngo uhindure umwirondoro, "Igenamiterere" kugira ngo ugere ku genamiterere',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gukoresha umwirondoro',
      ),
    );
  }

  Widget _buildProfileHeader(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 300 : 250,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Profile Avatar
                  Container(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 120 : 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 60 : 50),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: isTablet ? 60 : 50,
                    ),
                  ),

                  SizedBox(height: AppTheme.spacing16),

                  // User Info
                  Text(
                    _userName,
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 24,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    _userRole,
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      SizedBox(width: AppTheme.spacing4),
                      Text(
                        _userLocation,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildProfileStats(bool isTablet) {
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
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Amasomo yarangiye',
              '12',
              Icons.school_rounded,
              AppTheme.primaryColor,
              isTablet,
            ),
          ),
          Container(
            width: 1,
            height: isTablet ? 60 : 50,
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Iminsi ikurikirana',
              '45',
              Icons.calendar_today_rounded,
              AppTheme.secondaryColor,
              isTablet,
            ),
          ),
          Container(
            width: 1,
            height: isTablet ? 60 : 50,
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Intego zagezweho',
              '8',
              Icons.emoji_events_rounded,
              AppTheme.accentColor,
              isTablet,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: isTablet ? 28 : 24),
        SizedBox(height: AppTheme.spacing8),
        Text(
          value,
          style: AppTheme.headingMedium.copyWith(
            color: color,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(height: AppTheme.spacing4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuOptions(bool isTablet) {
    final menuItems = [
      MenuOption(
        title: 'Guhindura umwirondoro',
        subtitle: 'Hindura amakuru yawe',
        icon: Icons.edit_rounded,
        color: AppTheme.primaryColor,
        onTap: _showEditProfileDialog,
      ),
      MenuOption(
        title: 'Amateka y\'ubuzima',
        subtitle: 'Reba amateka yawe y\'ubuzima',
        icon: Icons.history_rounded,
        color: AppTheme.secondaryColor,
        onTap: () {
          // Navigate to health history
        },
      ),
      MenuOption(
        title: 'Igenamiterere',
        subtitle: 'Hindura igenamiterere ry\'app',
        icon: Icons.settings_rounded,
        color: AppTheme.accentColor,
        onTap: _navigateToSettings,
      ),
      MenuOption(
        title: 'Ubufasha',
        subtitle: 'Saba ubufasha cyangwa ubwiyunge',
        icon: Icons.help_rounded,
        color: AppTheme.warningColor,
        onTap: _navigateToHelp,
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
            'Umwirondoro',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildMenuCard(item, isTablet, index);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildMenuCard(MenuOption item, bool isTablet, int index) {
    return Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: item.color.withValues(alpha: 0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
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
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: isTablet ? 28 : 24,
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
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            item.subtitle,
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
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn()
        .slideX(begin: 0.3, duration: 600.ms);
  }

  Widget _buildSettingsSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Igenamiterere',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Gusohoka'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.errorColor),
                foregroundColor: AppTheme.errorColor,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Guhindura umwirondoro'),
            content: const Text(
              'Iyi fonctionnalité izaza vuba. Urashobora guhindura amakuru yawe.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Sawa'),
              ),
            ],
          ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToHelp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HelpScreen()));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Gusohoka'),
            content: const Text('Urashaka gusohoka muri app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kuraguza'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Perform logout
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wasohokaga neza!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text(
                  'Sohoka',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class MenuOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
