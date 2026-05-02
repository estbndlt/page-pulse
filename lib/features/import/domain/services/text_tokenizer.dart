import '../../../library/domain/entities/book_token.dart';
import '../../../library/domain/entities/text_anchor.dart';

class TextTokenizer {
  const TextTokenizer();

  static final RegExp _tokenPattern = RegExp(
    r"[\p{L}\p{N}]+(?:['’-][\p{L}\p{N}]+)*|\s+|[^\s\p{L}\p{N}]",
    unicode: true,
  );

  List<BookToken> tokenizeParagraph({
    required String sectionId,
    required int paragraphIndex,
    required String text,
  }) {
    final tokens = <BookToken>[];
    var speakableIndex = 0;

    for (final match in _tokenPattern.allMatches(text)) {
      final value = match.group(0)!;
      final kind = _classify(value);
      final tokenIndex = kind == BookTokenKind.word ? speakableIndex++ : -1;
      tokens.add(
        BookToken(
          text: value,
          kind: kind,
          anchor: TextAnchor(
            sectionId: sectionId,
            paragraphIndex: paragraphIndex,
            tokenIndex: tokenIndex,
          ),
          startOffset: match.start,
          endOffset: match.end,
        ),
      );
    }

    return tokens;
  }

  BookTokenKind _classify(String token) {
    if (token.trim().isEmpty) return BookTokenKind.whitespace;
    final startsWithLetterOrNumber = RegExp(
      r'[\p{L}\p{N}]',
      unicode: true,
    ).hasMatch(token[0]);
    return startsWithLetterOrNumber
        ? BookTokenKind.word
        : BookTokenKind.punctuation;
  }
}
