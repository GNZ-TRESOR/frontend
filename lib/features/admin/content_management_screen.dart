import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/services/api_service.dart';
import '../../core/models/education_lesson.dart';
import 'create_lesson_screen.dart';

/// Admin Content Management Screen
class ContentManagementScreen extends ConsumerStatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  ConsumerState<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState
    extends ConsumerState<ContentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<EducationLesson> _lessons = [];
  List<EducationLesson> _filteredContent = [];

  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.instance.getEducationLessons();

      if (response.success && response.data != null) {
        // Handle both possible response formats
        List<dynamic> lessonsData;
        if (response.data.containsKey('lessons')) {
          lessonsData = response.data['lessons'] as List<dynamic>? ?? [];
        } else {
          // Direct lessons array
          lessonsData = response.data as List<dynamic>? ?? [];
        }

        _lessons =
            lessonsData
                .map(
                  (json) =>
                      EducationLesson.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        _filterContent();
      } else {
        _error = response.message ?? 'Failed to load lessons';
      }
    } catch (e) {
      _error = 'Error loading lessons: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterContent() {
    List<EducationLesson> sourceList;
    switch (_tabController.index) {
      case 0:
        sourceList = _lessons;
        break;
      case 1:
        sourceList =
            _lessons
                .where((l) => l.videoUrl == null || l.videoUrl!.isEmpty)
                .toList();
        break;
      case 2:
        sourceList =
            _lessons
                .where((l) => l.videoUrl != null && l.videoUrl!.isNotEmpty)
                .toList();
        break;
      default:
        sourceList = [];
    }

    String query = _searchController.text.toLowerCase();

    _filteredContent =
        sourceList.where((lesson) {
          final matchesSearch =
              lesson.title.toLowerCase().contains(query) ||
              (lesson.description?.toLowerCase().contains(query) ?? false);
          final matchesCategory =
              _selectedCategory == 'All' ||
              lesson.category.name.toLowerCase() ==
                  _selectedCategory.toLowerCase().replaceAll(' ', '_');

          return matchesSearch && matchesCategory;
        }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Content Management'),
        backgroundColor: AppColors.educationBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadContent),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (_) => _filterContent(),
          tabs: const [
            Tab(text: 'All Content'),
            Tab(text: 'Articles'),
            Tab(text: 'Videos'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildContentStats(),
            Expanded(
              child: _error != null ? _buildErrorState() : _buildContentList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateContentDialog,
        backgroundColor: AppColors.educationBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search content...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.educationBlue),
              ),
            ),
            onChanged: (_) => _filterContent(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Category: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items:
                      [
                            'All',
                            'Family Planning',
                            'Contraception',
                            'Pregnancy',
                            'Menstrual Health',
                            'STI Prevention',
                            'Reproductive Health',
                          ]
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                    _filterContent();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentStats() {
    final totalLessons = _lessons.length;
    final articlesCount =
        _lessons.where((l) => l.videoUrl == null || l.videoUrl!.isEmpty).length;
    final videosCount =
        _lessons
            .where((l) => l.videoUrl != null && l.videoUrl!.isNotEmpty)
            .length;
    final publishedContent =
        _filteredContent.where((l) => l.isPublished).length;
    final draftContent = _filteredContent.where((l) => !l.isPublished).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard('Total', totalLessons, AppColors.primary),
            _buildStatCard('Articles', articlesCount, AppColors.educationBlue),
            _buildStatCard('Videos', videosCount, AppColors.secondary),
            _buildStatCard('Published', publishedContent, AppColors.success),
            _buildStatCard('Drafts', draftContent, AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    if (_filteredContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No content found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredContent.length,
      itemBuilder: (context, index) {
        final content = _filteredContent[index];
        return _buildContentCard(content);
      },
    );
  }

  Widget _buildContentCard(EducationLesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
                  ? AppColors.secondary
                  : AppColors.educationBlue,
          child: Icon(
            (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
                ? Icons.play_arrow
                : Icons.article,
            color: Colors.white,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.educationBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson.category.name.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.educationBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        lesson.isPublished
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson.isPublished ? 'Published' : 'Draft',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          lesson.isPublished
                              ? AppColors.success
                              : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleContentAction(lesson, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: lesson.isPublished ? 'unpublish' : 'publish',
                  child: Text(lesson.isPublished ? 'Unpublish' : 'Publish'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading content',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.educationBlue,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleContentAction(EducationLesson lesson, String action) {
    switch (action) {
      case 'view':
        _viewContent(lesson);
        break;
      case 'edit':
        _editContent(lesson);
        break;
      case 'publish':
      case 'unpublish':
        _togglePublishStatus(lesson);
        break;
      case 'delete':
        _showDeleteConfirmation(lesson);
        break;
    }
  }

  void _viewContent(EducationLesson lesson) {
    // TODO: Navigate to lesson view screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View ${lesson.title} - Coming Soon')),
    );
  }

  void _editContent(EducationLesson lesson) {
    // TODO: Navigate to lesson edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${lesson.title} - Coming Soon')),
    );
  }

  void _showCreateContentDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateLessonScreen(
              onLessonCreated: () {
                _loadContent(); // Refresh the list
              },
            ),
      ),
    );
  }

  Future<void> _togglePublishStatus(EducationLesson lesson) async {
    try {
      final response = await ApiService.instance.toggleLessonPublishStatus(
        lesson.id!,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lesson.isPublished
                    ? 'Lesson unpublished successfully'
                    : 'Lesson published successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          _loadContent(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Failed to toggle publish status',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(EducationLesson lesson) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lesson'),
            content: Text(
              'Are you sure you want to delete "${lesson.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteContent(lesson);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteContent(EducationLesson lesson) async {
    try {
      final response = await ApiService.instance.deleteEducationLesson(
        lesson.id!,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lesson "${lesson.title}" deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadContent(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to delete lesson'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
