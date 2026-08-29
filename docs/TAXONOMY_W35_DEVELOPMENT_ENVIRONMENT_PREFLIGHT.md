# Wave 35A-R — Development Environment Read-Only Preflight

**Date:** 2026-08-29

**Target:** `EsnaftaVar Development`

**Project ref:** `tnipyxnvhgelwdpykyez`

**State:** `PASS — RESUMED UNDER OWNER AUTHORIZATION; READ-ONLY PROFILE COMPLETE`

## Identity and resume gate

Before the authorized resume and again before every database inspection, the
authenticated Dashboard showed both the exact Development name and the exact
project ref. The controlling URL was always under
`/dashboard/project/tnipyxnvhgelwdpykyez`; the separate Production ref was never
opened or queried.

The Product Owner authorized resuming only this Development project so the
previously approved read-only preflight could run. The project was resumed once,
finished restoring, and reached `Healthy`. No data/configuration write followed.

- Resume required/requested: **YES**.
- Resume result: **PASS**.
- Queryable after resume: **YES**.
- Final observed status: **Healthy**.
- Exact resume timestamp: **not recorded by the Dashboard evidence capture**.

The Dashboard's `main / Production` label is the Supabase branch type inside the
verified **EsnaftaVar Development** project. It is not the separate EsnaftaVar
Production project; exact name/ref remained the identity authority.

## Live environment result

| Item | Fresh read-only result |
|---|---|
| Project name/ref | `EsnaftaVar Development` / `tnipyxnvhgelwdpykyez` |
| Project URL | `https://tnipyxnvhgelwdpykyez.supabase.co` |
| Health | `Healthy` after authorized resume |
| Region / compute | Central EU (Frankfurt), `eu-central-1`, nano |
| Postgres version | `17.6` |
| Migration ledger | 9 entries; canonical names `0001`–`0009` |
| Last migration | `0009_verified_product_reviews_storage` |
| Public tables | 23 |
| Public tables with RLS | 23 |
| Public policies | 52 |
| Public functions | 29, including platform `rls_auto_enable()` |
| Public table triggers | 23 distinct triggers; 33 event rows |
| Realtime tables | `chat_messages`, `notifications` |
| Storage | 3 canonical buckets; 0 objects |
| Business/application rows | 0 across all 23 public tables |

The ledger names match the tracked canonical migration chain. Live ledger
version stamps for `0001`–`0008` differ from the current local filename prefixes;
`0009` matches. The inspected schema objects match the canonical outcomes, and
the extra public `rls_auto_enable()` is a known Supabase platform object rather
than an application RPC.

### Exact live migration ledger

| Live version | Name |
|---|---|
| `20260812010907` | `0001_core_auth_catalog` |
| `20260812011047` | `0002_shops` |
| `20260812011128` | `0003_carts_v2` |
| `20260812013109` | `0004_qr_verified_purchases` |
| `20260812013220` | `0005_verified_shop_ratings` |
| `20260812013308` | `0006_chat_notifications_account` |
| `20260812013403` | `0007_storage_realtime` |
| `20260814000820` | `0008_fix_profile_role_guard` |
| `20260815000900` | `0009_verified_product_reviews_storage` |

### Exact public-table row baseline

Each of these 23 tables returned **0** rows:

`profiles`, `legal_consents`, `categories`, `brands`, `products`, `addresses`,
`customer_saved_locations`, `wishlist`, `orders`, `order_items`, `reviews`,
`banners`, `chat_messages`, `notifications`, `shops`, `shop_products`, `carts`,
`cart_items_v2`, `qr_sessions`, `qr_session_items`, `verified_transactions`,
`verified_transaction_items`, and `shop_ratings`.

## Read-only execution ledger

Only single `SELECT` statements and Dashboard metadata pages were used. No
business RPC was called. Reads covered migration history, server version, table
counts, category/product relationships, constraints, indexes, RLS/policies,
function signatures, triggers, Realtime membership, Storage bucket metadata and
backup capability.

- Development project resume: **YES — owner-authorized prerequisite**.
- Development database reads: **YES — SELECT/metadata only**.
- Development data writes: **NO**.
- DDL/migration/RPC/Auth/Storage/Realtime mutation: **NO**.
- Backup/restore execution: **NO**.
- Production access: **NO**.
- Secret/key/token/password exposure: **NO**.

`DEVELOPMENT_RESUME: PASS`

`DEVELOPMENT_TARGET_VERIFIED: PASS`

`LIVE_DATABASE_ACCESS: PASS`

`REMOTE_DATA_WRITES_PERFORMED: NO`

`PRODUCTION_ACCESSED: NO`
