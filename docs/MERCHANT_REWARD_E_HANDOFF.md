# Merchant E — earning lifecycle delivery

Date: 2026-10-15. Task branch: `agent/merchant-reward-e`.
Baseline: `b022f5f3c446618fca2bc54a42da77700830d38a` (integrated H0).
Authority: Product Owner requested the next large implementation after integration PASS.
Canonical §§5, 8, 8.1 and 9 govern this delivery. Main integration belongs to the Integration Agent.

## Delivered behavior

The local earning lifecycle now connects a funded referral package to a Customer
reservation, the existing Merchant QR confirmation, immutable reward contributions
and chronological five-purchase coupon issuance. This completes the bounded
**earning portion of E**, not the whole E checkout/redemption slice.

- Operator-only package activation records consent/external-funding attestations,
  applies reserve before other available receivables and requires the exact
  external remainder. One active package snapshots 100 slots, 5,000 TL fund,
  750 TL service fee and 90 days. There is no app purchase/payment-success API.
- Authoritative cart eligibility creates a fixed 30-minute attempt. Repeated calls,
  quantity changes and reconnection do not renew it. Below-threshold release,
  same-attempt reacquisition, explicit retry after expiry, shop switch and one live
  user reservation share the same transaction boundary.
- The existing QR ID receives an E companion; no second scanner/purchase system.
  Valid holds transition through the scan/claim deadlines and retain their original
  package across expiry. Finalization without a hold can consume free capacity;
  with neither available it creates the purchase but grants no reward.
- The merchant must explicitly attest that the unchanged quote is the actual
  physical sale and no EV coupon was used. The server requires the exact minor-unit
  amount; the legacy completion endpoint cannot bypass the E attestation.
  Ordinary B-only purchases remain unchanged and cannot earn retroactively.
- One eligible purchase contributes 50 TL once. Five valid chronological sources
  issue one 250 TL coupon only after every source matures. Maturity is the maximum
  of 24 hours and the snapshotted voluntary-return duration. Same-shop purchases
  qualify. Issued source links are immutable; V1 coupons have no expiry.
- A normal pre-maturity return below the threshold restores its original slot/fund.
  A genuine post-maturity return retains the reward. Audited invalidation reverses
  unspent value. Corrections restore original chronology without duplicate grants.
  Free expired capacity and subsequently released holds credit unused-fund
  receivables exactly once; the service fee is never refunded by this workflow.
- Merchant dashboard opens an owned package/capacity/acceptance screen. Active
  package or open hold forces acceptance ON; preferred value remains separate.
  Customer cart shows the server reservation, and existing Reward surfaces show
  pending value, issued coupon value and history. Error/loading never becomes a
  fabricated zero balance. Account changes clear old data; a fresh login resumes
  with a new authoritative read. Five Merchant tabs and shared push remain intact.

## Architecture and migration

Only additive migration `20261015002400_0024_reward_earning_cycle.sql` is new.
It adds 14 private tables, explicit RPC grants, append-only package/contribution/
coupon/capacity evidence, and deferred capacity/customer-ledger consistency seals.
Historical migration content is unchanged.

H0 remains the sole monetary journal. E's private business kernel posts balanced
journals in the same PostgreSQL transaction as the existing B purchase/return
and commerce event. The public H0 operator kernel rejects postings that would
bypass E's package/coupon allocation owner. Raw tables and monetary helpers are
unavailable to anon, authenticated and service_role. Public clients may only read
capabilities and invoke role/ownership/live-session checked workflow RPCs.

Lock order is owned cart, E serialization epoch, then ledger account locks in UUID
order. The epoch contains no balance and rejects stale repeatable-read snapshots.
Funding locks its complete account set before calculating the external remainder.
No network/provider call runs under a database lock. This conservative global
serialization boundary needs throughput testing before rollout.

The original B quote header/items and classification remain immutable. The E
companion and sale attestation establish the unchanged actual-sale terms; they do
not pretend to implement discount allocation or coupon-spend approval. The
Merchant confirmation DTO exposes that exact attested amount. The existing B
purchase-history DTO remains quote-oriented pending the complete checkout extension.

Customer amounts use decimal integer strings and BigInt. Parsers reject unknown
authority/status, malformed amounts, foreign shop responses, inconsistent capacity,
duplicate history/coupons and unsupported expiry. No dependency was added.

## Validation

| Check | Result |
| --- | --- |
| Full Flutter suite | 2,451 PASS / 0 FAIL / 6 existing live-environment SKIP |
| Focused reward adapters, QR, Merchant screens and actual Customer cart | 81 PASS |
| Analyzer | PASS, no issues |
| Native PostgreSQL 17.11 | 75 groups: existing C/D/F/H0 53 + E 22 |
| Real local Supabase Auth/PostgREST/Storage/PostgreSQL | 70 groups: existing 44 + E SQL 22 + E HTTP 4 |
| Local harness safety | 5 PASS |
| Customer development debug APK, E bindings enabled | PASS |
| Merchant development debug APK, E bindings enabled | PASS |

