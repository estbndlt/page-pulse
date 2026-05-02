import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
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
                tooltip: 'Back',
                icon: const Icon(Icons.replay_10),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Play',
                icon: const Icon(Icons.play_arrow),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Forward',
                icon: const Icon(Icons.forward_10),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              const Expanded(child: LinearProgressIndicator(value: 0.24)),
            ],
          ),
        ),
      ),
    );
  }
}
