# Merchant App Ads Readiness

Status: **PROPOSED MAPPING — ADS RUNTIME NOT READY**
Wave: 17 / WP116
Source: read-only `origin/agent2/w16-sponsored-advertising-engine-foundation@29582b4f30368febe7f1ac196b12d56c32456bdf`

## Source contract preserved

- Recommended future sponsored object is an eligible **shop listing**, not canonical product price/stock or merchant sector.
- Merchant, shop, listing, product policy, campaign, funding and integrity eligibility are independent and rechecked at serve time.
- Organic candidate order is built independently; ad failure returns normal organic results.
- Paid placement carries persistent exact text `Sponsorlu`; payment cannot buy relevance, policy approval, verification, nearest/cheapest claim or badge.
- Directions/open/click are not visit/sale; verified purchase attribution is not caused-sale proof.

## Merchant App future requirements

Eligibility precheck; owned eligible listing selector; governed geo/context; duration/budget only after billing; immutable sponsored preview; submit/review/status; pause/end; defined metrics/freshness/dispute. Merchant cannot set approval, spend, badge or ranking position.

## Current blockers

Merchant identity/shop ownership, canonical catalog/listing lifecycle, price/availability freshness, ads owner decisions, billing/tax/dispute, policy/fraud operations, privacy measurement and disclosure UI acceptance are not implemented here.

`MERCHANT_APP_READY_FOR_ADS_RUNTIME: NO`

`ADS_IMPLEMENTATION_PERFORMED: NO`
