# Wave 6 Verified Product Review RPC Contract

Status: **FROZEN for Agent 2 client integration**

This document is the client-facing contract installed by canonical migration
`20260815000900_0009_verified_product_reviews_storage.sql`.

## Canonical eligibility rule

A customer is eligible for a product review only when a
`verified_transaction_items` row with that durable `product_id` belongs to a
`verified_transactions` row whose `customer_user_id = auth.uid()`. The evidence
is created only by successful merchant confirmation of a physical-purchase QR.

The following are never evidence: product views, cart rows, QR creation,
legacy `orders`/`order_items`, or a client-provided
`is_verified_purchase = true` value. Quantity and repeat purchases do not
increase review entitlement. The existing unique `(user_id, product_id)`
constraint permits one active review per customer and canonical product.

The server chooses the earliest matching verified transaction item as the
review evidence. Its UUID is immutable after review creation. A customer may
edit or delete their review at any time. After deletion, the customer may
submit again while the durable evidence still exists.

## Exact RPC surface

### `get_product_reviews`

Callable by `anon` and `authenticated`.

Arguments:

```text
p_product_id uuid
p_limit integer = 20       // 1..50
p_offset integer = 0       // >= 0
```

Returns one JSON object:

```json
{
  "product_id": "uuid",
  "average_rating": 4.5,
  "review_count": 2,
  "rating_distribution": {"1": 0, "2": 0, "3": 0, "4": 1, "5": 1},
  "reviews": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "product_id": "uuid",
      "rating": 5,
      "title": "optional text or null",
      "comment": "optional text or null",
      "images": [],
      "is_verified_purchase": true,
      "helpful_count": 0,
      "created_at": "timestamptz",
      "updated_at": "timestamptz",
      "can_edit": false
    }
  ]
}
```

`average_rating`, `review_count`, and `rating_distribution` include only rows
with server evidence. Preserved legacy reviews remain in `reviews`, but return
`is_verified_purchase: false` and do not affect those aggregates. `can_edit` is
true only for the current authenticated owner.

### `get_product_review_eligibility`

Callable by `authenticated` only.

Arguments:

```text
p_product_id uuid
```

Returns one JSON object:

```json
{
  "product_id": "uuid",
  "eligible": true,
  "can_submit": true,
  "existing_review_id": null,
  "verified_transaction_item_id": "uuid or null",
  "verified_transaction_id": "uuid or null",
  "verified_at": "timestamptz or null"
}
```

`eligible` means durable purchase evidence exists. `can_submit` additionally
requires that no active review exists. An existing legacy review is not
silently upgraded; it keeps `existing_review_id` and prevents a second active
review.

### `submit_product_review`

Callable by `authenticated` only.

Arguments:

```text
p_product_id uuid
p_rating integer           // 1..5
p_title text = null
p_comment text = null
```

The RPC derives `user_id`, purchase evidence, and the verified flag on the
server. It never accepts `user_id`, evidence IDs, image paths, or
`is_verified_purchase` from the client.

Returns:

```json
{
  "created": true,
  "review": {
    "id": "uuid",
    "user_id": "uuid",
    "product_id": "uuid",
    "rating": 5,
    "title": "optional text or null",
    "comment": "optional text or null",
    "images": [],
    "is_verified_purchase": true,
    "helpful_count": 0,
    "created_at": "timestamptz",
    "updated_at": "timestamptz"
  }
}
```

Duplicate and concurrent duplicate submits are idempotent: the existing row is
returned unchanged with `created: false`. A duplicate request never adds a
second row and never changes the first row's content or evidence.

### `update_product_review`

Callable by `authenticated` only.

Arguments:

```text
p_review_id uuid
p_rating integer           // 1..5
p_title text = null
p_comment text = null
```

Returns the flat review JSON object with the same review fields shown above.
Only `rating`, `title`, and `comment` are changed. Ownership, product,
verification evidence, verified state, images, and helpful count cannot be
changed by this RPC. Preserved legacy reviews may be edited by their owner but
remain unverified.

