import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/simple_translated_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/mixins/tts_screen_mixin.dart';
import '../../core/providers/education_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/education_lesson.dart';

import 'lesson_detail_screen.dart';

/// Professional Education Screen
class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen>
    with TickerProviderStateMixin, TTSScreenMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final user = ref.read(authProvider).user;
    if (user != null && user.id != null) {
      final educationNotifier = ref.read(educationProvider.notifier);
      educationNotifier.loadLessons();
      educationNotifier.loadUserProgress(user.id!);
      educationNotifier.loadUserDashboard(user.id!);
      educationNotifier.loadRecommendedLessons(user.id!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationProvider);
    final user = ref.watch(authProvider).user;
    final isHealthWorker = user?.isHealthWorker ?? false;

    return addTTSToScaffold(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: 'Health Education'.str(),
        backgroundColor: AppColors.educationBlue,
        foregroundColor: Colors.white,
        actions: [
          if (isHealthWorker)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToAdminPanel(),
              tooltip: 'Manage Lessons',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(child: 'Featured'.str()),
            Tab(child: 'Categories'.str()),
            Tab(child: 'My Learning'.str()),
            Tab(child: 'Search'.str()),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: educationState.hasAnyLoading,
        child:
            educationState.error != null
                ? _buildErrorState(educationState.error!)
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeaturedTab(),
                    _buildCategoriesTab(),
                    _buildMyLearningTab(),
                    _buildSearchTab(),
                  ],
                ),
      ),
    );
  }

  Widget _buildFeaturedTab() {
    final featuredLessons = ref.watch(featuredLessonsProvider);
    final recommendedLessons = ref.watch(recommendedLessonsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Lessons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (featuredLessons.isEmpty)
            _buildEmptyState('No featured lessons available')
          else
            ...featuredLessons.map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFeaturedLessonCard(lesson),
              ),
            ),
          if (recommendedLessons.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Recommended for You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...recommendedLessons
                .take(3)
                .map(
                  (lesson) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildRecommendedLessonCard(lesson),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedLesson(
    String title,
    String description,
    String instructor,
    String duration,
    double rating,
    String imagePath,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _openLesson(title),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.educationBlue.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: AppColors.educationBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        instructor,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
    );
  }

  Widget _buildPopularLessons() {
    final popularLessons = [
      'STI Prevention and Testing',
      'Fertility Awareness Methods',
      'Healthy Pregnancy Nutrition',
      'Postpartum Care Essentials',
    ];

    return Column(
      children:
          popularLessons.map((lesson) => _buildCompactLesson(lesson)).toList(),
    );
  }

  Widget _buildCompactLesson(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.educationBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.play_arrow,
            color: AppColors.educationBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '12 min',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Icon(Icons.star, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              '4.6',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Icon(Icons.bookmark_border, color: AppColors.textSecondary),
        onTap: () => _openLesson(title),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildCategoryCard(
                'Family Planning',
                Icons.family_restroom,
                AppColors.primary,
                '24 lessons',
              ),
              _buildCategoryCard(
                'Reproductive Health',
                Icons.favorite,
                AppColors.error,
                '18 lessons',
              ),
              _buildCategoryCard(
                'Pregnancy & Birth',
                Icons.pregnant_woman,
                AppColors.pregnancyPurple,
                '32 lessons',
              ),
              _buildCategoryCard(
                'Contraception',
                Icons.shield,
                AppColors.contraceptionOrange,
                '15 lessons',
              ),
              _buildCategoryCard(
                'Sexual Health',
                Icons.health_and_safety,
                AppColors.secondary,
                '21 lessons',
              ),
              _buildCategoryCard(
                'Mental Wellness',
                Icons.psychology,
                AppColors.success,
                '16 lessons',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    String lessonCount,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _openCategory(title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                lessonCount,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyLearningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Learning Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressCard(),
          const SizedBox(height: 24),
          Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInProgressLesson(
            'Understanding Your Menstrual Cycle',
            'Dr. Sarah Johnson',
            0.65,
            '10 of 15 min completed',
          ),
          const SizedBox(height: 12),
          _buildInProgressLesson(
            'Contraception Options Explained',
            'Dr. Michael Brown',
            0.30,
            '7 of 22 min completed',
          ),
          const SizedBox(height: 24),
          Text(
            'Completed Lessons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCompletedLesson('Fertility Awareness Methods', '4.8'),
          _buildCompletedLesson('STI Prevention and Testing', '4.9'),
          _buildCompletedLesson('Healthy Pregnancy Nutrition', '4.7'),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.educationBlue,
            AppColors.educationBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Learning Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Lessons Completed', '12')),
              Expanded(child: _buildStatItem('Hours Learned', '8.5')),
              Expanded(child: _buildStatItem('Certificates', '3')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildInProgressLesson(
    String title,
    String instructor,
    double progress,
    String progressText,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _openLesson(title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.educationBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: AppColors.educationBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          instructor,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.educationBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progressText,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedLesson(String title, String rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.star, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'Rated $rating',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Icon(Icons.replay, color: AppColors.textSecondary),
        onTap: () => _openLesson(title),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search lessons, topics, instructors...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.educationBlue),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isEmpty) ...[
            _buildSearchSuggestions(),
          ] else ...[
            _buildSearchResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'Birth Control',
                  'Pregnancy',
                  'Fertility',
                  'STI Prevention',
                  'Menstrual Health',
                  'Family Planning',
                ].map((tag) => _buildSearchTag(tag)).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentSearch('Contraception methods'),
          _buildRecentSearch('Pregnancy nutrition'),
          _buildRecentSearch('Menstrual cycle tracking'),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String tag) {
    return InkWell(
      onTap: () => _performSearch(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.educationBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.educationBlue.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: TextStyle(fontSize: 14, color: AppColors.educationBlue),
        ),
      ),
    );
  }

  Widget _buildRecentSearch(String search) {
    return ListTile(
      leading: Icon(Icons.history, color: AppColors.textSecondary),
      title: Text(
        search,
        style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      trailing: Icon(
        Icons.north_west,
        color: AppColors.textSecondary,
        size: 16,
      ),
      onTap: () => _performSearch(search),
    );
  }

  Widget _buildSearchResults() {
    // Mock search results
    final results =
        [
              'Understanding Your Menstrual Cycle',
              'Contraception Options Explained',
              'Preparing for Pregnancy',
            ]
            .where(
              (lesson) =>
                  lesson.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${results.length} results for "$_searchQuery"',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildCompactLesson(results[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLessonCard(EducationLesson lesson) {
    return Card(
      child: InkWell(
        onTap: () => _openLessonDetail(lesson),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.educationBlue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  lesson.videoUrl != null
                      ? Icons.play_circle_filled
                      : lesson.audioUrl != null
                      ? Icons.headphones
                      : Icons.article,
                  size: 64,
                  color: AppColors.educationBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (lesson.description != null)
                    Text(
                      lesson.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (lesson.author != null) ...[
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.author!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
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
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.educationBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getLevelDisplayName(lesson.level),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.educationBlue,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildRecommendedLessonCard(EducationLesson lesson) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.educationBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            lesson.videoUrl != null
                ? Icons.play_circle_filled
                : lesson.audioUrl != null
                ? Icons.headphones
                : Icons.article,
            color: AppColors.educationBlue,
          ),
        ),
        title: Text(lesson.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle:
            lesson.durationMinutes != null
                ? Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
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
                  ],
                )
                : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: () => _openLessonDetail(lesson),
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
            'Error loading education content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    final user = ref.read(authProvider).user;
    if (user != null && user.id != null) {
      ref.read(educationProvider.notifier).refresh(userId: user.id!);
    }
  }

  void _navigateToAdminPanel() {
    // TODO: Navigate to admin lesson management screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Admin panel coming soon')));
  }

  // Helper methods for data formatting
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

  void _openLessonDetail(EducationLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailScreen(lesson: lesson),
      ),
    );
  }

  // Action methods
  void _openLesson(String lessonTitle) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening lesson: $lessonTitle')));
  }

  void _openCategory(String categoryTitle) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening category: $categoryTitle')));
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
  }

  // TTS Implementation
  @override
  String getTTSContent(BuildContext context, WidgetRef ref) {
    final currentTab = _tabController.index;

    final buffer = StringBuffer();
    buffer.write('Health Education screen. ');

    String tabName = '';
    switch (currentTab) {
      case 0:
        tabName = 'Featured Content';
        buffer.write('You are viewing featured educational content. ');
        buffer.write(
          'Here you can find the latest and most important health education materials. ',
        );
        buffer.write(
          'Topics include family planning, contraception, reproductive health, and wellness. ',
        );
        break;
      case 1:
        tabName = 'Categories';
        buffer.write('You are viewing educational categories. ');
        buffer.write('Browse different topics including: ');
        buffer.write(
          'Family Planning, Contraception Methods, Reproductive Health, ',
        );
        buffer.write(
          'Pregnancy Planning, STI Prevention, and General Wellness. ',
        );
        break;
      case 2:
        tabName = 'My Learning';
        buffer.write('You are viewing your personal learning progress. ');
        buffer.write(
          'Here you can track completed courses, bookmarked content, and your learning history. ',
        );
        break;
      case 3:
        tabName = 'Search';
        buffer.write('You are on the search tab. ');
        if (_searchQuery.isNotEmpty) {
          buffer.write('Current search: $_searchQuery. ');
        } else {
          buffer.write(
            'You can search for specific health education topics here. ',
          );
        }
        break;
    }

    buffer.write('Current tab: $tabName. ');

    return buffer.toString();
  }

  @override
  String getScreenName() => 'Health Education';
}
