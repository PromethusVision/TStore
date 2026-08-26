# EsnaftaVar Canonical Category Taxonomy — Architecture + L1

**Wave:** 15 / Phase A

**Belge tarihi:** 27 Ağustos 2026

**Kapsam:** Product taxonomy mimarisi, L1 ana kategori seti ve merchant-sector ayrımı

**Runtime durumu:** Dokümantasyon; migration, seed, Flutter, Figma veya remote değişikliği yoktur.

> Current main notu: Bu Phase A görevi başladığında repo zaten owner-approved
> `v1.0.0` full taxonomy artefaktını içeriyordu. Bu belge mevcut 23 L1 canonical
> baselineını geriye götürmez, L2/L3/L4 ağacını yeniden üretmez ve
> `docs/data/esnaftavar_category_taxonomy_v1_final.json` dosyasını değiştirmez.
> Belgenin yeni girdisi; mimariyi kısa bir sözleşmede toplamak ve teyit edilen
> merchant-sector hizmet kapsamını product taxonomy'den ayrı kaydetmektir.

## Karar etiketleri

- **CONFIRMED:** Product owner'ın bu görevde açıkça teyit ettiği veya current main'deki
  canonical V1.0.0 kararı.
- **PROPOSED:** Runtime uygulamasından önce owner/integration review gerektiren mimari
  öneri.
- **TBD:** Ürün, hukuk, operasyon veya implementation kararı henüz verilmemiş alan.

## 1. Purpose

Bu belgenin amacı EsnaftaVar'ın fiziksel yerel ticaret modelinde:

1. ürünün ne olduğunu tek ve kalıcı bir canonical kimlikle sınıflandırmak;
2. müşterinin kategoriyle keşif yapmasını, merchant'ın kontrollü ürün girişi yapmasını
   ve analitiğin zaman içinde aynı anlamı ölçmesini sağlamak;
3. ürün kategorisi, işletme türü ve facet/attribute kavramlarının birbirine
   karışmasını engellemek;
4. variable-depth, en fazla dört seviyeli ağacın L1 sınırlarını kesinleştirmek;
5. Google ve pazar yeri eşlemelerini EsnaftaVar source-of-truth'undan ayırmaktır.

EsnaftaVar online ödeme, kargo ve klasik checkout odaklı bir pazar yeri değildir.
Canonical taxonomy; müşterinin yakındaki esnafta ürünü bulması, mağaza tekliflerini
karşılaştırması ve fiziksel etkileşime geçmesi için ürün anlamını sağlar. Fiyat,
stok, mağaza uzaklığı ve açık/kapalı durumu category node değildir.

## 2. Research methodology / sources

Araştırma 27 Ağustos 2026 tarihinde kamuya açık resmi kaynaklar üzerinden yeniden
doğrulandı. Proprietary ağaçlar kopyalanmadı; yalnız hierarchy, assignment,
attribute ve lifecycle örüntüleri karşılaştırıldı. Bir platformun tüm L1/L2 ağacı
kamu dokümanında sabit liste halinde verilmediğinde bu durum özellikle belirtilmiş,
API örneğinden wholesale taxonomy sonucu çıkarılmamıştır.