E tests include independent-connection contention for reservation/last slot,
completion and coupon issuance; missing/malformed/mismatched attestation amounts;
no-capacity/no-reward; maturity ordering; reserve-first funding; expiry/release
accounting; whole-transaction rollback; stale snapshots; role/raw-access denial;
real Auth logout; in-flight work across gate-off; account erasure; UI duplicate
submit, slow/error responses, session changes, 320px/1.3 text scale and cart binding.

Native Auth/Storage schema is synthetic. The managed report separately proves
actual local signed sessions, HTTP and Storage. Neither is physical-device proof.
The first Customer build encountered the existing Kotlin incremental-cache daemon
fallback and succeeded; the final two builds also passed. Harness safety checks
were run after stopping the owned stack because they use the same loopback port.

Reports:
`data/merchant_e_native_acceptance.json`,
`data/merchant_e_managed_acceptance.json`,
`data/merchant_e_delivery_validation.json`.
Both database reports record the exact bytes of all 20 migrations. The 19 earlier
hashes match H0 evidence; checkout-only CRLF normalization for 0020–0023 was undone
before acceptance. A different Git line-ending policy may change checkout byte
hashes without changing SQL; report that distinction rather than rewriting history.

Five actual widget renders were inspected under `evidence/reward_e/`: Merchant
package, narrow layout, sale attestation, Customer reservation and Reward Center.
Fonts and icons are loaded from the project/Flutter runtime; screenshots are
synthetic fixtures and not production/customer data.

## Defaults, operation and remaining gates

- `REWARD_EARNING_V1_ENABLED` defaults false in both hosts. When true it also
  selects QR v2, but the server requires E, H0 and QR flags plus frozen policy V1
  before new enrollment. No server flag was enabled outside owned local fixtures.
- Gate-off prevents new enrollment and retains truthful history. Already-created
  E contracts may complete under their frozen terms while H0 remains available.
  Accounting OFF rejects new monetary effects atomically. Exact receipts can be
  reconciled; a timeout is never presented as proof of failure or success.
- Reconciliation runs on workflow/read requests and through private
  `_reward_reconcile_e(limit)`; maturity materializes on the owned Customer read.
  No scheduler is deployed. Production needs a bounded maintenance runner,
  invariant monitoring, measured lock contention and an operations owner.
- Trusted activation is an internal attestation boundary, **not provider proof**.
  Provider/funding consent verification, voluntary-return policy administration,
  privacy/retention review, deployment and legal/accounting approval remain open.
- Coupon spending, customer spend authorization, discounted final-sale amendment,
  cash-equivalent classification enforcement, partial-spent O7 offsets, settlement,
  Ads and real Firebase/APNs configuration remain outside this delivery.
- An administrative correction fails closed if the original fund/capacity cannot
  be recovered. There is no invented negative customer balance or automatic bank
  refund; the later reconciliation/settlement workflow must resolve such cases.
- Production access/write/migration apply: NONE. Local fixtures only. Their
  processes are stopped after validation and data retained. No main merge/push.

## Integration reproduction

Use a clean task checkout at the source branch and the existing pinned toolchain:

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub test/unit/rewards test/widget/merchant/merchant_reward_e_test.dart test/widget/cart/w45a_cart_prototype_test.dart
npm --prefix tool/merchant_acceptance ci --no-audit --no-fund
npm --prefix tool/merchant_acceptance test
node tool/merchant_acceptance/native.mjs <owned-local-postgresql-17-bin> --rewards
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run-directory>
node tool/merchant_acceptance/acceptance.mjs <new-owned-run-directory> --rewards
node tool/merchant_acceptance/local.mjs stop <same-owned-run-directory>
```

Every acceptance run requires a **fresh** fixture; never replay it into an existing
project database. Harness guards prohibit remote fallback and unexpected containers.
Run the harness safety test while its loopback ports are free.

Build Customer with `--debug --flavor development -t lib/main_development.dart`;
Merchant with `--debug --flavor merchantDevelopment -t lib/main_merchant_development.dart`.
Both final builds use `--no-pub` and
`--dart-define=REWARD_EARNING_V1_ENABLED=true`,
`--dart-define=QR_CLAIMS_V2_ENABLED=true`,
`--dart-define=TRUST_COMMERCE_V1_ENABLED=true`,
`--dart-define=REVIEWS_V2_ENABLED=true`.
These are compile checks, not permission to activate a hosted environment.

Shared review areas: additive migration/function wrappers, dependency injection,
Merchant development bootstrap/services, shared QR model/transport, existing
Customer cart/Reward bindings and the two canonical planning documents.
No pubspec/lockfile, routing/theme redesign, shared push or historical SQL edit.

The next coherent E package is the complete **coupon redemption/physical checkout
and O7 compensation** transaction, after reviewing remaining classification,
customer-approval and operating-policy decisions. Physical two-device acceptance
and any remote rollout still require their separate gates.
