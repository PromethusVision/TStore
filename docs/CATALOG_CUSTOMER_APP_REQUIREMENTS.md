# Customer App Catalog Requirements

Status: **OWNER REVIEW DRAFT — NO CLIENT IMPLEMENTATION**
Wave: 16, Work Package 43

| Surface | Catalog behavior |
| --- | --- |
| Search | Return one canonical product group by default; expose matched variant and nearby seller children. |
| Product details | Stable canonical identity, selected variant facts, canonical/variant media and policy-safe shared content. |
| Seller comparison | Listing price, availability/stock knowledge, distance/shop and timestamp; never imply universal price. |
| Variant selection | Change exact variant and its available sellers without creating duplicate product pages. |
| Wishlist | Reference canonical product and optional preferred variant; rename/merge aliases resolve safely. |
| Reviews | One active review per customer+canonical product; only server-verified QR evidence, variant context optional. |
| Cart V2 | Add exact active shop listing/variant; retain single-shop rule and revalidate listing state. |
| QR/history | Display immutable merchant/product/variant/listing and commercial snapshots from the confirmed event. |
| Deep links | Stable product ID; merge redirects to successor, split predecessor never guesses a child. |
| Media | Canonical media first; attributed shop media in seller context; safe existing fallback when absent. |
| Availability | Distinguish available, out of stock, temporarily unavailable and unknown; show observation age. |
| Variable measure | Show unit price, minimum/increment and estimated versus confirmed quantity semantics. |

## Safety and experience rules

- A policy-blocked or retired product/listing cannot become actionable through a stale
  deep link, wishlist or cart.
- Search/result grouping must still allow shop-specific intent and merchant profile
  discovery; grouping cannot erase the local shop.
- Merchant title/photo/claims are labeled and cannot masquerade as canonical facts.
- Product merge/split never silently changes a customer's historical receipt/review.
- No-offer behavior, residual discontinued stock and merge-review collision are open
  owner decisions and must not be guessed by the client.
