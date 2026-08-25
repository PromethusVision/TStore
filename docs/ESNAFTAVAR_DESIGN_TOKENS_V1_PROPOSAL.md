# EsnaftaVar Design Tokens V1 Proposal

> WAVE 14 — PHASE B1 · Design Tokens V1 Proposal
> Tarih: 2026-08-25
> Kaynak audit: `docs/ESNAFTAVAR_UI_DESIGN_SYSTEM_AUDIT_V1.md`
> Figma: `EsnaftaVar — Final UI System`
> File key: `O8MIn0KyQfFoPA3EnhiWii`
> Git base: `a3cc0971175f5401b1cf0cbe5b914e42d5dc0088`
> Kapsam: Proposal only; Figma kaynak UI kit, ekran, style ve variable'ları ile Flutter runtime değiştirilmemiştir.

## 1. Karar özeti

**RECOMMENDED palette: A · Mahalle Terracotta**

- Primary: `#B54732`
- Primary hover: `#A33F2C`
- Primary pressed: `#873425`
- Primary soft: `#FBE9E4`
- Secondary/accent: `#1F6B5D`
- Background: `#FFF8F3`
- Surface: `#FFFFFF`
- Text primary: `#2B211C`
- Ana font: **Poppins only**; V1'de Inter istisnası yoktur.
- Spacing: `4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48`
- Radius: `8 / 12 / 16 / 999`
- Shadow: `xs / sm / md`
- Touch target: **44 px minimum, 48 px preferred** ürün kuralı.

Mahalle Terracotta; sıcaklığı terracotta CTA'dan, güven ve profesyonellik dengesini koyu teal accent'ten alır. Sıcak beyaz yüzeyler ürün fotoğraflarını renkli bir arka planla kirletmez. Primary üzerinde beyaz metin `5.37:1`, accent üzerinde beyaz metin `6.33:1` kontrast verir.

Mevcut bilinen `#FF8523` bu aşamada final primary değildir. Beyaz metinle kontrastı yalnız `2.43:1` olduğu için beyaz etiketli ana CTA'da WCAG AA normal metin eşiğini geçmez. Ürün sahibi bu rengi korumak isterse, koyu `#2B211C` metinle (`6.46:1`) sınırlı accent/primitive rolü ayrıca değerlendirilebilir.

## 2. Ürün yönü ve tasarım ilkeleri

Final token sistemi şu karakteri desteklemelidir:

- sıcak ve yerel;
- mahalle/esnaf hissi taşıyan;
- güven veren;
- modern ve profesyonel;
- aşırı kurumsal/soğuk olmayan;
- aşırı oyuncak/çocukça olmayan;
- ürün görsellerini nötr tutan;
- ana aksiyonu ilk bakışta görünür kılan.

Bu proposal component veya screen redesign kararı değildir. Renklerin ProductCard ve Seller row üzerindeki örnekleri yalnız palette davranışını görmek için izole mock frame olarak hazırlanmıştır.

## 3. Token mimarisi

### 3.1 Katmanlar

Önerilen sistem iki renk katmanı ve dört foundation ailesinden oluşur:

1. `ref.color.*`: ham palette değerleri. Componentler bunları doğrudan kullanmaz.
2. `color.*`: ürün anlamını taşıyan semantic tokenlar. UI yalnız bu katmana bağlanır.
3. `type.*`: font ailesi, ağırlık, boyut, line-height ve gerektiğinde numeral davranışı.
4. `space.*`, `radius.*`, `shadow.*`: layout ve elevation foundation'ları.
5. `size.touch.*`: etkileşim hedefi gibi erişilebilirlik boyutları.

Figma variable collection önerisi, ürün sahibi palette onayından sonraki implementation fazı içindir:

- `Reference / Color`
- `Semantic / Color`
- `Foundation / Spacing`
- `Foundation / Radius`
- `Foundation / Size`

Typography ve effect karşılıkları semantic text/effect style olarak üretilebilir. Bu B1 proposal fazında yeni variable, text style, paint style veya effect style oluşturulmamıştır.

