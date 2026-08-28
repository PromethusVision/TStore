# Advertising Merchant Eligibility Model

**State:** PROPOSED FAIL-CLOSED MODEL — NO ROLE OR VERIFICATION IMPLEMENTATION

## Independent eligibility layers

Merchant advertising eligibility is not an Auth role, reputation badge or merchant
sector. It is a server-authoritative decision assembled from current evidence.

| Layer | Minimum candidate requirement |
|---|---|
| Merchant principal | Active, authorized owner; no severe suspension/abuse block |
| Shop | Active real physical shop; valid location and ownership |
| Listing | Active eligible listing for exact advertised product/variant |
| Product policy | Advertising allowed for exact SKU/claim/creative context |
| Merchant policy | Required sector/activity verification valid where applicable |
| Campaign | Active approved revision, schedule, targeting and disclosure valid |
| Funding | Budget/cap available under future billing contract |
| Quality/integrity | No current bait, fake-listing or invalid-traffic block |

All layers are rechecked at serve time. Passing onboarding once is insufficient.

## Explicit non-equivalences

- Customer-visible verification badge != advertising eligibility.
- High review score != permission to advertise.
- Merchant-sector selection != licence or product authorization.
- Campaign payment != active shop/listing proof.
- New merchant != low quality by definition.
- Existing advertiser != permanent eligibility.

## Decision outcomes

- `ELIGIBLE`: current scope may serve under campaign/listing gates;
- `PENDING_REVIEW`: no serve until evidence review completes;
- `TEMPORARILY_INELIGIBLE`: recoverable shop/listing/budget/quality issue;
- `POLICY_BLOCKED`: exact reason and review/appeal path where allowed;
- `SUSPENDED_ABUSE`: security-sensitive investigation state;
- `UNKNOWN`: fail closed.

## Changes

Shop relocation, owner change, sector/activity change, evidence expiry, severe
complaint, policy update or product recall triggers re-evaluation. Historical ads
remain auditable but do not keep eligibility alive.

`MERCHANT_SELF_GRANTS_AD_ELIGIBILITY: NO`

`BADGE_EQUALS_AD_ELIGIBILITY: NO`

`SERVE_TIME_RECHECK: REQUIRED`
