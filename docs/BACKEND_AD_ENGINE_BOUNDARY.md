# Backend Ad Engine Boundary

**State:** PROPOSED FROM ADS FOUNDATION — NO AD RUNTIME

## Identity and ownership

An ad campaign has immutable campaign ID, merchant organization/shop owner,
versioned listing target, schedule/geo/context, budget envelope, policy decision
and material revision. The preferred target is an existing eligible shop listing
tied to canonical product/variant identity.

## Hard gates

- active merchant membership and exact shop/campaign capability;
- active policy-eligible shop, listing and canonical product;
- truthful current listing price and owner-approved availability freshness;
- material edits create a revision and may require review;
- budget reservation/spend is server-authoritative if later approved;
- every served unit retains target/campaign/disclosure revision.

## Prohibited coupling

Ads cannot modify catalog/listing truth to qualify, alter organic relevance,
create purchase/review/reward evidence, buy reputation/badges, suppress ratings or
claim an inferred action is a sale. An independently verified purchase may be
linked in a privacy-approved reporting projection; attribution is not causality
or billing by default.

Campaign economics, stock posture, attribution and billing event remain
`OWNER_DECISION_REQUIRED`.
