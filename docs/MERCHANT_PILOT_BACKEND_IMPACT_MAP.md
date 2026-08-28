# Merchant Pilot Backend Impact Map

State: `FORECAST ONLY — NO DB/RPC CHANGE`

## Current static evidence

- `shops.owner_user_id` is unique when non-null; current RLS checks auth user plus profile role.
- `shop_products` carries price, boolean `is_available`, active state and shop/product references.
- QR migrations expose server functions for preview and confirm, owner/shop checks, immutable session item prices and verified transaction item snapshots.
- Current QR client already rejects session switch, stale async results, duplicate confirm and reconciles uncertain completion.

## Required future capabilities

| Need | Current seam | Forecast |
|---|---|---|
| Shop-scoped authority | owner_user_id + global role | additive membership/capability projection or hardened single-owner RPC; exact user/shop check |
| Shop lifecycle/policy | is_active | verified/suspended/policy state with fail-closed server predicate |
| Listing truth | price + bool availability | availability state, freshness, revision, source and audit |
| Safe listing writes | direct table RLS | scoped idempotent RPC or equivalent server command with expected revision |
| Catalog candidate | no pilot contract | candidate state machine with provenance/reviewer separation |
| QR authority | owner_user_id + role in RPC | membership/capability predicate and current shop/policy state |
| QR history | transaction tables | PII-minimized merchant projection by exact shop |
| Corrections | immutable history | append-only correction/case relationship, no delete/update shortcut |
| Support/audit | fragmented errors | correlation-safe event/case projections |

## Migration forecast

Likely additive schema/RPC work exists, but exact DDL is deferred. Do not rewrite applied migrations. Future migration must be Development-first, reversible where practical, N/N-1 compatible and tested against existing Customer App. Backfill owner memberships must be evidence-based; `owner_user_id = NULL` cannot auto-grant.

## Production dependencies

- Owner-approved capability and cohort policy.
- Development migration/RLS/RPC contract tests including real concurrency.
- Pilot merchants/shops verified and allowlisted.
- Exact signed artifact, remote config and support/monitoring readiness.
- Explicit Production migration/release authorization; never unattended.
