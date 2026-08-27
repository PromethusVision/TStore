# EsnaftaVar Canonical Taxonomy — Telefon & Aksesuarları L3/L4 Proposal

**Wave:** 15 / Phase C1

**Belge tarihi:** 27 Ağustos 2026

**Canonical path:** **Elektronik → Telefon & Aksesuarları — PRODUCT OWNER FINAL**

**Karar durumu:** **PROPOSED FOR OWNER REVIEW**

**Kapsam:** Yalnız owner-final `Telefon & Aksesuarları` L2 altındaki L3/L4,
leaf assignment, category/facet ayrımı, synonym ve ürün sınırları. Runtime taxonomy
JSON'u, stable ID/slug, DB, migration, search, Flutter, Figma, Production ve
Development değiştirilmez.

> Bu belge canonical path'i değiştirmez ve önerilen alt ağacı FINAL ilan etmez.
> Current `v1.0.0` full-tree artefaktı yalnız reconciliation girdisi olarak salt
> okunur incelenmiştir; bu görevde yeniden yazılmamıştır.

## 1. Scope

Amaç; Türkiye'deki müşteri diline ve yerel telefoncu envanterine uygun, uzun ömürlü
ve artificial depth üretmeyen bir Telefon & Aksesuarları ürün ağacı önermektir.

Canonical mimari kuralları:

- Her ürün tam olarak bir primary canonical leaf'e atanır.
- Maksimum yol `L1 → L2 → L3 → L4` olur; L5 yoktur.
- L3 doğal olarak yeterliyse doğrudan leaf olur.
- Marka, model, işletim sistemi, renk, kapasite, bağlantı standardı ve uyumluluk
  category değildir.
- Merchant/telefoncu türü, onarım hizmeti, kampanya ve ürün condition'ı category
  ownership'i üretmez.
- Generic güç/şarj/bağlantı ürünleri owner-final ayrı L2 sınırına uyar.
- Search synonym'i ikinci primary category değildir.

### Bu fazın dışında

- Node ID/slug/sort order ve current JSON successor mapping'i
- Attribute registry veya search implementation'ı
- Merchant/Service Taxonomy implementation'ı
- Policy workflow, moderation ve hukuki onay sistemi
- Flutter, Figma, DB, migration veya remote apply

## 2. Sources

Araştırma 27 Ağustos 2026 tarihinde resmi ve kamuya açık kaynaklardan yeniden
doğrulandı. Pazar yeri ağaçları birebir kopyalanmadı; customer language, leaf
granularity, compatibility facet'i ve over-fragmentation riski için karşılaştırıldı.

Internal source-of-truth:

- [`ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md`](ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md)
- [`TAXONOMY_ELECTRONICS_L2_PROPOSAL.md`](TAXONOMY_ELECTRONICS_L2_PROPOSAL.md)
- [`ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md`](ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md)
- `docs/data/esnaftavar_category_taxonomy_v1_final.json` — salt okunur legacy
  reconciliation girdisi

