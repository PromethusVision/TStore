# UI Contrarian Review

## Is K'pasa being customized too much?

Potentially. Fourteen canonical families are defensible, but a full attempt to
rebuild every K'pasa card, modal and state would recreate a large template system.
Use K'pasa only for proven structural patterns. EsnaftaVar-native seller, shop,
Cart V2, AuthGuard and verified-purchase components deserve custom semantics.

## Are we creating design-system overkill?

The risk is real if every private widget becomes public. A pilot needs semantic
tokens, Button, TextField, BottomNav, StateShell, MediaFrame and the critical
commerce families. One-off marketing/legal layouts can remain compositions. A
component should be public only when reused or when it protects behavior,
accessibility or product meaning.

## Could fewer custom components produce a better result?

Yes. The plan prefers about 15–18 critical families and recipes over a universal
component for every section. The current 157 component classes should shrink by
consolidating duplicate cards/states, not be mirrored one-for-one.

## Which current screens are already good enough?

Functionally, launch/auth recovery, legal/help and several settings routes already
have usable structure. Home already demonstrates warmer colors. They still need
token, text-scale and consistency review, but bespoke redesign of every low-traffic
surface is not required before the pilot.

## Are cosmetic changes risking functional regressions?

Yes—especially in Cart V2, search/listing, Nearby, reviews, chat and AuthGuard.
These screens contain state, navigation and realtime logic near private visual
classes. The plan uses compatibility adapters, one large-view owner and existing
functional suites instead of broad rewrites.

## Are we delaying commercialization for unnecessary polish?

A simultaneous 33-screen redesign would. The proposed order polishes the public
showcase and physical-commerce journey first, then brings secondary surfaces to a
coherent minimum. V3 decoration, advanced motion, full tablet layouts and dormant
future-engine UI are explicitly deferable.

## What can safely wait?

- advanced motion and illustrations;
- bespoke tablet layouts;
- Merchant-adjacent UI parity;
- dark mode if an explicit light-only pilot is approved;
- low-traffic legal/help decorative polish;
- future ads/reward/gamification components;
- fine shadow/icon variation with no comprehension impact.

## What truly matters for the main showcase?

1. Home feels unmistakably local, warm and trustworthy.
2. Search/category/product paths remain fast and understandable.
3. Seller comparison exposes price, distance, availability and shop identity.
4. Shop Details makes the physical next action obvious.
5. Cart V2 never implies shipping/payment/checkout.
6. Guest AuthGuard is respectful and recoverable.
7. Turkish copy, media fallbacks, loading/error and accessibility look intentional.

## Contrarian conclusion

Do not wait for universal pixel perfection. Do not ship a half-migrated global
theme either. The smallest credible route is a consistent token/primitives layer,
owner-approved critical screens, coherent secondary surfaces and an exact artifact
acceptance pass.
