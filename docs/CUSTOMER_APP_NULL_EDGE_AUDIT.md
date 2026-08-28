# Customer App Null, Empty, and Edge-data Audit

Status: PASS

| Edge | Behavior |
| --- | --- |
| Null/blank customer name, phone, avatar | Profile renders neutral/absent values, not invented identity. |
| Null/broken product/category/banner media | Functional placeholder; action remains available. |
| Empty description/metadata | Optional section omitted or neutral value; no forced placeholder claim. |
| Zero sellers | Explicit no-active-seller state; Cart action unavailable. |
| Zero reviews/rating | Empty aggregate/list state; no fabricated score. |
| Missing/invalid coordinates | Distance omitted; directions falls back to address or safe warning. |
| Deleted/inactive shop/listing | Filtered before customer action; stale action fails safely. |
| Missing category/product/shop ID | Navigation and dependent query blocked. |
| Invalid enum/status/RPC payload | Typed parser or safe failure; QR/review critical parsers are strict. |
| Zero total | Accepted only when the server snapshot itself is valid; malformed totals hide QR. |
| Long/large values | Critical customer cards/forms tested at narrow width and/or large text. |

No deterministic null crash was reproduced. Backend integrity and RLS remain authoritative; the client does not fabricate a replacement entity for a missing record.

`NULL_EDGE_AUDIT: PASS`  
`DETERMINISTIC_NULL_CRASH_FOUND: NO`
