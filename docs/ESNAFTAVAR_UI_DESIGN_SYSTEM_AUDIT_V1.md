# EsnaftaVar UI Design System Audit V1

> WAVE 14 — PHASE A · K'pasa Design System Audit
> Tarih: 2026-08-25
> Kaynak: `EsnaftaVar — Final UI System`
> Figma file key: `O8MIn0KyQfFoPA3EnhiWii`
> Figma URL: <https://www.figma.com/design/O8MIn0KyQfFoPA3EnhiWii/EsnaftaVar-%E2%80%94-Final-UI-System>
> Git base: `f41314ca4a57a3f5820c481c0182700cfbd6207e`
> Kapsam: Figma salt-okunur audit; final palette, ekran redesign'ı ve runtime uygulama kapsam dışıdır.

## 1. Executive summary

K'pasa dosyası, EsnaftaVar için sıfırdan başlamak yerine yararlanılabilecek geniş bir mobil e-ticaret iskeleti sunuyor. En güçlü tarafları; buton, text field ve bottom navigation component setleri; 142 parçalık 24 px ikon havuzu; temel ürün, kategori, bildirim, yorum ve mesaj kartları; onboarding/auth ile keşif ekranlarının geniş state örnekleridir.

Sistem buna rağmen EsnaftaVar'a doğrudan uygulanabilecek olgunlukta değildir:

- Yerel Figma variable collection sayısı **0**. Token sistemi paint/text/effect style'lara ve bağlı kütüphane stillerine dağılmıştır.
- 32 yerel paint style içinde semantik ve ham palette adları karışık; yinelenen ve çelişen adlar vardır.
- 113 mobil ekranın 111'i Poppins ile Inter'ı birlikte kullanır. 2.150 text node'un 571'i text style'sızdır.
- Ekran katmanlarında Auto Layout oranı %48,6; frame-benzeri düğümlerin %65,3'ü sabit genişliklidir. 883 çok-çocuklu alan mutlak yerleşime dayanır.
- Card bölümündeki 34 component'in hiçbiri component set içinde değildir. Card ailesi görsel açıdan yararlı, fakat varyant/state API'si olarak paketlenmemiştir.
- Klasik checkout, online payment, shipping ve order tracking ekranları dosyada geniş yer kaplar; hedef EsnaftaVar müşteri modelinde kullanılmamalıdır.
- Merchant, mesafe, yol tarifi, satıcı fiyat karşılaştırması, mağaza bazlı Cart V2 ve canonical taxonomy ihtiyaçları mevcut kitte karşılanmamaktadır.

Sonuç: **component altyapısı seçici biçimde korunmalı; token, tipografi, layout ve ürün varsayımları değiştirilmelidir.** Beklenen sonraki faz `WAVE 14 PHASE B — ESNAFTAVAR DESIGN TOKENS V1` olmalıdır. Canonical Category Taxonomy çalışması, token audit'inden sonra ve category/search/filter UI uygulamasından önce başlatılmalıdır.

## 2. Audit yöntemi ve Figma erişimi

- MCP erişimi başarılıdır; Design dosyası, node metadata'sı, local style API'leri ve salt-okunur Plugin API sorguları kullanılabilmiştir.
- Figma dosyasında hiçbir create/edit/delete/rename/recolor/variable/component/Auto Layout işlemi yapılmamıştır.
- Görsel doğrulama `Basic`, `Text Fields`, `Navbar` ve `Card` bölümlerinin salt-okunur screenshot'larıyla yapılmıştır.
- Repo içinde bu görevden önce UI/design-system audit dokümanı bulunmamıştır. `docs/PROJECT_STATE.md` ile ürün backlog'u referans alınmıştır.
- Bulgular mevcut Figma snapshot'ını anlatır; bağlı library style'ları aynı dosyada yerel style olarak görünmediği yerlerde MCP ile style ID üzerinden çözülmüştür.

## 3. Figma structure inventory

### 3.1 Sayfalar

| Sayfa | Node ID | Gerçek içerik |
|---|---:|---|
| `📔 Cover` | `458:7710` | `UI8 Thumbnail` (`949:2048`, 1208×840) |
| `📱 UI` | `401:358` | 124 üst-seviye öğe; 113 numaralı mobil ekran, 375 px ana viewport |
| `⚙️ Components` | `401:359` | Icon, Basic, Text Fields, Navbar, Illustration ve Card bölümleri |
| `🎨 Styles Guide` | `16:3` | Colors ve Font referans çerçeveleri |

### 3.2 Component sayfasının ana bölümleri

| Bölüm | Node ID | Ölçü | Özet |
|---|---:|---:|---|
| `Icon` | `418:400` | 688×2290 | 142 bağımsız component; çoğu 24×24 Google/Material tabanlı ikon; sosyal medya, ödeme ve logo alt grupları da var |
| `Basic` | `418:3346` | 993×1458 | 4 component set, 54 component: Button, Tag, Coupon, Status |
| `Text Fields` | `851:6706` | 560×750 | 1 component set, 5 state |
| `Navbar` | `937:2008` | 560×624 | 1 bottom navigation component set, 4 active-index state |
| `Illustration` | `421:1716` | 446×2460 | 8 bağımsız 300×200 illustration component'i |
| `Card` | `940:2048` | 1752×3029 | 34 bağımsız component; component set yok |

