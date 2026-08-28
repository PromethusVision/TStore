# K'pasa to EsnaftaVar Mapping

## Principle

K'pasa supplies useful interaction and composition references. EsnaftaVar supplies
the product semantics, brand roles, accessibility contract and runtime behavior.
No source K'pasa page is a runtime specification.

## Mapping matrix

| K'pasa reference | Reuse | Replace | EsnaftaVar target |
|---|---|---|---|
| Button variant matrix | State/size matrix idea | Colors, fonts, target sizes, checkout actions | Button: Primary/Secondary/Tertiary/Destructive × state |
| Text-field anatomy | Label, input, helper structure | Mixed font, fixed styling | Text/Search/Password/Select/Location states |
| Bottom bar distribution | Equal destination layout | Generic marketplace IA | Home/Nearby/Cart/Wishlist/Profile with auth/badges |
| Category tile/row | Compact icon-label composition | Demo taxonomy and fixed count | Dynamic CategoryCard/Row |
| Product card | Image/title/price scan order | Shipping/sale/checkout assumptions | Local merchant count, availability, favorite, fallback |
| Product-and-price row | Dense comparison layout | Generic commerce semantics | SellerPriceRow with shop, rating, distance and availability |
| Rating preview | Distribution/summary idea | Generic aggregate styling | ShopRatingSummary + verified marker |
| Status pattern | Compact status cue | Color-only/generic status | Commerce/trust StatusChip with text/icon |
| Search/filter patterns | Field and control composition | Hardcoded nodes/categories | Dynamic search, sort and category depth |
| Cards/surfaces | Basic grouping | 34 non-system card variants | Small canonical surface recipe set |
| Modals/sheets | Layout reference | Checkout/payment/shipping content | Cart conflict, QR, profile, filter and confirmation shells |

## EsnaftaVar-only components

- MerchantCard with physical shop actions.
- SellerPriceRow Mobile variants.
- VerifiedPurchaseBadge consuming server authority.
- CartShopHeader, CartItem and SingleStoreConflictState.
- Directions/location intent.
- Guest AuthGuard state that preserves public discovery.
- Product availability across nearby sellers.
- QR verified-purchase education and operational states.

## Rejected source concepts

- Buy Now, payment, shipping address, delivery selection and order tracking.
- Endless discount/sale decoration without authoritative data.
- Cold generic marketplace palette as the brand foundation.
- Fixed taxonomy labels or one screen per category depth.
- Merchant-management controls on customer surfaces.
- Ads/reward/badge visuals that imply an active engine.
- Fixed-height layouts that fail Turkish copy or text scaling.

## Customization budget

K'pasa should not be customized node-by-node. Use it only where one of these tests
passes:

1. The interaction is standard and already understood by customers.
2. The structure reduces engineering/design risk.
3. The result can be expressed with canonical semantic tokens.
4. It does not import a contradictory product assumption.

If a reference requires extensive overrides, an EsnaftaVar-native component is
simpler and more maintainable.

## Screen-level mapping

| Screen | K'pasa contribution | EsnaftaVar divergence |
|---|---|---|
| Home | Section rhythm, cards and search | Local location context, nearby shops, warm identity |
| Listing | Grid/list density and controls | Dynamic taxonomy depth, local seller availability |
| Product Details | Media/info hierarchy | “Which nearby shops have it?” as primary commerce question |
| Seller Comparison | Dense price rows | Distance, shop identity, physical availability and directions |
| Shop Details | Merchant/product composition | Physical visit CTA, local trust and no merchant admin |
| Cart V2 | Item list/quantity patterns | Single-store physical-intent semantics; no checkout |
| AuthGuard | Modal/page hierarchy reference | Public browsing plus protected-action continuation |

## Mapping acceptance

A migrated component is not accepted because it resembles K'pasa. It must:

- use approved EsnaftaVar tokens and Poppins roles;
- preserve existing callback/state/navigation semantics;
- pass Turkish, text-scale, contrast and touch-target checks;
- avoid contradictory checkout/payment/shipping language;
- render current dynamic data and all required states;
- match owner-approved critical screenshots within agreed tolerances.
