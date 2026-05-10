import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/section_playback_controller.dart';
import '../domain/entities/playback_cursor.dart';
import '../domain/entities/speech_asset.dart';
import '../domain/entities/voice_settings.dart';
import '../domain/repositories/playback_repository.dart';
import '../domain/repositories/speech_synthesis_repository.dart';

final speechSynthesisRepositoryProvider = Provider<SpeechSynthesisRepository>(
  (ref) => const _UnavailableSpeechSynthesisRepository(),
);

final playbackRepositoryProvider = Provider<PlaybackRepository>(
  (ref) => const _UnavailablePlaybackRepository(),
);

final sectionPlaybackControllerProvider =
    Provider.autoDispose<SectionPlaybackController>((ref) {
      final controller = SectionPlaybackController(
        speechSynthesisRepository: ref.watch(speechSynthesisRepositoryProvider),
        playbackRepository: ref.watch(playbackRepositoryProvider),
      );
      ref.onDispose(controller.dispose);
      return controller;
    });

final sectionPlaybackStateProvider =
    StreamProvider.autoDispose<SectionPlaybackState>((ref) async* {
      final controller = ref.watch(sectionPlaybackControllerProvider);
      yield controller.state;
      yield* controller.states;
    });

class _UnavailableSpeechSynthesisRepository
    implements SpeechSynthesisRepository {
  const _UnavailableSpeechSynthesisRepository();

  @override
  Future<SpeechAsset> prepareSectionSpeech(
    dynamic section,
    VoiceSettings settings,
  ) {
    throw UnimplementedError('Speech synthesis adapter is not wired.');
  }
}

class _UnavailablePlaybackRepository implements PlaybackRepository {
  const _UnavailablePlaybackRepository();

  @override
  Stream<PlaybackCursor> play(String speechAssetId, {from}) {
    throw UnimplementedError('Playback adapter is not wired.');
  }

  @override
  Future<void> pause() async {
    throw UnimplementedError('Playback adapter is not wired.');
  }

  @override
  Future<void> seek(Duration position) async {
    throw UnimplementedError('Playback adapter is not wired.');
  }
}
