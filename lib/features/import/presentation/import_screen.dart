import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../reader/presentation/reader_screen.dart';
import '../domain/entities/pdf_import_request.dart';
import 'import_providers.dart';
import '../../library/presentation/library_screen.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  static const routeName = 'import';
  static const routePath = '/import';

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _isImporting = false;

  Future<void> _choosePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }

    setState(() => _isImporting = true);
    try {
      final book = await ref
          .read(importPdfDocumentProvider)
          .call(PdfImportRequest(path: path));
      if (!mounted) {
        return;
      }
      context.go(ReaderScreen.routePath, extra: book);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not import PDF: $error')));
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import PDF'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(LibraryScreen.routePath),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF to ebook',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'The import adapter will extract text locally and convert pages into reflowable sections.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(_isImporting ? 'Importing...' : 'Choose PDF'),
              onPressed: _isImporting ? null : _choosePdf,
            ),
            if (_isImporting) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
