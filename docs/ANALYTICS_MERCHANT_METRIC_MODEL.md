# EsnaftaVar Merchant Metric Model

**State:** `PROPOSED — DASHBOARD/PRIVACY OWNER REVIEW REQUIRED`

| Metric | Definition | Evidence | Caveat |
|---|---|---|---|
| Verified physical purchases | Distinct server-authoritative verified-purchase IDs for a shop/window | `verified_purchase_created` | Not payment, order or audited revenue |
| Purchase items | Sum of governed verified-purchase item quantities if the canonical fact contains them | Verified purchase facts | Do not infer price/revenue |
| Shop views | Quality-filtered distinct view events for a shop | `shop_opened` | Interest, not visit |
| Product views | Quality-filtered views of products/listings offered by the shop | `product_viewed` | Soft signal; identity/version required |
| Directions intents | Quality-filtered requests for directions to the shop | `directions_requested` | Not arrival or sale |
| Review count/rating | Active eligible review projection | Review lifecycle events | Recompute update/delete; suppress unsafe small cohorts |
| Catalog health | Active, unavailable and stale listing counts | Authoritative listing revisions | Operational inventory health, not demand |
| QR health | Issue/success/failure/replay outcome rates | Dedicated QR events | Security details restricted |

Windows use the shop's recorded timezone: `today` is shop-local; rolling 7/30
complete days exclude the partial current day unless labelled. Late authoritative
events update the relevant prior window and surface freshness time.

Unique-customer, retention, conversion and revenue metrics are excluded until
identity, privacy, session/funnel and financial evidence contracts are approved.
Merchant views show aggregates only—no customer UUID, contact, journey, precise
location or low-count re-identifiable breakdown.

`SOFT_INTENT_LABELED_AS_SALES: NO`

