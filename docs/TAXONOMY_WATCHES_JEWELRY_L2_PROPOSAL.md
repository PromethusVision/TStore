# EsnaftaVar — Saat & Takı L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Saat & Takı — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Yalnız L2 omurgası önerilir. Kuyum yetkilendirmesi, high-value fulfilment, L3/L4,
stable ID, runtime taxonomy veya remote değişiklik yapılmaz.

## 2. Scope

Kapsam; klasik/analog-dijital kol saati, cep saati, saat kayışı/aksesuarı, kolye,
küpe, yüzük, bileklik/bilezik/halhal, broş/giyim takısı, vücut takısı, takı saklama
aksesuarı ve takı yapım malzemesidir.

Canonical ayrım **ürün formu** üzerinden kurulur. Altın, gümüş, platin, çelik,
değerli taş, bijuteri, kadın/erkek/unisex ve fiyat seviyesi category değil facet ve
gerektiğinde policy sinyalidir. Akıllı saat her durumda **Elektronik → Giyilebilir
Teknoloji** alanındadır.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Jewelry; anklet, body jewelry, bracelet, brooch/lapel pin, charm/pendant, earring, necklace, ring; watch/watch accessory gibi product-form dalları vardır. | Form-first omurga ve one-primary-leaf ilkesi desteklenir. Public dosya header'ı `2021-09-21`; Türkiye 2026 policy kaynağı değildir. |
| [n11 Bijuteri & Takılar](https://www.n11.com/bijuteri-takilar) | Kolye, küpe, yüzük, bileklik, broş ve set gibi customer-facing ürün tipleri görünürdür. | Form dili alındı; `bijuteri` material/value class olarak facet tutuldu. |
| [Trendyol Bijuteri Takım](https://www.trendyol.com/bijuteri-takim-x-c103563) | Bijuteri, değerli olmayan materyal ve moda odaklı set diliyle sunulur. | Material/value class'ın tek başına canonical product type olmadığını; set'in bundle olduğunu destekler. |
| [Trendyol Saat Kutusu](https://www.trendyol.com/saat-kutusu-y-s6549) | Saat kutusu/saklama ürünü ana saatten ayrı accessory intent'tir. | Saat aksesuarı ve genel takı saklamanın ayrı boundary'si desteklendi. |
| [Ticaret Bakanlığı — Kuyum Ticareti](https://ticaret.gov.tr/ic-ticaret/kuyum-ticareti) | Kuyum ticareti, yetki belgesi ve mesleki/işletme yükümlülükleriyle düzenlenir. | Değerli metal/taş listing'i normal bijuteri gibi sessizce açılmaz; merchant/policy verification gerekir. |
| [Ticaret Bakanlığı — sentetik kıymetli taş düzenlemesi 2026](https://ticaret.gov.tr/haberler/ticaret-bakanligindan-kuyumculuk-sektorunde-tuketiciyi-koruyacak-yeni-duzenleme-sentetik-kiymetli-tas-iceren-urunlerin-etiket-sertifika-fatura-ve-satis-alanlarinda-urunlerin-sentetik-oldugunun-acikca-belirtilmesi-zorunlu-hale-getirildi) | Sentetik/laboratuvar üretimi kıymetli taş bilgisinin etiket, sertifika, fatura, internet ve tanıtımda açık belirtilmesi zorunluluğu duyurulmuştur. | Stone origin/material typed facet ve compliance evidence ihtiyacını destekler; kategoriye çevrilmez. |
| [KTBS Sıkça Sorulan Sorular](https://ktbs.ticaret.gov.tr/Home/SikcaSorulanSorularDok) | Perakende kuyum ticareti için yetki belgesi kapsamı ve başvuru sistemi açıklanır. | Merchant eligibility'nin taxonomy'den bağımsız olması gerektiğini doğrular. |

**Source limitation:** Hepsiburada ve Amazon Türkiye'nin güncel tam public saat/takı
ağaçları alınamadı; Trendyol/n11 merchandising yapıları wholesale kopyalanmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **11**.

Saat formu ile takı formunu ayırır; her materyal/değer sınıfı için duplicate L2
oluşturmaz. Takı seti bundle facet'idir, ayrı L2 değildir.

## 5. Exact L2 list

1. Klasik Kol Saatleri
2. Cep Saatleri
3. Saat Kayışları & Aksesuarları
4. Kolyeler & Takı Uçları
5. Küpeler
6. Yüzükler
7. Bileklik, Bilezik & Halhallar
8. Broş & Giyim Takıları
9. Vücut Takıları
10. Takı Aksesuarları & Saklama
11. Takı Yapım Malzemeleri

Normalized duplicate: **0**. Material/value/gender-as-category: **0**. Smartwatch
leakage: **0**.

## 6. Granularity rationale

- Kol saati, yerel müşteri için güçlü ana ürün formudur. Analog, quartz, otomatik,
  dijital veya fashion style facet/L3 adayıdır; smartwatch burada değildir.
- Cep saati farklı taşıma/kullanım biçimi ve arama niyeti nedeniyle ayrı düşük
  hacimli L2 leaf olabilir.
- Kayış, kutu, kurma kutusu ve bakım ürünü ana saatten bağımsız accessory schema'sı
  taşır.
- Kolye/uç, küpe, yüzük ve bilek/ayak takısı birbirinden farklı ölçü, takma biçimi ve
  arama niyetidir; materyal bazlı dallanmadan daha kalıcıdır.
- Broş, yaka rozeti, kol düğmesi ve kravat takısı `Broş & Giyim Takıları` altında
  product-use family olarak birleşir; cinsiyet category olmaz.
- Piercing/body jewelry temas/ölçü ve hijyen facetleriyle ayrı üründür.
- Takı kutusu/standı/bakım aksesuarı ve takı yapım parçası bitmiş takı değildir;
  iki ayrı major intent'tir.
- Set/bundle, principal canonical leaf'e atanır ve `set` facet'i alır; ayrı L2 yoktur.

## 7. Inclusions

| L2 | Dahil olan ana ürünler |
|---|---|
| Klasik Kol Saatleri | Analog, quartz, mekanik/otomatik ve elektronik dijital klasik kol saatleri; smart özellik primary değil |
| Cep Saatleri | Zincirli/kapaklı klasik cep saati ve timepiece primary ürün |
| Saat Kayışları & Aksesuarları | Kayış/kordon, toka, saat kutusu, watch winder, stand, pil ve consumer bakım/tamir aksesuarı |
| Kolyeler & Takı Uçları | Kolye, zincir, choker, pendant/charms ve kolye ucu |
| Küpeler | Stud, halka, sallantılı, ear cuff ve bitmiş küpe ürünleri |
| Yüzükler | Alyans, tektaş, mühür, moda ve diğer bitmiş yüzükler; material facet |
| Bileklik, Bilezik & Halhallar | Bileklik, bilezik, charm bracelet ve halhal |
| Broş & Giyim Takıları | Broş, rozet/lapel pin, kol düğmesi, kravat iğnesi/klipsi ve giysiye takılan jewelry |
| Vücut Takıları | Piercing, burun/göbek/dudak/kaş takısı ve body jewelry |
| Takı Aksesuarları & Saklama | Takı kutusu, organizer, stand, seyahat çantası, temizleme bezi ve bitmiş takı bakım aksesuarı |
| Takı Yapım Malzemeleri | Boncuk, misina/tel, kapama, halka, boş yuva, zincir parçası ve jewelry-making component |

## 8. Exclusions

- Smartwatch, fitness tracker, smart ring ve elektronik giyilebilir cihaz:
  **Elektronik → Giyilebilir Teknoloji**.
- Duvar/masa/çalar saat: **Ev & Yaşam**; klasik personal timepiece değildir.
- Saat/takı tamir, boy ayarı, gravür, ekspertiz, kiralama ve sigorta:
  **service scope — excluded**.
- Saf yatırım altını, külçe, sikke/coin ve finansal/investment product: normal jewelry
  taxonomy'ye sessizce alınmaz; **LEGAL_REVIEW_REQUIRED / owner scope decision**.
- Antika/koleksiyon değeri primary saat/takı: **Antika & Koleksiyon**; modern/normal
  wearable ürün burada.
- Saç tokası/taç ve general fashion accessory: **Giyim & Aksesuar**; mücevher formu
  primary değilse burada değildir.
- Çocuk oyuncak takı seti: primary pretend-play ise **Oyuncak**.
- Loose gemstone/investment stone: Takı Yapım mı değerli varlık mı olduğu owner/
  legal review olmadan atanmaz.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Elektronik | Zaman gösterme + mekanik/quartz/standalone digital timepiece primary ise burada; app, sensör, connectivity ve smart platform primary ise Elektronik. |
| Giyim & Aksesuar | Jewelry formu/metal-ornament primary ise burada; tekstil aksesuarı, saç aksesuarı, kemer/şal vb. orada. |
| Antika & Koleksiyon | Kullanılabilir modern/vintage saat-takı burada; koleksiyon/antika değer ve provenance primary ise Antika & Koleksiyon. |
| Oyuncak | Gerçek wearable takı burada; pretend-play/plastic toy set Oyuncak. Material tek başına karar vermez. |
| Ev & Yaşam | Takı/saat saklama accessory burada; genel dekoratif kutu/stand ve wall/table clock Ev & Yaşam. |
| El Sanatları / Kırtasiye | Jewelry-making-specific findings/components burada; generic craft boya, ip, alet Kırtasiye & Ofis veya Yapı Market. |
| Sağlık | Body jewelry burada; piercing işlemi/hizmeti taxonomy dışında, medical implant Sağlık & Medikal/policy. |

## 10. Category vs facet

Aşağıdakiler category değil facet/policy attribute'tur:

- marka, model/seri, cinsiyet ve hedef yaş;
- materyal: altın, gümüş, platin, çelik, pirinç, tekstil, plastik vb.;
- ayar/karat, ağırlık, kaplama, metal rengi ve hallmark/damga;
- taş türü, doğal/sentetik/laboratuvar üretimi, carat, cut, clarity ve sertifika;
- saat mekanizması, güç kaynağı, su dayanımı, kasa/kordon materyali, çap;
- yüzük ölçüsü, zincir uzunluğu, küpe kapama, piercing gauge/ölçü;
- değer sınıfı: precious/fine jewelry, fashion jewelry/bijuteri;
- renk, tema, occasion ve personalization;
- set/bundle, adet ve hediye paketi.

`Altın Kolye`, `Gümüş Yüzük` veya `Erkek Saat` yeni kategori değil form L2 + facet
bileşimidir.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Klasik Kol Saatleri | kol saati, klasik saat, analog saat, quartz saat, mekanik saat |
| Cep Saatleri | köstekli saat, pocket watch, kapaklı cep saati |
| Saat Kayışları & Aksesuarları | saat kordonu, kayış, saat kutusu, watch winder, saat pili |
| Kolyeler & Takı Uçları | kolye, zincir, choker, pendant, charm, kolye ucu |
| Küpeler | küpe, ear cuff, halka küpe, stud küpe |
| Yüzükler | yüzük, alyans, tektaş, mühür yüzük |
| Bileklik, Bilezik & Halhallar | bileklik, bilezik, halhal, charm bracelet |
| Broş & Giyim Takıları | broş, rozet, lapel pin, kol düğmesi, kravat iğnesi |
| Vücut Takıları | piercing, body jewelry, burun/göbek/kaş takısı |
| Takı Aksesuarları & Saklama | takı kutusu, mücevher kutusu, takı standı, organizer |
| Takı Yapım Malzemeleri | boncuk, takı teli, kapama, takı aparatı, jewelry findings |

`Akıllı saat` alias'ı bu L1'e bağlanmaz; Elektronik sonucuna gitmelidir.

## 12. Policy/compliance

- Standart düşük değerli classic watch ve fashion jewelry **NORMAL** olabilir;
  product safety ve authenticity kontrolleri saklıdır.
- Altın/değerli metal/değerli taş veya high-value jewelry **LEGAL_REVIEW_REQUIRED**:
  seller KTBS/yetki, ayar/damga, sertifika, fatura, provenance, fraud/AML, güvenli
  ödeme/teslimat ve iade süreçleri ayrıca tasarlanmalıdır.
- Sentetik/laboratuvar üretimi taş bilgisi typed field ve görünür disclosure olarak
  zorunlu policy kanıtıdır; category adı yeterli değildir.
- Sahte marka, yanıltıcı metal/ayar/taş claimi ve çalıntı/provenance belirsiz ürün
  **EXCLUDED** veya enforcement review kapsamındadır.
- Body jewelry'de materyal, hijyen, steril/tek kullanımlık claim ve sağlık riskleri
  **LEGAL_REVIEW_REQUIRED** olabilir.
- Çocuk takısında küçük parça/metal ve yaş güvenliği kontrolü gerekir.
- Policy class category depth değildir.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Hibrit analog akıllı saat | App/sensör/connectivity ana değer ise Elektronik; yalnız quartz saat + pasif detay ise Klasik Kol Saatleri. Owner precedence rule gerekli. |
| Smart ring | Elektronik → Giyilebilir Teknoloji; yüzük formu jewelry ownership'i doğurmaz. |
| Pırlanta kolye | Kolyeler & Takı Uçları + precious material/stone facets + legal gate. |
| Bijuteri yüzük | Yüzükler + fashion/bijuteri facet; material L2 oluşturmaz. |
| Takı seti | Principal item leaf'i + bundle facet; eşit ağırlıklı çok-form set için deterministic owner rule gerekli. |
| Saat pili | Açık watch-specific ise Saat Kayışları & Aksesuarları; generic button cell Elektronik/appropriate battery branch. |
| Takı kutusu görünümlü dekor kutu | Jewelry storage primary ise burada; generic decorative storage Ev & Yaşam. |
| Loose diamond/gemstone | Jewelry component mi investment/high-value asset mi olduğu legal/owner review; otomatik Takı Yapım'a alınmaz. |
| Vintage mekanik saat | Kullanım timepiece primary ise burada; collector provenance/value primary ise Antika & Koleksiyon. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- Klasik Kol Saatleri → Analog; Dijital Klasik; Mekanik/Otomatik (schema/volume
  kanıtlanırsa).
- Saat Kayışları & Aksesuarları → Kayış/Kordon; Saklama/Kurma; Pil & Bakım;
  Consumer Tamir Parçaları.
- Kolyeler & Takı Uçları → Kolye/Zincir; Uç/Charm.
- Broş & Giyim Takıları → Broş/Rozet; Kol Düğmesi; Kravat Takıları.
- Takı Aksesuarları & Saklama → Kutu/Organizer; Stand; Seyahat Saklama;
  Temizleme/Bakım.
- Takı Yapım Malzemeleri → Boncuk; Tel/Misina; Kapama/Halka; Boş Yuva;
  Zincir/Component.

Materyal, cinsiyet, taş, marka, renk ve değer seviyesi L3/L4 yapılmaz.

## 15. Owner decisions

1. Exact 11 L2 adı ve sırası onaylanmalı.
2. Cep saatinin bağımsız L2 leaf olarak kalması veya Klasik Saatler altında
   birleşmesi kararlaştırılmalı.
3. High-value jewelry için seller verification, price/value threshold, secure
   delivery, returns ve fraud/AML policy matrix hazırlanmalı.
4. Loose gemstone ve investment gold/sikke ürünlerinin scope/exclusion kararı
   kesinleştirilmeli.
5. Eşit ağırlıklı çok-form takı setinde principal leaf selection rule belirlenmeli.
6. Hibrit analog-smart saat precedence kuralı onaylanmalı.
7. Saat pili ve generic button-cell sınırı kesinleştirilmeli.

Owner onayı olmadan proposal **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **11**
- Normalized duplicate L2: **0**
- Smartwatch leakage: **0**
- Material/value/gender-as-category: **0**
- Bundle-as-category: **0**
- Precious/high-value policy gate: **DOCUMENTED — OPEN**
- Service leakage: **0**
- Future max depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`WATCHES_JEWELRY_L2_ARCHITECTURE: PASS`

`WATCHES_JEWELRY_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
