import '../entities/playback_cursor.dart';
import '../entities/speech_cue.dart';

class PlaybackCursorMapper {
  const PlaybackCursorMapper();

  PlaybackCursor map({
    required List<SpeechCue> cues,
    required Duration position,
  }) {
    if (cues.isEmpty) return PlaybackCursor(position: position);

    for (final cue in cues) {
      if (cue.contains(position)) {
        return PlaybackCursor(position: position, anchor: cue.anchor);
      }
    }

    if (position >= cues.last.end) {
      return PlaybackCursor(position: position, anchor: cues.last.anchor);
    }

    return PlaybackCursor(position: position, anchor: cues.first.anchor);
  }
}
