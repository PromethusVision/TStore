# W53C — Canonical category Icon V1 audit

Status: **CATEGORY_ICON_V1_ACCEPTED — W53D Product Owner decision**

On 2026-09-16 Europe/Istanbul, the Product Owner explicitly accepted this
Codex-selected set as the commercial V1 category icons. Category icon art
direction is **CODEX-SELECTED V1 / PRODUCT OWNER ACCEPTED**. Final custom
24-category art is **DEFERRED UNTIL APPLICATION COMPLETION** and no longer
blocks Customer V1 completion. This is not final handcrafted art-direction
approval; minor metaphor preferences remain deferred polish. No further owner
micro-decision is required for this integration.

The original W53C delivery awaited acceptance; that historical state and the
review labels on its screenshots are superseded by this explicit W53D decision.
The technical evidence below is retained. Technical checks alone do not grant
Product Owner acceptance, and artwork from another task was not imported.

## Scope and baseline

- Base: `c10b40dbeb450c59ee2277f90421ea5c0ef2dcaf`; verified `origin/main` after fetching/pruning before implementation.
- Task branch: `ui/w53c-canonical-category-icon-polish` in an isolated worktree of the authorized clean repository.
- Authority for root identities/order: existing `docs/TAXONOMY_W36_CATEGORY_IMPORT.csv`, level 1 rows, and `test/helpers/canonical_taxonomy_test_support.dart`. The test checks their exact ordered agreement with the existing 24-entry visual catalog.
- Local UI changes only. No backend, taxonomy data, category ID/name/order, Home composition, route/navigation, Reward, theme-mode policy, Production, Development, Figma or device changes.
- No APK/AAB build or distribution. No custom AI artwork pack. One bundled font subset; no new Dart package or lockfile change.

## Missing-icon investigation: evidence and limits

The Product Owner reported at least two blank category cards in an earlier intermediate visual, but could not identify the cards or image. On the verified base, a fresh render of all 24 canonical icons at their actual Final UI size showed **24 visible / 0 missing** in both simulated OS light and OS dark. The full category route also rendered all 24 cards. No canonical mapping was null, neutral, zero-size, clipped or indistinguishable from its surface in that reproduction.

**The exact two originally reported categories and their historical cause remain UNKNOWN.** Do not interpret the fresh baseline as disproving that report, or claim those two have been independently identified or fixed. The Product Owner subsequently requested the initial V1 set without requiring that earlier image to be recovered.

Confirmed source issues and changes:

1. Final UI previously preferred `CategoryEntity.imageUrl` over the chosen canonical icon. An unrelated image could therefore replace the semantic mapping; a successfully decoded transparent image would not trigger the image-error fallback. This branch was present in source; a transparent image from the original reported screenshot was not recovered. W53C makes canonical roots and recognized aliases use the intentional local icon. Custom unknown categories retain their image behavior. Regression tests cover conflicting asset/network values.
2. Existing W53A Home evidence mixed legacy black image assets and Material icons. The legacy `Spor` name fell through to a neutral category symbol. Its recognized alias now resolves to the sports icon.
3. Several meanings were weak: roller skate for general shoes, briefcase for bags/accessories, leaf for personal care, eye for eyewear; food and kitchenware both used cutlery. They now have clearer distinct representatives.
4. Stable alias IDs previously pointed to integer positions in the visual list. They now point to canonical names. Icon and surface selection are independent of incoming category order. Turkish case/diacritics and whitespace are normalized for visual lookup only.
5. The recursive visual resolver now delegates canonical L1 identities to the same catalog used by Home and the full category screen. Existing child-category mappings remain in place.

The baseline raster tests passed (OS light, OS dark, full route). An initial audit-only metadata test used an older JSON fixture and failed; it was corrected to read the current W36 CSV authority. This was a test-fixture selection error, not an application failure.

## Before: all 24 rendered and inspected

`VISIBLE` below means actual Final UI foreground pixels, not merely an `IconData` declaration. Contrast was PASS for every row, with the same existing navy/pastel palette as after. Visual and semantic ratings are engineering review judgments, separate from Product Owner acceptance. Before assets use the `material:` prefix.

