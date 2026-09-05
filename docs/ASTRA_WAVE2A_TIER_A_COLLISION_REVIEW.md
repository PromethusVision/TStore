# Astra Wave 2A — Tier A collision review

Status: **PRE-MERGE REVIEW PASS — 2026-09-05**.
Current main: `6cc5d1607da96415f788d5324006bc89fe85d554`.
Source: `origin/astra-ui/w45a-tier-a-prototype-batch-1` at
`b5fe6304d8b3bdf47ee6d40609ff47d409279622`.
Common ancestor: `4287972429d9befe4ef2637a565ea6d8a2393a5e`.
Integration branch: `integration/astra-wave2a-tier-a-batch`.

## Source and current-main truth

Fetch completed before review. Main equals the required base; there are no later
main commits to reconcile. All eight specified source checkpoints (8276d8d,
39a8653, 6a9542b, a261004, 4ae9d6d, e366149, b2652d6, b5fe630) are ancestors of
the fetched final source. In particular, the owner QR-copy correction a261004
is included. No earlier prototype checkpoint is being used as final truth.

The complete source delta from the common ancestor is **70 files**: 7 runtime
Dart, 4 test Dart, 57 PNGs and 2 documents. The reported **65 files / 54 new visual
proofs** describes the narrower closeout delta from a261004; these are different
comparison bases, not missing files. Source changes are confined to Shop, Cart,
Nearby presentation, one offer-card layout correction and local tests/evidence.
No backend, taxonomy, dependencies, configuration or shared foundation changes.

Main includes both Wave 1 Discovery and Auth/Startup integrations. Changed-path
intersection between complete source and complete main deltas from 4287972 is
**empty**. The following semantic review goes beyond that textual result.

## Collision classification and resolution contract

| Area / exact files | Classification | Evidence and reconciliation |
|---|---|---|
| `lib/features/shop/presentation/views/shop_profile_view.dart`, `cart_v2_view.dart`, `nearby_view.dart` | SEMANTIC_RECONCILIATION_REQUIRED | Source compositions are still default-off. Final integration must make the three approved presentations the normal constructor defaults, so all existing callers receive them. Keep the explicit legacy switch for comparison coverage; no route or business method is replaced. |
| `lib/features/shop/presentation/views/all_products_view.dart`, `widgets/home_search_bar.dart` | NO_CONFLICT | Wave 1 source is authoritative and remains untouched. Search passes the actual ShopEntity and currentUserIdProvider to ShopProfileView; its active-shop/ID/duplicate-navigation guards are retained. Its product/shop cards are local widgets, not SellerComparisonOfferCard. |
| `lib/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart`, `lib/core/common/widgets/navigation_menu.dart` | NO_CONFLICT | The same five tabs construct NearbyView and CartV2View. Constructor defaults activate the accepted layouts without editing shell selection or the login return-to-caller guard. No generated/named router or standalone AuthGuard class exists. |
| `lib/features/auth/presentation/`, auth/session/recovery listeners | NO_CONFLICT | Source does not modify these files. Wave 1 login/signup/startup/confirmation and auth/session behavior remain authoritative; target and adjacent tests will exercise them. |
| `lib/features/shop/presentation/widgets/seller_comparison_offer_card.dart` | SAFE_TEXTUAL | Only `_OfferFact` Text gains Flexible. Narrow 320 px / 130% distance text previously overflowed by 29–31 px. No formatting, distance calculation, seller choice, callback, price or add-to-cart rule changes. Main has no delta in this file. |
| `lib/features/shop/presentation/widgets/product_sellers_section.dart`, `views/seller_comparison_view.dart`, `views/product_details_view.dart` | NO_CONFLICT | ProductSellersSection is the sole direct runtime constructor of SellerComparisonOfferCard. Its Final branch is consumed by SellerComparisonView and the Final Product Details seller section. Existing W42/W43 goldens and new narrow conflict tests cover the shared fix. |
| Home / Product Listing / Search / Nearby / Shop cards | NO_CONFLICT | These use their own card compositions; they do not directly instantiate SellerComparisonOfferCard. They remain adjacent regression targets because they share shop/product destinations and Final UI foundations. |
| `lib/features/shop/presentation/views/cart_v2_view.dart` private quantity/recovery widgets | SAFE_TEXTUAL | Source adjusts wrapping, touch-target density and inherited label font in widgets consumed by both Cart presentations. Mutation methods and confirmation/QR methods are unchanged. Both legacy and Final presentation coverage must remain. |
| `lib/features/cart/` QR Cubit, domain, repositories and `presentation/widgets/cart_qr_session_bottom_sheet.dart` | NO_CONFLICT | Source has no changes. Final exact CTA `QR kod oluştur` invokes the existing `_preparePurchaseVerification` -> refresh/availability/pricing checks -> existing QR sheet, preserving double-submit and verified-purchase handoff. |
| `lib/features/shop/presentation/cubit/nearby_shops_cubit.dart`, proximity helper and location services/helpers | NO_CONFLICT | No source changes. Final rendering accepts only finite, non-negative distances of listed shops in ready state. Original consent, saved-location, settings/resume and duplicate navigation methods are reused. No coordinates/locality are generated. |
| `lib/core/ui/`, theme/tokens/state components | NO_CONFLICT | Existing authoritative primitives are consumed; no competing foundation or simultaneous shared rewrite. |
| Test helpers / golden infrastructure | NO_CONFLICT | Source adds three self-contained test files and W45 PNGs; only W43 test cases are added to an existing file. No shared harness/config/golden replacement across branches. Existing live-gated files remain unchanged. |
| Protocol and coordination documents | SEMANTIC_RECONCILIATION_REQUIRED | Old fresh-conversation rule is superseded by the current task. Update only its session section; append source closeout calibration and recompute actual reachable units. Preserve Wave 1 history and MD-10's inactive correction. |

## Approved integration actions and gate

Pre-merge gate **PASS**: no BLOCKER and no textual conflict is expected. Semantic
reconciliation is explicit above; merge cleanliness alone will not declare
the three screens DONE. Merge final source with `--no-ff`, enable the three
approved defaults, preserve both legacy assertions and default-Final behavior
coverage, then require targeted/adjacent tests, analyzer and one combined suite.

Shared change record:

```text
SHARED_COMPONENT_CHANGE_REQUIRED: YES
EXACT_FILES: lib/features/shop/presentation/widgets/seller_comparison_offer_card.dart
REASON: Flexible distance/fact text prevents narrow large-text overflow.
OWNER_BRANCH: integration/astra-wave2a-tier-a-batch (integrating source e366149)
COLLISIONS: NONE — no current-main edit in the same file.
REGRESSION: W43 Seller Comparison, W42 Product Details, product seller actions;
  adjacent Home, Category/Product Listing, Search/All Products, Nearby/Shop.
```

No structural redesign is authorized. Shop directions stay primary, products
stay core and communication secondary. Cart stays single-shop physical shopping
preparation. Nearby keeps truthful discovery and the existing privacy model.
Production/Development/Figma/backend/taxonomy are outside this integration.

Final acceptance, exact test/discovery results, actual merge/reconciliation
commits and recomputed inventory will be recorded after the combined gate.
