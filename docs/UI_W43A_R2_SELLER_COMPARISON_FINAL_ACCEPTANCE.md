# W43A-R2 Seller Comparison Final Acceptance

## Acceptance status

The Product Owner-approved W43A Seller Comparison composition has completed its C1, 0/1/many seller-state, responsive, accessibility, shared-component safety, visual-evidence and full-regression gates. The result is a `SELLER_COMPARISON_FINAL_UI_V1_CANDIDATE`; it is not Production-final approval and does not merge or globally enable the opt-in UI.

## Accepted C1 result

- Cards: approved compact comparison density, hierarchy and 390 px composition preserved.
- Merchant/locality: two-line merchant-name safety and truthful locality with no fabricated distance.
- Availability: only customer-purchasable listings show `Rafta var`; unavailable and incomplete/unknown records fail closed.
- Rating/distance: rendered only from real values; missing values leave no fake star, score or pseudo-distance.
- Price/best-price: ordinary, decimal, large and equal values remain readable; exactly one deterministic multi-seller minimum receives the badge.
- CTA hierarchy: `Mağazayı gör` primary and Product Owner-approved `Sepete ekle` secondary remain 48 px and preserve existing destinations.

## Seller-state acceptance

| State | Result |
| --- | --- |
| Zero | PASS — no fake price, availability, seller or CTA; product context and meaningful empty state remain. |
| One | PASS — singular summary/hierarchy, direct price, no sort and no false comparison badge. |
| Many | PASS — actual count/minimum, supported sorting, repeatable card rhythm and truthful comparison. |
| Equal lowest | PASS — equal actual prices remain visible and one deterministic current minimum gets the badge. |

## Shared-component acceptance

`ProductSellersSection.visualPrototype` remains optional and defaults to `false`. Existing Product Details call sites continue to omit it. Only the dedicated `SellerComparisonView` explicitly opts in. Final UI loading/empty/error cards, singular treatment and best-price badge logic do not leak into legacy callers. The public API remains backward compatible and no silent global visual change occurs.

## Responsive and accessibility acceptance

- 320 px: PASS
- 390 px primary: PASS; approved composition unchanged and lineage golden updated only for the Product Owner-approved `Sepete ekle` copy
- 430 px: PASS
- 100% text scale: PASS
- 130% text scale: PASS
- 44/48 px interaction baseline: PASS
- Back, sort, Shop Details and Cart V2 semantic labels: PASS
- Poppins and canonical Final UI tokens: PASS

## Functional acceptance

- Existing cheapest, most expensive, highest rated and location-gated nearest sort: PASS
- Shop Details handoff and back-stack: PASS
- Exact seller listing identity passed to Cart V2: PASS
- Cart V2 single-shop physical-preparation contract: PASS
- Repeated-card scrolling and realistic 15-seller fixture: PASS
- No online checkout semantics: PASS
- No sponsored, promoted, boosted or paid-ordering logic: PASS

## State acceptance

- Loaded: PASS
- Loading: PASS
- Empty: PASS
- Error/retry: PASS
- Explicit unavailable listing: PASS — hidden from customer-purchasable offers
- Unknown/incomplete listing: PASS — hidden fail-closed; no artificial domain state added
- Missing price: NOT REPRESENTABLE by the current required `double` contract; invalid finite/non-negative values do not enter the minimum-price calculation

## Evidence register

