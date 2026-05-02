import '../../../library/domain/entities/text_anchor.dart';

class SpeechCue {
  const SpeechCue({
    required this.anchor,
    required this.text,
    required this.start,
    required this.end,
  });

  final TextAnchor anchor;
  final String text;
  final Duration start;
  final Duration end;

  bool contains(Duration position) => position >= start && position < end;
}
