import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/health_record_model.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/voice_button.dart';
import 'chat_screen.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final List<ChatContact> _contacts = [
    ChatContact(
      id: '1',
      name: 'Dr. Uwimana Marie',
      role: 'Umuganga w\'abagore',
      lastMessage: 'Murakoze ku kubaza. Ni byiza gukurikirana imihango yawe.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 2,
      isOnline: true,
      avatar: 'assets/images/doctor_1.jpg',
    ),
    ChatContact(
      id: '2',
      name: 'Nurse Mukamana',
      role: 'Umuforomo',
      lastMessage: 'Ntugire ubwoba bwo kuza ku kigo cy\'ubuzima.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
      avatar: 'assets/images/nurse_1.jpg',
    ),
    ChatContact(
      id: '3',
      name: 'CHW Gasana',
      role: 'Umukozi w\'ubuzima mu mudugudu',
      lastMessage: 'Ejo hazaba inama ku buzima bw\'imyororokere.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 1,
      isOnline: true,
      avatar: 'assets/images/chw_1.jpg',
    ),
    ChatContact(
      id: '4',
      name: 'Dr. Nkurunziza',
      role: 'Umuganga mukuru',
      lastMessage: 'Gahunda yawe y\'ubuzima igenda neza.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
      avatar: 'assets/images/doctor_2.jpg',
    ),
  ];

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('muganga') || lowerCommand.contains('doctor')) {
      // Filter to show only doctors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Abaganga bose...')));
    } else if (lowerCommand.contains('umuforomo') ||
        lowerCommand.contains('nurse')) {
      // Filter to show only nurses
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Abaforomo bose...')));
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

          // Quick Actions
          SliverToBoxAdapter(child: _buildQuickActions(isTablet)),

          // Contacts List
          SliverToBoxAdapter(child: _buildContactsList(isTablet)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Muganga" kugira ngo ugere ku baganga, cyangwa "Umuforomo" kugira ngo ugere ku baforomo',
        onResult: _handleVoiceCommand,
        tooltip: 'Shakisha abaganga mu ijwi',
      ),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor,
                AppTheme.accentColor.withValues(alpha: 0.8),
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
                          Icons.chat_rounded,
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
                              'Ubutumwa',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 28 : 24,
                              ),
                            ),
                            Text(
                              'Vugana n\'abaganga n\'abaforomo',
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusRound,
                          ),
                        ),
                        child: Text(
                          '3 bishya',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.accentColor,
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

  Widget _buildQuickActions(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
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
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Gusaba ubufasha bw\'ihutirwa',
                  'Hamagara abaganga',
                  Icons.emergency_rounded,
                  AppTheme.errorColor,
                  isTablet,
                  () {
                    // Emergency contact
                    _showEmergencyDialog();
                  },
                ),
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: _buildQuickActionCard(
                  'Gushyiraho gahunda',
                  'Gahunda y\'ubuzima',
                  Icons.calendar_today_rounded,
                  AppTheme.primaryColor,
                  isTablet,
                  () {
                    // Schedule appointment
                    _showAppointmentDialog();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isTablet,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
            child: Column(
              children: [
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                  ),
                  child: Icon(icon, color: color, size: isTablet ? 28 : 24),
                ),
                SizedBox(height: AppTheme.spacing12),
                Text(
                  title,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abaganga n\'abaforomo',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return _buildContactCard(contact, isTablet, index);
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildContactCard(ChatContact contact, bool isTablet, int index) {
    return Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
            border:
                contact.unreadCount > 0
                    ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    )
                    : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) => ChatScreen(
                          contact: HealthWorker(
                            id: contact.id,
                            name: contact.name,
                            specialization: contact.role,
                            facilityId: '',
                            phone: '+250788123456',
                            email:
                                '${contact.name.toLowerCase().replaceAll(' ', '.')}@health.gov.rw',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        ),
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
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                child: Row(
                  children: [
                    // Avatar with online status
                    Stack(
                      children: [
                        Container(
                          width: isTablet ? 60 : 50,
                          height: isTablet ? 60 : 50,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              isTablet ? 30 : 25,
                            ),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: isTablet ? 32 : 28,
                          ),
                        ),
                        if (contact.isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.surfaceColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: AppTheme.spacing16),

                    // Contact Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                contact.name,
                                style: AppTheme.labelLarge.copyWith(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight:
                                      contact.unreadCount > 0
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatTime(contact.lastMessageTime),
                                style: AppTheme.bodySmall.copyWith(
                                  color:
                                      contact.unreadCount > 0
                                          ? AppTheme.primaryColor
                                          : AppTheme.textTertiary,
                                  fontWeight:
                                      contact.unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            contact.role,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  contact.lastMessage,
                                  style: AppTheme.bodySmall.copyWith(
                                    color:
                                        contact.unreadCount > 0
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                    fontWeight:
                                        contact.unreadCount > 0
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (contact.unreadCount > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing8,
                                    vertical: AppTheme.spacing4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusRound,
                                    ),
                                  ),
                                  child: Text(
                                    '${contact.unreadCount}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Gusaba ubufasha bw\'ihutirwa'),
            content: const Text('Urashaka guhamagara abaganga b\'ihutirwa?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kuraguza'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Make emergency call
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text(
                  'Hamagara',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showAppointmentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Gushyiraho gahunda'),
            content: const Text('Urashaka gushyiraho gahunda y\'ubuzima?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kuraguza'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Schedule appointment
                },
                child: const Text('Shyiraho'),
              ),
            ],
          ),
    );
  }
}

class ChatContact {
  final String id;
  final String name;
  final String role;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String avatar;

  ChatContact({
    required this.id,
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.avatar,
  });
}
