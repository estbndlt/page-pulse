import 'package:flutter_test/flutter_test.dart';
import 'package:page_pulse/features/import/domain/services/text_tokenizer.dart';
import 'package:page_pulse/features/library/domain/entities/book_token.dart';

void main() {
  group('TextTokenizer', () {
    test('keeps stable word anchors while preserving punctuation tokens', () {
      const tokenizer = TextTokenizer();

      final tokens = tokenizer.tokenizeParagraph(
        sectionId: 'page-1',
        paragraphIndex: 0,
        text: "Hello, reader's world.",
      );

      final words = tokens
          .where((token) => token.kind == BookTokenKind.word)
          .toList();

      expect(words.map((token) => token.text), ['Hello', "reader's", 'world']);
      expect(words.map((token) => token.anchor.tokenIndex), [0, 1, 2]);
      expect(
        tokens.any(
          (token) =>
              token.text == ',' && token.kind == BookTokenKind.punctuation,
        ),
        isTrue,
      );
    });

    test('returns no speakable tokens for whitespace only text', () {
      const tokenizer = TextTokenizer();

      final tokens = tokenizer.tokenizeParagraph(
        sectionId: 'page-1',
        paragraphIndex: 0,
        text: '   \n  ',
      );

      expect(tokens.where((token) => token.isSpeakable), isEmpty);
    });
  });
}
