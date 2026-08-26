# EsnaftaVar Canonical Component Library V1

> WAVE 14 — PHASE B3 · Canonical Component Layer V1
> PHASE C extension · Approved Mobile variants for Critical Screen Pilot V1
> Tarih: 2026-08-26
> Durum: **CANONICAL V1 + PHASE C MOBILE EXTENSION / PRODUCT OWNER VISUAL REVIEW READY**
> Git base: `origin/main@911e326609fed85e3d6b55be6d27d75a91ce2176`
> Task branch: `agent-ui/w14-canonical-component-layer-v1`
> Phase C branch/base: `agent-ui/w14-critical-screen-pilot-v1` / `origin/main@7992dee8fb6512c53a94e8a094ab2b729a49bc3a`
> Figma: [EsnaftaVar — Final UI System](https://www.figma.com/design/O8MIn0KyQfFoPA3EnhiWii/EsnaftaVar-%E2%80%94-Final-UI-System)
> Token foundation: [ESNAFTAVAR_DESIGN_TOKENS_V1_FINAL.md](./ESNAFTAVAR_DESIGN_TOKENS_V1_FINAL.md)

## 1. Sonuç

Mahalle Terracotta foundation üzerinde, mevcut K'pasa kaynak UI kitini değiştirmeden yeni ve izole bir canonical component katmanı oluşturuldu.

| Artifact | Değer |
|---|---|
| Figma page | `EsnaftaVar — Components V1` |
| Page node | `52790:2` |
| Canonical board | `EsnaftaVar — Components V1 / Canonical Board` |
| Board node | `52790:3` |
| Board size | `2520 × 6124` |
| Public component family | `14` |
| Component set | `13` |
| Component node | `89` |
| Canonical font | Poppins only |
| Canonical color direction | Mahalle Terracotta: primary `#B54732`, accent `#1F6B5D` |
| Source K'pasa component/screen/style mutation | `0` |
| Flutter/runtime mutation | `0` |

Canonical B3 katmanına Phase C'de yalnız onaylı beş aile için toplam 10
`Layout=Mobile` varyantı eklenmiştir. Critical-screen çıktısı ayrı
`EsnaftaVar — Critical Screens V1` page'inde tutulur; Flutter widget, taxonomy
motoru, reklam motoru, ödül/gamification davranışı veya ödeme/checkout akışı
üretilmemiştir.

## 2. Mimari kurallar

1. Bütün public aileler `EsnaftaVar/*` namespace'i altındadır.
2. Her component root'u Auto Layout kullanır.
3. Bütün solid fill/stroke paint'leri `EsnaftaVar / Color` semantic variable'larına bağlıdır.
4. Layout gap/padding ve corner radius değerleri `EsnaftaVar / Dimension` variable'larına bağlıdır.
5. Bütün metinler `EsnaftaVar/type/*` Poppins stillerine bağlıdır; Inter yoktur.
6. Elevation gereken kartlar `EsnaftaVar/shadow/xs|sm` effect style'larını kullanır.
7. İnteraktif hedefler en az `44 px`, ana aksiyonlar ve form kontrolleri tercihen `48 px`'dir.
8. Focus, validation, stock ve status anlamı yalnız renk ile verilmez; text, icon, border weight veya shape cue eşlik eder.
9. Kategori isimleri, ürünler, esnaflar ve fiyatlar dinamik veri slotlarıdır; canonical taxonomy için component/ekran çoğaltılmaz.
10. Future semantic slot'lar yalnız görsel rol olarak tüketilir; advertising/reward/gamification engine davranışı tanımlanmaz.

## 3. Component envanteri

| Family | Figma node | Tür | Public component | Varyant özeti |
|---|---:|---|---:|---|
| `EsnaftaVar/Button` | `52792:148` | Component set | 16 | `Size=48` × 4 style × 4 state |
| `EsnaftaVar/TextField` | `52796:254` | Component set | 30 | 5 type × 6 state |
| `EsnaftaVar/BottomNav` | `52798:177` | Component set | 5 | 5 active destination |
| `EsnaftaVar/CategoryCard` | `52799:46` | Component set | 4 | 2 availability × 2 density |
| `EsnaftaVar/CategoryRow` | `52799:71` | Component set | 2 | 2 availability |
| `EsnaftaVar/ProductCard` | `52800:92` | Component set | 4 | 2 layout × 2 image state |
| `EsnaftaVar/SellerPriceRow` | `52801:71` | Component set | 6 | 2 layout × 3 state |
| `EsnaftaVar/MerchantCard` | `52801:120` | Component set | 4 | 2 layout × 2 image state |
| `EsnaftaVar/ShopRatingSummary` | `52802:87` | Component set | 2 | 2 density |
| `EsnaftaVar/VerifiedPurchaseBadge` | `52802:88` | Standalone component | 1 | Server-authoritative marker |
| `EsnaftaVar/CartShopHeader` | `52832:86` | Component set | 2 | `Layout=Wide|Mobile` |
| `EsnaftaVar/CartItem` | `52803:102` | Component set | 6 | 2 layout × 3 availability |
| `EsnaftaVar/SingleStoreConflictState` | `52833:107` | Component set | 2 | `Layout=Wide|Mobile` |
| `EsnaftaVar/StatusChip` | `52804:55` | Component set | 5 | Commerce/trust semantic states |

Toplam: **13 component set, 89 component node, 14 public family**. Phase C
extension yeni public family oluşturmaz; yalnız mevcut beş aileye exact 10 Mobile
varyantı ekler.

## 4. Varyant ve property sözleşmeleri

### 4.1 Button

- `Style`: `Primary`, `Secondary`, `Tertiary`, `Destructive`
- `State`: `Default`, `Pressed`, `Disabled`, `Loading`
- `Size`: `48`
- Properties: `Label`, `Show leading icon`, `Show trailing icon`
- Loading varyantlarında label `Yükleniyor…` ve spinner birlikte görünür.
- Primary/onPrimary, accent, disabled surface ve error tokenları kullanılır.

### 4.2 TextField

- `Type`: `Text`, `Search`, `Password`, `Select`, `Location`
- `State`: `Default`, `Focused`, `Filled`, `Error`, `Success`, `Disabled`
- Properties: `Label`, `Value`
- Kontrol yüksekliği `48 px`'dir.
- Focus güçlü border + helper cue; Error/Success icon/text + güçlü border ile verilir.
- Password visibility, Select chevron ve Location/Search prefix icon pattern'leri dahildir.

### 4.3 BottomNav

- `Active`: `Home`, `Nearby`, `Cart`, `Favorites`, `Profile`
- Görünen sözleşme: `Ana Sayfa`, `Yakındakiler`, `Sepet`, `Favoriler`, `Profil`
- Aktif item; accent renk, accentSoft icon container ve shape marker kullanır.
- Guest → login gate davranışı runtime sorumluluğudur.

### 4.4 CategoryCard / CategoryRow

- CategoryCard: `Availability=Available|Unavailable`, `Density=Standard|Compact`
- CategoryRow: `Availability=Available|Unavailable`
- Property: `Category name`
- Uzun Türkçe örnek adla truncation/wrapping kontrol edilmiştir.
- `12 yakın esnafta` ve `Şu an yakınınızda yok` supporting state'leri renk + text marker ile ayrılır.
- Componentler canonical taxonomy'den dinamik veri alır; taxonomy başına component veya ekran üretilmez.

### 4.5 ProductCard

- `Layout`: `Grid`, `List`
- `Image`: `Available`, `Fallback`
- Properties: `Product name`, `Price`, `Merchant count`, `Show favorite`
- İçerik: uzun ürün adı, rating/count, fiyat, stok, `14 esnafta var`, 44 px favorite action.
- Product image alanı warm-neutral surface kullanır; fallback explicit icon ve `Görsel yakında` text'i taşır.
- Shipping, online marketplace veya ranking semantiği içermez.

### 4.6 SellerPriceRow / MerchantCard

- Her iki ailede `Layout=Wide|Mobile`
- SellerPriceRow: `State=Default|BestPrice|Unavailable`
- MerchantCard: `Image=Available|Fallback`
- Seller properties: `Merchant name`, `Price`, `Show sponsored`
- Merchant properties: `Merchant name`, `Show merchant badge`
- Seller row; rating, distance, price, availability ve canonical `Mağazayı Gör` Button instance'ını birlikte taşır.
- MerchantCard; canonical `Yol Tarifi` ve `Mağazayı Gör` Button instance'larını taşır.
- `En uygun fiyat` etiketi yalnız presentational örnektir; sıralama/auction/advertising algoritması tanımlamaz.
- `Sponsorlu` etiketi optional visual disclosure slot'udur; default olarak kapalıdır.
- Merchant badge `future/merchantBadge` görsel slotunu kullanır; bir badge engine tanımlamaz.

### 4.7 ShopRatingSummary / VerifiedPurchaseBadge

- ShopRatingSummary: `Density=Compact|Detailed`
- Properties: `Rating`, `Review count`
- Detailed varyant 5→1 dağılım yapısını; Compact varyant özet mesajını gösterir.
- VerifiedPurchaseBadge `future/verifiedPurchase` slotunu kullanır.
- Verified purchase durumu istemci tarafından tahmin edilemez veya atanamaz; server-authoritative ürün sözleşmesidir.

### 4.8 Cart V2

- CartShopHeader: `Layout=Wide|Mobile`
- CartShopHeader property: `Merchant name`
- CartItem: `Layout=Wide|Mobile`
- CartItem: `Availability=Available|LowStock|Unavailable`
- CartItem properties: `Product name`, `Quantity`
- Quantity stepper ve remove action `44 px`'dir.
- Unavailable item sepette görünür ve kaldırılabilir; stock state açık text ile verilir.
- SingleStoreConflictState: `Layout=Wide|Mobile`
- SingleStoreConflictState property: `Description`
- Conflict state, mevcut mağazayı ve yeni mağazayı açıklayarak `Vazgeç` / `Sepeti Değiştir` onayı ister.
- Checkout, ödeme, shipping veya order tracking davranışı bu componentlerde yoktur.

### 4.9 StatusChip

- `Semantic`: `Available`, `LowStock`, `Unavailable`, `Verified`, `Sponsored`
- Her semantic state farklı icon shape, açık text label ve uygun commerce/future token çifti kullanır.
- `Verified` server-authoritative trust state'idir; `Sponsored` yalnız future disclosure slot'udur.
- StatusChip display-only'dir; interaktif chip olarak kullanılacaksa ayrı 44 px hit-area gerekir.

## 5. Token dependency mapping

| Component family | Ana color dependencies | Dimension / type / effect dependencies |
|---|---|---|
| Button | `brand/primary*`, `brand/accent*`, `state/error*`, surface/text | `touch/preferred`, `space/*`, `radius/medium`, `type/label` |
| TextField | surface, text, border, accent, success, error | `touch/preferred`, `space/*`, `radius/medium`, label/body/caption |
| BottomNav | surface, accent/accentSoft, textMuted, divider | `space/*`, `radius/pill`, caption/label |
| CategoryCard/Row | surface/surfaceAlt, accentSoft, success, unavailable | `touch/min`, `space/*`, radius medium/large, heading/label/caption, shadow/xs |
| ProductCard | surface/surfaceAlt, primarySoft, price, stockAvailable, unavailable | `touch/min`, `space/*`, radius medium/large/pill, heading/label/price/caption, shadow/sm |
| SellerPriceRow | surface, price, stockAvailable/Low/unavailable, merchantBadge | `touch/preferred`, `space/*`, radius medium/pill, label/price/caption, shadow/xs |
| MerchantCard | surface/surfaceAlt, accentSoft, merchantBadge | `touch/preferred`, `space/*`, radius medium/large/pill, label/caption, shadow/xs |
| Rating / verified | primary, surfaceAlt, divider, verifiedPurchase | `space/*`, radius large/pill, heading/label/caption |
| Cart V2 | surface/surfaceAlt, price, stock*, warning*, error* | `touch/min|preferred`, `space/*`, radius medium/large/pill, heading/body/label/price/caption, shadow/xs |
| StatusChip | stockAvailable, stockLow, unavailable, verifiedPurchase, sponsored ve supporting soft surfaces | `space/*`, `radius/pill`, `type/label` |

Canonical foundation toplamı değişmemiştir: `38` color variable, `15` dimension variable, `12` Poppins text style ve `3` effect style.

## 6. K'pasa source/reference mapping

| Canonical family | K'pasa reference | Korunan / değiştirilen yaklaşım |
|---|---|---|
| Button | `Button` (`418:4001`) | Variant-matrix fikri referans alındı; token, state, 48 px target ve Poppins API'si yeniden kuruldu. |
| TextField | `text-field building block` (`908:9716`) | Field anatomy referans alındı; type/state kapsamı, ölçü, Auto Layout ve typography değiştirildi. |
| BottomNav | `Bars` (`913:7501`) | Eşit dağılım fikri referans alındı; actual five-item IA ve labels ile yeniden kuruldu. |
| CategoryCard/Row | `Category` (`940:2872`) | Yalnız compact visual pattern referans alındı; demo taxonomy kullanılmadı. |
| ProductCard | `Product Card` (`940:2875`) | Temel bilgi hiyerarşisi referans alındı; local merchant count, stock, fallback ve canonical tokens eklendi. |
| SellerPriceRow | `Product and Price` (`940:2998`) | Row yapısı referans alındı; merchant identity, rating, distance, state ve CTA sözleşmesi yeniden kuruldu. |
| ShopRatingSummary | `Rating Preview` (`940:2959`) | Rating presentation fikri referans alındı; aggregate summary ayrı canonical family oldu. |
| StatusChip | `Status` (`418:5362`) | Semantic badge fikri referans alındı; commerce/trust states ve canonical variables ile yeniden kuruldu. |
| MerchantCard / Verified / Cart V2 | Dedicated K'pasa karşılığı yok | EsnaftaVar ürün sözleşmesi için sıfırdan canonical componentler oluşturuldu. |

Hiçbir reference component veya instance mutate edilmedi; bütün canonical family'ler yeni page altında yereldir.

## 7. Product-state mapping

| Product/domain durumu | Canonical component karşılığı |
|---|---|
| Product `stock available` | ProductCard stock label; SellerPriceRow/CartItem `Available`; `commerce/stockAvailable` |
| Product `low stock` | SellerPriceRow/CartItem `LowStock`; `commerce/stockLow` + explicit quantity text |
| Product unavailable | SellerPriceRow/CartItem `Unavailable`; `commerce/unavailable` + explicit text/icon |
| Product image missing | ProductCard `Image=Fallback` |
| Local merchant offers | SellerPriceRow; distance, merchant name, price and availability |
| Merchant preview | MerchantCard `Image=Available|Fallback` |
| Shop rating aggregate | ShopRatingSummary `Compact|Detailed` |
| Verified customer review | VerifiedPurchaseBadge; only authoritative backend state |
| Single-store cart | CartShopHeader + CartItem |
| Different-store add attempt | SingleStoreConflictState; explicit replacement confirmation |
| Dynamic category availability | CategoryCard/Row `Available|Unavailable` |
| Customer main navigation | BottomNav exact five-destination contract |
| Compact availability/trust disclosure | StatusChip `Available|LowStock|Unavailable|Verified|Sponsored` |

## 8. Screen usage mapping

| Ekran/akış | Önerilen canonical families |
|---|---|
| Home / discovery pilot | Search/Location TextField, CategoryCard, ProductCard, MerchantCard, BottomNav |
| Category / search results | Search TextField, CategoryRow, ProductCard, BottomNav |
| Product detail | ProductCard visual language, SellerPriceRow, ShopRatingSummary, VerifiedPurchaseBadge, Button |
| Merchant detail | MerchantCard, SellerPriceRow, ShopRatingSummary, Button |
| Cart V2 | CartShopHeader, CartItem, SingleStoreConflictState, Button, StatusChip |
| Auth/profile/merchant forms | TextField, Button, StatusChip |
| Review surface | ShopRatingSummary, VerifiedPurchaseBadge; review editor/card ayrı faz |

Bu mapping Phase C critical-screen pilotunda Home, Category Listing, Product
Details, Shop Details ve Cart V2 için doğrulanmıştır. Pilot node envanteri ve
ekran-spesifik kararlar
`docs/ESNAFTAVAR_CRITICAL_SCREEN_PILOT_V1.md` içindedir.

## 9. Accessibility and usability

- Primary `#B54732` / white: `5.37:1` — WCAG AA normal text PASS.
- Accent `#1F6B5D` / white: `6.33:1` — PASS.
- Primary / primarySoft: `4.57:1`; Accent / accentSoft: `5.51:1` — PASS.
- Success/Warning/Error/Info strong → soft pairs: `4.65:1–5.72:1` — PASS.
- Text primary/secondary/muted → background: `14.94:1 / 7.23:1 / 5.18:1` — PASS.
- Interaktif component denetiminde `44 px` altı hedef bulunmadı.
- Focus, error, success, stock, unavailable ve selected state'ler text/icon/shape cue taşır.
- Uzun Türkçe ürün, kategori ve esnaf adlarıyla wrapping/overflow denetimi yapılmıştır.
- Product image bölgeleri warm-neutral surface kullanır; brand renkleri ürün fotoğrafına baskın filtre olarak uygulanmaz.

## 10. Figma validation evidence

### 10.1 Canonical page audit

| Kontrol | Sonuç |
|---|---|
| Component set / component / public family | `13 / 89 / 14` — PASS |
| Exact Phase C `Layout=Mobile` addition | `10` — PASS |
| Expected variant matrix | PASS |
| Duplicate public family name | `0` |
| Duplicate full component key | `0` |
| Component root without Auto Layout | `0` |
| Non-Poppins text node | `0` |
| Canonical component text-style offender | `0` |
| Unbound visible solid paint | `0` |
| Legacy `#FF8523` paint | `0` |
| Unbound positive spacing value | `0` |
| Unbound positive radius value | `0` |
| Interactive target below 44 px | `0` |
| Visible child overflow | `0` |
| Section-by-section render | PASS |
| Full canonical board render | PASS |

### 10.2 Protected source fingerprints

B3 task-local fingerprint; node ID/type/name, 2-decimal geometry, child count ve instance main-component ID alanlarından hesaplanmıştır.

| Protected page | Node | Pre-write | Post-write | Sonuç |
|---|---:|---:|---:|---|
| Cover | `458:7710` | `8d49790d` | `8d49790d` | UNCHANGED |
| UI | `401:358` | `211def49` | `211def49` | UNCHANGED |
| Components | `401:359` | `f2da7779` | `f2da7779` | UNCHANGED |
| Styles Guide | `16:3` | `0a462f2b` | `0a462f2b` | UNCHANGED |

K'pasa source component, instance, screen ve style'larında mutation yapılmamıştır.

### 10.3 Phase C Mobile extension evidence

- Component root Auto Layout: `89/89` — PASS.
- Duplicate public family: `0`.
- Visible solid paint without canonical variable: `0`.
- Non-Poppins text / missing font: `0 / 0`.
- Legacy `#FF8523`: `0`.
- Interactive target below `44 px`: `0`.
- Full Components V1 board render: PASS.

Phase C task-local protected source fingerprint'leri:

| Protected page | Node | Pre-write | Post-write | Sonuç |
|---|---:|---:|---:|---|
| Cover | `458:7710` | `25ec69c9` | `25ec69c9` | UNCHANGED |
| UI | `401:358` | `13b5524b` | `13b5524b` | UNCHANGED |
| Components | `401:359` | `cbc628af` | `cbc628af` | UNCHANGED |
| Styles Guide | `16:3` | `7347b88b` | `7347b88b` | UNCHANGED |

## 11. Deferred component families

V1 component layer dışında bırakılan başlıca alanlar:

- AppBar/top navigation ve safe-area shell;
- modal, bottom sheet, dialog, toast/snackbar;
- skeleton/shimmer, empty-state ve network retry cards;
- product gallery/carousel ve zoom viewer;
- filter/sort control, interactive filter chip ve taxonomy browser;
- review card/editor, review media ve moderation state'leri;
- chat, notification ve activity list items;
- QR camera/scanner permission ve failure states;
- merchant product management/editor bileşenleri;
- advertising/sponsored placement behavior;
- reward/gamification behavior;
- dark mode;
- Flutter token/component mapping ve runtime rollout.

Future semantic variables (`sponsored`, `verifiedPurchase`, `merchantBadge`, `customerBadge`, `rewardProgress`) korunur; bu doküman bunlara engine davranışı eklemez.

## 12. Implementation prerequisites

1. Bu task branch'i integration/release süreciyle main'e alınmalıdır.
2. Product owner, Figma `EsnaftaVar — Components V1` ve
   `EsnaftaVar — Critical Screens V1` board'larını görsel olarak onaylamalıdır.
3. Critical-screen pilot Phase C'de tamamlanmıştır; full rollout öncesi product-owner
   kabulü ve integration gereklidir.
4. Flutter tarafında semantic token isimleri machine-readable manifestten map edilmelidir; raw hex ve px kopyalanmamalıdır.
5. Figma variant/property sözleşmeleri Flutter widget API'lerinde aynı semantik adlarla korunmalıdır.
6. Pilot; loading, empty, error, success, disabled, uzun Türkçe text, missing image, low/unavailable stock ve 44–48 px hedef doğrulaması içermelidir.
7. Screen-wide recolor/redesign yalnız canonical component instance'ları kabul edildikten sonra başlatılmalıdır.
8. Canonical taxonomy UI entegrasyonu taxonomy verisini dinamik kullanmalı; kategori başına ekran/component üretmemelidir.

## 13. Final status

- `CANONICAL_COMPONENT_LAYER_V1: PASS`
- `PHASE_C_MOBILE_EXTENSION: PASS`
- `SOURCE_KPASA_UNCHANGED: YES`
- `RUNTIME_CODE_CHANGED: NO`
- `CRITICAL_SCREEN_PILOT_CREATED: YES`
- `READY_FOR_PRODUCT_OWNER_VISUAL_REVIEW: YES`
- `INTEGRATION_REQUIRED`
