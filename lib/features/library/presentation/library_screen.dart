import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../import/presentation/import_providers.dart';
import '../../import/presentation/import_screen.dart';
import '../../reader/presentation/reader_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  static const routeName = 'library';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(appEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Pulse'),
        actions: [
          IconButton(
            tooltip: 'Import PDF',
            icon: const Icon(Icons.upload_file),
            onPressed: () => context.go(ImportScreen.routePath),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Library', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          if (environment.hasStarterPdf) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Starter PDF'),
                subtitle: const Text(
                  'Open the configured local PDF as an ebook.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(ReaderScreen.routePath),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Sample reader shell'),
              subtitle: const Text(
                'Import and local speech foundations are ready for adapters.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(ReaderScreen.routePath),
            ),
          ),
        ],
      ),
    );
  }
}