### 3.2 Naming kuralları

- Dot notation kullanılır: `color.brand.primaryPressed`.
- Kategori segmentleri lowercase; birden fazla sözcüklü leaf adları camelCase'tir.
- Boşluk, slash, font adı, hex ve px token adına yazılmaz.
- Rol adı görsel görünümü değil ürün anlamını anlatır.
- Aynı token adı birden fazla kez tanımlanamaz.
- Aynı değere işaret eden birden fazla semantic token yalnız bilinçli alias ise kabul edilir.
- Future slot'lar engine davranışı değil yalnız görsel semantic contract'tır.

### 3.3 Semantic token aileleri

| Aile | Tokenlar | Kullanım sınırı |
|---|---|---|
| Brand | `color.brand.primary`, `primaryHover`, `primaryPressed`, `primarySoft`, `accent` | Ana CTA, seçili durum, marka vurgusu; accent ikincil aksiyon ve merchant identity için |
| Surface | `color.surface.background`, `surface`, `surfaceAlt`, `elevated` | Uygulama zemini, kart, ikincil panel ve yükseltilmiş içerik |
| Text | `color.text.textPrimary`, `textSecondary`, `textMuted`, `textOnPrimary` | Başlık/gövde, yardımcı metin, metadata ve primary üzerindeki metin |
| Border | `color.border.borderDefault`, `borderStrong`, `divider` | Subtle ayırıcı, kontrol/focus sınırı ve divider |
| State | `color.state.success`, `successSoft`, `warning`, `warningSoft`, `error`, `errorSoft`, `info`, `infoSoft` | Label/icon ile birlikte loading dışı durum anlatımı |
| Commerce | `color.commerce.price`, `discount`, `stockAvailable`, `stockLow`, `unavailable` | Fiyat, indirim ve listing availability |
| Future | `color.future.sponsored`, `verifiedPurchase`, `merchantBadge`, `customerBadge`, `rewardProgress` | Default hidden/opsiyonel görsel slot; davranış motoru yok |

## 4. Palette candidates

### 4.1 Tam semantic mapping

| Semantic token | A · Mahalle Terracotta — **RECOMMENDED** | B · Bakır & Adaçayı | C · Nar & Petrol |
|---|---:|---:|---:|
| `color.brand.primary` | `#B54732` | `#9C4A24` | `#A73549` |
| `color.brand.primaryHover` | `#A33F2C` | `#8B411F` | `#952F41` |
| `color.brand.primaryPressed` | `#873425` | `#733419` | `#7B2635` |
| `color.brand.primarySoft` | `#FBE9E4` | `#F8E8DE` | `#F9E8EC` |
| `color.brand.accent` | `#1F6B5D` | `#3F6B45` | `#315F68` |
| `color.surface.background` | `#FFF8F3` | `#FBF8F3` | `#FFF8F5` |
| `color.surface.surface` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` |
| `color.surface.surfaceAlt` | `#F6EEE7` | `#F4EFE7` | `#F6EFED` |
| `color.surface.elevated` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` |
| `color.text.textPrimary` | `#2B211C` | `#27231E` | `#2B2022` |
| `color.text.textSecondary` | `#5F514A` | `#575149` | `#5E4E51` |
| `color.text.textMuted` | `#75675E` | `#746D64` | `#77686B` |
| `color.text.textOnPrimary` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` |
| `color.border.borderDefault` | `#DCCFC5` | `#D8D0C5` | `#DECED1` |
| `color.border.borderStrong` | `#A08B7D` | `#9C9286` | `#A68E93` |
| `color.border.divider` | `#E9DED5` | `#E5DED4` | `#E9DDE0` |
| `color.state.success` | `#287A4B` | `#2F7046` | `#2D7448` |
| `color.state.successSoft` | `#E6F4EA` | `#E8F3EA` | `#E7F3EA` |
| `color.state.warning` | `#8A5100` | `#8A5100` | `#8A5100` |
| `color.state.warningSoft` | `#FFF0D1` | `#FFF0D1` | `#FFF0D1` |
| `color.state.error` | `#B42318` | `#B42318` | `#B42318` |
| `color.state.errorSoft` | `#FDEAE7` | `#FDEAE7` | `#FDEAE7` |
| `color.state.info` | `#24677A` | `#2C6472` | `#315F68` |
| `color.state.infoSoft` | `#E5F2F5` | `#E7F1F3` | `#E7F0F2` |
| `color.commerce.price` | `#873425` | `#733419` | `#7B2635` |
| `color.commerce.discount` | `#B42318` | `#B42318` | `#B42318` |
| `color.commerce.stockAvailable` | `#287A4B` | `#2F7046` | `#2D7448` |
| `color.commerce.stockLow` | `#8A5100` | `#8A5100` | `#8A5100` |
| `color.commerce.unavailable` | `#75675E` | `#746D64` | `#77686B` |

