# Merchant App Backend Requirements

Status: **PROPOSED — NO MIGRATION/SCHEMA CHANGE**
Wave: 17 / WP78

## Existing conceptual capabilities to preserve

- Auth/profile customer contract and role escalation guard.
- Shop, product and shop-listing reads.
- Short-lived QR session, atomic merchant confirmation and verified transaction/items.
- Durable `product_id` snapshots and review evidence/RPC contract.
- Storage bucket policy separation where applicable.

## Likely new requirements

| Area | Capability |
|---|---|
| Identity | Merchant organization, membership, shop/branch scope, capability grants |
| Onboarding | Draft/review/policy state, evidence references and audit |
| Shop | Authorized profile/location/lifecycle mutation with revision |
| Catalog | Listing writes, candidate/exception queue, barcode lookup, governed fields |
| QR | Merchant-app actor/capability checks and minimized context projection |
| Analytics | Privacy-safe aggregates, freshness and authorized scope |
| Reviews | Merchant read/report; reply only if approved |
| Notifications | Merchant-targeted event projection and deep-link scope |
| Audit | Actor, before/after, reason, request ID and immutable evidence linkage |

## Gates

Canonical catalog and merchant taxonomy proposals are not runtime-ready until owner decisions. Every new backend surface needs RLS/RPC/authorization threat tests; no Flutter server secret.
