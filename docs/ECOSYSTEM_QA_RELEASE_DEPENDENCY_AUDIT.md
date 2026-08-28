# Ecosystem QA / Release Dependency Audit

**Result:** PASS — EVIDENCE CLASSES REMAIN HONEST

| Risk | Minimum evidence | Does not substitute for |
|---|---|---|
| deterministic business rule | unit/state/contract tests | deployed policy or device hardware |
| RLS/RPC/idempotency | isolated backend integration | Production identity/config |
| QR concurrency | two independent sessions/connections | physical camera/two-device acceptance |
| Flutter navigation/state | widget/integration tests | Android/iOS native callback/permission behavior |
| signed binary | artifact hash/signing/install/upgrade | source-level green tests |
| migration | clean-room + representative upgrade/backfill/rollback | owner-authorized remote apply |
| Production smoke | exact read-first authorized checklist | complete regression or long-term health |

Dependencies before pilot release: immutable candidate identity, standard release
build, signed Android acceptance, required iOS/Android-only owner decision, exact
backend state, QR physical gate, monitoring/runbook, fixture cleanup and explicit
go/no-go. Skips/quarantine/synthetic/manual states remain labelled; no green CI
result silently certifies unavailable evidence.

Advanced CI matrix expansion is DEFER unless change risk justifies it. The pilot
needs reliable minimum gates, not enterprise pipeline breadth.
