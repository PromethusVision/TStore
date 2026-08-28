# Sponsored Advertising Analytics Identity Model

**State:** CONCEPTUAL STABLE-IDENTITY CONTRACT — NO ANALYTICS IMPLEMENTATION

## Stable dimensions

Every ad fact references immutable opaque IDs where applicable:

- campaign and campaign revision;
- sponsored target and target revision;
- merchant organization/principal;
- physical shop/branch;
- shop listing;
- canonical product and variant;
- Product Taxonomy stable node plus taxonomy version for targeting context;
- merchant-sector stable ID plus proposal/final state only when used contextually;
- surface/placement/creative/disclosure version;
- event and attribution-model version.

Mutable display names, slugs, paths, titles, merchant SKUs and query text are not
identity keys.

## Historical semantics

- Product/taxonomy rename keeps historical identity; current display can resolve
  separately.
- Move preserves ID when semantic identity remains.
- Merge maps predecessors to successor while reports retain event-time ID/revision.
- Split never assigns old facts to one arbitrary successor; retain predecessor or
  explicit reclassification.
- Listing retirement/shop inactivity does not erase served-event history.
- Campaign setting edit creates a revision; reports can use event-time and current
  views explicitly.

## Metric grain

Ad delivery facts should have one documented grain—typically qualified event per
campaign-target-placement decision—not mixed with Product or Merchant Analytics.
Deduplicated counts, invalid status, attribution and billing classification are
separate derived facts.

## Privacy

Customer identity is not a universal analytics dimension. Use aggregated or
pseudonymous short-lived context where possible, minimum thresholds and restricted
access. Exact location/query histories are not retained merely for convenient
segmentation.

`MUTABLE_NAME_AS_AD_ANALYTICS_ID: NO`

`CAMPAIGN_REVISION_EVENT_TIME: REQUIRED`

`ANALYTICS_IDENTITY_MODEL: READY_FOR_OWNER_REVIEW`
