# EsnaftaVar — Kırtasiye & Ofis L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Kırtasiye & Ofis — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Belge yalnız L2 önerisidir. L3/L4, stable ID, taxonomy JSON, migration, seed veya
runtime değişikliği içermez.

## 2. Scope

Kapsam; yazım, not alma, planlama, genel kâğıt/baskı sarfı, dosyalama/arşiv,
masaüstü ofis, kesme/yapıştırma, okul/eğitim kırtasiyesi, sanat/çizim, sunum/pano,
küçük ofis makineleri ve paketleme/postalama ürünleridir.

Canonical printer sınırı korunur:

- yazıcı, tarayıcı, toner, kartuş, mürekkep, drum ve 3D filament → **Bilgisayar &
  Tablet → Yazıcı, Tarayıcı & Sarf Malzemeleri**;
- fotokopi/çizim kâğıdı, etiket, termal rulo ve genel ofis sarfı → **Kırtasiye &
  Ofis**.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Office supplies, filing, paper, writing/drawing, presentation ve küçük office equipment farklı ailelerdir; tek en uygun kategori istenir. | Fonksiyonel omurga ve tek primary leaf ilkesi alındı. Public dosya header'ı `2021-09-21`; 2026 Türkiye ağacı değildir. |
| [Trendyol Kırtasiye ve Ofis Malzemeleri 2026](https://www.trendyol.com/kirtasiye-ofis-malzemeleri-x-c104125) | Defter/not, ajanda, kâğıt, dosyalama, evrak düzeni ve masaüstü kullanım dili güçlüdür. | Türkçe müşteri niyeti ve ayrı schema aileleri doğrulandı. |
| [Trendyol Sanatsal Malzemeler 2026](https://www.trendyol.com/sanatsal-malzemeler-x-c103785) | Çizim, eskiz, boya ve uygulama ekipmanları ayrı bir alışveriş niyetidir. | Sanat/çizim L2'si desteklendi; profesyonel seviye ve teknik facet olarak bırakıldı. |
| [Trendyol Kırtasiye Setleri 2026](https://www.trendyol.com/kirtasiye-seti-x-c110823) | Okul/ofis setleri kalem, silgi, cetvel, defter, bant, hesap makinesi, zımba ve dosya gibi farklı ana ürünleri paketler. | Bundle/set'in category olmadığını; principal product veya çok ürünlü kit kuralı gerektiğini gösterir. |
| [n11 Kırtasiye & Ofis](https://www.n11.com/kirtasiye-ve-ofis) | Kalem/yazı, okul, sanat, kâğıt, defter/ajanda, ofis, dosyalama, office machines, pano/tahta aileleri görünürdür. | Önerilen breadth Türkiye pazar diliyle karşılaştırıldı; marketplace ağacı kopyalanmadı. |
| [Amazon Türkiye inkjet kâğıdı](https://www.amazon.com.tr/b?node=12619371031) | Yazıcı kâğıdı `Ofis ve Kırtasiye > Defterler ve Kağıt Ürünleri` içinde bulunur. | Device-specific toner/kartuş ile generic print substrate ayrımını destekler. |
| [Hepsiburada okul alışverişi rehberi](https://www.hepsiburada.com/hayatburada/okul-alisverisi-listesi-yeni-ogrenciler-icin-20-urun-listesi/) | Defter kaplama, etiket, kalem kutusu ve çanta gibi ürünler okul niyetiyle birlikte sunulur. | `Okul`un tek başına her ürünü yeniden sınıflamaması gerektiğini gösterir; çanta kendi L1'inde kalır. |

**Source limitation:** Hepsiburada ve Amazon Türkiye'nin güncel tam public L2
ağaçları alınamadı; eldeki sayfalar yalnız boundary/ürün dili kanıtıdır.

## 4. Recommended L2 count

Önerilen L2 sayısı: **11**.

Bu sayı fiziksel mağaza reyonlarını ve attribute şemalarını ayırır; kalem türleri,
kâğıt boyları, boya teknikleri ve sınıf seviyelerini L2 yapmaz.

## 5. Exact L2 list

1. Kalem & Yazım Gereçleri
2. Defter, Ajanda & Planlayıcılar
3. Kağıt, Etiket & Baskı Sarfı
4. Dosyalama & Arşivleme
5. Masaüstü Ofis Gereçleri
6. Yapıştırıcı, Bant & Kesim Gereçleri
7. Okul Kırtasiyesi & Eğitim Gereçleri
8. Sanat & Çizim Malzemeleri
9. Sunum, Pano & Yazı Tahtası Ürünleri
10. Ofis Makineleri & Ciltleme Ekipmanları
11. Paketleme & Postalama Ürünleri

Normalized duplicate: **0**. Marka-as-category: **0**. Okul seviyesi-as-category:
**0**.

## 6. Granularity rationale

- Kalem/yazım, uç/mürekkep ve kullanım tekniği açısından kendi schema ailesidir.
- Defter/ajanda/planlayıcı bitmiş not alma ürünüdür; boş kâğıt ve baskı substrate'ı
  ayrı L2'dir.
- Kâğıt/etiket/baskı sarfı generic substrate'ı kapsar; device-specific toner veya
  kartuşu kapsamaz.
- Dosyalama/arşivleme document retention; masaüstü ofis ise zımba, delgeç, ataş,
  kaşe ve düzenleyici gibi günlük işlem ürünüdür.
- Kesme/yapıştırma, ürün güvenliği ve teknik nitelikleri nedeniyle masaüstü genel
  gereçlerinden ayrılır.
- Okul L2'si yaş/okul temalı kalemi yeniden kopyalamaz; geometri seti, eğitim kartı,
  okul deney/etkinlik kırtasiyesi gibi school-specific ürünleri toplar.
- Sanat/çizim; boya, medium, yüzey ve teknik facetleriyle ayrı major department'tır.
- Sunum/pano/yazı tahtası; sergileme ve ortak çalışma ürünlerini toplar.
- Küçük ofis makineleri; printer/scanner hariç laminator, shredder, calculator,
  binding ve label maker gibi ürünleri kapsar.
- Paketleme/postalama; evrak/paket hazırlama ana işlevli ürünlerdir; shipping hizmeti
  değildir.

## 7. Inclusions

| L2 | Dahil olan ana ürünler |
|---|---|
| Kalem & Yazım Gereçleri | Tükenmez, dolma, roller, kurşun/versatil, marker, fosforlu kalem; uç, silgi ve kalem mürekkebi |
| Defter, Ajanda & Planlayıcılar | Okul/ofis defteri, günlük, ajanda, planner, bloknot ve not defteri |
| Kağıt, Etiket & Baskı Sarfı | Fotokopi/çizim/fotoğraf kâğıdı, karton, zarf, etiket, sticker sheet, termal/plotter rulo |
| Dosyalama & Arşivleme | Klasör, poşet dosya, sunum dosyası, arşiv kutusu, separatör ve evrak rafı |
| Masaüstü Ofis Gereçleri | Zımba/delgeç, ataş, raptiye, kaşe, kalemlik, kartvizitlik, masaüstü düzenleyici |
| Yapıştırıcı, Bant & Kesim Gereçleri | Yapıştırıcı, bant, bant kesici, makas, maket bıçağı ve kesim matı |
| Okul Kırtasiyesi & Eğitim Gereçleri | Cetvel/geometri seti, eğitim kartı, okul etkinlik seti, yazı/çizgi çalışma aracı ve school-specific kırtasiye |
| Sanat & Çizim Malzemeleri | Sanat boyası, fırça, kalem, pastel, tuval, eskiz yüzeyi, medium ve çizim aracı |
| Sunum, Pano & Yazı Tahtası Ürünleri | Whiteboard, mantar pano, flipchart, tahta kalemi/silgisi, sunum panosu ve aksesuarı |
| Ofis Makineleri & Ciltleme Ekipmanları | Hesap makinesi, laminasyon, ciltleme, evrak imha, etiketleme ve para sayma makinesi; sarfları |
| Paketleme & Postalama Ürünleri | Kargo zarfı/poşeti, paketleme kâğıdı, ip, lastik, gönderi etiketi ve postalama aksesuarı |

## 8. Exclusions

- Yazıcı, tarayıcı, çok fonksiyonlu yazıcı, 3D printer, toner, kartuş, mürekkep,
  drum, printhead ve 3D filament: **Bilgisayar & Tablet**.
- Bilgisayar, monitor, klavye, mouse ve USB elektronik cihaz: **Bilgisayar &
  Tablet** veya **Elektronik**.
- Okul çantası, kalem çantası ve laptop çantası: primary taşıma ürünü olarak
  **Çanta & Aksesuar**; loose pencil case owner boundary review gerektirir.
- Ofis masası, sandalye, raf ve genel mobilya: **Ev & Yaşam**.
- Profesyonel matbaa makinesi ve endüstriyel baskı hattı: B2B/policy scope; consumer
  office machine değildir.
- Dijital ofis yazılımı, abonelik, baskı/ciltleme/kargo hizmeti: Product Taxonomy
  dışında.
- Çocuk oyuncağı niteliğindeki craft/oyun seti: primary play function varsa
  **Oyuncak**.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Bilgisayar & Tablet | Baskı cihazı ve device-specific sarf orada; generic kâğıt/etiket/rulo burada. Toner/kartuş owner-final olarak oradadır. |
| Kitap | Okunmak için yayımlanmış içerik Kitap; boş yazım/not/planlama ürünü burada. Kitap ayracı burada. |
| Çanta & Aksesuar | Taşıma işlevi primary olan okul/laptop/evrak çantası orada; klasör ve dosyalama ürünü burada. |
| Oyuncak | Play function primary ise Oyuncak; çizim/yazım/öğrenme sarfı primary ise burada. Karakter baskısı category değiştirmez. |
| Ev & Yaşam | Mobilya ve genel dekor orada; masaüstü düzenleyici ve document workflow ürünü burada. |
| Yapı Market | Ağır kesim/el aleti ve yapı uygulama ürünü orada; kağıt/craft kesim aracı burada. |
| Hobi/sanat | Fiziksel sanat yapım malzemesi burada; sanat kitabı Kitap; bitmiş sanat/dekor ürünü primary işlevine göre başka L1. |

## 10. Category vs facet

Aşağıdakiler category değil facet/attribute'tur:

- marka, seri, renk, desen, karakter/lisans;
- uç kalınlığı, mürekkep tipi/rengi, kalem mekanizması;
- kâğıt boyutu, gramaj, renk, yüzey, çizgi tipi, sayfa/yaprak sayısı;
- defter cilt/spiral/kapak türü ve tarihli/tarihsiz;
- klasör ölçüsü, halka sayısı, kapasite ve malzeme;
- yaş/sınıf, okul/iş kullanım hedefi ve profesyonel/öğrenci seviyesi;
- boya türü/medium, yüzey uyumu ve paket adedi;
- makine kapasitesi, kâğıt boyutu, güç ve sarf uyumluluğu;
- set/bundle durumu. Kit, principal canonical leaf'e atanır.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Kalem & Yazım Gereçleri | yazı gereci, kalem, marker, versatil, uçlu kalem |
| Defter, Ajanda & Planlayıcılar | notebook, günlük, planner, bloknot, notluk |
| Kağıt, Etiket & Baskı Sarfı | fotokopi kağıdı, printer kağıdı, sticker, etiket, termal rulo |
| Dosyalama & Arşivleme | dosya, klasör, evrak, arşiv, poşet dosya |
| Masaüstü Ofis Gereçleri | masaüstü kırtasiye, zımba, delgeç, ataş, kaşe |
| Yapıştırıcı, Bant & Kesim Gereçleri | yapıştırıcı, tutkal, bant, makas, maket bıçağı |
| Okul Kırtasiyesi & Eğitim Gereçleri | okul malzemesi, eğitim gereci, geometri seti, cetvel |
| Sanat & Çizim Malzemeleri | resim malzemesi, sanat malzemesi, boya, tuval, çizim |
| Sunum, Pano & Yazı Tahtası Ürünleri | whiteboard, yazı tahtası, mantar pano, flipchart |
| Ofis Makineleri & Ciltleme Ekipmanları | laminasyon, ciltleme, shredder, evrak imha, hesap makinesi |
| Paketleme & Postalama Ürünleri | kargo zarfı, paketleme, postalama, gönderi malzemesi |

`Printer kağıdı` burada arama alias'ıdır; `printer` cihazı bu L1'e taşınmaz.

## 12. Policy/compliance

- Standart kırtasiye ürünleri çoğunlukla **NORMAL** sınıfına adaydır.
- Kesici alet, solventli yapıştırıcı, aerosol, güçlü marker/kimyasal ve bazı sanat
  mediumları yaş, tehlike, taşıma ve etiket koşulları nedeniyle **AGE_RESTRICTED**,
  **REGULATED** veya **LEGAL_REVIEW_REQUIRED** olabilir; exact SKU policy gerekir.
- Çocuk hedefli malzemelerde ürün güvenliği ve yaş uyarısı doğrulanır; karakter
  lisansı/telif category değil listing compliance konusudur.
- Sahte para kontrol/para sayma ekipmanı gibi ürünler illegal kullanım iddiasıyla
  pazarlanamaz; işlev ve mevzuat ayrıca kontrol edilir.
- Policy sınıfı category depth değildir.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Kalem kutusu | Loose desk/pencil organizer ise Masaüstü Ofis; taşıma çantası primary ise Çanta & Aksesuar. Owner rule gerekli. |
| Akıllı/dijital kalem | Tablet/stylus input device ise Bilgisayar Aksesuarları; yalnız kâğıda yazan elektronik kayıt kalemi primary işleve göre review. |
| Etiket yazıcı | Ofis workflow label maker ise Ofis Makineleri; genel printer contract ile çakışmaması için owner kararı gerekli. Sarfı primary device rule'u izler. |
| Fotoğraf kâğıdı | Generic print substrate burada; toner/kartuş Bilgisayar & Tablet. |
| Çizim tableti/light pad | Elektronik input/display cihazı ise Bilgisayar & Tablet/Elektronik; fiziksel çizim yüzeyi burada. |
| Çocuk sanat seti | Yapma/çizme sarfı primary ise Sanat & Çizim; oyun/kostüm/figür primary ise Oyuncak. |
| Laminasyon poşeti | Ofis Makineleri & Ciltleme Ekipmanları altında device-compatible sarf adayı; generic plastic sheet ise Kağıt/Etiket scope dışı olabilir. |
| Hazır kırtasiye seti | Set category değildir; principal/majority function leaf'i ve `bundle` facet'i kullanılır. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- Kalem & Yazım Gereçleri → Kurşun/Versatil; Tükenmez/Roller; Dolma;
  Marker/Fosforlu; Kalem Ucu & Mürekkep; Silgi.
- Defter, Ajanda & Planlayıcılar → Defter; Ajanda; Planlayıcı; Günlük; Bloknot.
- Kağıt, Etiket & Baskı Sarfı → Fotokopi Kâğıdı; Çizim/Fotoğraf Kâğıdı; Karton;
  Etiket/Sticker; Termal/Plotter Rulo; Zarf.
- Dosyalama & Arşivleme → Klasör; Dosya; Arşiv Kutusu; Separatör; Evrak Rafı.
- Sanat & Çizim → Boya; Fırça; Tuval/Yüzey; Pastel/Karakalem; Medium & Yardımcı.
- Ofis Makineleri → Hesap Makinesi; Laminasyon; Ciltleme; Evrak İmha;
  Etiketleme; Para Sayma.

Kâğıt boyu/gramajı, renk, yaş, sınıf, karakter ve marka L3/L4 yapılmaz.

## 15. Owner decisions

1. Exact 11 L2 adı ve sırası onaylanmalı.
2. `Okul Kırtasiyesi & Eğitim Gereçleri`nin yalnız school-specific ürünlere açık
   olması ve kalem/defter tekrarını yasaklayan kural onaylanmalı.
3. Etiket yazıcı ve sarfının Ofis Makineleri mi canonical Yazıcı L2'si mi olduğu
   finalleştirilmeli.
4. Kalem kutusu/evrak çantası için Kırtasiye–Çanta boundary'si kesinleştirilmeli.
5. Laminasyon/ciltleme sarflarının machine-family primary leaf kuralı onaylanmalı.
6. Kesici, solventli yapıştırıcı ve sanat kimyasalları için exact policy matrix
   hazırlanmalı.

Owner onayı olmadan proposal **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **11**
- Normalized duplicate L2: **0**
- Toner/kartuş canonical sınırı: **PASS**
- Printer/scanner leakage: **0**
- General paper ownership: **PASS — Kırtasiye & Ofis**
- Marka-as-category: **0**
- Sınıf/renk/boyut-as-category: **0**
- Service leakage: **0**
- Future max depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`STATIONERY_OFFICE_L2_ARCHITECTURE: PASS`

`STATIONERY_OFFICE_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
