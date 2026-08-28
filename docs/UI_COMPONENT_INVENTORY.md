# UI Component Inventory

> Wave 27 · current Flutter components reconciled with the canonical Figma layer.

## Counts and definitions

| Layer | Files | Widget classes | Public | Private/local |
|---|---:|---:|---:|---:|
| `lib/core/common/widgets` | 33 | 36 | 32 | 4 |
| Feature `presentation/widgets` | 60 | 121 | 61 | 60 |
| **Reusable/component layer total** | **93** | **157** | **93** | **64** |
| View-local widget classes | 38 view files | 248 | 40 | 208 |

A public class is not automatically a design-system component. Several public
widgets are listeners, forms or behavior adapters; many useful presentational
patterns are private classes trapped inside large view files.

## Current reusable families

| Current cluster | Representative Flutter files | Current condition | Target canonical family/approach |
|---|---|---|---|
| App shell/navigation | `navigation_menu.dart`, `customer_bottom_navigation.dart`, `app_bar.dart` | Functional semantics plus raw visual values | BottomNav + shell/app-bar primitives |
| Home/discovery | `home_*`, `promo_banner_carousel_slider.dart` | Home-specific token island | Canonical search/location/category/product/merchant composition |
| Product cards | `vertical_product_card.dart`, `horizontal_product_card.dart`, private cards in listing/recent/shop | Material and layout duplication | ProductCard grid/list + shared image/favorite/status slots |
| Category | `category_tab.dart`, `home_categories.dart`, private subcategory/list rows | Data and layout coupled | CategoryCard/CategoryRow |
| Merchant/shop | `brand_card.dart`, `brand_showcase.dart`, shop-local private widgets | “Brand” legacy language and shop-local duplication | MerchantCard + shop identity primitives |
| Seller comparison | `product_sellers_section.dart`, `product_seller_price_summary.dart` | Feature-local complex rows | SellerPriceRow Mobile states |
| Price/title/status | `product_price_text.dart`, `product_title_text.dart`, `sale_tag.dart` | Legacy semantics and hardcoded styling | Semantic text/status primitives |
| Cart | `cart_v2_view.dart`, `cart_qr_session_bottom_sheet.dart`, quantity widget | Most presentation remains private in a 1,580-line view | CartShopHeader, CartItem, conflict and QR state compositions |
| Rating/review | rating widgets, `user_review_card.dart`, review-view private widgets | Several partial patterns | ShopRatingSummary, VerifiedPurchaseBadge, future ReviewCard/editor |
| Forms | auth form widgets, `new_address_form.dart`, `customer_light_input_theme.dart` | Mixed global theme and local decoration | TextField types/states + form feedback primitives |
| Dialog/sheet | account deletion dialog, edit-profile sheet, QR session sheet, view-local dialogs | Inconsistent shell, spacing and destructive hierarchy | Dialog/BottomSheet shells; preserve callbacks/results |
| Loading/empty/error | `product_shimmer.dart`, `progress_indicator.dart`, many private status widgets | Repeated and visually inconsistent | StateShell, skeleton recipes and retry action |
| Images | `rounded_image.dart`, `product_image_fallback.dart`, screen-local fallbacks | Multiple ratios/fallbacks; resolution logic must stay intact | MediaFrame + purpose-specific aspect/placeholder variants |
| Settings/list tiles | settings/profile entity widgets | Related patterns duplicated | Canonical settings/list-row composition |

## Canonical Figma V1 inventory

The verified source defines 14 public families. Phase C adds Mobile variants but
does not create new public families.

| Canonical family | Known variants/nodes | Current Flutter mapping readiness |
|---|---:|---|
| Button | 16 | Existing themed/raw buttons; API adapter required |
| TextField | 30 | Multiple form decorations; adapter and validation-state map required |
| BottomNav | 5 | Exact five destinations exist; badge/auth behavior must be retained |
| CategoryCard | 4 | Home/category implementations exist; dynamic taxonomy required |
| CategoryRow | 2 | Several local list patterns; consolidate after data contract lock |
| ProductCard | 4 | High duplication; first major shared extraction candidate |
| SellerPriceRow | 3 + 3 Mobile states | Feature-local row; compact mobile mapping documented |
| MerchantCard | 2 + 2 Mobile states | Shop/brand terminology reconciliation needed |
| ShopRatingSummary | 2 | Existing rating widgets can supply data |
| VerifiedPurchaseBadge | 1 | Must consume server-authoritative state only |
| CartShopHeader | 1 + Mobile | Private Cart V2 header is current integration point |
| CartItem | 3 + 3 Mobile states | Private Cart V2 card is current integration point |
| SingleStoreConflictState | 1 + Mobile | Dialog/state must preserve explicit replacement choice |
| StatusChip | 5 | Map only real current states; future slots remain dormant |

## Missing canonical families for full rollout

These are gaps, not permission to create a large speculative library:

- screen shell and app-bar/safe-area patterns;
- modal, dialog, bottom-sheet and snackbar shells;
- loading skeleton, empty and retry state composition;
- image/media frame and fallback variants;
- search/filter/sort controls and chips;
- review card/editor and eligibility message;
- chat conversation/message and notification row;
- settings/profile/list row;
- location permission/auth-required prompt;
- QR sheet/camera/failure compositions.

Each missing family must pass a “used by at least two surfaces or materially
protects accessibility/behavior” test before becoming public.

## Consolidation candidates

### P0: required before critical-screen migration

1. Semantic token adapter and Theme extension.
2. Button, TextField and BottomNav primitives.
3. ProductCard and shared MediaFrame.
4. CategoryCard/Row.
5. SellerPriceRow and MerchantCard.
6. CartShopHeader/CartItem/conflict shell.
7. Loading/empty/error StateShell.

### P1: required for full Customer consistency

1. Review/verified badge and rating summary.
2. Dialog/bottom-sheet/snackbar shells.
3. Settings/profile rows.
4. Conversation/notification rows.
5. Search/filter/location field variants.

### Defer unless repetition is proven

- one-off marketing sections;
- highly specialized legal-document layout;
- decorative hero compositions;
- future ads/reward/gamification components;
- Merchant-only editor/scanner widgets.

## Behavioral adapter rule

Canonical widgets receive data, callbacks and semantic state; they do not own
navigation, repositories, Cubits, auth policy, QR authority, cart rules or review
rights. Existing screen/controller code remains the behavioral owner during visual
migration. This is the primary defense against cosmetic regressions.

## Duplication risk hotspots

- Product cards appear in core widgets and as private implementations in listing,
  shop, recently viewed and wishlist surfaces.
- Loading/empty/error and image fallback code is repeated in many screens.
- Buttons and fields mix global themes, local themes and direct Material styling.
- Shop identity appears through legacy `brand_*`, private shop widgets and seller
  rows; terminology and visual semantics must be normalized without changing data.
- Cart V2 contains 16 private classes; extraction must keep keys, callbacks and
  Cubit state branching stable.
