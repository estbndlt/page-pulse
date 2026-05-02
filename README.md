# Page Pulse

Page Pulse is a local-first Flutter app that imports PDFs, converts them into a reflowable ebook model, reads sections aloud with on-device TTS, and highlights the words being spoken.

## Architecture

The codebase follows clean architecture boundaries:

- `lib/features/*/domain`: entities, repository contracts, use cases, and pure business services.
- `lib/features/*/presentation`: Flutter screens and widgets.
- `lib/core`: routing, theme, environment, storage, and shared errors.
- `infra/supabase`: Raspberry Pi friendly backend templates for Supabase Auth/Postgres/PostgREST/Kong behind Cloudflare Tunnel.

Business logic is intentionally independent from Flutter plugins, Supabase, PDF parsers, local storage, and speech engines so it can be unit tested in isolation.

## Local development

```sh
flutter pub get
flutter test
flutter analyze
```

Runtime configuration is passed through Dart defines when Supabase auth is wired in:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://api.example.com \
  --dart-define=SUPABASE_ANON_KEY=replace-with-anon-key
```

## Backend

See `infra/supabase/README.md`. Commit only templates and migrations. Keep real `.env` files, tunnel tokens, JWT secrets, Google OAuth secrets, volumes, imported books, generated audio, and model files out of git.

## V1 scope

- Android and iOS Flutter app.
- PDF to internal reflowable ebook model, not EPUB export.
- On-device speech generation and practical word sync.
- Supabase Google OAuth plus metadata/progress/settings sync.
- No cloud processing of book content in v1.
