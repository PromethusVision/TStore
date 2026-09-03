# Wave 44A — Next 10 Customer UI Work Packages

Durum: **PROPOSED PLAN — NO IMPLEMENTATION**  
Base: `origin/main@c0462dbaf3955a7a064f05c214e2517092629e3b`

## Paketleme kuralları

- Paketler inventory'deki 54 kalan birimi bir kez kapsar; toplam beklenen doğrudan
  efor **250 agent-hour**dur.
- Home, Category/Recursive Browse, Product Listing, Product Details ve Seller
  Comparison yeniden açılmaz.
- Aynı Dart dosyası veya transaction/business contract ailesi iki agent arasında
  bölünmez.
- `core/ui`, global navigation, auth/deep-link listener ve shared theme yazarlığı
  Integration Agent'tadır.
- Product Owner visual gate yalnız Tier A composition için kullanılır.

## Öncelik özeti

| Priority | Package | Scope | Tier | Expected hours | Figma | Visual approval | Parallel-safe | Integration order |
|---:|---|---|---|---:|---|---|---|---:|
| 1 | WP-01 Shop Details foundation | Shop profile/details ve shop-product handoff | A | 12 | HEAVY | YES | YES, Auth ile | 2 |
| 2 | WP-02 All Products + Search | Catalog ve search modes, suggestions/results | A | 17 | HEAVY | YES | YES, Auth ile; kendi içinde NO | 3 |
| 3 | WP-08 Auth + Startup essentials | Launch, onboarding, login/signup, confirmation/recovery, legal | B/C | 30 | LIGHT/NONE | NO | YES, discovery ile | 1 |
| 4 | WP-03 Nearby + Location | Nearby, distance/location states ve dialogs | A/C | 23 | HEAVY | YES | NO, WP-01/02 ile shared shop primitives | 4 |
| 5 | WP-04 Cart V2 + Customer QR | Cart, conflicts/confirmations, QR session sheet | A/B/C | 29 | HEAVY/LIGHT | YES | YES, discovery ile; WP-05/06 ile NO | 5 |
| 6 | WP-05 Purchases + Shop Ratings | Verified purchase history, rating history/editor | A/B | 25 | HEAVY | YES | NO, WP-04 önce | 6 |
| 7 | WP-06 Product Reviews | Review list/eligibility/editor/delete | A/B/C | 20 | HEAVY/LIGHT | YES | NO, WP-05 contract önce | 7 |
| 8 | WP-09 Account Hub | Settings, profile, saved locations, privacy, help, modals | B/C | 44 | LIGHT/NONE | NO | WP-08 sonrası; discovery ile YES | 9 |
| 9 | WP-07 Customer Messaging | Chat detail ve conversation list | A/B | 22 | HEAVY/LIGHT | YES | YES, transaction hattıyla | 8 |
| 10 | WP-10 Secondary Customer Library | Wishlist, coupons, recent, notifications, shared feedback | B/C | 28 | LIGHT/NONE | NO | PARTIAL; notifications hedeflerden sonra | 10 |

Integration sırası priority ile aynı olmak zorunda değildir. Auth önce entegre
edilir; Messaging, Notifications ve Account Hub'ın target navigation'ları
stabilize olduktan sonra final birleşimi yapılır.

## WP-01 — Shop Details foundation

- Scope: `ShopProfileView`, product list/card, contact/chat CTA, loading/empty/error,
  correct shop/location data ve back navigation.
- Likely files: `lib/features/shop/presentation/views/shop_profile_view.dart`,
  yalnız gerekli shop-card/widgets ve karşılık gelen widget/golden tests.
- Tier: A; 12 h.
- Figma: FIGMA_HEAVY; tek 390 px prototype.
- Visual approval: YES.
- Reuse: Product Details/Seller Comparison header, state, product card ve CTA
  dili.
- Parallel: Auth paketiyle YES. Nearby veya Search agent'ıyla aynı shared shop
  widget'ında eşzamanlı NO.
