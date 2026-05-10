# Page Pulse

Page Pulse is a local-first Flutter app for importing PDFs, converting them into an internal reflowable ebook model, reading sections aloud with on-device text-to-speech, and highlighting the words being spoken.

The project is intentionally designed so private book content stays on the device. The Raspberry Pi backend is for authentication, user settings, document metadata, and reading progress only.

## Current Status

This repo is still early, but it now has one real end-to-end reading path on
iOS: import a local PDF, render it as a reflowable reader view, and wire the
reader play button into the speech/playback application boundary.

Implemented:

- Flutter Android/iOS app scaffold with app ID `com.estbndlt.pagepulse`.
- Clean architecture folder structure for auth, library, import, reader, speech, and sync.
- Pure Dart domain entities and repository contracts for the main app boundaries.
- PDF import foundation with tokenization and PDF-to-book model builder services.
- Speech foundation with practical word cue estimation and playback cursor mapping.
- Flutter screens for login, library, PDF import, reader, and playback controls.
- Real PDF picker flow plus an iOS PDFKit text extraction adapter for local PDF import.
- Reader rendering from imported `Book` data.
- Reader play-button orchestration through a `SectionPlaybackController` and Riverpod providers.
- TDD-friendly speech test infrastructure with fakes, provider overrides, controller tests, and reader widget tests.
- Supabase/Postgres/Auth/PostgREST/Kong/Cloudflare Tunnel backend templates under `infra/supabase`.
- Initial Supabase RLS migration for profiles, document metadata, reading positions, and user settings.
- Flutter tests for tokenization, speech cue estimation, playback cursor mapping, playback orchestration, and reader playback wiring.
- Security guidance and `.gitignore` rules for secrets, generated audio, model files, imported PDFs, and local backend volumes.

Not implemented yet:

- Android PDF text extraction parity with the current iOS import path.
- Local Drift database schema and repositories.
- Supabase client initialization and Google OAuth UI flow.
- On-device `sherpa_onnx` TTS adapter, model download/install UX, or generated audio cache.
- Real audio playback integration with `just_audio`.
- Seek, progress, current-section selection, and token highlighting during playback.
- End-to-end import, read-aloud, highlight, and progress sync flows.

## Design Architecture

Page Pulse follows clean architecture. Business rules live in pure Dart domain code, while Flutter widgets, platform plugins, local persistence, speech engines, and Supabase stay behind interfaces.

```text
Flutter UI
  -> Riverpod providers / presentation state
    -> Use cases
      -> Domain entities and services
      -> Repository interfaces
        -> Infrastructure adapters
          -> PDF plugins, Drift/SQLite, file system, sherpa_onnx, just_audio, Supabase
```

### App layers

- `lib/app`: application root, router wiring, and theme setup.
- `lib/core`: shared configuration, routing, storage factory, theme, and errors.
- `lib/features/*/domain`: pure entities, repository contracts, use cases, and deterministic services.
- `lib/features/*/presentation`: Flutter screens and widgets.
- `infra/supabase`: Docker Compose templates, gateway config, and SQL migrations for the Raspberry Pi backend.

### Feature boundaries

- `auth`: Google OAuth through self-hosted Supabase Auth. The domain only knows about `AppUser` and `AuthRepository`.
- `library`: local book model, sections, paragraphs, tokens, and stable text anchors.
- `import`: PDF import request contracts, PDF-to-book building, and text tokenization.
- `reader`: reading progress contracts and reader UI shell.
- `speech`: voice settings, generated speech assets, speech cues, playback cursor mapping, synthesis contracts, and playback contracts.
- `sync`: metadata sync contracts for document metadata, reading positions, and settings.

### Local-first data model

The app should treat local storage as the source of truth:

- Imported PDFs remain private local files.
- Extracted book text remains local.
- Generated audio and timing cues remain local.
- Backend sync is limited to user profile, document metadata, reading position, and settings.

The planned local persistence adapter is Drift/SQLite. The domain model already separates `Book`, `BookSection`, `BookParagraph`, `BookToken`, and `TextAnchor` so local storage can evolve without changing UI or speech logic.

### Speech and highlighting design

V1 uses practical word sync rather than exact model timestamps:

1. Extract paragraph text from the book model.
2. Generate local TTS audio by section or paragraph.
3. Estimate `SpeechCue` ranges using generated audio duration, token lengths, and syllable hints.
4. Map playback position to the active `TextAnchor` with `PlaybackCursorMapper`.
5. Highlight the matching token in the reader.

This keeps the exact timing engine replaceable. A future Kokoro or custom ONNX adapter can emit real timestamps while preserving the same `SpeechAsset` and `SpeechCue` domain types.

