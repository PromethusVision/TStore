# E earning cycle — local implementation

Baseline: integrated H0 `b022f5f3`; branch `agent/merchant-reward-e`.
Authority: Product Owner requested the next, large implementation package after
H0 integration PASS. Canonical §§5, 8–9 and slice E govern this work.

## Audit and scope

H0 supplies immutable accounting but no capacity/business authority. B supplies
real Auth, one QR/claim, exact undiscounted quote terms, immutable purchase/return
evidence and an atomic commerce outbox. The existing RewardRepository remains a
presentation shell. Merchant has no package/acceptance screen.

Deliver the earning lifecycle as one package: trusted local funding attestation,
100-slot package and expiry accounting, reserve-first package payment allocation,
effective coupon-acceptance lock, fixed-attempt reservation/reacquisition, existing
QR checkout holds, explicit merchant confirmation of the unchanged actual sale,
one contribution per purchase, chronological five-source coupon materialization,
return/invalidation compensation, owner/customer projections and app bindings.

No retroactive earning for legacy/B-only purchases. E-enabled QR uses a companion
on the existing QR UUID and requires explicit merchant confirmation that the
unchanged quote is the actual sale, with EV coupon zero. Old completion endpoints
cannot bypass that confirmation. Discounted final-sale amendments and customer
coupon-spend approval require the next complete checkout extension; neither is
implied by this earning-only implementation.

Real provider purchase, remote activation, coupon redemption/partially spent
offset recovery, Ads, settlement and physical acceptance remain gated. Internal
funding attestation is operator-only with exact amount/consent evidence; the app
cannot fabricate a paid package. No new money wallet or notification system.

## Engineering contracts

- One server attempt per cart; automatic calls never renew its 30-minute deadline.
  Explicit user retry is needed after expiry. Cart changes recompute eligibility;
  same-attempt reacquisition retains the deadline. One live user reservation/hold.
- Checkout retains the original package, including short holds across its expiry.
  Capacity/fund bookkeeping is atomic with purchase evidence and compensation.
- V1 uses a short database serialization epoch for reward mutations, after any
  owned cart lock and before package/account locks. No network work is done while
  holding it. Repeatable-read stale snapshots abort; throughput needs rollout
  load testing before activation. Money remains in the H0 journal.
- Contributions and compensation are append-only. Unissued allocation is rebuilt
  chronologically; issued five-source allocation is immutable. Maturity is max
  of policy minimum and snapshotted voluntary return duration.
- Normal pre-maturity threshold loss reverses capacity/fund; ordinary post-maturity
  return retains reward. Fraud invalidation removes unspent value with evidence.
  Spend remains disabled, so partial-spend offset policy is not silently invented.
- New capabilities and both app bindings default OFF. Existing B/C/D/F/H0 tests
  run alongside new actual PostgreSQL, Auth/HTTP, Dart/widget and build checks.

## Delivery gates

No Production access/write/apply or main merge. External finance/legal/refund,
provider, redemption consent/classification and physical-device approval remain
explicit gates. Implementation outcomes and final evidence will be appended here.

## Outcome

The bounded earning lifecycle is implemented. Final delivery, architecture,
validation evidence, reproduction and remaining E/rollout gates are recorded in
`MERCHANT_REWARD_E_HANDOFF.md`. There is no main integration or Production action.

The original H0/B/C/D/F regressions run with 0024 installed. During audit, fixed
below-threshold checkout release, guarded session changes between capability and
QR mutation, replaced misleading load/error zeros, and ensured same-customer
relogin resumes a new read without publishing old results. Added actual contention,
expiry, funding-source, unspent compensation and account-erasure proofs.