### 4.2 A · Mahalle Terracotta — RECOMMENDED

**Brand feeling**

Sıcak, tanıdık ve yerel; koyu teal sayesinde yalnız “turuncu marketplace” görünümüne düşmeyen, güven veren bir denge. Terracotta canlı fakat neon değildir. Warm-neutral yüzeyler ürün fotoğraflarını baskılamaz.

**Contrast rationale**

- Primary `#B54732` / white: `5.37:1`
- Accent `#1F6B5D` / white: `6.33:1`
- Text primary / background: `14.94:1`
- Text secondary / background: `7.23:1`
- Text muted / background: `5.18:1`
- Border strong / white: `3.24:1`

**Riskler**

- Çok geniş terracotta yüzeyler “kampanya” hissini artırabilir; primary büyük arka plan yerine aksiyon/vurgu rolünde kalmalıdır.
- Primary, error ve discount aynı sıcak aileye yaklaşır. Error/discount her zaman açık label/icon ve gerekirse soft yüzeyle ayrıştırılmalıdır.
- `borderDefault` subtle ayrım içindir; kontrolün tek görünür sınırı olacaksa `borderStrong` veya focus primary kullanılmalıdır.

### 4.3 B · Bakır & Adaçayı

**Brand feeling**

Zanaatkâr, doğal ve sakin. Yerel üretim, gıda ve ev kategorilerinde güçlü; “mahalle dükkânı” hissi yüksektir.

**Contrast rationale**

- Primary / white: `6.14:1`
- Accent / white: `6.18:1`
- Text primary / background: `14.73:1`
- Text muted / background: `4.82:1`
- Border strong / white: `3.06:1`

**Riskler**

- CTA daha ağır ve daha az enerjik görünebilir.
- Bakır + adaçayı ikilisi elektronik, teknoloji ve hızlı tüketim dışı kategorilerde gereğinden fazla “organik” çağrışım yapabilir.
- Accent ile success yeşili dikkatli ayrıştırılmazsa merchant identity ve success state birbirine yaklaşır.

### 4.4 C · Nar & Petrol

**Brand feeling**

Daha premium, şehirli ve güçlü. Nar tonu sıcaklığı, petrol tonu profesyonellik ve güveni taşır.

**Contrast rationale**

- Primary / white: `6.46:1`
- Accent / white: `7.08:1`
- Text primary / background: `15.01:1`
- Text muted / background: `5.03:1`
- Border strong / white: `3.04:1`

**Riskler**

- Moda, güzellik veya premium perakende markasına fazla yaklaşabilir.
- Mahalle/esnaf sıcaklığı Recommended seçeneğe göre daha düşüktür.
- Nar primary indirim/error ailesine görsel olarak yaklaşır; commerce state ayrımı daha çok dikkat ister.

## 5. Recommended semantic token detayları

### 5.1 Brand, surface, text ve border

