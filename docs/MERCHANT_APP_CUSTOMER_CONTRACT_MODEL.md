# Merchant App / Customer App Contract Model

Status: **PROPOSED — NO SCHEMA/API IMPLEMENTATION**
Wave: 17 / WP73

## Shared authoritative concepts

| Concept | Customer App reads/creates | Merchant App reads/updates |
|---|---|---|
| Canonical product | Reads eligible identity/taxonomy/facts | Searches/selects; correction candidate only |
| Variant | Reads eligible buyable choice | Selects/requests governed variant |
| Shop listing | Reads price/availability/sell unit | Own shop listing mutation |
| Shop/location | Reads customer-visible profile/state | Own authorized shop mutation |
| Customer QR session | Creates short-lived opaque session | Validates/confirms at bound shop |
| Verified transaction/item | Reads own evidence/status | Sees minimized confirmation/history scope |
| Review/rating | Customer creates under evidence contract | Reads/reports; no edit/delete |

## Projection rules

- Customer never receives merchant-private SKU, staff, audit, policy evidence or internal stock notes.
- Merchant never receives unnecessary customer identity, history or review entitlement internals.
- Both apps use durable product ID and immutable verified item snapshot.
- Listing becomes customer-available only when product, variant, listing and shop are all eligible.
- Price/availability freshness and update propagation are explicit.

## Frozen QR/review contract

QR remains server-authoritative; expiry, shop binding, replay and concurrency cannot be relaxed by either client. Verified evidence—not a client boolean—unlocks the one-active-review-per-customer+canonical-product lifetime rule.
