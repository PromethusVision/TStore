# EsnaftaVar Canonical Category Taxonomy — Research & Architecture

**Wave:** 15 / Phase A

**Araştırma tarihi:** 25 Ağustos 2026

**Durum:** V1 product owner review girdisi

**Kapsam:** Araştırma, bilgi mimarisi ve machine-readable taslak; migration, seed ve runtime implementation yoktur.

## Yönetici özeti

EsnaftaVar için önerilen model, başka bir pazar yerinin ağacını çevirmek veya K'pasa ekran adlarını backend gerçeğine dönüştürmek değildir. Öneri; yerel fiziksel ürün keşfi için bağımsız, Türkçe, stable slug kullanan ve her canonical ürünü **tek bir atanabilir yaprağa** bağlayan bir canonical ağaçtır. Marka, beden, renk, kapasite, cinsiyet, materyal, varyant, fiyat, stok ve mağaza mesafesi bu ağacın düğümü değil; ayrı attribute/facet veya offer verisidir.

V1 taslağı 20 L1, 91 L2, 505 L3 ve yalnız gerekli dallarda 32 L4 olmak üzere toplam 648 düğüm içerir. 526 yaprak ürün atamasına açıktır. Bu ölçek demo için değil, gerçek katalog başlangıcı içindir; fakat küresel taksonomilerin binlerce düğümlü ayrıntısını kopyalamaz. Yerel mağazada ticari karşılığı zayıf olan endüstriyel, dijital-only ve hizmet sınıfları dışarıda bırakılmıştır.

Önerilen çekirdek kararlar:

- Canonical ürün: tam bir aktif, atanabilir yaprak kategori.
- Merchant listing/offer: mağaza, fiyat, stok, uygunluk ve mesafe; canonical üründen ayrı.
- Marka: kategori değil, ayrı kimlik/facet.
- Attribute registry: kategoriye uygulanabilir, tipli, versiyonlu ve varyant/facet rollerini ayıran sözleşme.
- Search alias: node'a bağlı, marka içermeyen, Türkçe kullanıcı dilini ve yazım varyantlarını kapsayan arama sözlüğü.
- Dış taksonomiler: canonical kimlik değil, ayrı ve versiyonlu mapping tablosu.
- Riskli domain: ağaçta görünmesi otomatik yayın izni değildir; risk flag moderasyon routing'i sağlar.

## Repo ve mevcut ürün gerçeği

İncelenen canonical kaynaklar:

- `docs/PROJECT_STATE.md`
- `docs/LEGACY_ORDER_ISOLATION.md`
- `docs/PRODUCT_BACKLOG.md`
- `supabase/migrations/20260812000100_0001_core_auth_catalog.sql`
- `supabase/migrations/20260812000200_0002_shops.sql`
- category/product entity, model ve repository katmanları
- customer search Cubit ve kategori sunum helper'ı
- Esenler demo dataset ve seed sözleşmesi

Mevcut sistemin teyit edilen sınırları:

| Alan | Mevcut durum | Taxonomy etkisi |
|---|---|---|
| `categories` | `id`, `name`, `description`, `image_url`, `parent_id`, `sort_order`, `is_active` | Ağaç mümkün; slug, alias, seviye, assignment ve facet sözleşmesi henüz yok. |
| `products` | Tek `category_id`, ayrı `brand_id`, serbest `attributes JSONB` | Tek-primary-category yönüyle uyumlu; attribute registry ve doğrulama eksik. |
| `shop_products` | Mağaza bazlı fiyat/uygunluk/listing | Fiyat, stok ve mesafe kategoriye konmamalı. |
| Ürün arama | Ürün adı ve açıklamasında `ILIKE` | Alias, ancestor, marka ve yapılandırılmış attribute indeksleri gelecek faz ister. |
| Kategori arama | Kategori adı, UI-localized ad ve açıklama | Canonical alias alanı henüz runtime sözleşmesi değil. |
| Marka filtresi | Repository seviyesinde ayrı `brand_id` filtresi var | Marka-kategori ayrımının mevcut mimaride de temeli var. |
| Demo veri | Kırtasiye, Elektronik, Gıda, Ayakkabı | Yalnız demonstrasyon dataset'i; ürün taxonomy source of truth değildir. |
| Merchant katalog | Ürün/stok/fiyat yönetimi yok | Taslak merchant formunu yönlendirecek mimari girdi sağlar, implementation yapmaz. |

EsnaftaVar'ın canonical ürün yönü klasik checkout/kargo değil; müşterinin yakındaki esnafta ürünü keşfetmesi, tek mağaza sepeti hazırlaması ve fiziksel alışverişi QR ile doğrulamasıdır. Bu nedenle taxonomy'nin görevi teslimat ağacını taklit etmek değil; **ürün nedir, hangi özelliklerle aranır ve hangi yerel mağazada bulunur** sorularını tutarlı bağlamaktır.

