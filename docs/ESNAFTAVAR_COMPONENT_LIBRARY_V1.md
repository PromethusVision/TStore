# EsnaftaVar Canonical Component Library V1

> WAVE 14 — PHASE B3 · Canonical Component Layer V1
> Tarih: 2026-08-26
> Durum: **CANONICAL V1 / PRODUCT OWNER VISUAL REVIEW READY**
> Git base: `origin/main@911e326609fed85e3d6b55be6d27d75a91ce2176`
> Task branch: `agent-ui/w14-canonical-component-layer-v1`
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
| Board size | `2520 × 5004` |
| Public component family | `14` |
| Component set | `11` |
| Component node | `79` |
| Canonical font | Poppins only |
| Canonical color direction | Mahalle Terracotta: primary `#B54732`, accent `#1F6B5D` |
| Source K'pasa component/screen/style mutation | `0` |
| Flutter/runtime mutation | `0` |

Bu faz component-only'dir. Final ekran, Flutter widget, taxonomy motoru, reklam motoru, ödül/gamification davranışı veya ödeme/checkout akışı üretilmemiştir.

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
| `EsnaftaVar/SellerPriceRow` | `52801:71` | Component set | 3 | 3 availability |
| `EsnaftaVar/MerchantCard` | `52801:120` | Component set | 2 | 2 image state |
| `EsnaftaVar/ShopRatingSummary` | `52802:87` | Component set | 2 | 2 density |
| `EsnaftaVar/VerifiedPurchaseBadge` | `52802:88` | Standalone component | 1 | Server-authoritative marker |
| `EsnaftaVar/CartShopHeader` | `52803:22` | Standalone component | 1 | Single-store cart merchant header |
| `EsnaftaVar/CartItem` | `52803:102` | Component set | 3 | 3 availability |
| `EsnaftaVar/SingleStoreConflictState` | `52803:103` | Standalone component | 1 | Explicit cart replacement confirmation |
| `EsnaftaVar/StatusChip` | `52804:55` | Component set | 5 | 5 semantic tone |

Toplam: **11 component set, 79 component node, 14 public family**.

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

- SellerPriceRow: `Availability=Available|LowStock|Unavailable`
- MerchantCard: `Image=Available|Fallback`
- Seller properties: `Merchant name`, `Price`
- Merchant properties: `Merchant name`, `Show merchant badge`
- CTA'lar canonical Button instance'larıdır.
- `En uygun fiyat` etiketi yalnız presentational örnektir; sıralama/auction/advertising algoritması tanımlamaz.
- Merchant badge `future/merchantBadge` görsel slotunu kullanır; bir badge engine tanımlamaz.

### 4.7 ShopRatingSummary / VerifiedPurchaseBadge

- ShopRatingSummary: `Density=Compact|Detailed`
- Properties: `Rating`, `Review count`
- Detailed varyant 5→1 dağılım yapısını; Compact varyant özet mesajını gösterir.
- VerifiedPurchaseBadge `future/verifiedPurchase` slotunu kullanır.
- Verified purchase durumu istemci tarafından tahmin edilemez veya atanamaz; server-authoritative ürün sözleşmesidir.

### 4.8 Cart V2

- CartShopHeader property: `Merchant name`
- CartItem: `Availability=Available|LowStock|Unavailable`
- CartItem properties: `Product name`, `Quantity`
- Quantity stepper ve remove action `44 px`'dir.
- Unavailable item sepette görünür ve kaldırılabilir; stock state açık text ile verilir.
- SingleStoreConflictState property: `Description`
- Conflict state, mevcut mağazayı ve yeni mağazayı açıklayarak `Vazgeç` / `Sepeti Değiştir` onayı ister.
- Checkout, ödeme, shipping veya order tracking davranışı bu componentlerde yoktur.

### 4.9 StatusChip

- `Tone`: `Success`, `Warning`, `Error`, `Info`, `Neutral`
- Her tone farklı icon shape, açık text label ve strong/soft token çifti kullanır.
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
| StatusChip | success/warning/error/info strong+soft, surfaceAlt/textSecondary | `space/*`, `radius/pill`, `type/label` |

Canonical foundation toplamı değişmemiştir: `38` color variable, `15` dimension variable, `12` Poppins text style ve `3` effect style.

