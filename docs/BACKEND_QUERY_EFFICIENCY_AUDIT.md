# Backend Query Efficiency Audit

**State:** STATIC RISK AUDIT — OPTIMIZE FROM EVIDENCE

## Likely current pressure points

| Pattern | Risk | Future mitigation |
|---|---|---|
| Product list then per-product seller/shop read | N+1 and duplicate joins | bounded relational projection/RPC after measurement |
| Shop then per-listing product enrichment | N+1 | selected joined projection with stable pagination |
| Cart multi-step fetch/mutations | round trips and race windows | preserve transaction invariants; batch only justified transitions |
| Chat conversation enrichment | repeated shop/profile lookup | current summary RPC/cache with field minimization |
| Notification/chat Realtime + pages | duplicate/out-of-order rows | ID/revision reconciliation and keyset cursor |
| Nearby client-side full-shop distance | overfetch and scraping | bounded geo query/read model when data grows |
| Broad `select('*')` helpers | private/large payload drift | explicit column projections per feature |
| Merchant dashboard live aggregation | expensive scans/PII leakage | versioned aggregates with freshness/thresholds |

## Guardrails

Do not replace readable direct queries with RPCs or caches without query-plan,
latency, row-count and payload evidence. Measure p50/p95, scanned/returned rows,
cache hit/staleness and authorization cost. Batch within safe response limits;
avoid giant nested payloads. Index only proven filter/order shapes. A fast query
that leaks cross-shop/customer data is a failure.

Pilot demo cardinality is insufficient proof of future scale, but also insufficient
reason for an external search/cache platform now.

