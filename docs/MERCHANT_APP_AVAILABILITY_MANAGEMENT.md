# Merchant App Availability Management

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP20

## Proposed semantics

| State | Meaning | Customer implication |
|---|---|---|
| IN_STOCK | Merchant states item is currently available | Visible as available with freshness caveat |
| OUT_OF_STOCK | Merchant knows no sellable stock is available | Not presented as available |
| UNKNOWN | Merchant does not assert stock knowledge | Discoverable only with explicit unknown semantics if product decision allows |
| TEMPORARILY_UNAVAILABLE | Offer paused for a temporary operational reason | Not actionable as available |
| RETIRED | Merchant ended local offer | Historical reference only |

## V1 recommendation

Do not require exact stock counts. Use explicit availability plus `updated_at` freshness and one-tap in/out update. This reflects local shop reality without false real-time inventory promises.

## Rules

- Product, variant, listing and shop eligibility all apply; listing state cannot override upstream block.
- Scheduled auto-expiry/reminder for stale `IN_STOCK` is an owner decision.
- Bulk availability is shop-scoped, previewed and idempotent.
- Customer-facing wording distinguishes unknown from in stock.
- Reopening shop does not automatically reactivate every listing.

