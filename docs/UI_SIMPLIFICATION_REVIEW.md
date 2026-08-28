# UI Simplification Review

## Minimum credible pilot visual scope

| Must be polished | Must be coherent/usable | May defer |
|---|---|---|
| Home, listing, product details, seller comparison, Shop Details, Cart V2, AuthGuard | Reviews/purchases, Nearby, wishlist, chat/notifications, profile/location, recovery/legal/support | Advanced motion, bespoke tablet, dormant future systems, Merchant-adjacent surfaces |

“Coherent/usable” still requires semantic tokens, readable content, state handling,
touch targets and no legacy marketplace contradiction. It does not require unique
illustration or editorial composition for every route.

## Simplified component set

### Foundation

Token extensions, typography, Button, TextField, BottomNav, ScreenShell, StateShell,
MediaFrame and Dialog/BottomSheet recipes.

### Commerce

CategoryCard/Row, ProductCard, MerchantCard, SellerPriceRow, RatingSummary,
CartShopHeader, CartItem, SingleStoreConflict, Status/Verified badge and QR sheet.

### Secondary recipes

Review, purchase, settings, address, conversation and notification rows can begin
as composed recipes and become public families only after repetition proves value.

## Simplifications rejected

- Blindly recolor existing screens without semantic tokens.
- Skip AuthGuard/error/empty states because primary screenshots look polished.
- Replace dynamic content with fixed Figma labels.
- Hide functionality to make screenshots easier.
- Mark the whole app final after only 390 px/light/default-state review.

## Commercialization-safe deferment rule

Defer an item when it is cosmetic-only, has no effect on comprehension/trust/touch/
text scale, is outside pilot target usage, and leaves no visible contradictory
system. Every deferment is recorded as V2/V3 with owner/release visibility.

## Outcome

The rollout is reduced to ten waves with a first showcase tranche of Home through
Cart/Auth. This avoids a full-app “big bang,” keeps three-agent work separable and
preserves room for a bounded post-pilot polish wave.