- Unlocks: Nearby ve search shop-result presentation.

## WP-02 — All Products + Search

- Scope: normal catalog mode ile search/suggestions/results/no-result mode;
  category/shop/product handoff ve supported sort/filter behavior.
- Likely files: `lib/features/shop/presentation/views/all_products_view.dart`,
  `home_search_bar.dart`, ilgili search/product tests.
- Tier: iki A surface; 17 h incremental total.
- Figma: iki HEAVY surface state'i, tek coordinated owner session.
- Visual approval: YES.
- Reuse: Final Product Listing grid/product card, category header, StateCard.
- Parallel: Catalog ve Search aynı dosyada olduğu için kendi içinde NO. Auth ile
  YES; WP-01 shared shop primitive netleşmeden final integration yapılmaz.
- Unlocks: Home “Tümünü Gör” ve search commercialization path.

## WP-03 — Nearby + Location

- Scope: Nearby list/map-like composition, current/saved location, permission,
  service-disabled, acquisition loading, consent ve distance states.
- Likely files: `nearby_view.dart`, `location_helper.dart`,
  `helper_functions.dart` içindeki location-only surfaces ve location tests.
- Tier: A + C; 23 h.
- Figma: HEAVY yalnız Nearby ana composition; dialogs için NOT_REQUIRED.
- Visual approval: YES, yalnız Nearby.
- Reuse: Shop Details cards, Home location bar, Saved Locations, StateCard.
- Parallel: WP-01/WP-02 ile shared shop/location primitives nedeniyle final
  closeout sırasında NO. Cart/Auth ile YES.
- Integration prerequisite: WP-01 ardından WP-02.

## WP-04 — Cart V2 + Customer QR

- Scope: cart loaded/empty/error, quantity/remove/clear, single-shop conflict,
  refreshed total confirmation ve two-minute customer QR session sheet.
- Likely files: `cart_v2_view.dart`,
  `lib/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart`,
  Cart/QR widget tests.
- Tier: A + B + C; 29 h.
- Figma: Cart HEAVY; QR sheet LIGHT.
- Visual approval: YES, Cart composition.
- Reuse: Product/listing cards, CTA, StateCard, SurfaceIconButton.
- Parallel: Discovery hattıyla YES. Purchases/Reviews ile contract ve target
  navigation çakışması nedeniyle NO.
- Safety: Checkout/payment/order/shipping semantiği eklenmez; QR payment değildir.

## WP-05 — Purchases + Shop Ratings

- Scope: verified purchase history/tabs, QR-result focus, shop detail handoff,
  rating editor ve customer ratings history.
- Likely files: `purchases_view.dart`, `customer_ratings_view.dart`, ilgili rating
  widget/tests.
- Tier: A + B; 25 h.
- Figma: Purchases HEAVY; rating sheet/history NOT_REQUIRED.
- Visual approval: YES, Purchases.
- Reuse: final product/shop cards, section header, state surfaces.
- Parallel: WP-04 tamamlanmadan NO; WP-01 shop handoff stabilize olduktan sonra.
- Safety: verified purchase “order/payment” olarak yeniden adlandırılmaz.

## WP-06 — Product Reviews

- Scope: review list, aggregate/evidence copy, guest/ineligible/eligible states,
  create/edit sheet ve delete confirmation.
- Likely files: `product_reviews_view.dart`, review widgets/tests.
- Tier: A + B + C; 20 h.
- Figma: Reviews HEAVY; editor LIGHT.
- Visual approval: YES, main screen.
- Reuse: Product Details header/product identity, StateCard, form/CTA language.
- Parallel: WP-05 contract sonucu ile NO; Auth implementation ile file-level YES
  fakat integration'da review-auth regression birlikte çalışır.
- Safety: one active review/customer+canonical product ve verified-purchase
  eligibility aynen korunur.

## WP-07 — Customer Messaging

- Scope: conversation list, chat detail, composer/send/loading/error/empty,
  keyboard/long-message, unread refresh ve pending-product-chat handoff.
