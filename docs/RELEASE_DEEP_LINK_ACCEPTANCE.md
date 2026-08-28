# Deep Link Release Acceptance

State: PROPOSED — OWNER REVIEW REQUIRED

The current legacy callback contract remains `io.supabase.tstore://login-callback/` until final scheme and remote allowlist are changed atomically under separate authorization.

## Matrix

- cold/warm/resumed app;
- guest, authenticated user, and user switched during flow;
- confirmation, recovery, and supported navigation links;
- valid, expired, malformed, reused, wrong-environment, and unrelated links;
- Android intent filters and iOS URL schemes in exact signed artifacts;
- browser cancellation, app absent, and duplicate delivery.

Tokens must not be logged or exposed in UI. A link cannot confer merchant/operator role. Existing callback unit/static tests remain necessary but do not prove remote allowlist or physical device delivery.

OWNER_DECISION_REQUIRED: authorize a future atomic final callback scheme/allowlist cutover; not performed here.
