import 'package:flutter_test/flutter_test.dart';
import 'package:page_pulse/features/speech/application/section_playback_controller.dart';
import 'package:page_pulse/features/speech/presentation/playback_providers.dart';

import '../../../helpers/book_test_factory.dart';
import '../../../helpers/fakes/fake_playback_repository.dart';
import '../../../helpers/fakes/fake_speech_synthesis_repository.dart';
import '../../../helpers/provider_container.dart';

void main() {
  group('playback providers', () {
    test(
      'build the playback controller from overrideable repositories',
      () async {
        final speechRepository = FakeSpeechSynthesisRepository();
        final playbackRepository = FakePlaybackRepository();
        addTearDown(playbackRepository.dispose);
        final container = createProviderContainer(
          overrides: [
            speechSynthesisRepositoryProvider.overrideWithValue(
              speechRepository,
            ),
            playbackRepositoryProvider.overrideWithValue(playbackRepository),
          ],
        );
        final controller = container.read(sectionPlaybackControllerProvider);

        await controller.playSection(BookTestFactory.section());

        expect(controller.state.status, SectionPlaybackStatus.playing);
        expect(speechRepository.requests, hasLength(1));
        expect(playbackRepository.playRequests, hasLength(1));
      },
    );
  });
}