Current implementation note:

- The reader now wires the play button into a `SectionPlaybackController`.
- The default speech and playback repositories are still unavailable placeholders until concrete adapters are added.
- The current vertical slice proves the UI-to-application orchestration path and keeps real TTS/audio engines behind interfaces.

### Backend design

The backend is deliberately lightweight for Raspberry Pi hosting:

- Postgres stores user-owned metadata only.
- Supabase Auth handles Google OAuth.
- PostgREST exposes tables through RLS policies.
- Kong routes `/auth/v1` and `/rest/v1`.
- Cloudflare Tunnel is the only intended public ingress.

Google OAuth callback URL:

```text
https://<api-domain>/auth/v1/callback
```

See `infra/supabase/README.md` for deployment notes.

## Security Model

This repository is safe for public GitHub use by design, but only if secrets stay out of git.

Do not commit:

- `.env` files with real values.
- Supabase JWT secrets, anon keys, or service role keys.
- Google OAuth client secrets.
- Cloudflare tunnel tokens.
- Android/iOS signing keys or certificates.
- Imported PDFs, extracted book text, generated audio, timing caches, model weights, or database volumes.

Commit only placeholder templates such as `.env.example`. See `SECURITY.md` for the full policy.

## Local Development

```sh
flutter pub get
flutter test
flutter analyze
```

For iOS simulator runs, make sure the local machine has:

- CocoaPods installed and available on `PATH`.
- An Xcode iOS Simulator runtime installed that matches the active Xcode SDK.

Runtime configuration is passed through Dart defines when Supabase auth is wired in:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://api.example.com \
  --dart-define=SUPABASE_ANON_KEY=replace-with-anon-key
```

For the current iOS PDF import path, a starter PDF can also be injected with:

```sh
flutter run \
  --dart-define=STARTER_PDF_PATH=/absolute/path/to/book.pdf
```

Validate the backend Compose template:

```sh
cd infra/supabase
docker compose --env-file .env.example config
```

Current backend caveat:

- The checked-in `infra/supabase` stack is still a template. `db`, `rest`, and `kong` can start locally, but the current plain `postgres:17-alpine` bootstrap is not yet sufficient for a clean Supabase Auth startup on a fresh database. Align it with the official self-hosted Supabase Postgres/bootstrap flow before treating it as a working end-to-end local auth environment.

## Moving To A New Codex Project

This repo was renamed locally after the original Codex workspace was created, so the active sandbox writable root may still point at the old directory. For future work, create a new Codex project directly at the current repo path:

```text
/Users/estbndlt/Documents/git/page-pulse
```

Recommended handoff steps:

1. Open a new Codex project with `/Users/estbndlt/Documents/git/page-pulse` as the workspace root.
2. Confirm the branch is `codex/initial-page-pulse-scaffold` or switch to the branch you want to continue from.
3. Run `flutter pub get`, `flutter test`, and `flutter analyze`.
4. Keep real backend credentials in untracked `.env` files only.
5. If you need iOS simulator work, confirm CocoaPods and the matching Xcode simulator runtime are installed before running `flutter run`.
6. If you want the sample reader path immediately, launch with `STARTER_PDF_PATH` pointing at a local PDF.
7. Continue development from the clean architecture boundaries already present in `lib/features`.
8. The next TDD-ready speech slice is a concrete `SpeechSynthesisRepository` adapter that generates a local `SpeechAsset` for one section.

## Future Improvements

Near-term app work:

- Add Android support for the current PDF text extraction path.
- Add Drift tables and local repository implementations for books, sections, tokens, speech assets, and reading progress.
- Integrate `just_audio` playback and connect it to `PlaybackCursorMapper`.
- Add the first `sherpa_onnx` adapter for on-device TTS and cache generated audio safely.
- Add Supabase initialization and Google OAuth login/logout.

Quality and architecture work:

- Add integration tests for import-to-reader and playback-to-highlight flows.
- Add repository tests with in-memory SQLite.
- Extend the existing fake PDF/speech/playback test harness to cover full reader and playback flows.
- Add error handling for encrypted PDFs, image-only PDFs, unsupported TTS models, missing storage, and offline backend access.
- Add CI for formatting, `flutter test`, `flutter analyze`, and backend SQL lint/config validation.

Product work:

- Improve ebook structure detection for chapters, headings, footnotes, headers, and page numbers.
- Add search, bookmarks, reading history, and voice/speed settings.
- Add model management UX for downloading, verifying, and deleting local TTS models.
- Add exact word timestamps when a local speech engine can provide reliable alignment.
- Add optional EPUB export after the internal book model is stable.
- Add cross-device metadata/progress sync while keeping book content local unless explicitly changed later.
