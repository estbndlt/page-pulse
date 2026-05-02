import 'package:flutter_test/flutter_test.dart';
import 'package:page_pulse/features/import/domain/services/text_tokenizer.dart';
import 'package:page_pulse/features/speech/domain/services/speech_cue_estimator.dart';

void main() {
  group('SpeechCueEstimator', () {
    test(
      'creates ordered non-overlapping cues that fill the audio duration',
      () {
        const tokenizer = TextTokenizer();
        const estimator = SpeechCueEstimator();
        final tokens = tokenizer.tokenizeParagraph(
          sectionId: 'page-1',
          paragraphIndex: 0,
          text: 'Short longer longest.',
        );

        final cues = estimator.estimate(
          tokens: tokens,
          audioDuration: const Duration(seconds: 3),
        );

        expect(cues, hasLength(3));
        expect(cues.first.start, Duration.zero);
        expect(cues.last.end, const Duration(seconds: 3));
        for (var i = 1; i < cues.length; i++) {
          expect(cues[i].start, cues[i - 1].end);
          expect(cues[i].end >= cues[i].start, isTrue);
        }
      },
    );

    test('returns no cues when there are no words', () {
      const tokenizer = TextTokenizer();
      const estimator = SpeechCueEstimator();
      final tokens = tokenizer.tokenizeParagraph(
        sectionId: 'page-1',
        paragraphIndex: 0,
        text: '... !!!',
      );

      final cues = estimator.estimate(
        tokens: tokens,
        audioDuration: const Duration(seconds: 1),
      );

      expect(cues, isEmpty);
    });
  });
}
