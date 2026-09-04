# Wave 44A — Customer UI Surface Inventory

Durum: **ANALYSIS ONLY — 2026-09-04**
Kaynak: `origin/main@c0462dbaf3955a7a064f05c214e2517092629e3b`

## 1. Sayım sözleşmesi

Bu envanter route, görünüm sınıfı, `Navigator` hedefi, alt navigasyon,
deep-link listener'ları ve widget testleri birlikte okunarak çıkarıldı.

- Bir tam ekranın loading/empty/error varyantları ayrı ekran sayılmadı.
- Aynı Dart sınıfı farklı girişte farklı müşteri görevi ve kompozisyon üretiyorsa
  ayrı yüzey sayıldı. Bu nedenle `AllProductsView` içindeki **Tüm ürünler** ve
  **Arama** modları ayrı tam ekran yüzeyidir.
- Modal içindeki loading/success/error varyantları ayrıca modal sayılmadı.
- `NavigationMenu` müşteri shell'idir; beş alt sekmeyi taşıdığı için ayrıca tam
  ekran sayılmadı.
- `SellerComparisonView` kaynak kodunda route'a bağlı değildir; buna rağmen Wave
  43B ve bu görevin açık sözleşmesi gereği `DONE / MAIN` kabul edildi ve kalan
  işten çıkarıldı.
- `EsnaftaVarStateCard` gibi paylaşılan durum ailesi, onu kullanan her ekran için
  yeniden sayılmadı.

## 2. Kesin sayılar

| Ölçü | Kesin sayı | Açıklama |
|---|---:|---|
| A. Erişilebilir müşteri tam ekran yüzeyi | **34** | Shell hariç; iki ayrı `AllProductsView` modu dahil |
| B. Aktif modal/sheet/dialog/menu/overlay yüzeyi | **24** | 2 tanesi tamamlanan Final UI kapsamındadır |
| C. Paylaşılan durum yüzeyi ailesi | **3** | 1 tanesi Final UI foundation'da tamamlandı |
| D. Final UI V1 tamamlanan ana özellik yüzeyi | **5** | Home, Category, Product Listing, Product Details, Seller Comparison |
| E. Kalan Tier A birimi | **8** | Tamamı tam ekran |
| F. Kalan Tier B birimi | **18** | 13 tam ekran + 5 sheet |
| G. Kalan Tier C birimi | **28** | 9 tam ekran + 17 modal + 2 shared-state |
| H. Inactive/legacy/non-customer excluded | **8** | 5 customer inactive/dead + 3 merchant-only |
| I. Unknown / follow-up | **0** | Reachability belirsizliği kalmadı |

Kalan dönüşüm birimi **54**'tür: 30 erişilebilir tam ekran + 22 aktif modal +
2 paylaşılan durum ailesi. Final UI kapsamındaki iki menü ve tamamlanmış
`EsnaftaVarStateCard` bu toplamda yoktur. Aktif tam ekranların **30'u
PARTIALLY_FINAL**, saf `OLD_UI` sınıfında erişilebilir tam ekran yoktur. Eski
customer yüzeyleri erişilemez/legacy olarak ayrıca dışlandı.

## 3. Navigation ve reachability kanıtı

- `lib/t_store.dart`: `MaterialApp(home: CustomerLaunchGate())`; named route,
  `GoRouter` veya route generator yok.
- `lib/core/common/widgets/navigation_menu.dart`: müşteri shell'i ve guest için
  auth detour.
- `lib/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart`: Home,
  Nearby, Cart V2, Wishlist ve Settings sekmeleri.
- Uygulama içi geçişler `MaterialPageRoute`, `push`, `pushReplacement` ve
  `pushAndRemoveUntil` ile kurulmuş.
- E-posta confirmation ve password recovery deep-link'leri global listener'larla
  doğrulanıp ilgili hedefe yönlendiriliyor.
- `SettingsView`, Home app bar, notifications, purchase/review ve product/shop
  bileşenlerindeki gerçek hedefler çapraz kontrol edildi.
- `SellerComparisonView` yorum ve referans taraması onun yalnız test/golden
  kanıtında bulunduğunu, runtime route'a henüz bağlanmadığını açıkça gösteriyor.

## 4. Tam ekran müşteri yüzeyleri

`ESTIMATED_HOURS`, mevcut davranışı koruyarak Final UI closeout ve hedefli test
ekleme için beklenen doğrudan agent-saatidir; ortak full-suite/integration payı
ayrıca plan belgesinde ele alınır.

