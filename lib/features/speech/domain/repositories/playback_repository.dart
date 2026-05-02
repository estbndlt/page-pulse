import '../../../library/domain/entities/text_anchor.dart';
import '../entities/playback_cursor.dart';

abstract interface class PlaybackRepository {
  Stream<PlaybackCursor> play(String speechAssetId, {TextAnchor? from});
  Future<void> pause();
  Future<void> seek(Duration position);
}
