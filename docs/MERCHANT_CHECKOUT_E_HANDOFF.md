# Merchant E — customer-authorized coupon checkout delivery

Task branch: `agent/merchant-checkout-e`.
Baseline: `af9d59652851c7fa3348bfc1564725411ad85aea` (integrated earning lifecycle).
Authority: Product Owner requested the next implementation after integration PASS.
Canonical §§5, 8.2, 9 and O6/O7 govern. Main integration belongs to Integration Agent.

## Integration correction to 00192eb6

Integration correctly rejected the first delivery: the existing QR path reserved
against the gross sale before coupon approval, then only released an ineligible
hold at completion. The earlier terminal "no reward" tests missed that interval.
The added pre-claim regression failed on 00192eb6 with `checkout_hold` instead of
`released` for 500 TL sale − 250 TL coupon = 250 TL payment.

Forward migration 0026 releases the slot and its 50 TL fund in the same approval
transaction. Reservation refresh reads the immutable live consent and its policy,
so reopen, simultaneous retries and explicit restart cannot reacquire on gross
value or extend the original attempt. Exact 500 TL net retains a valid hold.
Cancellation permits normal reassessment under the unchanged attempt deadline.
The private repair also handles previously created bad holds without rewriting
their approval/QR evidence; its migration pass requires no customer Auth context.

Regression proof now includes pre-claim/post-claim slot and fund balances, one-cent
boundaries, zero payment, exact replay, last-slot contention, atomic rollback,
expired-package receivables and denial of the private gross-value bypass. A real
local HTTP/Auth test independently verifies immediate release and refresh behavior.

## Delivered behavior

Customer-selected EV coupon use now connects to the existing physical Merchant QR
transaction. This is the local **unchanged-price coupon checkout and O7** package;
it is not authorization to deploy funded economics or declare physical QR complete.

- Customer sees server-authoritative sale, available coupon, selected coupon and
  remaining physical payment before approval. Exact approval captures customer
  Auth session, request UUID, immutable cart/classification fingerprint and QR.
  Duplicate taps are suppressed; uncertain retries retain the same request/totals.
  Reopening recovers an owned pending or completed approval instead of issuing a
  second authorization. Account changes discard stale private replies.
- Merchant sees sale, approved coupon and physical payment separately and must
  attest all three. Old B/E completion endpoints reject coupon contracts. Existing
  B and earning-only E flows retain their original behavior.
- Only products with explicit current `ordinary` classification may participate.
  Unknown/cash-equivalent items close coupon use for the entire cart. Classification
  evidence is private, append-only and trusted-operator-only, with policy reference
  and reason. No category inference or client classification authority was added.
- Same transaction: original purchase, exact final terms/line allocations, coupon
  debit, chronological source consumption, Merchant reserve/pending receivable and
  net-eligible earning. `750−250=500` earns; `500−250` and `500−500` do not. Failures
  roll all effects back. The original quote header/items remain immutable.
- Partial spends consume oldest coupon/source first. Audited invalidation reverses
  only unspent source value and creates a non-cash future reward offset for spent
  value, while restoring original package fund/capacity. Next mature groups recover
  offsets before spendable issuance. Five source links/250 TL face remain immutable;
  remaining coupon value may be reduced or zero. No duplicate recovery/cash debt.
- Genuine returns preserve exact allocated sale/coupon evidence, including small
  remainders and out-of-order corrections. No cash refund or coupon restoration is
  executed. Both apps' purchase history show exact coupon/payment amounts; pending
  future offsets are explained in the Customer Reward Center.

## Migration, ownership and compatibility

Migration `20261015002500_0025_coupon_checkout.sql` adds six private tables
(gate, product classification, approval, redemption,
source use and future offset), private helpers/triggers and role-scoped RPCs.
Forward migration `20261015002600_0026_coupon_reservation_net_threshold.sql` adds
the approval-time release, guarded reservation wrapper and existing-hold repair.
0025 and all earlier migrations are unchanged from the rejected delivery.
RLS and revoked table/helper privileges are verified for anon/authenticated/
service_role. The classification function is database-owner-only, not an admin
screen or a provider attestation API. Classification policy must be approved
separately before any real rollout.

The existing B purchase insertion receives final terms through a BEFORE trigger;
E earning checks the actual coupon redemption against those terms. H0 remains the
sole monetary ledger. Coupon redemption calls its source/reserve guards privately;
the generic public ledger API still rejects bypasses of E allocation ownership.
E's private compensation kernel handles the audited source-aware memo obligation.
Deferred seals bind account balances, immutable source capacity and owned offsets.
Existing migrations are byte-identical to the previous E acceptance evidence.

Lock order remains cart → E serialization epoch → UUID-ordered ledger locks;
purchase return/invalidation uses B's purchase-row lock before the E epoch.
No network/provider call occurs under these locks. Global serialization still
needs measured throughput/SLO and operational reconciliation before rollout.

The gate `COUPON_CHECKOUT_V1_ENABLED` defaults false in both applications. It also
enables their E/QR transport bindings when explicitly compiled true. Server
`reward_checkout_config.enabled` defaults false and depends on E/H0/B readiness.
Legacy reward capability fields remain false for old clients; new checkout uses
its versioned capability/preview and optional exact DTO extension. Old clients
cannot complete coupon purchases using an earning-only attestation.

