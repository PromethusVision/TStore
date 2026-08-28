# Backend Failure Registry

**State:** DEDUPLICATED DESIGN FAILURE MODES — NO LIVE FAILURES CLAIMED

Stress rows validate expected handling; this registry names the root condition that
would become a product/security failure if the required control were absent.

| FAILURE_ID | Priority | Root failure | Affected domains | Required invariant |
|---|---:|---|---|---|
| BF-P0-01 | P0 | Cross-customer IDOR | profile/cart/purchase/chat/notification | subject-derived ownership and non-enumerating denial |
| BF-P0-02 | P0 | Cross-shop or revoked-staff mutation | listing/QR/chat/dashboard | active membership + exact shop + capability |
| BF-P0-03 | P0 | Client role/service-credential escalation | Auth/all private data | DB role guard and server-only credentials |
| BF-P0-04 | P0 | Duplicate/replayed QR creates multiple purchases | QR/purchase/review/reward | atomic consume and source-session uniqueness |
| BF-P0-05 | P0 | Non-authoritative fact creates review/reward/reputation | review/reward/reputation/analytics/ads | evidence authority and independent evaluators |
| BF-P0-06 | P0 | Product merge/split corrupts history | catalog/listing/purchase/review | immutable lineage and unresolved ambiguity |
| BF-P0-07 | P0 | Unsafe generic privileged RPC/operator action | ops/catalog/purchase/policy | case capability policy revision and audit |
| BF-P0-08 | P0 | Destructive migration or partial backfill | all clients/data | additive phases reconciliation and stop gates |
| BF-P1-01 | P1 | Lost update from stale listing/membership/review | merchant/customer | expected revision and conflict response |
| BF-P1-02 | P1 | Retry duplicates a mutation/event | RPC/outbox/notification/chat | scoped idempotency and consumer dedup |
| BF-P1-03 | P1 | Public/private projection leaks fields | discovery/dashboard/media | field allowlist and data classification |
| BF-P1-04 | P1 | Realtime/user-switch leaks old subject | chat/notification/merchant | reauthorization and session generation reset |
| BF-P1-05 | P1 | Precise location/content enters analytics/logs | nearby/chat/events | collection minimization and redaction |
| BF-P1-06 | P1 | Demo/test data affects trust/business metrics | catalog/QR/reward/ads/analytics | environment + demo dimension exclusion |
| BF-P1-07 | P1 | Search/listing projection serves stale blocked data | search/ads/discovery | authoritative eligibility recheck and freshness |
| BF-P1-08 | P1 | Account deletion erases needed evidence or leaves private residual | Auth/customer/history/Storage | purpose-specific deletion and reconciliation |
| BF-P2-01 | P2 | Offset pagination duplicates/skips feed rows | chat/reviews/notifications | stable keyset cursor and ID dedup |
| BF-P2-02 | P2 | Broad query/N+1 creates cost/latency | catalog/shop/dashboard | measured projections and indexes |
| BF-P2-03 | P2 | Client sees internal/security details | all APIs | stable safe error taxonomy |
| BF-P3-01 | P3 | Optional telemetry/notification delayed | analytics/UX | eventual retry/freshness without domain rollback |

No P0 is accepted as pilot debt. P1 requires mitigation/test before the affected
feature launches. P2/P3 may be scheduled with explicit bounds and monitoring.