### 3.3 Component setleri ve varyantlar

| Set | Node ID | Varyant eksenleri | Değerlendirme |
|---|---:|---|---|
| `Button` | `418:4001` | Size: small/large; Configuration: filled/outlined; Icon: n/a/with-icon; State: enabled/hovered/focused/pressed/disabled | 40 kombinasyonla matris tamam; loading ve destructive yok |
| `Tag` | `418:5080` | `Dafault`: true/false; type: tag/version/`itme-count`; size: small/large | 7 kombinasyon; eksik kombinasyonlar ve yazım hataları var; quantity control yanlış aile altında |
| `Coupon` | `418:5002` | Selected: 1st/2nd/3rd | Ürün modelinde öncelikli değil; klasik promosyon varsayımı içeriyor |
| `Status` | `418:5362` | Status: default/`warnig`/`succes`/error | Semantik yön doğru; naming ve token bağımlılığı düzeltilmeli |
| `text-field building block` | `908:9716` | State: disabled/focused/hovered/password/error | Enabled/default, filled, search, select/dropdown yok; default variant disabled |
| `Bars` | `913:7501` | State: home/favorite/notification/profile | Dört ikonlu, labelsız bottom nav; EsnaftaVar'ın beş sekmesine uymuyor |

### 3.4 Styles, variables, effects ve grid

- Local variable collection: **0**
- Local variables: **0**
- Local paint styles: **32**
- Local text styles: **7**
- Local effect styles: **6**
- Local grid styles: **1** — `Grid-4-24-16`: 4 kolon, 24 px dış offset, 16 px gutter
- Componentler local stillere ek olarak `Ink/Darkest`, `Ink/Light`, `Tiny/Normal/Regular`, `Light Gray / Light Gray 1–2` gibi bağlı library stilleri de kullanır. Bu, dosyanın kendi başına taşınabilirliğini azaltır.

### 3.5 Spacing, sizing ve image convention

- Sık görülen spacing değerleri: 4, 6, 8, 10, 12, 16 ve 24 px. Bunlar variable/token olarak tanımlı değildir.
- Button padding'i normal varyantlarda `10/24/10/24`, icon'lu varyantlarda `10/24/10/16`; pill radius 100'dür.
- Button ölçüleri içerik genişliğine göre HUG; yükseklikler 40 ve 52 px'tir.
- Text field ana kontrolü 327×48, radius 8'dir. Error component root'u 320×74 iken iç kontrol 327 px geniştir; taşma/ölçü tutarsızlığı vardır.
- 113 ekranın 109'u 375×812'dir. 4 ekran uzun içerik için 375×980–1157 aralığındadır.
- UI ekranlarındaki 298 image fill'in tamamı `FILL` kullanır. Alternatif FIT/CROP davranış spesifikasyonu yoktur.
- Card placeholder isimleri çoğunlukla `Image Placeholder (Copy paste here)` veya jenerik `Image`, `Card img`, `Avatar` biçimindedir. Card image oranları başlıca 1:1; ads 327×126, ürün hero ve review preview için farklı sabit oranlar kullanılır.

## 4. Colors / token audit

### 4.1 Genel bulgu

Renk adları üç farklı yaklaşımı aynı seviyede karıştırır:

1. Semantik görünümlü adlar: `Color/Primary`, `Color/Surface`, `Status/Error`.
2. Ham/pazarlama tipi adlar: `Colors/Aurora Light`, `Colors/Purple Haze`, `Colors/Gold`.
3. Nötr görünse de hatalı/adı belirsiz stiller: `Ashpalt`, `Notral`, `Drakers`, `Ink`, `Light`.

Variable/alias katmanı olmadığı için semantic → primitive ilişkisi yoktur. Bir rengin rolü style adından tahmin edilmekte, component seviyesinde raw renkler de kullanılmaktadır.

### 4.2 Tam local paint-style envanteri

`KEEP`, mevcut değer kesinleşti anlamına gelmez; rolün korunabileceğini ifade eder. Final EsnaftaVar palette'i Phase B'de belirlenmelidir.

