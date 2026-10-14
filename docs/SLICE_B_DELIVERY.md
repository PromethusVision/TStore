# Slice B — QR claim, purchase evidence and returns

Status: local implementation complete; real-service acceptance remains OPEN.
Authorized 2026-10-15. Both enablement flags remain OFF by default.
Baseline: `origin/main@ebe54ccd`; branch `agent/merchant-qr-slice-b`.

## Audit and implementation boundary

- Reuse `qr_sessions`, immutable QR items, `verified_transactions/items`,
  `QrSessionRepository`, both existing QR cubits and Merchant's exact-shop adapter.
- 0009 installs final legacy create/get/confirm bodies. Its 120-second guard
  applies to confirmation as well as scanning. Wrap those bodies with a protocol
  guard before any expiry mutation; preserve legacy behavior when disabled.
- Cart item mutations already cancel active QR. Use the same cart-before-session
  lock order for all new operations. Confirmed purchases already have unique QR
  source IDs and best-effort notifications. Reuse both guarantees.
- Purchase history omits the stored product UUID. Add it compatibly without
  changing accepted Customer layouts. No second purchase, QR or inbox system.
- New additive migration 0018: protocol/config, verified device session binding,
  manual aliases, claims/rate limits, immutable terms/events/returns/invalidation.
  No historical migration or Phase 1/notification proposal is edited.
- Extend the existing Merchant QR screen with manual entry, claim recovery,
  deadline distinction and cancellation. A nested purchase/return view stays
  within the existing QR tab; no new navigation tab or turnover dashboard.
- Customer QR changes are limited to opt-in v2 code/deadline/status compatibility.
  Legacy mode remains the default. V2 must never silently fall back after a claim.

## Engineering defaults (not production activation)

