import '../../../library/domain/entities/text_anchor.dart';

abstract interface class ReadingProgressRepository {
  Future<void> saveProgress({
    required String bookId,
    required TextAnchor anchor,
    required Duration audioPosition,
  });

  Future<TextAnchor?> getLastAnchor(String bookId);
}