| Style | Hex | Tür / bulgu | Öneri |
|---|---:|---|---|
| `Color/Primary` | `#FF8523` | Semantik; Components sayfasında 124 kullanım | **KEEP role / REPLACE value if needed** — `brand/action/primary` semantiğine taşınmalı |
| `Color/Primary Variant` | `#212529` | Semantik adı belirsiz; koyu metin rengi gibi kullanılıyor | **CONSOLIDATE** — text/ink strong semantiğine ayır |
| `Color/Secondary` | `#F9FAFE` | Soğuk yüzey; Replay ve Add Item select'te 2 kullanım | **REPLACE/CONSOLIDATE** — surface/subtle rolüyle yeniden tanımla |
| `Color/Secondary Variant` | `#EBECED` | 18 kullanım; outlined button state-layer ve mesaj noktaları | **CONSOLIDATE** — border/disabled/state-layer rollerini ayır |
| `Color/Surface` | `#FFFFFF` | Semantik yüzey; 49 component kullanımı | **KEEP** — surface/default rolü |
| `Colors/Render` | `#3D5AFE` | Ham mavi; Components sayfasında kullanım yok | **REPLACE** — aktif palette'e taşımadan önce ihtiyacı kanıtla |
| `Colors/Render Dark` | `#304FFE` | Ham mavi; kullanım yok | **REPLACE** |
| `Colors/Aurora Light` | `#64FFDA` | Ham accent; kullanım yok | **REPLACE** |
| `Colors/Aurora Dark` | `#1DE9B6` | Ham accent; kullanım yok | **REPLACE** |
| `Colors/Light Radish` | `#EF9A9A` | Ham danger tonu | **CONSOLIDATE** — danger primitive |
| `Colors/Red Radish` | `#FF5252` | 2 Card kullanımı; ham danger | **CONSOLIDATE** — danger semantic |
| `Colors/Purple Haze` | `#725AF2` | Ham accent; kullanım yok | **REPLACE** |
| `Colors/Dark Haze` | `#403D9E` | Ham accent; kullanım yok | **REPLACE** |
| `Colors/Burned Gold` | `#FFD752` | Ham rating/warning adayı | **CONSOLIDATE** — rating veya warning rolünü ayır |
| `Colors/Gold` | `#FFDA5D` | Aynı ada sahip başka değer var; kullanım yok | **CONSOLIDATE** |
| `Colors/Eclipse` | `#141B2D` | Product and Rating text'inde 1 kullanım | **CONSOLIDATE** — text/strong primitive |
| `Colors/Midnight` | `#1E2746` | Soğuk koyu mavi; kullanım yok | **REPLACE/CONSOLIDATE** |
| `Colors/Dusk` | `#383B4C` | Soğuk gri-mavi; kullanım yok | **REPLACE/CONSOLIDATE** |
| `Colors/Granite` | `#626D8D` | Soğuk gri-mavi; kullanım yok | **REPLACE/CONSOLIDATE** |
| `Colors/Ashpalt` | `#808B9D` | 21 kullanım; yorum, adres, typing, tag ve ikonlar | **REPLACE/CONSOLIDATE** — text/muted ve icon/inactive rollerine böl; adı düzelt |
| `Colors/Concrete` | `#AEBAC8` | 6 kullanım; notification ve comment | **REPLACE/CONSOLIDATE** — border/disabled ayrımı |
| `Colors/Dark Smoke` | `#E2E7F0` | 3 kullanım; notification/title | **REPLACE/CONSOLIDATE** — border/subtle surface |
| `Colors/White Light` | `#F2F8FA` | Soğuk yüzey; kullanım yok | **REPLACE** |
| `Colors/Black` | `#000000` | Ham siyah | **CONSOLIDATE** — text/strong primitive |
| `Status/Error` | `#F04438` | Semantik danger | **KEEP role** — kontrast Phase B'de doğrulanmalı |
| `Colors/Ink` | `#72777A` | 13 kullanım; notification, transaction, profile, text field | **CONSOLIDATE** — text/secondary ve icon/muted rollerine böl |
| `Colors/Light` | `#E3E5E5` | Birebir duplicate style 1; kullanım yok | **CONSOLIDATE** |
| `Colors/Drakers` | `#090A0A` | Ham koyu nötr; adı hatalı | **CONSOLIDATE** — text/strong primitive; adı düzelt |
| `Colors/Notral` | `#445275` | Password field icon'unda 1 kullanım | **REPLACE/CONSOLIDATE** — icon/secondary; adı düzelt |
| `Colors/Gray` | `#667085` | Coupon text'inde 2 kullanım | **CONSOLIDATE** — neutral/text role |
| `Colors/Gold` | `#FFB323` | Aynı ad, farklı değer; local style kullanımı yok, Card'da raw olarak 20 kez rating yıldızı | **CONSOLIDATE** — tek rating/warning primitive |
| `Colors/Light` | `#E3E5E5` | Birebir duplicate style 2; kullanım yok | **CONSOLIDATE** |

### 4.3 Duplicate, naming ve hard-coded renkler

- `Colors/Light #E3E5E5` iki ayrı style ID ile birebir duplicate'tir.
- `Colors/Gold` iki farklı değer taşır: `#FFDA5D` ve `#FFB323`.
- `Ashpalt`, `Notral`, `Drakers` adları hatalı veya semantik değildir.
- Card bölümünde raw olarak `#000000`, `#FFFFFF`, `#FFB323`, `#F9FAFE`, `#F5F5F5` opacity varyantları, `#CCAD8A`, `#C9011B`, `#646663`, `#D9D9D9` kullanılır.
- Basic Status setinde raw `#F9F9F9`, `#888888`, `#FFFAE6`, `#FAAD14`, `#FFF2F2`, `#FF5B05`, `#EAFEE0`, `#52C41A` bulunur.
- Text Field error örneğinde raw `#667085` kullanımı vardır.

