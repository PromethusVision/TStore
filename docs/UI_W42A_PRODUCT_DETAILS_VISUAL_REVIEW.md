# W42A-R2 Product Details Visual Review

## Review scope and decision

The Product Owner-approved W42A Product Details composition is preserved. R2 is a bounded C1 polish, state, responsive, accessibility and regression pass; it is not a structural redesign and it does not enable the opt-in Final UI as canonical runtime.

The retained composition is:

- compact `YEREL ÜRÜN / Ürün detayları` header;
- independent back and wishlist actions;
- current compact product hero;
- category, product name and brand hierarchy;
- prominent local seller and merchant-owned price summary;
- seller comparison handoff;
- Product Information and Reviews sections;
- existing inline seller list and seller-based Cart V2 action.

The screen remains a local physical-commerce surface. No shipping, delivery, online payment, buy-now, checkout or order semantics were added.

## C1 polish result

### Product hero image normalization

- The approved 224 px hero surface, padding, radius and neutral background remain unchanged.
- The shared image renderer continues to use `BoxFit.contain`, so portrait, square, wide and transparent assets are neither stretched nor cropped.
- Large-internal-whitespace input remains bounded by the same 184 px image stage; source pixels are not destructively cropped to fake scale.
- Products with multiple images expose the existing Final UI image-count cue without creating a false interactive control.
- The legacy/default 340 px gallery, thumbnail strip, back action and favorite action remain available to existing callers.

The square, portrait, wide, transparent-background, large-whitespace and multiple-image fixtures are visual test inputs, not new production product artwork.

### Title, brand and category

- The approved category chip, product title and brand order is unchanged.
- Long Turkish category, product and brand content uses controlled wrapping/ellipsis without horizontal overflow.
- `Ç Ğ İ Ö Ş Ü` content was exercised at 320/390/430 px and at 130% text scale.

### Seller availability and price truth

The local summary derives only from customer-purchasable `ShopProductEntity` records already returned by the existing seller use case. It does not display `ProductEntity.price` as a false canonical market price.

| Supported state | Final UI behavior |
| --- | --- |
| Multiple sellers | Actual count, minimum listing price with `TL’den`, active `Esnafları karşılaştır` handoff. |
| One seller | `1 esnafta var`, direct listing price without `-den`, active `Esnafı gör` handoff. |
| Zero sellers | Meaningful unavailable copy; no price and no comparison CTA. Existing lower empty-state route remains available. |
| Loading | Loading copy only; no price and no premature comparison CTA. |
| Error | Safe error copy; no price and no comparison CTA. Existing lower retry action remains available. |

Ordinary, decimal and `123.456.789,87 TL’den` stress values render without clipping. Merchant/listing price ownership and current minimum-price calculation are unchanged.

### Product Information

- The approved Product Information surface remains intact.
- Description is sourced from the current product contract; the existing safe missing-description copy remains.
- The category chip above the title provides browsing context, while the bounded `Marka:` and `Kategori:` chips inside Product Information retain factual metadata. They were kept because these placements serve different reading contexts and do not collide in the reviewed layouts.
- No specification or attribute was invented.

### Reviews

- The lower section now has a clear `Değerlendirmeler` heading within the same approved surface language.
- Reviews-present uses only `ProductEntity.rating` and `reviewsCount` for the summary and opens the existing Product Reviews destination with the same product context.
- Reviews-empty uses truthful empty copy and keeps the existing handoff.
- Product Details does not own an authoritative review-list preview model, so no fabricated quote, customer identity or verified-purchase badge was added.
- Existing verified-purchase rules remain exclusively in the Reviews domain/screen and were regression-tested without modification.

## Product Details state coverage

- Loaded: the view receives an existing `ProductEntity` and renders the approved Final UI.
- Seller loading/error/empty: represented through the existing seller use-case contract.
- Unavailable: an existing inactive `ProductEntity.isActive == false` produces a safe warning and does not request or show seller actions.
- Not found: not represented inside `ProductDetailsView`; route/repository layers must withhold a missing entity. No new backend state was invented.

## Functional review

- Back navigation: preserved.
- Wishlist: existing inactive/active/loading/AuthGuard behavior remains independent of other taps.
- Seller comparison: 1/many actions scroll to the existing seller section with the same product and listing context; zero/loading/error expose no misleading handoff.
- Shop handoff/back behavior: preserved by the existing seller section.
- Cart V2: the selected `shopProductId` and quantity continue to call the existing single-shop physical-preparation cubit; no Cart V2 screen or business rule changed.
- Gallery: the explicit Final UI count cue and existing default gallery presentation both remain covered.
- Reviews: the same product identifier is passed to the current Product Reviews destination.