### `delete_product_review`

Callable by `authenticated` only.

Arguments:

```text
p_review_id uuid
```

Returns:

```json
{"review_id": "uuid", "deleted": true}
```

Deletion is owner-scoped and idempotent. A missing review or a review owned by
another customer returns `deleted: false` without revealing ownership. Review
deletion never removes or changes the verified transaction evidence.

## Error mapping

PostgreSQL `code` and stable message tag:

| Condition | Code | Message tag |
| --- | --- | --- |
| Authentication missing | `28000` | `[REVIEW_AUTH_REQUIRED]` |
| Missing/invalid argument | `22023` | `[REVIEW_INVALID_ARGUMENT]` |
| Rating outside 1..5 | `22023` | `[REVIEW_INVALID_RATING]` |
| Product missing/inactive public read | `P0002` | `[REVIEW_PRODUCT_NOT_FOUND]` |
| No server-authoritative evidence | `42501` | `[REVIEW_NOT_VERIFIED]` |
| Update target missing or not owned | `P0002` | `[REVIEW_NOT_FOUND]` |
| Evidence/ownership mutation attempt | `42501` | `[REVIEW_EVIDENCE_IMMUTABLE]` |
| Evidence does not match customer/product | `42501` | `[REVIEW_EVIDENCE_MISMATCH]` |

Agent 2 should branch on the stable tag first and use the PostgreSQL code as a
secondary category. Raw backend text is not customer-facing copy.

## Direct table access

Public read compatibility on `reviews` remains available. Direct
`INSERT`/`UPDATE`/`DELETE` privileges and mutation policies for authenticated
clients are removed. Agent 2 must use the RPCs above for every review mutation
and should use `get_product_reviews` for derived verification and aggregate
semantics.

## Active Storage contract

Only these buckets are active in Wave 6:

| Bucket | Public object download | Max size | MIME allowlist |
| --- | --- | --- | --- |
| `product-images` | yes | 8 MiB | JPEG, PNG, WebP |
| `category-images` | yes | 2 MiB | JPEG, PNG, WebP |
| `banner-images` | yes | 5 MiB | JPEG, PNG, WebP |

Object listing and every anon/authenticated write, update, and delete remain
denied because no `storage.objects` client policy exists. Uploading is a
trusted backend/operations responsibility. No server-only credential may be
embedded in the Flutter app or bundled assets.

Exact lowercase object paths:

```text
product-images/catalog/<product_uuid>/v<YYYYMMDDHHMMSS>/<safe-name>.<jpg|jpeg|png|webp>
product-images/shops/<shop_uuid>/<shop_product_uuid>/v<YYYYMMDDHHMMSS>/<safe-name>.<jpg|jpeg|png|webp>
category-images/catalog/<category_uuid>/v<YYYYMMDDHHMMSS>/<safe-name>.<jpg|jpeg|png|webp>
banner-images/catalog/<banner_uuid>/v<YYYYMMDDHHMMSS>/<safe-name>.<jpg|jpeg|png|webp>
```

`safe-name` starts with an ASCII lowercase letter or digit and then contains
only lowercase letters, digits, `.`, `_`, or `-` (maximum 128 characters before
the extension boundary enforced by the database expression). The database
rejects invalid paths. Bucket metadata enforces MIME and byte limits.

Replacement is versioned and non-destructive:

1. Upload a new versioned object.
2. Verify that object.
3. Atomically change the owning database row's image URL/pointer.
4. Keep the former object and any orphan for at least seven days.
5. A trusted operations cleanup may delete an unreferenced object only after
   the seven-day window.

The seven-day retention window is a trusted operations workflow contract, not
a database delete blocker. This permits exact rollback and disposable test
object cleanup while client delete remains denied by the absence of a Storage
policy. Wave 6 installs no cron or automatic garbage collector. `brand-logos`,
`avatars`, and `review-images` remain deferred and are not provisioned.
