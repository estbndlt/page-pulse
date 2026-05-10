import 'package:flutter/services.dart';

import '../../domain/entities/pdf_import_request.dart';
import '../../domain/services/pdf_book_builder.dart';

class ExtractedPdfDocument {
  const ExtractedPdfDocument({required this.pages, this.title});

  final String? title;
  final List<PdfPageText> pages;
}

class PlatformPdfTextExtractor {
  const PlatformPdfTextExtractor();

  static const MethodChannel _channel = MethodChannel('page_pulse/pdf_text');

  Future<ExtractedPdfDocument> extract(PdfImportRequest request) async {
    final response = await _channel
        .invokeMapMethod<String, Object?>('extractText', <String, Object?>{
          'path': request.path,
          if (request.password != null) 'password': request.password,
        });
    if (response == null) {
      throw StateError('PDF text extraction returned no result.');
    }

    final pagesData = response['pages'];
    if (pagesData is! List<Object?>) {
      throw StateError('PDF text extraction returned invalid page data.');
    }

    final pages = pagesData
        .map((data) {
          if (data is! Map<Object?, Object?>) {
            throw StateError('PDF text extraction returned an invalid page.');
          }

          final pageNumber = data['pageNumber'];
          if (pageNumber is! int) {
            throw StateError(
              'PDF text extraction returned a page without a number.',
            );
          }

          return PdfPageText(
            pageNumber: pageNumber,
            text: data['text'] as String? ?? '',
          );
        })
        .toList(growable: false);

    return ExtractedPdfDocument(
      title: response['title'] as String?,
      pages: pages,
    );
  }
}