| ID | FEATURE | SURFACE | TYPE | ROUTE/ENTRY | REACHABLE | CURRENT_UI_STATUS | TIER | FIGMA_NEED | REUSE_LEVEL | OWNER_VISUAL_GATE | DEPENDENCIES | ESTIMATED_HOURS | NOTES |
|---|---|---|---|---|---|---|---|---|---|---|---|---:|---|
| FS-01 | Startup | Customer launch/loading gate | FULL_SCREEN_FLOW | `MaterialApp.home` | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Onboarding, Navigation shell | 1 | Tek splash/loading gate; child ekranları ayrıca sayılır. |
| FS-02 | Onboarding | Onboarding carousel | SCREEN | Launch gate, first run | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | HIGH | NO | Navigation shell | 4 | Marka ilk teması; mevcut token dili yeniden kullanılabilir. |
| FS-03 | Auth | Customer login | SCREEN | Auth guard, Settings, feature detours | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | HIGH | NO | Auth cubit, Navigation shell | 5 | Merchant outcome ayrı customer surface değildir. |
| FS-04 | Auth | Customer signup | SCREEN | Login | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | HIGH | NO | Legal screens, Verify email | 6 | Consent ve validation korunmalı. |
| FS-05 | Auth | Verify email waiting/resend | SCREEN | Signup/login confirmation-required | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Confirmation listener | 2 | State varyantları tek surface. |
| FS-06 | Auth | Forgot password request | SCREEN | Login | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Reset email instructions | 2 | Form primitive reuse. |
| FS-07 | Auth | Password reset email sent | SCREEN | Forgot-password success | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Recovery deep link | 2 | Bu ekran parola değiştirme ekranı değildir. |
| FS-08 | Auth | Update password | SCREEN | Recovery deep link | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Recovery listener, Login | 2 | Security-sensitive behavior değişmez. |
| FS-09 | Auth | Invalid/expired recovery | SCREEN | Invalid recovery deep link | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Forgot password, Login | 1 | Fail-closed state. |
| FS-10 | Legal | KVKK information | SCREEN | Signup, Privacy | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Legal content | 1 | İçerik/policy değişikliği yok. |
| FS-11 | Legal | Terms of Use | SCREEN | Signup, Privacy | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Legal content | 1 | İçerik/policy değişikliği yok. |
| FS-12 | Home | Home | SCREEN | Bottom tab 0 | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Navigation shell | 0 | **DONE / MAIN**; visual pack ayrı polish backlog'udur. |
| FS-13 | Category | Recursive category browse | SCREEN | Home category; recursive push | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Canonical taxonomy capability | 0 | **DONE / MAIN**; variable depth korunur. |
| FS-14 | Product listing | Category-scoped product listing | SCREEN | Recursive leaf; `SubCategoryView` | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Category browse | 0 | **DONE / MAIN**; Final UI branch sourceudur. |
| FS-15 | Discovery | All products catalog | SCREEN | Home “Tümünü Gör”, promo | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | Product card, Product Details | 10 | Search olmayan catalog modu; mixed legacy spacing bulunuyor. |
| FS-16 | Search | Search/suggestions/results | FULL_SCREEN_FLOW | Home query/search tap; `isSearchMode` | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | FS-15 ile aynı dosya; category/shop/product targets | 7 | FS-15 ile paralel düzenlenemez. |
| FS-17 | Product | Product Details | SCREEN | Product cards/results | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Seller/review sections | 0 | **DONE / MAIN**. |
| FS-18 | Nearby | Nearby shops/location | FULL_SCREEN_FLOW | Bottom tab 1 | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | Location helpers, Shop Details | 14 | Permission, sorting ve distance state'leri. |
| FS-19 | Shop | Shop Details/Profile | SCREEN | Home/Nearby/seller/purchase | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | Shop/product cards, Chat | 12 | Yüksek reuse ama kendine özgü shop kompozisyonu. |
| FS-20 | Cart | Cart V2 | FULL_SCREEN_FLOW | Bottom tab 2; seller add-to-cart | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | Auth, QR sheet, Purchases | 16 | Single-shop ve verified-purchase hazırlığı korunur. |
| FS-21 | Wishlist | Wishlist | SCREEN | Bottom tab 3; favorite guards | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Auth, Product Details | 6 | Existing product-card dili yeterli. |
| FS-22 | Account | Settings/Profile hub | SCREEN | Bottom tab 4 | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Auth, account destinations | 6 | Guest path kodda var; bottom-tab seçimi auth-gated. |
| FS-23 | Account | Profile details | SCREEN | Settings/header | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Edit/delete modals | 7 | Profile mutation contract korunmalı. |
| FS-24 | Location | Saved locations | FULL_SCREEN_FLOW | Settings, Home, seller section | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | MEDIUM | NO | Location permission, editor sheet | 9 | Form/map-state yoğunluğu orta. |
| FS-25 | Privacy | Privacy & Permissions | SCREEN | Settings | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Legal views, OS settings | 5 | Privacy davranışı/policy kapsam dışıdır. |
| FS-26 | Support | Help & Support | SCREEN | Settings | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Purchases, Messages, Locations | 4 | Bilinen hedeflere shortcut sağlar. |
| FS-27 | Coupons | Customer coupons | SCREEN | Settings | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | None | 2 | Ekonomik coupon engine yok; UI truthfulness korunmalı. |
| FS-28 | History | Recently viewed products | SCREEN | Settings | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Product Details | 6 | Local/storage davranışı. |
| FS-29 | Notifications | Customer notifications | FULL_SCREEN_FLOW | Home app bar, Settings | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | MEDIUM | NO | Purchases, Chat | 8 | Type-based navigation ve pagination var. |
| FS-30 | Purchases | Verified purchase history | FULL_SCREEN_FLOW | Settings, Cart QR result, Notifications | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | QR contract, Shop Details, rating sheet | 16 | “Order/payment” semantiği eklenemez. |
| FS-31 | Ratings | Customer shop ratings | SCREEN | Settings | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Purchases | 5 | Review ile shop rating ayrımı korunur. |
| FS-32 | Reviews | Product reviews/eligibility | FULL_SCREEN_FLOW | Product Details | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | MEDIUM | YES | Verified purchase, review editor | 14 | Review eligibility kritik ve server-authoritative. |
| FS-33 | Chat | Conversation list | SCREEN | Settings, Notifications | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | MEDIUM | NO | Chat detail, unread cubit | 8 | Chat detail ile aynı agent paketi önerilir. |
| FS-34 | Chat | Chat detail/composer | FULL_SCREEN_FLOW | Conversation list, Shop, pending-chat listener | YES | PARTIALLY_FINAL | A | FIGMA_HEAVY | LOW | YES | Auth, shop/product context | 14 | Kendine özgü interaction ve keyboard states. |