## 6. Product-state mapping

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

## 7. Screen usage mapping

| Ekran/akış | Önerilen canonical families |
|---|---|
| Home / discovery pilot | Search/Location TextField, CategoryCard, ProductCard, MerchantCard, BottomNav |
| Category / search results | Search TextField, CategoryRow, ProductCard, BottomNav |
| Product detail | ProductCard visual language, SellerPriceRow, ShopRatingSummary, VerifiedPurchaseBadge, Button |
| Merchant detail | MerchantCard, SellerPriceRow, ShopRatingSummary, Button |
| Cart V2 | CartShopHeader, CartItem, SingleStoreConflictState, Button, StatusChip |
| Auth/profile/merchant forms | TextField, Button, StatusChip |
| Review surface | ShopRatingSummary, VerifiedPurchaseBadge; review editor/card ayrı faz |

Bu tablo implementation mapping'idir; bu fazda yukarıdaki ekranların hiçbiri oluşturulmamıştır.

## 8. Accessibility and usability

- Primary `#B54732` / white: `5.37:1` — WCAG AA normal text PASS.
- Accent `#1F6B5D` / white: `6.33:1` — PASS.
- Primary / primarySoft: `4.57:1`; Accent / accentSoft: `5.51:1` — PASS.
- Success/Warning/Error/Info strong → soft pairs: `4.65:1–5.72:1` — PASS.
- Text primary/secondary/muted → background: `14.94:1 / 7.23:1 / 5.18:1` — PASS.
- Interaktif component denetiminde `44 px` altı hedef bulunmadı.
- Focus, error, success, stock, unavailable ve selected state'ler text/icon/shape cue taşır.
- Uzun Türkçe ürün, kategori ve esnaf adlarıyla wrapping/overflow denetimi yapılmıştır.
- Product image bölgeleri warm-neutral surface kullanır; brand renkleri ürün fotoğrafına baskın filtre olarak uygulanmaz.

## 9. Figma validation evidence

### 9.1 Canonical page audit

| Kontrol | Sonuç |
|---|---|
| Component set / component / public family | `11 / 79 / 14` — PASS |
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

### 9.2 Protected source fingerprints

B3 task-local fingerprint; node ID/type/name, 2-decimal geometry, child count ve instance main-component ID alanlarından hesaplanmıştır.

| Protected page | Node | Pre-write | Post-write | Sonuç |
|---|---:|---:|---:|---|
| Cover | `458:7710` | `8d49790d` | `8d49790d` | UNCHANGED |
| UI | `401:358` | `211def49` | `211def49` | UNCHANGED |
| Components | `401:359` | `f2da7779` | `f2da7779` | UNCHANGED |
| Styles Guide | `16:3` | `0a462f2b` | `0a462f2b` | UNCHANGED |

K'pasa source component, instance, screen ve style'larında mutation yapılmamıştır.

## 10. Deferred component families

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

## 11. Implementation prerequisites

1. Bu task branch'i integration/release süreciyle main'e alınmalıdır.
2. Product owner, Figma `EsnaftaVar — Components V1` board'unu görsel olarak onaylamalıdır.
3. İlk critical-screen pilot tek bir akışta yapılmalıdır; önerilen pilot Product Detail + SellerPriceRow veya Cart V2'dir.
4. Flutter tarafında semantic token isimleri machine-readable manifestten map edilmelidir; raw hex ve px kopyalanmamalıdır.
5. Figma variant/property sözleşmeleri Flutter widget API'lerinde aynı semantik adlarla korunmalıdır.
6. Pilot; loading, empty, error, success, disabled, uzun Türkçe text, missing image, low/unavailable stock ve 44–48 px hedef doğrulaması içermelidir.
7. Screen-wide recolor/redesign yalnız canonical component instance'ları kabul edildikten sonra başlatılmalıdır.
8. Canonical taxonomy UI entegrasyonu taxonomy verisini dinamik kullanmalı; kategori başına ekran/component üretmemelidir.

## 12. Final status

- `CANONICAL_COMPONENT_LAYER_V1: PASS`
- `SOURCE_KPASA_UNCHANGED: YES`
- `RUNTIME_CODE_CHANGED: NO`
- `READY_FOR_CRITICAL_SCREEN_PILOT: YES`
- `INTEGRATION_REQUIRED`
