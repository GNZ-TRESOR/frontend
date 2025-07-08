import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class ForumsScreen extends StatefulWidget {
  const ForumsScreen({super.key});

  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<ForumTopic> _topics = [
    ForumTopic(
      id: '1',
      title: 'Uburyo bwo kurinda inda bwiza',
      description: 'Ni ubuhe buryo bwiza bwo kurinda inda ku bagore?',
      category: 'Family Planning',
      author: 'Mukamana Marie',
      replies: 23,
      views: 156,
      lastReply: DateTime.now().subtract(const Duration(hours: 2)),
      isSticky: true,
      isLocked: false,
      tags: ['Kurinda inda', 'Abagore', 'Ubufasha'],
    ),
    ForumTopic(
      id: '2',
      title: 'Ubuzima bw\'urubyiruko',
      description: 'Ikiganiro ku buzima bw\'urubyiruko n\'imyitwarire myiza',
      category: 'Youth Health',
      author: 'Jean Baptiste',
      replies: 45,
      views: 289,
      lastReply: DateTime.now().subtract(const Duration(minutes: 30)),
      isSticky: false,
      isLocked: false,
      tags: ['Urubyiruko', 'Ubuzima', 'Imyitwarire'],
    ),
    ForumTopic(
      id: '3',
      title: 'Kurinda indwara zandurira',
      description: 'Amakuru ku kurinda indwara zandurira mu mibanire',
      category: 'STI Prevention',
      author: 'Dr. Grace Mukamana',
      replies: 67,
      views: 445,
      lastReply: DateTime.now().subtract(const Duration(hours: 1)),
      isSticky: false,
      isLocked: true,
      tags: ['Indwara', 'Kurinda', 'Mibanire'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka ibiganiro');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gushaka') || lowerCommand.contains('search')) {
      // Focus search field
    } else if (lowerCommand.contains('kurema') ||
        lowerCommand.contains('create')) {
      _showCreateTopicDialog();
    } else if (lowerCommand.contains('gusoma') ||
        lowerCommand.contains('read')) {
      // Open first topic
      if (_topics.isNotEmpty) {
        _openTopic(_topics.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ibiganiro'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSearchAndFilter(isTablet), _buildTabBar(isTablet)];
        },
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllTopicsTab(isTablet),
                    _buildPopularTab(isTablet),
                    _buildMyTopicsTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'create_topic',
            onPressed: _showCreateTopicDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt:
                'Vuga: "Gushaka" kugira ngo ushake, "Kurema" kugira ngo ureme ikiganiro, cyangwa "Gusoma" kugira ngo usome ikiganiro',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga ibiganiro',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Shakisha ibiganiro...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(height: AppTheme.spacing16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      'all',
                      'Family Planning',
                      'Youth Health',
                      'STI Prevention',
                      'Mental Health',
                    ].map((category) {
                      final isSelected = _selectedCategory == category;
                      return Container(
                        margin: EdgeInsets.only(right: AppTheme.spacing8),
                        child: FilterChip(
                          label: Text(_getCategoryLabel(category)),
                          selected: isSelected,
                          onSelected:
                              (selected) =>
                                  setState(() => _selectedCategory = category),
                          selectedColor: AppTheme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppTheme.primaryColor,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
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
          Tab(text: 'Byose', icon: Icon(Icons.forum)),
          Tab(text: 'Bizwi cyane', icon: Icon(Icons.trending_up)),
          Tab(text: 'Ibyanjye', icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildAllTopicsTab(bool isTablet) {
    return _buildTopicsList(isTablet);
  }

  Widget _buildPopularTab(bool isTablet) {
    final popularTopics = List<ForumTopic>.from(_topics)
      ..sort((a, b) => b.views.compareTo(a.views));
    return _buildTopicsList(isTablet, topics: popularTopics);
  }

  Widget _buildMyTopicsTab(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: isTablet ? 64 : 48,
            color: AppTheme.textTertiary,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'Ntabwo ufite ibiganiro',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
          ),
          SizedBox(height: AppTheme.spacing8),
          TextButton(
            onPressed: _showCreateTopicDialog,
            child: const Text('Tangira ikiganiro'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsList(bool isTablet, {List<ForumTopic>? topics}) {
    final topicsToShow = topics ?? _topics;
    final filteredTopics =
        topicsToShow.where((topic) {
          final matchesSearch =
              topic.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              topic.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          final matchesCategory =
              _selectedCategory == 'all' || topic.category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

    if (filteredTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta biganiro biboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacing8),
            TextButton(
              onPressed: _showCreateTopicDialog,
              child: const Text('Tangira ikiganiro'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
      ),
      itemCount: filteredTopics.length,
      itemBuilder: (context, index) {
        final topic = filteredTopics[index];
        return _buildTopicCard(topic, isTablet, index);
      },
    );
  }

  Widget _buildTopicCard(ForumTopic topic, bool isTablet, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: InkWell(
        onTap: () => _openTopic(topic),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        topic.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      _getCategoryIcon(topic.category),
                      color: _getCategoryColor(topic.category),
                      size: 16,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Row(
                      children: [
                        if (topic.isSticky)
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: AppTheme.warningColor,
                          ),
                        if (topic.isSticky) SizedBox(width: AppTheme.spacing4),
                        Expanded(
                          child: Text(
                            topic.title,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  topic.isSticky ? AppTheme.warningColor : null,
                            ),
                          ),
                        ),
                        if (topic.isLocked)
                          Icon(
                            Icons.lock,
                            size: 16,
                            color: AppTheme.textTertiary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing8),
              Text(
                topic.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppTheme.spacing12),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing4,
                children:
                    topic.tags
                        .take(3)
                        .map(
                          (tag) => Chip(
                            label: Text(tag, style: AppTheme.bodySmall),
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: AppTheme.textTertiary),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    topic.author,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing16),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    '${topic.replies}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing16),
                  Icon(
                    Icons.visibility,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Text(
                    '${topic.views}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(topic.lastReply),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'Byose';
      case 'Family Planning':
        return 'Ubwiyunge';
      case 'Youth Health':
        return 'Ubuzima bw\'urubyiruko';
      case 'STI Prevention':
        return 'Kurinda indwara';
      case 'Mental Health':
        return 'Ubuzima bw\'ubwoba';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Family Planning':
        return AppTheme.primaryColor;
      case 'Youth Health':
        return AppTheme.secondaryColor;
      case 'STI Prevention':
        return AppTheme.accentColor;
      case 'Mental Health':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Family Planning':
        return Icons.family_restroom;
      case 'Youth Health':
        return Icons.school;
      case 'STI Prevention':
        return Icons.health_and_safety;
      case 'Mental Health':
        return Icons.psychology;
      default:
        return Icons.forum;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} iminsi ishize';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} amasaha ashize';
    } else {
      return '${difference.inMinutes} iminota ishize';
    }
  }

  void _openTopic(ForumTopic topic) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(topic.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.description),
                SizedBox(height: AppTheme.spacing16),
                Text('Uwanditse: ${topic.author}'),
                Text('Ibisubizo: ${topic.replies}'),
                Text('Abareba: ${topic.views}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Siga'),
              ),
              if (!topic.isLocked)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _replyToTopic(topic);
                  },
                  child: const Text('Subiza'),
                ),
            ],
          ),
    );
  }

  void _replyToTopic(ForumTopic topic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gusubiza ${topic.title} - Izaza vuba...')),
    );
  }

  void _showCreateTopicDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kurema ikiganiro'),
            content: const Text(
              'Iyi fonctionnalité izaza vuba. Uzashobora kurema ikiganiro gishya.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sawa'),
              ),
            ],
          ),
    );
  }
}

class ForumTopic {
  final String id;
  final String title;
  final String description;
  final String category;
  final String author;
  final int replies;
  final int views;
  final DateTime lastReply;
  final bool isSticky;
  final bool isLocked;
  final List<String> tags;

  ForumTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.author,
    required this.replies,
    required this.views,
    required this.lastReply,
    required this.isSticky,
    required this.isLocked,
    required this.tags,
  });
}