## 5. Final fakat route'a bağlı olmayan ana yüzey

| ID | FEATURE | SURFACE | TYPE | ROUTE/ENTRY | REACHABLE | CURRENT_UI_STATUS | TIER | FIGMA_NEED | REUSE_LEVEL | OWNER_VISUAL_GATE | DEPENDENCIES | ESTIMATED_HOURS | NOTES |
|---|---|---|---|---|---|---|---|---|---|---|---|---:|---|
| FD-05 | Seller comparison | Dedicated Seller Comparison | SCREEN | Test/golden only; runtime route yok | NO | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Product Details seller section | 0 | **DONE / MAIN**; route activation ayrı entegrasyon konusu, UI conversion işi değildir. |

## 6. Aktif modal, sheet, dialog, menu ve overlay yüzeyleri

| ID | FEATURE | SURFACE | TYPE | ROUTE/ENTRY | REACHABLE | CURRENT_UI_STATUS | TIER | FIGMA_NEED | REUSE_LEVEL | OWNER_VISUAL_GATE | DEPENDENCIES | ESTIMATED_HOURS | NOTES |
|---|---|---|---|---|---|---|---|---|---|---|---|---:|---|
| MD-01 | Location | Permanently denied/settings dialog | DIALOG | Location helper | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | OS settings | 2 | Exact permission state; modal variants çoğaltılmadı. |
| MD-02 | Location | Location acquisition loading | DIALOG_OVERLAY | Location helper `DialogRoute` | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Geolocator | 1 | Blocking progress surface. |
| MD-03 | Location | Location service disabled | DIALOG | Location helper | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | OS location settings | 2 | Shared Home/Nearby use. |
| MD-04 | Location | Runtime permission request explanation | DIALOG | Location helper | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Permission request | 2 | System permission sheet ayrıca app-owned UI sayılmadı. |
| MD-05 | Purchases | Shop rating editor | BOTTOM_SHEET | Purchases | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Rating contract | 4 | Purchases package'ına bağlı. |
| MD-06 | Profile | Edit profile form | BOTTOM_SHEET | Profile | YES | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | HIGH | NO | Profile mutation | 4 | Form primitives reuse. |
| MD-07 | Profile | Account deletion confirmation | DIALOG | Profile | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Canonical delete flow | 2 | Destructive copy ve loading/error states korunur. |
| MD-08 | Location | Add/edit saved location | BOTTOM_SHEET | Saved Locations | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | MEDIUM | NO | Permission, geolocation | 5 | Targeted reference yeterli. |
| MD-09 | Location | Delete saved location | DIALOG | Saved Locations | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Saved location row | 2 | Exact-row confirmation. |
| MD-10 | Auth | Wrong merchant-account warning | DIALOG | Login outcome | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Role contract | 1 | Customer app security feedback. |
| MD-11 | Auth | Merchant registration information | DIALOG | Login | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Merchant handoff policy | 1 | Merchant app ekranı değildir. |
| MD-12 | Cart | Single-shop conflict | DIALOG | Seller add-to-cart | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Cart V2 | 2 | Business rule değişmez. |
| MD-13 | Seller comparison | Seller sort menu | POPUP_MENU | Seller list | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Seller Comparison | 0 | Wave 43B kapsamı; kalan iş değildir. |
| MD-14 | Product listing | Product sort menu | POPUP_MENU | Category product listing | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Product Listing | 0 | Wave 41B kapsamı; kalan iş değildir. |
| MD-15 | History | Clear all recently viewed | DIALOG | Recently Viewed | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Local history | 1 | Destructive local action. |
| MD-16 | History | Recently viewed item action menu | POPUP_MENU | Recently Viewed item | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Local history | 1 | Remove action. |
| MD-17 | Reviews | Review create/edit form | BOTTOM_SHEET | Product Reviews | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | MEDIUM | NO | Eligibility, review mutation | 5 | Reviews Tier A prototype'ına bağlı. |
| MD-18 | Reviews | Review delete confirmation | DIALOG | Product Reviews | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Review mutation | 1 | Evidence korunur; yalnız active review silinir. |
| MD-19 | Nearby | Use current location consent | DIALOG | Nearby | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Location helper | 2 | Location permission'dan ayrı app consent'i. |
| MD-20 | Cart | Remove cart item | DIALOG | Cart V2 | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Cart row | 1 | Confirmation. |
| MD-21 | Cart | Clear cart | DIALOG | Cart V2 | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Cart | 1 | Confirmation. |
| MD-22 | Cart | Continue after refreshed totals | DIALOG | Cart V2 QR preparation | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Listing snapshot, QR | 2 | Truthful refreshed total contract. |
| MD-23 | QR | Customer QR session | BOTTOM_SHEET | Cart V2 “Mağazada Göster” | YES | PARTIALLY_FINAL | B | FIGMA_LIGHT | MEDIUM | NO | Cart, session expiry, Purchases | 7 | Çok durumlu sheet; Cart Tier A gate'i altında uygulanır. |
| MD-24 | Auth | Email confirmation success notice | TRANSIENT_OVERLAY | Confirmation deep link destination | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Global confirmation listener | 1 | Destination üstünde dismissible notice; snackbar değildir. |

