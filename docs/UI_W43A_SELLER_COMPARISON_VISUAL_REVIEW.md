# W43A-R2 Seller Comparison Visual Review

## Review scope and decision

The Product Owner-approved W43A Seller Comparison composition is preserved. R2 is a bounded C1 polish, seller-state, responsive, accessibility and regression pass; it is not a structural redesign and it does not enable an opt-in Final UI globally.

The retained composition is:

- compact `YEREL FİYAT KARŞILAŞTIRMA / Esnafları karşılaştır` header;
- compact product context and truthful seller-count/starting-price summary;
- `Esnaf teklifleri` hierarchy for real comparison cases;
- existing supported sorting;
- dense seller cards with merchant identity, locality, availability, rating, real distance, price and one deterministic best-price badge;
- primary `Mağazayı gör` and secondary `Listeye ekle` actions.

The screen remains a local physical seller-comparison surface. No shipping, delivery, online payment, buy-now, checkout, order, sponsored seller or paid-ranking semantics were added.

## C1 polish result

### Seller cards and identity

- The approved card density, hierarchy, radii, colors and 390 px rhythm remain unchanged.
- Merchant names use a controlled two-line treatment; long Turkish names remain understandable without pushing price or actions outside the card.
- District/city remains directly under the merchant identity. Address-only data remains visible as locality but is never converted into a fabricated distance.
- Availability, rating and distance occupy a compact metadata row and disappear individually when their source value is absent.
- Price remains right-aligned and comparison-friendly for ordinary, decimal and `123.456.789,87 TL` values.
- Both actions retain a minimum 48 px height. At narrow widths or 130% text scale, only decorative button icons are removed and horizontal padding becomes compact; the approved 390 px/100% composition remains intact.

### Price and best-price truth

Only customer-purchasable listings participate in the visible list, seller count and minimum-price calculation. Prices must be finite and non-negative. With multiple valid sellers, the first seller in the current deterministic sorted result whose price matches the minimum receives `En uygun fiyat`. This gives equal-lowest-price data exactly one badge without inventing a recommendation. A single seller receives no comparison badge.

| Seller state | Final UI behavior |
| --- | --- |
| Zero | Product context retained; meaningful empty state; no price, seller card or commerce CTA. |
| One | `1 esnaf` summary, direct listing price, singular `Yerel esnaf` hierarchy, no sort and no best-price claim. |
| Many | Actual seller count, real minimum with `TL’den`, comparison copy and supported sort. |
| Equal lowest | All actual prices remain visible; exactly one deterministic matching listing receives the best-price badge. |

### Availability, distance and rating truth

- `ShopProductEntity.isAvailable == true` and an active, valid shop are required for a listing to be customer-purchasable.
- Explicitly unavailable listings and incomplete/unknown listings with no valid shop are filtered fail-closed. They never show `Rafta var`.
- The current domain contract has a Boolean availability field rather than a separate unknown enum, so no artificial third-state chip was introduced.
- A distance is shown only when valid shop coordinates and customer coordinates produce an actual calculation. Address-only sellers show their address and no pseudo-distance.
- A star is shown only with a real rating. Missing ratings do not produce a star or placeholder score.

## Sort contract

The shared seller section already implements four real, deterministic presentation modes: cheapest, most expensive, highest rated and nearest. Nearest is available only when a valid customer location exists and is the automatic default only in that case. Without location, the existing repository order is preserved until the user selects a supported non-distance sort. The approved supporting copy asks the user to compare price, rating and distance; it does not claim that all three are combined into one recommendation score.

## Cart V2 and Shop Details behavior

- `Mağazayı gör` pushes the existing Shop Details destination with the same `ShopEntity`; back-stack behavior is unchanged.
- `Listeye ekle` sends the exact selected `shopProductId` and quantity to the existing Cart V2 cubit.
- Cart V2 remains a single-shop physical-shopping preparation flow. No payment, delivery, shipping, checkout or order behavior was introduced.
- The visible copy is preserved. The surrounding local-comparison header, merchant-specific action hierarchy, explicit accessibility label and tooltip clarify physical-shopping preparation; no Product Owner copy change is recommended in this pass.

