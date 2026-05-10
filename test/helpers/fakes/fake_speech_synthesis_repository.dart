import 'package:page_pulse/features/library/domain/entities/book.dart';
import 'package:page_pulse/features/speech/domain/entities/speech_asset.dart';
import 'package:page_pulse/features/speech/domain/entities/voice_settings.dart';
import 'package:page_pulse/features/speech/domain/repositories/speech_synthesis_repository.dart';
import 'dart:async';

import '../book_test_factory.dart';

class SpeechSynthesisRequest {
  const SpeechSynthesisRequest({
    required this.section,
    required this.voiceSettings,
  });

  final BookSection section;
  final VoiceSettings voiceSettings;
}

class FakeSpeechSynthesisRepository implements SpeechSynthesisRepository {
  FakeSpeechSynthesisRepository({
    SpeechAsset? speechAsset,
    this.error,
    Completer<SpeechAsset>? pendingSpeechAsset,
  }) : speechAsset = speechAsset ?? BookTestFactory.speechAsset(),
       _pendingSpeechAsset = pendingSpeechAsset;

  final SpeechAsset speechAsset;
  final Object? error;
  final Completer<SpeechAsset>? _pendingSpeechAsset;
  final requests = <SpeechSynthesisRequest>[];

  @override
  Future<SpeechAsset> prepareSectionSpeech(
    BookSection section,
    VoiceSettings settings,
  ) async {
    requests.add(
      SpeechSynthesisRequest(section: section, voiceSettings: settings),
    );

    final error = this.error;
    if (error != null) {
      throw error;
    }

    final pendingSpeechAsset = _pendingSpeechAsset;
    if (pendingSpeechAsset != null) {
      return pendingSpeechAsset.future;
    }

    return speechAsset;
  }
}
