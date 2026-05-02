import '../../../library/domain/entities/book.dart';
import '../entities/pdf_import_request.dart';
import '../repositories/book_import_repository.dart';

class ImportPdfDocument {
  const ImportPdfDocument(this._repository);

  final BookImportRepository _repository;

  Future<Book> call(PdfImportRequest request) {
    return _repository.importPdf(request);
  }
}
