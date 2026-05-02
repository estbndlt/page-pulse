import 'text_anchor.dart';

enum BookTokenKind { word, punctuation, whitespace }

class BookToken {
  const BookToken({
    required this.text,
    required this.kind,
    required this.anchor,
    required this.startOffset,
    required this.endOffset,
  });

  final String text;
  final BookTokenKind kind;
  final TextAnchor anchor;
  final int startOffset;
  final int endOffset;

  bool get isSpeakable => kind == BookTokenKind.word;
}
