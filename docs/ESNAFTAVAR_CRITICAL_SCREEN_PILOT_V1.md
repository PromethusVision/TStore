# EsnaftaVar Critical Screen Pilot V1

> WAVE 14 — PHASE C · Critical Screen Pilot V1
> Tarih: 2026-08-26
> Durum: **FIGMA PILOT COMPLETE / PRODUCT OWNER VISUAL REVIEW READY**
> Git base: `origin/main@7992dee8fb6512c53a94e8a094ab2b729a49bc3a`
> Task branch: `agent-ui/w14-critical-screen-pilot-v1`
> Figma: [EsnaftaVar — Final UI System](https://www.figma.com/design/O8MIn0KyQfFoPA3EnhiWii/EsnaftaVar-%E2%80%94-Final-UI-System)
> Canonical component source: [ESNAFTAVAR_COMPONENT_LIBRARY_V1.md](./ESNAFTAVAR_COMPONENT_LIBRARY_V1.md)

## 1. Sonuç

Canonical EsnaftaVar token ve component katmanının birlikte çalıştığını doğrulayan,
Figma-only bir critical-screen pilot oluşturuldu. Pilot full-app redesign değildir;
yalnız aşağıdaki beş kritik müşteri alanını kapsar:

1. Home
2. Category / Product Listing
3. Product Details + Seller Price Comparison
4. Shop Details
5. Cart V2

| Artifact | Değer |
|---|---|
| Figma page | `EsnaftaVar — Critical Screens V1` |
| Page node | `52825:2` |
| Pilot board | `EsnaftaVar — Critical Screens V1 / Pilot Board` |
| Board node | `52825:3` |
| Board size | `2520 × 5212` |
| Primary mobile frame | `390 × 844` |
| Screen/state frame | `9` |
| Public component family | `14` — değişmedi |
| Canonical component set | `13` |
| Canonical component node | `89` |
| Phase C Mobile varyantı | `10` |
| Yeni public family | `0` |
| K'pasa source mutation | `0` |
| Flutter/runtime mutation | `0` |

## 2. Figma ekran envanteri

| Bölüm | Section node | Ekran/durum | Screen node |
|---|---:|---|---:|
| `01 Home` | `52825:4` | Home / Primary | `52835:6` |
| `01 Home` | `52825:4` | Home / Guest Location Auth Gate | `52835:208` |
| `02 Category Listing` | `52825:5` | Category Listing / Taxonomy Ready | `52838:204` |
| `03 Product Details` | `52825:6` | Product Details / Overview | `52839:384` |
| `03 Product Details` | `52825:6` | Product Details / Seller Comparison | `52839:481` |
| `04 Shop Details` | `52825:7` | Shop Details / Customer View | `52840:561` |
| `05 Cart V2` | `52825:8` | Cart V2 / Active Single Store | `52841:687` |
| `05 Cart V2` | `52825:8` | Cart V2 / Wrong Store Conflict | `52841:808` |
| `05 Cart V2` | `52825:8` | Cart V2 / Empty State | `52841:905` |

Her screen root'u `390 × 844`, vertical Auto Layout, `44 px` safe-area,
`720 px` clipped vertical scroll viewport ve `80 px` canonical BottomNav yapısını
kullanır.

## 3. Canonical component kullanımı

Pilot içinde aşağıdaki mevcut public family'lerin instance'ları kullanıldı:

- `EsnaftaVar/Button`
- `EsnaftaVar/TextField`
- `EsnaftaVar/BottomNav`
- `EsnaftaVar/CategoryCard`
- `EsnaftaVar/ProductCard`
- `EsnaftaVar/SellerPriceRow`
- `EsnaftaVar/MerchantCard`
- `EsnaftaVar/ShopRatingSummary`
- `EsnaftaVar/VerifiedPurchaseBadge`
- `EsnaftaVar/CartShopHeader`
- `EsnaftaVar/CartItem`
- `EsnaftaVar/SingleStoreConflictState`

Screen shell, app bar, bilgi callout'u, breadcrumb, ürün medyası fallback'i ve empty
state gibi pilot-spesifik kompozisyonlar screen-local frame olarak bırakıldı. Yeni
public family üretilmedi; canonical library duplicate edilmedi.

## 4. Onaylı Phase C Mobile varyantları

Phase 0 onayı doğrultusunda yalnız beş mevcut aileye toplam **10**
`Layout=Mobile` varyantı eklendi. Mevcut Wide varyantlar korundu.

| Aile | Component set | Eklenen Mobile varyantlar | Node'lar |
|---|---:|---|---|
| SellerPriceRow | `52801:71` | Default, BestPrice, Unavailable | `52828:38`, `52828:62`, `52828:86` |
| MerchantCard | `52801:120` | Image Available, Image Fallback | `52830:50`, `52830:79` |
| CartItem | `52803:102` | Available, LowStock, Unavailable | `52831:66`, `52831:88`, `52831:110` |
| CartShopHeader | `52832:86` | Mobile | `52832:66` |
| SingleStoreConflictState | `52833:107` | Mobile | `52833:66` |

`CartShopHeader` ve `SingleStoreConflictState` mevcut Wide component kimliklerini
koruyarak component set'e dönüştürüldü. Yeni variant axis dışında token, Poppins,
public property ve ürün semantiği değiştirilmedi.

## 5. Ekran sözleşmeleri

### 5.1 Home

- Konum yüzeyi, arama, kategori girişi, organik keşif ürünleri ve yakın esnaf
  sunumu aynı akışta gösterilir.
- “Featured” örnek ürün sponsorlu sayılmaz; sponsorlu sıralama veya placement
  davranışı yoktur.
- Actual customer BottomNav korunur.
- Konum kişiselleştirmesi AuthGuard ile temsil edilir; runtime davranışı bu fazda
  uygulanmaz.

### 5.2 Category / Product Listing

- Breadcrumb, dinamik alt kategori satırı, arama refinement, filtre, sıralama,
  availability ve ürün listesi birlikte gösterilir.
- Kategori sayısı hard-code edilmez; yatay alt kategori alanı ve breadcrumb daha
  derin seviyelere ölçeklenir.
- Figma'daki kategori etiketleri **temsili/provisional içeriktir**. Yapı canonical
  taxonomy V1'in `L1→L2→L3→L4` derinliğini yeniden ekran tasarlamadan tüketmeye
  hazırdır.
- Taxonomy backend/runtime implementation yapılmamıştır.

### 5.3 Product Details + Seller Comparison

- Ürün bilgisi, fallback görsel, kategori context'i, rating özeti ve yerel fiyat
  aralığı seller comparison öncesinde sunulur.
- Birincil ürün sorusu açıkça “Bu ürünü hangi esnaflarda bulabilirim?” olarak
  görünür.
- Seller comparison ekranı `15 esnaf` context'i ve 4 temsili state ile gösterilir;
  aynı dikey liste sözleşmesi kalan `+11` satırı ve 14–15+ satıcıyı destekler.
- SellerPriceRow; fiyat, rating, mesafe, availability, best-price ve
  `Mağazayı Gör` aksiyonunu korur.
- Online `Buy Now`, checkout veya delivery CTA'sı yoktur.

### 5.4 Shop Details

- Mağaza kimliği, adres, mesafe, rating, açık durum, Yol Tarifi, mağaza ürünleri ve
  review context'i müşteri tarafında sunulur.
- Merchant yönetim kontrolü veya owner-only aksiyon eklenmemiştir.
- Fiziksel mağaza ziyareti primary aksiyon hiyerarşisidir.

### 5.5 Cart V2

- Active state yalnız bir aktif mağaza, ürün satırları, quantity, remove,
  availability ve estimated total gösterir.
- Wrong-store state mağaza karışımını sessizce yapmaz; açık kullanıcı kararı ister.
- Empty state kullanıcıyı yakındaki ürün keşfine döndürür.
- Sepet, online sipariş değil tek mağazalı fiziksel alışveriş hazırlığı/niyetidir.
- Demo mağazanın kayıtlı sahibi olmadığı açıkça belirtilir; QR doğrulama
  kullanılabilirliği ima edilmez.
- Shipping address, payment card, delivery option, checkout ve order tracking yoktur.

## 6. Location AuthGuard temsili

Guest genel içeriği gezebilir. Home guest state'te yakınlık/konum kişiselleştirmesi
isteyen aksiyon canonical login gate mesajına yönelir:

`guest → location action → login/auth gate`

Bu yalnız görsel state'tir. Flutter AuthGuard, route veya session davranışı
değiştirilmemiştir. Runtime rollout sırasında Nearby ve kayıtlı konum kullanan bütün
giriş noktaları aynı canonical AuthGuard sözleşmesini tüketmelidir.

## 7. Erişilebilirlik ve kalite kapıları

| Kontrol | Sonuç |
|---|---|
| Screen/state frame | `9/9` — PASS |
| Screen root Auto Layout | `9/9` — PASS |
| Screen-local child composition without Auto Layout | `0` |
| Canonical component source outside EsnaftaVar page | `0` |
| Public component family / duplicate family | `14 / 0` |
| Component set / component node | `13 / 89` |
| Exact `Layout=Mobile` addition | `10` — PASS |
| Visible solid paint without semantic variable | `0` |
| Legacy `#FF8523` | `0` |
| Non-Poppins text / missing font | `0 / 0` |
| Interactive target below 44 px | `0` |
| Turkish text-risk finding | `0` |
| Safe area / fixed BottomNav / vertical scroll | `9/9` — PASS |
| Section-by-section render | PASS |
| Full-board render | PASS |

WCAG contrast kontrolü:

| Pair | Ratio | Sonuç |
|---|---:|---|
| textPrimary / background | `14.94:1` | AA PASS |
| textSecondary / background | `7.23:1` | AA PASS |
| textMuted / background | `5.18:1` | AA PASS |
| textOnPrimary / primary | `5.37:1` | AA PASS |
| textOnAccent / accent | `6.33:1` | AA PASS |
| success / successSoft | `4.65:1` | AA PASS |
| warning / warningSoft | `5.72:1` | AA PASS |
| error / errorSoft | `5.67:1` | AA PASS |
| info / infoSoft | `5.57:1` | AA PASS |
| price / background | `7.84:1` | AA PASS |
| unavailable / background | `5.18:1` | AA PASS |

## 8. K'pasa source fingerprint sonucu

Phase C task-local fingerprint; node ID/type/name, iki ondalık geometri, child count
ve instance main-component ID alanlarından hesaplandı. Pre-write ve post-write aynı
algoritmayla karşılaştırıldı.

| Protected page | Node | Pre-write | Post-write | Sonuç |
|---|---:|---:|---:|---|
| Cover | `458:7710` | `25ec69c9` | `25ec69c9` | UNCHANGED |
| UI | `401:358` | `13b5524b` | `13b5524b` | UNCHANGED |
| Components | `401:359` | `cbc628af` | `cbc628af` | UNCHANGED |
| Styles Guide | `16:3` | `7347b88b` | `7347b88b` | UNCHANGED |

K'pasa Cover/UI/Components/Styles page'lerinde source component, instance, screen,
style veya variable mutation yapılmadı.

## 9. Runtime ve rollout durumu

- Flutter rollout: **NOT STARTED**
- Flutter source change: **NO**
- Production operation: **NO**
- Development operation: **NO**
- Backend/migration/taxonomy implementation: **NO**
- Advertising/reward/gamification implementation: **NO**

## 10. Implementation prerequisites

1. Bu task branch'i integration/release süreciyle main'e alınmalıdır.
2. Product owner, `EsnaftaVar — Critical Screens V1` board'unu görsel olarak
   onaylamalıdır.
3. Onaydan önce full UI rollout veya Flutter screen migration başlatılmamalıdır.
4. Flutter mapping'de raw hex/px kopyalanmamalı; canonical semantic token ve public
   component property adları korunmalıdır.
5. Runtime taxonomy canonical JSON'u dinamik tüketmeli; pilotun temsili etiketleri
   veri kaynağı sayılmamalıdır.
6. Location/Nearby akışı mevcut canonical AuthGuard ile tek sözleşmeye bağlanmalıdır.
7. Cart V2 tek-mağaza ve fiziksel satın alma niyeti semantiğini korumalıdır.
8. Seller listesi 14–15+ satırda performans, loading, empty ve error state'leriyle
   ayrıca runtime doğrulanmalıdır.

## 11. Final status

- `CRITICAL_SCREEN_PILOT_V1: PASS`
- `TAXONOMY_READY_UI_STRUCTURE: YES`
- `SOURCE_KPASA_UNCHANGED: YES`
- `READY_FOR_PRODUCT_OWNER_VISUAL_REVIEW: YES`
- `READY_FOR_FULL_UI_ROLLOUT: NO`
- `INTEGRATION_REQUIRED`
