# EsnaftaVar Canonical Category Taxonomy — Architecture + L1

**Wave:** 15 / Phase A2

**Belge tarihi:** 27 Ağustos 2026

**Owner approval:** 27 Ağustos 2026 / Wave 15 Phase A2 — **CONFIRMED — PRODUCT OWNER FINAL**

**Kapsam:** Product taxonomy mimarisi, L1 ana kategori seti, merchant-sector ayrımı
ve owner-final Elektronik/Bilgisayar & Tablet L2 omurgaları

**Runtime durumu:** Dokümantasyon; migration, seed, Flutter, Figma veya remote değişikliği yoktur.

**Integration durumu:** Wave 15 Phase A ile B1+B2 final integration tamamlandı;
taxonomy architecture, 24 Product L1 owner lock, Elektronik `9` L2 ve Bilgisayar &
Tablet `11` L2 canonical'dır. Current full-tree JSON ile rename/split reconciliation,
L3/L4 design ve runtime implementation ayrı controlled task'lardır.

> Current main notu: Phase A başladığında repo önceki `v1.0.0` full taxonomy
> artefaktını içeriyordu. Phase A1'de refine edilen 24 Product Taxonomy L1 adı ve
> sırası, Product Owner tarafından Phase A2'de açıkça **CONFIRMED / FINAL / CANONICAL
> V1** olarak onaylandı. Bu decision lock mevcut L2/L3/L4 ağacını yeniden üretmez ve
> `docs/data/esnaftavar_category_taxonomy_v1_final.json` dosyasını değiştirmez.
> Full tree/JSON/runtime reconciliation ayrı controlled integration görevidir.

## Karar etiketleri

- **CONFIRMED:** Product owner'ın bu görevde açıkça teyit ettiği karar; bu belgede
  özellikle Merchant/Sector hizmet kapsamı için kullanılır.
- **CONFIRMED — PRODUCT OWNER FINAL:** Phase A2'de kilitlenen 24 Product Taxonomy L1
  adı, sırası ve L1 sınırı; **CANONICAL V1 product decision**'dır.
- **CANONICAL / FINAL:** Product/Merchant/Facet ayrımı, variable-depth max-4 model,
  exactly-one primary leaf ve bu Phase A'da kilitlenen taxonomy mimarisi.
- **PROPOSED:** Runtime schema, stable-ID bridge, search ve governance gibi ayrı
  implementation/design kararları.
- **TBD:** Ürün, hukuk, operasyon veya implementation kararı henüz verilmemiş alan.

## 1. Purpose

**Architecture status: CANONICAL / FINAL.** Phase A2, owner-approved 24 L1 product
decision'ı ile birlikte Product/Merchant/Facet ayrımını, variable-depth max-4
modelini ve exactly-one primary leaf kuralını canonical olarak kilitler. Runtime
schema ve migration ayrı implementation işidir.

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

### Araştırma sentezi — CANONICAL ARCHITECTURE BASIS

- Ürün, tam olarak bir primary canonical leaf'e atanır.
- Leaf olup olmama ile aktif/atanabilir olma ayrı kavramlardır.
- Attribute, facet ve variant metadata category node değildir.
- Dış taxonomy ID/path'i internal kimlik değil, versioned mapping'dir.
- Ağaç değişebilir; stable identity, deprecation ve replacement kaydı gerekir.
- Marketplace merchandising derinliği EsnaftaVar'a wholesale kopyalanmaz.

## 3. Product Taxonomy vs Merchant/Sector Taxonomy vs Facets

| Sistem | Soru | Örnek | Canonical rol | Durum |
|---|---|---|---|---|
| **Product Taxonomy** | Bu ürün nedir? | Elektronik → Telefon & Giyilebilir Teknoloji → Akıllı Telefon | Customer browse, search context, merchant product entry, analytics | **CANONICAL / FINAL** |
| **Merchant / Sector Taxonomy** | Bu işletme ne tür bir işletmedir? | Telefoncu, Kırtasiye, Pet Shop, Erkek Berberi | Merchant onboarding, shop profile, sector filter ve future policy routing | **CONFIRMED / FINAL — ayrı sistem** |
| **Facet / Attribute System** | Bu ürünün seçilebilir/filtrelenebilir özelliği nedir? | marka, renk, beden, kapasite, materyal, uyumluluk | Filter, variant, validation ve structured search | **FINAL SEPARATION — category değildir; profile implementation ayrıdır** |

