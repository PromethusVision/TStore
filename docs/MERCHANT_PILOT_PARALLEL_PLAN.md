# Merchant Pilot Parallel Plan

State: `FUTURE COORDINATION PROPOSAL`

| Track | Scope | Parallel-safe start | Shared-risk areas |
|---|---|---|---|
| Agent 1 | Merchant app shell/auth/shop projection | Owner scope decision | auth contracts, shared packages |
| Agent 2 | Listing UI/data, QR verifier, lifecycle tests | API contracts frozen | QR DTOs, shop/listing models |
| Agent 3 | Backend authority/listing/candidate migrations + tests | Owner/backend decision | migration chain, RLS/RPC |
| Integration | Contract pinning, combined validation, release gate | Always read-only early | main, pubspec, DI, routing, signing |

Ops/compliance can prepare cohort/verification/support runbooks independently. QA can build matrices and fixture contract before runtime. Physical two-device and Production gates remain human/integration activities, not unattended agent work.

No two agents should independently edit migration chain, `pubspec`, shared auth models, route bootstrap or QR RPC signatures. Contract docs precede parallel implementation; additive backward-compatible seams are preferred.
