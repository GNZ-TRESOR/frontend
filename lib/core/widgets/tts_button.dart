import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tts_provider.dart';
import '../theme/app_colors.dart';

/// Floating TTS Button Widget
/// Can be easily added to any screen without affecting layout
class TTSFloatingButton extends ConsumerWidget {
  final String textToSpeak;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const TTSFloatingButton({
    super.key,
    required this.textToSpeak,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    return FloatingActionButton(
      mini: true,
      backgroundColor: backgroundColor ?? AppColors.primary,
      onPressed: () async {
        if (onPressed != null) {
          onPressed!();
        }
        
        if (ttsState.isSpeaking) {
          await ttsNotifier.stop();
        } else {
          await ttsNotifier.speak(textToSpeak);
        }
      },
      tooltip: tooltip ?? (ttsState.isSpeaking ? 'Stop reading' : 'Read aloud'),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ttsState.isSpeaking
            ? Icon(
                Icons.stop,
                color: iconColor ?? Colors.white,
                size: size ?? 20,
                key: const ValueKey('stop'),
              )
            : Icon(
                Icons.volume_up,
                color: iconColor ?? Colors.white,
                size: size ?? 20,
                key: const ValueKey('speak'),
              ),
      ),
    );
  }
}

/// Inline TTS Button (for use within text or content)
class TTSInlineButton extends ConsumerWidget {
  final String textToSpeak;
  final double? size;
  final Color? color;
  final EdgeInsets? padding;

  const TTSInlineButton({
    super.key,
    required this.textToSpeak,
    this.size,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    return InkWell(
      onTap: () async {
        if (ttsState.isSpeaking) {
          await ttsNotifier.stop();
        } else {
          await ttsNotifier.speak(textToSpeak);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ttsState.isSpeaking
              ? Icon(
                  Icons.stop_circle,
                  color: color ?? AppColors.primary,
                  size: size ?? 18,
                  key: const ValueKey('stop'),
                )
              : Icon(
                  Icons.volume_up_rounded,
                  color: color ?? AppColors.primary,
                  size: size ?? 18,
                  key: const ValueKey('speak'),
                ),
        ),
      ),
    );
  }
}

/// TTS-enabled Text Widget
/// Automatically adds a TTS button next to text content
class TTSText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool showTTSButton;
  final double? ttsButtonSize;
  final Color? ttsButtonColor;

  const TTSText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.showTTSButton = true,
    this.ttsButtonSize,
    this.ttsButtonColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showTTSButton) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
        ),
        const SizedBox(width: 8),
        TTSInlineButton(
          textToSpeak: text,
          size: ttsButtonSize,
          color: ttsButtonColor,
        ),
      ],
    );
  }
}

/// TTS Control Panel (for settings screens)
class TTSControlPanel extends ConsumerWidget {
  const TTSControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    if (!ttsState.isInitialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Initializing Text-to-Speech...'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Text-to-Speech Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (ttsState.isSpeaking)
                  ElevatedButton.icon(
                    onPressed: () => ttsNotifier.stop(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Language info
            Row(
              children: [
                const Text('Language: '),
                Text(
                  ttsState.currentLanguage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Speech rate slider
            Row(
              children: [
                const Text('Speed: '),
                Expanded(
                  child: Slider(
                    value: ttsState.speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(ttsState.speechRate * 100).round()}%',
                    onChanged: (value) => ttsNotifier.setSpeechRate(value),
                  ),
                ),
              ],
            ),
            
            // Volume slider
            Row(
              children: [
                const Text('Volume: '),
                Expanded(
                  child: Slider(
                    value: ttsState.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(ttsState.volume * 100).round()}%',
                    onChanged: (value) => ttsNotifier.setVolume(value),
                  ),
                ),
              ],
            ),
            
            // Test button
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => ttsNotifier.speak(
                  'Welcome to Ubuzima. This is a test of the text-to-speech functionality.',
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test Voice'),
              ),
            ),
            
            // Error display
            if (ttsState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: ${ttsState.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