Bir merchant birden fazla product L1 altında ürün satabilir. Bu nedenle merchant
sector ile product category ilişkisi future modelde many-to-many olabilir; sector
ürünün primary category'sini otomatik belirlemez.

### Category olmayan kavramlar — CANONICAL / FINAL SEPARATION

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

### Invariants — CANONICAL / FINAL ARCHITECTURE

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
5. `Oyuncak, Hobi & Müzik` split successor mapping'ini ayrı controlled runtime
   task'ında tasarla ve doğrula;
6. mevcut final JSON'u bu Phase A2'de yeniden yazma; schema/migration tasarımında
   backward-compatible adapter tanımla.

Bu bridge kararı verilmeden taxonomy'yi runtime'a deploy etmek identity drift riski
taşır.

## 6. Product assignment rules

### Primary category — CANONICAL / FINAL

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

Phase A1 product-owner review, previous 23-name L1 setini refine etti. Product Owner,
bu refinement sonucundaki customer-facing terminology ve müzik domain split'ini
Phase A2'de açıkça onayladı. Sonuç **24 L1 / CONFIRMED / FINAL / CANONICAL V1**'dir.

| Previous Phase A adı | Phase A1 action | Phase A2 final canonical adı | Gerekçe |
|---|---|---|---|
| Market & Gıda | **RENAME / terminology correction** | Gıda & İçecek | “Market” ürün ailesi değil satış kanalı/merchant formatıdır. |
| Moda & Giyim | **RENAME** | Giyim & Moda | Türkçe customer-facing adlandırma sırası. |
| Çanta & Giyim Aksesuarı | **RENAME / scope clarity** | Çanta & Aksesuar | Daha temiz müşteri adı; saat/takı ayrı L1'de kalır. |
| Yapı & Hırdavat | **RENAME / local scope** | Yapı, Hırdavat & Tesisat | Mahalle tesisatçısı/nalbur ürünlerinin discoverability'sini başlıkta görünür kılar. |
| Kişisel Bakım & Kozmetik | **RENAME** | Kozmetik & Kişisel Bakım | Product-owner tarafından seçilen customer-facing canonical sıra. |
| Bebek & Çocuk | **RENAME / boundary refinement** | Anne & Bebek | Çocuk giyimi, ayakkabısı, oyuncağı ve okul ürünü kendi fonksiyonel L1'lerine gider. |
| Oyuncak, Hobi & Müzik | **SPLIT** | Oyuncak & Hobi; Müzik & Enstrüman | Attribute, search intent, merchant type ve filter sözleşmeleri önemli ölçüde ayrıdır. |
| Pet Shop | **RENAME / mandatory terminology correction** | Evcil Hayvan Ürünleri | `Pet Shop` merchant type'tır; product node ürün ailesini ifade etmelidir. |
| Optik | **RENAME / clarity** | Gözlük & Optik | Customer-facing ürün kapsamını açıklar; regulated sınırlar Phase B/legal review'dedir. |

İsim değişikliği stable node identity'yi değiştirmez. Combined oyuncak/hobi/müzik
node'unun split successor mapping'i ayrı controlled runtime task gerektirir; bu belge
yeni runtime ID üretmez.

### Overlap audit — 24/24 reviewed

| Kritik sınır | Phase B boundary principle | Multi-category önleme kuralı |
|---|---|---|
| Elektronik ↔ Bilgisayar & Tablet | Telefon, giyilebilir teknoloji, ses/görüntü ve camera Elektronik; bilgisayar, tablet, core component, storage ve peripheral Bilgisayar & Tablet. | Ana cihaz fonksiyonu belirler; “akıllı” veya bağlantılı olmak tek başına Elektronik'e taşımaz. |
| Ev & Yaşam ↔ Züccaciye & Mutfak | Mobilya, ev tekstili, dekorasyon, düzenleme ve genel ev bakımı Ev & Yaşam; pişirme, hazırlama, servis ve gıda saklama Züccaciye & Mutfak. | Kullanıldığı oda değil ana işlev belirler; elektrikli appliance ayrıca Beyaz Eşya & Ev Aletleri'ne gider. |
| Giyim & Moda ↔ Çanta & Aksesuar ↔ Ayakkabı | Giyilen tekstil Giyim & Moda; taşınan/tamamlayıcı aksesuar Çanta & Aksesuar; footwear Ayakkabı. | Cinsiyet, beden, renk ve stil facet'tir; saat/takı kendi L1'inde kalır. |
| Anne & Bebek ↔ Giyim/Oyuncak/Ayakkabı/Kırtasiye | Bez, emzirme, beslenme, bakım, güvenlik ve taşıma Anne & Bebek; çocuk giysisi/ayakkabısı/oyuncağı/okul ürünü kendi fonksiyonel L1'ine gider. | Hedef yaş tek başına category ownership üretmez; yaş grubu facet olarak kalabilir. |
| Gözlük & Optik ↔ Sağlık & Medikal | Gözlük, çerçeve ve optik aksesuar Gözlük & Optik; genel ölçüm, takip, destek ve medikal cihaz Sağlık & Medikal. | Kontakt lens, numaralı ürün ve medical claim sınırı Phase B + legal policy review olmadan assignable sayılmaz. |

