# W39A Home Visual Review

## Review scope

Wave 39A establishes the final light-mode customer foundation and applies it only to Home and its reusable primitives. Figma was not modified. Product logic, navigation, AuthGuards and data contracts are unchanged.

Primary review width is 390 x 844 logical pixels. Responsive tests also cover 320, 390 and 430 px plus 130% text scaling.

## Visual direction applied

- Warm neighborhood-commerce canvas instead of the prior cold blue-gray character.
- Trustworthy teal/green primary (`#146C6E`) and restrained terracotta accent (`#B54732`).
- Poppins-only hierarchy with compact but readable customer-marketplace density.
- Clear top journey: greeting -> location -> search -> optional Reward slot -> category discovery -> campaign -> products -> nearby merchants.
- 44 px minimum and 48 px preferred interactive sizing.
- Semantic surfaces, borders and shadows replace Home-local styling.
- Dynamic category row remains ready for all 24 canonical root categories; no count is hard-coded.

## Local visual evidence

All files are deterministic Flutter goldens generated from local fixtures; no production data was changed.

| Scenario | Evidence | Review result |
| --- | --- | --- |
| Guest | `test/widget/shop/goldens/w39a_home_guest_390.png` | Guest greeting and login-gated location guidance are visible; layout clean. |
| Authenticated | `test/widget/shop/goldens/w39a_home_authenticated_390.png` | Customer greeting and saved home location are visible; hierarchy clean. |
| Reward fixture | `test/widget/shop/goldens/w39a_home_rewardFixture_390.png` | Structural card sits between search and categories; fixture is test-only. |
| Long Turkish content | `test/widget/shop/goldens/w39a_home_longText_390.png` | Long category copy is bounded to three lines without overflow. |

## Component reuse

Home now composes `EsnaftaVarScaffold`, `EsnaftaVarSectionHeader`, `EsnaftaVarStateCard`, `EsnaftaVarSurfaceIconButton`, `RewardProgressSlot`, the existing Home component family and the existing customer bottom navigation. Product/favorite/shop/category behavior continues through the previous public inputs and destinations.

## State and safety review

- Categories, products and nearby merchants retain loading, empty and error states without fake runtime records.
- Reward is absent when disabled or when data is missing.
- Product and merchant cards protect two-line Turkish names; category tiles protect three lines.
- The campaign frame grows for narrow screens and scaled text rather than clipping.
- Safe areas, bottom navigation and scroll composition were exercised in widget tests.
- Primary/accent foreground contrast and body-text contrast meet the automated 4.5:1 threshold used by W39A tests.
- Poppins and both icon fonts are loaded in golden tests, so screenshots represent the real visual hierarchy.

## Functional regression result

- Targeted Home and adjacent contract matrix: 525/525 passed.
- Full suite: 1316 passed, 6 existing conditional skips, 0 failures.
- `flutter analyze --no-pub`: no issues.

## Product-owner review focus

1. Confirm the warmth and density of the teal/terracotta Home direction.
2. Confirm the discovery order and compact category/product presentation.
3. Review Reward Bar structure only; its language, economics and activation remain a later product decision.

`HOME_FINAL_FOUNDATION_READY: YES`

`FIGMA_MODIFIED: NO`

`REWARD_RUNTIME_ACTIVE: NO`