| Token | Değer | Kullanım |
|---|---:|---|
| `color.brand.primary` | `#B54732` | Ana CTA, seçili ana state, kritik vurgu |
| `color.brand.primaryHover` | `#A33F2C` | Web/desktop hover; mobil ana state değildir |
| `color.brand.primaryPressed` | `#873425` | Basılı/aktif state ve price emphasis |
| `color.brand.primarySoft` | `#FBE9E4` | Primary badge, düşük ağırlıklı seçili yüzey |
| `color.brand.accent` | `#1F6B5D` | Secondary CTA, merchant identity, link/icon accent |
| `color.surface.background` | `#FFF8F3` | Uygulama ana zemini |
| `color.surface.surface` | `#FFFFFF` | Kart, sheet ve standart container |
| `color.surface.surfaceAlt` | `#F6EEE7` | Gruplama paneli, media placeholder, section alternation |
| `color.surface.elevated` | `#FFFFFF` | Shadow ile yükseltilmiş yüzey |
| `color.text.textPrimary` | `#2B211C` | Başlık ve ana gövde |
| `color.text.textSecondary` | `#5F514A` | Açıklama ve ikincil bilgi |
| `color.text.textMuted` | `#75675E` | Metadata; kritik bilgi için kullanılmaz |
| `color.text.textOnPrimary` | `#FFFFFF` | Primary/pressed üzerinde metin ve icon |
| `color.border.borderDefault` | `#DCCFC5` | Subtle kart/alan ayrımı |
| `color.border.borderStrong` | `#A08B7D` | Kontrol sınırı, yüksek önemde outline |
| `color.border.divider` | `#E9DED5` | Dekoratif divider; tek başına state taşımaz |

### 5.2 State

| Token | Değer | Soft pair | Not |
|---|---:|---:|---|
| `color.state.success` | `#287A4B` | `#E6F4EA` | Stok, tamamlandı, doğrulanmış sonuç |
| `color.state.warning` | `#8A5100` | `#FFF0D1` | Düşük stok, dikkat, geçici risk |
| `color.state.error` | `#B42318` | `#FDEAE7` | Hata, kullanılamaz, destructive sonuç |
| `color.state.info` | `#24677A` | `#E5F2F5` | Açıklama, fiyat/mesafe bağlamı |

Strong state rengi soft pair üzerinde normal metin için en az `4.57:1` kontrast verir. State yalnız renkle anlatılmaz; görünür label ve gerektiğinde icon kullanılır.

### 5.3 Commerce / Product

| Token | Değer | Kullanım |
|---|---:|---|
| `color.commerce.price` | `#873425` | Ana fiyat; primary'den koyu olduğu için metin okunurluğu yüksek |
| `color.commerce.discount` | `#B42318` | İndirim oranı/fiyatı; error ile aynı primitive olabilir fakat label semantiği ayrıdır |
| `color.commerce.stockAvailable` | `#287A4B` | `Stokta`, `Bugün hazır` gibi olumlu listing state |
| `color.commerce.stockLow` | `#8A5100` | Düşük stok |
| `color.commerce.unavailable` | `#75675E` | Kullanılamaz metadata; icon/label ve disabled treatment ile |

### 5.4 Future semantic slots

| Future token | V1 alias | Bu fazdaki sınır |
|---|---|---|
| `color.future.sponsored` | `color.state.warning` | Yalnız ileride etiketlenebilir slot; reklam/campaign motoru yok |
| `color.future.verifiedPurchase` | `color.state.success` | Yalnız doğrulanmış alışveriş görünür rolü |
| `color.future.merchantBadge` | `color.brand.accent` | Merchant badge için opsiyonel renk slotu |
| `color.future.customerBadge` | `color.brand.primary` | Customer badge için opsiyonel renk slotu |
| `color.future.rewardProgress` | `color.brand.primary` | Progress görsel slotu; reward/gamification davranışı yok |

Bu alias'lar intentional duplicate value'dur; ayrı engine veya ürün davranışı tasarlamaz.

## 6. Typography proposal

### 6.1 Final recommendation

**Ana ve tek UI font ailesi: Poppins.**

- Repo teması zaten Poppins kullanır.
- Audit'teki Poppins + Inter karışımı component bazlı ve rastlantısaldır.
- V1'de Inter için kanıtlanmış teknik, numerik veya mono rol bulunmamıştır.
- Fiyatlarda ikinci aile yerine Poppins `SemiBold/Bold` kullanılır.
- Numeral özelliği desteklendiği yerde fiyat/sayaç tablolarında tabular lining figures tercih edilir; desteklenmiyorsa layout sabit genişliğe güvenmez.

