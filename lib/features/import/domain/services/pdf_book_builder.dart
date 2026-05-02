import 'package:uuid/uuid.dart';

import '../../../library/domain/entities/book.dart';
import 'text_tokenizer.dart';

class PdfPageText {
  const PdfPageText({required this.pageNumber, required this.text});

  final int pageNumber;
  final String text;
}

class PdfBookBuilder {
  const PdfBookBuilder({TextTokenizer tokenizer = const TextTokenizer()})
    : _tokenizer = tokenizer;

  final TextTokenizer _tokenizer;

  Book build({
    required String title,
    required String? sourceFileName,
    required List<PdfPageText> pages,
  }) {
    const uuid = Uuid();
    final bookId = uuid.v5(
      Namespace.url.value,
      '$sourceFileName:$title:${pages.length}',
    );
    final sections = <BookSection>[];

    for (final page in pages) {
      final sectionId = 'page-${page.pageNumber}';
      final paragraphs = _splitParagraphs(page.text)
          .asMap()
          .entries
          .map(
            (entry) => BookParagraph(
              index: entry.key,
              text: entry.value,
              tokens: _tokenizer.tokenizeParagraph(
                sectionId: sectionId,
                paragraphIndex: entry.key,
                text: entry.value,
              ),
            ),
          )
          .toList(growable: false);

      sections.add(
        BookSection(
          id: sectionId,
          title: 'Page ${page.pageNumber}',
          sourcePageNumber: page.pageNumber,
          paragraphs: paragraphs,
        ),
      );
    }

    return Book(
      id: bookId,
      title: title.trim().isEmpty ? 'Untitled PDF' : title.trim(),
      sourceFileName: sourceFileName,
      sections: sections,
    );
  }

  List<String> _splitParagraphs(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n\s*\n+'))
        .map((paragraph) => paragraph.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList(growable: false);
  }
}
