# Sponsored Advertising Object Model

**State:** PROPOSED FOR PRODUCT OWNER REVIEW — NO RUNTIME

## Question

An advertising object answers **what paid placement points to**. It is not Product
Taxonomy, canonical product identity, merchant-sector identity or an organic ranking
flag.

## Candidate objects

| Object | Appropriate use | Critical constraint | V1 posture |
|---|---|---|---|
| Merchant | Organization awareness | Does not prove a shop or product is locally available | DEFER |
| Shop | Local storefront awareness | Must use a real active physical shop and location | FUTURE CANDIDATE |
| Canonical product | Shared product awareness | Has no merchant price, stock or universal seller | TARGETING/GROUPING ONLY |
| Product variant | Exact selectable configuration | Still has no local offer without a listing | TARGETING/GROUPING ONLY |
| Shop listing | One shop's offer for one product/variant | Must be active, eligible and fresh | **RECOMMENDED V1 OBJECT** |
| Category/search term | Context in which an ad may compete | Mutable language/path cannot be campaign identity | TARGETING ONLY |

## V1 recommendation

Sponsor the **shop listing**. A sponsored target stores immutable references to the
campaign, listing, shop and canonical product/variant plus a target revision. The
customer sees the real shop offer, price/availability state, distance and the
visible `Sponsorlu` disclosure.

The canonical product remains the seller-comparison grouping key. Sponsoring a
listing cannot create a duplicate canonical product or claim a universal price.

## Hard eligibility invariant

A merchant may sponsor a product only when it controls an eligible active shop
listing that resolves to that exact canonical product/variant. The serve-time check
must reject:

- missing, retired, deleted or reassigned listing;
- inactive or suspended shop/merchant;
- known out-of-stock or stale availability outside the approved policy;
- policy-blocked product, variant, listing, shop or campaign;
- price/identity mismatch;
- target whose successor after product split is unresolved.

Campaign state alone never proves sellability.

## Identity lifecycle

- Product rename or taxonomy move keeps listing/campaign identity if semantic
  identity is unchanged.
- Listing retirement stops serving while history remains resolvable.
- Product merge requires auditable compatible successor resolution.
- Product split pauses the target until a specific successor is selected; it never
  chooses an arbitrary child.
- Listing reassignment to another product requires a new target revision and review.
- Shop relocation triggers geo re-evaluation before serving.

## Future objects

Shop-awareness cards may be evaluated after merchant profile, branch, eligibility
and reporting contracts exist. Merchant-level, canonical-product-only and generic
banner campaigns are not required for V1.

`ADS_V1_SPONSORED_OBJECT: SHOP_LISTING`

`FAKE_PRODUCT_SPONSORSHIP: BLOCKED_BY_DESIGN`

`OWNER_FINALIZATION_PERFORMED: NO`