### 6.2 Type scale

| Token | Font | Size / line-height | Kullanım |
|---|---|---:|---|
| `type.display` | Poppins SemiBold | `32 / 40` | Sınırlı hero/empty-state başlığı |
| `type.heading.lg` | Poppins SemiBold | `28 / 36` | Screen title |
| `type.heading.md` | Poppins SemiBold | `24 / 32` | Section/major panel title |
| `type.heading.sm` | Poppins SemiBold | `20 / 28` | Card group/title |
| `type.title` | Poppins SemiBold | `18 / 26` | Product/merchant başlığı |
| `type.body.lg` | Poppins Regular | `16 / 24` | Ana gövde |
| `type.body.md` | Poppins Regular | `14 / 22` | Standart yardımcı gövde |
| `type.body.sm` | Poppins Regular | `12 / 18` | Metadata; kritik uzun metin değil |
| `type.label` | Poppins Medium | `14 / 20` | Field label, badge, compact action |
| `type.caption` | Poppins Regular | `12 / 16` | Tarih, kaynak ve ikincil metadata |
| `type.button.large` | Poppins SemiBold | `16 / 20` | 48–52 px CTA |
| `type.button.small` | Poppins SemiBold | `14 / 20` | Minimum 44 px aksiyon |
| `type.price.hero` | Poppins Bold | `24 / 32` | Product detail ana fiyat |
| `type.price.card` | Poppins SemiBold | `18 / 24` | ProductCard/Seller row fiyatı |
| `type.price.compact` | Poppins SemiBold | `16 / 22` | Compact listing fiyatı |

### 6.3 Türkçe ve accessibility notları

- `ğ, ş, ı, İ, ö, ü, ç` içeren gerçek Türkçe örneklerle component width ve truncation test edilir.
- Kritik body metni 14 px altına inmez.
- Caption 12 px yalnız ikincil metadata'dır.
- Başlıklar default olarak iki satıra kadar büyüyebilir; sabit tek satıra güvenilmez.
- Dynamic type/text scale testleri component implementation fazında yapılır.

## 7. Spacing, radius, shadow ve size

### 7.1 Spacing scale

| Token | Değer | Örnek kullanım |
|---|---:|---|
| `space.0` | `0` | Reset |
| `space.4` | `4` | Icon/text mikro boşluk |
| `space.8` | `8` | İç gap |
| `space.12` | `12` | Compact padding/gap |
| `space.16` | `16` | Standart component padding |
| `space.20` | `20` | Card/panel ara değer |
| `space.24` | `24` | Screen horizontal padding veya major gap |
| `space.32` | `32` | Section spacing |
| `space.40` | `40` | Büyük section separation |
| `space.48` | `48` | Page/major block separation |
| `space.64` | `64` | Büyük proposal/docs layout; mobilde sınırlı |

### 7.2 Radius scale

| Token | Değer | Kullanım |
|---|---:|---|
| `radius.small` | `8` | Input, küçük badge/container |
| `radius.medium` | `12` | Button, compact card |
| `radius.large` | `16` | ProductCard, modal/panel |
| `radius.pill` | `999` | Badge/chip/avatar; bütün kartlara uygulanmaz |

`radius.large` 16 px'te tutulur. Daha yüksek değerleri yaygınlaştırmak sistemi oyuncak/çocukça gösterebilir.

### 7.3 Shadow scale

Shadow rengi siyah yerine warm charcoal `#2B211C` kullanır.

| Token | X / Y / Blur / Spread | Opacity | Kullanım |
|---|---|---:|---|
| `shadow.xs` | `0 / 1 / 2 / 0` | `8%` | Hafif card ayrımı |
| `shadow.sm` | `0 / 4 / 12 / -2` | `10%` | Yükseltilmiş kart, floating action |
| `shadow.md` | `0 / 12 / 28 / -6` | `14%` | Modal/sheet; sınırlı kullanım |

