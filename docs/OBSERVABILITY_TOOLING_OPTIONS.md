# EsnaftaVar Observability Tooling Options

**State:** `CURRENT CONCEPTUAL COMPARISON — NO PURCHASE/INSTALLATION`

| Option | Strength | Cost/complexity/risk | Pilot fit |
|---|---|---|---|
| Supabase Logs Explorer | Native API/Postgres/Auth/Storage/Realtime diagnosis | Retention and features vary by plan; app crashes absent | Baseline backend source |
| Firebase Crashlytics | Flutter crash/nonfatal/ANR reporting and release grouping | Firebase setup; breadcrumbs may couple Analytics; privacy/config review | Strong mobile candidate |
| Sentry-like SaaS | Cross-platform errors, release context, optional performance tracing | SDK/SaaS/data processing/cost and scrubbing work | Strong broad candidate after evaluation |
| Custom lightweight metrics | Exact QR/RPC/data-quality invariants and cheap aggregates | Must operate storage/query/alerts; avoid reinventing crash tooling | Good for a small critical set |
| OpenTelemetry-compatible layer | Vendor-neutral logs/metrics/traces semantics | Full collector/tracing can overengineer pilot | Conventions now, selective adoption later |

Recommendation: use Supabase logs plus one privacy-reviewed crash reporter and a
small custom critical-metric/reconciliation set. Do not enable Analytics solely to
obtain crash breadcrumbs without a separate consent/privacy decision. Run a
non-Production proof with symbolication, release/environment separation, redaction,
quota/retention and alert delivery before selection.

Official references reviewed 28 August 2026:

- <https://supabase.com/docs/guides/monitoring-and-debugging/logs>
- <https://firebase.google.com/docs/crashlytics/flutter/get-started>
- <https://docs.sentry.io/platforms/dart/guides/flutter/>
- <https://opentelemetry.io/docs/concepts/signals/>

`OBSERVABILITY_TOOL_SELECTED: NO`

