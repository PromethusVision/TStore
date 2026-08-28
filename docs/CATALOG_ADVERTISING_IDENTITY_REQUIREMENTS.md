# Advertising Identity Requirements

Status: **FUTURE OWNER REVIEW DRAFT — NO AD ENGINE**
Wave: 16, Work Package 45

## Sponsorable entities

| Entity | Suitable use | Constraint |
| --- | --- | --- |
| Shop/merchant | Local awareness | Must not imply a particular product is available unless an active listing supports it. |
| Shop listing | Preferred V1 product sponsorship unit | Exact product/variant, merchant, price/availability timestamp and policy eligibility. |
| Canonical product | Future brand/product awareness | Sponsor attribution cannot change seller ranking or suggest a universal price. |
| Category/search placement | Future discovery campaign | Stable taxonomy identity and policy-safe query context required. |

Recommendation: when product advertising is introduced, sponsor the **shop listing**
because EsnaftaVar's customer promise is a nearby physical offer. Canonical product
identity remains the grouping key, so multiple sponsored listings do not create
duplicate product cards.

## Identity safeguards

- Sponsored status is presentation/auction metadata, never product, variant or
  taxonomy identity and never `is_featured` synonym.
- Merge transfers a campaign only through an auditable compatible successor mapping;
  split pauses targeting until a specific child is selected.
- Retired/out-of-stock/policy-blocked listings cannot serve, even if campaign state
  is active.
- Merchant-created bundle ads identify the exact bundle/listing, not every component.
- Impression/click/visit attribution records campaign, canonical product, variant,
  listing, shop and mapping version separately.
- Clear sponsored labeling, budget/billing, auction and measurement consent are
  future product/legal decisions outside this design.
