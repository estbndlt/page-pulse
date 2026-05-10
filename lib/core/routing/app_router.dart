import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/import/presentation/import_providers.dart';
import '../../features/import/presentation/import_screen.dart';
import '../../features/library/domain/entities/book.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/reader/presentation/reader_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final environment = ref.watch(appEnvironmentProvider);

  return GoRouter(
    initialLocation: environment.hasStarterPdf
        ? ReaderScreen.routePath
        : LibraryScreen.routePath,
    routes: [
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: LibraryScreen.routePath,
        name: LibraryScreen.routeName,
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: ImportScreen.routePath,
        name: ImportScreen.routeName,
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: ReaderScreen.routePath,
        name: ReaderScreen.routeName,
        builder: (context, state) {
          final book = state.extra is Book ? state.extra! as Book : null;
          return ReaderScreen(book: book);
        },
      ),
    ],
  );
});
