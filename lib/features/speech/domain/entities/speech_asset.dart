import 'speech_cue.dart';
import 'voice_settings.dart';

class SpeechAsset {
  const SpeechAsset({
    required this.id,
    required this.sectionId,
    required this.audioPath,
    required this.duration,
    required this.cues,
    required this.voiceSettings,
  });

  final String id;
  final String sectionId;
  final String audioPath;
  final Duration duration;
  final List<SpeechCue> cues;
  final VoiceSettings voiceSettings;
}
