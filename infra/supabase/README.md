# Page Pulse Supabase Backend

This directory is a local-first backend template for a Raspberry Pi deployment behind Cloudflare Tunnel.

## Security model

- Copy `.env.example` to `.env` locally and replace every placeholder with generated values.
- Never commit `.env`, OAuth secrets, JWT secrets, tunnel tokens, database volumes, imported books, generated audio, or model files.
- Cloudflare Tunnel is the only intended public ingress. The `kong` service should not be exposed directly except for trusted local development.
- Google OAuth callback URL: `https://<api-domain>/auth/v1/callback`.

## Local validation

```sh
docker compose --env-file .env.example config
```

For real local runs, use a private `.env` file with strong random values and valid Google OAuth credentials.
