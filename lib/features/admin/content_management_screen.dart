import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<ContentItem> _contentItems = [
    ContentItem(
      id: '1',
      title: 'Kubana n\'ubwiyunge',
      category: 'Family Planning',
      type: 'Lesson',
      status: 'Published',
      views: 1234,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ContentItem(
      id: '2',
      title: 'Uburyo bwo kurinda inda',
      category: 'Contraception',
      type: 'Guide',
      status: 'Draft',
      views: 0,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ContentItem(
      id: '3',
      title: 'Kurinda indwara zandurira',
      category: 'STI Prevention',
      type: 'Video',
      status: 'Published',
      views: 856,
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka ibikubiye');
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
    if (lowerCommand.contains('gushaka') || lowerCommand.contains('search')) {
      // Focus search field
    } else if (lowerCommand.contains('kongeraho') || lowerCommand.contains('add')) {
      _showAddContentDialog();
    } else if (lowerCommand.contains('gusiba') || lowerCommand.contains('filter')) {
      _showFilterDialog();
    }
  }

  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kongeraho ibikubiye'),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gusiba ibikubiye'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'all',
            'Family Planning',
            'Contraception',
            'STI Prevention',
            'Maternal Health'
          ].map((category) => RadioListTile<String>(
            title: Text(category == 'all' ? 'Byose' : category),
            value: category,
            groupValue: _selectedCategory,
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
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
            _buildSearchAndFilter(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildContentList(isTablet),
                  _buildLessonsTab(isTablet),
                  _buildVideosTab(isTablet),
                  _buildAnalyticsTab(isTablet),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_content',
            onPressed: _showAddContentDialog,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          VoiceButton(
            prompt: 'Vuga: "Kongeraho" kugira ngo wongeraho ibikubiye, "Gushaka" kugira ngo ushake, cyangwa "Gusiba" kugira ngo usibe',
            onResult: _handleVoiceCommand,
            tooltip: 'Koresha ijwi gucunga ibikubiye',
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
          'Gucunga amasomo',
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

  Widget _buildSearchAndFilter(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Shakisha amasomo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            SizedBox(width: AppTheme.spacing16),
            IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
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
        isScrollable: true,
        tabs: const [
          Tab(text: 'Byose', icon: Icon(Icons.list)),
          Tab(text: 'Amasomo', icon: Icon(Icons.school)),
          Tab(text: 'Amashusho', icon: Icon(Icons.video_library)),
          Tab(text: 'Imibare', icon: Icon(Icons.analytics)),
        ],
      ),
    );
  }

  Widget _buildContentList(bool isTablet) {
    final filteredContent = _contentItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _selectedCategory == 'all' || item.category == _selectedCategory;
      
      return matchesSearch && matchesFilter;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        final item = filteredContent[index];
        return _buildContentCard(item, isTablet).animate(delay: (index * 100).ms).fadeIn().slideX();
      },
    );
  }

  Widget _buildContentCard(ContentItem item, bool isTablet) {
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
                  padding: EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(item.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    _getTypeIcon(item.type),
                    color: _getTypeColor(item.type),
                    size: 20,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        item.category,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    item.status,
                    style: AppTheme.bodySmall.copyWith(
                      color: _getStatusColor(item.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Hindura')),
                    const PopupMenuItem(value: 'preview', child: Text('Reba')),
                    const PopupMenuItem(value: 'publish', child: Text('Tangaza')),
                    const PopupMenuItem(value: 'delete', child: Text('Siba')),
                  ],
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value - Izaza vuba...')),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  '${item.views} views',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: AppTheme.textTertiary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  _formatDate(item.lastUpdated),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsTab(bool isTablet) {
    return const Center(
      child: Text('Amasomo - Izaza vuba...'),
    );
  }

  Widget _buildVideosTab(bool isTablet) {
    return const Center(
      child: Text('Amashusho - Izaza vuba...'),
    );
  }

  Widget _buildAnalyticsTab(bool isTablet) {
    return const Center(
      child: Text('Imibare y\'amasomo - Izaza vuba...'),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Lesson':
        return AppTheme.primaryColor;
      case 'Video':
        return AppTheme.secondaryColor;
      case 'Guide':
        return AppTheme.accentColor;
      case 'Quiz':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Lesson':
        return Icons.school;
      case 'Video':
        return Icons.play_circle;
      case 'Guide':
        return Icons.book;
      case 'Quiz':
        return Icons.quiz;
      default:
        return Icons.article;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Published':
        return AppTheme.successColor;
      case 'Draft':
        return AppTheme.warningColor;
      case 'Archived':
        return AppTheme.textTertiary;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} iminsi ishize';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} amasaha ashize';
    } else {
      return '${difference.inMinutes} iminota ishize';
    }
  }
}

class ContentItem {
  final String id;
  final String title;
  final String category;
  final String type;
  final String status;
  final int views;
  final DateTime lastUpdated;

  ContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.status,
    required this.views,
    required this.lastUpdated,
  });
}
