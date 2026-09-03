# Customer App Final UI Rollout Plan

## Governing rules

- W39A semantic tokens, Poppins type ramp, shared primitives and light theme are the reuse baseline.
- Each wave preserves current domain logic, routes, AuthGuards, Cubits/repositories and canonical taxonomy contracts unless a separate product task explicitly changes them.
- UI migration must not introduce shipping-first, payment-first or classic delivery-commerce semantics. EsnaftaVar remains local discovery, merchant/price comparison, physical visit and single-store Cart V2 preparation.
- No runtime fake data. Fixtures remain isolated to tests/goldens.
- Each screen wave must cover loading, empty, error and success where applicable; 320/390/430 px, Turkish overflow, 44 px touch targets, accessibility semantics, targeted regressions and full analyzer.
- Dark mode is deferred until a product-approved palette and contrast contract exist.

## Operating model — single UI Agent

Final Customer UI rollout uses exactly:

`ONE UI AGENT + INTEGRATION AGENT`

The three-UI-agent parallel implementation model is not active. A single UI Agent
owns visual consistency, shared-foundation reuse and the bounded screen diff;
the Integration Agent owns merge review, regression gates, coordination state and
main delivery.

Each major screen follows this sequence:

1. The UI Agent creates one `390 px` visual prototype.
2. The Product Owner reviews and explicitly approves the visual direction.
3. The UI Agent completes responsive/state/accessibility coverage and full
   regression without structural redesign outside the approved direction.
4. The Integration Agent reviews and merges the verified delivery to main.
5. Only then does work move to the next major screen.

No screen becomes FINAL solely from an agent's self-assessment. Shared tokens and
components remain single-owner hotspots during each screen wave.

## Figma budget policy

- Figma use remains minimal, selective and tied to a concrete visual decision.
- Repeated exploratory reads and unnecessary write iterations are avoided.
- The approved K'pasa direction, established Flutter design system, prior audit
  findings and committed golden evidence are reused before requesting new Figma
  work.
- The Flutter Final UI foundation is the primary implementation reference. Figma
  remains a selective visual reference and is not a parallel source of runtime
  behavior.

## Sequence

Wave 39B-R semantic visual delta closes the Home root-category mapping gate:
canonical-name resolution is `24/24`, order/root-id independent, and missing,
mismatch, ambiguous or unrelated fallbacks are `0`. The current rounded Material
icons are an owner-accepted temporary V1. A professional `CANONICAL 24 CATEGORY
VISUAL PACK` is deferred polish; it did not block the Category / Recursive Browse
delivery now closed by W40B. Home composition and canonical taxonomy content/runtime
remain unchanged.

Wave 40B closes the second rollout surface. The Product Owner-approved Category /
Recursive Browse V1 is integrated with compact header/breadcrumb, `Alt kategoriler`,
two-column cards, variable-depth L2/L3/L4 navigation, unavailable fail-safe and the
existing leaf-to-Product-Listing taxonomy-scope handoff.

Wave 41B closes the third rollout surface. The Product Owner-approved Product
Listing V1 preserves compact path/summary/sort, balanced two-column cards,
normalized images, product/brand/local-merchant/price hierarchy, seller-count or
single-store context, wishlist independence and existing Product Details handoff.
Only default/newest/rating sorting is exposed; no new filters, pagination or
shipping/payment/checkout semantics exist.

Wave 42B closes the fourth rollout surface. The Product Owner-approved Product
Details V1 preserves compact identity/header, explicit 224 px contain-fit hero,
truthful 0/1/many local-seller and listing-price states, Product Information,
Reviews, wishlist, existing seller-section context and Cart V2 preparation. The
shared image slider remains optional/default-off and retains the 340 px legacy
branch for existing callers. The next visual gate is Seller Comparison Final UI at
`390 px`.

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

`UI_ROLLOUT_MODEL: SINGLE_UI_AGENT`

`CATEGORY_RECURSIVE_BROWSE_V1_MAIN: YES`

`PRODUCT_LISTING_V1_MAIN: YES`

`PRODUCT_DETAILS_V1_MAIN: YES`

`NEXT_ROLLOUT_SURFACE: SELLER_COMPARISON_FINAL_UI`

`NEXT_REQUIRED_VISUAL_GATE: ONE_390PX_PRODUCT_OWNER_APPROVED_PROTOTYPE`

`W39B_MAIN_INTEGRATED: YES`

`CANONICAL_CATEGORY_SEMANTIC_MAPPING: INTEGRATED_24_OF_24`

`CATEGORY_ART_STATUS: TEMPORARY_V1_OWNER_ACCEPTED`

`CANONICAL_24_CATEGORY_VISUAL_PACK: DEFERRED_POLISH`

`MAIN_INTEGRATION_REQUIRED: NO`