Gate-off blocks new approvals, preserves prior receipts and permits already
approved work under frozen terms while H0 is enabled. Customer-session revocation,
classification changes or insufficient balance still block finalization. This is
not a new coupon balance reservation: authorization is an exact cap, and completion
rechecks actual source availability under the ledger lock. A changed sale requires
cancellation and a new quote/customer approval.

## Verification and reproduction

Passing reports: `data/merchant_checkout_e_native_acceptance.json`,
`data/merchant_checkout_e_managed_acceptance.json` and
`data/merchant_checkout_e_delivery_validation.json`.
Native proof uses PostgreSQL 17.11 with real crypto and independent connections;
its Auth/Storage schemas are synthetic. Managed proof separately uses actual local
Supabase Auth/PostgREST/Storage. Neither replaces physical-device acceptance.
Both reports identify all 22 migration byte hashes; the first 21 exactly match
00192eb6. The correction changes no Flutter runtime, dependency or asset file.

| Check | Result |
| --- | --- |
| Full Flutter suite | 2,465 PASS, 0 FAIL, 6 existing SKIP |
| Final migration contract tests | 18 PASS |
| Analyzer | PASS, no issues |
| Native PostgreSQL | 101 groups PASS |
| Managed local services | 100 groups PASS |
| Harness isolation/safety | 5 PASS |
| Customer / Merchant debug APK | Prior PASS reused; Flutter build inputs unchanged |
| Widget renders | 5 prior inspected renders; UI unchanged |

Native and managed groups overlap and must not be added as independent coverage.
The full Flutter suite and analyzer were rerun for this correction; final contract
tests cover the last SQL edit. The prior 83 focused Flutter tests, both APKs and
five inspected renders remain valid for the unchanged Flutter implementation;
they are not reported as newly executed builds or physical acceptance. Prior
Customer compilation used Gradle's successful fallback after the known Kotlin
incremental-cache daemon error; both APK fingerprints are retained in the report.

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub test/unit/rewards test/widget/merchant/coupon_checkout_widget_test.dart test/widget/merchant/merchant_reward_e_test.dart test/widget/cart/cart_qr_session_bottom_sheet_test.dart
npm --prefix tool/merchant_acceptance ci --no-audit --no-fund
npm --prefix tool/merchant_acceptance test
node tool/merchant_acceptance/native.mjs <owned-local-postgresql-17-bin> --checkout
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-owned-run-directory> --checkout
node tool/merchant_acceptance/local.mjs stop <same-owned-run-directory>
```

Use fresh fixtures only. Run harness safety checks with its loopback ports free.
No existing project DB, Docker-wide reset/prune or remote fallback is used. Owned
validation processes are stopped and their synthetic data retained after checks.

Customer APK: `--debug --flavor development -t lib/main_development.dart`.
Merchant APK: `--debug --flavor merchantDevelopment -t lib/main_merchant_development.dart`.
Both use `--no-pub` plus `COUPON_CHECKOUT_V1_ENABLED=true`,
`REWARD_EARNING_V1_ENABLED=true`, `QR_CLAIMS_V2_ENABLED=true`,
`TRUST_COMMERCE_V1_ENABLED=true` and `REVIEWS_V2_ENABLED=true` dart defines.
These are compilation checks, not a hosted activation request.

Five inspected widget renders are in `evidence/checkout_e/`: Customer approval at
320px/1.3 scale, uncertain retry, ineligible cart, actual recovered QR and Merchant
attestation. They use synthetic data and the existing project fonts/theme.

## Rehearsal and rollback boundary

Both fresh local fixtures applied the complete ordered migration chain and checked
the new default-OFF state before enabling synthetic scenarios. Migrations 0025–0026 are
transactional with preflight checks, statement/lock timeouts and no historical
rewrite. A failed application rolls back that migration transaction.
The 0026 repair uses the existing ledger release, preserving history and routing
expired-package funds through the existing expiry rule. If affected holds exist
while H0 is stopped, the release fails closed and the whole migration rolls back;
an operator must resolve that operational gate before an authorized deployment.

For an approved future rollout, disabling the checkout gate stops new approvals;
existing approved work retains frozen terms while H0 is enabled. This is deliberate
compatibility, not a universal emergency cancellation switch. An incident affecting
already approved work requires the existing H0 operational stop/reconciliation
procedure. Do not drop tables/functions, replay old migrations or reverse monetary
entries to downgrade after purchases have posted. Preserve the evidence and use a
reviewed forward fix; no hosted rollback or migration was performed in this task.

## Remaining release/product gates

- Unchanged-price physical checkout only. Merchant price amendment/automatic
  campaign discount allocation is not implemented; original quote semantics stay.
- O8 cash refunds/coupon restoration, disputed redemption receivable treatment,
  withdrawal/settlement/provider rules need approved external policy. Recording a
  return or invalidation does not promise money movement or restore a used coupon.
- Real classification perimeter, trusted funding/provider proof, voluntary-return
  policy administration, privacy/retention, deployment, operations/SLO monitoring
  and physical two-device acceptance remain open. Firebase/APNs configuration is
  unchanged; no second notification system, Ads or new reward rule was added.
- Production access/write/migration apply: NONE. Main merge/push: NONE.

Shared review areas: additive SQL wrappers/triggers, canonical planning documents,
QR DTO/transport, DI and Merchant bootstrap, Customer QR/purchase history/Reward
bindings and Merchant purchase evidence. No new dependency, pubspec/lockfile change,
routing/theme redesign, shared push modification or historical migration edit.
