import '../../../library/domain/entities/book_token.dart';
import '../entities/speech_cue.dart';

class SpeechCueEstimator {
  const SpeechCueEstimator();

  List<SpeechCue> estimate({
    required List<BookToken> tokens,
    required Duration audioDuration,
  }) {
    final words = tokens
        .where((token) => token.kind == BookTokenKind.word)
        .toList(growable: false);
    if (words.isEmpty || audioDuration <= Duration.zero) return const [];

    final totalWeight = words.fold<double>(
      0,
      (sum, token) => sum + _weight(token.text),
    );
    var elapsedMicros = 0;
    final cues = <SpeechCue>[];

    for (var index = 0; index < words.length; index++) {
      final token = words[index];
      final isLast = index == words.length - 1;
      final start = Duration(microseconds: elapsedMicros);
      final endMicros = isLast
          ? audioDuration.inMicroseconds
          : elapsedMicros +
                (audioDuration.inMicroseconds *
                        (_weight(token.text) / totalWeight))
                    .round();
      final end = Duration(
        microseconds: endMicros.clamp(
          elapsedMicros,
          audioDuration.inMicroseconds,
        ),
      );
      cues.add(
        SpeechCue(
          anchor: token.anchor,
          text: token.text,
          start: start,
          end: end,
        ),
      );
      elapsedMicros = end.inMicroseconds;
    }

    return cues;
  }

  double _weight(String text) {
    final base = text.length.clamp(1, 18).toDouble();
    final syllableHint = RegExp(
      r'[aeiouyAEIOUY]+',
    ).allMatches(text).length.clamp(1, 6);
    return base + (syllableHint * 1.4);
  }
}
