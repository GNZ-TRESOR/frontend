import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/education_service.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/voice_button.dart';

class LessonDetailScreen extends StatefulWidget {
  final EducationLesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final EducationService _educationService = EducationService();
  final AuthService _authService = AuthService();

  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 100.0;
  bool _isCompleted = false;
  bool _isLoading = true;
  EducationProgress? _userProgress;

  @override
  void initState() {
    super.initState();
    _totalDuration =
        widget.lesson.estimatedDuration.toDouble() *
        60; // Convert minutes to seconds
    _loadUserProgress();
  }

  Future<void> _loadUserProgress() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final progressList = await _educationService.getUserProgress(
          currentUser.id,
        );
        _userProgress = progressList.firstWhere(
          (progress) => progress.lessonId == widget.lesson.id,
          orElse:
              () => EducationProgress(
                id: '',
                userId: currentUser.id,
                lessonId: widget.lesson.id,
                progressPercentage: 0.0,
                isCompleted: false,
                completedAt: null,
                timeSpent: 0,
                quizResults: null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );

        setState(() {
          _isCompleted = _userProgress?.isCompleted ?? false;
          _currentPosition =
              (_userProgress?.progressPercentage ?? 0.0) / 100 * _totalDuration;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to format lesson duration
  String _formatLessonDuration() {
    final minutes = widget.lesson.estimatedDuration;
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

  // Helper method to get lesson content in Kinyarwanda or fallback to English
  String _getLessonContent() {
    return widget.lesson.contentKinyarwanda.isNotEmpty
        ? widget.lesson.contentKinyarwanda
        : widget.lesson.content;
  }

  // Helper method to format difficulty
  String _formatDifficulty() {
    switch (widget.lesson.difficulty.toUpperCase()) {
      case 'BEGINNER':
        return 'Byoroshye';
      case 'INTERMEDIATE':
        return 'Hagati';
      case 'ADVANCED':
        return 'Bigoye';
      default:
        return widget.lesson.difficulty;
    }
  }

  Future<void> _updateProgress() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final progressPercentage = (_currentPosition / _totalDuration * 100)
            .clamp(0.0, 100.0);
        final timeSpent = _currentPosition.round();

        final updatedProgress = await _educationService.updateLessonProgress(
          userId: currentUser.id,
          lessonId: widget.lesson.id,
          progressPercentage: progressPercentage,
          timeSpent: timeSpent,
          isCompleted: _isCompleted,
        );

        if (updatedProgress != null) {
          setState(() {
            _userProgress = updatedProgress;
          });
        }
      }
    } catch (e) {
      // Handle error silently for now
      debugPrint('Error updating progress: $e');
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _simulateAudioProgress();
    }
  }

  void _simulateAudioProgress() {
    if (_isPlaying && _currentPosition < _totalDuration) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isPlaying) {
          setState(() {
            _currentPosition = (_currentPosition + 1).clamp(
              0.0,
              _totalDuration,
            );
            if (_currentPosition >= _totalDuration) {
              _isPlaying = false;
              _isCompleted = true;
            }
          });

          // Update progress every 5 seconds
          if (_currentPosition % 5 == 0) {
            _updateProgress();
          }

          _simulateAudioProgress();
        }
      });
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('gukina') || lowerCommand.contains('play')) {
      _togglePlayPause();
    } else if (lowerCommand.contains('guhagarika') ||
        lowerCommand.contains('pause')) {
      setState(() {
        _isPlaying = false;
      });
    } else if (lowerCommand.contains('subira') ||
        lowerCommand.contains('back')) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildAppBar(isTablet),

          // Audio Player
          SliverToBoxAdapter(child: _buildAudioPlayer(isTablet)),

          // Lesson Content
          SliverToBoxAdapter(child: _buildLessonContent(isTablet)),

          // Key Points
          SliverToBoxAdapter(child: _buildKeyPoints(isTablet)),

          // Action Buttons
          SliverToBoxAdapter(child: _buildActionButtons(isTablet)),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing64)),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Gukina" kugira ngo utangire isomo, "Guhagarika" kugira ngo uhagarike, cyangwa "Subira" kugira ngo usubirire inyuma',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gukurikirana isomo',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 300 : 250,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              _isCompleted
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isCompleted = !_isCompleted;
              });
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: isTablet ? 40 : 30,
                left: isTablet ? 32 : 24,
                right: isTablet ? 32 : 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        _formatDifficulty(),
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing12),
                    Text(
                      widget.lesson.title,
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.white,
                        fontSize: isTablet ? 32 : 28,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Text(
                          _formatLessonDuration(),
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
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
    );
  }

  Widget _buildAudioPlayer(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        children: [
          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  Text(
                    _formatDuration(_totalDuration),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: _currentPosition.clamp(0.0, _totalDuration),
                  max: _totalDuration,
                  activeColor: AppTheme.primaryColor,
                  inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  onChanged: (value) {
                    setState(() {
                      _currentPosition = value.clamp(0.0, _totalDuration);
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacing20),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Button
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.replay_10_rounded,
                    color: AppTheme.primaryColor,
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPosition = (_currentPosition - 10).clamp(
                        0,
                        _totalDuration,
                      );
                    });
                  },
                ),
              ),

              SizedBox(width: AppTheme.spacing24),

              // Play/Pause Button
              Container(
                    width: isTablet ? 80 : 70,
                    height: isTablet ? 80 : 70,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 40 : 35),
                      boxShadow: AppTheme.mediumShadow,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: isTablet ? 40 : 35,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  )
                  .animate(target: _isPlaying ? 1 : 0)
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
                    duration: 200.ms,
                  ),

              SizedBox(width: AppTheme.spacing24),

              // Forward Button
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.forward_10_rounded,
                    color: AppTheme.primaryColor,
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPosition = (_currentPosition + 10).clamp(
                        0,
                        _totalDuration,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildLessonContent(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ku iki gisomo',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            _getLessonContent(),
            style: AppTheme.bodyLarge.copyWith(height: 1.6),
          ),
          SizedBox(height: AppTheme.spacing20),
          Text(
            'Mu iki gisomo uziga:',
            style: AppTheme.headingSmall.copyWith(fontSize: isTablet ? 18 : 16),
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildLearningPoint('Ibanze ku buzima bw\'imyororokere'),
          _buildLearningPoint('Uburyo bwo kwita ku buzima bwawe'),
          _buildLearningPoint('Ibyangombwa by\'ingenzi byo kumenya'),
          _buildLearningPoint('Uko wakora ibyemezo byiza'),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildLearningPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoints(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(
        isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingingo z\'ingenzi',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildKeyPointCard(
            'Menya ubuzima bwawe',
            'Ni ngombwa kumenya ibijyanye n\'ubuzima bwawe bw\'imyororokere.',
            Icons.health_and_safety_rounded,
            AppTheme.primaryColor,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildKeyPointCard(
            'Gufata ibyemezo byiza',
            'Koresha amakuru meza kugira ngo ufate ibyemezo byiza ku buzima bwawe.',
            Icons.psychology_rounded,
            AppTheme.secondaryColor,
            isTablet,
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildKeyPointCard(
            'Gusaba ubufasha',
            'Ntugire ubwoba bwo gusaba ubufasha ku baganga cyangwa abajyanama.',
            Icons.support_agent_rounded,
            AppTheme.accentColor,
            isTablet,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildKeyPointCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 50 : 40,
            height: isTablet ? 50 : 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
            ),
            child: Icon(icon, color: color, size: isTablet ? 24 : 20),
          ),
          SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    color: color,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
      ),
      child: Column(
        children: [
          // Complete Lesson Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isCompleted = true;
                  _currentPosition = _totalDuration;
                });

                await _updateProgress();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Isomo ryarangiye neza! Komeza gutuma.'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCompleted
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(
                _isCompleted ? 'Isomo ryarangiye' : 'Rangiza isomo',
                style: AppTheme.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacing12),

          // Next Lesson Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to next lesson
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Isomo rikurikira',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
