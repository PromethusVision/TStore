# Backend Shop Listing Contract

**State:** PROPOSED EVOLUTION OF `shop_products`

A shop listing is one merchant-controlled offer for one canonical product and,
when applicable, one exact variant at one shop. Current `shop_products.id` should
remain listing identity.

## Field ownership

| Listing-owned | Canonical-owned |
|---|---|
| shop, price, availability knowledge, merchant SKU, local description/media, active/retired state | canonical name, brand, taxonomy, governed attributes, product policy |

## Mutation contract

- caller must have active listing capability for the exact shop;
- create/update is server validated, idempotent and revision checked;
- canonical IDs and shop ownership cannot be changed by ordinary update;
- same merchant SKU uniqueness is namespace-bound;
- price/availability changes record actor, source, observed/effective time;
- retirement stops new discovery/QR selection but preserves history;
- public visibility is derived from product, listing, shop and policy states.

Existing unique `(shop_id, product_id)` may be insufficient once variants exist.
Changing it requires an explicit compatibility/data migration and is not approved
here.

