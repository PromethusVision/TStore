# W41A-R2 Product Listing Visual Review

## Review scope and decision

The Product Owner-approved W41A composition is preserved. R2 is a bounded C1 polish and hardening pass for the existing Product Listing prototype; it is not a redesign and it does not enable the prototype as the canonical runtime.

The retained composition is:

- compact `YEREL ÜRÜNLER` header and current leaf title;
- compact taxonomy path context;
- local comparison summary and the supported sort action;
- balanced two-column, image-led product grid;
- independent wishlist action;
- local seller/shop context;
- existing `TL’den` minimum-price semantics.

The screen remains a local physical-commerce discovery surface. No shipping, delivery, checkout, payment or buy-now language was added.

## C1 polish result

### Breadcrumb and hierarchy truth

- Deep paths are rendered as `first › … › current leaf`, instead of uncontrolled character clipping.
- The compact path remains one line so the approved header height does not expand.
- The complete L1/L2/L3/L4 path remains available through the semantic label and tooltip.
- Turkish labels and long hierarchy input were exercised at 320 px and 130% text scale.

### Product image normalization

- Every product card uses the same bounded image stage, inner padding, radius and alignment.
- Images use `BoxFit.contain`; no source is stretched or cropped to fake consistency.
- Square, portrait, wide, transparent-background and large-internal-whitespace fixtures were checked.
- The existing no-image fallback stays token-aligned.

The heterogeneous assets in the stress evidence are test fixtures, not a new production artwork pack. A future curated product-art pass is cosmetic and remains deferred.

### Merchant and local context

- Multiple listings continue to show the existing count contract, such as `3 esnafta var`.
- A single listing is explicitly identified as `Mağaza: <existing shop name>` so the line cannot be mistaken for a brand or generic product attribute.
- Only existing shop data is displayed; no neighborhood or merchant metadata was invented.
- Merchant text has a stable two-line area, controlled ellipsis, tooltip and top-aligned storefront icon.

### Card and price alignment

- Product title, brand, merchant and price zones are bounded consistently across each row.
- Long product and shop names no longer create chaotic row heights or collide with wishlist/price controls.
- The existing minimum/listing price calculation is unchanged; large prices remain bottom-aligned and scale down only when necessary.
- Natural lower-row visibility is retained as the scroll cue; text is not deliberately chopped to create a false peek.

## Responsive and accessibility review

| Case | Result |
| --- | --- |
| 320 px / 100% | Two columns retained safely; title, merchant, price and 44 px wishlist target pass. |
| 390 px / 100% | Approved primary composition preserved. |
| 430 px / 100% | Grid expands without changing the visual language. |
| 390 px / 130% | Header, summary, sort, product, merchant and price areas remain readable without layout exceptions. |

Interactive back, sort and wishlist targets remain at least 44 px. Poppins, canonical Final UI colors, spacing, radii and surface language remain in use. No text-scaling override was introduced.

## State and behavior review

- Loaded: final two-column local-product composition.
- Loading: canonical token-based skeleton with stable card geometry.
- Empty: shared W39 state-card language with category-specific Turkish copy.
- Error: shared W39 state-card language and retry action.
- Pagination/loading-more: not activated. `SubCategoryView` did not expose a pagination interaction in the approved implementation; generic cubit capability alone was not treated as permission to invent a new view contract.
- Sort: only default, newest and rating remain available; selection and dismissal are covered.
- Wishlist: existing favorite/AuthGuard contract and tap independence are unchanged.
- Product Details: existing card route and identifier handoff are unchanged; Product Details and Seller Comparison were not redesigned.

## Visual evidence

Primary and responsive evidence:

- `test/widget/shop/goldens/w41a_r2_loaded_390.png`
- `test/widget/shop/goldens/w41a_r2_loaded_320.png`
- `test/widget/shop/goldens/w41a_r2_loaded_430.png`
- `test/widget/shop/goldens/w41a_r2_text_scale_130_390.png`
- `test/widget/shop/goldens/w41a_r2_long_content_image_stress_390.png`

State and interaction evidence:

- `test/widget/shop/goldens/w41a_r2_loading_390.png`
- `test/widget/shop/goldens/w41a_r2_empty_390.png`
- `test/widget/shop/goldens/w41a_r2_error_390.png`
- `test/widget/shop/goldens/w41a_r2_sort_open_390.png`

The original approved W41A lineage image remains unchanged at `test/widget/shop/goldens/w41a_product_listing_prototype_390.png`. The legacy-before golden was refreshed only to make asset decoding deterministic in parallel test runs.

## Verification

- Targeted Product Listing behavior/golden matrix: 27 passed, 0 failed.
- Adjacent Home/Category/Search/Product Details/AuthGuard/Bottom Navigation and Cart V2/QR/Reviews/Wishlist/Seller Comparison/Auth matrix: 880 passed, 0 failed.
- Full Flutter suite: 1362 passed, 6 pre-existing conditional/live skips, 0 failed.
- `flutter analyze --no-pub`: no issues.
- Nine R2 golden images were generated and visually inspected.
- No new skip and no weakened assertion.

## Boundaries

- Home changed: NO
- Reward changed: NO
- Category UI changed: NO
- Product Details redesigned: NO
- Seller Comparison redesigned: NO
- Backend changed: NO
- Taxonomy changed: NO
- Canonical runtime enabled: NO
- Production accessed: NO
- Figma modified: NO
- Dark mode added: NO

`W41A_COMPOSITION_PRESERVED: PASS`

`LOCAL_COMMERCE_IDENTITY_PRESERVED: PASS`

`PRODUCT_LISTING_UI_V1_CANDIDATE: YES`