Bu değerler Phase B'de primitive + semantic variable katmanlarına konsolide edilmeli; componentler raw renk referansı taşımamalıdır.

## 5. Typography audit

### 5.1 Local Poppins text styles

| Style | Font | Size | Line height | Not |
|---|---|---:|---:|---|
| `Headers/H1-Poppins-Semi Bold-60px` | Poppins SemiBold | 60 | 80 | Büyük pazarlama başlığı; mobil ürün UI'sında sınırlı kullanım |
| `Headers/H2-Poppins-Semi Bold-40px` | Poppins SemiBold | 40 | 60 | Component section başlıklarında kullanılıyor |
| `Headers/H3-Poppins-Bold-26px` | Poppins Bold | 26 | 32 | Heading |
| `Body/B1-Poppins-Reguler-16px` | Poppins Regular | 16 | 24 | `Reguler` yazım hatası |
| `Body/B2-Poppins-Regular-12px` | Poppins Regular | 12 | 20 | Küçük metin |
| `Subtitle/S1-Poppins-bold-18px` | Poppins Bold | 18 | 32 | `bold` case tutarsızlığı |
| `Subtitle/S2-Poppins-Bold-16px` | Poppins Bold | 16 | 32 | Line height görece gevşek |

Tüm local stillerde letter spacing `%0`'dır. Medium, caption, label, price/numeric ve button için local Poppins style bulunmaz.

### 5.2 Poppins / Inter karışımı

- UI sayfasında 2.150 text node vardır: Poppins 1.276, Inter 866, mixed 8.
- 113 ekranın **111'i** iki aileyi birlikte kullanır.
- 571 text node herhangi bir text style'a bağlı değildir.
- Basic Button: 40 varyantta Poppins SemiBold 16/20; tüm button label'ları raw text style'dır.
- Basic Tag/Coupon/Status: ağırlıklı Inter 10–20 px kullanır.
- Text Fields: Inter Regular 12/12, 16/16 ve error helper 14/20; yalnız section başlığı Poppins'tir.
- Product Card: Poppins Regular 16/24 başlık/fiyat ile Inter Regular 12/16 açıklama/review count aynı component içinde karışır.
- Card Address, quantity, product title/variant/size gibi alt ailelerde Inter; notifications, transactions, comments ve profile'da ağırlıklı Poppins kullanılır.
- Card bölümündeki 33 text node raw; Basic bölümündeki 60 text node raw'dır.

### 5.3 Recommendation

**Tek ana font ailesine standardizasyon mantıklıdır.** Ürün kararıyla uyumlu olarak Poppins ana aile adayıdır. Inter ancak teknik/numerik bir ikincil rol için bilinçli, belgelenmiş ve tokenlaştırılmış bir istisna olursa korunmalıdır; mevcut component-bazlı rastlantısal karışım korunmamalıdır.

Phase B'de font ailesi seçiminin yanında semantic type ramp (`display`, `heading`, `title`, `body`, `label`, `caption`, `price`) tanımlanmalı; style adlarından font ailesi/px ayrıntısı kaldırılmalı veya sistematik hale getirilmelidir.

## 6. Basic / Button / Tag audit

### 6.1 Button

- Component set: `Button` (`418:4001`)
- Varyant sayısı: 40
- Yükseklik: small 40 px, large 52 px
- Configuration: filled, outlined
- State: enabled, hovered, focused, pressed, disabled
- Icon: n/a, with-icon; instance-swap property mevcut
- Radius: 100 (pill)
- Normal horizontal padding: 24 px; icon tarafı 16 px; icon gap çoğunlukla 8 px
- Auto Layout: componentlerin 50'si horizontal/vertical; 4 Basic component'i `NONE`
- Color dependency: Primary, Surface, Primary Variant, Secondary Variant ve bağlı shadow style'ları

**Güçlü taraf:** state matrisi eksiksiz ve görsel ayrımlar anlaşılır. 52 px large touch target yeterlidir.

**Riskler:**

- 40 px small button, önerilen 44×44 minimum touch target'ın altındadır.
- Loading/progress, destructive/danger ve success action varyantları yoktur.
- Label'lar text style'a bağlı değildir.
- Bazı pressed/focused/hovered component root'larında padding `0` görünür; state-layer iç yapısına bağımlılık, component API'sini kırılganlaştırır.
- Hover mobilde ana state olmamalı; desktop/web taşınabilirliği için kalabilir ancak mobile state hiyerarşisiyle karıştırılmamalıdır.

**Karar:** component-set mantığını **KORU**; token, typography, min-height ve eksik durumları **DEĞİŞTİR**.

### 6.2 Tags / chips / status / quantity

