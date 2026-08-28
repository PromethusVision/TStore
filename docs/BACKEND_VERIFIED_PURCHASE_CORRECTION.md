# Backend Verified Purchase Correction

**State:** PROPOSED RESTRICTED OPS CONTRACT — NO MUTATION

Verified purchase history may need correction for proven duplicate projection,
integrity defect, fraud/collusion, policy void or link repair. It must never be
silently edited or hard-deleted to satisfy a dispute.

## Required path

1. restricted operations case with exact subject and evidence;
2. impact preview across reviews, ratings, rewards, reputation, ads and analytics;
3. fresh operator authorization, capability and second-review/compensating control;
4. append a versioned `DISPUTED`, `VOIDED`, `INVALIDATED` or `SUPERSEDED`
   correction fact with stable reason;
5. deterministic projection reversal/recalculation;
6. communication/appeal and reconciliation audit.

Original customer/shop/items/price/timestamps remain restricted but interpretable.
Correction cannot mark an unconfirmed QR as verified, invent a payment or transfer
review rights to an arbitrary product child.

Exact correction classes, review display impact and reward recovery are
`OWNER_DECISION_REQUIRED` with policy/legal review where applicable.