## Responsive and accessibility review

| Case | Result |
| --- | --- |
| 320 px / 100% | Header, hero, long title, seller block, CTA and following information remain overflow-safe. |
| 390 px / 100% | Approved primary composition preserved; identity, local price and seller action remain in the first viewport. |
| 430 px / 100% | Content expands within the 430 px cap without changing hierarchy. |
| 390 px / 130% | Title, seller count, price, CTA, explanation, information and review copy remain readable without layout exceptions. |

Back and wishlist controls are at least 44 px; the primary seller action uses the canonical 48 px button minimum. The review surface is a meaningful semantic button, the inactive-product notice has a semantic label, and existing back/wishlist/Cart/gallery semantics remain in place. Poppins and canonical Final UI colors, spacing and radii are unchanged.

## Shared `ProductImageSlider` safety audit

The exact shared delta was introduced in W42A, not expanded in R2:

- one optional, backward-compatible public parameter: `visualPrototype = false`;
- default branch: existing 340 px media, thumbnail gallery, back and wishlist presentation;
- explicit Final UI branch: 224 px neutral contain-fit hero and multiple-image count cue;
- only `ProductDetailsView._buildVisualPrototype` passes `visualPrototype: true`;
- every existing production caller of `ProductDetailsView` still uses the default `false` value;
- R2 made no further change to `ProductImageSlider`, `SelectedProductImage` or gallery behavior.

The shared safety test asserts both 224 px opt-in and 340 px legacy geometry, `BoxFit.contain`, the Final UI multiple-image cue and the existing `OtherSameProductsList`. Home, Category and Product Listing do not call `ProductImageSlider` directly and their full widget regressions passed.

## Visual evidence

Primary, responsive and stress evidence:

- `test/widget/shop/goldens/w42a_r2_loaded_multiple_sellers_390.png`
- `test/widget/shop/goldens/w42a_r2_loaded_320.png`
- `test/widget/shop/goldens/w42a_r2_loaded_430.png`
- `test/widget/shop/goldens/w42a_r2_text_scale_130_390.png`
- `test/widget/shop/goldens/w42a_r2_long_title_large_price_390.png`

Seller and product state evidence:

- `test/widget/shop/goldens/w42a_r2_single_seller_390.png`
- `test/widget/shop/goldens/w42a_r2_zero_sellers_390.png`
- `test/widget/shop/goldens/w42a_r2_loading_390.png`
- `test/widget/shop/goldens/w42a_r2_error_390.png`
- `test/widget/shop/goldens/w42a_r2_unavailable_390.png`

Lower-section evidence:

- `test/widget/shop/goldens/w42a_r2_product_information_390.png`
- `test/widget/shop/goldens/w42a_r2_reviews_present_390.png`
- `test/widget/shop/goldens/w42a_r2_reviews_empty_390.png`

Hero normalization evidence:

- `test/widget/shop/goldens/w42a_r2_hero_square_390.png`
- `test/widget/shop/goldens/w42a_r2_hero_portrait_390.png`
- `test/widget/shop/goldens/w42a_r2_hero_wide_390.png`
- `test/widget/shop/goldens/w42a_r2_hero_transparent_390.png`
- `test/widget/shop/goldens/w42a_r2_hero_whitespace_390.png`
- `test/widget/shop/goldens/w42a_r2_multiple_images_390.png`

The Product Owner-approved W42A lineage images remain at:

- `test/widget/shop/goldens/w42a_product_details_visual_prototype_390.png`
- `test/widget/shop/goldens/w42a_before_product_details_390.png`

## Verification

- Targeted Product Details/gallery/seller/Cart V2/wishlist/Reviews matrix: 100 passed, 0 failed.
- All widget/adjacent regression matrix: 701 passed, 0 failed.
- Full Flutter suite: 1402 passed, 6 pre-existing conditional/live skips, 0 failed.
- `flutter analyze --no-pub`: no issues.
- Nineteen R2 golden images were generated and visually inspected.
- No new skip and no weakened assertion.

## Boundaries

- Home changed: NO
- Reward changed: NO
- Category changed: NO
- Product Listing changed: NO
- Seller Comparison redesigned: NO
- Cart V2 redesigned: NO
- Reviews screen redesigned: NO
- Backend changed: NO
- Taxonomy changed: NO
- Canonical runtime enabled: NO
- Production accessed: NO
- Figma modified: NO
- Dark mode added: NO

`W42A_COMPOSITION_PRESERVED: PASS`

`PRODUCT_DETAILS_FINAL_UI_V1_CANDIDATE: YES`
