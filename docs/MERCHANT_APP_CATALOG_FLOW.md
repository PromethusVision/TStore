# Merchant App Catalog Flow

Status: **PROPOSED — CATALOG OWNER DECISIONS OPEN**  
Wave: 17 / WP15

## Preferred flow

```text
SEARCH_EXISTING_PRODUCT
 -> SELECT_CANONICAL_PRODUCT
 -> SELECT_OR_REQUEST_VARIANT (when material)
 -> REVIEW_INHERITED_FACTS
 -> ENTER_SHOP_LISTING_FIELDS
 -> VALIDATE_POLICY_AND_DUPLICATE
 -> CREATE_OR_UPDATE_LISTING
```

Merchant canonical ürünü her mağaza için yeniden yaratmaz. Arama sonucu bulunamazsa doğrudan yayınlanan serbest ürün yerine candidate flow açılır.

## Layer ownership

| Layer | Owns | Merchant edit boundary |
|---|---|---|
| CANONICAL PRODUCT | Stable ID, canonical name, brand/model, taxonomy, shared facts | Protected; correction/candidate request only |
| VARIANT | Material buyable choice such as size/capacity/color when modeled | Select or request; not redefine silently |
| SHOP LISTING | Shop relation, merchant SKU, price, availability/stock knowledge, sell unit, allowed local media | Merchant-owned within authorization/policy |

## Required safeguards

- Listing uniqueness is evaluated for target shop + canonical product/variant contract.
- No universal product price or stock.
- Search context, aliases and barcode aid discovery but do not auto-merge identities.
- Listing creation is idempotent and revision-aware.
- Policy-blocked or retired canonical entities cannot be bypassed with a new listing.
- Other merchants' private SKU, stock notes or provenance are never exposed.

## States

- Product: active / retired / policy-blocked.
- Variant: active / discontinued / review.
- Listing: active / temporarily unavailable / out of stock / retired.
- Stock knowledge: known in stock / known out of stock / unknown.

