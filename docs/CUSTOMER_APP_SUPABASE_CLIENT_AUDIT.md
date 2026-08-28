# Customer App Supabase Client Access Audit

Status: PASS — static client audit only

## Access inventory

The client references public/business tables through `SupabaseTables`: profiles, saved locations, current/legacy addresses, categories, brands, products, shops, shop products, Wishlist, Cart V2, QR sessions, verified transaction/items, reviews, ratings, banners, chat messages, notifications, plus isolated legacy order/coupon/product-variation constants.

Canonical RPCs used by active customer flows include:

- QR: `create_qr_session`, `get_qr_session_for_verification`, `confirm_qr_session`.
- Reviews: `get_product_reviews`, `get_product_review_eligibility`, `submit_product_review`, `update_product_review`, `delete_product_review`.
- Ratings: `submit_verified_shop_rating`.
- Saved locations: `set_default_customer_saved_location`, `delete_customer_saved_location`.
- Chat summaries: `get_customer_conversations`, `get_customer_unread_chat_count`.
- Protected Auth/account deletion is invoked through the Auth repository's canonical operation.

Realtime channels exist for customer-filtered chat messages and notifications. Public media resolves through Storage URLs; active buckets are product, category, and banner images.

## Security/result

- No service-role/admin client is initialized or referenced by Flutter.
- Customer deletes/updates include user/session filters where direct mutation is appropriate; sensitive invariants use RPC/RLS.
- Generic `deleteAllNotifications` is scoped by current `user_id`; it is not a global delete.
- Deferred avatar storage methods and legacy addresses/orders are not active runtime surfaces.
- Client-controlled IDs are never treated as authorization; canonical RLS/RPC contracts remain the security boundary.

No remote project was queried or mutated.

`SUPABASE_CLIENT_AUDIT: PASS`
`SERVICE_ROLE_REFERENCE_IN_CLIENT: NO`
`REMOTE_ACCESS: NO`