Diğer 19 L1'in boundary guard'ı aşağıdaki recommendation tablosunda kayıtlıdır.
Sınır vakaları satış kanalına veya merchant type'a göre değil ürünün ana fonksiyonuna
göre çözülür. Cross-discovery alias/attribute/collection ile sağlanır; ikinci primary
category oluşturulmaz.

## 10. Recommended L1 V1

**Durum: CONFIRMED — PRODUCT OWNER FINAL / CANONICAL V1.** Aşağıdaki 24 L1 adı ve
sırası kilitlidir. Bu karar tek başına current full-tree JSON/runtime state'ini
değiştirmez.

Tablodaki her L1 satırı bu ortak durumu taşır: **CONFIRMED — PRODUCT OWNER FINAL —
CANONICAL V1**.

| # | Final canonical L1 | Display-route candidate (identity değildir) | Boundary guard |
|---:|---|---|---|
| 1 | Gıda & İçecek | `gida-icecek` | Yenebilir/içilebilir perakende ürünü; `Market` merchant type'tır, category değildir. |
| 2 | Giyim & Moda | `giyim-moda` | Giyilen tekstil ürünü; gender/size/renk facet'tir. |
| 3 | Ayakkabı | `ayakkabi` | Ayakkabı türü; numara ve hedef cinsiyet facet'tir. |
| 4 | Çanta & Aksesuar | `canta-aksesuar` | Çanta, cüzdan, kemer, şemsiye ve moda aksesuarı; saat/takı burada değildir. |
| 5 | Elektronik | `elektronik` | Telefon, audio, camera ve consumer electronics; bilgisayar ayrı L1. |
| 6 | Bilgisayar & Tablet | `bilgisayar-tablet` | Bilgisayar/tablet, bileşen, depolama ve peripheral. |
| 7 | Beyaz Eşya & Ev Aletleri | `beyaz-esya-ev-aletleri` | Elektrikli dayanıklı/küçük ev cihazı; non-electric kitchenware ayrı. |
| 8 | Ev & Yaşam | `ev-yasam` | Mobilya, tekstil, dekorasyon, düzenleme ve ev tüketim ürünleri. |
| 9 | Züccaciye & Mutfak | `zuccaciye-mutfak` | Pişirme, servis, saklama ve non-electric kitchenware. |
| 10 | Yapı, Hırdavat & Tesisat | `yapi-hirdavat-tesisat` | Yapı, el aleti, bağlantı, elektrik ve tesisat ürünü; broad industrial channel değil. |
| 11 | Otomotiv & Motosiklet | `otomotiv-motosiklet` | Araç parçası/aksesuarı/bakım; fitment attribute'tur. |
| 12 | Kozmetik & Kişisel Bakım | `kozmetik-kisisel-bakim` | Bakım/kozmetik ürünü; salon hizmeti değildir. |
| 13 | Anne & Bebek | `anne-bebek` | Emzirme, beslenme, bez, bakım, güvenlik ve bebek taşıma; genel çocuk ürünü domaini değildir. |
| 14 | Oyuncak & Hobi | `oyuncak-hobi` | Oyuncak, oyun, koleksiyon ve fiziksel hobi; gerçek enstrüman ayrı L1. |
| 15 | Müzik & Enstrüman | `muzik-enstruman` | Müzik enstrümanı ve çalma/performans aksesuarı; oyuncak enstrüman Phase B'de ana fonksiyonla ayrılır. |
| 16 | Spor & Outdoor | `spor-outdoor` | Spor/outdoor ekipmanı ve specialist ürün; apparel sınırı ana fonksiyonla çözülür. |
| 17 | Kitap | `kitap` | Fiziksel kitap; tek primary shelf + multi-value genre facet yaklaşımı. |
| 18 | Kırtasiye & Ofis | `kirtasiye-ofis` | Kâğıt, yazım, dosyalama, sanat sarfı ve ofis ürünü. |
| 19 | Evcil Hayvan Ürünleri | `evcil-hayvan-urunleri` | Pet ürünü; `Pet Shop` merchant type'tır, canlı hayvan ve veteriner ilacı excluded. |
| 20 | Gözlük & Optik | `gozluk-optik` | Gözlük/optik ürün; regulated/contact-lens sınırı legal review ister. |
| 21 | Saat & Takı | `saat-taki` | Klasik saat ve takı; smart watch Elektronik'tedir. |
| 22 | Sağlık & Medikal | `saglik-medikal` | Sağlık/medikal ürün; claim/evidence ve policy fail-closed. |
| 23 | Çiçek & Bahçe | `cicek-bahce` | Çiçek, bitki ve yetiştirme/bahçe ürünü; bahçe el aleti ana kullanımına göre burada olabilir. |
| 24 | Hediyelik & Parti | `hediyelik-parti` | Fiziksel hediye/parti ürünü; organizasyon hizmeti ve seasonal state category değildir. |

