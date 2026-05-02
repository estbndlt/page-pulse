import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../library/presentation/library_screen.dart';
import '../../speech/presentation/playback_controls.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  static const routeName = 'reader';
  static const routePath = '/reader';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
        leading: IconButton(
          tooltip: 'Library',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(LibraryScreen.routePath),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text('Page 1', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: textTheme.bodyLarge?.copyWith(
                height: 1.65,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                const TextSpan(
                  text:
                      'Page Pulse turns a local PDF into a reflowable reading model. ',
                ),
                TextSpan(
                  text:
                      'The active word highlight will follow generated speech cues.',
                  style: TextStyle(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PlaybackControls(),
    );
  }
}