- Scan 120 seconds; completion 600 seconds from first claim, never renewed.
- Auth JWT `session_id` must match an unexpired live `auth.sessions` row owned by
  `auth.uid()`. Bind one installation to that session and allow at most two live
  registered Merchant sessions. A client UUID alone is never authority.
  Basis: [Supabase Auth sessions](https://supabase.com/docs/guides/auth/sessions).
  Deployment must verify
  actual Auth schema, expiry settings and logout/revocation behavior.
- Invalid code attempts commit bounded server counters; raising an exception
  must not roll back the attempt counter. Both scan and code claim one source.
- B captures a quote-only sale: final sale equals the immutable quote, coupon=0.
  No merchant discount negotiation, rewards, coupon spending or financial ledger
  is enabled. Exact integer minor units are required; fractional-kurus quotes fail.
- Return-policy duration is explicitly unknown until a real versioned shop policy
  exists. No guessed legal return period or automatic eligibility promise.
- Returns record evidence, not an executed cash refund. Legacy purchases without
  terms are `legacy_unclassified`; neither retroactive terms nor benefits are made.
- Durable evidence contains UUID references, not FKs into disposable Auth/cart/QR
  rows. Account deletion must remain possible; retention approval remains external.

## Open acceptance gates

- Docker engine is unavailable; the existing real local Storage HTTP acceptance
  remains open until the local environment can start. Synthetic transport and
  ephemeral PostgreSQL results must be reported separately.
- Docker Desktop repeatedly fails on the local `sailor-ingest.sock` listener.
  After stopping the backend, its four zero-length runtime socket entries were
  preserved by renaming `run` to `run.before-slice-b-20261015`. A hidden restart
  reproduced the error. No data/image/WSL deletion, factory reset or remote
  fallback was performed. The backup remains available.
- Managed Auth logout/expiry/revocation, real pgcrypto HMAC, simultaneous requests
  on independent PostgreSQL connections and gateway transaction behavior remain
  OPEN. The fixture cannot establish those properties. Before activation, verify
  session limits and rate thresholds with the intended shop traffic as well.
- Production schema/app activation needs explicit authorization. Main merge is
  Integration Agent work. Two physical device QR acceptance remains Slice J.

## Validation

| Check | Evidence |
|---|---|
| New QR transport/state, purchase evidence and migration contract tests | 34 PASS |
| Complete Flutter regression suite | 2357 PASS, existing 6 SKIP |
| Analyzer | PASS, no issues |
| Slice B ephemeral SQL | 17 grouped checks PASS |
| Slice A / Merchant daily SQL regression | 26 / 9 grouped checks PASS |
| New narrow-screen golden tests | 4 PASS: claim and purchase, 320/390 px, text scale 130% |
| Merchant development debug APK | PASS; package identity verified |

The full suite and analyzer both exited 0. Existing Customer/Merchant golden
baselines were not regenerated. Narrow claim and
purchase renders were visually inspected; duplicate purchase screen headers were
removed. Loading/error/retry, double submit, lost response, same-request recovery
after screen reconstruction, invalid return quantity and navigation are covered.

`tool/qr_slice_b/schema.test.mjs` applies the development fixture 0001–0011 + 0016,
then 0017 and the exact 0018 file. PGlite 0.5.5 / PostgreSQL 18.3 runs in memory
with synthetic identities and an `auth.sessions` fixture. HMAC/digest use explicit
test substitutes because pgcrypto is unavailable in that runtime. The script
tests access boundaries, private function/table revokes, session registration,
retry/deadline/flag behavior, persistent rejected-attempt counters, quote changes,
append-only evidence, bounded returns, admin correction/invalidation and account
deletion. Sequential idempotency checks are not proof of concurrent SQL behavior
or cryptographic strength. No real credentials or production rows are used.

The Android build uses `QR_CLAIMS_V2_ENABLED=true` to compile the opt-in path,
loopback backend URL and a synthetic publishable-key-shaped value. It does not
establish a real backend session or install/release the application.

- Artifact: `build/app/outputs/flutter-apk/app-merchantdevelopment-debug.apk`
- Package: `com.esnaftavar.app.merchant.dev`, `1.0.0+5`
- SHA-256: `DD0DF701DA4233EBAEBDE355E4DE85464F29A194B68F627FE64AD784F8A6A4AB`
- Build exit 0, 111.8 seconds. Existing cross-drive Kotlin incremental cache
  errors fell back successfully; no global Gradle or dependency changes.

## Integration, activation and rollback boundary

Only new migration `20261015001800_0018_qr_claim_purchase_returns.sql` is added.
Applied migrations, proposal SQL, dependencies and provider configuration remain
unchanged. Integration Agent must refresh the main/source fingerprint and merge
this task branch with combined validation. This delivery does not merge main.

0018 preflight requires 0017, canonical QR functions, managed `auth.sessions` and
its `not_after` column, and `auth.jwt()`. A real environment needs independent
verification of actual Auth semantics, canonical QR function definitions,
extensions and permissions. Development 0010/0011 and Production 0012–0015 are
mutually exclusive taxonomy tracks; do not run a generic migration push over the
production chain. The production schema track has not been rehearsed for 0018.

The migration saves the legacy create/get/confirm implementations privately and
puts a protocol guard in front of them. Legacy clients retain existing behavior
for legacy sessions. V2 needs compatible Customer and Merchant opt-in clients
and server configuration. A legacy client receives an explicit version-required
failure when presented with a v2 session. It cannot expire or finalize that
session using the old protocol. Shared notification triggers are reused; Firebase
and APNs setup is not part of this task.

Rollback starts by disabling **new** v2 sessions/claims on the server while
retaining compatible clients to reconcile, complete or cancel existing claims.
Keep terms/returns/events and protocol guards in place. Turning off the client
flag or reverting to an old binary before draining claimed sessions is not a
safe recovery plan. Never drop the new evidence or restore legacy wrappers over
live v2 data as an automatic rollback. No remote activation/rollback was executed.

The header participant RLS policy now enforces current active exact ownership
for v2 merchant evidence; historical confirming identity alone is insufficient.
Customer-owned access and legacy visibility remain. Existing item RLS derives
access through that parent. Existing purchase headers and item deletion also
gain immutable guards. These are shared integration review points, alongside
the QR repository/cubits, Customer QR sheet, locator and Merchant local entry.

## Reproducible local checks

```text
flutter analyze --no-pub
flutter test --no-pub
node tool/qr_slice_b/schema.test.mjs <local-pglite-package-directory>
node tool/catalog_media/schema.test.mjs <local-pglite-package-directory>
node tool/merchant_operations/schema.test.mjs <local-pglite-package-directory>
```

The scripts create only ephemeral fixture databases. They are not migration
deployment tools. After local services recover, the remaining acceptance is:

1. Real local Supabase Auth/pgcrypto/concurrent claim + completion + return
   requests, ownership/session revocation and same-source recovery after restart.
2. The previously open real Storage upload/publish/read journey.
3. Two physical devices and camera/permissions later under Slice J authorization.