Owner approval bu tablodaki L1 adlarını ve sırasını kilitler. Display-route candidate
değerleri stable identity değildir; existing V1 source slugs korunur ve runtime alias/
redirect kararı ayrı integration task'ında verilir.

Duplicate L1 name yoktur. `Market` ve `Pet Shop` Product Taxonomy L1 adı değildir.
Birleşik adlar kullanıcı tarafından birlikte aranan ve aynı attribute/merchant-entry
bağlamını paylaşan yakın domainlerle sınırlıdır; scope notları bütün 24 L1 için
boundary guard sağlar.

## 11. Demo category mapping

Bu eşleme conceptual/read-only'dir; Production/Development migration veya demo data
değişikliği yapılmaz.

| Current demo category | Final canonical L1 | Mapping | Not |
|---|---|---|---|
| Elektronik | Elektronik (`elektronik`) | Direct | Demo ürünün leaf'i sonraki controlled mapping çalışmasında doğrulanır. |
| Kırtasiye | Kırtasiye & Ofis (`kirtasiye-ofis`) | Rename/broaden | Demo `Defter` ürünü canonical `defter` leaf'ine conceptual olarak uygundur. |
| Gıda | Gıda & İçecek (`gida-icecek`) | Rename/broaden | İçerik L2/L3 leaf'e göre ayrıca sınıflandırılır. |
| Ayakkabı | Ayakkabı (`ayakkabi`) | Direct | Numara/renk/gender category değil facet olarak kalır. |

Dört demo category de exactly one canonical L1'e temiz eşlenir; hiçbir mapping
merchant-sector node'a veya multi-primary category'ye gitmez.

**Demo mapping state: CONFIRMED — PRODUCT OWNER FINAL / conceptual only.** Production
ve demo dataset migration'ı bu decision-lock görevinde yapılmaz.

## 12. Confirmed Merchant/Sector Scope Decisions

### Berber, Kuaför & Güzellik Salonu — CONFIRMED

Merchant/Sector Taxonomy future scope'una aşağıdaki ana başlık kaydedilmiştir:

- **Berber, Kuaför & Güzellik Salonu**
  - **Erkek Berberi**
  - **Kadın Kuaförü**
  - **Güzellik Salonu**

`Unisex Kuaför`: **ABSENT / DO NOT ADD / EKLENMEYECEK**. Bu hizmet sektörü Product Taxonomy L1
listesinde yer almaz. Bir salonun sattığı fiziksel şampuan, bakım veya kozmetik ürünü
ürünün kendi Product Taxonomy leaf'ine bağlanır; salon sector identity'si product
category olmaz.

Terminoloji örnekleri:

- `Market`, future Merchant/Sector Taxonomy'de işletme tipi olabilir; Product
  Taxonomy L1'i değildir.
- `Pet Shop`, future Merchant/Sector Taxonomy'de işletme tipi olabilir; Product
  Taxonomy karşılığı **Evcil Hayvan Ürünleri** proposalıdır.

Bu iki örnek full Merchant/Sector Taxonomy tasarımı değildir.

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
| Home projection | **PASS** | Availability-gated shortcut canonical 24 L1 registry'nin yerini almaz; sponsored ayrı ve etiketlidir. |

