# Sponsored Advertising Attribution Model

**State:** OPTIONS — NO FINAL WINDOW, CAUSAL CLAIM OR BILLING

## Physical-commerce constraint

EsnaftaVar normally cannot observe the full path from ad exposure to store visit and
sale. Attribution is a deterministic reporting convention, not proof of causation.

## Candidate models

| Model | Evidence | Strength | Risk | Proposed posture |
|---|---|---|---|---|
| Last sponsored click/open | Explicit ad open before later action | Relatively clear interaction | Ignores other influences | V1 reporting candidate |
| Sponsored shop open | Shop page opened from ad | Local intent | Not visit/purchase | Supporting metric |
| Directions/phone | Explicit action after ad | Stronger intent | Accidental action/privacy | Supporting metric |
| View-through | Impression without click | Measures awareness | Very weak causal link | Separate/defer |
| Verified physical purchase | Independent server-authoritative transaction | Strong outcome evidence | Can be gamed; purchase may be organic | Reporting-quality signal only |

## Recommended V1 convention

Report direct click-through paths with a clearly published owner-approved window and
model version. Keep view-through separate and disabled/deferred by default. Show
“sponsored interaction followed by …”, not “ad generated sale”. Exact window is TBD;
no numeric duration is finalized here.

## Rules

- immutable event time, campaign revision, target, listing, shop and product IDs;
- deterministic tie-breaking when multiple sponsored interactions exist;
- organic interaction after an ad is recorded, not hidden;
- cross-device/user joining is deferred and cannot be inferred without a lawful
  privacy model;
- location/directions is not a store visit;
- expired/invalid/filtered events are excluded with reason;
- model revisions do not rewrite previously reported facts silently;
- attribution cannot change review eligibility, product identity or billable state
  without a separate owner decision.

`ADS_V1_ATTRIBUTION_CANDIDATE: LAST_DIRECT_SPONSORED_INTERACTION`

`VIEW_THROUGH_V1: DEFER`

`CAUSAL_ROI_CLAIM: NO`
