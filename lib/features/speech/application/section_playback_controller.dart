import 'dart:async';

import '../../library/domain/entities/book.dart';
import '../../library/domain/entities/text_anchor.dart';
import '../domain/entities/playback_cursor.dart';
import '../domain/entities/speech_asset.dart';
import '../domain/entities/voice_settings.dart';
import '../domain/repositories/playback_repository.dart';
import '../domain/repositories/speech_synthesis_repository.dart';

enum SectionPlaybackStatus {
  idle,
  preparing,
  playing,
  paused,
  completed,
  error,
}

class SectionPlaybackState {
  const SectionPlaybackState._({
    required this.status,
    this.section,
    this.speechAsset,
    this.cursor,
    this.error,
  });

  const SectionPlaybackState.idle()
    : this._(status: SectionPlaybackStatus.idle);

  const SectionPlaybackState.preparing({required BookSection section})
    : this._(status: SectionPlaybackStatus.preparing, section: section);

  const SectionPlaybackState.playing({
    required BookSection section,
    required SpeechAsset speechAsset,
    PlaybackCursor? cursor,
  }) : this._(
         status: SectionPlaybackStatus.playing,
         section: section,
         speechAsset: speechAsset,
         cursor: cursor,
       );

  const SectionPlaybackState.paused({
    required BookSection section,
    required SpeechAsset speechAsset,
    PlaybackCursor? cursor,
  }) : this._(
         status: SectionPlaybackStatus.paused,
         section: section,
         speechAsset: speechAsset,
         cursor: cursor,
       );

  const SectionPlaybackState.completed({
    required BookSection section,
    required SpeechAsset speechAsset,
    PlaybackCursor? cursor,
  }) : this._(
         status: SectionPlaybackStatus.completed,
         section: section,
         speechAsset: speechAsset,
         cursor: cursor,
       );

  const SectionPlaybackState.error({
    required BookSection section,
    required Object error,
    SpeechAsset? speechAsset,
    PlaybackCursor? cursor,
  }) : this._(
         status: SectionPlaybackStatus.error,
         section: section,
         speechAsset: speechAsset,
         cursor: cursor,
         error: error,
       );

  final SectionPlaybackStatus status;
  final BookSection? section;
  final SpeechAsset? speechAsset;
  final PlaybackCursor? cursor;
  final Object? error;

  bool get isBusy => status == SectionPlaybackStatus.preparing;
  bool get isPlaying => status == SectionPlaybackStatus.playing;
}

class SectionPlaybackController {
  SectionPlaybackController({
    required SpeechSynthesisRepository speechSynthesisRepository,
    required PlaybackRepository playbackRepository,
    VoiceSettings voiceSettings = const VoiceSettings(),
  }) : _speechSynthesisRepository = speechSynthesisRepository,
       _playbackRepository = playbackRepository,
       _voiceSettings = voiceSettings;

  final SpeechSynthesisRepository _speechSynthesisRepository;
  final PlaybackRepository _playbackRepository;
  final VoiceSettings _voiceSettings;
  final _states = StreamController<SectionPlaybackState>.broadcast(sync: true);

  StreamSubscription<PlaybackCursor>? _cursorSubscription;
  SectionPlaybackState _state = const SectionPlaybackState.idle();
  bool _isDisposed = false;

  SectionPlaybackState get state => _state;
  Stream<SectionPlaybackState> get states => _states.stream;

  Future<void> playSection(BookSection section, {TextAnchor? from}) async {
    await _cursorSubscription?.cancel();
    _emit(SectionPlaybackState.preparing(section: section));

    try {
      final speechAsset = await _speechSynthesisRepository.prepareSectionSpeech(
        section,
        _voiceSettings,
      );
      _emit(
        SectionPlaybackState.playing(
          section: section,
          speechAsset: speechAsset,
        ),
      );

      _cursorSubscription = _playbackRepository
          .play(speechAsset.id, from: from)
          .listen(
            (cursor) => _emit(
              SectionPlaybackState.playing(
                section: section,
                speechAsset: speechAsset,
                cursor: cursor,
              ),
            ),
            onError: (Object error) => _emit(
              SectionPlaybackState.error(
                section: section,
                speechAsset: speechAsset,
                cursor: _state.cursor,
                error: error,
              ),
            ),
            onDone: () => _emit(
              SectionPlaybackState.completed(
                section: section,
                speechAsset: speechAsset,
                cursor: _state.cursor,
              ),
            ),
          );
    } catch (error) {
      _emit(SectionPlaybackState.error(section: section, error: error));
    }
  }

  Future<void> pause() async {
    final section = _state.section;
    final speechAsset = _state.speechAsset;
    if (section == null || speechAsset == null) {
      return;
    }

    await _playbackRepository.pause();
    _emit(
      SectionPlaybackState.paused(
        section: section,
        speechAsset: speechAsset,
        cursor: _state.cursor,
      ),
    );
  }

  Future<void> seekRelative(Duration offset) async {
    final currentPosition = _state.cursor?.position ?? Duration.zero;
    final nextPosition = currentPosition + offset;
    await _playbackRepository.seek(
      nextPosition < Duration.zero ? Duration.zero : nextPosition,
    );
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _cursorSubscription?.cancel();
    _states.close();
  }

  void _emit(SectionPlaybackState state) {
    if (_isDisposed) {
      return;
    }

    _state = state;
    _states.add(state);
  }
}
