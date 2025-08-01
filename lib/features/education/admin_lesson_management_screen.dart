import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/education_lesson.dart';
import '../../core/providers/education_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import 'lesson_form_screen.dart';
import '../../core/widgets/simple_translated_text.dart';
import 'lesson_detail_screen.dart';

/// Professional Admin Lesson Management Screen
class AdminLessonManagementScreen extends ConsumerStatefulWidget {
  const AdminLessonManagementScreen({super.key});

  @override
  ConsumerState<AdminLessonManagementScreen> createState() =>
      _AdminLessonManagementScreenState();
}

class _AdminLessonManagementScreenState
    extends ConsumerState<AdminLessonManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLevel;
  bool? _selectedPublishStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLessons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadLessons() {
    ref.read(educationProvider.notifier).loadAllLessons();
    ref.read(educationProvider.notifier).loadEducationAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationProvider);
    final user = ref.watch(authProvider).user;

    // Check admin access
    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: 'Access Denied'.str()),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              'Admin access required'.str(
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: 'Lesson Management'.str(),
        backgroundColor: AppColors.educationBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLessons,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalytics(),
            tooltip: 'Analytics',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(child: 'All Lessons'.str()),
            Tab(child: 'Published'.str()),
            Tab(child: 'Drafts'.str()),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: educationState.isLoading,
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildLessonStats(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLessonList(null), // All lessons
                  _buildLessonList(true), // Published only
                  _buildLessonList(false), // Unpublished only
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewLesson(),
        backgroundColor: AppColors.educationBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: 'New Lesson'.str(),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search lessons...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),

          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Category',
                  _selectedCategory,
                  EducationCategory.values.map((e) => e.name).toList(),
                  (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Level',
                  _selectedLevel,
                  EducationLevel.values.map((e) => e.name).toList(),
                  (value) => setState(() => _selectedLevel = value),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Status',
                  _selectedPublishStatus?.toString(),
                  ['true', 'false'],
                  (value) => setState(
                    () =>
                        _selectedPublishStatus =
                            value == null ? null : value == 'true',
                  ),
                ),
                const SizedBox(width: 8),
                if (_selectedCategory != null ||
                    _selectedLevel != null ||
                    _selectedPublishStatus != null)
                  TextButton.icon(
                    onPressed:
                        () => setState(() {
                          _selectedCategory = null;
                          _selectedLevel = null;
                          _selectedPublishStatus = null;
                        }),
                    icon: const Icon(Icons.clear_all),
                    label: 'Clear Filters'.str(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return PopupMenuButton<String>(
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(value: null, child: Text('All ${label}s')),
            ...options.map(
              (option) => PopupMenuItem<String>(
                value: option,
                child: Text(_getDisplayName(option)),
              ),
            ),
          ],
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              value != null
                  ? AppColors.educationBlue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                value != null
                    ? AppColors.educationBlue
                    : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? '$label: $value' : label,
              style: TextStyle(
                fontSize: 12,
                color:
                    value != null
                        ? AppColors.educationBlue
                        : AppColors.textSecondary,
                fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color:
                  value != null
                      ? AppColors.educationBlue
                      : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(String value) {
    switch (value) {
      case 'true':
        return 'Published';
      case 'false':
        return 'Draft';
      default:
        return value
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty
                      ? word
                      : word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  Widget _buildLessonStats() {
    final educationState = ref.watch(educationProvider);
    final analytics = educationState.analytics;

    if (analytics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Lessons',
              analytics.totalLessons.toString(),
              Icons.article,
              AppColors.educationBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Published',
              analytics.publishedLessons.toString(),
              Icons.publish,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Drafts',
              analytics.unpublishedLessons.toString(),
              Icons.edit_note,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completion Rate',
              '${analytics.completionRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonList(bool? publishedFilter) {
    final educationState = ref.watch(educationProvider);
    List<EducationLesson> lessons = educationState.lessons;

    // Apply filters
    if (publishedFilter != null) {
      lessons =
          lessons
              .where((lesson) => lesson.isPublished == publishedFilter)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      lessons =
          lessons
              .where(
                (lesson) =>
                    lesson.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (lesson.description?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false) ||
                    (lesson.author?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    if (_selectedCategory != null) {
      lessons =
          lessons
              .where((lesson) => lesson.category.name == _selectedCategory)
              .toList();
    }

    if (_selectedLevel != null) {
      lessons =
          lessons
              .where((lesson) => lesson.level.name == _selectedLevel)
              .toList();
    }

    if (educationState.error != null) {
      return _buildErrorState(educationState.error!);
    }

    if (lessons.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadLessons(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, index) => _buildLessonCard(lessons[index]),
      ),
    );
  }

  Widget _buildLessonCard(EducationLesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewLesson(lesson),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lesson.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            lesson.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleLessonAction(lesson, value),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: lesson.isPublished ? 'unpublish' : 'publish',
                            child: Text(
                              lesson.isPublished ? 'Unpublish' : 'Publish',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Text('Duplicate'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lesson metadata
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMetadataChip(
                    _getCategoryDisplayName(lesson.category),
                    AppColors.educationBlue,
                  ),
                  _buildMetadataChip(
                    _getLevelDisplayName(lesson.level),
                    AppColors.secondary,
                  ),
                  if (lesson.author != null)
                    _buildMetadataChip(lesson.author!, AppColors.textSecondary),
                  _buildMetadataChip(
                    lesson.isPublished ? 'Published' : 'Draft',
                    lesson.isPublished ? AppColors.success : AppColors.warning,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Lesson stats
              Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.viewCount} views',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (lesson.durationMinutes != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.durationMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (lesson.createdAt != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(lesson.createdAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading lessons',
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadLessons,
            icon: const Icon(Icons.refresh),
            label: 'Retry'.str(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.educationBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          'No lessons found'.str(
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          'Create your first lesson to get started'.str(
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _createNewLesson(),
            icon: const Icon(Icons.add),
            label: 'Create Lesson'.str(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.educationBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _handleLessonAction(EducationLesson lesson, String action) {
    switch (action) {
      case 'view':
        _viewLesson(lesson);
        break;
      case 'edit':
        _editLesson(lesson);
        break;
      case 'publish':
      case 'unpublish':
        _togglePublishStatus(lesson);
        break;
      case 'duplicate':
        _duplicateLesson(lesson);
        break;
      case 'delete':
        _showDeleteConfirmation(lesson);
        break;
    }
  }

  void _viewLesson(EducationLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailScreen(lesson: lesson),
      ),
    );
  }

  void _createNewLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LessonFormScreen()),
    ).then((_) => _loadLessons());
  }

  void _editLesson(EducationLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonFormScreen(lesson: lesson)),
    ).then((_) => _loadLessons());
  }

  Future<void> _togglePublishStatus(EducationLesson lesson) async {
    if (lesson.id == null) return;

    try {
      await ref
          .read(educationProvider.notifier)
          .toggleLessonPublishStatus(lesson.id!);
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update lesson: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _duplicateLesson(EducationLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonFormScreen(duplicateFrom: lesson),
      ),
    ).then((_) => _loadLessons());
  }

  void _showDeleteConfirmation(EducationLesson lesson) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: 'Delete Lesson'.str(),
            content:
                'Are you sure you want to delete "${lesson.title}"? This action cannot be undone.'
                    .str(),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: 'Cancel'.str(),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteLesson(lesson);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: 'Delete'.str(),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteLesson(EducationLesson lesson) async {
    if (lesson.id == null) return;

    try {
      await ref.read(educationProvider.notifier).deleteLesson(lesson.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lesson "${lesson.title}" deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete lesson: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAnalytics() {
    final analytics = ref.read(educationProvider).analytics;
    if (analytics == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: 'Education Analytics'.str(),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnalyticsRow(
                    'Total Lessons',
                    analytics.totalLessons.toString(),
                  ),
                  _buildAnalyticsRow(
                    'Published',
                    analytics.publishedLessons.toString(),
                  ),
                  _buildAnalyticsRow(
                    'Drafts',
                    analytics.unpublishedLessons.toString(),
                  ),
                  _buildAnalyticsRow(
                    'Completion Rate',
                    '${analytics.completionRate.toStringAsFixed(1)}%',
                  ),
                  _buildAnalyticsRow(
                    'Total Progress Records',
                    analytics.totalProgressRecords.toString(),
                  ),
                  _buildAnalyticsRow(
                    'Completed Lessons',
                    analytics.completedLessonsCount.toString(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: 'Close'.str(),
              ),
            ],
          ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper methods
  String _getCategoryDisplayName(EducationCategory category) {
    switch (category) {
      case EducationCategory.contraception:
        return 'Contraception';
      case EducationCategory.pregnancy:
        return 'Pregnancy';
      case EducationCategory.menstrualHealth:
        return 'Menstrual Health';
      case EducationCategory.stiPrevention:
        return 'STI Prevention';
      case EducationCategory.reproductiveHealth:
        return 'Reproductive Health';
      case EducationCategory.familyPlanning:
        return 'Family Planning';
      case EducationCategory.nutrition:
        return 'Nutrition';
      case EducationCategory.generalHealth:
        return 'General Health';
      case EducationCategory.maternalHealth:
        return 'Maternal Health';
      case EducationCategory.mentalHealth:
        return 'Mental Health';
    }
  }

  String _getLevelDisplayName(EducationLevel level) {
    switch (level) {
      case EducationLevel.beginner:
        return 'Beginner';
      case EducationLevel.intermediate:
        return 'Intermediate';
      case EducationLevel.advanced:
        return 'Advanced';
      case EducationLevel.expert:
        return 'Expert';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