### 7.4 Touch ve icon size

| Token | Değer | Not |
|---|---:|---|
| `size.touch.minimum` | `44` | EsnaftaVar ürün minimumu |
| `size.touch.preferred` | `48` | Standart button/field/action |
| `size.icon.small` | `16` | Supporting icon; tek başına tap target değil |
| `size.icon.medium` | `20` | Compact action içinde |
| `size.icon.default` | `24` | Standart icon; tap wrapper 44–48 px |

## 8. Accessibility ve contrast validation

WCAG 2.2 referans eşikleri:

- Normal metin: `4.5:1`.
- Büyük metin: `3:1`.
- Zorunlu UI component/state göstergesi ve anlamlı grafik: `3:1`.
- WCAG 2.2 AA target-size minimumu `24×24 CSS px` veya tanımlı spacing/istisnalardır; EsnaftaVar bunun üstünde ürün standardı olarak 44–48 px bandını kullanır. WCAG 2.5.5 enhanced 44×44 seviyesini ayrıca tanımlar.

Resmî kaynaklar:

- <https://www.w3.org/TR/WCAG22/#contrast-minimum>
- <https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast>
- <https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum>
- <https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced>

### 8.1 Hesaplanan kontrastlar

| Palette | Pair | Ratio | Sonuç |
|---|---|---:|---|
| A | Primary / white | `5.37:1` | AA normal text PASS |
| A | Accent / white | `6.33:1` | AA normal text PASS |
| A | Text primary / background | `14.94:1` | PASS |
| A | Text secondary / background | `7.23:1` | PASS |
| A | Text muted / background | `5.18:1` | PASS |
| A | Success / white | `5.28:1` | PASS |
| A | Warning / white | `6.45:1` | PASS |
| A | Error / white | `6.57:1` | PASS |
| A | Info / white | `6.37:1` | PASS |
| A | Border strong / white | `3.24:1` | Non-text PASS |
| B | Primary / white | `6.14:1` | PASS |
| B | Accent / white | `6.18:1` | PASS |
| B | Text muted / background | `4.82:1` | PASS, düşük marj |
| B | Border strong / white | `3.06:1` | Non-text PASS, düşük marj |
| C | Primary / white | `6.46:1` | PASS |
| C | Accent / white | `7.08:1` | PASS |
| C | Text muted / background | `5.03:1` | PASS |
| C | Border strong / white | `3.04:1` | Non-text PASS, düşük marj |
| Current | `#FF8523` / white | `2.43:1` | Normal ve large text FAIL |
| Current | `#FF8523` / `#2B211C` | `6.46:1` | Koyu metinle PASS |

### 8.2 Kullanım kuralları

- `borderDefault` ve `divider` kontrolün varlığını veya state'ini tek başına anlatmaz.
- Focus/selected/error gibi state'lerde `borderStrong`, primary/state rengi, label ve/veya icon birlikte kullanılır.
- Soft state yüzeyinde strong state metin/icon kullanılır.
- Stock, discount, unavailable ve verified state yalnız renkle anlatılmaz.
- Ürün görsellerinin arkasında `surface` veya `surfaceAlt` kullanılır; brand rengi geniş image backdrop yapılmaz.
- Disabled state erişilebilirlik istisnası olsa da bilgi tamamen görünmez hâle getirilmez.

## 9. Figma proposal

