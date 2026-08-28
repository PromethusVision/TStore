# Backend Current State Audit

**State:** REPOSITORY-EVIDENCED BASELINE — DESIGN ONLY  
**Wave:** 21 / Workstream A  
**Base:** `origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63`

## Scope and evidence

This audit describes the backend contracts present in canonical migrations
`0001`–`0009` and the Flutter call sites that those migrations support. It does
not inspect a remote Supabase project and does not claim that any remote schema
matches this repository.

Classification:

- **ACTIVE:** canonical repository contract used by the Customer App or required
  by its supported backend behavior.
- **LEGACY:** retained compatibility surface that must not be treated as the
  preferred future contract.
- **UNCLEAR:** present, but ownership or future use requires evidence before
  extension.
- **FUTURE_CANDIDATE:** not implemented; a later design may add it without
  replacing a working Customer App contract.

## Migration inventory

| Migration | Main responsibility | Classification |
|---|---|---|
| `0001_initial_schema.sql` | Core customer, catalog, legacy order, review, banner and profile model | ACTIVE with named legacy areas |
| `0002_chat_and_notifications.sql` | Direct customer chat and in-app notifications | ACTIVE |
| `0003_customer_profile_and_address_rls.sql` | Customer profile/address hardening and saved locations | ACTIVE |
| `0004_marketplace_cart_qr_ratings.sql` | Shop listings, Cart V2, QR sessions, verified transactions and shop ratings | ACTIVE |
| `0005_customer_legal_and_account_delete.sql` | Canonical legal consent and customer self-deletion | ACTIVE |
| `0006_customer_saved_location_contract.sql` | Saved-location RPC contract | ACTIVE |
| `0007_realtime_and_media_contract.sql` | Managed Realtime publication and storage contract checks | ACTIVE |
| `0008_profile_role_guard.sql` | Database-enforced client role-escalation guard | ACTIVE |
| `0009_verified_review_and_storage_contract.sql` | Durable product evidence for purchases/reviews and canonical media buckets | ACTIVE |

The chain contains 23 canonical `public` tables. No application view is part of
the canonical chain. A future migration must append to the chain; rewriting
these migrations or treating a ledger entry as proof of remote state is outside
this foundation.

## Tables and ownership

| Domain | Tables | Current owner/source of truth | Classification |
|---|---|---|---|
| Identity | `profiles`, `legal_consents` | Auth user plus server triggers/RLS; customer may edit allowed profile fields | ACTIVE |
| Catalog | `categories`, `brands`, `products` | Canonical database rows; public reads limited to active content | ACTIVE |
| Customer private data | `addresses`, `customer_saved_locations`, `wishlist` | Authenticated customer | ACTIVE |
| Legacy commerce | `orders`, `order_items` | Customer-scoped historical compatibility model | LEGACY; not verified-purchase evidence |
| Reviews | `reviews` | Customer through verified-evidence RPCs; aggregate maintained server-side | ACTIVE |
| Discovery | `banners` | Platform-managed content | ACTIVE; write authority is not a client contract |
| Communication | `chat_messages`, `notifications` | Message participants / notification recipient | ACTIVE, direct-party V1 model |
| Marketplace | `shops`, `shop_products` | Shop owner for allowed listing fields; public active reads | ACTIVE; direct owner model is future bridge |
| Cart V2 | `carts`, `cart_items_v2` | Authenticated customer, single-shop invariant | ACTIVE |
| QR | `qr_sessions`, `qr_session_items` | Customer issuance; server validation/consumption | ACTIVE |
| Purchase evidence | `verified_transactions`, `verified_transaction_items` | Server-authoritative QR confirmation | ACTIVE |
| Shop rating | `shop_ratings` | Verified transaction participant through server contract | ACTIVE |

Current `products.price`, `products.sale_price` and stock-like fields are
compatibility fields. The future ownership recommendation that price and
availability belong to the shop listing does not authorize deleting or silently
reinterpreting these columns.

## RPC and function inventory

| Contract family | Repository evidence | Classification |
|---|---|---|
| Auth/profile | `handle_new_user`, timestamp helpers, profile-role escalation guard | ACTIVE |
| Saved locations | create/update/delete/default-location RPCs | ACTIVE |
| Account lifecycle | `delete_current_customer_account` | ACTIVE |
| Chat/notifications | conversation and unread-count reads; notification helper triggers | ACTIVE |
| QR | create, verification read and confirmation RPCs; cancellation/integrity triggers | ACTIVE |
| Shop rating | eligibility/submit and aggregate refresh contracts | ACTIVE |
| Product reviews | read, eligibility, submit/update/delete RPCs and evidence/aggregate triggers | ACTIVE |
| Merchant organization/membership | none | FUTURE_CANDIDATE |
| Variant/candidate/lineage | none | FUTURE_CANDIDATE |
| Ads/reward/reputation/ops/event outbox | none | FUTURE_CANDIDATE |

Security-sensitive multi-row mutations already favor server functions. Direct
table access remains appropriate only where one row, one owner and one policy can
fully express the invariant.

## RLS and grant baseline

- Private customer rows are owner-scoped.
- Public catalog, banner, active shop and active listing reads are allowed by
  bounded policies.
- Merchant writes currently depend on direct shop ownership plus merchant role;
  this is not a future organization/staff authorization model.
- QR and verified-purchase reads are limited to participants. Confirmation is
  server-authoritative and must not be replaced with client writes.
- Review direct insert/update/delete grants and policies were removed in `0009`;
  mutation is through the verified-evidence contract.
- Profile role escalation is blocked in the database. Client metadata and hidden
  UI are not authorization.
- Future operator/admin access is not granted merely because an admin screen
  exists.

## Realtime

`0007` validates the managed Realtime publication and includes
`chat_messages` and `notifications`. Realtime delivery is a projection/transport;
it does not bypass row authorization and is not the source of truth for a write.
No future merchant, reward, ads or operations channel exists today.

## Storage

Canonical buckets are `product-images`, `category-images` and `banner-images`.
The current contract enforces bounded path/media constraints and intentionally
does not grant broad `storage.objects` CRUD to `anon` or `authenticated`.
Storage objects are media, not catalog identity. Signed URLs, object paths and
bucket publicity must not become ownership proof.

## Client-used surfaces

The Customer App relies on public catalog/shop/listing reads, owner-scoped
profile/location/wishlist/cart data, QR creation/status, review contracts,
notifications/chat and canonical media paths. Future work must preserve response
meaning, error classes and stable IDs or introduce an explicit compatibility
adapter and migration window.

## Current gaps, not defects by themselves

- no merchant organization, membership, branch or capability entity;
- no canonical variant or product-candidate/merge/split lineage entity;
- no explicit listing revision or idempotency record;
- no ads campaign, reward ledger, badge/reputation signal or operations case;
- no general event registry/outbox;
- no explicit audit record for every privileged mutation;
- no freshness-grade model for price/availability;
- direct chat parties do not model organization/shop staff assignment.

These are future candidates. Their absence does not invalidate the working
Customer App.

## Non-negotiable baseline

1. Verified purchase remains server-authoritative and QR is not payment.
2. Review eligibility remains tied to durable verified physical-purchase evidence.
3. One active review remains `customer + canonical product`; repeat and quantity
   do not multiply rights.
4. Advertising, analytics, reward and reputation cannot manufacture purchase or
   review evidence.
5. Remote state was not contacted or modified by this audit.