| Category | Before icon | Visibility | Semantic | Quality | Contrast | Action |
|---|---|---|---|---|---|---|
| Gıda & İçecek | restaurant_rounded | VISIBLE | AMBIGUOUS | WEAK | PASS | Grocery goods; distinguish from kitchenware |
| Giyim & Moda | checkroom_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Clothing silhouette in shared family |
| Ayakkabı | roller_skating_rounded | VISIBLE | FAIL | WEAK | PASS | Shoe without skate wheels |
| Çanta & Aksesuar | business_center_rounded | VISIBLE | AMBIGUOUS | WEAK | PASS | Handled bag instead of office briefcase |
| Elektronik | devices_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Bilgisayar & Tablet | computer_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Beyaz Eşya & Ev Aletleri | kitchen_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Ev & Yaşam | chair_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Züccaciye & Mutfak | flatware_rounded | VISIBLE | AMBIGUOUS | WEAK | PASS | Pan; distinguish from food |
| Yapı, Hırdavat & Tesisat | handyman_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Otomotiv & Motosiklet | directions_car_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Kozmetik & Kişisel Bakım | spa_rounded | VISIBLE | AMBIGUOUS | WEAK | PASS | Care bottle and comb instead of leaf |
| Anne & Bebek | child_friendly_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Oyuncak & Hobi | toys_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Müzik & Enstrüman | piano_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Spor & Outdoor | fitness_center_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family; also recognize legacy Spor alias |
| Kitap | menu_book_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Kırtasiye & Ofis | edit_note_rounded | VISIBLE | PASS | WEAK | PASS | Larger, clearer pen/note glyph |
| Evcil Hayvan Ürünleri | pets_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Gözlük & Optik | visibility_rounded | VISIBLE | AMBIGUOUS | WEAK | PASS | Eyeglass frame instead of generic eye |
| Saat & Takı | watch_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Sağlık & Medikal | medical_services_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |
| Çiçek & Bahçe | local_florist_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Potted plant in shared family |
| Hediyelik & Parti | redeem_rounded | VISIBLE | PASS | ACCEPTABLE | PASS | Shared family and size |

Before review: 1 semantic FAIL, 5 AMBIGUOUS, 7 visually WEAK; all 24 visible in the fresh reproduction. Blank cards reported by the Product Owner: at least 2, identities unconfirmed.

## After: intentional 24/24 mapping

Every listed asset has the `symbols-rounded:` prefix, font family `EsnaftaVarCategorySymbols`, and one constant codepoint in `CategorySymbols`. Ink counts are measured on the actual 52 x 52 Final UI rendering at device pixel ratio 1. Both OS modes yielded identical RGBA pixels for every icon.