`COPY_POLISH_RECOMMENDED: NO`

## Final UI states

| State | Result |
| --- | --- |
| Loaded | Approved product summary, comparison hierarchy and seller cards. |
| Loading | Static Final UI loading card and honest loading summary; no fake price/action. |
| Empty | Final UI empty card; product context retained; no fake listing/action. |
| Error | Final UI error card and 48 px retry action; no fake price/action. |
| Unavailable/unknown listings | Fail-closed into the truthful empty result when no customer-purchasable seller remains. |

## Responsive and accessibility review

| Case | Result |
| --- | --- |
| 320 px / 100% | Header, product summary, seller metadata, price and two compact text actions remain overflow-safe. |
| 390 px / 100% | Product Owner-approved W43A composition and original lineage golden remain unchanged. |
| 430 px / 100% | Content expands without changing the approved hierarchy or comparison density. |
| 390 px / 130% | Names, locality, metadata, prices, sort and actions remain readable; cards grow vertically as needed. |

Back, sort, shop and Cart V2 actions have explicit semantic labels. The Cart V2 action also has a physical-preparation tooltip. Touch targets remain at least 44/48 px. Poppins and the canonical Final UI tokens remain unchanged.

## Shared `ProductSellersSection` safety audit

The W43A shared API remains backward compatible:

- `visualPrototype` is optional and defaults to `false`;
- existing loading, empty, error, seller-tile and copy presentation remains on the default branch;
- only `SellerComparisonView` explicitly passes `visualPrototype: true`;
- both Product Details call sites omit the argument and therefore retain their existing presentation;
- R2 Final UI state cards, singular hierarchy and deterministic best-price treatment are all gated by the explicit opt-in;
- no caller receives a silent global visual change.

The existing ProductSellersSection test suite and all widget callers are included in regression coverage.

## Visual evidence

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

The Product Owner-approved lineage image remains at `test/widget/shop/goldens/w43a_seller_comparison_visual_prototype_390.png` and passes unchanged.

## Verification

- Targeted Seller Comparison matrix: 28 passed, 0 failed.
- Targeted plus shared-component deterministic matrix: 57 passed, 0 failed.
- Adjacent regression matrix across Home, Category, Product Listing, Product Details, ProductSellersSection callers, Shop Details, Cart V2, QR, Reviews, Wishlist and Auth/AuthGuard: 411 passed, 0 failed.
- Full Flutter suite: 1430 passed, 6 pre-existing conditional/live skips, 0 failed.
- `flutter analyze --no-pub`: no issues.
- Twelve R2 golden images were generated and visually inspected.
- No new skip and no weakened assertion.
- A transient 0.71% lineage-golden difference caused by wide-screen button padding was found during development; that padding change was removed and the approved lineage golden now passes unchanged.
- The long-merchant stress golden changed by 5.81% when unverified distance copy was removed from the opt-in Final UI fixture. Only that R2 stress golden was regenerated and visually re-inspected; the approved W43A lineage image remained unchanged.
- Initial sandboxed Flutter-test invocations could not write Flutter's user-profile tool-state file and were stopped before producing a test result. The same commands were rerun with the scoped Flutter-test permission; all recorded matrices above completed successfully.

## Boundaries

- Home changed: NO
- Reward changed: NO
- Category changed: NO
- Product Listing changed: NO
- Product Details changed: NO
- Shop Details redesigned: NO
- Cart V2 redesigned: NO
- Backend changed: NO
- Taxonomy changed: NO
- Canonical runtime enabled: NO
- Production accessed: NO
- Figma modified: NO
- Dark mode added: NO

`W43A_COMPOSITION_PRESERVED: PASS`

`SELLER_COMPARISON_FINAL_UI_V1_CANDIDATE: YES`