- `Tag` seti (`418:5080`) 7 component içerir; yükseklikler 16, 20, 24, 36 ve 52 px arasında değişir.
- `Dafault`, `itme-count` yazım hataları ve incomplete variant matrix vardır.
- Tag ve Status 16–24 px olduğundan bunlar yalnız display badge olarak güvenlidir; interaktif chip ise 44 px tap wrapper gerektirir.
- Quantity control small 152×36, large 200×52'dir. Sepet için yararlı bir pattern olsa da `Tag` ailesinde yer almamalıdır.
- `Status` seti default/warning/error/success semantiğine yakındır fakat raw renk ve yanlış adlar kullanır.
- `Coupon` seti EsnaftaVar'ın şu anki öncelikli motorlarından biri değildir; component slot'u ileride değerlendirilebilir, mevcut haliyle aktif sistemin parçası yapılmamalıdır.

**Karar:** badge ve quantity davranış kalıplarını **KORU**; ayrı component ailelerine bölerek **DEĞİŞTİR**. Klasik coupon sunumunu şimdilik **KULLANMA**.

## 7. Text Field audit

- Component set: `text-field building block` (`908:9716`)
- Varyantlar: disabled (`908:10901`), focused (`908:10902`), hovered (`908:10903`), password (`908:10905`), error (`908:11013`)
- Kontrol ölçüsü: 327×48; radius 8
- Error root: 320×74; iç kontrol 327×48, helper text 320×20 ve 6 px gap
- Password state'te trailing visibility icon'u vardır.
- Error state label + value + alert icon + helper text hiyerarşisini içerir.
- Font: tamamı Inter; local Poppins ramp ile uyumsuzdur.

Eksikler:

- Enabled/default ve read-only state
- Filled/success state
- Search field ve clear action
- Select/dropdown
- Prefix/suffix/icon slot sözleşmesi
- Optional helper text (yalnız error değil)
- Multiline/textarea
- Location/address için picker ve permission state
- Merchant form'ları için label, required, counter ve validation çeşitleri

**Yeniden kullanılabilirlik:** login/signup ve password akışları için görsel kalıp korunabilir. Search, address/location ve gelecekteki merchant ürün formları için component API'si yetersizdir. Error root genişlik tutarsızlığı ve `NONE` layout ağırlığı giderilmelidir.

**Karar:** **DEĞİŞTİR** — tek Poppins ramp, semantic field tokens, Auto Layout, prefix/suffix slots ve eksik statelerle yeniden kur.

## 8. Navbar audit

- Component set: `Bars` (`913:7501`)
- Varyantlar: home (`913:7500`), favorite (`913:7502`), notification (`913:7528`), profile (`913:7541`)
- Ölçü: 375×56
- Dört eşit item: 93,75×56; icon 24×24
- Active: Primary orange; inactive: soğuk gri/mavi
- Item label'ı yoktur; icon-only pattern kullanılır.
- Component root'ları horizontal Auto Layout'tur; child slotlar `FILL/FILL` davranır.
- Safe-area/inset component ölçüsüne dahil değildir.
- UI ekranlarında `Bars / Nav Bars: Standard` top bar örnekleri görülür; Components sayfasında yerel, belgeli bir top app-bar component seti yoktur.

Mevcut EsnaftaVar customer navigation: Ana Sayfa, Yakındakiler, Sepet, Favoriler, Profil. Kitte Nearby ve Cart yok, Notification bottom-nav item olarak yer alır ve toplam item sayısı 4'tür.

**Karar:** eşit dağılım, active/inactive ve 56 px bar kabuğunu **KORU**; beş item, label/accessibility, cart/unread badge slotu ve safe-area ile **DEĞİŞTİR**. Notification bottom-nav item'ını **KULLANMA**; bildirim üst seviye aksiyon/hub olarak kalabilir.

## 9. Card-family audit

Card bölümü `940:2048` altında 34 bağımsız component içerir; hiçbir card component set/variant API'sine bağlanmamıştır.

| Component | Node ID | Ölçü | EsnaftaVar kararı |
|---|---:|---:|---|
| Ads | `940:2871` | 327×126 | Gelecek sponsored slot için yalnız yerleşim fikri; reklam motoru implement edilmez |
| Category | `940:2872` | 400×116 | 4 adet 88×116 kategori pattern'i; taxonomy adlarını kullanma, pattern'i değiştir |
| Show / hero | `940:2874` | 375×341 | Ürün medya galerisi pattern'i değiştirilebilir |
| Rating Preview | `940:2959` | 965×352 | Review photo preview pattern'i seçici koru |
| Product | `940:2875` | 141×263 | Ürün keşif kartı için aday; merchant/distance/availability eksik |
| Product + favorite (`Card`) | `940:2958` | 141×263 | Favorite action pattern'i koru; adını düzelt |
| Product and Price | `940:2998` | 318×116 | `SellerPriceRow` için en güçlü başlangıç adayı |
| Product and Rating | `940:2999` | 375×133 | Detay/selection row pattern'i; sabit layout ve raw renkleri değiştir |
| Product and ID | `940:3009` | 318×80 | Sipariş/transaction varsayımı; hedef müşteri akışında kullanma |
| Review Photo | `940:3033` | 136×40 | Thumbnail group pattern'i koru; 40 px interaction riski |
| Notifications | `940:3048`, `940:3077`, `940:3076`, `940:3157`, `940:3158` | 355–375×66–88 | Bildirim pattern'lerini değiştir; blur ve shopping copy'yi temizle |
| Transaction status | `940:3309`, `940:3310`, `940:3311`, `940:3364` | 375×92 | Delivery/packing/classic order varsayımı; kullanma |
| Comment / Reply | `940:3499`, `940:3522` | 327×164 / 327×92 | Review/comment altyapısı için değiştirerek koru |
| Coupon | `940:3586` | 375×80 | Mevcut öncelikte kullanma |
| Product title/variant/size | `940:3587`, `940:3588`, `940:3605` | 373–375 px | Ürün detay pattern'i; taxonomy/listing modeline göre değiştir |
| Address | `940:3699`, `940:3715` | 342×130 | Location/saved-address row için değiştirerek koru |
| Add Item | `940:3804`, `940:3805`, `940:3806` | 327×130 | Cart V2 quantity/selection pattern'i için değiştir |
| Message / Reply / Typing | `940:3880`, `940:3881`, `940:3882` | 96–209×24–48 | Chat bubble state mantığını koru; typing 24 px display-only |
| Profile | `940:2876` | 183×196 | Merchant/user profile mini-card için yetersiz; yeni role göre değiştir |

