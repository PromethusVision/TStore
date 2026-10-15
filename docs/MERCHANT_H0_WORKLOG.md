# H0 — local accounting foundation

Baseline: integrated `6ef06be80296d4e88d0e7c1907ad1ae3575a5abb`.
Branch: `agent/merchant-ledger-h0`. Scope follows canonical sections 8–9 and H0
in the implementation slices, after the Product Owner's next-work instruction.

## Audit and bounded scope

The integrated repository has immutable purchase/return/invalidation evidence,
the B commerce outbox, C subject/session guards and D/F features. It has no live
accounting ledger. The existing RewardRepository is explicitly presentation-only.
The phase-1 isolated SQL proposal is a design reference, not a deployable backend.

Implement versioned frozen V1 policy, typed accounting parties/accounts, immutable
source claims/journals/postings, exact source replay protection, balanced entries,
nonnegative protected accounts, compensating reversals and consumer receipts.
Reserve allocation must distinguish coupon receivables from unused package funds;
platform service debits consume reserve first. Future reward-offset records are
internal accounting obligations, never customer cash debt.

H0 accepts monetary source facts only from the trusted database operator/future
server modules. It does not verify provider payments or decide purchase/coupon
eligibility. No mobile or service-role posting permission; no automatic outbox
consumer. E/G must supply their complete source validation and atomic workflows
before use. B quote-only terms, rewards UI and notification architecture stay as-is.

Minimal owner-scoped read contracts and typed Dart amounts prepare H1; no balance
screen, top-up, transfer, settlement or payment provider is added. Money is integer
minor units internally and decimal integer strings across JSON boundaries.

## Verification and release boundary

Rehearse a new additive migration with real PostgreSQL and local managed Auth.
Test missing/null/invalid amounts, currency and balancing, exact/changed replays,
concurrent duplicate and overdraft attempts, reversals, reserve-source rules,
account erasure, unauthorized SQL/RPC calls and session changes. Re-run canonical
migration contracts, Flutter analyzer/tests and both application builds.

All activation defaults OFF. No Production access/application, real funds, real
merchant billing, coupon issuance, Ads activation, H1 payout policy or main merge.
Unknown external policy keeps the corresponding later action unavailable.

## Completed local delivery — 2026-10-15

Added migration 0023, nine protected tables and internal source/posting/reversal/
consumer functions; read-only capability/account projections and an unbound Dart
adapter. No existing screen, host registration, notification transport or package
dependency changed. Frozen decisions are preserved in canonical §9.1.

Acceptance covers actual contended transactions, a repeatable-read stale snapshot,
reserve refill races, insufficient/duplicate/replenished-reserve reversals, bounded
offset recovery, exact integer encoding and privileged API denial. General return
postings fail closed until E implements its source allocation. Tests also exercise
the integrated review/trust/campaign flows with H0 installed.

Results: 53 native PostgreSQL groups, 44 real local service groups, 2407 Flutter
tests with 6 existing live-environment skips, 25 focused contract/adapter tests,
5 acceptance-harness safety tests, clean analyzer and both Android development
debug APKs. The Customer build recovered from a Kotlin incremental-cache daemon
error using the build tool's fallback; its final build succeeded. No dependency
or build configuration was changed to suppress that diagnostic.

Only disposable task-owned PostgreSQL/Supabase fixtures were written. They are
stopped with data retained. JSON reports contain the exact tested migration hashes;
the 18 earlier migrations retain their prior D/F evidence bytes and Git content.
Windows checkout line endings in 0020–0022 were restored to those historical bytes
before the final database runs. No historical migration change is delivered.

See `MERCHANT_H0_HANDOFF.md` for reproduction, accounting assumptions and release
gates. Main integration remains Integration Agent's responsibility.
