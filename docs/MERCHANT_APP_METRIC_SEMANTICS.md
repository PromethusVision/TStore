# Merchant App Metric Semantics

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP40

## Core definitions

- **Verified physical purchase:** one terminal successful QR confirmation transaction. It is not payment settlement or order revenue.
- **Verified purchase item:** immutable item snapshot attached to a verified transaction; quantity does not multiply review rights.
- **Shop/product view:** an eligible customer exposure after bot/internal-test filtering and agreed dedup window.
- **Direction intent:** customer invoked directions; it does not prove arrival or purchase.
- **Active listing:** listing and all upstream product/variant/shop states are customer-eligible.
- **Stale availability:** current merchant assertion older than an owner-approved freshness threshold; not automatically out of stock.
- **Review/rating:** only canonical eligible reviews/aggregates; merchant cannot rewrite them.

## Zero, missing and delayed

- `0`: measured source is available and no eligible events occurred.
- `NOT_AVAILABLE`: source or contract does not exist.
- `DELAYED`: processing window is incomplete.
- `SUPPRESSED`: privacy threshold prevents display.
- `PARTIAL`: known source coverage gap; never shown as a complete total.

## Language guardrails

Use “doğrulanmış fiziksel alışveriş”, “görüntülenme” and “yol tarifi isteği”. Do not label intent as sales, customers or conversion without a separately approved denominator and evidence chain.
