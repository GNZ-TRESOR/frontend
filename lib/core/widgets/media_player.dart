import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';

/// Media Player Types
enum MediaPlayerType { video, audio }

/// Media Player State
class MediaPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isMuted;
  final String? error;

  const MediaPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isMuted = false,
    this.error,
  });

  MediaPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isMuted,
    String? error,
    bool clearError = false,
  }) {
    return MediaPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      error: clearError ? null : (error ?? this.error),
    );
  }

  double get progressPercentage {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }
}

/// Media Player Notifier
class MediaPlayerNotifier extends StateNotifier<MediaPlayerState> {
  MediaPlayerNotifier() : super(const MediaPlayerState());

  void play() {
    // TODO: Implement actual media player integration
    state = state.copyWith(isPlaying: true, clearError: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void stop() {
    state = state.copyWith(
      isPlaying: false,
      position: Duration.zero,
    );
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }

  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isPlaying: false, isLoading: false);
  }
}

/// Media Player Provider
final mediaPlayerProvider = StateNotifierProvider.family<MediaPlayerNotifier, MediaPlayerState, String>(
  (ref, playerId) => MediaPlayerNotifier(),
);

/// Reusable Media Player Widget
class MediaPlayer extends ConsumerWidget {
  final String url;
  final MediaPlayerType type;
  final String? title;
  final String? subtitle;
  final Function(Duration)? onProgressUpdate;
  final Function()? onCompleted;
  final bool showControls;
  final bool autoPlay;
  final double? aspectRatio;

  const MediaPlayer({
    super.key,
    required this.url,
    required this.type,
    this.title,
    this.subtitle,
    this.onProgressUpdate,
    this.onCompleted,
    this.showControls = true,
    this.autoPlay = false,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerId = '${type.name}_${url.hashCode}';
    final playerState = ref.watch(mediaPlayerProvider(playerId));
    final playerNotifier = ref.read(mediaPlayerProvider(playerId).notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Media Display Area
          AspectRatio(
            aspectRatio: aspectRatio ?? (type == MediaPlayerType.video ? 16 / 9 : 4 / 1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Media Content
                  Center(
                    child: type == MediaPlayerType.video
                        ? _buildVideoPlayer(playerState, playerNotifier)
                        : _buildAudioPlayer(playerState, playerNotifier),
                  ),
                  
                  // Loading Overlay
                  if (playerState.isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  
                  // Error Overlay
                  if (playerState.error != null)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error loading media',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              playerState.error!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Controls
          if (showControls) _buildControls(context, playerState, playerNotifier),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(MediaPlayerState state, MediaPlayerNotifier notifier) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video placeholder (in real implementation, this would be the video widget)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 8),
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          
          // Play/Pause overlay
          if (!state.isLoading)
            Center(
              child: GestureDetector(
                onTap: () {
                  if (state.isPlaying) {
                    notifier.pause();
                  } else {
                    notifier.play();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(MediaPlayerState state, MediaPlayerNotifier notifier) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.educationBlue.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.audiotrack,
            size: 48,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 16),
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                subtitle!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, MediaPlayerState state, MediaPlayerNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: [
              Text(
                _formatDuration(state.position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: state.progressPercentage,
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds: (value * state.duration.inMilliseconds).round(),
                      );
                      notifier.seek(newPosition);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(state.duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous (placeholder)
              IconButton(
                onPressed: () {
                  // TODO: Implement previous functionality
                },
                icon: const Icon(Icons.skip_previous, color: Colors.white70),
              ),
              
              const SizedBox(width: 16),
              
              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    if (state.isPlaying) {
                      notifier.pause();
                    } else {
                      notifier.play();
                    }
                  },
                  icon: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Next (placeholder)
              IconButton(
                onPressed: () {
                  // TODO: Implement next functionality
                },
                icon: const Icon(Icons.skip_next, color: Colors.white70),
              ),
              
              const Spacer(),
              
              // Volume Control
              IconButton(
                onPressed: () => notifier.toggleMute(),
                icon: Icon(
                  state.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