| Category | Symbol / codepoint | Meaning | Visible ink pixels | Visibility | Semantic | Quality | Contrast |
|---|---|---|---:|---|---|---|---|
| Gıda & İçecek | grocery / EF97 | Grocery goods, fruit | 146 | VISIBLE | PASS | GOOD | PASS |
| Giyim & Moda | apparel / EF7B | Shirt | 134 | VISIBLE | PASS | GOOD | PASS |
| Ayakkabı | steps / F6DA | Shoe silhouette | 130 | VISIBLE | PASS | GOOD | PASS |
| Çanta & Aksesuar | shopping_bag / F1CC | Handled bag | 132 | VISIBLE | PASS | GOOD | PASS |
| Elektronik | devices / E326 | Screen and mobile device | 128 | VISIBLE | PASS | GOOD | PASS |
| Bilgisayar & Tablet | computer / E31E | Computer | 118 | VISIBLE | PASS | GOOD | PASS |
| Beyaz Eşya & Ev Aletleri | kitchen / EB47 | Refrigerator | 138 | VISIBLE | PASS | GOOD | PASS |
| Ev & Yaşam | chair / EFED | Armchair | 158 | VISIBLE | PASS | GOOD | PASS |
| Züccaciye & Mutfak | skillet / F543 | Cooking pan | 127 | VISIBLE | PASS | GOOD | PASS |
| Yapı, Hırdavat & Tesisat | handyman / F10B | Hand tools | 173 | VISIBLE | PASS | GOOD | PASS |
| Otomotiv & Motosiklet | directions_car / EFF7 | Motor vehicle | 160 | VISIBLE | PASS | GOOD | PASS |
| Kozmetik & Kişisel Bakım | health_and_beauty / EF9D | Care bottle and comb | 180 | VISIBLE | PASS | GOOD | PASS |
| Anne & Bebek | child_friendly / EF80 | Baby stroller | 113 | VISIBLE | PASS | GOOD | PASS |
| Oyuncak & Hobi | toys / E332 | Toy vehicle | 181 | VISIBLE | PASS | GOOD | PASS |
| Müzik & Enstrüman | piano / E521 | Piano keys | 168 | VISIBLE | PASS | GOOD | PASS |
| Spor & Outdoor | fitness_center / EB43 | Dumbbell | 126 | VISIBLE | PASS | GOOD | PASS |
| Kitap | menu_book / EA19 | Open book | 161 | VISIBLE | PASS | GOOD | PASS |
| Kırtasiye & Ofis | edit_note / E745 | Pen and writing | 81 | VISIBLE | PASS | ACCEPTABLE | PASS |
| Evcil Hayvan Ürünleri | pets / E91D | Animal paw | 250 | VISIBLE | PASS | GOOD | PASS |
| Gözlük & Optik | eyeglasses / F6EE | Eyeglass frame | 98 | VISIBLE | PASS | GOOD | PASS |
| Saat & Takı | watch / E334 | Wristwatch | 112 | VISIBLE | PASS | GOOD | PASS |
| Sağlık & Medikal | medical_services / F109 | Medical case | 134 | VISIBLE | PASS | GOOD | PASS |
| Çiçek & Bahçe | potted_plant / F8AA | Potted plant | 148 | VISIBLE | PASS | GOOD | PASS |
| Hediyelik & Parti | redeem / E8F6 | Wrapped gift | 188 | VISIBLE | PASS | GOOD | PASS |

All 24 glyph masks are different; fallback count is 0. Unknown categories intentionally use `category / E72C`, not a random category. Existing noncanonical Manav/Fırın/Kasap child/legacy representations are outside this L1 artwork scope.

## Visual specification and font provenance

