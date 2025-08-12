import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// WhatsApp-style audio message player with waveform visualization
class AudioMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final int duration;
  final bool isMe;

  const AudioMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.duration,
    required this.isMe,
  });

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _setupAnimations();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.playing && _currentPosition == Duration.zero;
        });
        
        if (_isPlaying) {
          _waveController.repeat();
        } else {
          _waveController.stop();
        }
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _totalDuration = duration);
      }
    });
  }

  void _setupAnimations() {
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          await _audioPlayer.play(UrlSource(widget.audioUrl));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 250,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isMe 
                    ? Colors.green[700] 
                    : Colors.grey[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLoading 
                    ? Icons.hourglass_empty
                    : _isPlaying 
                        ? Icons.pause 
                        : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Waveform and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform visualization
                _buildWaveform(),
                
                const SizedBox(height: 4),
                
                // Duration
                Text(
                  _currentPosition > Duration.zero 
                      ? _formatDuration(_currentPosition)
                      : _formatDuration(Duration(seconds: widget.duration)),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Microphone icon
          Icon(
            Icons.mic,
            size: 16,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 30,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(
              progress: _totalDuration.inMilliseconds > 0 
                  ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                  : 0.0,
              isPlaying: _isPlaying,
              animationValue: _waveAnimation.value,
              isMe: widget.isMe,
            ),
            size: const Size(double.infinity, 30),
          );
        },
      ),
    );
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final double animationValue;
  final bool isMe;

  WaveformPainter({
    required this.progress,
    required this.isPlaying,
    required this.animationValue,
    required this.isMe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final playedPaint = Paint()
      ..color = isMe ? Colors.green[700]! : Colors.blue[600]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final unplayedPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Generate waveform bars
    const barCount = 20;
    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      
      // Generate pseudo-random heights for waveform effect
      final baseHeight = (i % 3 + 1) * 4.0;
      final animatedHeight = isPlaying 
          ? baseHeight + (animationValue * 6 * ((i % 2) + 1))
          : baseHeight;
      
      final barHeight = animatedHeight.clamp(2.0, size.height * 0.8);
      
      // Determine if this bar should be colored as played
      final barProgress = i / barCount;
      final isPlayed = barProgress <= progress;
      
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        isPlayed ? playedPaint : unplayedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.isPlaying != isPlaying ||
           oldDelegate.animationValue != animationValue;
  }
}
