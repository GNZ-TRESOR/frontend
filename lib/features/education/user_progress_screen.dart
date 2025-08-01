import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/education_lesson.dart';
import '../../core/models/education_progress.dart';
import '../../core/providers/education_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// User Progress Screen showing learning analytics and progress tracking
class UserProgressScreen extends ConsumerStatefulWidget {
  const UserProgressScreen({super.key});

  @override
  ConsumerState<UserProgressScreen> createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends ConsumerState<UserProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProgress();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    // Load user progress data
    await ref
        .read(educationProvider.notifier)
        .loadUserProgress(1); // TODO: Get actual user ID
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationProvider);
    final userProgress = educationState.userProgress;
    final lessons = educationState.lessons;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Learning Progress',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Completed'),
            Tab(text: 'In Progress'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: educationState.isLoadingProgress,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(userProgress, lessons),
            _buildCompletedTab(userProgress, lessons),
            _buildInProgressTab(userProgress, lessons),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    List<EducationProgress> progress,
    List<EducationLesson> lessons,
  ) {
    final completedCount = progress.where((p) => p.isCompleted).length;
    final inProgressCount =
        progress
            .where((p) => !p.isCompleted && p.progressPercentage > 0)
            .length;
    final totalLessons = lessons.length;
    final completionRate =
        totalLessons > 0 ? (completedCount / totalLessons) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Statistics
          _buildSectionHeader('Learning Statistics'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedCount.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'In Progress',
                  inProgressCount.toString(),
                  Icons.play_circle,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Lessons',
                  totalLessons.toString(),
                  Icons.library_books,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completion Rate',
                  '${completionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppColors.educationBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Chart
          _buildSectionHeader('Progress Overview'),
          const SizedBox(height: 16),
          _buildProgressChart(completionRate),
          const SizedBox(height: 24),

          // Recent Activity
          _buildSectionHeader('Recent Activity'),
          const SizedBox(height: 16),
          _buildRecentActivity(progress, lessons),
        ],
      ),
    );
  }

  Widget _buildCompletedTab(
    List<EducationProgress> progress,
    List<EducationLesson> lessons,
  ) {
    final completedProgress = progress.where((p) => p.isCompleted).toList();

    if (completedProgress.isEmpty) {
      return _buildEmptyState(
        'No Completed Lessons',
        'Start learning to see your completed lessons here',
        Icons.school,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedProgress.length,
      itemBuilder: (context, index) {
        final progressItem = completedProgress[index];
        final lesson =
            progressItem.lesson ??
            const EducationLesson(
              title: 'Unknown Lesson',
              category: EducationCategory.generalHealth,
              level: EducationLevel.beginner,
            );
        return _buildProgressCard(progressItem, lesson, true);
      },
    );
  }

  Widget _buildInProgressTab(
    List<EducationProgress> progress,
    List<EducationLesson> lessons,
  ) {
    final inProgressItems =
        progress
            .where((p) => !p.isCompleted && p.progressPercentage > 0)
            .toList();

    if (inProgressItems.isEmpty) {
      return _buildEmptyState(
        'No Lessons in Progress',
        'Start a lesson to track your progress here',
        Icons.play_circle_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inProgressItems.length,
      itemBuilder: (context, index) {
        final progressItem = inProgressItems[index];
        final lesson =
            progressItem.lesson ??
            const EducationLesson(
              title: 'Unknown Lesson',
              category: EducationCategory.generalHealth,
              level: EducationLevel.beginner,
            );
        return _buildProgressCard(progressItem, lesson, false);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(double completionRate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Progress',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: completionRate / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                Center(
                  child: Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(
    List<EducationProgress> progress,
    List<EducationLesson> lessons,
  ) {
    final recentProgress =
        progress.where((p) => p.lastAccessedAt != null).toList()
          ..sort((a, b) => b.lastAccessedAt!.compareTo(a.lastAccessedAt!));

    final recent = recentProgress.take(5).toList();

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children:
          recent.map((progressItem) {
            final lesson =
                progressItem.lesson ??
                const EducationLesson(
                  title: 'Unknown Lesson',
                  category: EducationCategory.generalHealth,
                  level: EducationLevel.beginner,
                );
            return _buildActivityItem(progressItem, lesson);
          }).toList(),
    );
  }

  Widget _buildActivityItem(
    EducationProgress progress,
    EducationLesson lesson,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            progress.isCompleted ? Icons.check_circle : Icons.play_circle,
            color: progress.isCompleted ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  progress.isCompleted
                      ? 'Completed'
                      : '${progress.progressPercentage}% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (progress.lastAccessedAt != null)
            Text(
              _formatDate(progress.lastAccessedAt!),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    EducationProgress progress,
    EducationLesson lesson,
    bool isCompleted,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle,
                  color: isCompleted ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.categoryDisplayName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (!isCompleted) ...[
              LinearProgressIndicator(
                value: progress.progressPercentage / 100,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.progressPercentage}% complete',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (progress.completedAt != null)
              Text(
                'Completed on ${_formatDate(progress.completedAt!)}',
                style: const TextStyle(fontSize: 12, color: AppColors.success),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