- Material Symbols Rounded, fixed `FILL=0`, `wght=400`, `GRAD=0`, `opsz=24`. Consistent native glyph design; the paw retains that family's recognizable solid silhouette.
- Final UI glyph: 28 logical pixels, centered in the existing 52 x 52 surface with existing 16-pixel corner radius. Prototype icon slots also use the same 28-pixel family; their existing surrounding geometry is retained.
- Existing navy `#17233B`; existing pastel surfaces, now selected by named visual tone rather than incoming list position.
- Contrast ratios for the six surfaces: `#DCEDEA 12.94:1`, `#E4F0E0 13.31:1`, `#FFEDD3 13.66:1`, `#FFE1DC 12.73:1`, `#F9DFDF 12.42:1`, `#DDEDEA 12.97:1`. Test threshold: at least 4.5:1 for all 24.
- App remains light-only; OS light/dark simulation produced identical icon pixels. No theme-mode feature change.
- `assets/fonts/EsnaftaVarCategorySymbols.ttf`: static TrueType subset, 25 symbols (24 plus neutral fallback), 10,236 bytes.
- Font SHA-256: `589353c1bcb0e2663eefe02722b82bcea3afa4429cd7e70512d71150f5c98d2f`.
- Font registered once in `pubspec.yaml`; all `IconData` declarations are compile-time constants under `@staticIconProvider`.
- Apache 2.0 license copied to `assets/fonts/EsnaftaVarCategorySymbols.LICENSE.txt` from the [official icon repository](https://github.com/google/material-design-icons/blob/master/LICENSE).
- Official [Material Symbols guide](https://developers.google.com/fonts/docs/material_symbols) documents the family, axes, subsetting and self-hosting. Codepoint names were checked against the [official Rounded codepoint file](https://github.com/google/material-design-icons/blob/master/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.codepoints).
- The font was obtained from the official Google Fonts CSS endpoint, `family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0`, with `display=block` and the following sorted `icon_names`. The returned static TTF URL used version `v373`; the committed asset/hash is the reproducible reference, not a runtime network dependency.

```text
apparel,category,chair,child_friendly,computer,devices,directions_car,edit_note,eyeglasses,fitness_center,grocery,handyman,health_and_beauty,kitchen,medical_services,menu_book,pets,piano,potted_plant,redeem,shopping_bag,skillet,steps,toys,watch
```

## Render evidence

These are actual Flutter widget/golden renders using local mock data and the bundled font, not design mockups or physical-device screenshots. Home uses the existing Final UI content and eight-card limit; the full-screen evidence is reached through the existing `Tüm kategoriler` action.

- [Home 390: eight canonical categories and Tüm kategoriler](../test/widget/shop/goldens/w53c_home_canonical_eight_390.png)
- [All 24 categories: review contact sheet](../test/widget/shop/goldens/w53c_after_canonical_24_contact_sheet.png)
- [Full category screen: 24 actual cards at 390](../test/widget/shop/goldens/w53c_all_categories_24_390.png)
- [Fresh baseline contact sheet](../test/widget/shop/goldens/w53c_before_canonical_24_contact_sheet.png)

The 12 existing related golden images were updated for the intentional icon/surface changes. Their dimensions are unchanged. Image differences in the Home goldens are confined to category cells; the Home composition, banner, Reward and bottom navigation remain unchanged.

## Validation

| Check | Result |
|---|---|
| Targeted UI/golden tests (five related test files) | PASS: 47 tests |
| Full Flutter suite, without updating goldens | PASS: 2,094 passed, 0 failed, 6 existing gated skips |
| Baseline comparison | 2,088 existing passes plus 6 added tests; no new skips |
| `flutter analyze --no-pub` | PASS: no issues |
| `git diff --check` and scoped secret/PII scan | PASS |

The existing gated skips are Auth/RLS (1), product reviews (1), Development Realtime (2), Production demo smoke (1), and Production read-only smoke (1). No live-test opt-in flags or external backend configuration were supplied. Two initial test-style analyzer notices were fixed with braces; final analysis is clean.

Commands used for reproducible validation:

```text
flutter test --no-pub test/widget/shop/w53c_category_icon_polish_test.dart test/widget/shop/w39a_category_visual_mapping_golden_test.dart test/widget/shop/w39a_home_visual_review_golden_test.dart test/widget/shop/home_categories_test.dart test/widget/shop/w53b_all_categories_flow_test.dart
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
git diff --check
```

New checks cover the authoritative set/order, 24 unique mappings/codepoints, zero canonical fallback, stable identity resolution with reversed input/unrelated IDs, Turkish name normalization, root resolver consistency, contrast, actual rendered ink/nonzero size, no clipping, 24 distinct glyph masks, identical OS-light/dark pixels, eight Home cards, the full 24-card route, and protection from image overrides. Custom category image behavior is still tested. Existing routing and state assertions are retained.

Local test logs remain under ignored `build/w53c/`; raw logs containing machine paths are not committed. This document and the committed visual evidence contain no local user paths, credentials, tokens or device identifiers.

## Result flags

```text
ALL_24_CATEGORY_ICONS_AUDITED: PASS
MISSING_CATEGORY_ICONS_BEFORE: 0 (fresh reproduction; reported >=2, identities UNKNOWN)
MISSING_CATEGORY_ICONS_AFTER: 0
CANONICAL_MAPPING_24_24: PASS
CANONICAL_FALLBACK_USAGE: 0
SEMANTIC_MISMATCHES_REMAINING: 0 (engineering review; V1 accepted by Product Owner)
VISUAL_FAMILY_CONSISTENT: PASS
LIGHT_THEME_ICON_CONTRAST: PASS
SYSTEM_DARK_ICON_VISIBILITY: PASS
HOME_8_CATEGORY_ICONS: PASS
FULL_24_CONTACT_SHEET: PASS
FULL_TEST_SUITE: PASS
ANALYZER: PASS
BACKEND_CHANGED: NO
TAXONOMY_CHANGED: NO
PRODUCTION_ACCESSED: NO
FIGMA_ACCESSED: NO
PRODUCT_OWNER_V1_ACCEPTANCE: ACCEPTED
READY_FOR_INTEGRATION: YES
STATUS: CATEGORY_ICON_V1_ACCEPTED_CUSTOM_ART_DEFERRED
```

W53C itself did not merge main. W53D integrates this accepted V1 set after its
independent validation. Final custom artwork remains deferred until application
completion and is not an additional integration gate.