### 9.1 Product Card (`940:2875`)

Bilgi hiyerarşisi:

1. 141×141 square image, `FILL`
2. Product title — Poppins Regular 16/24
3. İki satır açıklama — Inter Regular 12/16
4. Beş yıldız + review count
5. Price — Poppins Regular 16/24

Güçlü taraf: küçük grid için kompakt ve okunabilir temel hiyerarşi, image ratio wrapper ve rating pattern'i hazırdır.

Hard-coded varsayımlar/riskler:

- 141 px sabit genişlik ve iki satırlık İngilizce açıklama Türkçe uzun adlarda kırılgandır.
- Para birimi `$`; fiyat biçimi localization/token modeli yoktur.
- Beş star ayrı 16 px frame olarak yerleştirilmiştir; rating 112 px sabittir.
- Merchant, kaç esnafta bulunduğu, yakınlık/mesafe, stok/listing availability ve sponsor etiketi yoktur.
- Poppins/Inter aynı component içinde karışır.
- Product root radius 0; card yüzeyi/elevation semantics'i tanımlı değildir.

**Karar:** bilgi sırasının çekirdeğini ve square image pattern'ini **KORU**; responsive width, text truncation, semantic tokens ve EsnaftaVar verileriyle **DEĞİŞTİR**.

### 9.2 Category Card (`940:2872`)

- Dört sabit 88×116 child card; 88×88 `FILL` image + Poppins 12/20 label.
- `Women`, `Man`, `Gadget`, `Food Time` yalnız demo içeriğidir; taxonomy source-of-truth değildir.
- 400 px container ve 16 px gap, 375 px mobil viewport'a doğrudan uymaz; horizontal scroll/grid davranışı tanımlı değildir.

**Karar:** image + label atomunu **KORU**; canonical taxonomy, Türkçe metin, seçili state ve responsive layout ile **DEĞİŞTİR**.

### 9.3 Product and Price (`940:2998`)

- 318×116 horizontal component; 116×116 square image, 141 px info column.
- Title, iki satır açıklama, price ve `In Stock` bilgisi vardır.
- Component'in tüccar kimliği, mağaza puanı, mesafe, yol tarifi ve aksiyon alanı yoktur.

**Karar:** `SellerPriceRow` için yapısal aday olarak **KORU**; product image yerine merchant/logo opsiyonu, merchant adı, price, stock, distance, verified state ve CTA slotlarıyla **DEĞİŞTİR**.

## 10. Screen-family audit

UI sayfasında 113 numaralı ekran vardır. 109 ekran 375×812'dir.

| Aile | Gerçek Figma ekranları | Sınıf | Not |
|---|---|---|---|
| Splash / Walkthrough | `01–05`, başlangıç `902:6896` | Likely reusable | İllüstrasyon/copy EsnaftaVar diline değiştirilmeli |
| Sign Up / Login | `06–23`, ör. `902:8134`, `908:11085` | Likely reusable | Field/button altyapısı korunabilir; sosyal login davranışı ürün gerçeğine göre ele alınmalı |
| Recovery / New Password | `24–32`, ör. `908:13529`, `908:14135` | Likely reusable | State coverage güçlü; typography/tokens değişmeli |
| Home / Search / Filter | `33–44`, ayrıca `49–50` | Likely reusable | Canonical taxonomy sonrası yeniden kurgulanmalı |
| Favorites | `45_Favorite` (`913:11337`) | Likely reusable | Card pattern'i EsnaftaVar'a uyarlanmalı |
| Notifications | `46–47` | Likely reusable | Shopping/order copy ve blur efektleri temizlenmeli |
| Settings / Profile | `48_Setting`, `105_Profile` | Likely reusable | Mevcut customer navigation ile eşleştirilmeli |
| Product Detail | `51–54`, `65`, `104` | Likely reusable | SellerPriceRow, merchant, distance ve availability eklenmeli |
| Reviews / Rating | `55–61` | Likely reusable | Verified purchase badge ve shop rating summary eksik |
| Chat | `62–64` | Likely reusable | Message pattern'i uyarlanabilir |
| Add to Cart / Cart | `66–73` | Shell reusable | Cart V2, tek-mağaza kuralı, shop header ve conflict state ile yeniden kurulmalı |
| Buy / Purchase | `74–77` | Exclude as flow | Klasik satın alma/checkout varsayımı; yalnız layout atomları seçici incelenebilir |
| Checkout group | `78–104`, heading `803:8661` | Exclude as flow | Address pattern'i location için ayrıştırılabilir; purchase/payment akışı kullanılmaz |
| Payment Method | `92–102` | Remove / do not use | Online/card payment hedef model değil |
| Purchase complete | `80`, `103` ve benzerleri | Remove / do not use | Hedef EsnaftaVar müşteri modeli değil |
| Order / Transaction / Tracking | `107–113`, heading `814:12551` | Remove / do not use | Shipping, delivery, packing ve classic tracking hedef model değil |

