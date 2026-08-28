# Customer App Deleted and Inactive Entity Audit

Status: PASS

| Stale entity | Customer behavior |
| --- | --- |
| Product ID missing | Card/search/Wishlist refuses invalid details navigation. |
| Product deleted after Wishlist/recent view | Missing enrichment row is hidden; remaining content stays usable. |
| Inactive product | Public queries/state filters are authoritative; unavailable actions do not create QR. |
| Shop missing/inactive | Seller/Nearby/search filters it; delayed open returns safe warning. |
| Listing missing/inactive/unavailable | Seller/Cart refresh marks it unavailable; QR preparation stops. |
| Category missing/inactive | Invalid search/category target is hidden; empty category is explicit. |
| Notification target deleted | Metadata validation/fallback preserves notification list. |
| Purchase shop missing | Purchase stays visible; shop-open action reports safe unavailability. |
| Review deleted concurrently | Canonical RPC failure refreshes eligibility/list rather than trusting local ID. |

The client cannot guarantee freshness between every read and tap; backend RLS/RPC/state constraints remain authoritative. Audited actions fail closed without crashing or creating a different entity.

`STALE_ENTITY_AUDIT: PASS`  
`UNSAFE_STALE_WRITE_FOUND: NO`
