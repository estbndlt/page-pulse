import 'package:flutter_test/flutter_test.dart';
import 'package:page_pulse/features/import/domain/services/text_tokenizer.dart';
import 'package:page_pulse/features/speech/domain/services/playback_cursor_mapper.dart';
import 'package:page_pulse/features/speech/domain/services/speech_cue_estimator.dart';

void main() {
  group('PlaybackCursorMapper', () {
    test('maps a playback position to the active cue anchor', () {
      const tokenizer = TextTokenizer();
      const estimator = SpeechCueEstimator();
      const mapper = PlaybackCursorMapper();
      final tokens = tokenizer.tokenizeParagraph(
        sectionId: 'page-1',
        paragraphIndex: 0,
        text: 'alpha beta gamma',
      );
      final cues = estimator.estimate(
        tokens: tokens,
        audioDuration: const Duration(seconds: 3),
      );

      final cursor = mapper.map(
        cues: cues,
        position: const Duration(milliseconds: 1500),
      );

      expect(cursor.anchor?.sectionId, 'page-1');
      expect(cursor.anchor?.tokenIndex, 1);
    });

    test('holds the final anchor after audio ends', () {
      const tokenizer = TextTokenizer();
      const estimator = SpeechCueEstimator();
      const mapper = PlaybackCursorMapper();
      final tokens = tokenizer.tokenizeParagraph(
        sectionId: 'page-1',
        paragraphIndex: 0,
        text: 'alpha beta',
      );
      final cues = estimator.estimate(
        tokens: tokens,
        audioDuration: const Duration(seconds: 2),
      );

      final cursor = mapper.map(
        cues: cues,
        position: const Duration(seconds: 3),
      );

      expect(cursor.anchor?.tokenIndex, 1);
    });
  });
}