- Likely files: `conversations_view.dart`, `chat_view.dart`, chat widgets/tests.
- Tier: A + B; 22 h.
- Figma: Chat HEAVY; Conversations LIGHT.
- Visual approval: YES, Chat detail.
- Reuse: shop/product context card, section header, shared state/CTA.
- Parallel: Cart/Purchases hattıyla YES. Notifications aynı target contract'a
  bağlı olduğundan final navigation entegrasyonu sonradır.
- Collision: unread cubit/global listener değişikliği Integration Agent review.

## WP-08 — Auth + Startup essentials

- Scope: launch gate, onboarding, login, signup, verify-email, forgot/reset/update
  password, invalid recovery, KVKK/Terms ve üç auth modal/overlay.
- Likely files: `lib/features/auth/presentation/` ve auth widget/golden tests.
- Tier: B/C; 30 h.
- Figma: Onboarding/Login/Signup LIGHT; diğerleri NOT_REQUIRED.
- Visual approval: NO; established Final UI language yeterli.
- Parallel: WP-01/WP-02/WP-04 ile YES; global listener değişikliği doğrudan
  yapılmaz, Integration Agent'a handoff edilir.
- Safety: callback/PKCE, consent, role ve client-safe error davranışı değişmez.

## WP-09 — Account Hub

- Scope: Settings, Profile, edit/delete, Saved Locations/editor/delete,
  Privacy/Permissions, Help & Support.
- Likely files: `lib/features/personalization/presentation/` içindeki aktif view
  ve widgets; inactive address files kapsam dışı.
- Tier: B/C; 44 h.
- Figma: Saved Locations/editor LIGHT; kalan NOT_REQUIRED.
- Visual approval: NO.
- Reuse: scaffold/header, form, section, state, settings tile ve CTA primitives.
- Parallel: WP-08 ile aynı auth/profile handoff nedeniyle önce değil; WP-01/02/03
  ile ayrı agent'ta YES, ancak location helper ownership önceden sabitlenmeli.
- Safety: account deletion ve OS permission davranışı yalnız presentation closeout.

## WP-10 — Secondary Customer Library

- Scope: Wishlist, Coupons, Recently Viewed + actions, Notifications ve shared
  loading/snackbar consistency.
- Likely files: ilgili shop/personalization/notifications views, shared feedback
  ancak yalnız Integration Agent üzerinden.
- Tier: B/C; 28 h.
- Figma: Notifications LIGHT; kalan NOT_REQUIRED.
- Visual approval: NO.
- Reuse: product card, section header, StateCard, SurfaceIconButton.
- Parallel: Wishlist/Coupons/Recent kendi aralarında güvenli batch'tir.
  Notifications, Purchases ve Chat target'ları stabilize olmadan final merge NO.
- Pilot cut: Coupons ve Recent polish gerekirse post-pilot'a kayabilir; Wishlist,
  Notifications ve shared error clarity kayamaz.

## Paket kapsamı mutabakatı

| Kaynak | Unit | Expected hours |
|---|---:|---:|
| Tier A | 8 | 103 |
| Tier B | 18 | 104 |
| Tier C | 28 | 43 |
| **Toplam** | **54** | **250** |

Cross-cutting integration, full suite ve owner-review bekleme payı bu 250 saate
dahil değildir; acceleration planındaki expected tek-agent toplamı bu nedenle
280 saattir.

## Başlatma önerisi

İlk paralel kesit:

1. Design/UI Owner: Shop Details + All Products/Search karar paketleri.
2. Agent 2: owner-approved Shop Details closeout.
3. Agent 3: WP-08 Auth + Startup.
4. Integration Agent: önce Auth, sonra Shop; ardından Search ve Nearby.

Bu kesit yüksek shared-component leverage üretir, Product Owner'ı aynı anda sekiz
prototype ile boğmaz ve Cart/Purchases/Reviews kritik contract hattını ikinci
faz için temiz bırakır.

