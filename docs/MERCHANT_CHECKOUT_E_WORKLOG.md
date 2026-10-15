# Merchant E — customer-authorized physical coupon checkout

Baseline: `af9d59652851c7fa3348bfc1564725411ad85aea`.
Task: `agent/merchant-checkout-e`; local implementation authorized by the Product
Owner's request to begin the next package after integration. Canonical §§5, 8,
9 and O6/O7 govern. No main integration or hosted-environment access.

## Coherent implementation target

Extend the existing QR identity with immutable customer-approved coupon terms,
exact line allocations, explicit merchant attestation, atomic coupon debit and
merchant receivable, net-of-coupon earning, and source-aware administrative
compensation. Preserve original quote evidence, old B/E clients, five-source
chronology, exact retries and live Auth/device checks.

- Customer reviews authoritative sale/coupon/payment amounts before QR creation.
  Approval is bound to the cart fingerprint and exact live customer session.
- Catalog coupon eligibility is operator-attested and versioned; absent/unknown
  or cash-equivalent classifications fail closed. No guessed category policy.
- This package supports unchanged listed sale prices with EV coupon use. A
  merchant price amendment requires a new cart quote/customer approval; automated
  campaign discounts and stacking are not introduced.
- Coupon and source lots consume oldest issuance/source first. Item allocations
  use proportional integer division, largest remainder and listing UUID tie-break.
- Spent-source invalidation reverses only unspent value and creates an internal
  future reward offset for the spent portion. Recovery precedes spendable coupon
  issuance from the next mature chronological group, preserving all five links.
- Genuine return records preserve allocated sale/coupon evidence. They do not
  execute cash refunds or restore coupon balances while O8 policy is unresolved.
- Separate client/server gates remain OFF by default. Physical two-device proof,
  provider funding, classification policy approval, settlement and rollout stay open.

## Verification plan

Fresh native PostgreSQL and managed local Supabase fixtures; concurrent completion,
approval replay, stale quote, unknown eligibility, cross-user/device denial, exact
net thresholds, reserve cap, partial-spend compensation and no double recovery.
Flutter adapter/widget/navigation/state checks, full tests/analyzer, both debug
builds, inspected UI renders and migration-byte/scope audit before task push.

## Progress

- Integrated baseline and clean isolated worktree verified.
- Audited B quote/return evidence, H0 journal guards, E capacity/issuance/seals,
  existing Customer QR lifecycle, Merchant attestation and purchase evidence UI.
- Dependencies prepared from existing lockfiles; no new dependency planned.
- Delivered migration 0025, exact Customer approval/recovery, Merchant attestation,
  atomic redemption/receivable/earning, source-aware O7 offsets and return evidence.
  The same QR and H0 journal remain authoritative; gates default OFF.
- Fixed a numeric wire-format edge case for decimal catalog prices and tested
  missing/null amounts, replay, stale approval/classification, concurrency, account
  revocation, balance changes, full/partial spent sources and return rounding.
- Full Flutter suite: 2,465 PASS / 0 FAIL / 6 existing SKIP. Focused regressions:
  83 PASS. Analyzer clean. Native PostgreSQL: 94 groups; managed local services:
  92 groups; harness safety: 5 checks, all PASS. Both debug APK builds passed.
- Inspected five Customer/Merchant renders, including narrow text scale, uncertain
  retry and recovery through the actual QR sheet. All 20 historical migration
  hashes match the prior E proof; only 0025 is new.
- Owned validation processes stopped; synthetic fixture data retained. Delivery
  report and source/build fingerprints are in `MERCHANT_CHECKOUT_E_HANDOFF.md`
  and `data/merchant_checkout_e_delivery_validation.json`.
- No Production access, remote migration, provider send, main integration or
  FROZEN product-rule change. Physical two-device and external policy gates remain.
- Final staging found an extra SQL EOF blank line; it was removed and both DB
  suites rerun against the exact final bytes. Docker's default address pool was
  exhausted by retained networks; only two verified empty networks from this
  task's earlier stopped fixtures were removed. All fixture volumes were retained.

## Integration correction — net eligibility before completion

- Integration rejected 00192eb6 without merging. Confirmed the missing intermediate
  invariant using a new native regression: 500−250 left `checkout_hold` before
  claim although the final purchase correctly earned nothing.
- Preserved migrations through 0025. Added forward 0026: release capacity/fund
  atomically at approval, prevent gross-value reacquisition while consent is live,
  preserve the fixed attempt deadline and repair earlier ineligible live holds.
- Expanded acceptance with seven SQL groups and one real HTTP group, observing
  approval, claim, retry, recovery, cancellation, last-slot competition, rollback,
  policy boundary and expired-package fund destination before completion.
- The synthetic prior-version repair check also caught an Auth-context assumption
  in the first repair helper. The final helper reads private QR deadlines directly
  and works for the migration owner without impersonating a customer.
- No Flutter runtime or UI/dependency changes; prior builds/renders are reused only
  after checking their inputs are unchanged. New final validation supersedes the
  original delivery's incomplete capacity proof; external release gates stay open.
- Final results: full Flutter 2,465 PASS / 0 FAIL / 6 existing SKIP; final migration
  contracts 18 PASS; analyzer clean; native PostgreSQL 101 groups PASS; managed
  local services 100 groups PASS; harness safety 5 PASS. All 21 prior migration
  byte hashes and unchanged Flutter/build/render inputs verified. Owned local
  validation processes stopped; no Production operation or main integration.