İstenen `docs/ESNAFTAVAR_CRITICAL_SCREEN_PILOT_V1.md` current main'de mevcut değildir;
bu yüzden o spesifik artefakt için görsel kabul iddiası yapılmaz. Mevcut canonical
`docs/ESNAFTAVAR_COMPONENT_LIBRARY_V1.md`, CategoryCard/CategoryRow'un dynamic taxonomy
ve availability sözleşmesini doğrular. Figma'ya bu görevde yazılmamış ve mevcut
Critical Screen Pilot davranışı değiştirilmemiştir.

## 14. Phase B1+B2 owner-final L2 locks

### Elektronik — 9 L2 / CONFIRMED — PRODUCT OWNER FINAL

1. Telefon & Aksesuarları
2. TV & Görüntü Sistemleri
3. Ses & Kulaklık
4. Fotoğraf & Kamera
5. Oyun Konsolu & Aksesuarları
6. Giyilebilir Teknoloji
7. Akıllı Ev & Güvenlik
8. Güç, Şarj & Bağlantı
9. Elektronik Bileşenler

Canonical karar belgesi:
`docs/TAXONOMY_ELECTRONICS_L2_PROPOSAL.md`. Exact ad/sıra `9/9`, duplicate `0`.

### Bilgisayar & Tablet — 11 L2 / CONFIRMED — PRODUCT OWNER FINAL

1. Dizüstü Bilgisayar
2. Masaüstü Bilgisayar
3. Tablet
4. E-Kitap Okuyucu
5. Monitör
6. Bilgisayar Bileşenleri
7. Veri Depolama
8. Klavye, Mouse & Çevre Birimleri
9. Bilgisayar Aksesuarları
10. Yazıcı, Tarayıcı & Sarf Malzemeleri
11. Ağ & İnternet Ürünleri

Canonical karar belgesi:
`docs/TAXONOMY_COMPUTER_TABLET_L2_PROPOSAL.md`. Exact ad/sıra `11/11`, duplicate
`0`.

### Canonical cross-domain boundary

- PC-specific/computer-primary cihaz veya aksesuar **Bilgisayar & Tablet**;
  general consumer electronics **Elektronik** kapsamındadır.
- Arduino/ESP ve general electronics development board **Elektronik → Elektronik
  Bileşenler**; Raspberry Pi/SBC **Bilgisayar & Tablet → Bilgisayar Bileşenleri**.
- Webcam, computer dock/USB hub ve PC-first gaming peripheral **Bilgisayar &
  Tablet**; console ve console-first controller **Elektronik → Oyun Konsolu &
  Aksesuarları**.
- Generic headphone/audio **Elektronik → Ses & Kulaklık**; generic powerbank,
  cable ve charging adapter **Elektronik → Güç, Şarj & Bağlantı**;
  phone-model-specific case/protector/accessory **Telefon & Aksesuarları**.
- Smart bulb/plug/connected lock **Akıllı Ev & Güvenlik**; camera drone
  **Fotoğraf & Kamera**, toy drone **Oyuncak & Hobi**; vehicle-fitment electronics
  **Otomotiv & Motosiklet**; robot vacuum/klima/coffee machine **Beyaz Eşya & Ev
  Aletleri**; classic watch **Saat & Takı**, smartwatch **Giyilebilir Teknoloji**.
- Gaming laptop/desktop/monitor/keyboard/mouse kendi functional computer L2'sinde;
  `gaming` facet/discovery signal olarak kalır.
- Toner/kartuş ve 3D printer/filament **Yazıcı, Tarayıcı & Sarf
  Malzemeleri**; kâğıt, etiket, termal rulo ve general office consumable
  **Kırtasiye & Ofis** kapsamındadır.
- Rack/enterprise server exact L3/L4 boundary ve assignability **TBD**; bank/payment
  POS terminal **TBD / consumer taxonomy'ye atanmamış** kalır.
- Brand, color, size, capacity, CPU/GPU, connector, wattage, Bluetooth, 5G, refresh
  rate, OS ve compatibility facet/attribute'tur; L2 category değildir.

Bu kararlar L2 omurgasını kilitler; full L3/L4 node, leaf/assignability, ID/slug,
JSON reconciliation, migration veya runtime davranışı üretmez.

## 15. Open owner decisions

24 L1 ad/sıra kararı **RESOLVED — CONFIRMED — PRODUCT OWNER FINAL** durumundadır.
Aşağıdaki runtime, policy ve governance kararları açık kalır:

