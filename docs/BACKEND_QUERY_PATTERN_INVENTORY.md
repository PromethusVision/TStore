# Backend Query Pattern Inventory

**State:** CURRENT REPOSITORY AUDIT + FUTURE CANDIDATES

## Current critical reads

| Domain | Current pattern | Ordering/filter expectation | Risk |
|---|---|---|---|
| Home/catalog | Active/featured products, categories, banners | stable sort/name/time + active filters | broad selects and separate enrichment |
| Product details | one product then shop listings/shops | product/listing IDs, active listing, price | N+1 shop enrichment |
| Seller comparison | listings by canonical product | active/available, deterministic price/shop tie-break | wrong shop/listing join |
| Shop details | shop then listings/products | shop scope, active states | N+1 product enrichment |
| Nearby | active shops with coordinates | bounded area/distance + stable tie-break | client-side overfetch |
| Wishlist | customer rows joined/enriched by product | user + created/id cursor | private overfetch |
| Cart V2 | active customer cart and items/listings | one active cart, item/listing identity | several sequential mutations/reads |
| QR | session status and verification RPC projection | exact session/shop, terminal state | polling load/token leakage |
| Purchases | customer verified transactions/items | confirmed time + ID cursor | nested payload growth |
| Reviews | RPC aggregate/list/eligibility | rating/created/id cursor, evidence | aggregate/list consistency |
| Chat | participant messages and conversation summary RPC | created/id cursor | dual sender/receiver query and unread count |
| Notifications | customer feed/unread mutations | created/id cursor | offset drift with Realtime |
| Profile/location | own row(s) | owner + default/created | cross-user isolation |

## Future critical reads

- merchant shop/listing work queues and exact-shop dashboards;
- organization membership/capability resolution;
- product candidate/dedup and merge/split impact preview;
- campaign target eligibility and budget state;
- reward ledger/balance and reputation evidence projections;
- operations case queue/audit history;
- event/outbox delivery/reconciliation and migration progress.

Each query needs owner, cardinality assumption, selected fields, order, pagination,
freshness, authorization, expected index evidence and a slow-query threshold.
Current generic Supabase helpers do not justify selecting `*` on growing/private
tables.