`THelperFunctions.showAlert` için runtime caller bulunmadı; görünür surface olarak
sayılmadı. Sistem tarafından çizilen Android/iOS permission sheet'i de app-owned
surface değildir.

## 7. Paylaşılan durum yüzeyleri

| ID | FEATURE | SURFACE | TYPE | ROUTE/ENTRY | REACHABLE | CURRENT_UI_STATUS | TIER | FIGMA_NEED | REUSE_LEVEL | OWNER_VISUAL_GATE | DEPENDENCIES | ESTIMATED_HOURS | NOTES |
|---|---|---|---|---|---|---|---|---|---|---|---|---:|---|
| ST-01 | Shared state | `EsnaftaVarStateCard` empty/error/unavailable family | SHARED_STATE | Home/category/final screens | YES | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | HIGH | COMPLETED | Final UI foundation | 0 | Varyant başına ayrı sayılmadı. |
| ST-02 | Shared state | Generic progress/loading family | SHARED_STATE | `TLoadingIndicator` + repeated progress usage | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | Screen-specific loaders | 2 | Tek standarda yakınlaştırma; davranış değişmez. |
| ST-03 | Shared state | Snackbar feedback family | SHARED_STATE | Auth/cart/chat/location/mutation feedback | YES | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | HIGH | NO | ScaffoldMessenger | 2 | Success/error/info copy farklı; aynı presentation family. |

