# Backend Current Entity Map

**State:** REPOSITORY-EVIDENCED — DESIGN ONLY
**Wave:** 21 / Workstream B

## Relationship map

```text
auth.users
  └─1:1─ profiles
       ├─1:N─ legal_consents
       ├─1:N─ addresses
       ├─1:N─ customer_saved_locations
       ├─1:N─ wishlist ─N:1─ products
       ├─1:N─ carts ─N:1─ shops
       │          └─1:N─ cart_items_v2 ─N:1─ shop_products
       ├─1:N─ qr_sessions ─N:1─ shops
       │          └─1:N─ qr_session_items ─N:1─ shop_products
       ├─1:N─ verified_transactions ─N:1─ shops
       │          └─1:N─ verified_transaction_items
       │                    ├─N:1─ shop_products
       │                    └─N:1─ products (durable review identity)
       ├─1:N─ reviews ─N:1─ products
       ├─1:N─ shop_ratings ─N:1─ shops
       ├─1:N─ chat_messages (sender or receiver)
       └─1:N─ notifications

profiles (merchant role in current model)
  └─1:N─ shops.owner_user_id
            └─1:N─ shop_products ─N:1─ products

categories ─1:N─ products ─N:1?─ brands
```

## Entity meanings

| Entity | Identity | Current relationship invariant |
|---|---|---|
| Auth user | Supabase Auth user ID | Authentication principal, not merchant organization |
| Profile | Same ID as Auth user | Application customer/merchant/admin profile; role is guarded server-side |
| Shop | Independent row; nullable `owner_user_id` | Physical seller/location in current model |
| Product | Canonical product row | Shared customer-facing identity; listing price is a separate concern |
| Shop product | Shop + product listing | Unique shop/product pair; owns local price/availability content |
| Cart | Customer + shop + lifecycle | Active cart is bound to one shop |
| Cart item | Cart + shop listing | Quantity references listing truth at cart time |
| QR session | Opaque token + customer/shop/cart context | Short lived, terminal state, single-shop |
| Verified transaction | Customer/shop + source QR | One durable transaction per consumed QR session |
| Verified transaction item | Purchase snapshot + product/listing references | Durable evidence survives mutable listing/product presentation |
| Review | Customer + canonical product | At most one active row; mutation requires verified evidence |
| Shop rating | Customer + shop | Verified transaction participant contract |
| Notification | Recipient-scoped message | In-app notification, not delivery proof for push/email |
| Chat message | Sender + receiver | Direct-party message; organization/staff routing is absent |

## Authority boundaries

- Auth authenticates a principal; `profiles.role` does not prove shop ownership.
- Current shop ownership is `shops.owner_user_id`. A future membership model must
  bridge this field without granting access based on user-supplied metadata.
- `shop_products` is the current listing entity. Introducing a named listing
  concept should preserve its ID or provide a durable mapping.
- QR issue and scan are not purchase evidence. Only the atomic confirmation path
  creates `verified_transactions` and items.
- A review points to canonical product identity. The verified item supplies
  eligibility evidence; it is not consumed by review creation.
- Notifications and Realtime are delivery/projection mechanisms, not authority.

## Legacy and compatibility edges

`orders` and `order_items` are customer-visible compatibility entities. They do
not establish QR verification, review eligibility, payment settlement or reward
entitlement. Product-level price/stock fields also remain compatibility data until
a separately authorized migration establishes listing-only ownership.

## Known future pressure points

1. One user may belong to multiple merchant organizations and shops.
2. A shop may need several staff members and scoped capabilities.
3. Canonical product may require variants while a shop listing remains the
   commercial offer.
4. Product merge/split must preserve purchase/review references.
5. Ads, rewards, reputation, operations cases and events need independent IDs and
   must reference—not replace—current authoritative entities.