| Evidence | Path |
| --- | --- |
| Many sellers / 390 | `test/widget/shop/goldens/w43a_r2_many_sellers_390.png` |
| One seller / 390 | `test/widget/shop/goldens/w43a_r2_one_seller_390.png` |
| Zero sellers / 390 | `test/widget/shop/goldens/w43a_r2_zero_sellers_390.png` |
| Responsive 320 | `test/widget/shop/goldens/w43a_r2_loaded_320.png` |
| Responsive 430 | `test/widget/shop/goldens/w43a_r2_loaded_430.png` |
| 130% text | `test/widget/shop/goldens/w43a_r2_text_scale_130_390.png` |
| Long merchant / large price | `test/widget/shop/goldens/w43a_r2_long_merchant_large_price_390.png` |
| Loading | `test/widget/shop/goldens/w43a_r2_loading_390.png` |
| Empty | `test/widget/shop/goldens/w43a_r2_empty_390.png` |
| Error | `test/widget/shop/goldens/w43a_r2_error_390.png` |
| Equal-lowest price | `test/widget/shop/goldens/w43a_r2_equal_lowest_390.png` |
| Unavailable/unknown | `test/widget/shop/goldens/w43a_r2_unavailable_unknown_390.png` |

The Product Owner-approved W43A lineage remains at `test/widget/shop/goldens/w43a_seller_comparison_visual_prototype_390.png`; it was regenerated only for the approved `Listeye ekle` → `Sepete ekle` terminology change.

## Verification record

- Targeted matrix: 28 passed, 0 failed.
- Targeted plus shared-component deterministic matrix: 57 passed, 0 failed.
- Adjacent regression across Home, Category, Product Listing, Product Details, ProductSellersSection callers, Shop Details, Cart V2, QR, Reviews, Wishlist and Auth/AuthGuard: 411 passed, 0 failed.
- Full Flutter suite: 1430 passed, 6 existing conditional/live skips, 0 failed.
- Analyzer: no issues.
- Visual inspection: twelve R2 golden images passed.
- A temporary 0.71% original-golden mismatch was detected during R2 and corrected by restoring the approved 390 px button padding.
- A later 5.81% change in the long-merchant stress golden was the expected removal of unverified distance copy from a coordinate-less fixture.
- Following R2 closeout, the Product Owner-approved `Sepete ekle` terminology was applied to the visible Seller Comparison CTA. CTA-bearing goldens were regenerated and re-inspected; layout, destinations, accessibility semantics and the physical-preparation contract remain unchanged.
- Initial sandboxed Flutter-test invocations were stopped before test execution because Flutter could not write its user-profile tool-state file. Scoped Flutter-test reruns completed successfully and are the results recorded here.
- No new skip, weakened assertion, backend operation, Figma write or Production access.

## Final self-review

A. Approved W43A composition preserved: YES.

B. Prices easy to compare: YES.

C. Local seller identity obvious: YES.

D. 0/1/many states truthful: YES.

E. No online checkout semantics: YES.

F. Cart V2 remains physical preparation: YES.

G. Shop Details handoff works: YES.

H. ProductSellersSection shared change safe: YES.

I. No sponsored logic: YES.

J. 320/390/430 and 130% text safe: YES.

`W43A_COMPOSITION_PRESERVED: PASS`

`SELLER_0_1_MANY_STATES: PASS`

`PRICE_COMPARISON_INTEGRITY: PASS`

`AVAILABILITY_TRUTHFUL: PASS`

`LOCALITY_DISTANCE_TRUTHFUL: PASS`

`SHOP_DETAILS_HANDOFF: PASS`

`CART_V2_BEHAVIOR_PRESERVED: PASS`

`PRODUCT_SELLERS_SHARED_CHANGE_SAFE: PASS`

`NO_SPONSORED_LOGIC: PASS`

`RESPONSIVE_320_390_430: PASS`

`TEXT_SCALE_130: PASS`

`FULL_TEST_SUITE: PASS`

`ANALYZER: PASS`

`HOME_CHANGED: NO`

`CATEGORY_CHANGED: NO`

`PRODUCT_LISTING_CHANGED: NO`

`PRODUCT_DETAILS_CHANGED: NO`

`SHOP_DETAILS_REDESIGNED: NO`

`BACKEND_CHANGED: NO`

`TAXONOMY_CHANGED: NO`

`PRODUCTION_ACCESSED: NO`

`SELLER_COMPARISON_UI_V1_CANDIDATE: YES`

`READY_FOR_W43B_INTEGRATION: YES`