- File: [EsnaftaVar — Final UI System](https://www.figma.com/design/O8MIn0KyQfFoPA3EnhiWii/EsnaftaVar-%E2%80%94-Final-UI-System)
- Yeni page: `EsnaftaVar — Tokens V1 Proposal`
- Page node: `52748:2`
- Board frame: `Proposal Board / EsnaftaVar Tokens V1`
- Board node: `52748:3`
- Board size: `1440 × 3802`

Proposal bölümleri:

| Bölüm | Node |
|---|---:|
| Proposal header ve source guard | `52749:2` |
| Recommended palette swatches | `52750:2` |
| Alternate palettes | `52751:2` |
| Semantic states ve future slots | `52752:2` |
| Typography scale | `52753:2` |
| Spacing / radius / shadow | `52754:2` |
| CTA / ProductCard / Merchant-Seller previews | `52755:2` |

Figma izolasyon doğrulaması:

- Proposal page top-level child: `1` board.
- Proposal page component/component-set/instance: `0`.
- Proposal page text node: `179`; font offender: `0`, tamamı Poppins.
- Kalan placeholder/shimmer: `0`.
- Local variable collection: `0` — değişmedi.
- Local paint/text/effect style: `32 / 7 / 6` — değişmedi.
- Kaynak page child count'ları `1 / 124 / 6 / 2` — ön kontrolle aynı.
- Mevcut K'pasa componentleri recolor edilmedi.
- Mevcut UI ekranları değiştirilmedi.
- Preview'lar component değil, açık isimli izole proposal mock frame'leridir.

## 10. Duplicate ve naming validation

Validation contract:

1. Token adları case-sensitive unique olmalıdır.
2. Aynı aile içinde aynı role farklı değer atanamaz.
3. Aynı hex birden fazla semantic role bağlanıyorsa alias intent belgelenmelidir.
4. `color.future.*` alias'ları intentional duplicate'tir.
5. State ve commerce alias'ları (`stockAvailable → success`, `stockLow → warning`, `discount → error primitive`) intentional'dır; UI anlamı ayrı kalır.
6. Token adlarında slash, boşluk, typo ve raw palette pazarlama adı kullanılmaz.

Bu dokümandaki canonical token listesinde duplicate ad bulunmaz. Farklı tokenların aynı hex'e bağlandığı durumlar alias olarak açıkça belirtilmiştir.

## 11. Implementation prerequisites

Bu proposal doğrudan implementation yetkisi değildir. Sonraki fazdan önce:

1. Product owner A/B/C arasından görsel palette kararını verir; Recommended otomatik final sayılmaz.
2. Primary, accent, background ve ProductCard/Seller row önizlemeleri gerçek ürün fotoğrafı ve uzun Türkçe metinlerle görsel kabul edilir.
3. Onaydan sonra `ref.color.* → color.*` Figma variable alias mimarisi kurulur.
4. İlk implementation Light mode ile başlayabilir; Dark mode değerleri ayrı tasarım/kontrast turu olmadan türetilmez.
5. Poppins semantic text style'ları kurulur; mevcut Inter kullanımları kontrollü migration listesine alınır.
6. Button, Text Field, Navbar, ProductCard ve SellerPriceRow semantic tokenlara sırayla taşınır; canonical source componentler ancak bu onaydan sonra değiştirilir.
7. Category/search/filter UI, canonical taxonomy kararı tamamlandıktan sonra ele alınır.
8. Flutter token mapping ve runtime rollout ayrı görevdir; bu fazda runtime kod değişikliği yoktur.
9. Contrast, text scale, Türkçe truncation, loading/empty/error/success, disabled/focus ve 44–48 px target testleri component fazında otomatikleştirilir.
10. Ekran çapında toplu recolor yapılmadan önce component-level golden/screenshot kabulü alınır.

## 12. Kapsam dışı

Bu proposal şunları yapmaz:

- bütün UI kit'i recolor etmez;
- Home redesign yapmaz;
- ProductCard'ı final component olarak yeniden tasarlamaz;
- category UI veya taxonomy implement etmez;
- Flutter code değiştirmez;
- advertising/campaign engine tasarlamaz;
- reward/gamification davranışı tasarlamaz;
- mevcut K'pasa source component, screen, style veya variable'larını değiştirmez.

## 13. Proposal status

- `DESIGN_TOKENS_V1_PROPOSAL: PASS`
- `SOURCE_UI_KIT_UNCHANGED: YES`
- `FIGMA_PROPOSAL_ISOLATED: YES`
- `RUNTIME_CODE_CHANGED: NO`
- `READY_FOR_PRODUCT_OWNER_VISUAL_REVIEW: YES`
- `INTEGRATION_REQUIRED`
