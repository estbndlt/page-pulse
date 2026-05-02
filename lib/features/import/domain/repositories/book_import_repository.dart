import '../../../library/domain/entities/book.dart';
import '../entities/pdf_import_request.dart';

abstract interface class BookImportRepository {
  Future<Book> importPdf(PdfImportRequest request);
}
