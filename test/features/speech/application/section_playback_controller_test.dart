import 'package:flutter_test/flutter_test.dart';
import 'package:page_pulse/features/speech/application/section_playback_controller.dart';
import 'package:page_pulse/features/speech/domain/entities/playback_cursor.dart';
import 'package:page_pulse/features/speech/domain/entities/voice_settings.dart';

import '../../../helpers/book_test_factory.dart';
import '../../../helpers/fakes/fake_playback_repository.dart';
import '../../../helpers/fakes/fake_speech_synthesis_repository.dart';

void main() {
  group('SectionPlaybackController', () {
    test(
      'prepares section speech and starts playback with the asset id',
      () async {
        final section = BookTestFactory.section();
        final speechAsset = BookTestFactory.speechAsset(sectionId: section.id);
        final speechRepository = FakeSpeechSynthesisRepository(
          speechAsset: speechAsset,
        );
        final playbackRepository = FakePlaybackRepository();
        addTearDown(playbackRepository.dispose);
        final controller = SectionPlaybackController(
          speechSynthesisRepository: speechRepository,
          playbackRepository: playbackRepository,
        );
        addTearDown(controller.dispose);

        await controller.playSection(section, from: BookTestFactory.anchor);

        expect(speechRepository.requests, hasLength(1));
        expect(speechRepository.requests.single.section, section);
        expect(
          speechRepository.requests.single.voiceSettings,
          isA<VoiceSettings>(),
        );
        expect(playbackRepository.playRequests, hasLength(1));
        expect(
          playbackRepository.playRequests.single.speechAssetId,
          speechAsset.id,
        );
        expect(
          playbackRepository.playRequests.single.from,
          BookTestFactory.anchor,
        );
        expect(controller.state.status, SectionPlaybackStatus.playing);
        expect(controller.state.speechAsset, speechAsset);
      },
    );

    test('emits cursor updates from the playback repository', () async {
      final section = BookTestFactory.section();
      final playbackRepository = FakePlaybackRepository();
      addTearDown(playbackRepository.dispose);
      final controller = SectionPlaybackController(
        speechSynthesisRepository: FakeSpeechSynthesisRepository(),
        playbackRepository: playbackRepository,
      );
      addTearDown(controller.dispose);

      await controller.playSection(section);
      const cursor = PlaybackCursor(
        position: Duration(milliseconds: 750),
        anchor: BookTestFactory.anchor,
      );

      playbackRepository.emitCursor(cursor);

      expect(controller.state.status, SectionPlaybackStatus.playing);
      expect(controller.state.cursor, cursor);
    });

    test('pauses playback and seeks relative to the current cursor', () async {
      final section = BookTestFactory.section();
      final playbackRepository = FakePlaybackRepository();
      addTearDown(playbackRepository.dispose);
      final controller = SectionPlaybackController(
        speechSynthesisRepository: FakeSpeechSynthesisRepository(),
        playbackRepository: playbackRepository,
      );
      addTearDown(controller.dispose);

      await controller.playSection(section);
      playbackRepository.emitCursor(
        const PlaybackCursor(position: Duration(seconds: 12)),
      );

      await controller.seekRelative(const Duration(seconds: -10));
      await controller.seekRelative(const Duration(seconds: -20));
      await controller.pause();

      expect(playbackRepository.seekRequests, [
        const Duration(seconds: 2),
        Duration.zero,
      ]);
      expect(playbackRepository.pauseCallCount, 1);
      expect(controller.state.status, SectionPlaybackStatus.paused);
    });

    test('publishes an error state when speech preparation fails', () async {
      final section = BookTestFactory.section();
      final error = StateError('missing voice model');
      final playbackRepository = FakePlaybackRepository();
      addTearDown(playbackRepository.dispose);
      final controller = SectionPlaybackController(
        speechSynthesisRepository: FakeSpeechSynthesisRepository(error: error),
        playbackRepository: playbackRepository,
      );
      addTearDown(controller.dispose);

      await controller.playSection(section);

      expect(controller.state.status, SectionPlaybackStatus.error);
      expect(controller.state.error, error);
      expect(playbackRepository.playRequests, isEmpty);
    });
  });
}