Permission dialogları MD-01–04, auth gate'in görünür hedefi FS-03 ve confirmation
overlay'i MD-24 olarak zaten sayıldığı için burada tekrar edilmedi. Offline için
ayrı global surface bulunmadı; network hataları ekranların mevcut error state'ine
düşüyor.

## 8. Dışlanan yüzeyler

| ID | FEATURE | SURFACE | TYPE | ROUTE/ENTRY | REACHABLE | CURRENT_UI_STATUS | EXCLUSION_EVIDENCE |
|---|---|---|---|---|---|---|---|
| EX-01 | Address legacy | User address list | SCREEN | Runtime caller yok | NO | LEGACY_INACTIVE | Settings artık Saved Locations açıyor. |
| EX-02 | Address legacy | Add new address | SCREEN | Yalnız EX-01'den | NO | DEAD/UNUSED_CANDIDATE | Parent route erişilemez. |
| EX-03 | Shop legacy | Store tab/view | SCREEN | Runtime caller yok | NO | DEAD/UNUSED_CANDIDATE | Bottom navigation `WishlistView` kullanıyor. |
| EX-04 | Orders legacy | Legacy orders | SCREEN | Test yalnız izolasyonu doğruluyor | NO | LEGACY_INACTIVE | Customer path `PurchasesView`. |
| EX-05 | Auth legacy | Legacy email success/`SuccessView` composition | SCREEN | Runtime caller yok | NO | DEAD/UNUSED_CANDIDATE | Aktif flow MD-24 confirmation notice kullanıyor. |
| EX-06 | Merchant | My Shop | SCREEN | Merchant-role login branch | NO | NOT_CUSTOMER_RUNTIME | Merchant scope. |
| EX-07 | Merchant | My Shop form | SCREEN | EX-06 child | NO | NOT_CUSTOMER_RUNTIME | Merchant scope. |
| EX-08 | Merchant | Merchant QR scanner | SCREEN | EX-06 child | NO | NOT_CUSTOMER_RUNTIME | Verifier/merchant scope. |

## 9. Feature alanı sonucu

- Repo'da müşteri için gerçek yüzeyi bulunan alanlar: startup/onboarding, auth,
  password recovery, email confirmation, legal/privacy, Home, category,
  catalog/search, product, seller comparison, Nearby/location, shop, Wishlist,
  Cart V2/QR, purchases, reviews/ratings, notifications, chat, profile/settings,
  saved locations, help, coupons ve recently viewed.
- Ayrı müşteri “Address” runtime'ı yoktur; Saved Locations bunun aktif
  karşılığıdır.
- Ayrı checkout/payment/order-tracking surface'i yoktur ve icat edilmedi.
- Canonical 24 Category Visual Pack bir artwork/polish backlog'udur; core ekran
  dönüşümü değildir.

## 10. Figma ve reuse özeti

Kalan 54 birim için:

| Figma sınıfı | Sayı | Kapsam |
|---|---:|---|
| FIGMA_HEAVY | **8** | Tier A tam ekranlar |
| FIGMA_LIGHT | **9** | Onboarding, Login, Signup, Saved Locations, Notifications, Conversations ve üç complex sheet |
| FIGMA_NOT_REQUIRED | **37** | Foundation ile doğrudan uygulanabilir |

Reuse:

- HIGH: 37 birim; scaffold/header/state/form/CTA/card dili doğrudan kullanılabilir.
- MEDIUM: 16 birim; composition özeldir fakat foundation ve domain kartları
  yeniden kullanılabilir.
- LOW: 1 birim; Chat detail'in interaction/keyboard yapısı özeldir.

Bu sınıflandırma Figma kullanımını 54 ayrı çalışma yerine sekiz owner-gated
prototype ve dokuz hedefli referansla sınırlar.

## 11. Quality sonucu

- Named routes/GoRouter: **0**.
- Runtime ref bulunmayan customer full-screen candidates: **5**, tamamı dışlandı.
- Customer runtime olmayan merchant full screens: **3**, tamamı dışlandı.
- Reachability unknown: **0**.
- Duplicate path/surface sayımı: **0**; state ve mode sayım kuralları yukarıda
  açıklandı.
- Flutter/Figma/backend/taxonomy/remote environment değişikliği: **yok**.
