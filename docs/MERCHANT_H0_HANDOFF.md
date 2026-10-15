# Merchant H0 — local accounting foundation

Date: 2026-10-15. Branch: `agent/merchant-ledger-h0`.
Baseline: `6ef06be80296d4e88d0e7c1907ad1ae3575a5abb` (integrated D+F).
Product authority: canonical §§8–9 and implementation slice H0, following the
Product Owner's instruction to start the next work. Integration Agent owns merge.

## Delivered scope

Additive migration `20261015002300_0023_commerce_ledger_foundation.sql` adds:

- Immutable versioned V1 policy with the already frozen amounts/durations;
  `commerce_ledger_config` starts disabled and seeds no balance.
- Typed parties/accounts, immutable source attestations, balanced journals,
  postings and event-consumer receipts. Account lock epochs serialize operations;
  they contain no monetary balance. Balances derive from immutable postings.
- Exact source/payload replay, deferred journal count/hash/balance sealing,
  nonnegative protected accounts and atomic compensating reversal.
- Coupon-source reserve allocation up to 1000 TL; unused package funds kept
  separate; platform service charges consume existing reserve first.
- Bounded, noncash future-offset creation/recovery and consumer/event deduplication.
- Authenticated owner-scoped account reads and public, accounting-only capabilities.
  Money is integer minor units in PostgreSQL and decimal integer strings in JSON.
- A read-only Dart repository/domain contract using BigInt, strict scope/shape
  checks, timeout/error handling and late-response rejection after account changes.
  It is not bound into either app host or any money screen.

The existing Customer UI, Merchant navigation, Reward presentation, shared push
architecture and dependency graph are unchanged. H1 statement/withdrawal screens
and E/G economic integration are not included.

## Accounting and authority contract

| Party | Account classes | Meaning |
| --- | --- | --- |
| Merchant | coupon pending/available, unused fund pending/available, reserve | Separate origins; available is not bank-withdrawal authorization |
| Customer | pending, coupon, future offset | Offset is a noncash obligation against future rewards, not personal cash debt |
| Package | free, held | Internal fund partitions; no real purchase/provider activation |
| Platform | clearing, service, offset control | Signed clearing/control accounts; protected service balance stays nonnegative |

Only the database owner/trusted future server modules may register sources or post.
`anon`, `authenticated` and `service_role` have no raw table or posting access.
Client grants are limited to capabilities and the authenticated own-account read.
Reads check the live Auth session, customer role or exact shop ownership; erased
customer identity mappings are removed while financial facts remain private.
Retention and identity-unlinking still require the release privacy-policy review.

`evidence_ref` records a trusted source attestation. It does not prove provider
funding, actual final sale, coupon consent, eligibility or package ownership beyond
the internal party relation. E/G must validate those facts and call source,
journal and consumer functions within the complete business transaction.
No automatic outbox worker is installed, and no service-role grant is a substitute
for that future business authorization layer. Two different consumers are distinct
receipt namespaces; the future workflow must choose stable consumer/source keys.

New posting requires the accounting flag. An exact prior receipt can still be
replayed while disabled; altered payloads and new effects fail. Funding, rewards
and settlement capabilities stay false even when local tests enable accounting.

Reversals are exact compensating entries. They reject duplicate reversal, an
insufficient account, reserve overfill after later refill and reversal of a
previously offset original reward. No partial reserve reclassification is guessed.
General `return` postings explicitly fail with `LEDGER_RETURN_POLICY_PENDING`.
E must supply O7 per-coupon/source allocation and partial-return transactions.

The H0 offset bound conservatively subtracts all current unspent customer value
from the original reward source before allowing an obligation. Recovery consumes
future pending value and reduces the obligation in one journal, bounded by both
the original obligation and referenced accrual. It is not the final reward engine;
cases requiring detailed coupon-lot allocation remain unavailable until E.

## Validation

| Evidence | Result |
| --- | --- |
| Flutter full suite | 2407 PASS / 0 FAIL / 6 existing live-environment SKIP |
| Focused Dart adapter + canonical migration contracts | 25 PASS |
| Flutter analyzer | PASS, no issues |
| Native PostgreSQL 17.11 | 53 groups PASS: C 17 + D/F 16 + H0 20 |
| Real local Supabase Auth/PostgREST/Storage/PostgreSQL | 44 groups PASS: existing HTTP 5 + D/F SQL 16 + H0 SQL 20 + H0 HTTP 3 |
| Local harness safety tests | 5 PASS |
| Customer development debug APK | PASS |
| Merchant development debug APK | PASS |

The Customer build logged a Kotlin incremental-cache daemon failure, recovered
through the build tool's fallback and produced the APK successfully. Merchant
build completed successfully. No build/dependency configuration was changed.

Native evidence uses synthetic Auth/Storage schema and cannot prove managed
authentication. The separate managed run uses actual local Auth-issued sessions,
HTTP privilege checks and logout invalidation. Neither is physical-device evidence.

Reports: `data/merchant_h0_native_acceptance.json` and
`data/merchant_h0_managed_acceptance.json`. Each records the actual SHA-256 of all
19 tested migrations. The 18 earlier migration hashes match the prior D/F evidence;
no historical SQL content is changed. 0020–0022 checkout line endings were restored
to the previous tested bytes before final acceptance. A different Git line-ending
policy may change a checkout byte hash; compare original file bytes and report
that difference explicitly rather than treating it as a SQL change or silently
rewriting a prior report.

Reproduction from the task checkout:

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub test/unit/commerce_ledger test/unit/supabase/canonical_migrations_contract_test.dart
npm --prefix tool/merchant_acceptance test
node tool/merchant_acceptance/native.mjs <local-postgresql-17-bin-directory> --ledger
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-printed-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-run-directory> --ledger
node tool/merchant_acceptance/local.mjs stop <same-run-directory>
flutter build apk --debug --no-pub --flavor development -t lib/main_development.dart --dart-define=TRUST_COMMERCE_V1_ENABLED=true --dart-define=REVIEWS_V2_ENABLED=true
flutter build apk --debug --no-pub --flavor merchantDevelopment -t lib/main_merchant_development.dart --dart-define=TRUST_COMMERCE_V1_ENABLED=true --dart-define=REVIEWS_V2_ENABLED=true
```

Use a fresh run directory for every managed acceptance attempt: tests deliberately
consume/delete synthetic actors. Install the harness's existing pinned development
dependencies with `npm ci` in its directory when needed. Use the local runner's
ownership/loopback checks; never substitute a linked or hosted Supabase project.
All task-owned runtimes are stopped after validation, retaining diagnostic data.

## Integration and release gates

Migration 0023 depends on integrated B/C/D/F. Local rehearsal uses Development
0001–0011 plus shared 0016–0023. Production-only 0012–0015 are a separate track:
these results do not authorize generic `db push`, remote migration reconciliation,
Production apply or a deployed worker. Historical migrations remain intact.

Shared changes are limited to the additive migration, canonical/slices entries,
the migration-contract inventory/parser and optional local acceptance runners.
There is no main merge/push, provider configuration, credential change, external
financial action or live-data write in this delivery.

Before economic rollout: review the account map and finance/legal policy, assign
a reconciliation owner, implement complete E/G source validation and atomic
workflows, obtain provider/settlement contracts and explicit deployment authority.
H1 must expose only server-approved actions; H0 does not approve withdrawals.
Physical two-device QR acceptance, real push-provider delivery and final release
acceptance remain open and cannot be inferred from these local tests.
