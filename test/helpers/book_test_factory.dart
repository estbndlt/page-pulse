import 'package:page_pulse/features/library/domain/entities/book.dart';
import 'package:page_pulse/features/library/domain/entities/text_anchor.dart';
import 'package:page_pulse/features/speech/domain/entities/speech_asset.dart';
import 'package:page_pulse/features/speech/domain/entities/voice_settings.dart';

class BookTestFactory {
  const BookTestFactory._();

  static const anchor = TextAnchor(
    sectionId: 'section-1',
    paragraphIndex: 0,
    tokenIndex: 0,
  );

  static BookSection section({String id = 'section-1'}) {
    return BookSection(
      id: id,
      title: 'Section 1',
      sourcePageNumber: 1,
      paragraphs: const [
        BookParagraph(index: 0, text: 'Alpha beta gamma.', tokens: []),
      ],
    );
  }

  static Book book({
    String id = 'book-1',
    String title = 'Test Book',
    List<BookSection>? sections,
  }) {
    return Book(
      id: id,
      title: title,
      sourceFileName: 'test-book.pdf',
      sections: sections ?? [section()],
    );
  }

  static SpeechAsset speechAsset({String id = 'speech-1', String? sectionId}) {
    return SpeechAsset(
      id: id,
      sectionId: sectionId ?? 'section-1',
      audioPath: '/tmp/speech.wav',
      duration: const Duration(seconds: 3),
      cues: const [],
      voiceSettings: const VoiceSettings(),
    );
  }
}
