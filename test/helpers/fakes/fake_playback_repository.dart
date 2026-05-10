import 'dart:async';

import 'package:page_pulse/features/library/domain/entities/text_anchor.dart';
import 'package:page_pulse/features/speech/domain/entities/playback_cursor.dart';
import 'package:page_pulse/features/speech/domain/repositories/playback_repository.dart';

class PlaybackPlayRequest {
  const PlaybackPlayRequest({required this.speechAssetId, this.from});

  final String speechAssetId;
  final TextAnchor? from;
}

class FakePlaybackRepository implements PlaybackRepository {
  final _cursorController = StreamController<PlaybackCursor>.broadcast(
    sync: true,
  );

  final playRequests = <PlaybackPlayRequest>[];
  final seekRequests = <Duration>[];
  var pauseCallCount = 0;
  bool _isClosed = false;

  @override
  Stream<PlaybackCursor> play(String speechAssetId, {TextAnchor? from}) {
    playRequests.add(
      PlaybackPlayRequest(speechAssetId: speechAssetId, from: from),
    );
    return _cursorController.stream;
  }

  @override
  Future<void> pause() async {
    pauseCallCount += 1;
  }

  @override
  Future<void> seek(Duration position) async {
    seekRequests.add(position);
  }

  void emitCursor(PlaybackCursor cursor) {
    _cursorController.add(cursor);
  }

  void emitError(Object error) {
    _cursorController.addError(error);
  }

  Future<void> complete() async {
    await dispose();
  }

  Future<void> dispose() async {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    await _cursorController.close();
  }
}
