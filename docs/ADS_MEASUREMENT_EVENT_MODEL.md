# Sponsored Advertising Measurement Event Model

**State:** CONCEPTUAL METRICS — NO TRACKING IMPLEMENTATION

## Measurement separation

- **Ad measurement:** delivery and interaction with a sponsored placement.
- **Product analytics:** discovery/use of canonical product and listing regardless
  of paid status.
- **Merchant analytics:** shop/catalog/customer activity independent of campaigns.

One physical action may emit linked domain events, but their IDs, purposes and
definitions remain separate.

## Candidate ad events

| Event | Qualification | Billing posture |
|---|---|---|
| `AD_DECISION` | Candidate evaluated with outcome/reason | Never billable |
| `AD_IMPRESSION` | Sponsored unit rendered | Shadow/raw; not enough alone |
| `AD_QUALIFIED_IMPRESSION` | Label and meaningful card area visible under approved rule | Candidate only; exact rule TBD |
| `AD_OPEN` | Customer intentionally opens sponsored product/listing | Candidate click metric; not sale |
| `AD_SHOP_OPEN` | Customer opens advertiser shop from ad path | Reporting signal |
| `AD_DIRECTIONS` | Customer invokes directions from attributable context | Intent signal, not proven visit |
| `AD_PHONE_ACTION` | Customer invokes call action | Sensitive intent; legal/privacy review |
| `AD_HIDE` | Customer hides placement | Quality signal |
| `AD_REPORT` | Customer reports ad | Safety/review signal |
| `AD_VERIFIED_PURCHASE_OBSERVED` | Independent verified purchase later matches attribution rule | Reporting only candidate; not causal proof |

Wishlist is a product/customer behavior event and should not be added to ad
measurement unless an explicit purpose/consent/owner decision exists.

## Event invariants

- globally unique idempotency/event ID;
- immutable campaign/target/revision/listing/shop/product/variant IDs;
- surface, placement and disclosure variant;
- event/client/server time and freshness/provenance;
- attribution eligibility separate from raw occurrence;
- invalid-traffic status can change without deleting raw audit evidence;
- no mutable name/slug as identity;
- data minimization and retention class.

## Reporting cautions

Do not label directions, phone actions, shop opens or inferred visits as sales. A
verified purchase after an ad is an observed attributed signal under a declared
window/model, not proof that the ad caused the purchase.

`AD_MEASUREMENT_MODEL: READY_FOR_OWNER_REVIEW`

`OFFLINE_ACTION_AUTOMATICALLY_BILLABLE: NO`

`TRACKING_IMPLEMENTED: NO`
