# EsnaftaVar Product / Variant / Listing Attribute Boundary

**State:** `PROVISIONAL CONCEPTUAL MODEL — OWNER DECISIONS OPEN`
**Data model/runtime:** Explicitly not finalized or implemented

## Three layers

| Layer | Identity question | Typical facts | Change cadence | Shared across shops? |
|---|---|---|---|---|
| `CANONICAL_PRODUCT` | What stable commercial product/model is this? | canonical title, manufacturer/brand, model/form, primary taxonomy leaf, invariant composition/specification | low | YES |
| `PRODUCT_VARIANT` | Which sellable physical configuration of that product? | color, size, storage, pack size or other owner-approved differentiating attributes | medium | YES when the same variant is sold by many shops |
| `SHOP_LISTING` | How/where does this shop offer it now? | shop SKU, price, stock/availability, condition, local notes, offer state | high | NO |

Taxonomy node identity is not any of these layers; it classifies the canonical
product/variant through exactly one primary leaf. A facet concept can be usable at
different layers by domain, but a future profile must declare one source of truth.

## Placement tests

### Canonical product test

A fact belongs at product level when changing it would mean a different product
model/type or correcting shared factual identity, and it should remain the same in
every shop. Manufacturer, model family, primary product form and invariant technical
specification are candidates. Marketing copy and merchant title are not.

### Variant test

A fact is a variant candidate only if:

1. customers intentionally choose among values before purchase;
2. each combination denotes a physically distinct sellable item/stock unit;
3. values are controlled and comparable;
4. price/stock may differ by combination;
5. it does not merely describe a claim, condition, compatibility target or shop offer.

Passing these tests still requires owner approval per leaf. Not every color/size is a
variant; not every technical value should generate combinatorial variants.

### Shop listing test

A fact belongs at listing level when it varies by merchant, location or time without
changing shared product identity: price, local stock, availability, shop SKU,
condition/offer state and shop-specific fulfilment/contact details. These are not
taxonomy facets even when searchable.

## Example analysis

| Scenario | Canonical product | Variant candidates | Shop listing | Open boundary |
|---|---|---|---|---|
| Smartphone-family-like device | model/form, CPU/display/OS baseline | storage, color; memory/SIM only if distinct sellable SKUs | price, stock, condition, shop SKU | Region/revision and bundled charger may be product/variant evidence. |
| T-shirt | model/style, material construction | color, apparel size | price, stock per variant, condition | Fit/cut may define model or variant depending assortment. |
| Shoes | model/form, construction | size system/value, color/material combination | price, stock, condition | Width/fit may be variant or descriptive facet. |
| Packaged food | packaged product identity, ingredients, producer | pack size/flavor only when distinct canonical sellable configuration | price, stock, freshness/lot where policy requires | Pack size may be product identity rather than child variant. |
| Loose/random-weight food | product type/origin/grade where governed | normally no pre-created weight variant | unit price, available quantity, measured sale unit | Commerce pricing contract is separate and unresolved. |
| Furniture | model/form/material construction | finish/color and fixed size only if catalogued combinations | shop price/stock/condition | Made-to-order/custom dimensions may be service/configuration, not variant. |
| Printer cartridge | consumable product/part identity and compatibility set | color/channel, capacity/yield only if distinct SKUs | price, stock, condition | Compatibility is a relation, never the variant itself. |
| Vehicle part | part/MPN identity and physical specification | revision/package quantity only if distinct product | price, stock, condition | Vehicle fitment relation stays product/variant evidence, not listing prose. |
| Cosmetic shade product | formula/product line/form | governed shade and size if physically distinct | price, stock, condition | Formula change may mean product, not variant. |
| Ring | design/model and material construction | governed ring size; finish/material only when same model system | price, stock, condition | Made-to-order sizing/custom engraving boundary is open. |
| Appliance | model and technical configuration | color/finish only when manufacturer SKU differs | price, stock, condition, display unit notes | Capacity is normally product/model identity, not a user-generated variant. |
| Book | edition/ISBN/language/format identity | usually none; binding only when separate ISBN/product | price, stock, condition | Box set is product/kit identity, not arbitrary variant. |

No real brand is required for this architecture.

## Facet source-of-truth classes

| Class | Example | Write owner |
|---|---|---|
| Product invariant | manufacturer, ingredients, model, technical baseline | canonical catalog review |
| Owner-approved variant discriminator | apparel size, governed shade, device storage | canonical variant review/import |
| Listing fact | price, stock, shop SKU | merchant/listing system |
| Compatibility relation | model/vehicle/device targets and rule result | structured evidence + compatibility service |
| Policy metadata | classification, certification, claim evidence | authorized policy/review owner |
| Derived search/display | normalized units/colors, search tokens | system rules; never merchant source |

The same concept must not have two mutable sources. A listing may display inherited
facts but cannot override them locally.

## Identity and deduplication

- Canonical product identity survives display-title/category-label changes.
- Variant identity is based on the governed discriminator set and normalized values,
  not concatenated title text.
- Listing identity includes merchant/shop context and points to one product/variant.
- UPC/EAN/GTIN/MPN/ISBN may be matching evidence, not unquestioned identity truth.
- Duplicate candidate creation must compare canonical identity and variant signature.
- Bundle/kit is assigned to the principal product rule from the canonical method;
  included-items metadata does not automatically create multiple products.

## Change scenarios

| Change | Expected handling |
|---|---|
| Display color rename | Same value/variant identity through alias mapping. |
| Shop price/stock change | Listing-only update. |
| Manufacturer specification correction | Versioned canonical correction and affected compatibility/index review. |
| Variant discriminator set changes | Owner-approved profile version; reconciliation/migration plan required. |
| Product taxonomy leaf changes | Stable product identity retained; analytics mapping and review required. |
| Compatibility rule changes | New rule/evaluation version; product/variant identity unchanged. |
| Policy eligibility changes | Listing state/review changes; category/product identity unchanged. |

## Anti-combinatorial safeguards

- Do not create a variant for every optional facet value.
- Do not cross-product all possible values before real SKUs exist.
- Do not model compatibility targets as variants.
- Do not model condition, seller, price, stock or promotion as variants.
- Do not derive variants from free-text titles alone.
- Do not merge different pack/formula/revision products merely because marketing name
  is similar.

## Owner questions

1. exact variant discriminator set per leaf/profile;
2. whether packaged-food pack size is product identity or variant by product family;
3. when color/material/fit changes create product vs variant;
4. canonical product creation and merge/split authority;
5. barcode/MPN evidence hierarchy and regional revisions;
6. bundle/multipack identity and stock semantics;
7. refurbished/used condition layer and policy;
8. custom/made-to-order products versus service/configuration;
9. merchant override/correction workflow and conflict SLA;
10. analytics behavior when a product or variant is split/merged.

## Non-decisions

This document intentionally does not define tables, IDs, FK relations, API payloads,
variant cart behavior, merchant UI or migration. The 22 proposed L2 domains remain
proposed and no Product Owner decision is inferred.

`PRODUCT_VARIANT_LISTING_BOUNDARY: PASS`

`DATA_MODEL_FINALIZED: NO`

`OWNER_DECISIONS_OPEN: 10`
