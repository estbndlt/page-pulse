import '../../../library/domain/entities/text_anchor.dart';

class PlaybackCursor {
  const PlaybackCursor({required this.position, this.anchor});

  final Duration position;
  final TextAnchor? anchor;
}