1. **Rename/split identity mapping — PROPOSED / integration gate:** Current immutable
   V1 source identity'leri korunurken dokuz rename ve combined oyuncak/hobi/müzik
   split'i hangi successor mapping'lerle yayınlanacak?
2. **Stable ID bridge — PROPOSED / integration gate:** Current immutable V1 source
   slug ile future immutable opaque `id` ve mutable display slug nasıl bağlanacak?
3. **Policy governance — TBD:** `REGULATED` ve `LEGAL_REVIEW_REQUIRED` node'larda belge,
   moderator, audit/recall ve approval sahibi kim olacak?
4. **Sensitive domain permanence — TBD + legal:** Current excluded domainler kalıcı mı,
   yoksa yalnız V1 launch exclusion mı? Relaxation otomatik yapılamaz.
5. **Attribute profiles — TBD:** İlk typed `attribute_profile_id` pilotları ve value
   registry owner'ı kim olacak?
6. **Google mapping — TBD:** Google ID/path mapping hangi release ihtiyacında ve hangi
   taxonomy snapshot/version ile üretilecek?
7. **Merchant-sector breadth — TBD:** Teyit edilen salon başlığı dışında shop type
   L1/L2 seti ve many-to-many product recommendation kuralları ayrı çalışmada tasarlanmalı.
8. **Service capabilities — TBD:** Booking, hizmet kataloğu/fiyatı, çalışan ve slot
   modeli bu taxonomy kararından bağımsız owner review ister.
9. **Category request governance — TBD:** Merchant talebi, taxonomy review SLA,
   deprecation/replacement onayı ve sürüm yayın sahibi belirlenmeli.

Phase A2 owner approval product decision'ı kilitler; current V1.0.0 full tree, JSON,
runtime, Production veya Development state'ini bu dokümantasyon görevi değiştirmez.

## 16. Next-phase plan

Phase A ve owner-final Elektronik/Bilgisayar & Tablet L2 omurgaları tamamlanmıştır.
Sıradaki taxonomy tasarım çalışması controlled L3/L4'tür. Current main full
V1.0.0 tree taşır; onu decision-lock görevinde paralel ağaçla çoğaltmak veya
yeniden yazmak yasaktır.

1. Integration/taxonomy owner final 24 L1 decision lock'ını review edip main'e
   entegre etti.
2. Rename ve split successor mapping'i current V1.0.0 tree ile reconcile edilir;
   stable identity'ler korunur.
3. **Elektronik** `9` L2 ve **Bilgisayar & Tablet** `11` L2 owner-final olarak
   entegre edildi; ayrı controlled turda L3/L4 adı, sırası, variable-depth leaf ve
   assignability tasarlanır.
4. Runtime öncesi current source slug → stable opaque ID bridge kesinleştirilir.
5. Ayrı tek-sahipli implementation design; taxonomy schema/migration, deterministic
   ID mapping, read path ve seed planını hazırlar. Bu adım remote apply değildir.
6. Merchant/Sector Taxonomy ayrı lane'de, Product Taxonomy node'larını tekrar kullanmadan
   tasarlanır; salon hizmet capability'leri owner kararı gelmeden modellenmez.

`TAXONOMY_ARCHITECTURE: PASS`

`WAVE_15_PHASE_A_INTEGRATION: PASS`

`CANONICAL_L1_LOCK: PASS`

`L1_CANONICAL_OWNER_APPROVAL: FINAL`

`L1_COUNT: 24`

`CANONICAL_L1_COUNT: 24`

`PRODUCT_MERCHANT_SEPARATION: PASS`

`PRODUCT_MERCHANT_FACET_SEPARATION: PASS`

`MERCHANT_SECTOR_SCOPE_DECISION_RECORDED: YES`

`DEMO_CATEGORY_MAPPING_READY: YES`

`READY_FOR_PHASE_A_INTEGRATION: COMPLETED`

`READY_FOR_TAXONOMY_PHASE_B: COMPLETED`

`WAVE_15_B1_B2_INTEGRATION: PASS`

`ELECTRONICS_L2_CANONICAL: PASS`

`ELECTRONICS_L2_COUNT: 9`

`COMPUTER_TABLET_L2_CANONICAL: PASS`

`COMPUTER_TABLET_L2_COUNT: 11`

`CROSS_DOMAIN_BOUNDARY: PASS`

`L3_L4_STATE: NOT_STARTED`

`RUNTIME_TAXONOMY_IMPLEMENTED: NO`

`READY_FOR_L3_L4_DESIGN: YES`
