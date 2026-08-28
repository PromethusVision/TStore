# Merchant Advertising Reporting Requirements

**State:** PROPOSED METRIC CONTRACT — NO DASHBOARD OR ANALYTICS RUNTIME

## Reportable metrics

| Metric | Definition requirement | Must not be presented as |
|---|---|---|
| Eligible opportunities | Contexts where campaign could enter hard gates | Impression guarantee |
| Impressions | Sponsored unit rendered | Qualified view by default |
| Qualified impressions | Label/card met owner-approved visibility rule | Unique customer unless deduped |
| Sponsored opens/clicks | Intentional open from ad | Visit or sale |
| Shop opens | Shop page opened from attributable ad path | Physical visit |
| Directions | Directions action invoked | Arrival/purchase |
| Phone actions | Call action invoked | Completed call/sale |
| Spend/reserved/credited | Future billing ledger states | Revenue or ROI |
| Invalid traffic | Excluded/held events under model | Named customer/fraud accusation |
| Verified purchase signal | Independent valid purchase after modelled interaction | Ad-caused sale |

## Required dimensions

Campaign/target/listing/shop/product, surface/placement, date/time zone, current
campaign revision and attribution model. Product and Merchant Analytics remain
separate; mutable names are labels only.

## Presentation requirements

- metric glossary and calculation/model version;
- freshness/as-of timestamp;
- raw versus qualified versus invalid distinction;
- attributed versus unattributed and click-through versus view-through separation;
- minimum sample/privacy suppression;
- no guaranteed reach, conversion, visit, revenue or ROI;
- spend/credit/dispute reconciliation where billing later exists;
- downloadable data/access owner remains an owner/privacy/security decision.

## Low-data behavior

Show `insufficient data` rather than unstable rates. Zero qualified delivery is
distinguished from measurement outage. Campaign comparisons do not hide policy or
eligibility differences.

`MERCHANT_AD_REPORTING: READY_FOR_OWNER_REVIEW`

`DIRECTIONS_EQUALS_VISIT: NO`

`VERIFIED_PURCHASE_EQUALS_CAUSED_SALE: NO`
