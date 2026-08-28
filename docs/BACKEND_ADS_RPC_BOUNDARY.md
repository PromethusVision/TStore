# Backend Ads RPC Boundary

**State:** PROPOSED FROM ADS FOUNDATION — NO ADS IMPLEMENTATION

Ads commands may create/revise/pause/resume/end a campaign, manage eligible
listing targets and retrieve scoped reporting. They must validate merchant/shop/
listing authority, target eligibility, schedule, budget policy, campaign revision
and idempotency.

The ads boundary cannot:

- mutate canonical product/listing truth to make a target eligible;
- create QR verification, purchase, review, reward or reputation evidence;
- hide organic results or customer ratings;
- declare inferred directions/clicks as sales;
- accept client-calculated spend as authoritative.

Material edits create campaign/target revisions and may require re-review. Billing
or budget ledger transactions need a separate approved economic contract. V1
campaign command set, billing event and attribution reporting are
`OWNER_DECISION_REQUIRED`.

