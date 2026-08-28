# EsnaftaVar Reward Event Boundary

**State:** `PLACEHOLDER BOUNDARY — REWARD FOUNDATION SOURCE UNAVAILABLE`

The requested Reward/Gamification source branch has no usable committed contract.
Therefore this document defines only safety invariants and does not invent earn,
expiry, redemption, funding or balance policy.

- Generic analytics, clicks, views, cart actions, QR rendering/scanning and ad
  interactions cannot award value.
- A future reward ledger needs server-authoritative, idempotent award/reversal/
  redemption entries with stable account, policy version and source event lineage.
- `verified_purchase_created` may be an eligibility input only after owner policy;
  replaying or reprojecting it cannot duplicate a ledger entry.
- Ledger balance is derived from ledger facts, never reconstructed from analytics
  retention or dashboard aggregates.
- Ad spend/exposure cannot manufacture reward eligibility.
- Customer-facing progress and notifications are projections, not ledger authority.

Open owner decisions include eligible behaviors, reward unit/value, caps, expiry,
reversal, abuse handling, accounting/funding, consent and retention. Runtime design
must wait for the missing canonical source or a future explicit owner decision.

`REWARD_LEDGER_FROM_ANALYTICS: FORBIDDEN`

