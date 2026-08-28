# Evaluation and Badge Event/Idempotency Model

**State:** CONCEPTUAL EVENT CONTRACT — NO BACKEND IMPLEMENTATION

## Event chain

```text
VerifiedPurchaseConfirmed
  → UnifiedEvaluationSubmitted
    → ProductReviewCreatedOrEdited
    → ShopEvaluationRecorded
      → EffectiveContributionRecomputed
        → DimensionAggregateRecomputed
          → BadgeEligibilityEvaluated
```

Each derived event carries source ID, shop, customer subject, policy/question/algorithm version,
event time and an idempotency key. Retries must yield the same terminal result.

## Required invariants

- One submission cannot create duplicate product reviews or duplicate effective shop contributions.
- Product and shop section success/failure are independently observable.
- Out-of-order corrections rebuild projections from authoritative state.
- Badge state changes reference the aggregate/evidence version that caused them.
- Analytics consumes approved server facts and never becomes badge source truth.
- Historical events are append-only; correction events supersede, not rewrite.

## Concurrency cases

Duplicate taps, offline retry, two devices, simultaneous edit/delete and evidence correction require
server-side uniqueness plus transaction/idempotency semantics. Client disabling is UX defense only.

`CLIENT_AUTHORITY_FOR_BADGE: NO`
`IDEMPOTENT_RECOMPUTE: REQUIRED`

