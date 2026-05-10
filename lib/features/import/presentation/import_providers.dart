import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_environment.dart';
import '../../library/domain/entities/book.dart';
import '../domain/entities/pdf_import_request.dart';
import '../domain/repositories/book_import_repository.dart';
import '../domain/usecases/import_pdf_document.dart';
import '../infrastructure/repositories/platform_pdf_text_book_import_repository.dart';

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.fromDartDefines,
);

final bookImportRepositoryProvider = Provider<BookImportRepository>(
  (ref) => const PlatformPdfTextBookImportRepository(),
);

final importPdfDocumentProvider = Provider<ImportPdfDocument>(
  (ref) => ImportPdfDocument(ref.watch(bookImportRepositoryProvider)),
);

final starterBookProvider = FutureProvider<Book?>((ref) async {
  final environment = ref.watch(appEnvironmentProvider);
  if (!environment.hasStarterPdf) {
    return null;
  }

  return ref
      .watch(importPdfDocumentProvider)
      .call(PdfImportRequest(path: environment.starterPdfPath));
});
