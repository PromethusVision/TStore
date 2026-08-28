# Canonical Product Identity Contract

Status: **OWNER REVIEW DRAFT — NOT RUNTIME OR OWNER FINAL**
Wave: 16, Work Package 1
Scope: conceptual product identity; no schema or migration.

## Identity unit

A canonical product represents one repeatably recognizable, independently
sellable physical trade item shared by one or more shops. Identity follows the
real-world item, not a merchant's wording, price, stock, photo, or local SKU.

Two records are the **same product** only when their identity-bearing facts are
compatible: responsible brand/manufacturer where applicable, product family and
model, physical form, sellable pack, material or formulation where it changes
the item, edition, and the attributes that a customer must choose before buying.
The same primary taxonomy leaf is supporting context, never proof by itself.

## Relationship decision table

| Relationship | Rule | Typical evidence |
| --- | --- | --- |
| `SAME_PRODUCT` | Same sellable item and same identity-bearing attributes; wording or non-identity metadata differs. | Valid same GTIN plus compatible brand/model/pack; or strong non-barcode evidence. |
| `SAME_PRODUCT_DIFFERENT_VARIANT` | Same product family, but at least one choice-bearing variant dimension differs. | Size, colour, capacity, storage/RAM configuration, flavour, formulation shade, or fitment. |
| `DIFFERENT_PRODUCT` | Function, model, edition, material/formulation, physical form, or retail pack creates a separately recognized item. | Different model number; book edition/format; 500 ml versus 1 L; incompatible component. |
| `DUPLICATE_RECORD` | Two catalog records represent the same canonical identity and should converge. | Same verified identifiers and no unresolved identity conflict. |
| `BUNDLE` | One sellable unit intentionally contains multiple component identities. | Manufacturer set or fixed merchant-created kit; not merely quantity in a cart. |
| `MERCHANT_SPECIFIC_LISTING` | A shop's offer for a canonical product or variant. | Price, availability, shop SKU, local description, shop photo, sell-by-unit policy. |

## Identity-bearing versus descriptive facts

Identity-bearing facts may include manufacturer/brand, model or part number,
form factor, sellable pack quantity, capacity, size, colour, material,
formulation, edition, intrinsic compatibility, and a trustworthy global
identifier. Which dimensions matter is domain-specific: colour usually creates
a clothing or cosmetics variant, while a cosmetic formula change may create a
different product. Compatibility is identity-bearing only when it is intrinsic
to the physical item, not merely a search tag.

Descriptions, spelling, marketing claims, seller title, price, stock, shop SKU,
distance, shop-specific photos, freshness, lot and expiry do not define the
canonical identity. They belong to content, listing, derived, or batch layers.

## Identifier and evidence rules

- GTIN, EAN, UPC, ISBN and manufacturer part numbers are evidence, not the
  canonical primary key and not infallible truth.
- A syntactically valid identifier must still agree with product facts and
  provenance. Reuse, mistyping, packaging changes and merchant labels exist.
- Missing barcode never forces a custom item into an unmatchable record.
- One product family can have multiple variants and each variant can have one or
  more identifiers. A GTIN assigned to a distinct retail pack normally points
  to that pack/variant, not the abstract family.
- A taxonomy move or display-name rename does not change product identity.

## Decision order

1. Establish physical-product scope and policy eligibility separately.
2. Normalize identifiers without discarding their raw/provenance form.
3. Compare manufacturer, brand, model/family and responsible-party evidence.
4. Compare form, edition, pack and domain-specific variant dimensions.
5. Check intrinsic compatibility and taxonomy plausibility.
6. Classify only when conflicts are resolved; otherwise use manual review or
   `UNKNOWN` rather than a false merge.

## Invariants

- A shop listing references one canonical product/variant identity.
- Many shops may reuse that identity.
- Canonical product identity has no universal EsnaftaVar price or stock.
- A product has exactly one primary assignable taxonomy leaf; facets do not
  become duplicate category identities.
- Merge/split must preserve aliases, historical purchase evidence, reviews and
  analytics lineage; it must never silently rewrite history.
