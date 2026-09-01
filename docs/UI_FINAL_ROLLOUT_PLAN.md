# Customer App Final UI Rollout Plan

## Governing rules

- W39A semantic tokens, Poppins type ramp, shared primitives and light theme are the reuse baseline.
- Each wave preserves current domain logic, routes, AuthGuards, Cubits/repositories and canonical taxonomy contracts unless a separate product task explicitly changes them.
- UI migration must not introduce shipping-first, payment-first or classic delivery-commerce semantics. EsnaftaVar remains local discovery, merchant/price comparison, physical visit and single-store Cart V2 preparation.
- No runtime fake data. Fixtures remain isolated to tests/goldens.
- Each screen wave must cover loading, empty, error and success where applicable; 320/390/430 px, Turkish overflow, 44 px touch targets, accessibility semantics, targeted regressions and full analyzer.
- Dark mode is deferred until a product-approved palette and contrast contract exist.

## Sequence

| Order | Surface | Required foundation reuse | Primary acceptance focus |
| --- | --- | --- | --- |
| 1 | Home — W39A | Completed token/theme/primitives | Discovery hierarchy, location/search, dynamic categories, campaign, products, merchants, Reward slot off by default. |
| 2 | Category / Recursive Browse | Section/state/surface foundations | 24-root and variable-depth taxonomy, breadcrumb/path context, long labels and no frozen demo tree. |
| 3 | Product Listing | Input/chip/card/section/state foundations | Search refinement, filter/sort, availability, density and exact canonical category scope. |
| 4 | Product Details | Surface/card/button/state foundations | Product context, media/fallback, rating summary and physical local-shopping semantics. |
| 5 | Seller Comparison | Merchant/price/section foundations | 14–15 seller scalability, price/distance/availability, best-price state and “Mağazayı Gör”. |
| 6 | Shop Details | Merchant/product/section foundations | Shop identity, address, rating/open state where contracted, directions, products and customer-side reviews. |
| 7 | Cart V2 | Button/state/surface foundations | Single active store, conflict/empty states, quantity/total, physical-purchase intent and QR availability without demo-owner claims. |
| 8 | Search | Input/chip/card/state foundations | Recent/refined search, taxonomy-aware results, products/shops and existing navigation behavior. |
| 9 | Wishlist / Reviews / Profile / Auth | Entire customer foundation | Auth gates, empty/error states, verified reviews, settings, accessible forms and final secondary-state/polish pass. |

## Change-control checkpoints

For every rollout wave:

1. Inventory current component and behavioral contracts before visual changes.
2. Reuse or extend the W39A foundation; do not create a parallel token family.
3. Add a new reusable primitive only when at least two consumers or a clear cross-screen contract justify it.
4. Keep compatibility facades until all consumers migrate, then remove them in a dedicated cleanup diff.
5. Record local visual evidence at 390 px plus narrow/large-text stress.
6. Run screen-specific regression tests, relevant adjacent business-contract tests, full analyzer and the full suite before integration.

## Deferred decisions

- Reward economics/backend/activation.
- Product-approved dark mode.
- Any taxonomy content change; the canonical taxonomy workstream remains authoritative.
- Advertising, sponsorship ranking, gamification and merchant-management behavior.
- Final campaign artwork/content policy beyond the existing runtime banner source.

`W39A_FOUNDATION_COMPLETE: YES`

`NEXT_ROLLOUT_SURFACE: CATEGORY_RECURSIVE_BROWSE`

`MAIN_INTEGRATION_REQUIRED: YES`
