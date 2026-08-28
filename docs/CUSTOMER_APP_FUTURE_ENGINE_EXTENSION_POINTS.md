# Customer App Future Engine Extension Points

Status: **AUDIT ONLY — NO ENGINE IMPLEMENTED**

## Sponsored advertising

Potential presentation points are labeled Home sections, listing/search cards,
Product Details seller rows and shop discovery. Future results must retain stable
product/shop/listing ids, expose an explicit “Sponsorlu” label, preserve organic
fallback and keep ranking separate from category/`featured` semantics. Do not
encode sponsorship in taxonomy nodes or overwrite canonical prices.

## Rewards and gamification

Potential surfaces are profile, verified-purchase history, review completion and
non-transactional badges. Authoritative eligibility must be server-side and tied
to stable customer and verified-transaction ids. The client must not award points
from button taps, QR rendering or mutable local state.

## Safe extension boundaries

- Add new repositories/use cases and injected interfaces rather than branching
  core discovery/cart logic on provider SDKs.
- Keep experiment/placement metadata distinct from product/shop/listing models.
- Label sponsored content accessibly and test organic ordering/no-ad states.
- Do not couple rewards to review rating or incentivize only positive reviews.
- Do not start analytics collection before privacy/consent/retention decisions.

No ranking, ad auction, reward formula, badge system, SDK or schema change was
introduced in Wave 16.
