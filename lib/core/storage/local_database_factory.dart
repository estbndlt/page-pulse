import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalDatabaseFactory {
  const LocalDatabaseFactory();

  QueryExecutor createExecutor({String fileName = 'page_pulse.sqlite'}) {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, fileName));
      return NativeDatabase.createInBackground(file);
    });
  }
}