Dedicated Merchant discovery, seller comparison, distance/directions ve Cart V2 single-store conflict ekran aileleri bulunmamaktadır.

## 11. KEEP / CHANGE / REMOVE / CREATE decision table

| Sınıf | Kapsam | Gerekçe / sınır |
|---|---|---|
| **KORU** | Component-set yaklaşımı; Button state matrisi; 24 px generic icon havuzu; image-ratio wrapper; ürün/kategori bilgi hiyerarşisinin çekirdeği; auth/recovery state örnekleri; review/chat bildirim atomları; bottom-nav eşit item dağılımı | Bunlar ürün bağımsız, yeniden kullanılabilir altyapı sağlar |
| **DEĞİŞTİR** | Renk/token mimarisi; Poppins/Inter karışımı; Button min-height/typography; Text Field API; Navbar item/label/safe-area; Card family packaging; Product/Category/Product-and-Price; notification/comment/address/cart patterns; Auto Layout ve responsiveness | EsnaftaVar kimliği, Türkçe metin, erişilebilirlik ve gerçek ürün davranışı için gerekli |
| **KALDIR / KULLANMA** | Checkout, online/card payment, shipping, delivery/packing/transaction tracking, classic purchase/order completion; payment-brand iconları; K'pasa demo category taxonomy; mevcut Coupon akışını aktif öncelik yapmak | Product owner kararlarıyla hedef model dışında |
| **ESNAFTAVAR İÇİN YENİ OLUŞTUR** | MerchantCard, SellerPriceRow, merchant/location indicators, Cart V2 shop/single-store states, taxonomy componentleri, verified purchase/shop rating/availability states ve future label slots | K'pasa'nın klasik e-commerce modeli yerel esnaf keşfi ve mağazada hazırlık modelini karşılamıyor |

## 12. Missing EsnaftaVar components / requirements

Bu bölüm tasarım değil, Phase B ve sonraki component fazları için requirement listesidir.

| Yeni/yetersiz component | Minimum requirement |
|---|---|
| `MerchantCard` | Mağaza adı/logo veya fotoğraf, kategori, distance, rating, open/closed/availability, verified state, tap target |
| `SellerPriceRow` | Merchant identity, price, stock/listing state, distance, shop rating, selected/default state, directions/detail CTA |
| `MerchantCountIndicator` | “X esnafta var” için singular/plural ve compact/full biçim |
| `DistanceIndicator` | Metre/km biçimi, location unavailable ve permission fallback state |
| `DirectionsCTA` | Yol tarifi aksiyonu, disabled/no-location state, icon + label |
| `MerchantMiniCard` | Product detail, cart conflict ve chat context içinde kompakt merchant bilgisi |
| Taxonomy components | Category, subcategory, product group; selected/unselected, icon/image/no-image, loading/empty |
| `VerifiedPurchaseBadge` | Ürün/mağaza review bağlamı, açıklanabilir label ve erişilebilir icon |
| `ShopRatingSummary` | Ortalama, dağılım, review count, verified filter |
| `ListingAvailability` | In stock, low stock, unavailable, stale/unknown ve shop-specific state |
| `CartV2ShopHeader` | Tek mağaza bağlamı, mağaza adı, mesafe, hazırlık özeti, remove/change shop aksiyonu |
| `SingleStoreConflictState` | Mevcut sepet mağazası, yeni mağaza, açık karar ve destructive confirmation |
| `SponsoredLabelSlot` | Şimdilik motor yok; ileride Card/section üzerinde açıkça etiketlenebilir, default hidden slot |
| `CustomerMerchantBadgeSlot` | Şimdilik gamification yok; gelecekte verified/role badge için opsiyonel slot |
| Semantic state wrappers | Loading, empty, partial-error, offline/slow-network, retry ve success presentation patternleri |
| App bars | Customer top app bar, back/title/actions, cart/unread badges, safe-area davranışı |

## 13. Auto Layout, responsiveness ve accessibility riskleri

### 13.1 Ölçülebilen durum

