# Price Ownership Model

Status: **OWNER REVIEW DRAFT — NO PAYMENT OR PROMOTION ENGINE**
Wave: 16, Work Package 21

EsnaftaVar has no universal sale price for a canonical product. A price is a
timestamped claim by a shop for a particular listing and sell unit.

## Listing price facts

- current amount and currency;
- tax/inclusion semantics where required by policy;
- effective start and observed/updated timestamp;
- sell unit, pack and quantity basis;
- campaign amount and validity interval when supported;
- previous/reference amount only with a valid source and history;
- provenance/actor and confidence/freshness.

Canonical products may expose derived nearby minimum/maximum/median or seller count,
but these are query-time summaries, never canonical price fields. Search, analytics
and advertising must retain the listing ID and timestamp behind every displayed
price.

## Rules

- Price changes do not create a product/variant identity.
- Different shops may validly hold different prices; there is no conflict to resolve.
- Unit price is derived only when normalized measures are comparable (`TL/kg`,
  `TL/L`, `TL/piece`). It must label assumptions and avoid comparing unlike bundles.
- “Previous price” requires recorded history; merchant-entered crossed-out values
  without evidence are not trusted.
- Campaign price is a listing state layered over the ordinary price and must not
  mutate verified purchase history.
- QR/verified purchase records the amount actually confirmed, independent of later
  listing price corrections.

Current `products.price` and `sale_price` remain untouched compatibility fields in
this analysis-only wave; future migration requires a separate owner-approved plan.
