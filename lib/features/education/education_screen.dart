import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/voice_button.dart';
import 'lesson_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'all';
  final List<EducationCategory> _categories = [
    EducationCategory(id: 'all', name: 'Byose', icon: Icons.apps_rounded),
    EducationCategory(id: 'family_planning', name: 'Kubana n\'ubwiyunge', icon: Icons.family_restroom_rounded),
    EducationCategory(id: 'reproductive_health', name: 'Ubuzima bw\'imyororokere', icon: Icons.health_and_safety_rounded),
    EducationCategory(id: 'contraception', name: 'Gukumira inda', icon: Icons.medical_services_rounded),
    EducationCategory(id: 'pregnancy', name: 'Inda', icon: Icons.pregnant_woman_rounded),
  ];

  final List<EducationLesson> _lessons = [
    EducationLesson(
      id: '1',
      title: 'Kubana n\'ubwiyunge - Ibanze',
      description: 'Menya ibanze ku kubana n\'ubwiyunge n\'uburyo bwo gutegura umuryango wawe.',
      category: 'family_planning',
      duration: '15 iminota',
      difficulty: 'Byoroshye',
      imageUrl: 'assets/images/family_planning_1.jpg',
      isCompleted: true,
      progress: 100,
      audioUrl: 'assets/audio/family_planning_1.mp3',
    ),
    EducationLesson(
      id: '2',
      title: 'Uburyo bwo gukumira inda',
      description: 'Iga uburyo butandukanye bwo gukumira inda n\'uburyo bwo guhitamo ubukwiye.',
      category: 'contraception',
      duration: '20 iminota',
      difficulty: 'Hagati',
      imageUrl: 'assets/images/contraception_1.jpg',
      isCompleted: false,
      progress: 45,
      audioUrl: 'assets/audio/contraception_1.mp3',
    ),
    EducationLesson(
      id: '3',
      title: 'Ubuzima bw\'imyororokere bw\'abagore',
      description: 'Menya byinshi ku buzima bw\'imyororokere bw\'abagore n\'uburyo bwo bwita.',
      category: 'reproductive_health',
      duration: '18 iminota',
      difficulty: 'Byoroshye',
      imageUrl: 'assets/images/reproductive_health_1.jpg',
      isCompleted: false,
      progress: 0,
      audioUrl: 'assets/audio/reproductive_health_1.mp3',
    ),
    EducationLesson(
      id: '4',
      title: 'Gutegura inda',
      description: 'Ibyo ugomba kumenya mbere yo gufata inda n\'uburyo bwo kwita ku buzima bwawe.',
      category: 'pregnancy',
      duration: '25 iminota',
      difficulty: 'Bigoye',
      imageUrl: 'assets/images/pregnancy_1.jpg',
      isCompleted: false,
      progress: 0,
      audioUrl: 'assets/audio/pregnancy_1.mp3',
    ),
    EducationLesson(
      id: '5',
      title: 'Imihango y\'abagore',
      description: 'Menya byinshi ku mihango y\'abagore n\'uburyo bwo kuyikurikirana.',
      category: 'reproductive_health',
      duration: '12 iminota',
      difficulty: 'Byoroshye',
      imageUrl: 'assets/images/menstrual_cycle.jpg',
      isCompleted: true,
      progress: 100,
      audioUrl: 'assets/audio/menstrual_cycle.mp3',
    ),
  ];

  List<EducationLesson> get _filteredLessons {
    if (_selectedCategory == 'all') return _lessons;
    return _lessons.where((lesson) => lesson.category == _selectedCategory).toList();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('kubana') || lowerCommand.contains('family')) {
      setState(() {
        _selectedCategory = 'family_planning';
      });
    } else if (lowerCommand.contains('gukumira') || lowerCommand.contains('contraception')) {
      setState(() {
        _selectedCategory = 'contraception';
      });
    } else if (lowerCommand.contains('ubuzima') || lowerCommand.contains('health')) {
      setState(() {
        _selectedCategory = 'reproductive_health';
      });
    } else if (lowerCommand.contains('inda') || lowerCommand.contains('pregnancy')) {
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
          SliverToBoxAdapter(
            child: _buildCategories(isTablet),
          ),
          
          // Progress Overview
          SliverToBoxAdapter(
            child: _buildProgressOverview(isTablet),
          ),
          
          // Lessons Grid
          SliverPadding(
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                crossAxisSpacing: AppTheme.spacing16,
                mainAxisSpacing: AppTheme.spacing16,
                childAspectRatio: isTablet ? 1.2 : 1.4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = _filteredLessons[index];
                  return _buildLessonCard(lesson, isTablet, index);
                },
                childCount: _filteredLessons.length,
              ),
            ),
          ),
          
          // Bottom Padding
          SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacing64),
          ),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Kubana" kugira ngo ugere ku masomo y\'umuryango, "Gukumira" kugira ngo ugere ku buryo bwo gukumira inda',
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
              padding: EdgeInsets.all(isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
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
                          borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
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
        padding: EdgeInsets.symmetric(horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.id;
          
          return Container(
            margin: EdgeInsets.only(
              right: index < _categories.length - 1 ? AppTheme.spacing12 : 0,
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
                    horizontal: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                    vertical: isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                    boxShadow: isSelected ? AppTheme.softShadow : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected ? Colors.white : AppTheme.primaryColor,
                        size: isTablet ? 24 : 20,
                      ),
                      SizedBox(width: AppTheme.spacing8),
                      Text(
                        category.name,
                        style: AppTheme.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate(delay: (index * 100).ms).fadeIn().slideX(
            begin: 0.3,
            duration: 600.ms,
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(bool isTablet) {
    final completedLessons = _lessons.where((lesson) => lesson.isCompleted).length;
    final totalLessons = _lessons.length;
    final progressPercentage = (completedLessons / totalLessons * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
        vertical: AppTheme.spacing16,
      ),
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing20),
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
    ).animate().fadeIn(delay: 400.ms).slideY(
      begin: 0.3,
      duration: 800.ms,
    );
  }

  Widget _buildLessonCard(EducationLesson lesson, bool isTablet, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: lesson.isCompleted 
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
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LessonDetailScreen(lesson: lesson),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
            padding: EdgeInsets.all(isTablet ? AppTheme.spacing20 : AppTheme.spacing16),
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
                        color: lesson.isCompleted 
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        lesson.isCompleted ? 'Byarangiye' : lesson.difficulty,
                        style: AppTheme.bodySmall.copyWith(
                          color: lesson.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      lesson.isCompleted ? Icons.check_circle_rounded : Icons.play_circle_rounded,
                      color: lesson.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
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
                  lesson.description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Progress bar
                if (lesson.progress > 0) ...[
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
                            '${lesson.progress}%',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      LinearProgressIndicator(
                        value: lesson.progress / 100,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          lesson.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
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
                      lesson.duration,
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
    ).animate(delay: (index * 150).ms).fadeIn().slideY(
      begin: 0.3,
      duration: 600.ms,
    );
  }
}

class EducationCategory {
  final String id;
  final String name;
  final IconData icon;

  EducationCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class EducationLesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String difficulty;
  final String imageUrl;
  final bool isCompleted;
  final int progress;
  final String audioUrl;

  EducationLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
    required this.isCompleted,
    required this.progress,
    required this.audioUrl,
  });
}