| Kaynak | Doğrulanan sinyal | EsnaftaVar sonucu / sınırlama |
|---|---|---|
| [Google Product Taxonomy — official text](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center category contract](https://support.google.com/merchants/answer/6324436?hl=en) | Official snapshot; Mobile Phones, Mobile Phone Cases, Stands, Replacement Parts, Camera Accessories ve SIM Cards için ayrı path'ler taşır. Google bir ürün için ana işlevi tanımlayan en spesifik tek category'yi önerir. | Tek-leaf ve main-function yaklaşımı alınır. Snapshot header'ı `2021-09-21` olduğundan 2026 Türkiye müşteri dili veya EsnaftaVar L1/L2 ownership'i için tek başına güncel kanıt değildir. Contract/prepaid/unlocked ayrımları ürün tipinden çok teklif/hizmet sözleşmesine bağlı olduğundan kopyalanmaz. |
| [Trendyol live Telefon Aksesuarları](https://www.trendyol.com/telefon-aksesuarlari-x-c1190), [category-tree contract](https://developers.trendyol.com/docs/trendyol-kategori-listesi-getcategorytree) ve [category attributes V2](https://developers.trendyol.com/docs/kategori-%C3%B6zellik-listesi-v2) | Kapak & Kılıf, Ekran Koruyucu, Kamera Lens Koruyucu ve benzeri müşteri terimleri görünür; marketplace aynı browse alanına generic güç, kablo ve şarj cihazlarını da alır. API yalnız leaf'e ürün girişini, attribute sözleşmesi ise category'den ayrı özellikleri gösterir. | Kılıf/koruyucu dili güçlü girdidir. Generic powerbank/kablo/şarj yığılması owner-final EsnaftaVar sınırına aykırıdır ve bilinçli olarak reddedilir. Marka/model filtreleri node yapılmaz. |
| [Hepsiburada live telefon ürün örneği](https://www.hepsiburada.com/arazon) ve [official catalog contract](https://developers.hepsiburada.com/tr/companies/hepsiburada?guide=katalog-onemli-bilgiler&product=katalog-urun-entegrasyonu&view=guide) | Live ürün yüzeyi Ekran Koruyucular, Kılıflar ve Diğer Telefon Aksesuarları tiplerini; `Uyumlu Model` ve renk filtrelerini ayrı gösterir. Catalog contract leaf, active/available state ve category-specific attribute yaklaşımı taşır. | Uyumlu modelin category değil facet olması desteklenir. `Diğer Telefon Aksesuarları` gibi catch-all EsnaftaVar canonical leaf'i olarak alınmaz. Public live örnek tam ve sabit hierarchy kanıtı değildir. |
| [n11 live Telefon & Aksesuarları](https://www.n11.com/telefon-ve-aksesuarlari), [Cep Telefonu Aksesuarları](https://www.n11.com/telefon-ve-aksesuarlari/cep-telefonu-aksesuarlari), [official category tree](https://developer.n11.com/documentation/n11-marketplace-entegrasyonu/kategori-agaci-listeleme/) ve [attributes](https://developer.n11.com/documentation/n11-marketplace-entegrasyonu/kategori-ozellikleri-listeleme/) | Cep Telefonu, Tuşlu Telefon, Aksesuarlar ve Yedek Parça customer-facing ayrımları görünür; model ölçüsü ve renk gibi uyumluluk/filter sinyalleri ayrıca kullanılır. Marketplace SIM/hat/paket ve yenilenmiş/outlet merchandising'ini de aynı department'a taşır. | Akıllı/tuşlu cihaz ayrımı ile spare-part domain'i desteklenir. SIM/hat/paket service-policy alanı ve yenilenmiş/outlet condition'ı canonical product node yapılmaz. Araç fitment ürünü Otomotiv sınırına uyar. |
| [Amazon Türkiye seller category list](https://satis.amazon.com.tr/satis) ve [live phone-case browse example](https://www.amazon.com.tr/b?node=13710307031) | Cep telefonu/elektronik aksesuarları ayrı satış alanlarıdır. Case browse; model compatibility, material, form factor ve protection features gibi çok sayıda filtre taşır. | Kılıf ayrı leaf olmaya yeterli müşteri niyeti taşır; bumper/cüzdan/malzeme/renk/model gibi uzun kuyruk L4 yapılmaz, facet kalır. Amazon'un multi-category listing modeli EsnaftaVar'ın exactly-one-primary-leaf kuralı değildir. |

### Research synthesis

1. Telefon cihazları ile aksesuarları aynı final L2 altında kalabilir; L3 cihaz ve
   aksesuar niyetini temiz ayırır.
2. Akıllı telefon ile tuşlu telefon; farklı kullanıcı niyeti, merchant şeması ve
   teknik facet profili nedeniyle anlamlı L4 product type'larıdır.
3. Kılıf, ekran koruyucu ve kamera lens koruyucu ayrı, yüksek niyetli leaf'lerdir;
   malzeme, form, brand ve exact model alt category değildir.
4. Telefon-first tutucu/stand, çekim aksesuarı ve stylus ayrı leaf olabilir; araç,
   camera-first veya tablet-first ürünler ana işleve göre diğer L1/L2'ye gider.
5. Generic şarj ekosistemi marketplace browse alışkanlığına rağmen bu dalın dışında
   kalır; yalnız phone-model-specific charging accessory burada tutulur.
6. Fiziksel yedek parça ürün olabilir, fakat repair service değildir ve güvenlik,
   authenticity, uyumluluk ile visibility politikası olmadan normal aksesuar gibi
   yayımlanmamalıdır.

## 3. L3 proposal

**Önerilen L3 sayısı: 9.** Exact sıra owner review'a tabidir.

| # | Proposed L3 | Yapısal rol | Leaf? | Kapsam / gerekçe |
|---:|---|---|---|---|
| 1 | **Cep Telefonları** | Device group | Hayır | Akıllı ve tuşlu cihazları ortak cihaz girişinde toplar; gerçek product type ayrımı L4'tedir. |
| 2 | **Telefon Kılıfları** | Product type | **Evet** | Modele/form-factor'a göre fiziksel koruma sağlayan kılıf, kapak ve battery-case olmayan koruma gövdeleri. Alt türler facet'tir. |
| 3 | **Ekran Koruyucular** | Product type | **Evet** | Telefon ekranına uygulanan cam/film/privacy koruyucu. Malzeme ve coverage facet'tir. |
| 4 | **Kamera Lens Koruyucuları** | Product type | **Evet** | Telefonun kamera lens grubuna takılan koruma ürünü. Fotoğraf lens/filter aksesuarı değildir. |
| 5 | **Telefon Tutucu, Stand & Askıları** | Product type family | **Evet** | Phone-first masa standı, grip/yüzük, askı/kordon ve araç fitment'i gerektirmeyen tutucu. |
| 6 | **Telefon Modeline Özgü Şarj Aksesuarları** | Compatibility-bound product family | **Evet** | Exact telefon/model ailesi için tasarlanmış charging case, cradle veya proprietary dock. Generic charger/kablo/powerbank değildir. |
| 7 | **Telefon Kamera & Çekim Aksesuarları** | Product type family | **Evet** | Phone-first selfie stick, telefon gimbalı, clip-on telefon lensi ve phone-first çekim aparatı. |
| 8 | **Telefon Kalemleri** | Product type | **Evet** | Telefon-first veya exact telefon modeliyle çalışan stylus/dokunmatik kalem. Tablet-first/generic computing stylus burada değildir. |
| 9 | **Telefon Yedek Parçaları** | Controlled spare-part group | Hayır | Ayrı satılan fiziksel telefon replacement part'larını toplar; servis emeğini kapsamaz ve policy-gated L4 leaf'lere açılır. |

### Neden daha fazla L3 yok?

- `Telefon Kabloları` açılmaz: kablo çoğunlukla connector/device-family facet'li
  generic bağlantı ürünüdür ve **Güç, Şarj & Bağlantı** L2'sine gider.
- `Telefon Şarj Cihazları` açılmaz: generic adaptör, kablosuz pad ve powerbank aynı
  owner-final L2 sınırına gider.
- `Telefon Hafıza Ürünleri` açılmaz: memory card/removable storage
  **Bilgisayar & Tablet → Veri Depolama** kapsamındadır.
- `Android Telefon`, `iOS Telefon`, marka veya model ailesi açılmaz: bunlar typed
  facet/compatibility verisidir.
- `Diğer Telefon Aksesuarları` açılmaz: bilinmeyen ürün için fail-open catch-all
  yerine taxonomy review gerekir.

## 4. L4 proposal where needed

Yalnız iki L3 gerçek product-type ayrımı gerektirir. Diğer yedi L3'ün altına yapay
L4 eklenmez.

| Parent L3 | # | Proposed L4 | Leaf? | Gerekçe |
|---|---:|---|---|---|
| Cep Telefonları | 1 | **Akıllı Telefonlar** | **Evet** | App/OS, storage, RAM, screen ve network profiliyle güçlü customer intent. |
| Cep Telefonları | 2 | **Tuşlu Telefonlar** | **Evet** | Feature-phone kullanım niyeti, form, input ve teknik profil akıllı telefondan anlamlı biçimde farklıdır. |
| Telefon Yedek Parçaları | 3 | **Telefon Bataryaları** | **Evet / policy-gated** | Physical replacement battery; lithium/safety, provenance ve exact compatibility kanıtı gerekir. |
| Telefon Yedek Parçaları | 4 | **Ekran & Dokunmatik Modülleri** | **Evet / controlled** | Replacement display/digitizer assembly; ekran koruyucu değildir. |
| Telefon Yedek Parçaları | 5 | **Şarj Soketi & Bağlantı Parçaları** | **Evet / controlled** | Dahili port, daughterboard ve replacement connector assembly. Generic charging cable değildir. |
| Telefon Yedek Parçaları | 6 | **Kamera Modülleri** | **Evet / controlled** | Dahili replacement camera module; clip-on çekim aksesuarı veya lens koruyucu değildir. |
| Telefon Yedek Parçaları | 7 | **Flex Kablo & Dahili Parçalar** | **Evet / controlled** | Button/sensor/speaker flex ve diğer açıkça tanımlı dahili replacement assembly; catch-all açıklamasıyla yayımlanamaz. |

**Önerilen L4 sayısı: 7.** `Android`, `iOS`, `5G`, `dual SIM`, `128 GB`, brand,
model, kılıf formu, koruyucu materyali veya connector tipi L4 değildir.

### Phone-device structure decision

**Öneri:** `Cep Telefonları` L3 non-leaf; `Akıllı Telefonlar` ve `Tuşlu Telefonlar`
L4 leaf olsun. Bu ayrım yalnız teknik attribute değildir: müşteri arama niyeti,
girdi şeması ve yerel stok/mağaza sunumu farklıdır. Buna karşılık Android/iOS,
5G, storage, RAM, SIM configuration ve brand aynı product type içindeki facet'tir.

`Yenilenmiş`, `outlet`, `teşhir`, `ikinci el`, `kontratlı`, `peşin` veya `taksitli`
telefon category değildir; condition, warranty, offer veya service/contract verisidir.

## 5. Leaf-node assignments

Her proposed product node ya doğrudan L3 leaf'tir ya da L4 leaf'e iner. L3 container'a
ürün atanmaz.

| # | Proposed canonical leaf path | Level | Assignment / policy proposal | Representative products |
|---:|---|---:|---|---|
| 1 | Telefon & Aksesuarları → Cep Telefonları → **Akıllı Telefonlar** | L4 | Assignable / normal product | Smartphone |
| 2 | Telefon & Aksesuarları → Cep Telefonları → **Tuşlu Telefonlar** | L4 | Assignable / normal product | Feature phone, klasik tuşlu cep telefonu |
| 3 | Telefon & Aksesuarları → **Telefon Kılıfları** | L3 | Assignable / normal product | Silikon kılıf, kapaklı/cüzdan kılıf, bumper, su geçirmez phone pouch |
| 4 | Telefon & Aksesuarları → **Ekran Koruyucular** | L3 | Assignable / normal product | Temperli cam, koruyucu film, privacy screen protector |
| 5 | Telefon & Aksesuarları → **Kamera Lens Koruyucuları** | L3 | Assignable / normal product | Telefon kamera lens koruma camı/halkası |
| 6 | Telefon & Aksesuarları → **Telefon Tutucu, Stand & Askıları** | L3 | Assignable / normal product | Masa standı, telefon grip/yüzük, boyun/bilek askısı |
| 7 | Telefon & Aksesuarları → **Telefon Modeline Özgü Şarj Aksesuarları** | L3 | Assignable / compatibility-critical | Model-specific battery case, charging cradle/dock |
| 8 | Telefon & Aksesuarları → **Telefon Kamera & Çekim Aksesuarları** | L3 | Assignable / normal product | Phone-first selfie stick, telefon gimbalı, clip-on lens |
| 9 | Telefon & Aksesuarları → **Telefon Kalemleri** | L3 | Assignable / compatibility-critical | Phone-specific active/passive stylus |
| 10 | Telefon & Aksesuarları → Telefon Yedek Parçaları → **Telefon Bataryaları** | L4 | Proposed controlled assignment; `REGULATED`/safety review | Replacement phone battery |
| 11 | Telefon & Aksesuarları → Telefon Yedek Parçaları → **Ekran & Dokunmatik Modülleri** | L4 | Proposed controlled assignment; compatibility/provenance evidence | LCD/OLED/digitizer assembly |
| 12 | Telefon & Aksesuarları → Telefon Yedek Parçaları → **Şarj Soketi & Bağlantı Parçaları** | L4 | Proposed controlled assignment; compatibility/provenance evidence | Charging-port flex/daughterboard |
| 13 | Telefon & Aksesuarları → Telefon Yedek Parçaları → **Kamera Modülleri** | L4 | Proposed controlled assignment; compatibility/provenance evidence | Front/rear replacement camera module |
| 14 | Telefon & Aksesuarları → Telefon Yedek Parçaları → **Flex Kablo & Dahili Parçalar** | L4 | Proposed controlled assignment; exact part type required | Button/sensor/speaker flex, internal assembly |

**Toplam proposed leaf: 14** — `7` direct L3 leaf + `7` L4 leaf.

`Cep Telefonları` ve `Telefon Yedek Parçaları` non-leaf container'dır; doğrudan
ürün assignment kabul etmez.

## 6. Generic vs phone-specific boundary

Owner-final test: Ürün yalnız telefon kategorisine değil, **exact telefon modeli veya
telefon-first fiziksel forma** mı bağlı? Hayırsa generic/cross-device L2'ye gider.

| Ürün | Canonical placement | Boundary rule |
|---|---|---|
| Generic powerbank | Elektronik → **Güç, Şarj & Bağlantı** | Telefonla kullanılabilmesi phone-specific ownership üretmez. |
| Generic USB-C, Lightning, Micro-USB veya çoklu kablo | Elektronik → **Güç, Şarj & Bağlantı** | Connector/protocol ve supported devices facet'tir. `Lightning` tek başına exact phone-model specificity değildir. |
| Generic duvar tipi şarj adaptörü | Elektronik → **Güç, Şarj & Bağlantı** | Wattage/protocol/device compatibility facet'tir. |
| Multi-device kablosuz şarj pedi/standı | Elektronik → **Güç, Şarj & Bağlantı** | Telefon, kulaklık ve saat gibi birden fazla device family'yi şarj eder. |
| Exact modele/form ailesine göre üretilmiş battery case | Telefon & Aksesuarları → **Telefon Modeline Özgü Şarj Aksesuarları** | Charging işlevi fiziksel phone compatibility'ye gömülüdür. |
| Exact modele özgü charging cradle/dock | Telefon & Aksesuarları → **Telefon Modeline Özgü Şarj Aksesuarları** | Başka consumer device family'de generic kullanılamaz. |
| Replacement phone battery | Telefon & Aksesuarları → Telefon Yedek Parçaları → **Telefon Bataryaları** | Şarj accessory değil, dahili replacement part'tır. |
| Vehicle-only phone charger veya mount | **Otomotiv & Motosiklet** | Araç fitment'i, sabit montajı veya araç elektrik sistemi ana şemadır. |
| Generic headphone/earbuds | Elektronik → **Ses & Kulaklık** | Telefon compatibility'si audio ownership'i değiştirmez. |
| Memory card | Bilgisayar & Tablet → **Veri Depolama** | Telefonla kullanılabilmesi storage product type'ını değiştirmez. |

Phone-model-specific olma iddiası title metniyle değil structured compatibility ve
ürünün fiziksel/elektriksel tasarımıyla doğrulanmalıdır. Kanıt yoksa ürün bu dala
fail-open atanmaz.

## 7. Repair/spare-part boundary

### Recommendation

Fiziksel, ayrı satılan replacement part Product Taxonomy'de kalabilir; fakat normal
consumer-installable accessory gibi sunulmamalıdır. `Telefon Yedek Parçaları` bu
nedenle beş kontrollü L4 leaf taşır.

| Sınıf | Örnek | Taxonomy davranışı |
|---|---|---|
| Consumer-installable accessory | Kılıf, screen protector, phone stand | İlgili normal accessory leaf'ine atanır; repair part değildir. |
| Physical technician part | Dahili batarya, display module, charging port, camera module, flex cable | Yedek parça L4 leaf'ine; exact part number/model compatibility, provenance, condition ve safety evidence ile kontrollü assignment. |
| Repair consumable/tool | Yapıştırıcı, lehim sarfı, açma aparatı, universal repair tool | Telefon product type'ı değildir; ana işlevine göre Hırdavat/Elektronik Bileşenler review'ı gerekir. |
| Repair labor/service | Ekran değişimi, batarya değişimi, port onarımı, yazılım kurulumu | **Product Taxonomy dışında**; future Merchant/Service Taxonomy/capability alanıdır. |

Installability product identity'yi tek başına belirlemez. Physical part katalog ürünü
olabilir; montaj emeği ise ürün değildir. Bir servis ilanı yedek parça leaf'ine ürün
olarak girilemez. Parça + montaj paketi ana işlevi hizmetse Service Taxonomy review'ına
gider; içindeki fiziksel parça ayrıca canonical product olabilir.

### Safety and authenticity proposal

- Telefon bataryaları: `REGULATED`/hazmat ve safety review; chemistry, capacity,
  voltage, compatibility, provenance ve taşıma kuralları gerekir.
- Diğer internal parçalar: compatibility-critical; OEM/original/aftermarket durumu,
  part number, condition ve warranty structured evidence olmalıdır.
- Counterfeit veya doğrulanamayan `orijinal` claim'i category alanıyla çözülemez.
- Public customer browse visibility ve hangi merchant'ların assign edebileceği owner,
  legal ve operations kararı gelmeden FINAL değildir.
- `Flex Kablo & Dahili Parçalar` çıplak catch-all değildir; exact component type ve
  compatible model olmadan yayınlanamaz.

## 8. Product vs service boundary

| Alan | Proposal state | Gerekçe |
|---|---|---|
| Fiziksel boş SIM eject tool | **TBD / dedicated node yok** | Tek başına L3 açacak coverage kanıtı yoktur; category request ile review edilir veya ilgili ürünle bundle component'i olarak kalır. |
| Physical SIM starter card | **LEGAL_REVIEW_REQUIRED / normal product leaf yok** | Fiziksel kart carrier activation, kimlik doğrulama ve telekom service contract'ından ayrı düşünülemez. |
| eSIM activation/QR | **EXCLUDED FROM PRODUCT TAXONOMY** | Digital service/credential'dır; fiziksel retail product değildir. |
| Hat, tarife, paket, kontör/top-up | **EXCLUDED FROM PRODUCT TAXONOMY** | Telecom service/contract veya stored-value işlemidir. |
| Cihaz sigortası/uzatılmış garanti | **EXCLUDED FROM PRODUCT TAXONOMY** | Financial/service contract'tır; phone product node değildir. |
| Telefon onarım/kurulum hizmeti | **EXCLUDED FROM PRODUCT TAXONOMY** | Merchant capability/service taxonomy konusudur. |

Google ve n11'de SIM/prepaid/plan browse ayrımlarının bulunması EsnaftaVar için
otomatik inclusion üretmez. Türkiye telekom mevzuatı, activation/KYC, ödeme ve
consumer protection modeli ayrı owner/legal review olmadan tasarlanmaz.

## 9. Facet profiles

Facet'ler implementation değildir; future typed `attribute_profile_id` tasarımına
girdi sağlar. Hiçbiri category node değildir.

| Proposed leaf/family | Required/strong facet candidates | Optional/discovery facets |
|---|---|---|
| Akıllı Telefonlar | brand, model, operating system, storage, RAM, screen size, network generation, SIM configuration | color, connector, battery capacity, eSIM support, NFC, warranty, condition |
| Tuşlu Telefonlar | brand, model, network generation, SIM configuration, screen size, connector | color, battery capacity, radio, camera presence, ruggedness, warranty, condition |
| Telefon Kılıfları | compatible brand/model, form factor, material | color, MagSafe compatibility, card slot, stand, protection rating, waterproofing, pattern |
| Ekran Koruyucular | compatible brand/model, protector material/type, coverage | privacy, anti-glare, hardness claim, border color, installation applicator |
| Kamera Lens Koruyucuları | compatible brand/model, material, covered lens set | color, installation method, ring/full-cover form |
| Telefon Tutucu, Stand & Askıları | product subtype, mounting/attachment method, supported device dimensions/weight | adjustability, MagSafe compatibility, material, color, rotation |
| Telefon Modeline Özgü Şarj Aksesuarları | compatible brand/model, accessory subtype, connector/protocol, input/output wattage | MagSafe/Qi compatibility, capacity, color, included cable |
| Telefon Kamera & Çekim Aksesuarları | accessory subtype, supported device dimensions, mount/interface | stabilization axes, extension length, remote protocol, light, color |
| Telefon Kalemleri | compatible brand/model, active/passive type, protocol | pressure levels, tilt, charging method, tip type, color |
| Telefon Yedek Parçaları | exact compatible brand/model, part type, part number, provenance/OEM status, condition | color, revision, warranty, included adhesive/tools |
| Telefon Bataryaları ek güvenlik profili | chemistry, nominal voltage, rated/typical capacity, part number, safety evidence | manufacture date, cycle state, transport classification |

### Explicit category olmayan değerler

- Apple, Samsung, Xiaomi ve diğer tüm markalar
- Android, iOS ve diğer işletim sistemleri
- 5G/4G, dual SIM, eSIM support, Bluetooth, NFC, Wi-Fi
- 128 GB, 8 GB RAM, wattage, mAh ve ekran boyutu
- USB-C, Lightning, Micro-USB, MagSafe ve Qi
- siyah/beyaz/şeffaf, materyal, desen ve finish
- exact phone model, model year ve compatibility
- yenilenmiş/outlet/teşhir/ikinci el condition'ı

## 10. Synonyms

Controlled synonym/alias listesi canonical display adın yerini almaz. Brand, model,
attribute, typo ve promotional term synonym registry'ye yazılmaz.

| Canonical scope | Controlled synonym / alias hints | Guard |
|---|---|---|
| Cep Telefonları | cep telefonu, telefon, mobil telefon | `telefon` sabit hat/aksesuar context'iyle disambiguate edilir. |
| Akıllı Telefonlar | akıllı telefon, smartphone, akıllı cep telefonu | Android/iOS ve brand facet'tir. |
| Tuşlu Telefonlar | tuşlu telefon, tuşlu cep telefonu, klasik telefon, feature phone | `eski telefon` condition/age sinyalidir, synonym değildir. |
| Telefon Kılıfları | telefon kılıfı, cep telefonu kılıfı, telefon kabı, telefon kapağı, phone case, case | Model adı compatibility index'inden gelir. |
| Ekran Koruyucular | ekran koruyucu, cam koruyucu, kırılmaz cam, temperli cam, ekran filmi | `hayalet/privacy` product feature facet'tir. |
| Kamera Lens Koruyucuları | kamera lens koruyucu, lens koruma camı, kamera koruma halkası | Camera filter/lens accessory ile karıştırılmaz. |
| Telefon Tutucu, Stand & Askıları | telefon tutucu, telefon standı, telefon yüzüğü, telefon askısı, telefon kordonu | Vehicle-only mount Otomotiv'e gider; marka terimi synonym değildir. |
| Telefon Modeline Özgü Şarj Aksesuarları | şarjlı kılıf, battery case, telefon şarj standı, charging cradle | `şarj aleti`, `kablo`, `powerbank` generic branch synonym'idir; buraya yönlenmez. |
| Telefon Kamera & Çekim Aksesuarları | selfie çubuğu, selfie stick, telefon gimbalı, telefon lensi, clip-on lens | Camera-first tripod/gimbal Fotoğraf & Kamera'ya gider. |
| Telefon Kalemleri | telefon kalemi, dokunmatik kalem, stylus, akıllı telefon kalemi | Tablet kalemi Bilgisayar & Tablet'e gider. |
| Telefon Bataryaları | telefon bataryası, cep telefonu pili, replacement phone battery | `powerbank` synonym değildir. |
| Ekran & Dokunmatik Modülleri | telefon ekran modülü, yedek telefon ekranı, display module, digitizer | `ekran koruyucu` synonym değildir. |
| Şarj Soketi & Bağlantı Parçaları | telefon şarj soketi, charging port, dock connector flex | Generic cable/adapter synonym değildir. |
| Kamera Modülleri | telefon kamera modülü, replacement camera module | Clip-on lens/koruyucu synonym değildir. |
| Flex Kablo & Dahili Parçalar | flex kablo, fleks kablo, dahili telefon parçası | Exact part type olmadan broad search sonucu assign edilemez. |

Proposed search precedence: exact canonical name > exact semantic synonym > alias >
normalized token. Typo/fuzzy ve brand/model matching search engine/structured index
katmanında ölçülür; synonym source-of-truth'una yazılmaz.

## 11. Inclusion/exclusion examples

| Ürün | Primary placement / state | Neden |
|---|---|---|
| 5G Android smartphone, 128 GB | Akıllı Telefonlar | 5G, OS, storage ve brand facet'tir. |
| Tuşlu dual-SIM telefon | Tuşlu Telefonlar | Dual SIM facet; gerçek product type tuşlu telefondur. |
| Yenilenmiş smartphone | Akıllı Telefonlar | `Yenilenmiş` condition/warranty policy'sidir, category değildir. |
| Exact model silikon case | Telefon Kılıfları | Model compatibility, material, color ve MagSafe facet'tir. |
| Temperli cam / privacy film | Ekran Koruyucular | Material/privacy/coverage facet'tir. |
| Telefon kamera koruma halkası | Kamera Lens Koruyucuları | Koruma ürünüdür; camera module değildir. |
| Masa telefonu standı veya phone-first grip | Telefon Tutucu, Stand & Askıları | Phone-first kullanım; vehicle fitment yok. |
| Araç havalandırmasına özel telefon mount | **Otomotiv & Motosiklet** | Vehicle installation/context ana şemadır. |
| Model-specific battery case | Telefon Modeline Özgü Şarj Aksesuarları | Telefon gövdesine/fiziksel modele bağlıdır. |
| Generic powerbank / USB-C cable / 45W adapter | **Güç, Şarj & Bağlantı** | Generic cross-device power/connection product. |
| Phone-first selfie stick / gimbal / clip-on lens | Telefon Kamera & Çekim Aksesuarları | Ana kullanım telefonla görüntü üretimidir. |
| Camera-first tripod/gimbal | **Fotoğraf & Kamera** | Ana kullanım camera equipment'tır. |
| Phone-specific active stylus | Telefon Kalemleri | Exact phone compatibility gerekir. |
| Generic/tablet-first stylus | **Bilgisayar & Tablet** | Computing/tablet input ana işlevi. |
| Internal replacement battery | Telefon Bataryaları | Physical repair part; safety/policy gate gerekir. |
| Replacement OLED + digitizer | Ekran & Dokunmatik Modülleri | Ekran koruyucu değil technician replacement part. |
| Charging-port daughterboard | Şarj Soketi & Bağlantı Parçaları | Generic charging accessory değil dahili parça. |
| Front camera replacement module | Kamera Modülleri | Clip-on camera accessory değildir. |
| Button/sensor flex | Flex Kablo & Dahili Parçalar | Exact part type/model evidence gerekir. |
| Ekran değişimi hizmeti | **Product Taxonomy dışında** | Service/merchant capability'dir. |
| Physical SIM starter pack | **LEGAL_REVIEW_REQUIRED / unassigned** | Telecom activation/service contract içerir. |
| eSIM QR, tarife, paket, kontör | **Product Taxonomy dışında** | Digital telecom service/stored-value işlemidir. |
| microSD memory card | **Bilgisayar & Tablet → Veri Depolama** | Storage product type'ıdır; phone usage ownership üretmez. |
| Bluetooth earbuds | **Ses & Kulaklık** | Audio ana işlevdir. |
| Smartwatch | **Giyilebilir Teknoloji** | Telefon compatibility'si ayrı owner-final L2'yi değiştirmez. |

### Ambiguous-product adjudication

1. Ana product function'ı belirle.
2. Phone-first, camera-first, vehicle-fitment, audio-first veya computing-first
   kullanım şemasını belirle.
3. Exact model compatibility'nin category ownership mi, facet mi olduğunu belirle.
4. Fiziksel ürün ile service/contract'ı ayır.
5. Safety, authenticity ve regulated policy'yi category'den ayrı değerlendir.
6. Tek leaf kesinleşmiyorsa duplicate assignment yapma; taxonomy review'a gönder.

## 12. Open owner decisions

Bu belge aşağıdaki kararları product owner'a taşır; hiçbiri henüz FINAL değildir:

1. **Exact L3 seti:** Önerilen dokuz L3 adı, sırası ve scope'u onaylanacak mı?
2. **Phone device depth:** `Cep Telefonları` L3 container altında `Akıllı Telefonlar`
   ve `Tuşlu Telefonlar` L4 leaf yaklaşımı onaylanacak mı? Öneri: evet.
3. **Spare-part tree:** Beş yedek parça L4 leaf'i Product Taxonomy'de kalsın mı?
   Öneri: fiziksel parça olarak kalsın; normal aksesuar gibi görünmesin.
4. **Spare-part assignability/visibility:** Hangi merchant, provenance, warranty,
   condition ve compatibility evidence'iyle yedek parça yayımlayabilir?
5. **Battery policy:** Telefon bataryası için `REGULATED`/hazmat/safety owner'ı ve
   taşıma/yayın kuralı kim olacak?
6. **Phone-specific charging threshold:** Model-family charging case/cradle bu dalda,
   generic cable/adapter/powerbank ayrı L2'de kalma kuralı aynen onaylanacak mı?
7. **Phone-first capture/stylus:** Phone-first gimbal/lens ve phone-specific stylus
   proposed leaf'leri onaylanacak mı; mixed-use SKU review eşiği nasıl ölçülecek?
8. **SIM/telecom exclusion:** Physical SIM starter kit `LEGAL_REVIEW_REQUIRED`,
   eSIM/plan/package/top-up Product Taxonomy dışında kalsın mı? Öneri: evet.
9. **Small installation tools:** SIM eject tool gibi düşük-coverage ürünler için
   dedicated node açılmaması ve category-request review yaklaşımı onaylanacak mı?
10. **Coverage pilot:** Final karar öncesi yerel telefoncu/servislerden representative
    SKU pilotu ve zero-result/category-request analizi istenecek mi?

### Proposal outcome markers

`CANONICAL_PATH: ELEKTRONİK → TELEFON & AKSESUARLARI — UNCHANGED`

`PHONE_ACCESSORIES_L34_STATE: PROPOSED FOR OWNER REVIEW`

`PROPOSED_L3_COUNT: 9`

`PROPOSED_L4_COUNT: 7`

`PROPOSED_LEAF_COUNT: 14`

`MAX_DEPTH: 4 — PASS`

`DUPLICATE_CATEGORY: NONE`

`BRAND_AS_CATEGORY: NONE`

`ATTRIBUTE_AS_CATEGORY: NONE`

`GENERIC_CHARGING_BOUNDARY: PASS`

`LEAF_ASSIGNMENT: COMPLETE FOR PROPOSED SCOPE`

`SYNONYM_MODEL: CONTROLLED / NOT IMPLEMENTED`

`RUNTIME_IMPLEMENTATION: NO`
