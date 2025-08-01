import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/mixins/tts_screen_mixin.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../feedback/feedback_screen.dart';

/// Professional Profile Screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TTSScreenMixin {
  @override
  Widget build(BuildContext context) {
    return addTTSToScaffold(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(currentUserProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildProfileOptions(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Text(
              user?.initials ?? 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.roleDisplayName ?? 'Client',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    final options = [
      ProfileOption(
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        icon: Icons.edit,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit profile feature coming soon!')),
          );
        },
      ),
      ProfileOption(
        title: 'Settings',
        subtitle: 'Manage app preferences and privacy',
        icon: Icons.settings,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
      ProfileOption(
        title: 'Notifications',
        subtitle: 'View and manage notifications',
        icon: Icons.notifications,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      ),
      ProfileOption(
        title: 'Send Feedback',
        subtitle: 'Help us improve the app',
        icon: Icons.feedback,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedbackScreen()),
          );
        },
      ),
      ProfileOption(
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        icon: Icons.help,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
        },
      ),
      ProfileOption(
        title: 'About',
        subtitle: 'App version and information',
        icon: Icons.info,
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
        },
      ),
    ];

    return Column(
      children:
          options.map((option) => _buildProfileOptionCard(option)).toList(),
    );
  }

  Widget _buildProfileOptionCard(ProfileOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: option.onTap,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: 8),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  // TTS Implementation
  @override
  String getTTSContent(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final buffer = StringBuffer();
    buffer.write('Profile screen. ');

    if (user != null) {
      buffer.write('Welcome ${user.firstName} ${user.lastName}. ');
      buffer.write('Email: ${user.email}. ');
      if (user.phoneNumber != null) {
        buffer.write('Phone: ${user.phoneNumber}. ');
      }
      buffer.write('Role: ${user.role}. ');
    }

    buffer.write('Available options: ');
    buffer.write('1. Settings - Manage your account preferences. ');
    buffer.write('2. Notifications - View and manage your notifications. ');
    buffer.write('3. Help and Support - Get assistance and provide feedback. ');
    buffer.write('4. About - Learn more about the Ubuzima platform. ');
    buffer.write('5. Logout - Sign out of your account. ');

    return buffer.toString();
  }

  String getScreenName() => 'Profile';
}

/// Profile option data class
class ProfileOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  ProfileOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