## Araştırma yöntemi

Araştırma 25 Ağustos 2026 tarihinde kamuya açık ve mümkün olduğunca resmi/birincil kaynaklarla yapıldı. Ağaçlar kopyalanmadı; şu tasarım sinyalleri karşılaştırıldı:

- canonical kimlik ve path davranışı;
- yaprak kategoriye ürün atama kuralı;
- kategori ile attribute/aspect ayrımı;
- kategoriye özel zorunluluk ve varyant metadata'sı;
- versioning/deprecation yaklaşımı;
- merchant veri girişindeki pratikler;
- Türk pazarındaki isimlendirme ve yerel perakende kapsamı;
- ürün güvenliği ve açıkça riskli/yasak domainler.

### Kaynak karşılaştırması

| Kaynak | Gözlenen örüntü | EsnaftaVar'a alınan ilke | Bilerek alınmayan taraf |
|---|---|---|---|
| Google Product Taxonomy | Kamu dosyası 5.595 kategori satırı taşır; derinlik dal bazında değişir ve her satır numeric kimlik + breadcrumb verir. Merchant spesifikasyonu ürün başına tek ve en ilgili Google kategorisini önerir; merchant-defined `product_type` ayrıdır. [Taxonomy dosyası](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt), [ürün veri sözleşmesi](https://support.google.com/merchants/answer/7052112?hl=en) | Tek en-spesifik leaf, stable semantic kimlik, tam breadcrumb, kategori ile merchant özel etiketin ayrılması. | ABD/global genişliği, canlı hayvan, silah, endüstriyel ve EsnaftaVar'a ilgisiz uzun kuyruk kopyalanmadı. Kamu dosyasının header sürümü `2021-09-21`; bu nedenle tek başına “güncel Türkiye gerçeği” sayılmadı. |
| Shopify Standard Product Taxonomy | Standard category ürünün ana fonksiyonunu tanımlar; kategoriye bağlı metafield/attribute'lar renk, beden, kumaş, yaş grubu gibi alanları ayrı tutar. Her ürünün tek standard category'si ve ayrı custom product type'ı olabilir. Açık repo source data, localizations ve mapping dağıtımları taşır. [Shopify Help](https://help.shopify.com/en/manual/products/details/product-category?lang=en-US), [resmi açık repo](https://github.com/Shopify/product-taxonomy) | Category ↔ attribute applicability, stable distribution, localization ve external mapping katmanı. | Vergi/checkout odaklı kurallar ve global uzun kuyruk birebir alınmadı. |
| Amazon Selling Partner API | Product Type Definitions API, mağaza ve product type için zorunlu/opsiyonel/koşullu alanları JSON Schema olarak döndürür; katalog sınıflandırması ve listing requirement ayrı servislerdir. [Resmi listing rehberi](https://developer-docs.amazon.com/sp-api/lang-en_EN/docs/manage-product-listings-guide) | Merchant formu category leaf seçildikten sonra tipli ve koşullu şemayla açılmalı; validation UI'dan bağımsız sözleşme olmalı. | Amazon browse node/ASIN ve fulfillment mantığı EsnaftaVar canonical kimliği yapılmadı. |
| eBay Taxonomy API | Category tree marketplace bazında versioned'dır; seller leaf suggestion alabilir. Leaf category sonrasında aspect'lerin required/recommended/optional, cardinality ve variation rolleri sorgulanır. Expired category mapping'i ayrı API davranışıdır. [Seller category rehberi](https://developer.ebay.com/api-docs/sell/static/metadata/sell-categories.html), [buyer tree rehberi](https://developer.ebay.com/api-docs/buy/buy-categories.html), [release notes](https://developer.ebay.com/api-docs/commerce/taxonomy/static/release-notes.html) | Leaf suggestion, facet metadata, category retirement/replacement mapping'i ve versioning. | Pazar yeri bazında ayrı canonical ağaç yerine EsnaftaVar için tek TR canonical ağaç; dış pazarlar mapping olarak kalır. |
| Trendyol Marketplace API | Ürün yalnız en alt kategori ID'sine açılır; ağaç ve kategori-özellik listesi periyodik güncellenir. Attribute metadata'sı required, slicer, varianter ve multi-value rollerini ayırır. [Kategori ağacı](https://developers.trendyol.com/docs/trendyol-kategori-listesi-getcategorytree), [kategori özellikleri V2](https://developers.trendyol.com/docs/kategori-%C3%B6zellik-listesi-v2) | Yaprak-only merchant assignment, kategoriye bağlı required/facet/variant ayrımı, değişen kaynaklara karşı versioning. | Trendyol ID/adları ve moda-merkezli merchandising ağacı kopyalanmadı. |
| Hepsiburada API | Kategori ürün data modelini belirler; yalnız `leaf: true`, active ve available kategoriler ürün açmaya uygundur. Attribute ve variant group katalog girişinden ayrılmaz. [Resmi API portalı](https://developers.hepsiburada.com/tr/companies/hepsiburada?guide=katalog-onemli-bilgiler&product=katalog-urun-entegrasyonu&view=guide) | Leaf'in `assignable` durumunu açık taşımak; kategori durumunu sadece `is_active` ile karıştırmamak; varyant grubunu kategori sanmamak. | Hepsiburada leaf ID ve kategori adları canonical kaynak yapılmadı. |
| n11 Marketplace API | Tüm kategori ağacı ve leaf işareti ayrı; kategori attribute'larında mandatory ve variant bilgileri vardır. [n11 kategori/özellik rehberi](https://magazadestek.n11.com/satis-surecleri/restapi-kategori-agaci-ve-kategori-ozellikleri-listeleme-10473) | Zorunlu attribute, izinli değer ve varyant rollerini category mapping'inde tutmak. | n11 katalog kimlikleri ve marketplace checkout operasyonu alınmadı. |

### Sentez

Kaynaklar farklı ölçeklerde olsa da ortak sonuç nettir:

1. Category, ürünün ana ticari/fonksiyonel sınıfıdır.
2. Merchant en-spesifik, ürün atanabilir yaprağı seçer.
3. Marka, renk, beden, uyumluluk, kapasite ve benzeri ayrımlar category değil aspect/attribute'tur.
4. Yaprak kategori, hangi alanların gerekli ve hangi alanların varyant/filtre olduğu bilgisini açar.
5. Taxonomy değişir; stable identity, sürüm, retirement ve replacement mapping'i olmadan analitik kırılır.
6. Browse tree ile kampanya/UI koleksiyonları aynı şey değildir.

## Tasarım ilkeleri

### 1. Ürün fonksiyonuna göre sınıflandır

Ürün birden fazla özelliğe sahip olsa da ana fonksiyonu hangi yaprakta olduğunu belirler. Işıklı alarm saati “aydınlatma” değil saat; bataryalı telefon kılıfı ana fonksiyonu koruma ise telefon kılıfıdır. Gerekli ek keşif sinyalleri attribute ve keywords üzerinden gelir.

### 2. Tek primary leaf, çoklu keşif sinyali

Canonical ürünün tek primary leaf'i olur. Çoklu browse ihtiyacı şu katmanlarla çözülür:

- ancestor roll-up;
- attributes/facets;
- searchable aliases ve keywords;
- editoryal/seasonal collection;
- recommendation embeddings/signalleri;
- ayrı external taxonomy mapping'i.

Bir ürünü birden fazla canonical kategoriye bağlamak; sayım, reklam bütçesi, reward analitiği, merchant validasyonu ve duplicate yönetimini belirsizleştirir.

### 3. Slug kimlik, görünen ad içeriktir

Slug ASCII kebab-case semantic anahtardır. `display_name_tr` veya merchant label iyileştirilebilir; sırf copy değişti diye slug değişmemelidir. Düğüm taşınırsa slug korunur, parent değişir; birleşme/emeklilikte `replaced_by_slug` mapping'i gerekir. UUID bu fazda özellikle üretilmemiştir.

### 4. Derinlik hedef değil

- L1: müşterinin ve merchant'ın tanıdığı geniş departman.
- L2: ticari alt alan.
- L3: çoğunlukla atanabilir ürün grubu.
- L4: L3 merchant için hâlâ farklı attribute şemaları gerektiren birkaç dalda ürün tipi.

V1'de L4 yalnız 32/648 (%4,9) düğümdür. Telefon şarj/kılıf, bilgisayar ana bileşen/depolama, oto motor/fren parçaları ve kedi-köpek mama formatı gibi alanlarda kullanılır. “Her dal dört seviye olmalı” kuralı yoktur.

### 5. UI taxonomy'yi yönetmez

Ana sayfa kısayolları, sponsor alanları, kampanyalar, K'pasa chip'leri veya merchant popüler kategorileri canonical ağacın ayrı projection'larıdır. UI isimleri source of truth değildir. `sort_order` canonical sibling sırası içindir; kişiselleştirilmiş merchandising ayrıca tutulmalıdır.

### 6. Yerel availability kategori değildir

Fiyat, aktif stok, mağaza uzaklığı, açık/kapalı durumu ve “bugün mevcut” sinyali canonical product değil `shop_products`/offer bağlamıdır. Bunlar müşteri filtresidir fakat node-specific attribute registry'ye gömülmez.

## V1 seviye mimarisi

| Seviye | Sayı | Anlam | Atama |
|---|---:|---|---|
| L1 | 20 | Ana kategori/departman | Hayır |
| L2 | 91 | Alt kategori | Mevcut taslakta hayır; model gelecekte L2 leaf'e izin verir. |
| L3 | 505 | Ürün grubu | Yaprak ise evet. |
| L4 | 32 | Ürün tipi | Evet. |
| Toplam | 648 |  | 526 atanabilir yaprak |

L1'ler:

1. Market & Gıda
2. Moda & Giyim
3. Ayakkabı
4. Çanta & Giyim Aksesuarı
5. Elektronik
6. Bilgisayar & Tablet
7. Beyaz Eşya & Ev Aletleri
8. Ev & Yaşam
9. Züccaciye & Mutfak
10. Yapı & Hırdavat
11. Otomotiv & Motosiklet
12. Kişisel Bakım & Kozmetik
13. Bebek & Çocuk
14. Oyuncak, Hobi & Müzik
15. Spor & Outdoor
16. Kitap & Kırtasiye
17. Pet Shop
18. Optik, Saat & Takı
19. Sağlık & Medikal
20. Çiçek, Bahçe & Hediyelik

Bu L1 listesi mağaza türleri değil ürün domainleridir. Bir mahalle esnafı birden fazla L1'de ürün sunabilir; shop type ile category birbirine bağlanmamalıdır.

## Taxonomy ile attribute ayrımı

Karar testi:

| Soru | “Evet” ise |
|---|---|
| Ürünün ana işlevini değiştiriyor ve merchant farklı veri şemasıyla tanımlıyor mu? | Category adayı. |
| Aynı ürün ailesinde seçilebilir varyant/değer mi? | Attribute/variant. |
| Müşteri filtrelemek istiyor ama ürün aynı türde mi kalıyor? | Facet attribute. |
| Mağazaya/listing'e göre değişiyor mu? | Offer/listing alanı. |
| Kampanya veya sezon anlatımı mı? | Collection/merchandising etiketi. |
| Üretici adı mı? | Brand. |

Örnekler:

| Yanlış kategori yaklaşımı | Önerilen model |
|---|---|
| Elektronik > Cep Telefonu > Apple/Samsung | `Akıllı Telefon` leaf + `brand` facet. |
| Giyim > Kadın > Siyah > M | Ürün tipi leaf + `gender`, `color`, `apparel_size` ve `fit`. |
| Ayakkabı > 42 Numara | Ayakkabı leaf + `shoe_size=42`. |
| Telefon Kılıfı > iPhone 17 | `Cep Telefonu Kılıfı` + kontrollü `compatibility`. |
| Oto Parça > belirli araç markası/modeli | Parça leaf + marka-model-yıl-motor fitment kaydı. |
| Market > Vegan | Gıda leaf + çoklu `dietary_preference`; aynı ürün “glutensiz” de olabilir. |
| Yakındaki / İndirimli / Stokta | Mağaza offer filtreleri; taxonomy düğümü değil. |
| Yeni Sezon / Okula Dönüş | Editoryal/seasonal collection. |

Kitap türleri müşteri rafı olarak ağaçta primary shelf sağlar; `book_genre` ayrıca çoklu değer taşıyabilir. Böylece bir eser tek primary leaf'e atanırken birden çok türe göre aranabilir.

## Filter ve attribute mimarisi

### Katmanlar

1. **Kategoriler arası catalog facets:** `brand`, `condition`; her leaf'te otomatik zorunlu değildir ve ikinci el politikası ayrıca owner kararıdır.
2. **Kategoriye özgü product attributes:** beden, materyal, kapasite, cilt tipi, uyumluluk, pet türü vb.
3. **Variant axes:** renk, beden, ayakkabı numarası, depolama kapasitesi gibi aynı canonical ürünün satılabilir varyantını ayıran alanlar.
4. **Offer/discovery filters:** fiyat, stok/availability, mağaza mesafesi, mağaza açık mı; canonical product attribute değildir.
5. **Compliance attributes:** enerji sınıfı, oyuncak yaş uyarısı, medikal kayıt, güvenlik standardı, alerjen ve saklama koşulu.
6. **Analytics-only dimensions:** risk routing, category ancestor, taxonomy version; merchant serbest metni olmamalı.

### Önerilen future registry sözleşmesi

Bu faz DB tasarlamaz; sonraki faz için mantıksal varlıklar:

| Varlık | Görev |
|---|---|
| `attribute_definitions` | Stable key, TR label, data type, unit family, cardinality ve normalizasyon. |
| `attribute_values` | Kontrollü enum değerleri, aliases ve sıralama. |
| `category_attribute_rules` | Leaf/category ↔ attribute; required/recommended/optional, facet, variant, searchable ve inheritance rolleri. |
| `product_attribute_values` | Canonical ürünün doğrulanmış yapılandırılmış değerleri. |
| `product_variants` | Varyant eksenleri ve canonical ürün altındaki satılabilir variant kimliği. |
| `external_taxonomy_mappings` | Google/Shopify/pazar yeri sürümü, dış ID/path, confidence ve valid dates. |
| `category_replacements` | Emekli slug → aktif slug, effective date ve migration notu. |

Her attribute tanımı en az şunları taşımalıdır:

- stable key ve localized label;
- string/integer/decimal/boolean/enum/range/date veri tipi;
- birim ailesi ve canonical unit;
- single/multi cardinality;
- izinli/custom değer davranışı;
- required/recommended/optional;
- variant/facet/search/display rolleri;
- kategori inheritance ve override;
- validation/normalization;
- compliance/risk sınıfı.

Mevcut `products.attributes JSONB` kısa vadeli taşıyıcı olabilir; fakat merchant doğrulaması, indeksleme ve analitik için tek başına uzun vadeli source of truth olmamalıdır.

### Filter-family applicability

Machine-readable taslak 62 filter family tanımlar ve her node için `applicable_filter_family_ids` üretir. Bunlar hazır filtre değerleri değil, form/facet ailesi önerisidir. Örnek:

- Giyim: marka, renk, materyal, hedef cinsiyet, yaş grubu, beden, kalıp.
- Telefon: marka, ekran, depolama, RAM, bağlantı, işletim sistemi, garanti.
- Gıda: miktar, beslenme tercihi, alerjen, menşei, aroma, saklama koşulu.
- Otomotiv: araç uyumluluğu, parça konumu, güç, güvenlik standardı.
- Medikal: kullanım amacı, cihaz sınıfı/kaydı ve güvenlik uygunluğu.

## Search alias mimarisi

### Alias türleri

- **Yaygın eş anlam:** cep telefonu ↔ telefon ↔ smartphone.
- **Pazar dili:** spor ayakkabı ↔ sneaker; şarj cihazı ↔ şarj aleti.
- **Yerel mağaza dili:** hırdavat ↔ nalbur; market ↔ bakkal; balık & deniz ürünü ↔ balıkçı.
- **ASCII fallback:** kırtasiye ↔ kirtasiye; züccaciye ↔ zuccaciye.
- **Birleşik/ayrı yazım:** powerbank ↔ power bank.
- **İngilizce ödünç terim:** laptop, webcam, router; yalnız Türkiye'de gerçekten kullanılan terimler.

Marka isimleri alias değildir. Marka sorgusu brand index'inden gelir ve category sinyaliyle birlikte sıralanabilir.

### Normalizasyon ve sıralama önerisi

1. Unicode normalize et; Türkçe `I/İ/ı/i` case folding'i locale-aware yap.
2. Noktalama, art arda boşluk ve `&` varyasyonlarını normalize et.
3. Diakritik/ASCII folding'i ek fallback olarak kullan; canonical metni bozma.
4. Exact canonical ad > canonical prefix > exact alias > alias prefix > keyword > açıklama sırası uygula.
5. Matched leaf'in ancestor'larını browse sonucu olarak roll-up et; ancestor eşleşmesinde tüm descendant ürünleri körlemesine ilk sayfaya yığma.
6. Typo/fuzzy aramayı alias kaynağına yazmak yerine kontrollü search katmanında ele al.
7. Alias değişikliklerini ölç; zero-result sorgu ve yanlış kategori tıklaması product feedback'i olsun.

`search_aliases` kullanıcıya gösterilen kategori adı değildir. `optional_keywords` daha düşük ağırlıklı, merchandiser kontrollü arama sinyalidir; promotional copy veya rakip marka enjeksiyonu kabul etmez.

## Yerel fiziksel perakende uyarlamaları

### Yerel dükkân gerçekliği

Taslak; bakkal/market, manav, fırın, kasap, şarküteri, balıkçı, nalbur/hırdavat, züccaciye, telefoncu, bilgisayarcı, kırtasiye, pet shop, optikçi, çiçekçi ve oto yedek parçacı gibi Türkiye mahalle perakendesini tanıyan dil kullanır. Bunlar ayrı shop type olabilir; ürün taxonomy'sinde ise gerçek ürün gruplarına açılır.

### Fiziksel keşif farkı

- “Yakında var mı?” category değil stok + mesafe sorgusudur.
- Aynı canonical ürün birçok esnafta farklı fiyat/availability ile listelenebilir.
- Merchant, tam breadcrumb ve örnek attribute'larla leaf seçmelidir.
- Barkodsuz/yerel üretim ürün için marka zorunlu olmayabilir; “Markasız” sahte marka yaratılmamalıdır.
- Açık ürün/ağırlıkla satış için miktar ve satış birimi listing bağlamında ayrıca modellenmelidir.
- Taze gıdada soğuk zincir, son tüketim/tavsiye edilen tüketim tarihi ve günlük availability gerekir.
- Telefon ve oto parçada model uyumluluğu serbest metin değil kontrollü referans olmalıdır.
- Mahalle bazında boş L1/L2'ler UI'da zorunlu gösterilmez; canonical ağacın varlığı ile o bölgede merchandised görünürlük ayrıdır.

### Merchant-friendly label

Her node ayrı `merchant_label_tr` taşır. V1'de çoğu display adıyla aynıdır; yapı buna rağmen ayrıdır çünkü müşteri “Akıllı Telefon” görürken merchant formu gelecekte “Akıllı Telefon (cihaz)” gibi disambiguation isteyebilir. Label değişimi slug değişimi değildir.

## Downstream sistemlere hizmet

| Sistem | Canonical taxonomy rolü |
|---|---|
| Customer browse | Ancestor/descendant roll-up, bölgesel availability ile projection. |
| Search | Canonical ad, alias, keywords, ancestor ve structured attribute sinyalleri. |
| Filter | Yaprağa bağlı facet applicability ve aggregate değer sayıları. |
| Merchant upload | Leaf suggestion, breadcrumb, required fields ve validasyon. |
| Analytics | Stable slug + taxonomy version ile zaman içinde karşılaştırılabilir boyut. |
| Sponsored advertising | Category/ancestor hedefi; marka ve lokasyon ayrı targeting dimension. |
| Recommendation | Category prior, co-view/co-purchase ve attribute similarity; UI kategorisiyle sınırlı değil. |
| Reward/gamification | Category roll-up ile çeşitlilik/yerel alışveriş ölçümü; fiyat/mağaza verisinden ayrık. |

## JSON veri sözleşmesi

`docs/data/esnaftavar_category_taxonomy_v1_draft.json` self-describing metadata taşır:

- `schema_version`, `taxonomy_version`, `locale`, `status`;
- deterministic sıra ve identity/assignment politikası;
- seviye/toplam/yaprak sayıları;
- filter family ve risk flag tanımları;
- explicit excluded domainler;
- validation summary;
- DFS preorder `nodes` listesi.

Her node için zorunlu alanlar:

| Alan | Tip | Kural |
|---|---|---|
| `slug` | string | Global unique ASCII kebab-case stable semantic key. |
| `display_name_tr` | string | Canonical müşteri adı. |
| `merchant_label_tr` | string | Merchant seçim adı. |
| `parent_slug` | string/null | Yalnız L1'de `null`; aksi halde önceki node'a referans. |
| `level` | integer | 1–4; parent + 1. |
| `level_label_tr` | string | Ana Kategori / Alt Kategori / Ürün Grubu / Ürün Tipi. |
| `path_slugs` | string[] | Root'tan node'a stable key path. |
| `path_display_tr` | string[] | Root'tan node'a TR breadcrumb. |
| `sort_order` | integer | Sibling içinde 1 tabanlı açık sıra. |
| `is_leaf` | boolean | Child yoksa true. |
| `assignable` | boolean | V1'de ancak ve ancak leaf ise true. |
| `search_aliases` | string[] | Node içinde normalize duplicate yok; boş olabilir. |
| `optional_keywords` | string[] | Düşük ağırlıklı kontrollü arama terimi; boş olabilir. |
| `applicable_filter_family_ids` | string[] | Tanımlı registry key'leri. |
| `risk_flags` | string[] | Tanımlı risk routing key'leri. |

Determinism:

- node sırası DFS preorder + açık sibling `sort_order`;
- tüm obje key'leri üreticide sabit sırada;
- iki boşluk JSON indentation ve final newline;
- tarih/sürüm sabit; runtime timestamp yok;
- UUID ve database insert yok;
- arrays ordered ve node içinde unique;
- aynı input her çalıştırmada byte-equivalent JSON üretir.

## Güvenlik, hukuk ve uygunluk sınırı

Bu bölüm hukuki görüş değildir; yayın politikası ve uzman incelemesi için risk haritasıdır.

### Açıkça dışarıda tutulan domainler

- Reçeteli/reçetesiz ilaçlar ve özel tıbbi amaçlı ürünler.
- Tütün, nikotin ve elektronik sigara ürünleri.
- Alkollü içkiler.
- Ateşli silah, mühimmat ve patlayıcılar.
- Yasa dışı maddeler ve üretim ekipmanı.
- Canlı hayvan satışı.
- Dijital-only ürünler, hizmetler ve klasik checkout/kargo domainleri.

6197 sayılı Kanun'un 24. maddesi ilaçların internet veya başka elektronik ortamda satışını yasaklar; bu nedenle ilaçlar taxonomy'ye alınmadı. [Sağlık Bakanlığı/HSGM konsolide kanun PDF'si](https://hsgm.saglik.gov.tr/depo/Mevzuat/Kanunlar/Eczacilar_Ve_Eczaneler_Hakkinda_Kanun_6197.pdf)

Tütün/alkol mevzuatı tüketiciye internet ve benzeri elektronik ticaret araçlarıyla satış sistemi kurulmasını yasaklayan hükümler ve alkol reklam/tanıtım kısıtları taşır. EsnaftaVar yalnız fiziksel discovery olduğunu varsayarak bu ürünleri otomatik güvenli saymamalıdır; V1 bunları dışarıda tutar. [Tarım ve Orman Bakanlığı yönetmeliği](https://www.tarimorman.gov.tr/TADAB/Belgeler/Y%C3%B6netmelikler/yonetmelik_27808_07.01.2011.pdf), [2026 reklam düzenlemesi duyurusu](https://www.tarimorman.gov.tr/TADAB/Duyuru/280/Alkollu-Icki-Reklamlarina-Iliskin-Mevzuatta-Yapilan-Degisiklik-Hakkinda-Duyuru)

7223 sayılı Ürün Güvenliği ve Teknik Düzenlemeler Kanunu; piyasaya arz, izlenebilirlik, geri çağırma ve güvensiz ürün sorumluluğu çerçevesi getirir ve çevrimiçi ürünler de denetim kapsamındadır. Oyuncak, tekstil, ayakkabı, elektrikli ürün, kimyasal ve medikal gibi gruplar kategoriye özel uygunluk alanı ister. [Türkiye Ürün Kuralları veritabanı](https://urunkurallari.ticaret.gov.tr/tr/mevzuat/7223-sayili-urun-guvenligi-ve-teknik-duzenlemeler-kanunu), [Ticaret Bakanlığı PGD mevzuatı](https://www.ticaret.gov.tr/tuketici/mevzuat/piyasa-gozetimi-ve-denetimi-mevzuati)

### Risk flag gerektiren başlıca dallar

- Tıbbi cihaz, optik ölçülü ürün ve kontakt lens: `regulated_review`.
- Vitamin/gıda takviyesi, dermokozmetik ve sağlık iddiası: `claim_sensitive` + gerekirse `regulated_review`.
- Bebek oto koltuğu, beşik, oyuncak yaş uygunluğu: `safety_critical`/`age_sensitive`.
- Fren, lastik, kask, iş güvenliği donanımı: `safety_critical` + `compatibility_critical`.
- Boya, solvent, pil, akü, aerosol ve benzeri: `hazmat_review`.
- Taze/soğuk gıda: `cold_chain`.

Risk flag ürünün yayınlanabileceği anlamına gelmez. Operasyonel policy; hangi belge, yetkili satıcı, kayıt numarası, claim moderasyonu ve recall akışının zorunlu olduğunu ayrıca tanımlamalıdır.

## Riskler ve mitigasyon

| Risk | Etki | Mitigasyon |
|---|---|---|
| Fazla derin/boş dallar | Merchant yanlış leaf seçer, browse boş görünür. | L4 yalnız %4,9; UI yalnız stoklu projection gösterir; merchant pilot telemetry. |
| Category churn | Analitik ve reklam hedefi kırılır. | Stable slug, taxonomy version, retirement/replacement mapping. |
| Marka/attribute sızıntısı | Ağaç şişer ve arama parçalanır. | Automated guards + taxonomy review checklist. |
| Tek-primary-category sınır vakaları | Çok işlevli ürün tartışması. | Ana işlev kuralı + secondary attributes/collections; adjudication log. |
| Alias yanlış pozitifleri | Yanlış ürün/leaf önerisi. | Ağırlıklı alias türleri, zero-result/click telemetry, marka yasağı. |
| Merchant yükü | Eksik veya düşük kaliteli veri. | Leaf suggestion, progressive form, required/recommended ayrımı, barcode/catalog match. |
| Serbest JSONB drift | Filtre ve analytics güvenilmez. | Versiyonlu attribute registry ve typed validation. |
| Uyumluluk serbest metni | Telefon/oto parçada yanlış satış. | Kontrollü device/vehicle fitment referansı. |
| Regüle ürün yanlış yayını | Hukuki ve kullanıcı güvenliği riski. | Fail-closed category policy, belge/claim review, audit trail, recall/deactivation. |
| External taxonomy'yi canonical yapmak | Dış değişiklik iç analitiği bozar. | Versioned mapping layer; internal slug bağımsız kalır. |

## Kalite doğrulamaları

Üretim doğrulaması ve bağımsız validator şu kapıları fail-closed çalıştırdı:

| Kontrol | Sonuç |
|---|---|
| JSON parse ve zorunlu alan üretimi | PASS |
| Duplicate slug | PASS — 0 |
| Normalize duplicate sibling adı | PASS — 0 |
| Cycle | PASS — 0 |
| Orphan | PASS — 0 |
| Parent/level uyumsuzluğu | PASS — 0 |
| Maximum depth | PASS — 4 |
| Leaf/assignable tutarlılığı | PASS |
| Bilinmeyen filter family/risk referansı | PASS — 0 |
| Brand-as-category guard | PASS — 0 |
| Exact attribute-as-category guard | PASS — 0 |
| Çıplak belirsiz ad (`Diğer`, `Aksesuar`, `Parça` vb.) | PASS — 0 |
| Türkçe display spelling guard | PASS — 0 |
| Node-içi normalize duplicate alias | PASS — 0 |

Semantik QA ayrıca şu ilkelerle yapıldı:

- kadın/erkek/çocuk ayrımı moda ve ayakkabıda kategori ağacını çoğaltmadı;
- cihaz/araç markaları kategori olmadı;
- dijital hizmet/checkout kategorileri eklenmedi;
- riskli ürünlere flag verildi veya domain tamamen dışlandı;
- çıplak “aksesuar/parça/malzeme” yerine bağlamlı ad kullanıldı;
- optik, sağlık ve pet shop'ta canlı hayvan/ilaç ayrımı korundu.

## Product owner kararları

V1 draft hazırdır; implementation öncesi owner'ın çözmesi gereken gerçek ürün kararları:

1. **L1 onayı:** 20 L1'in adı ve sınırı kabul ediliyor mu? Özellikle `Elektronik` ile `Bilgisayar & Tablet`, `Ev & Yaşam` ile `Züccaciye & Mutfak` ayrımı.
2. **Tam canonical / kademeli görünürlük:** Öneri tam 648-node canonical registry'yi koruyup müşteri/merchant UI'da yalnız aktif ve stoklu subset'i göstermektir. Launch'ta fiziksel olarak seed edilecek subset ayrı karardır.
3. **Regüle domain policy:** Sağlık/medikal, kontakt lens, supplement, kimyasal ve güvenlik kritik ürünler için belge/moderasyon sahibi kim olacak? Policy yoksa ilgili leaf'ler inactive kalmalıdır.
4. **Yasak domainlerin kalıcılığı:** İlaç, tütün/nikotin, alkol, silah/patlayıcı ve canlı hayvan V1'de dışarıdadır. Gelecekte yalnız uzman hukuki görüş ve ayrı owner kararıyla ele alınmalıdır.
5. **İkinci el/yenilenmiş ürün:** Öneri yeni kategori açmak değil `condition` attribute kullanmaktır; fakat merchant kabul ve kalite policy'si owner kararıdır.
6. **Kitap sınıflandırması:** Öneri tek primary shelf + çoklu `book_genre`; editorial ekip ihtiyacı teyit edilmelidir.
7. **Shop type taxonomy:** Ürün kategorisinden ayrı bir merchant/shop type ağacı ayrıca tasarlanacak mı? Ürün L1'leri shop type olarak tekrar kullanılmamalıdır.
8. **Category governance:** Slug sahibi, değişiklik talebi, review SLA, version cadence ve backward mapping sorumlusu belirlenmelidir.
9. **External mapping önceliği:** Google/Shopify/Trendyol mapping'lerinden hangileri V1 merchant onboarding için gerçekten gereklidir? Mapping canonical tree'yi değiştirmemelidir.
10. **Attribute registry fazı:** Hangi L1'lerle pilot yapılacak ve required/variant/facet değer sözlüklerini kim onaylayacaktır?

## Sonraki faz için önerilen sıra

1. Product owner L1 sınırlarını, excluded/risky domainleri ve tek-primary-leaf kuralını onaylar.
2. 6–10 gerçek yerel merchant'tan temsilî SKU örnekleriyle leaf coverage ve yanlış sınıflandırma pilotu yapılır.
3. Zero-result müşteri sorguları ve merchant dilinden alias listesi ölçüyle iyileştirilir.
4. Seçilen pilot L1'ler için typed attribute registry ve category rules tasarlanır.
5. Demo 4 kategori/20 ürün için old → new leaf mapping planı hazırlanır; henüz migration/seed uygulanmaz.
6. External mapping ve category lifecycle/retirement sözleşmesi oluşturulur.
7. Ancak bu kapılar geçince DB migration, seed, search index ve merchant UI implementation fazına gidilir.

## Üretilen artefaktlar

- `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY_RESEARCH.md`
- `docs/ESNAFTAVAR_CATEGORY_TAXONOMY_V1_DRAFT.md`
- `docs/data/esnaftavar_category_taxonomy_v1_draft.json`

`CATEGORY_TAXONOMY_RESEARCH: PASS`

`CATEGORY_TAXONOMY_V1_DRAFT_READY: YES`

`READY_FOR_PRODUCT_OWNER_TAXONOMY_REVIEW: YES`
