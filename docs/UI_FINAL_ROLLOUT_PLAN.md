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

`NEXT_ROLLOUT_SURFACE: CATEGORY_RECURSIVE_BROWSE`

`NEXT_REQUIRED_VISUAL_GATE: ONE_390PX_PRODUCT_OWNER_APPROVED_PROTOTYPE`

`W39B_MAIN_INTEGRATED: YES`

`MAIN_INTEGRATION_REQUIRED: NO`