| Kaynak | L1/L2 structural pattern | Naming convention | Aşırı fragmentation riski | EsnaftaVar için eksik/local fark |
|---|---|---|---|---|
| [Google Product Taxonomy dosyası](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center kategori sözleşmesi](https://support.google.com/merchants/answer/6324436?hl=en) — erişim 2026-08-27 | Numeric ID + tam breadcrumb; dal bazında değişken derinlik. Google ürün başına bir, ana fonksiyona göre en ilgili ve mümkün olan en spesifik kategoriyi ister. | Global, fonksiyon temelli, İngilizce noun phrase; path segmentleri `>` ile ayrılır. | Public dosya 5.595 kategori satırı ve EsnaftaVar'a ilgisiz global/endüstriyel/riskli uzun kuyruk taşır. Dosya header sürümü `2021-09-21`; erişim güncel olsa da taxonomy snapshot tarihi yenilenmiş sayılmaz. | Türkiye mahalle esnafı dili, merchant-sector ayrımı ve yakınlık/yerel availability Google product tree'nin amacı değildir. Google yalnız optional external mapping olabilir. |
| [Trendyol kategori ağacı](https://developers.trendyol.com/docs/trendyol-kategori-listesi-getcategorytree) ve [Kategori Özellik Listesi V2](https://developers.trendyol.com/docs/kategori-%C3%B6zellik-listesi-v2) — erişim 2026-08-27 | `id`, `parentId`, `subCategories`; yalnız en alt kategoriye ürün girişi. Ağaç ve attribute listesi değişkendir, güncel/haftalık alınması önerilir. | Türkçe müşteri dili; `&` ile birleşik ürün aileleri ve ayrı display name alanı görülebilir. | Leaf düzeyinde çok ince pazar yeri merchandising ayrımları ve sık güncelleme, yerel küçük katalogda boş/yanlış seçim üretebilir. | Product tree; shop type, mahalle availability ve fiziksel mağaza etkileşimini modellemez. `required`, `varianter`, `slicer` ayrımı category/facet separation için güçlü örnektir. |
| [Hepsiburada Katalog Ürün Giriş Önemli Bilgiler](https://developers.hepsiburada.com/tr/companies/hepsiburada?guide=katalog-onemli-bilgiler&product=katalog-urun-entegrasyonu&view=guide) — erişim 2026-08-27 | `categoryId`, `parentCategoryId`, `paths`; ürün girişi için `leaf=true`, `status=active`, `available=true` birlikte gerekir. Category ürün data modelini ve attribute gereksinimlerini belirler. | Turkish catalog label + explicit path; assignability adın değil ayrı status alanlarının sonucudur. | Public rehber tüm L1 ağacını statik olarak göstermediğinden L1 bazında wholesale fragmentation iddiası yapılmadı. Leaf ve attribute şemasının birlikte büyümesi operasyon yükü yaratabilir. | Merchant türü ile ürün kategorisini ve customer-nearby projection'ını ayıran EsnaftaVar domain sözleşmesi ayrıca gerekir. |
| [n11 Kategori Ağacı](https://developer.n11.com/documentation/n11-marketplace-entegrasyonu/kategori-agaci-listeleme/) ve [Kategori Özellikleri](https://developer.n11.com/documentation/n11-marketplace-entegrasyonu/kategori-ozellikleri-listeleme/) — erişim 2026-08-27 | Nested `id`, `parentId`, `subCategories`; `null` child leaf'tir ve ürün yalnız leaf ID'ye gönderilir. Attribute servisi mandatory, variant, slicer ve custom value rollerini ayırır. | Türkçe compound adlar; örneklerde `Banyo & Tuvalet`, `Erkek Giyim & Aksesuar` gibi browse/merchant dili kullanılır. | Cinsiyetin L1'e kadar taşınması veya her browse ayrımının node yapılması EsnaftaVar için tekrar ve multi-category riski doğurur; gender facet kalmalıdır. | Shop/sector identity, fiziksel yakınlık ve local availability ayrı katmandır; product tree bu görevleri üstlenmemelidir. |

### Araştırma sentezi — CONFIRMED

- Ürün, tam olarak bir primary canonical leaf'e atanır.
- Leaf olup olmama ile aktif/atanabilir olma ayrı kavramlardır.
- Attribute, facet ve variant metadata category node değildir.
- Dış taxonomy ID/path'i internal kimlik değil, versioned mapping'dir.
- Ağaç değişebilir; stable identity, deprecation ve replacement kaydı gerekir.
- Marketplace merchandising derinliği EsnaftaVar'a wholesale kopyalanmaz.

## 3. Product Taxonomy vs Merchant/Sector Taxonomy vs Facets

| Sistem | Soru | Örnek | Canonical rol | Durum |
|---|---|---|---|---|
| **Product Taxonomy** | Bu ürün nedir? | Elektronik → Telefon & Giyilebilir Teknoloji → Akıllı Telefon | Customer browse, search context, merchant product entry, analytics | **CONFIRMED** |
| **Merchant / Sector Taxonomy** | Bu işletme ne tür bir işletmedir? | Telefoncu, Kırtasiye, Pet Shop, Erkek Berberi | Merchant onboarding, shop profile, sector filter ve future policy routing | **CONFIRMED — ayrı sistem** |
| **Facet / Attribute System** | Bu ürünün seçilebilir/filtrelenebilir özelliği nedir? | marka, renk, beden, kapasite, materyal, uyumluluk | Filter, variant, validation ve structured search | **CONFIRMED — category değildir** |

Bir merchant birden fazla product L1 altında ürün satabilir. Bu nedenle merchant
sector ile product category ilişkisi future modelde many-to-many olabilir; sector
ürünün primary category'sini otomatik belirlemez.

### Category olmayan kavramlar — CONFIRMED

- marka, renk, beden, ayakkabı numarası, kapasite, materyal, uyumluluk;
- cinsiyet, yaş grubu ve teknik özellik;
- Yakınımdaki, Popüler, Sponsorlu, İndirimli, Çok Satan ve Featured;
- fiyat, stok, mağaza uzaklığı ve mağazanın açık/kapalı durumu.

İlk grup attribute/facet, ikinci grup discovery/ranking/advertising, son grup ise
offer/listing verisidir. `Sponsorlu` future Advertising Engine kapsamıdır ve
canonical ya da organik category sırasını değiştirmez.

## 4. Depth model

Maximum supported depth **4** seviyedir; her dalın dört seviyeye zorlanması yasaktır.

| Seviye | Anlam | Örnek rol | Leaf olabilir mi? |
|---|---|---|---|
| L1 | Ana kategori / department | Elektronik | Hayır |
| L2 | Major department | Telefon & Giyilebilir Teknoloji | **Evet** |
| L3 | Ürün grubu | Akıllı Telefon | **Evet** |
| L4 | Ürün tipi | Gerçekten ayrı şema gerektiren dar tip | **Evet** |

### Invariants — CONFIRMED

- Root yalnız L1'dir; her L2–L4 node'un tam bir parent'ı vardır.
- Child level her zaman `parent.level + 1` olur; cycle ve orphan kabul edilmez.
- `level <= 4` fail-closed doğrulanır.
- Leaf, child taşımayan node'dur. Her leaf otomatik yayımlanabilir değildir;
  `is_active`, `is_assignable` ve policy birlikte değerlendirilir.
- L2 veya L3 doğal olarak yeterliyse artificial child yaratılmaz.
- `canonical_path` identity değildir; parent/name değişiminde yeniden türetilebilir.

Current V1.0.0 full artefaktı max depth 4 sözleşmesini karşılar; bu Phase A mevcut
L2/L3/L4 node'larını üretmez veya değiştirmez.

## 5. Canonical node contract

Aşağıdaki sözleşme logical/domain contract'tır; bu görev DB schema tasarlamaz.

| Alan | Kural | Durum |
|---|---|---|
| `id` | Immutable, opaque stable ID. Ad, slug, parent veya path değişince değişmez; yeniden kullanılmaz. | **PROPOSED — runtime primary identity** |
| `parent_id` | L1'de `null`; diğer seviyelerde aynı taxonomy version içindeki parent `id`. | **PROPOSED** |
| `level` | Integer `1..4`; parent'tan doğrulanır, serbest metin değildir. | **CONFIRMED** |
| `display_name_tr` | Kullanıcıya gösterilen Türkçe canonical ad; trim edilmiş, sibling içinde normalize unique; copy revizyonu yapılabilir. | **CONFIRMED** |
| `slug` | URL/search-friendly ASCII kebab-case, global unique aktif handle. Değişirse historical alias/redirect bırakılır. | **PROPOSED** |
| `sort_order` | Sibling içinde deterministic sıra; ranking veya sponsor puanı değildir. | **CONFIRMED** |
| `is_active` | Browse/selection görünürlüğünün lifecycle durumu; hard delete yerine deactivation tercih edilir. | **CONFIRMED** |
| `is_leaf` | Child yoksa true; yalnız yapısal bilgidir. | **CONFIRMED** |
| `is_assignable` | Product assignment'a izin verir; `is_leaf && is_active` gerekli ama policy nedeniyle tek başına yeterli olmayabilir. | **PROPOSED / gerekli ayrım** |
| `canonical_path` | Root'tan node'a display breadcrumb ve/veya ID path projection'ı; identity değildir. | **PROPOSED** |
| `synonyms` | Aynı kavramın yaygın eş anlamlıları; brand/promotional term içermez. | **PROPOSED** |
| `aliases` | Yazım, ASCII, birleşik/ayrı ve yerel kullanım varyantları; canonical display name değildir. | **PROPOSED** |
| `normalized_search_tokens` | Locale-aware türetilmiş indeks girdisi; source text değildir ve yeniden üretilebilir. | **PROPOSED** |
| `attribute_profile_id` | Leaf'e uygulanacak typed attribute/facet profile referansı; nullable. | **PROPOSED** |
| `policy_class` | `NORMAL`, `AGE_RESTRICTED`, `REGULATED`, `LEGAL_REVIEW_REQUIRED`, `EXCLUDED`. | **PROPOSED** |
| `google_product_category_id` | Versioned external mapping'in optional numeric ID'si; EsnaftaVar identity değildir. | **PROPOSED / optional** |
| `google_product_category_path` | External mapping'in optional snapshot path'i; ID ile sürüm uyumu doğrulanır. | **PROPOSED / optional** |
| `taxonomy_version` | Node'un hangi published taxonomy sürümüne ait olduğunu gösterir. | **PROPOSED** |
| `replaced_by_id` | Deprecated node için nullable successor; split/merge durumunda ayrı mapping listesi gerekir. | **PROPOSED** |

### Stable identity bridge — INTEGRATION_REQUIRED

Current V1.0.0 JSON, `slug` alanını immutable semantic identity kabul eder ve UUID
taşımaz. Bu görevin contract'ı ise ad/slug değişse de `id` değişmemesini gerektirir.
Runtime implementation başlamadan önce şu bridge tek taxonomy/schema sahibi tarafından
kesinleştirilmelidir:

1. V1.0.0 source slug'larından bir defaya mahsus, deterministic ve kalıcı opaque
   `id` registry üret;
2. V1 source slug'ını `source_key`/seed mapping olarak immutable koru;
3. kullanıcı-facing `slug` daha sonra değişirse eski slug'ı permanent alias/redirect
   olarak sakla;
4. analytics, product foreign key ve external mappings'i `id` üzerinden bağla;
5. mevcut final JSON'u bu Phase A'da yeniden yazma; schema/migration tasarımında
   backward-compatible adapter tanımla.

Bu bridge kararı verilmeden taxonomy'yi runtime'a deploy etmek identity drift riski
taşır.

## 6. Product assignment rules

### Primary category — CONFIRMED

Her canonical product **exactly one** aktif ve atanabilir primary canonical leaf'e
bağlanır. Product bir ancestor'a atanmaz; ancestor browse/analytics roll-up ile
türetilir.

### Discovery alias — PROPOSED

Başka bir kullanıcı teriminden aynı primary leaf'e veya ürüne yönlendiren, ownership
oluşturmayan arama/browse köprüsüdür. Örneğin `power bank` sorgusu Şarj & Güç
dalındaki doğru leaf'e gidebilir.

### Secondary discovery tag — PROPOSED / sınırlı

Season, occasion, editorial collection veya cross-domain discovery sinyalidir.
Canonical category foreign key değildir; ürün sayımı, attribute profile veya policy
inheritance üretmez.

Multi-category physical duplication yapılmaz. Çok işlevli üründe ana fonksiyon,
merchant veri şeması ve customer expectation birlikte değerlendirilir; sınır vakası
taxonomy review log'una gider.

## 7. Search / synonym architecture

### Kaynak alanlar

- `display_name_tr`: tek canonical görünen ad;
- `synonyms`: semantik eş anlam (`cep telefonu`, `akıllı telefon`);
- `aliases`: pazar dili/yazım (`powerbank`, `power bank`, `taşınabilir şarj`);
- `normalized_search_tokens`: indeks için türetilmiş tokenlar;
- ancestor names: düşük ağırlıklı category context;
- brand ve structured attributes: kendi index/facet alanlarından gelir.

### Normalizasyon kuralları — PROPOSED

1. Unicode normalize et; Türkçe `I/İ/ı/i` dönüşümünü locale-aware yap.
2. Trim, noktalama, art arda boşluk ve `&`/`ve` varyasyonlarını normalize et.
3. Diakritik/ASCII folding'i fallback olarak kullan; canonical Türkçe metni bozma.
4. Exact canonical ad > canonical prefix > exact synonym/alias > alias prefix >
   normalized keyword sıralamasını kullan.
5. Typo/fuzzy eşleşmeyi synonym kaynağına yazma; search engine katmanında ölç.
6. Marka adını category alias yapma.
7. Zero-result, yanlış leaf seçimi ve merchant category request verisini review girdisi
   olarak ölç.

Search backend ve merchant suggestion flow bu görevde implement edilmez. Merchant
public taxonomy'den leaf seçer; kendi başına public node oluşturamaz. Unknown product
için future `category request → taxonomy review` workflow'u **TBD**'dir.

## 8. Policy / regulated classification

| Policy class | Anlam | Varsayılan davranış |
|---|---|---|
| `NORMAL` | Özel yaş/hukuk/policy routing'i gerektirmeyen ürün sınıfı | Normal catalog validation |
| `AGE_RESTRICTED` | Yaş doğrulaması veya görünürlük kısıtı potansiyeli | Policy ve age gate yoksa fail-closed |
| `REGULATED` | Belge, kayıt, yetkili satıcı veya claim kontrolü gerektirebilir | Evidence + moderation owner yoksa yayımlama yok |
| `LEGAL_REVIEW_REQUIRED` | Ürün ailesinin satış/visibility modeli hukuk ve owner kararı ister | Karar çıkana kadar non-assignable/inactive |
| `EXCLUDED` | Canonical katalog ve discovery kapsamı dışında | Atanamaz ve yayımlanamaz |

### Current baseline ve açık karar ayrımı

- Current canonical V1.0.0; ilaçlar/özel tıbbi amaçlı ürünler, tütün/nikotin/e-sigara,
  alkollü içki, ateşli silah/mühimmat/patlayıcı, yasa dışı madde/üretim ekipmanı,
  canlı hayvan ve digital-only ürün/hizmetleri `EXCLUDED` baseline olarak kaydeder.
  Bu Phase A yeni bir hukuki sonuç üretmez.
- Kontakt lens, medikal cihaz, supplement/health claim, bazı kimyasallar, solvent,
  pil/akü, iş güvenliği ve araç güvenliği ürünleri category-specific policy ve uzman
  review gerektirir.
- `policy_class` bir satış izni değildir. Belge, moderation owner, audit trail,
  recall/deactivation ve görünürlük kuralı ayrıca tanımlanmalıdır.
- Excluded alanların gelecekte açılması, yaş kısıtı modeli ve hassas kimyasal sınırı
  **TBD — product owner + legal review** olarak kalır.

## 9. L1 hypothesis evaluation

Başlangıç hipotezi current canonical V1.0.0 ve araştırma ilkeleriyle challenge edildi.
Sonuç, 18–25 hedef aralığında **23 L1**'dir.

| Başlangıç hipotezi | Karar | Recommended/current L1 sonucu | Gerekçe |
|---|---|---|---|
| Elektronik | **SPLIT** | Elektronik; Bilgisayar & Tablet | Telefon/audio/camera ile bilgisayar bileşen ve peripheral şemaları yeterince farklıdır. |
| Beyaz Eşya & Ev Aletleri | **KEEP** | Beyaz Eşya & Ev Aletleri | Dayanıklı appliance ve küçük ev aleti tek anlaşılır departmenttır. |
| Ev & Yaşam | **KEEP + SCOPE** | Ev & Yaşam | Mobilya, ev tekstili, dekorasyon ve ev tüketim ürünleri bu sınırdadır. |
| Mobilya & Dekorasyon | **MERGE** | Ev & Yaşam altında | Ayrı L1, yerel katalogda Ev & Yaşam ile kalıcı overlap yaratır. |
| Yapı Market, Hırdavat & Tesisat | **RENAME** | Yapı & Hırdavat | “Market” satış kanalı çağrışımı yapar; tesisat L2 kapsamı olabilir. |
| Giyim & Moda | **RENAME** | Moda & Giyim | Türkçe browse kullanımı ve final canonical adla hizalanır. |
| Ayakkabı, Çanta & Aksesuar | **SPLIT** | Ayakkabı; Çanta & Giyim Aksesuarı | Ayakkabı numarası/fit ile çanta/aksesuar attribute şemaları ve browse niyeti ayrıdır. |
| Kozmetik & Kişisel Bakım | **RENAME** | Kişisel Bakım & Kozmetik | Bakım domainini önceleyen final canonical ad; kapsam korunur. |
| Sağlık & Medikal | **KEEP** | Sağlık & Medikal | Regulated policy ile ürün domaini birlikte görünür, satış izni ayrıca değerlendirilir. |
| Anne, Bebek & Çocuk | **RENAME** | Bebek & Çocuk | “Anne” hedef kullanıcı facet'i olmamalı; ürün fonksiyonu bebek/çocuk kapsamıdır. |
| Oyuncak & Hobi | **MERGE/EXPAND** | Oyuncak, Hobi & Müzik | Ayrı müzik L1'i yerel coverage için seyrek; enstrümanlar aynı hobby departmentında yönetilebilir. |
| Kitap, Kırtasiye & Ofis | **SPLIT** | Kitap; Kırtasiye & Ofis | Kitabın shelf/genre modeli ile ofis/kırtasiye attribute ve merchant giriş modeli farklıdır. |
| Gıda & İçecek | **RENAME/EXPAND** | Market & Gıda | Mahalle marketi/bakkal dilini ve içecek/atıştırmalık/taze gıda kapsamını birlikte taşır. |
| Spor & Outdoor | **KEEP** | Spor & Outdoor | Kullanıcı niyeti ve ürün özellikleri tutarlı department oluşturur. |
| Otomotiv & Motosiklet | **KEEP** | Otomotiv & Motosiklet | Vehicle fitment ortak altyapısı, alt domain sınırları L2'de çözülür. |
| Evcil Hayvan | **RENAME** | Pet Shop | Türkiye'deki gerçek mağaza dilini tanır; canlı hayvan satışı kapsam dışıdır. |
| Takı, Saat & Gözlük | **SPLIT** | Optik; Saat & Takı | Optiğin regulated/ölçülü ürün sözleşmesi saat/takıdan ayrıdır. |
| Bahçe, Çiçek & Bitki | **RENAME** | Çiçek & Bahçe | Bitki ve yetiştirme ürünleri aynı domain; daha kısa Türkçe browse adı. |
| Müzik & Enstrüman | **MERGE** | Oyuncak, Hobi & Müzik altında | Mahalle coverage ve L1 sadeliği; enstrüman ürün grupları kaybolmaz. |
| Hediyelik, Parti & Organizasyon | **RENAME/SCOPE** | Hediyelik & Parti | Fiziksel ürünler kalır; organizasyon hizmeti Product Taxonomy değildir. |
| İş Güvenliği & Endüstriyel | **DISTRIBUTE / REMOVE L1** | Fonksiyona göre Giyim, Ayakkabı, Yapı & Hırdavat, Otomotiv | “Endüstriyel” aşırı geniş satış kanalıdır; safety bir policy/attribute, ürünün ana fonksiyonu değil. |
| — | **ADD/SPLIT** | Züccaciye & Mutfak | Kitchenware ile furniture/decor ve elektrikli appliance ayrımını netleştirir. |

No unexplained L1 overlap kuralı: sınır vakaları satış kanalına veya mağaza türüne göre
değil ürünün ana fonksiyonuna göre çözülür. Cross-discovery alias/attribute/collection
ile sağlanır; ikinci primary category oluşturulmaz.

## 10. Recommended L1 V1

**Durum: CONFIRMED — current repo canonical V1.0.0 baseline.** Bu belge L1 adlarını
yeniden açmaz; owner review için öneri mevcut 23 L1'in korunmasıdır.

| # | L1 | Stable V1 source slug | Boundary guard |
|---:|---|---|---|
| 1 | Market & Gıda | `market-gida` | Gıda/market ürünü; restoran hizmeti, ilaç ve yasak hassas domain değil. |
| 2 | Moda & Giyim | `moda-giyim` | Giyim ürünü; gender/size/renk facet'tir. |
| 3 | Ayakkabı | `ayakkabi` | Ayakkabı türü; numara ve hedef cinsiyet facet'tir. |
| 4 | Çanta & Giyim Aksesuarı | `canta-giyim-aksesuari` | Taşıma/giyim aksesuarı; cihaz uyumluluğu attribute'tur. |
| 5 | Elektronik | `elektronik` | Telefon, audio, camera ve consumer electronics; bilgisayar ayrı L1. |
| 6 | Bilgisayar & Tablet | `bilgisayar-tablet` | Bilgisayar/tablet, bileşen, depolama ve peripheral. |
| 7 | Beyaz Eşya & Ev Aletleri | `beyaz-esya-ev-aletleri` | Elektrikli dayanıklı/küçük ev cihazı; non-electric kitchenware ayrı. |
| 8 | Ev & Yaşam | `ev-yasam` | Mobilya, tekstil, dekorasyon, düzenleme ve ev tüketim ürünleri. |
| 9 | Züccaciye & Mutfak | `zuccaciye-mutfak` | Pişirme, servis, saklama ve non-electric kitchenware. |
| 10 | Yapı & Hırdavat | `yapi-hirdavat` | Yapı, el aleti, bağlantı, elektrik/tesisat malzemesi; broad industrial channel değil. |
| 11 | Otomotiv & Motosiklet | `otomotiv-motosiklet` | Araç parçası/aksesuarı/bakım; fitment attribute'tur. |
| 12 | Kişisel Bakım & Kozmetik | `kisisel-bakim-kozmetik` | Bakım/kozmetik ürünü; salon hizmeti değildir. |
| 13 | Bebek & Çocuk | `bebek-cocuk` | Bebek bakım/taşıma/beslenme ürünleri; yaş grubu gerektiğinde facet'tir. |
| 14 | Oyuncak, Hobi & Müzik | `oyuncak-hobi-muzik` | Oyuncak, fiziksel hobi ve enstrüman; dijital hizmet değildir. |
| 15 | Spor & Outdoor | `spor-outdoor` | Spor/outdoor ekipmanı ve specialist ürün; apparel sınırı ana fonksiyonla çözülür. |
| 16 | Kitap | `kitap` | Fiziksel kitap; tek primary shelf + multi-value genre facet yaklaşımı. |
| 17 | Kırtasiye & Ofis | `kirtasiye-ofis` | Kâğıt, yazım, dosyalama, sanat sarfı ve ofis ürünü. |
| 18 | Pet Shop | `pet-shop` | Evcil hayvan ürünü; canlı hayvan ve veteriner ilacı excluded. |
| 19 | Optik | `optik` | Gözlük/optik ürün; regulated policy olmadan yayın izni yok. |
| 20 | Saat & Takı | `saat-taki` | Klasik saat ve takı; smart watch Elektronik'tedir. |
| 21 | Sağlık & Medikal | `saglik-medikal` | Sağlık/medikal ürün; claim/evidence ve policy fail-closed. |
| 22 | Çiçek & Bahçe | `cicek-bahce` | Çiçek, bitki ve yetiştirme/bahçe ürünü; bahçe el aleti ana kullanımına göre burada olabilir. |
| 23 | Hediyelik & Parti | `hediyelik-parti` | Fiziksel hediye/parti ürünü; organizasyon hizmeti ve seasonal state category değildir. |

Duplicate L1 name yoktur. Birleşik adlar kullanıcı tarafından birlikte aranan ve aynı
attribute/merchant-entry bağlamını paylaşan yakın domainlerle sınırlıdır; category
scope notları bilinen overlapleri açıklar.

## 11. Demo category mapping

Bu eşleme conceptual/read-only'dir; Production/Development migration veya demo data
değişikliği yapılmaz.

| Current demo category | Canonical L1 | Mapping | Not |
|---|---|---|---|
| Elektronik | Elektronik (`elektronik`) | Direct | Demo ürünün leaf'i sonraki controlled mapping çalışmasında doğrulanır. |
| Kırtasiye | Kırtasiye & Ofis (`kirtasiye-ofis`) | Rename/broaden | Demo `Defter` ürünü canonical `defter` leaf'ine conceptual olarak uygundur. |
| Gıda | Market & Gıda (`market-gida`) | Rename/broaden | İçerik L2/L3 leaf'e göre ayrıca sınıflandırılır. |
| Ayakkabı | Ayakkabı (`ayakkabi`) | Direct | Numara/renk/gender category değil facet olarak kalır. |

Dört demo category de exactly one canonical L1'e temiz eşlenir; hiçbir mapping
merchant-sector node'a veya multi-primary category'ye gitmez.

## 12. Confirmed Merchant/Sector Scope Decisions

### Berber, Kuaför & Güzellik Salonu — CONFIRMED

Merchant/Sector Taxonomy future scope'una aşağıdaki ana başlık kaydedilmiştir:

- **Berber, Kuaför & Güzellik Salonu**
  - **Erkek Berberi**
  - **Kadın Kuaförü**
  - **Güzellik Salonu**

`Unisex Kuaför` subtype'ı **EKLENMEYECEK**. Bu hizmet sektörü Product Taxonomy L1
listesinde yer almaz. Bir salonun sattığı fiziksel şampuan, bakım veya kozmetik ürünü
ürünün kendi Product Taxonomy leaf'ine bağlanır; salon sector identity'si product
category olmaz.

Şunlar **TBD / future product decision** olarak kalır:

- randevu sistemi;
- hizmet rezervasyonu ve online booking;
- hizmet fiyat listesi veri modeli/algoritması;
- hizmet availability, çalışan ve zaman slotu modeli.

Bu belge booking veya Merchant App implementation'ı başlatmaz.

## 13. Figma / UI compatibility

| Contract | Uyumluluk | Not |
|---|---|---|
| Dynamic hierarchy | **PASS** | UI node isimlerini veya child sayısını hard-code etmemeli; data-driven projection kullanmalı. |
| Maximum depth 4 | **PASS** | Navigation/breadcrumb 1–4 seviyeyi destekler; her dal için dört ekran zorunlu değildir. |
| Variable-depth leaf | **PASS** | L2/L3/L4 leaf seçilebilir; leaf davranışı level numarasına bağlanmaz. |
| CategoryCard / CategoryRow | **PASS** | Current component library taxonomy'den dynamic label/image/availability alır; category başına component üretmez. |
| Category/Product Listing | **PASS** | Primary leaf ve descendant roll-up ile beslenebilir; listing/offer data category'den ayrıdır. |
| Filters | **PASS — architecture** | Facet/attribute profile leaf'ten açılır; brand/size/color node yapılmaz. Filter backend bu görevde yoktur. |
| Search | **PASS — architecture** | Canonical name, synonyms ve aliases için ayrı contract vardır; backend implementation yoktur. |
| Home projection | **PASS** | Availability-gated shortcut canonical 23 L1'in yerini almaz; sponsored ayrı ve etiketlidir. |

İstenen `docs/ESNAFTAVAR_CRITICAL_SCREEN_PILOT_V1.md` current main'de mevcut değildir;
bu yüzden o spesifik artefakt için görsel kabul iddiası yapılmaz. Mevcut canonical
`docs/ESNAFTAVAR_COMPONENT_LIBRARY_V1.md`, CategoryCard/CategoryRow'un dynamic taxonomy
ve availability sözleşmesini doğrular. Figma'ya bu görevde yazılmamış ve mevcut
Critical Screen Pilot davranışı değiştirilmemiştir.

## 14. Open owner decisions

1. **Stable ID bridge — PROPOSED / integration gate:** Current immutable V1 source
   slug ile future immutable opaque `id` ve mutable display slug nasıl bağlanacak?
2. **Policy governance — TBD:** `REGULATED` ve `LEGAL_REVIEW_REQUIRED` node'larda belge,
   moderator, audit/recall ve approval sahibi kim olacak?
3. **Sensitive domain permanence — TBD + legal:** Current excluded domainler kalıcı mı,
   yoksa yalnız V1 launch exclusion mı? Relaxation otomatik yapılamaz.
4. **Attribute profiles — TBD:** İlk typed `attribute_profile_id` pilotları ve value
   registry owner'ı kim olacak?
5. **Google mapping — TBD:** Google ID/path mapping hangi release ihtiyacında ve hangi
   taxonomy snapshot/version ile üretilecek?
6. **Merchant-sector breadth — TBD:** Teyit edilen salon başlığı dışında shop type
   L1/L2 seti ve many-to-many product recommendation kuralları ayrı çalışmada tasarlanmalı.
7. **Service capabilities — TBD:** Booking, hizmet kataloğu/fiyatı, çalışan ve slot
   modeli bu taxonomy kararından bağımsız owner review ister.
8. **Category request governance — TBD:** Merchant talebi, taxonomy review SLA,
   deprecation/replacement onayı ve sürüm yayın sahibi belirlenmeli.

Current 23 Product Taxonomy L1 adı/sınırı repo canonical V1.0.0 kararıdır; bu Phase A
belgesi owner'dan aynı L1 listesini yeniden onaylamasını gerektirmez. Yukarıdaki açık
kararlar runtime ve merchant-sector sonraki fazları içindir.

## 15. Next-phase plan

Bu görev Phase B L2/L3/L4 üretimi yapmaz. Current main zaten ayrı owner kararlarıyla
finalize edilmiş full V1.0.0 tree taşır; onu paralel bir Phase B ağacıyla çoğaltmak
yasaktır.

1. Product owner/integration owner bu architecture companion ve merchant-sector
   karar kaydını review eder.
2. Runtime öncesi stable ID/slug bridge kesinleştirilir.
3. Full V1.0.0 tree yeniden açılacaksa yalnız açık owner change request ile, öncelik
   sırası Elektronik → Ev & Yaşam → Moda & Giyim → Market & Gıda olacak şekilde
   mevcut L2 dalları review edilir; sıfırdan ikinci ağaç üretilmez.
4. Ayrı tek-sahipli implementation design; taxonomy schema/migration, deterministic
   ID mapping, read path ve seed planını hazırlar. Bu adım remote apply değildir.
5. Merchant/Sector Taxonomy ayrı lane'de, Product Taxonomy node'larını tekrar kullanmadan
   tasarlanır; salon hizmet capability'leri owner kararı gelmeden modellenmez.

`TAXONOMY_ARCHITECTURE: PASS`

`L1_RECOMMENDATION_READY_FOR_OWNER_REVIEW: YES`

`MERCHANT_SECTOR_SCOPE_DECISION_RECORDED: YES`

`DEMO_CATEGORY_MAPPING_READY: YES`

`READY_FOR_TAXONOMY_PHASE_B: NO`
