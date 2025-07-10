import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/education_service.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/voice_button.dart';
import 'lesson_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'all';
  final EducationService _educationService = EducationService();
  final AuthService _authService = AuthService();

  List<EducationLesson> _lessons = [];
  List<EducationProgress> _userProgress = [];
  bool _isLoading = true;
  String? _error;

  final List<EducationCategory> _categories = [
    EducationCategory(id: 'all', name: 'Byose', icon: Icons.apps_rounded),
    EducationCategory(
      id: 'family_planning',
      name: 'Kubana n\'ubwiyunge',
      icon: Icons.family_restroom_rounded,
    ),
    EducationCategory(
      id: 'reproductive_health',
      name: 'Ubuzima bw\'imyororokere',
      icon: Icons.health_and_safety_rounded,
    ),
    EducationCategory(
      id: 'contraception',
      name: 'Gukumira inda',
      icon: Icons.medical_services_rounded,
    ),
    EducationCategory(
      id: 'pregnancy',
      name: 'Inda',
      icon: Icons.pregnant_woman_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadEducationData();
  }

  Future<void> _loadEducationData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to load lessons from API
      final lessons = await _educationService.getEducationLessons();

      // Load user progress if authenticated
      List<EducationProgress> progress = [];
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        try {
          progress = await _educationService.getUserProgress(currentUser.id);
        } catch (e) {
          // Progress loading failed, continue with empty progress
          debugPrint('Failed to load user progress: $e');
        }
      }

      setState(() {
        _lessons = lessons;
        _userProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load education lessons: $e');
      // Fallback to sample data if API fails
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    // Create sample lessons for demonstration
    final sampleLessons = <EducationLesson>[
      EducationLesson(
        id: '1',
        title: 'Kubana n\'ubwiyunge - Ibanze',
        titleKinyarwanda: 'Kubana n\'ubwiyunge - Ibanze',
        content:
            'Menya ibanze ku kubana n\'ubwiyunge n\'uburyo bwo gutegura umuryango wawe.',
        contentKinyarwanda:
            'Menya ibanze ku kubana n\'ubwiyunge n\'uburyo bwo gutegura umuryango wawe.',
        category: 'FAMILY_PLANNING',
        difficulty: 'BEGINNER',
        estimatedDuration: 15,
        tags: ['kubana', 'umuryango', 'ibanze'],
        imageUrls: ['assets/images/family_planning_1.jpg'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EducationLesson(
        id: '2',
        title: 'Uburyo bwo gukumira inda',
        titleKinyarwanda: 'Uburyo bwo gukumira inda',
        content:
            'Iga uburyo butandukanye bwo gukumira inda n\'uburyo bwo guhitamo ubukwiye.',
        contentKinyarwanda:
            'Iga uburyo butandukanye bwo gukumira inda n\'uburyo bwo guhitamo ubukwiye.',
        category: 'CONTRACEPTION',
        difficulty: 'INTERMEDIATE',
        estimatedDuration: 20,
        tags: ['gukumira', 'inda', 'uburyo'],
        imageUrls: ['assets/images/contraception_1.jpg'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EducationLesson(
        id: '3',
        title: 'Ubuzima bw\'imyororokere bw\'abagore',
        titleKinyarwanda: 'Ubuzima bw\'imyororokere bw\'abagore',
        content:
            'Menya byinshi ku buzima bw\'imyororokere bw\'abagore n\'uburyo bwo bwita.',
        contentKinyarwanda:
            'Menya byinshi ku buzima bw\'imyororokere bw\'abagore n\'uburyo bwo bwita.',
        category: 'REPRODUCTIVE_HEALTH',
        difficulty: 'BEGINNER',
        estimatedDuration: 18,
        tags: ['ubuzima', 'abagore', 'imyororokere'],
        imageUrls: ['assets/images/reproductive_health_1.jpg'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _lessons = sampleLessons;
      _userProgress = [];
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadEducationData();
  }

  // Helper method to get lesson progress
  EducationProgress? _getLessonProgress(String lessonId) {
    try {
      return _userProgress.firstWhere(
        (progress) => progress.lessonId == lessonId,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if lesson is completed
  bool _isLessonCompleted(String lessonId) {
    final progress = _getLessonProgress(lessonId);
    return progress?.isCompleted ?? false;
  }

  // Helper method to get lesson progress percentage
  int _getLessonProgressPercentage(String lessonId) {
    final progress = _getLessonProgress(lessonId);
    return progress?.progressPercentage.round() ?? 0;
  }

  // Helper method to format duration
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes iminota';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours ${hours == 1 ? 'isaha' : 'amasaha'}';
      } else {
        return '$hours ${hours == 1 ? 'isaha' : 'amasaha'} $remainingMinutes iminota';
      }
    }
  }

  // Helper method to format difficulty
  String _formatDifficulty(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
        return 'Byoroshye';
      case 'INTERMEDIATE':
        return 'Hagati';
      case 'ADVANCED':
        return 'Bigoye';
      default:
        return difficulty;
    }
  }

  List<EducationLesson> get _filteredLessons {
    if (_selectedCategory == 'all') return _lessons;
    return _lessons
        .where((lesson) => lesson.category == _selectedCategory)
        .toList();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('kubana') || lowerCommand.contains('family')) {
      setState(() {
        _selectedCategory = 'family_planning';
      });
    } else if (lowerCommand.contains('gukumira') ||
        lowerCommand.contains('contraception')) {
      setState(() {
        _selectedCategory = 'contraception';
      });
    } else if (lowerCommand.contains('ubuzima') ||
        lowerCommand.contains('health')) {
      setState(() {
        _selectedCategory = 'reproductive_health';
      });
    } else if (lowerCommand.contains('inda') ||
        lowerCommand.contains('pregnancy')) {
      setState(() {
        _selectedCategory = 'pregnancy';
      });
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

          // Categories
          SliverToBoxAdapter(child: _buildCategories(isTablet)),

          // Progress Overview
          SliverToBoxAdapter(child: _buildProgressOverview(isTablet)),

          // Lessons Grid
          SliverPadding(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                crossAxisSpacing: AppTheme.spacing16,
                mainAxisSpacing: AppTheme.spacing16,
                childAspectRatio: isTablet ? 1.2 : 1.4,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final lesson = _filteredLessons[index];
                return _buildLessonCard(lesson, isTablet, index);
              }, childCount: _filteredLessons.length),
            ),
          ),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Kubana" kugira ngo ugere ku masomo y\'umuryango, "Gukumira" kugira ngo ugere ku buryo bwo gukumira inda',
        onResult: _handleVoiceCommand,
        tooltip: 'Shakisha amasomo mu ijwi',
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
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
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
                          Icons.school_rounded,
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
                              'Amasomo',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 28,
                              ),
                            ),
                            Text(
                              'Iga ku buzima bw\'imyororokere',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
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

  Widget _buildCategories(bool isTablet) {
    return Container(
      height: isTablet ? 80 : 70,
      margin: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.id;

          return Container(
                margin: EdgeInsets.only(
                  right:
                      index < _categories.length - 1 ? AppTheme.spacing12 : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                        vertical:
                            isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryGradient : null,
                        color: isSelected ? null : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge,
                        ),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.transparent
                                  : AppTheme.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                        ),
                        boxShadow: isSelected ? AppTheme.softShadow : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                            size: isTablet ? 24 : 20,
                          ),
                          SizedBox(width: AppTheme.spacing8),
                          Text(
                            category.name,
                            style: AppTheme.labelMedium.copyWith(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }

  Widget _buildProgressOverview(bool isTablet) {
    final completedLessons =
        _lessons.where((lesson) => _isLessonCompleted(lesson.id)).length;
    final totalLessons = _lessons.length;
    final progressPercentage =
        totalLessons > 0 ? (completedLessons / totalLessons * 100).round() : 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
        vertical: AppTheme.spacing16,
      ),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.secondaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 80 : 70,
            height: isTablet ? 80 : 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isTablet ? 40 : 35),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressPercentage / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '$progressPercentage%',
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppTheme.spacing20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uko ugeze',
                  style: AppTheme.headingSmall.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 18,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  '$completedLessons ku $totalLessons amasomo yarangiye',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: AppTheme.spacing8),
                Text(
                  'Komeza gutuma! Ugiye gutsinda.',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 800.ms);
  }

  Widget _buildLessonCard(EducationLesson lesson, bool isTablet, int index) {
    return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color:
                  _isLessonCompleted(lesson.id)
                      ? AppTheme.successColor.withValues(alpha: 0.3)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            LessonDetailScreen(lesson: lesson),
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
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isLessonCompleted(lesson.id)
                                    ? AppTheme.successColor.withValues(
                                      alpha: 0.1,
                                    )
                                    : AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Text(
                            _isLessonCompleted(lesson.id)
                                ? 'Byarangiye'
                                : _formatDifficulty(lesson.difficulty),
                            style: AppTheme.bodySmall.copyWith(
                              color:
                                  _isLessonCompleted(lesson.id)
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          _isLessonCompleted(lesson.id)
                              ? Icons.check_circle_rounded
                              : Icons.play_circle_rounded,
                          color:
                              _isLessonCompleted(lesson.id)
                                  ? AppTheme.successColor
                                  : AppTheme.primaryColor,
                          size: isTablet ? 28 : 24,
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacing16),

                    // Title
                    Text(
                      lesson.title,
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: isTablet ? 18 : 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppTheme.spacing8),

                    // Description
                    Text(
                      lesson.content,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Progress bar
                    if (_getLessonProgressPercentage(lesson.id) > 0) ...[
                      SizedBox(height: AppTheme.spacing12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Uko ugeze',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              Text(
                                '${_getLessonProgressPercentage(lesson.id)}%',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          LinearProgressIndicator(
                            value:
                                _getLessonProgressPercentage(lesson.id) / 100,
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isLessonCompleted(lesson.id)
                                  ? AppTheme.successColor
                                  : AppTheme.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: AppTheme.spacing12),

                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppTheme.textTertiary,
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Text(
                          _formatDuration(lesson.estimatedDuration),
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
          ),
        )
        .animate(delay: (index * 150).ms)
        .fadeIn()
        .slideY(begin: 0.3, duration: 600.ms);
  }
}

class EducationCategory {
  final String id;
  final String name;
  final IconData icon;

  EducationCategory({required this.id, required this.name, required this.icon});
}
