import 'book_token.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.sections,
    this.sourceFileName,
  });

  final String id;
  final String title;
  final String? sourceFileName;
  final List<BookSection> sections;
}

class BookSection {
  const BookSection({
    required this.id,
    required this.title,
    required this.paragraphs,
    required this.sourcePageNumber,
  });

  final String id;
  final String title;
  final int sourcePageNumber;
  final List<BookParagraph> paragraphs;
}

class BookParagraph {
  const BookParagraph({
    required this.index,
    required this.text,
    required this.tokens,
  });

  final int index;
  final String text;
  final List<BookToken> tokens;
}
