# EsnaftaVar — Kitap L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Kitap — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Yalnız fiziksel kitap ürünleri için L2 omurgası önerilir. Belge L3/L4, stable ID,
runtime taxonomy veya ürün taşıma işlemi yapmaz.

## 2. Scope

Amaç, yerel kitapçı ve kırtasiyelerde fiziksel kitabı müşterinin alışveriş niyetiyle
bulunabilir kılan kalıcı ana rafları kurmaktır. Kitapta içerik konusu kaçınılmaz bir
discovery eksenidir; ancak her tür, tema, yazar, yayınevi veya dil category yapılmaz.

Canonical yaklaşım:

- ürünün bir primary shelf/category ataması olur;
- birden çok tür/tema `genre` ve `subject` facetleriyle aranır;
- yazar, yayınevi, ISBN, baskı dili, yaş, sınıf, sınav ve format typed facet olur;
- e-kitap, sesli kitap aboneliği ve diğer digital-only haklar V1 fiziksel Product
  Taxonomy'den ayrılır.

## 3. Sources

Araştırma 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center category contract](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Physical books, e-books, audiobooks ve book accessories farklı ürün aileleri olarak ele alınabilir; ürün için tek en uygun kategori ilkesi vardır. | Physical/digital ve ana-fonksiyon sınırı alındı. Public taxonomy header'ı `2021-09-21`; 2026 Türkiye raf ağacı olarak kopyalanmadı. |
| [n11 Kitap](https://www.n11.com/kitap) | Eğitim/ders, edebiyat, çocuk/gençlik, akademik, hobi, yabancı kitap, araştırma/inceleme ve dergi gibi müşteri rafları görünürdür. | Türkiye müşteri dilinin major shelf yaklaşımını doğrular; dini/sağlık/aile gibi her konu L2 yapılmadı. |
| [n11 Edebiyat](https://www.n11.com/kitap/edebiyat) ve [n11 Manga](https://www.n11.com/kitap?q=manga) | Roman, öykü, şiir ve çizgi anlatı/manga güçlü format-tür niyetleridir; manga farklı yaşlara ve temalara uzanır. | `Çizgi Roman & Manga` ayrı discovery shelf'i önerildi; alt genre facet kalır. |
| [n11 Çocuk & Gençlik](https://www.n11.com/kitap/cocuk-ve-genclik-kitaplari) ve [n11 Eğitim kaynakları](https://www.n11.com/kitap/egitim/kaynak-kitaplar) | Hedef yaş ve eğitim amacı güçlü alışveriş başlangıçlarıdır. | Çocuk/gençlik ile eğitim/ders ayrıldı; yaş ve sınıf facet olarak tutuldu. |
| [Trendyol Ders ve Yardımcı Kitaplar 2026](https://www.trendyol.com/ders-ve-yardimci-kitaplar-x-c104420) | Sınıf, ders, soru bankası, konu anlatımı ve müfredat/sınav niyetleri birlikte kullanılır. | `Eğitim & Ders` ile `Sınav Hazırlık` şema farkı desteklenir; sınıf/ders/sınav facet kalır. |
| [Trendyol Tudem 2026](https://www.trendyol.com/tudem-yayinlari-x-b104917) | Aynı yayınevi çocuk edebiyatı, çizgi roman ve sınav kaynakları üretebilir. | Yayınevinin kategori olamayacağını ve product-led raf atamasını destekler. |
| [Hepsiburada kitap satış eğilimi özeti](https://kurumsal.hepsiburada.com/uploads/2022nin-ilk-uc-ayinda-hepsiburadada-en-cok-cocuk-kitaplari-satildi.pdf) | Çocuk, edebiyat, eğitim, araştırma/inceleme ve kişisel gelişim ayrı müşteri talep kümeleridir. | Tarihsel talep kanıtı olarak kullanıldı; güncel eksiksiz taxonomy yerine geçmez. |

**Source limitation:** Hepsiburada ve Amazon Türkiye'nin 2026 tarihli tam public
category tree'si alınamadı. Amazon Türkiye sonuçları tekil ürün/raf örnekleri sundu;
tam L2 yapısı varsayılmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **10**.

Bu omurga major shelf niyetlerini ayırır; roman alt türleri, okul sınıfları, tekil
sınavlar, diller ve akademik disiplinleri L2'ye şişirmez.

## 5. Exact L2 list

1. Edebiyat & Kurgu
2. Çocuk & Gençlik Kitapları
3. Eğitim & Ders Kitapları
4. Sınav Hazırlık Kitapları
5. Akademik & Mesleki Kitaplar
6. Araştırma, İnceleme & Düşünce
7. Kişisel Gelişim & Yaşam
8. Sanat, Kültür & Hobi Kitapları
9. Çizgi Roman & Manga
10. Dil Öğrenimi & Sözlükler

Normalized duplicate: **0**. Yazar/yayınevi-as-category: **0**. Baskı dili-as-
category: **0**.

## 6. Granularity rationale

- `Edebiyat & Kurgu`, yetişkin/genel okur anlatı rafıdır; romanın polisiye,
  fantastik, romantik gibi türleri facet veya gelecek L3'tür.
- `Çocuk & Gençlik`, yaşa uygunluk, resimleme ve okuma seviyesi nedeniyle ayrı
  product schema ister; tema yine facet'tir.
- `Eğitim & Ders` müfredat/öğretim ürünüdür; `Sınav Hazırlık` ise belirli sınava ve
  hazırlık biçimine göre satın alınır. Sınavın adı category yerine facet/L3 adayıdır.
- `Akademik & Mesleki`, disiplin, seviye, güncel baskı ve uzmanlık şemasıyla genel
  araştırma/incelemeden ayrılır.
- `Araştırma, İnceleme & Düşünce`; tarih, toplum, felsefe, din, politika ve bilim
  gibi non-fiction alanlarını major shelf olarak taşır; her konu L2 değildir.
- `Kişisel Gelişim & Yaşam`; aile, psikoloji-popüler yaşam, sağlık farkındalığı ve
  yaşam pratiği kitaplarını toplar; tıbbi tedavi ürünü değildir.
- `Sanat, Kültür & Hobi`; sanat kuramı, fotoğraf, müzik, yemek, gezi ve uygulamalı
  hobi yayınları için major shelf'tir.
- `Çizgi Roman & Manga`, format ve müşteri arama niyeti çok güçlü olduğu için ayrı
  L2'dir; yaş, tema ve menşe facet kalır.
- `Dil Öğrenimi & Sözlükler`, kitabın yazıldığı dilden değil öğrenme/başvuru
  işlevinden doğar. Yabancı dilde basılmış roman kendi shelf'inde kalır.

## 7. Inclusions

| L2 | Dahil olan ana ürünler |
|---|---|
| Edebiyat & Kurgu | Roman, öykü, şiir, deneme, tiyatro eseri, klasikler ve edebi anlatı |
| Çocuk & Gençlik Kitapları | Resimli kitap, ilk okuma, çocuk öykü/romanı, gençlik kurgu ve yaşa uygun etkinlik kitabı |
| Eğitim & Ders Kitapları | Okul ders kitabı, yardımcı kaynak, konu anlatımı, çalışma kitabı ve öğretmen kaynağı |
| Sınav Hazırlık Kitapları | Soru bankası, deneme, çıkmış soru ve sınav odaklı konu anlatım seti |
| Akademik & Mesleki Kitaplar | Üniversite ders kitabı, bilimsel monografi, hukuk/tıp/mühendislik ve mesleki başvuru kitabı |
| Araştırma, İnceleme & Düşünce | Tarih, felsefe, din/mitoloji, politika, toplum, popüler bilim ve biyografi/inceleme |
| Kişisel Gelişim & Yaşam | Kişisel gelişim, aile/ilişki, popüler psikoloji, sağlık farkındalığı ve gündelik yaşam rehberi |
| Sanat, Kültür & Hobi Kitapları | Görsel sanat, mimari, müzik, sinema, fotoğraf, yemek, gezi ve uygulamalı hobi kitabı |
| Çizgi Roman & Manga | Grafik roman, çizgi roman albümü, manga ve çizgi anlatı antolojisi |
| Dil Öğrenimi & Sözlükler | Dil öğretim kitabı, gramer, kelime çalışması, konuşma kılavuzu, iki/tek dilli sözlük |

## 8. Exclusions

- E-kitap, sesli kitap, online eğitim, app erişimi ve digital subscription:
  **digital/service scope — V1 physical Product Taxonomy dışında**.
- Defter, ajanda, kalem, kitap ayracı ve genel kitap aksesuarı: **Kırtasiye & Ofis**.
- Sadece dekoratif sahte kitap/kutu: ana işlevine göre **Ev & Yaşam**.
- Antika/nadir koleksiyon nesnesi olarak satılan eser: **Antika & Koleksiyon**;
  sıradan ikinci el fiziksel kitap için seller/condition facet ve owner policy gerekir.
- Dergi, gazete ve süreli yayın: L1 adıyla semantik uyumu owner tarafından
  netleşene kadar bu 10 L2'ye sessizce atanmaz.
- Kitap yanında kurs, danışmanlık veya üyelik satışı: hizmet kısmı product taxonomy
  değildir; fiziksel kitabın primary ataması değişmez.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Kırtasiye & Ofis | Okunmak/öğrenmek için yayımlanmış, ISBN'li fiziksel kitap burada; yazmak/planlamak/uygulamak için boş veya sarf niteliğindeki defter, ajanda ve kırtasiye orada. |
| Oyuncak | Hikâye/öğrenme primary olan basılı kitap burada; oyun mekanizması/oyuncak primary ise Oyuncak. Etkinlik kitabında ana ürün ve tekrar kullanılabilir oyun parçaları değerlendirilir. |
| Sağlık & Medikal | Sağlık konulu kitap burada; tıbbi cihaz/sarf Sağlık & Medikal. Kitap içeriği tedavi ürünü iddiası yaratmaz. |
| Elektronik | Fiziksel kitap burada; e-reader cihazı Bilgisayar & Tablet; digital içerik V1 dışında. |
| Antika & Koleksiyon | Okuma ürünü olarak normal kitap burada; koleksiyon/antika değeri primary ise Antika & Koleksiyon. |
| Sanat & Hobi malzemeleri | Sanat/hobi hakkında kitap burada; boya, fırça, tuval ve craft malzemesi Kırtasiye & Ofis veya ilgili L1. |

## 10. Category vs facet

Aşağıdakiler normalde facet/search alanıdır:

- yazar, editör, çevirmen, yayınevi ve seri;
- ISBN, baskı yılı/sayısı, cilt tipi, sayfa sayısı ve fiziksel format;
- basım dili ve orijinal dil;
- genre/tema: polisiye, romantik, fantastik, bilimkurgu, tarihî, korku vb.;
- subject/disiplin, hedef yaş, okuma seviyesi, sınıf, ders;
- sınav adı/yılı, soru türü, video çözüm varlığı;
- akademik seviye, meslek alanı, curriculum/müfredat uyumu;
- yeni/ikinci el condition ve set/tekil durumu.

`Genre`, çok-değerli olabilir. Tek primary shelf seçimi için ürünün baskın hedef
kitlesi, yayıncı metadata'sı ve ana satış amacı kullanılır; facetler diğer aramaları
korur.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Edebiyat & Kurgu | roman, edebi eser, kurgu, klasik kitap |
| Çocuk & Gençlik Kitapları | çocuk kitabı, gençlik kitabı, ilk okuma, okul öncesi kitap |
| Eğitim & Ders Kitapları | yardımcı kaynak, ders kitabı, çalışma kitabı, konu anlatım |
| Sınav Hazırlık Kitapları | sınav kitabı, soru bankası, deneme, çıkmış sorular |
| Akademik & Mesleki Kitaplar | akademik kitap, üniversite kitabı, meslek kitabı, monografi |
| Araştırma, İnceleme & Düşünce | inceleme kitabı, tarih, felsefe, düşünce, popüler bilim |
| Kişisel Gelişim & Yaşam | kişisel gelişim, yaşam rehberi, aile, popüler psikoloji |
| Sanat, Kültür & Hobi Kitapları | sanat kitabı, kültür, yemek kitabı, gezi, hobi kitabı |
| Çizgi Roman & Manga | çizgi roman, grafik roman, manga, comic |
| Dil Öğrenimi & Sözlükler | yabancı dil kitabı, dil öğrenme, gramer, sözlük, konuşma kılavuzu |

`Yabancı kitap` kontrollü alias olarak doğrudan L2'ye bağlanmaz; kullanıcı yabancı
dilde roman arıyorsa `Edebiyat & Kurgu + basım dili` sonucu üretmelidir.

## 12. Policy/compliance

- Standart fiziksel kitaplar genel olarak **NORMAL** sınıfına adaydır.
- Yaş derecelendirmesi, yetişkin içerik, yasaklı yayın, telif/kaçak baskı ve ithalat
  konusu category derinliği değil seller/listing policy kontrolüdür.
- Cinsel uyarım ürünü veya yetişkin fiziksel ürün, kitap kılıfıyla bu domain'e
  sokulmaz; exact product ve içerik **LEGAL_REVIEW_REQUIRED** olabilir.
- Korsan fotokopi, yetkisiz PDF çıktısı veya lisanssız çoğaltım **EXCLUDED** önerilir.
- Sağlık, hukuk veya finans kitabı profesyonel hizmet/garanti değildir; yanıltıcı
  ürün iddiası ayrı content policy kontrolüdür.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Yabancı dilde roman | Edebiyat & Kurgu; `basım dili` facet. Dil Öğrenimi değildir. |
| İngilizce gramer kitabı | Dil Öğrenimi & Sözlükler; hedef dil facet. |
| Çocuklar için İngilizce etkinlik kitabı | Baskın amaç dil öğretimiyse Dil Öğrenimi; yaş facet. Genel çocuk hikâyesiyse Çocuk & Gençlik. |
| TYT matematik soru bankası | Sınav Hazırlık; sınav ve ders facetleri. |
| 8. sınıf matematik yardımcı kaynak | Eğitim & Ders; sınav odaklıysa Sınav Hazırlık. Metadata kuralı owner tarafından tanımlanmalı. |
| Akademik tarih monografisi | Akademik & Mesleki veya Araştırma/İnceleme ayrımı hedef seviye ve yayın tipine göre; deterministic rule gerekir. |
| Çocuk manga | Çizgi Roman & Manga primary; hedef yaş facet. Owner çocuk rafı önceliğini farklı kararlaştırabilir. |
| Boyama/etkinlik kitabı | Ciltli/basılı tüketilebilir kitap primary ise Çocuk & Gençlik; malzeme/oyuncak seti primary ise Kırtasiye/Oyuncak. |
| Kitap + online video kodu | Fiziksel kitap primary ise ilgili L2; dijital hak accessory entitlement. Salt dijital ürün excluded. |
| Dergi/süreli yayın | Kitap L1 altında ayrı L2 mi yoksa ayrı policy/domain mi olacağı owner decision. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- Edebiyat & Kurgu → Roman; Öykü; Şiir; Deneme; Tiyatro.
- Çocuk & Gençlik → Okul Öncesi; İlk Okuma; Çocuk Edebiyatı; Gençlik Edebiyatı.
- Eğitim & Ders → Okul Öncesi Eğitim; İlkokul; Ortaokul; Lise; Öğretmen Kaynakları.
- Sınav Hazırlık → Okul Sınavları; Lise Geçiş; Üniversite Giriş; Kamu/Meslek;
  Yabancı Dil Sınavları.
- Akademik & Mesleki → Hukuk; Sağlık Bilimleri; Mühendislik; Sosyal Bilimler;
  İşletme/Ekonomi.
- Araştırma, İnceleme & Düşünce → Tarih; Felsefe; Din & Mitoloji; Toplum;
  Popüler Bilim; Biyografi.
- Sanat, Kültür & Hobi → Sanat; Müzik; Sinema; Fotoğraf; Yemek; Gezi; El Sanatları.

Genre, dil, yazar, yayınevi, sınıf ve sınav yılı L4'e zorlanmaz.

## 15. Owner decisions

1. Exact 10 L2 adı ve sırası onaylanmalı.
2. `Çizgi Roman & Manga` için format-first primary shelf kuralı, çocuk hedefli
   eserlerde de geçerli mi kararlaştırılmalı.
3. Dergi, gazete ve süreli yayınların **Kitap** L1 altında ayrı L2 olarak eklenip
   eklenmeyeceği belirlenmeli.
4. Akademik monografi ile genel araştırma/inceleme ayrımında metadata önceliği
   tanımlanmalı.
5. Eğitim kaynağı ile sınav hazırlık kaynağı arasında `explicit exam target`
   eşiği kesinleştirilmeli.
6. İkinci el sıradan kitap ile antika/koleksiyon kitabı için age/value/edition
   policy eşiği belirlenmeli.

Owner onayı olmadan bu proposal **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **10**
- Normalized duplicate L2: **0**
- Yazar/yayınevi/marka-as-category: **0**
- Basım dili-as-category: **0**
- Genre multi-value facet architecture: **DOCUMENTED**
- One primary shelf rule: **DOCUMENTED**
- Physical/digital boundary: **PASS**
- Kırtasiye leakage: **0**
- Service/subscription leakage: **0**
- Max future depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`BOOKS_L2_ARCHITECTURE: PASS`

`BOOKS_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
