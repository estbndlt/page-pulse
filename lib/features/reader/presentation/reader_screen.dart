import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../import/presentation/import_providers.dart';
import '../../library/domain/entities/book.dart';
import '../../library/presentation/library_screen.dart';
import '../../speech/application/section_playback_controller.dart';
import '../../speech/presentation/playback_controls.dart';
import '../../speech/presentation/playback_providers.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, this.book});

  static const routeName = 'reader';
  static const routePath = '/reader';

  final Book? book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final starterBook = book == null ? ref.watch(starterBookProvider) : null;

    if (book != null) {
      return _ReaderScaffold(book: book!);
    }

    return starterBook!.when(
      data: (book) => book == null
          ? const _PlaceholderReaderScaffold()
          : _ReaderScaffold(book: book),
      error: (error, stackTrace) => _ReaderErrorScaffold(error: error),
      loading: () => const _ReaderLoadingScaffold(),
    );
  }
}

class _ReaderScaffold extends ConsumerWidget {
  const _ReaderScaffold({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState =
        ref.watch(sectionPlaybackStateProvider).value ??
        const SectionPlaybackState.idle();
    final firstSection = book.sections.isEmpty ? null : book.sections.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        leading: IconButton(
          tooltip: 'Library',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(LibraryScreen.routePath),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        itemCount: book.sections.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _BookHeader(book: book);
          }

          final section = book.sections[index - 1];
          return _BookSectionView(section: section);
        },
      ),
      bottomNavigationBar: PlaybackControls(
        isPlaying: playbackState.isPlaying,
        isBusy: playbackState.isBusy,
        progress: 0,
        onPlayPause: firstSection == null
            ? null
            : () {
                final controller = ref.read(sectionPlaybackControllerProvider);
                if (playbackState.isPlaying) {
                  controller.pause();
                  return;
                }

                controller.playSection(firstSection);
              },
      ),
    );
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.title, style: textTheme.headlineSmall),
          if (book.sourceFileName != null) ...[
            const SizedBox(height: 8),
            Text(
              book.sourceFileName!,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '${book.sections.length} pages imported as reflowable text',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BookSectionView extends StatelessWidget {
  const _BookSectionView({required this.section});

  final BookSection section;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (section.paragraphs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final paragraph in section.paragraphs) ...[
            Text(
              paragraph.text,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.65,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _PlaceholderReaderScaffold extends StatelessWidget {
  const _PlaceholderReaderScaffold();

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

class _ReaderLoadingScaffold extends StatelessWidget {
  const _ReaderLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importing PDF'),
        leading: IconButton(
          tooltip: 'Library',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(LibraryScreen.routePath),
        ),
      ),
      body: const Center(
        child: SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Extracting PDF text...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderErrorScaffold extends StatelessWidget {
  const _ReaderErrorScaffold({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import failed'),
        leading: IconButton(
          tooltip: 'Library',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(LibraryScreen.routePath),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Could not render the PDF as an ebook: $error'),
      ),
    );
  }
}
