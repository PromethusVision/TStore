# Verified Purchase Correction Model

**State:** PROPOSED — EXTREMELY SENSITIVE, NO RUNTIME MUTATION

Verified purchase is historical evidence used by reviews, merchant reputation, analytics, and future rewards. It must not be silently edited or deleted.

## Correction classes

- duplicate technical projection while one canonical transaction remains;
- confirmed wrong shop/customer/item due proven integrity defect;
- fraud/collusion determination;
- void/cancellation under an owner-approved O2O rule;
- data-link repair that preserves immutable original snapshot;
- display/projection error without transaction correction.

## Required controls

Case, high-confidence server evidence, exact transaction/version, impact preview, fresh re-authentication, authorized reviewer, second-review candidate, stable reason/policy version, before/after/superseding relationship, derived review/reputation/reward effects, communication/appeal, and reconciliation.

## Corrective pattern

Prefer append-only `VALID`, `DISPUTED`, `VOIDED_BY_POLICY`, `INVALIDATED_FOR_FRAUD`, or `SUPERSEDED` evidence events. Original actor/shop/item/price/timestamps remain restricted but interpretable. Derived projections recalculate deterministically; they are not manually edited.

## Prohibitions

- hard delete to solve support pressure;
- change price/items/shop/customer to fit a claim;
- mark an unconfirmed QR as verified;
- invalidate solely from one party's disagreement;
- transfer review eligibility to an arbitrary split/merged product;
- directly set reputation/reward balances;
- expose fraud reporter/internal evidence unnecessarily.

## Recovery

If an operator mistake occurred, issue a reversal/superseding event and reconcile every consumer. Do not erase the mistaken audit event.

`VERIFIED_HISTORY_SILENT_ERASURE: PROHIBITED`

`CORRECTION_POLICY_FINALIZED: NO`
