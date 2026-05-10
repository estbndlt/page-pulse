import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    this.isPlaying = false,
    this.isBusy = false,
    this.progress = 0,
    this.onPlayPause,
    this.onSeekBack,
    this.onSeekForward,
  });

  static const seekBackButtonKey = Key('playback.seekBack');
  static const playPauseButtonKey = Key('playback.playPause');
  static const seekForwardButtonKey = Key('playback.seekForward');

  final bool isPlaying;
  final bool isBusy;
  final double progress;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeekBack;
  final VoidCallback? onSeekForward;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0, 1).toDouble();

    return SafeArea(
      top: false,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton.filledTonal(
                key: seekBackButtonKey,
                tooltip: 'Back',
                icon: const Icon(Icons.replay_10),
                onPressed: isBusy ? null : onSeekBack,
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: playPauseButtonKey,
                tooltip: isPlaying ? 'Pause' : 'Play',
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: isBusy ? null : onPlayPause,
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: seekForwardButtonKey,
                tooltip: 'Forward',
                icon: const Icon(Icons.forward_10),
                onPressed: isBusy ? null : onSeekForward,
              ),
              const SizedBox(width: 12),
              Expanded(child: LinearProgressIndicator(value: clampedProgress)),
            ],
          ),
        ),
      ),
    );
  }
}
