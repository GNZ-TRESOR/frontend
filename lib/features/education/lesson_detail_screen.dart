import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../core/models/education_lesson.dart';
import '../../core/models/education_progress.dart';
import '../../core/providers/education_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/simple_translated_text.dart';
import '../../core/mixins/tts_screen_mixin.dart';

/// Professional Lesson Detail Screen with media player and progress tracking
class LessonDetailScreen extends ConsumerStatefulWidget {
  final EducationLesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen>
    with TTSScreenMixin, TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isVideoInitialized = false;
  bool _isAudioPlaying = false;
  bool _isVideoPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  final TextEditingController _notesController = TextEditingController();
  bool _isCompleted = false;
  EducationProgress? _userProgress;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMedia();

    // Load lesson data after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLessonData();
    });
  }

  void _loadLessonData() {
    final user = ref.read(authProvider).user;
    if (user != null && user.id != null) {
      // Check if we already have progress data loaded
      final educationState = ref.read(educationProvider);
      if (educationState.userProgress.isEmpty &&
          !educationState.isLoadingProgress) {
        // Try to load progress data, but don't block the UI if it fails
        ref.read(educationProvider.notifier).loadUserProgress(user.id!).catchError((
          error,
        ) {
          print('Failed to load progress data: $error');
          // Continue without progress data - the UI will handle this gracefully
        });
      }
    }
  }

  void _initializeMedia() {
    // Initialize video player if video URL exists
    if (widget.lesson.videoUrl != null && widget.lesson.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.lesson.videoUrl!),
      );
      _videoController!.initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
    }

    // Initialize audio player if audio URL exists
    if (widget.lesson.audioUrl != null && widget.lesson.audioUrl!.isNotEmpty) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.onDurationChanged.listen((duration) {
        setState(() {
          _audioDuration = duration;
        });
      });
      _audioPlayer!.onPositionChanged.listen((position) {
        setState(() {
          _audioPosition = position;
        });
      });
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationProvider);
    final user = ref.watch(authProvider).user;

    // Get user progress for this lesson
    _userProgress =
        educationState.userProgress
            .where((p) => p.lesson?.id == widget.lesson.id)
            .firstOrNull;

    _isCompleted = _userProgress?.isCompleted ?? false;

    return addTTSToScaffold(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: widget.lesson.title.str(),
        backgroundColor: AppColors.educationBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            ),
            onPressed: () => _toggleCompletion(),
            tooltip: _isCompleted ? 'Mark as incomplete' : 'Mark as complete',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareLesson(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(child: 'Content'.str()),
            Tab(child: 'Notes'.str()),
            Tab(child: 'Progress'.str()),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading:
            educationState.isLoadingProgress && educationState.error == null,
        child:
            educationState.error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load progress data',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can still view the lesson content',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Show lesson content without progress
                          setState(() {
                            _tabController.animateTo(0); // Go to content tab
                          });
                        },
                        child: const Text('View Lesson'),
                      ),
                    ],
                  ),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContentTab(),
                    _buildNotesTab(),
                    _buildProgressTab(),
                  ],
                ),
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Header
          _buildLessonHeader(),
          const SizedBox(height: 24),

          // Media Player Section
          if (widget.lesson.videoUrl != null || widget.lesson.audioUrl != null)
            _buildMediaSection(),

          // Lesson Content
          if (widget.lesson.content != null) ...[
            const SizedBox(height: 24),
            _buildContentSection(),
          ],

          // Tags Section
          if (widget.lesson.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(),
          ],

          // Action Buttons
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (widget.lesson.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.lesson.description!,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.lesson.author != null) ...[
                  Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    widget.lesson.author!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (widget.lesson.durationMinutes != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.lesson.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
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
                    _getLevelDisplayName(widget.lesson.level),
                    style: TextStyle(
                      fontSize: 12,
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
    );
  }

  Widget _buildMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Video Player
            if (widget.lesson.videoUrl != null) _buildVideoPlayer(),

            // Audio Player
            if (widget.lesson.audioUrl != null) _buildAudioPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  if (_isVideoPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                  _isVideoPlaying = !_isVideoPlaying;
                });
              },
            ),
            Expanded(
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: AppColors.educationBlue,
                  bufferedColor: AppColors.educationBlue.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.educationBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.headphones, color: AppColors.educationBlue),
              const SizedBox(width: 8),
              Text(
                'Audio Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.educationBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                  color: AppColors.educationBlue,
                ),
                onPressed: () async {
                  if (_isAudioPlaying) {
                    await _audioPlayer!.pause();
                  } else {
                    await _audioPlayer!.play(
                      UrlSource(widget.lesson.audioUrl!),
                    );
                  }
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value: _audioPosition.inSeconds.toDouble(),
                      max: _audioDuration.inSeconds.toDouble(),
                      onChanged: (value) async {
                        await _audioPlayer!.seek(
                          Duration(seconds: value.toInt()),
                        );
                      },
                      activeColor: AppColors.educationBlue,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_audioPosition),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(_audioDuration),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.lesson.content!,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.lesson.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.educationBlue.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.educationBlue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.educationBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _toggleCompletion(),
            icon: Icon(
              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            ),
            label: Text(
              _isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isCompleted ? AppColors.success : AppColors.educationBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareLesson(),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _bookmarkLesson(),
                icon: const Icon(Icons.bookmark_border),
                label: const Text('Bookmark'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _notesController,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText:
                              'Add your personal notes about this lesson...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveNotes(),
                        icon: const Icon(Icons.save),
                        label: const Text('Save Notes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.educationBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            _isCompleted
                                ? AppColors.success
                                : AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCompleted ? 'Completed' : 'In Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    _isCompleted
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                              ),
                            ),
                            if (_userProgress?.completedAt != null)
                              Text(
                                'Completed on ${_formatDate(_userProgress!.completedAt!)}',
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
                  if (_userProgress?.progressPercentage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Progress: ${(_userProgress!.progressPercentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _userProgress!.progressPercentage,
                      backgroundColor: AppColors.textSecondary.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.educationBlue,
                      ),
                    ),
                  ],
                  if (_userProgress?.timeSpentMinutes != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Time spent: ${_userProgress!.timeSpentMinutes} minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _toggleCompletion() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.id == null) return;

    try {
      if (_isCompleted) {
        // Mark as incomplete - for now just show message since method doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mark as incomplete feature coming soon'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      } else {
        // Mark as complete
        await ref
            .read(educationProvider.notifier)
            .markLessonComplete(
              lessonId: widget.lesson.id!,
              userId: user.id!,
              timeSpentMinutes: _userProgress?.timeSpentMinutes,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isCompleted
                  ? 'Lesson marked as incomplete'
                  : 'Lesson completed!',
            ),
            backgroundColor:
                _isCompleted ? AppColors.warning : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating lesson progress: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _saveNotes() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.id == null) return;

    try {
      await ref
          .read(educationProvider.notifier)
          .saveLessonNotes(
            lessonId: widget.lesson.id!,
            userId: user.id!,
            notes: _notesController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving notes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareLesson() {
    // TODO: Implement lesson sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing feature coming soon')),
    );
  }

  void _bookmarkLesson() {
    // TODO: Implement lesson bookmarking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark feature coming soon')),
    );
  }

  // TTS Implementation
  @override
  String getTTSContent(BuildContext context, WidgetRef ref) {
    final buffer = StringBuffer();

    buffer.write('Lesson: ${widget.lesson.title}. ');

    if (widget.lesson.description != null) {
      buffer.write('Description: ${widget.lesson.description}. ');
    }

    if (widget.lesson.author != null) {
      buffer.write('Author: ${widget.lesson.author}. ');
    }

    if (widget.lesson.durationMinutes != null) {
      buffer.write('Duration: ${widget.lesson.durationMinutes} minutes. ');
    }

    buffer.write('Level: ${_getLevelDisplayName(widget.lesson.level)}. ');

    if (_isCompleted) {
      buffer.write('This lesson is completed. ');
    } else {
      buffer.write('This lesson is in progress. ');
    }

    if (widget.lesson.content != null) {
      buffer.write('Content: ${widget.lesson.content}');
    }

    return buffer.toString();
  }

  @override
  String getScreenName() => 'Lesson Detail';
}
