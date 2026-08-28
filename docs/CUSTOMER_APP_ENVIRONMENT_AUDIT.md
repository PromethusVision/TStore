# Customer App Environment Audit

Status: PASS

## Contracts

| Concern | Development | Production |
| --- | --- | --- |
| Entrypoint | `main_development.dart` | `main_production.dart` |
| URL variable | `SUPABASE_DEVELOPMENT_URL` | `SUPABASE_PRODUCTION_URL` |
| Public-key variable | `SUPABASE_DEVELOPMENT_ANON_KEY` | `SUPABASE_PRODUCTION_ANON_KEY` |
| Android identity | `.dev` application suffix | `com.esnaftavar.app` |
| Auth callback | Development flavor scheme | `com.esnaftavar.app://login-callback/` |

`SupabaseConfig` validates each environment independently and never consults the other namespace. Production rejects loopback targets and the canonical Development project ref. HTTP is accepted only for loopback Development. Only anon JWTs or publishable keys are accepted; service-role/server-only material is rejected before initialization.

## Repository checks

- `.env` files, signing properties, private keystores, and build outputs are ignored.
- `.env.example` contains names/placeholders, not real credentials, and is not a Flutter asset.
- The synthetic production compile contract is client-safe and is not live Production proof.
- Android flavor identity and callback separation are covered by architecture tests.
- No remote environment was read or written in Wave 16.

## Manual release dependency

Real Production URL/public-key injection remains a controlled build responsibility. The values must be supplied outside source control and validated by the existing release preflight. This audit intentionally did not inspect or print real secrets.

`ENVIRONMENT_SEPARATION: PASS`
`DEVELOPMENT_FALLBACK: NO`
`PRODUCTION_SECRET_COMMITTED: NO`
`PRODUCTION_TOUCHED: NO`