- 113 screen'in 109'u 375×812; bütün top-level screen frame'leri `FIXED/FIXED` ve `layoutMode=NONE`.
- Screen alt ağacındaki 4.757 frame-benzeri düğümün 2.312'si Auto Layout: **%48,6**.
- 3.106 frame-benzeri düğüm sabit genişlikli: **%65,3**.
- 883 çok-çocuklu frame `layoutMode=NONE`; absolute-position kırılganlığı taşır.
- 2.150 text node'un 1.208'i sabit genişliklidir.
- Text auto-resize: 1.337 `WIDTH_AND_HEIGHT`, 601 `HEIGHT`, 212 `NONE`.
- 1.579 text node style'a bağlı, 571 raw'dır.
- 298 image fill'in tamamı `FILL`; 245'i 1:1 oranlıdır.

### 13.2 Riskler

- **Türkçe localization:** İngilizce demo başlıkları kısa. 141 px product card, 88 px category label, icon-only veya sabit-width action row'ları Türkçe metinde taşma/truncation riski taşır. Mevcut İngilizce içerikte otomatik taşma bulunmaması Türkçe güvenliğini kanıtlamaz.
- **Dynamic type/accessibility:** Sabit 375 px ekran ve absolute-position alanları büyütülmüş fontta overlap/crop riski taşır.
- **Touch target:** Small button 40 px'tir. Interactive chip/tag olarak kullanılırsa 16–24 px componentler yetersizdir. Navbar icon'u 24 px olsa da 93,75×56 item içinde bulunduğu için tap alanı yeterli olabilir; label yokluğu anlaşılabilirlik riskidir.
- **Safe area:** Navbar 56 px'tir, bottom safe-area ayrıca modellenmemiştir.
- **Image crop:** Bütün görseller `FILL`; merchant logo, ürün packshot ve farklı aspect-ratio kaynakları için FIT/background/placeholder kuralları yoktur.
- **State completeness:** Button loading/destructive; Text Field enabled/search/select/success; Card loading/empty/unavailable state'leri eksiktir.
- **Contrast:** Mevcut orange-on-white, muted grays ve status palette için WCAG kontrast doğrulaması audit kapsamında yapılmamıştır; Phase B'de zorunlu olmalıdır.
- **Effect portability:** 6 local effect style yanında Card'da raw background blur 80 ve raw drop-shadow kombinasyonları vardır. Mobil performans ve görsel tutarlılık için konsolide edilmelidir.
- **Naming/API quality:** Yazım hataları ve jenerik `Card`, `Frame 304`, `Text`, `Container` adları component kullanımını ve dev handoff'u zorlaştırır.

## 14. Design-system quality score

| Boyut | Puan / 10 | Kısa gerekçe |
|---|---:|---|
| Component reusability | **6.0** | Button/Text Field/Navbar setleri iyi başlangıç; Card'lar setsiz, component properties ve semantic slots zayıf |
| Token consistency | **3.5** | Variable yok; 32 paint style semantik/ham karışık, duplicate ve raw değerler var |
| Typography consistency | **3.0** | 111/113 ekran Poppins+Inter karışık, 571 raw text, local ramp eksik |
| Auto Layout quality | **5.0** | Componentlerde kısmen güçlü; ekranlarda %48,6 ve 883 absolute-heavy alan |
| Accessibility readiness | **3.5** | 40 px button, labelsız nav, safe-area ve contrast kanıtı yok, state eksikleri var |
| EsnaftaVar adaptability | **5.0** | Discovery/auth/chat/card shell'leri yararlı; merchant/local-commerce ve Cart V2 modeli eksik, klasik commerce yükü yüksek |
| **Genel** | **4.3** | Seçici olarak yararlanılacak sağlam bir kit; doğrudan final design system değildir |

## 15. Recommended next step

### WAVE 14 PHASE B — ESNAFTAVAR DESIGN TOKENS V1

Önerilen sıra:

1. Bu audit'i source-of-truth olarak onayla; Figma'da henüz redesign yapma.
2. Phase B'de primitive + semantic color variables, semantic typography ramp, spacing, radius, elevation ve responsive sizing ilkelerini tanımla.
3. Poppins'i ana aile olarak doğrula; Inter istisnası varsa rol bazında açıkça sınırla.
4. Token audit'i tamamlandıktan sonra **Canonical Category Taxonomy** ürün mimarisini başlat.
5. Taxonomy kararı tamamlanmadan category/search/filter UI implementasyonuna başlama.
6. Sonraki component fazında önce Button, Text Field, Navbar, ProductCard, CategoryCard ve SellerPriceRow'u normalize et; ardından EsnaftaVar screen redesign'ına geç.

Bu belge final palette atamaz, screen redesign yapmaz ve Phase B'yi implement etmez.

## 16. Audit status

- `FIGMA_DESIGN_SYSTEM_AUDIT: PASS`
- `FIGMA_WRITE_PERFORMED: NO`
- `READY_FOR_DESIGN_TOKENS_V1: YES`
- `CATEGORY_TAXONOMY_SHOULD_START_BEFORE_CATEGORY_UI: YES`
- `RUNTIME_CODE_CHANGED: NO`
