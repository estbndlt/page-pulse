import '../../../library/domain/entities/book.dart';
import '../entities/speech_asset.dart';
import '../entities/voice_settings.dart';

abstract interface class SpeechSynthesisRepository {
  Future<SpeechAsset> prepareSectionSpeech(
    BookSection section,
    VoiceSettings settings,
  );
}
