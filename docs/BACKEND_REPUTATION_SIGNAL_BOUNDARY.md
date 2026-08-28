# Backend Reputation Signal Boundary

**State:** PROPOSED FROM WAVE 18 — NO SCORE/BADGE IMPLEMENTATION

Merchant reputation is a governed projection of typed evidence. It is separate
from customer rating, merchant verification, advertising and reward participation.

## Signal quality

- **Strong factual:** current verified identity/policy state, objectively measured
  listing mismatch/correction, upheld abuse/policy decision with appeal.
- **Medium:** eligible rating/count with sample context, verified-purchase history
  as activity not quality, measurable availability accuracy.
- **Weak:** profile completeness, tenure, views/directions, undefined response time.
- **Unsafe:** ad spend/impressions, reward funding, merchant sector, listing volume,
  raw scans or self-reported superlatives.

## Contract

Each signal stores source event/fact, subject (prefer exact shop), evidence grade,
window, rule version, integrity/appeal state and idempotency identity. Derived badge
or projection is explainable and rebuildable. Revocation/correction preserves
history.

Actual eligible customer rating/count remains independently visible; reputation
cannot hide, edit or outweigh bad ratings. Cold-start shows insufficient history,
not an untrusted score. Weights, public badges, shop-vs-organization roll-up and
decay remain `OWNER_DECISION_REQUIRED`.

