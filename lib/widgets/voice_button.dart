import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/voice_service.dart';

class VoiceButton extends StatefulWidget {
  final String prompt;
  final Function(String) onResult;
  final String tooltip;
  final bool autoSpeak;

  const VoiceButton({
    super.key,
    required this.prompt,
    required this.onResult,
    this.tooltip = 'Koresha ijwi',
    this.autoSpeak = true,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  VoiceService? _voiceService;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    _voiceService = VoiceService();
    if (!_voiceService!.isInitialized) {
      await _voiceService!.initialize();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleVoiceAction() async {
    if (_voiceService == null || !_voiceService!.isInitialized) {
      await _initializeVoiceService();
      if (_voiceService == null || !_voiceService!.isInitialized) {
        _showError('Ijwi ntirirashobora gukoresha. Gerageza ukundi.');
        return;
      }
    }

    if (_voiceService!.isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    // First, speak the prompt if auto-speak is enabled
    if (widget.autoSpeak && widget.prompt.isNotEmpty) {
      await _voiceService!.speak(widget.prompt);
      // Wait a moment for the prompt to finish
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    _pulseController.repeat(reverse: true);

    await _voiceService!.startListening(
      onResult: (result) {
        _stopListening();
        widget.onResult(result);
      },
      onError: (error) {
        _stopListening();
        _showError('Habaye ikosa: $error');
      },
    );
  }

  Future<void> _stopListening() async {
    await _voiceService!.stopListening();
    _pulseController.stop();
    _pulseController.reset();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceService>(
      builder: (context, voiceService, child) {
        final isListening = voiceService.isListening;

        return Tooltip(
          message: widget.tooltip,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        isListening
                            ? LinearGradient(
                              colors: [
                                AppTheme.errorColor,
                                AppTheme.errorColor.withValues(alpha: 0.8),
                              ],
                            )
                            : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (isListening
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _handleVoiceAction,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(
                      isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
