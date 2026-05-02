# Security Policy

Page Pulse is intended for a public repository, so this repo must never contain real secrets, private documents, generated speech, model weights, or local database volumes.

## Secret handling

- Keep real values only in untracked `.env` files or platform secret stores.
- Do not commit Supabase JWT secrets, service role keys, OAuth client secrets, Cloudflare tunnel tokens, signing keys, certificates, imported PDFs, extracted book text, or generated audio.
- Use `.env.example` files with placeholders for documentation.
- Rotate any credential immediately if it is ever committed or pasted into an issue.

## Local data

Imported PDFs, extracted ebook content, generated audio, and speech timing cues are private user data. V1 stores them on-device only. Backend sync is limited to metadata, settings, and reading position.

## Reporting vulnerabilities

Open a private security advisory on GitHub when available, or contact the repository owner directly. Do not publish exploit details before a fix or mitigation is available.

## Deployment notes

Run the Raspberry Pi backend behind Cloudflare Tunnel. Avoid inbound firewall openings for Supabase services, and expose only the API gateway hostname needed by the mobile app.
