# Merchant Review Feed Projection Model

**State:** PROPOSED VIEW CONTRACT — NO SECOND REVIEW SYSTEM

## Definition

`Değerlendirmeler` on a shop profile is a read projection of eligible product reviews whose immutable
origin evidence belongs to that shop, optionally accompanied by separately labeled structured shop
experience responses from the same evaluation flow.

Example projection:

```text
Spor Ayakkabı — Ürün yorumu ★★★★★
“Ürün rahat ve beklediğim gibi.”
Doğrulanmış fiziksel alışveriş · Bu mağazadan

Mağaza deneyimi (ayrı): Güler yüzlülük 5 · Yardımcı olma 5
```

This is not a seller-authored review, organization-wide quality guarantee or extra aggregate vote.

## Projection rules

- Product free text appears on the origin shop feed only.
- Editing the product review updates that same projection and preserves revision history.
- Deleting hides the active projection; recreate restores from the same durable origin unless an
  explicit evidence correction says otherwise.
- Product rating participates only in product aggregate, never shop dimension aggregates.
- Structured values participate only in dimension aggregates and may be omitted from public feed
  while still contributing under an approved policy.
- Content removal does not silently remove valid structured values; evidence invalidation can affect
  both through separate deterministic projections.
- Sorting is disclosed, objective and never changed by ad spend, rewards or merchant pressure.

## Catalog and lifecycle

| Event | Feed behavior |
|---|---|
| product rename/taxonomy move | current name may update; at-event snapshot remains available |
| product duplicate merge | project to survivor; same-customer collisions need explicit rule |
| product split | map only with deterministic snapshot; ambiguous content stays historical/out of child aggregates |
| shop rename/relocation | stable shop feed remains; current and at-event context distinguished |
| temporary closure | historical feed remains; current closure state shown |
| permanent closure | active discovery retires; historical evidence remains interpretable |
| ownership transfer | no automatic new-owner badge portability; feed lineage and effective dates shown |

## Trust labels

Use distinct labels such as `Ürün puanı`, `Mağaza deneyimi`, `Doğrulanmış fiziksel alışveriş` and
`Yeterli veri yok`. Never collapse them into “Esnaf puanı” without an owner-approved definition.

`MERCHANT_FREE_TEXT_TABLE_REQUIRED: NO`
`FEED_IS_DERIVED_PROJECTION: YES`
