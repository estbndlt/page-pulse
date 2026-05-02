import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../library/presentation/library_screen.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  static const routeName = 'import';
  static const routePath = '/import';

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
              label: const Text('Choose PDF'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
