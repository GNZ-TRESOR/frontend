import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';
import 'support_groups_screen.dart';
import 'forums_screen.dart';
import 'community_events_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  final List<CommunityHighlight> _highlights = [
    CommunityHighlight(
      title: 'Itsinda ry\'abagore',
      description: 'Itsinda ry\'abagore biga kubana n\'ubwiyunge',
      memberCount: 156,
      type: 'Support Group',
      isActive: true,
      image: 'assets/images/women_group.jpg',
    ),
    CommunityHighlight(
      title: 'Ikiganiro cy\'ubuzima',
      description: 'Ikiganiro gishya kuri ubuzima bw\'imyororokere',
      memberCount: 89,
      type: 'Forum',
      isActive: true,
      image: 'assets/images/health_discussion.jpg',
    ),
    CommunityHighlight(
      title: 'Ubwiyunge bw\'urubyiruko',
      description: 'Amasomo y\'ubwiyunge ku rubyiruko',
      memberCount: 234,
      type: 'Event',
      isActive: false,
      image: 'assets/images/youth_education.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCommunityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunityData() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amakuru y\'umuryango');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('itsinda') || lowerCommand.contains('group')) {
      _navigateToSupportGroups();
    } else if (lowerCommand.contains('ikiganiro') || lowerCommand.contains('forum')) {
      _navigateToForums();
    } else if (lowerCommand.contains('ibirori') || lowerCommand.contains('event')) {
      _navigateToEvents();
    }
  }

  void _navigateToSupportGroups() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SupportGroupsScreen()),
    );
  }

  void _navigateToForums() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForumsScreen()),
    );
  }

  void _navigateToEvents() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CommunityEventsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(isTablet),
            _buildCommunityStats(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(isTablet),
                  _buildActiveGroupsTab(isTablet),
                  _buildMyActivityTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'create_group',
            onPressed: _showCreateGroupDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Itsinda" kugira ngo ugere ku matsinda, "Ikiganiro" kugira ngo ugere ku biganiro, cyangwa "Ibirori" kugira ngo ugere ku birori',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga umuryango',
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 120 : 100,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Umuryango',
          style: AppTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityStats(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Abanyamuryango',
                '2,456',
                Icons.people_rounded,
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
                'Amatsinda',
                '23',
                Icons.groups_rounded,
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
                'Ibirori',
                '8',
                Icons.event_rounded,
                AppTheme.accentColor,
                isTablet,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isTablet) {
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

  Widget _buildTabBar(bool isTablet) {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textTertiary,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: 'Rusange', icon: Icon(Icons.dashboard)),
          Tab(text: 'Amatsinda', icon: Icon(Icons.groups)),
          Tab(text: 'Ibyanjye', icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ibikomeye mu muryango',
            style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacing16),
          ...List.generate(_highlights.length, (index) {
            final highlight = _highlights[index];
            return _buildHighlightCard(highlight, isTablet, index);
          }),
          SizedBox(height: AppTheme.spacing24),
          _buildQuickActions(isTablet),
        ],
      ),
    );
  }

  Widget _buildActiveGroupsTab(bool isTablet) {
    return const SupportGroupsScreen();
  }

  Widget _buildMyActivityTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ibikorwa byanjye',
            style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildActivityList(isTablet),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(CommunityHighlight highlight, bool isTablet, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: _getTypeColor(highlight.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getTypeIcon(highlight.type),
                    color: _getTypeColor(highlight.type),
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.title,
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        highlight.type,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                if (highlight.isActive)
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
                      'Gikora',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              highlight.description,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  '${highlight.memberCount} abanyamuryango',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _joinGroup(highlight),
                  child: const Text('Kwinjira'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  Widget _buildQuickActions(bool isTablet) {
    final actions = [
      QuickAction(
        title: 'Amatsinda y\'ubufasha',
        icon: Icons.support_agent,
        color: AppTheme.primaryColor,
        onTap: _navigateToSupportGroups,
      ),
      QuickAction(
        title: 'Ibiganiro',
        icon: Icons.forum,
        color: AppTheme.secondaryColor,
        onTap: _navigateToForums,
      ),
      QuickAction(
        title: 'Ibirori',
        icon: Icons.event,
        color: AppTheme.accentColor,
        onTap: _navigateToEvents,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ibikorwa byihuse',
          style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppTheme.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: AppTheme.spacing16,
            mainAxisSpacing: AppTheme.spacing16,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(action, isTablet);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(QuickAction action, bool isTablet) {
    return Card(
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color, size: isTablet ? 32 : 28),
              SizedBox(height: AppTheme.spacing8),
              Text(
                action.title,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(bool isTablet) {
    return Column(
      children: [
        _buildActivityItem('Winjiye mu tsinda ry\'abagore', '2 amasaha ashize', Icons.group_add),
        _buildActivityItem('Watanze igitekerezo ku kiganiro', '5 amasaha ashize', Icons.comment),
        _buildActivityItem('Witabiriye ikiganiro cy\'ubuzima', 'Ejo', Icons.event_available),
        _buildActivityItem('Washyize igitekerezo ku masomo', '2 iminsi ishize', Icons.thumb_up),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Support Group':
        return AppTheme.primaryColor;
      case 'Forum':
        return AppTheme.secondaryColor;
      case 'Event':
        return AppTheme.accentColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Support Group':
        return Icons.support_agent;
      case 'Forum':
        return Icons.forum;
      case 'Event':
        return Icons.event;
      default:
        return Icons.group;
    }
  }

  void _joinGroup(CommunityHighlight highlight) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kwinjira mu ${highlight.title} - Izaza vuba...')),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurema itsinda'),
        content: const Text('Iyi fonctionnalité izaza vuba...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
        ],
      ),
    );
  }
}

class CommunityHighlight {
  final String title;
  final String description;
  final int memberCount;
  final String type;
  final bool isActive;
  final String image;

  CommunityHighlight({
    required this.title,
    required this.description,
    required this.memberCount,
    required this.type,
    required this.isActive,
    required this.image,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
