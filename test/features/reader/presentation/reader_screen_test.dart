import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_pulse/features/reader/presentation/reader_screen.dart';
import 'package:page_pulse/features/speech/domain/entities/speech_asset.dart';
import 'package:page_pulse/features/speech/presentation/playback_controls.dart';
import 'package:page_pulse/features/speech/presentation/playback_providers.dart';

import '../../../helpers/book_test_factory.dart';
import '../../../helpers/fakes/fake_playback_repository.dart';
import '../../../helpers/fakes/fake_speech_synthesis_repository.dart';

void main() {
  group('ReaderScreen', () {
    testWidgets(
      'enables the play button when the reader has a playable section',
      (tester) async {
        final book = BookTestFactory.book();

        await tester.pumpWidget(
          _buildTestApp(
            book: book,
            speechRepository: FakeSpeechSynthesisRepository(),
            playbackRepository: FakePlaybackRepository(),
          ),
        );

        final playButton = tester.widget<IconButton>(
          find.byKey(PlaybackControls.playPauseButtonKey),
        );

        expect(playButton.onPressed, isNotNull);
      },
    );

    testWidgets(
      'tapping play requests section speech and playback for the first section',
      (tester) async {
        final book = BookTestFactory.book();
        final speechAsset = BookTestFactory.speechAsset(
          sectionId: book.sections.first.id,
        );
        final speechRepository = FakeSpeechSynthesisRepository(
          speechAsset: speechAsset,
        );
        final playbackRepository = FakePlaybackRepository();
        addTearDown(playbackRepository.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            book: book,
            speechRepository: speechRepository,
            playbackRepository: playbackRepository,
          ),
        );

        await tester.tap(find.byKey(PlaybackControls.playPauseButtonKey));
        await tester.pump();

        expect(speechRepository.requests, hasLength(1));
        expect(speechRepository.requests.single.section, book.sections.first);
        expect(playbackRepository.playRequests, hasLength(1));
        expect(
          playbackRepository.playRequests.single.speechAssetId,
          speechAsset.id,
        );
      },
    );

    testWidgets('disables the play button while section speech is preparing', (
      tester,
    ) async {
      final book = BookTestFactory.book();
      final pendingSpeechAsset = Completer<SpeechAsset>();
      final speechRepository = FakeSpeechSynthesisRepository(
        pendingSpeechAsset: pendingSpeechAsset,
      );

      await tester.pumpWidget(
        _buildTestApp(
          book: book,
          speechRepository: speechRepository,
          playbackRepository: FakePlaybackRepository(),
        ),
      );

      final initialPlayButton = tester.widget<IconButton>(
        find.byKey(PlaybackControls.playPauseButtonKey),
      );
      expect(initialPlayButton.onPressed, isNotNull);

      await tester.tap(find.byKey(PlaybackControls.playPauseButtonKey));
      await tester.pump();

      final playButton = tester.widget<IconButton>(
        find.byKey(PlaybackControls.playPauseButtonKey),
      );

      expect(playButton.onPressed, isNull);
    });

    testWidgets('switches the play control to pause once playback starts', (
      tester,
    ) async {
      final book = BookTestFactory.book();

      await tester.pumpWidget(
        _buildTestApp(
          book: book,
          speechRepository: FakeSpeechSynthesisRepository(),
          playbackRepository: FakePlaybackRepository(),
        ),
      );

      await tester.tap(find.byKey(PlaybackControls.playPauseButtonKey));
      await tester.pump();

      expect(find.byTooltip('Pause'), findsOneWidget);
    });
  });
}

Widget _buildTestApp({
  required dynamic book,
  required FakeSpeechSynthesisRepository speechRepository,
  required FakePlaybackRepository playbackRepository,
}) {
  return ProviderScope(
    overrides: [
      speechSynthesisRepositoryProvider.overrideWithValue(speechRepository),
      playbackRepositoryProvider.overrideWithValue(playbackRepository),
    ],
    child: MaterialApp(home: ReaderScreen(book: book)),
  );
}
