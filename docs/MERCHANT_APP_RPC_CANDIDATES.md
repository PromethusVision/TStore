# Merchant App RPC Candidates

Status: **PROPOSED — NO SQL/RPC IMPLEMENTATION**
Wave: 17 / WP79

| Candidate | Why transactional/server-authoritative | Idempotency/revision |
|---|---|---|
| validate_merchant_qr_context | Minimized context + shop/actor/policy validation | Read-only token fingerprint |
| confirm_physical_purchase | Atomic token consume + verified transaction/items | Token + request ID |
| create_shop_listing | Enforce canonical/variant eligibility and uniqueness | Request ID + unique scope |
| update_listing_price | Authorization, validation, audit, conflict | Expected revision + request ID |
| update_listing_availability | State/freshness/audit | Expected revision + request ID |
| bulk_update_availability | Scoped preflight and per-row result | Batch/request IDs |
| submit_catalog_candidate | Duplicate/policy gates and provenance | Fingerprint + request ID |
| update_shop_profile | Field policy, location/status revision | Expected revision |
| invite_or_revoke_staff | Owner guard and least privilege | Membership/invite identity |
| report_customer_review | Scope, reason and duplicate-report rules | Review + merchant + request ID |

## Rule

RPC is not automatically safer: caller auth, resource scope, field allowlist, search path/security-definer behavior, grants, audit and tests must be explicit. Generic JSON mutation or client-selected actor/shop ownership is forbidden.
