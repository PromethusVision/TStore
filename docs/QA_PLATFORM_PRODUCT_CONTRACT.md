# EsnaftaVar QA Platform Product Contract

**State:** PROPOSED — DESIGN/AUDIT ONLY

## Mission

QA is the evidence system that answers whether a specific EsnaftaVar change, backend contract and exact release artifact is safe enough for its intended environment. It spans Customer App, future Merchant App, backend, catalog, QR, reviews, deferred ads/rewards, Operations and analytics without treating one green test as universal proof.

## Evidence classes

| Class | Proves | Does not prove |
|---|---|---|
| Unit | deterministic logic, validation and state transition | platform wiring, real permissions or remote policy |
| Cubit/BLoC | async state, retries, stale-result and duplicate-action behavior | real backend concurrency or native lifecycle |
| Repository/contract | mapping, request/response and error contracts | deployed schema/config correctness unless run against it |
| Widget | render, interaction, navigation and Flutter lifecycle | native dialogs, camera/GPS quality or store artifact identity |
| Backend integration | RLS/RPC/trigger/idempotency in an isolated stack | Production configuration or physical-device behavior |
| App integration | critical journeys across app layers | native platform UI unless the harness explicitly controls it |
| Physical acceptance | camera, GPS, permissions, deep links, background/resume and exact binary | fleet-wide behavior or Production health |
| Production smoke | narrowly authorized environment/artifact wiring | complete regression, destructive safety or long-term reliability |
| Release certification | reconciled evidence for one immutable artifact and backend state | future versions or unexecuted manual gates |

## Rules

- The cheapest deterministic layer owns each invariant; higher layers prove only the integration risk they uniquely cover.
- A skipped, quarantined, synthetic, compile-only or mock test is labelled honestly.
- Production smoke is read-only by default and never substitutes for Development-first mutation acceptance.
- Physical two-device QR, Apple signing/TestFlight and store-distributed artifact checks remain manual until actually executed.
- Customer and Merchant clients must share server contracts without sharing authority assumptions.
- Test, demo and synthetic traffic is marked at source and excluded from business, reward, reputation and ad metrics.
- Evidence records commit, app/build identity, environment, command/matrix, result, skips and artifact hash where applicable.

## Certification boundary

Automated PASS may certify source-level regression and an exact unsigned/compile artifact contract. `RELEASE_CERTIFIED` requires signed artifact identity, installation/upgrade evidence, required physical tests, backend compatibility, migration status, observability readiness and an authorized go/no-go decision.

## Research anchors

Flutter recommends many unit/widget tests and enough integration tests for critical journeys because cost and confidence differ by layer: https://docs.flutter.dev/testing/overview. Supabase recommends local, reproducible migration/test workflows before remote deployment: https://supabase.com/docs/guides/local-development/database-migrations.

`QA_PRODUCT_CONTRACT: PROPOSED`

`RUNTIME_OR_CI_MUTATION: NO`
