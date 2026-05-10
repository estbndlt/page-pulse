import 'package:path/path.dart' as p;

import '../../../library/domain/entities/book.dart';
import '../../domain/entities/pdf_import_request.dart';
import '../../domain/repositories/book_import_repository.dart';
import '../../domain/services/pdf_book_builder.dart';
import '../services/platform_pdf_text_extractor.dart';

class PlatformPdfTextBookImportRepository implements BookImportRepository {
  const PlatformPdfTextBookImportRepository({
    PdfBookBuilder builder = const PdfBookBuilder(),
    PlatformPdfTextExtractor extractor = const PlatformPdfTextExtractor(),
  }) : _builder = builder,
       _extractor = extractor;

  final PdfBookBuilder _builder;
  final PlatformPdfTextExtractor _extractor;

  @override
  Future<Book> importPdf(PdfImportRequest request) async {
    final document = await _extractor.extract(request);
    final sourceFileName = p.basename(request.path);
    final documentTitle = document.title?.trim();
    final fallbackTitle = p
        .basenameWithoutExtension(sourceFileName)
        .replaceAll(RegExp(r'[_-]+'), ' ');

    return _builder.build(
      title: documentTitle != null && documentTitle.isNotEmpty
          ? documentTitle
          : fallbackTitle,
      sourceFileName: sourceFileName,
      pages: document.pages,
    );
  }
}
