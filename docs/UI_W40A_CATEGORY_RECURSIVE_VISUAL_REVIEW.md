# W40A Category / Recursive Browse Visual Review

## Final review status

W40A-R2 preserves the Product Owner-approved W40A composition and closes its bounded C1 polish, responsive behavior, recursive-depth proof and presentation-state evidence. The result is marked `CATEGORY_RECURSIVE_BROWSE_UI_V1_CANDIDATE`; it is a candidate for Integration/main, not a Production-final release.

Home, Reward, backend, canonical taxonomy data, Production, Figma and Product Listing presentation were not modified. The screen continues to use the W39 Final UI foundation: Poppins, `#146C6E`, `#B54732`, canonical spacing/radius/elevation and shared scaffold/surface primitives.

## Approved composition preserved

The compact header and back action, hierarchy breadcrumb, two-column grid, pastel icon surfaces, container/leaf interaction language and W39 Home relationship remain intact. No structural redesign was introduced.

The C1 changes are deliberately bounded:

- The child section heading is now `Alt kategoriler`; search-like copy was removed.
- The breadcrumb is shorter and less tall. Deep paths retain parent/current context plus a complete semantic path. At narrow widths or 130% text scale, the visible home label collapses to its icon to prevent overflow.
- Standard cards changed from 124 px to 118 px and scaled cards from 150 px to 142 px, a roughly 5% density reduction. The complete card remains the interaction surface, so touch targets are not reduced.
- Icon and cue surfaces were tightened proportionally and aligned to the revised card padding.
- A nine-child grid keeps the last item at normal column width in the left column; it is not stretched to full width.

## Canonical recursive-depth evidence

The evidence fixtures use names and paths from the staged canonical taxonomy truth.

| Level | Representative path | Result |
| --- | --- | --- |
| L2 | `Elektronik` → nine real L2 children | PASS; odd count, long names and scroll density remain balanced. |
| L3 | `Elektronik` → `Telefon & Aksesuarları` | PASS; real L3 containers and leaves use distinct navigation cues. |
| L4 | `Elektronik` → `Telefon & Aksesuarları` → `Cep Telefonları` | PASS; real L4 leaves remain readable and hand off with exact-leaf scope. |
| Long Turkish content | `Oyuncak & Hobi` → `Koleksiyon Ürünleri` | PASS at 130% text scale; the 48-character canonical child name stays meaningfully readable. |

Depth is derived from each canonical node, not from a fixed L2/L3/L4 route table. Containers open the next taxonomy depth. Assignable leaves open the existing Product Listing destination through `SubCategoryView` while preserving `TaxonomyProductQueryScope.exactLeaf`. Unavailable nodes do not behave as valid containers or leaves. Technical domain words are not exposed in customer copy.

## Final local visual evidence

All evidence is deterministic Flutter golden output generated from local canonical fixtures and visually inspected after generation.

| Scenario | Evidence |
| --- | --- |
| Original W40A lineage, retained unchanged | `test/widget/shop/goldens/w40a_category_recursive_browse_electronics_390.png` |
| Elektronik L2, 390 | `test/widget/shop/goldens/w40a_r2_electronics_l2_390.png` |
| Telefon & Aksesuarları L3, 390 | `test/widget/shop/goldens/w40a_r2_phone_l3_390.png` |
| Cep Telefonları L4/deep path, 390 | `test/widget/shop/goldens/w40a_r2_deep_l4_390.png` |
| Long canonical name at 130% scale, 390 | `test/widget/shop/goldens/w40a_r2_long_name_130_390.png` |
| Elektronik L2, 320 | `test/widget/shop/goldens/w40a_r2_electronics_l2_320.png` |
| Elektronik L2, 430 | `test/widget/shop/goldens/w40a_r2_electronics_l2_430.png` |
| Loading, 390 | `test/widget/shop/goldens/w40a_r2_loading_390.png` |
| Empty, 390 | `test/widget/shop/goldens/w40a_r2_empty_390.png` |
| Error, 390 | `test/widget/shop/goldens/w40a_r2_error_390.png` |
| Unavailable regulated node, 390 | `test/widget/shop/goldens/w40a_r2_unavailable_390.png` |

## Responsive, state and accessibility result

- 320, 390 and 430 px renders pass without horizontal layout failure. The primary 390 px composition is structurally unchanged.
- A dedicated 320 px / 130% test renders a 122-character deep path without overflow. Visible truncation is controlled and the complete hierarchy remains in the semantic label.
- Header, section copy, 48-character child label and Turkish characters `Ç Ğ İ Ö Ş Ü` remain safe at 100% and 130% scales.
- Back and full-card navigation remain at or above the 44/48 px interaction baseline. Container, leaf and unavailable actions expose meaningful Turkish semantics.
- Loaded, loading, empty, error and domain-supported unavailable states use the same Final UI language. No new backend state was invented.
- Unknown category nodes continue to receive the coherent neutral visual; mapping is name-based rather than index-based.

## Verification

- Category behavior and golden matrix: 13 passed, 0 failed.
- Adjacent Home/search/Product Listing/bottom navigation/AuthGuard and Cart V2/QR/Reviews/Wishlist/Seller Comparison/Auth matrix: 270 passed, 0 failed.
- Full Flutter suite: 1344 passed, 6 pre-existing conditional/live skips, 0 failed.
- `flutter analyze --no-pub`: no issues.
- No new skip and no weakened assertion.

## Deferred visual polish

Current V1 icons are accepted. A future professional child-category visual pass may refine `Güç, Şarj & Bağlantı` and `Akıllı Ev & Güvenlik`; this does not block the screen candidate and no large artwork pack was started.

`W40A_COMPOSITION_PRESERVED: PASS`

`CATEGORY_RECURSIVE_UI_V1_CANDIDATE: YES`

`HOME_CHANGED: NO`

`BACKEND_CHANGED: NO`

`TAXONOMY_CHANGED: NO`

`PRODUCTION_ACCESSED: NO`
