# Ayakkabı L2 Taksonomi Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW**

- Canonical L1: `Ayakkabı`
- Önerilen L2 sayısı: **8**
- Bu belge yalnız L2 mimarisini önerir; owner onayı veya runtime implementasyonu değildir.
- Full L3/L4 ağacı bu görev kapsamında değildir. Aşağıdaki alt seviye örnekleri yalnız genişleyebilirlik kontrolüdür.

## 2. Scope

Bu öneri, Türkiye'deki yerel ayakkabı mağazalarının ürünlerinin müşteri tarafından anlaşılır biçimde bulunmasını amaçlar. Ayakkabının kullanım biçimini ana kategori ekseni; cinsiyet, numara, renk, marka ve malzemeyi facet ekseni kabul eder.

Hedefler:

- Günlük müşteri dilini korumak.
- Spor, klasik, mevsimlik ve güvenlik ayakkabılarının farklı alışveriş niyetlerini ayırmak.
- Çocuk/bebek ayakkabılarının beden ve güvenlik gereksinimlerini yönetilebilir bir dalda toplamak.
- Küçük ayakkabı bakım ürünlerini ayrı L1'lere sızdırmadan bulunabilir kılmak.

## 3. Sources reviewed

| Kaynak | Kullanılan sinyal | Sınırlama |
|---|---|---|
| [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | `Apparel & Accessories > Shoes` ve `Shoe Accessories` ayrımı; ürün tipi ile aksesuar ayrımı | Kamuya açık dosyanın sürümü 2021-09-21; Türkiye müşteri dili için tek başına yeterli değil |
| [Google Merchant Center kategori rehberi](https://support.google.com/merchants/answer/6324436?hl=tr) | En spesifik uygun kategori ve tek ürün sınıflandırması yaklaşımı | Bir mağaza gezinme taksonomisi değil |
| [n11 Ayakkabı & Çanta](https://www.n11.com/ayakkabi-ve-canta) | Türkiye'deki ayakkabı türleri ile cinsiyet, numara, renk ve marka filtrelerinin pratik ayrımı | Marketplace merchandising yapısı aşırı parçalı olabilir |
| [Hepsiburada ayakkabı türleri rehberi](https://www.hepsiburada.com/hayatburada/beyaz-ayakkabi-boyanir-mi/) | Bot, spor, günlük ve malzeme/bakım diline dair yerel kullanım | Tam kategori ağacı değil; içerik sinyali |
| [ISO 20345:2021](https://www.iso.org/standard/73222.html) | İş güvenliği ayakkabılarının ayrı güvenlik/uygunluk gereksinimi | Kategori adı değil, politika kanıtı |

Kaynaklar birebir kopyalanmamıştır. Marketplace yapıları, yerel mağaza keşfi ve ilerideki facet modeli birlikte değerlendirilmiştir.

## 4. Recommended L2 count

**8 L2** önerilir. Bu sayı:

- `Ayakkabı Ürünleri` gibi aşırı geniş tek düğümden kaçınır.
- Sneaker, loafer, babet veya çizme gibi her küçük türü L2 yapmaz.
- Yerel mağazaların en sık taşıdığı ürün gruplarını anlamlı raflara ayırır.

## 5. Exact L2 list

1. Günlük Ayakkabılar
2. Spor Ayakkabıları
3. Klasik Ayakkabılar
4. Bot & Çizmeler
5. Sandalet & Terlikler
6. Çocuk & Bebek Ayakkabıları
7. İş & Güvenlik Ayakkabıları
8. Ayakkabı Bakım & Aksesuarları

Sıra, yaygın müşteri talebinden daha özel kullanım ve yardımcı ürüne doğru ilerler.

## 6. Granularity rationale

- `Günlük`, `spor` ve `klasik`, aynı ürün tipinin yalnız stil varyantları değildir; müşterinin kullanım niyetini ve mağaza rafını değiştirir.
- `Bot & Çizmeler` ile `Sandalet & Terlikler`, mevsim ve form bakımından yeterince güçlü ayrı kümelerdir.
- `Çocuk & Bebek Ayakkabıları`, yaşa göre her ürünü ayırma istisnasıdır; beden sistemi, gelişim ve ürün güvenliği bağlamı farklıdır.
- `İş & Güvenlik Ayakkabıları`, sertifika ve koruyucu özellikleri nedeniyle genel bottan ayrılır.
- Bakım ve ayakkabıya özgü aksesuarlar, ana ayakkabı listelerini kirletmemek için tek yardımcı L2'de tutulur.

## 7. Inclusions

### 1. Günlük Ayakkabılar

Günlük sneaker olmayan rahat modeller, loafer, mokasen, babet, espadril ve günlük slip-on ürünler.

### 2. Spor Ayakkabıları

Koşu, yürüyüş, basketbol, futbol, tenis ve antrenman için üretilen ayakkabılar. Spor dalı ileride facet veya L3 olabilir.

### 3. Klasik Ayakkabılar

Oxford, derby, klasik loafer, resmi topuklu ve davet/iş giyimine yönelik ayakkabılar.

### 4. Bot & Çizmeler

Günlük bot, yağmur botu, kar botu, çizme ve bilek üstü kışlık ayakkabılar. Sertifikalı iş botu L2 7'ye gider.

### 5. Sandalet & Terlikler

Sandalet, plaj terliği, ev terliği, sabo ve benzeri açık/kolay giyilen ayakkabılar.

### 6. Çocuk & Bebek Ayakkabıları

İlk adım ayakkabısı, çocuk sneaker, okul ayakkabısı, çocuk botu ve çocuk sandalet/terlikleri.

### 7. İş & Güvenlik Ayakkabıları

Koruyucu burunlu iş ayakkabıları, kaymaz profesyonel ayakkabılar ve güvenlik standardı iddiası taşıyan botlar.

### 8. Ayakkabı Bakım & Aksesuarları

Bağcık, tabanlık, ayakkabı çekeceği, kalıp, ayakkabı fırçası, cila ve ayakkabıya özgü bakım setleri.

## 8. Exclusions

- Çanta, cüzdan, kemer ve genel moda aksesuarları → `Çanta & Aksesuar`.
- Spor kıyafetleri → `Giyim`; spor ekipmanları → `Spor & Outdoor`.
- Medikal ortopedik cihaz veya tedavi iddialı ürün → `Sağlık & Medikal` ve ilgili politika incelemesi.
- Çorap ve genel giyim tamamlayıcıları → `Giyim`.
- Kostümün ayrılmaz parçası olan, normal ayakkabı olarak kullanılmayan parti ürünü → `Hediyelik & Parti`.
- Ürün olmayan tamir, boya, lostra veya kişiselleştirme hizmeti → ürün taksonomisinin dışında.
- Doğa yürüyüşü tozluğu gibi ayakkabı olmayan uzman outdoor koruması → `Spor & Outdoor`.

## 9. Cross-domain boundaries

| Sınır | Canonical yönlendirme kuralı |
|---|---|
| Ayakkabı vs Spor & Outdoor | Ürün ayakta giyilen bir ayakkabıysa burada kalır; spor dalı facet/L3 olur. Ayakkabı olmayan spor ekipmanı Spor & Outdoor'a gider. |
| Ayakkabı vs Giyim | Ayakkabı burada; çorap, tayt ve giysi Giyim'de kalır. |
| Ayakkabı vs Anne & Bebek | Bebek/çocuk ayakkabısı burada; bebek taşıma, bakım ve beslenme ürünü Anne & Bebek'tedir. |
| Ayakkabı vs Sağlık & Medikal | Konfor tabanlığı burada olabilir; teşhis/tedavi iddialı ortez ve medikal cihaz Sağlık & Medikal'e gider. |
| Ayakkabı vs Hediyelik & Parti | Giyilebilir gerçek ayakkabı burada; yalnız kostüm/parti dekoru niteliğindeki ayak aksesuarı Hediyelik & Parti'dedir. |
| Ayakkabı vs Hırdavat & Yapı Market | Sertifikalı kişisel iş ayakkabısı burada; iş güvenliği ekipmanı ve donanımının geri kalanı Hırdavat sınırında ayrıca değerlendirilir. |

Her ürün tek bir primary leaf almalıdır. Mağaza türü veya satış kanalı sınıflandırmayı değiştirmez.

## 10. Category vs facet

Aşağıdakiler L2 değildir:

- Cinsiyet sunumu: kadın, erkek, unisex.
- Numara ve kalıp: 38, wide fit, dar kalıp.
- Renk ve desen.
- Marka.
- Malzeme: deri, süet, tekstil, vegan malzeme.
- Bağlama tipi: bağcıklı, cırt cırtlı, fermuarlı.
- Topuk yüksekliği ve taban tipi.
- Su geçirmezlik, kaymazlık ve sertifika gibi doğrulanabilir özellikler.
- Sezon, kullanım zemini ve spor dalı.

`Sneaker`, `koşu`, `ilk adım` gibi terimler kategori seçimine yardımcı olabilir; fakat marka/model/renk ile aynı şekilde kontrolsüz kategori çoğaltmamalıdır.

## 11. Search synonyms

| Canonical terim | Arama eş anlamlıları / halk dili |
|---|---|
| Spor Ayakkabıları | sneaker, koşu ayakkabısı, yürüyüş ayakkabısı, trainer |
| Günlük Ayakkabılar | casual, loafer, mokasen, babet, slip-on |
| Bot & Çizmeler | postal, yağmur çizmesi, kar botu, bilek botu |
| Sandalet & Terlikler | plaj terliği, ev terliği, sabo, parmak arası |
| Çocuk & Bebek Ayakkabıları | ilk adım, okul ayakkabısı, çocuk sneaker |
| İş & Güvenlik Ayakkabıları | iş ayakkabısı, çelik burun, koruyucu burun, kaymaz iş ayakkabısı |
| Ayakkabı Bakım & Aksesuarları | bağcık, tabanlık, cila, lostra seti, ayakkabı kalıbı |

Bu eş anlamlılar yalnız arama sözlüğü ipucudur; backend implementasyonu yapılmamıştır.

## 12. Policy notes

- Normal moda ayakkabıları: `NORMAL`.
- Güvenlik standardı, koruyucu burun, elektriksel direnç veya kaymazlık iddiası: belge/iddia doğrulaması gerektirir; desteklenmeyen iddia yayınlanmamalıdır.
- Medikal, ortopedik tedavi veya ağrı giderme iddiası: `REGULATED` ya da `LEGAL_REVIEW_REQUIRED` değerlendirmesine yönlendirilmelidir.
- Çocuk ürünlerinde yaş, beden ve malzeme bilgisinin açık olması önerilir.
- Taklit marka, yanıltıcı sertifika ve ürün olmayan hizmet listelemesi politika düzeyinde engellenmelidir.

## 13. Ambiguous products

| Ürün | Önerilen yer | Gerekçe / owner konusu |
|---|---|---|
| Trekking ayakkabısı | Spor Ayakkabıları | Ana kimliği ayakkabıdır; outdoor kullanımı facet olur. Owner isterse ileride L3 açabilir. |
| Çelik burunlu iş botu | İş & Güvenlik Ayakkabıları | Mevsimsel bottan önce güvenlik amacı belirleyicidir. |
| Ortopedik konfor tabanlığı | Ayakkabı Bakım & Aksesuarları | Tedavi iddiası yoksa yardımcı ayakkabı ürünüdür. Medikal iddia varsa Sağlık & Medikal. |
| Yağmur galoşu | Ayakkabı Bakım & Aksesuarları | Ayakkabı üstü koruma; bağımsız çizme formundaysa Bot & Çizmeler. |
| Kostüm ayakkabısı | Ayakkabı veya Hediyelik & Parti | Normal giyilebilir ürünse Ayakkabı; yalnız kostüm aksesuarıysa Hediyelik & Parti. |
| İş terliği / profesyonel sabo | İş & Güvenlik veya Sandalet & Terlik | Sertifika/mesleki koruma varsa güvenlik; yoksa ürün formu belirler. |

## 14. Future L3/L4 examples

Yalnız yapısal uygulanabilirlik örnekleri:

- `Spor Ayakkabıları → Koşu Ayakkabıları → Yol Koşusu Ayakkabıları`
- `Bot & Çizmeler → Kışlık Botlar → Kar Botları`
- `Çocuk & Bebek Ayakkabıları → Bebek Ayakkabıları → İlk Adım Ayakkabıları`
- `İş & Güvenlik Ayakkabıları → Koruyucu Burunlu Ayakkabılar`
- `Ayakkabı Bakım & Aksesuarları → Tabanlıklar`

Bu örnekler canonical L3/L4 listesi değildir. Her L2'nin zorunlu aynı derinliğe inmesi beklenmez; maksimum gelecek derinlik L4'tür.

## 15. Open owner decisions

1. Sertifikalı trekking ayakkabıları spor ayakkabısı altında mı kalmalı, yoksa ileride ayrı bir `Outdoor Ayakkabıları` L3'ü mü açılmalı?
2. Konfor tabanlığı ile medikal ortez sınırı için hangi iddia/sertifika alanları zorunlu olmalı?
3. İş güvenliği ürünleri Ayakkabı altında mı kalmalı, yoksa ileride Hırdavat ile ortak yönlendirme kuralı mı isteniyor?
4. Kostüm ayakkabısında “normal kullanım mümkün” ölçütünü operasyonel olarak hangi alan belirlemeli?

Owner kararı verilmeden bu konular final kabul edilmez.

## 16. Validation summary

- Canonical L1 adı `Ayakkabı` değişmedi: **PASS**
- L2 sayısı 8 ve duplicate L2 yok: **PASS**
- Marka, cinsiyet, numara ve renk kategori yapılmadı: **PASS**
- Spor ayakkabısı ile spor ekipmanı sınırı yazıldı: **PASS**
- Çocuk/bebek ayakkabısının Anne & Bebek sınırı yazıldı: **PASS**
- Hizmetler ürün taksonomisinden çıkarıldı: **PASS**
- Güvenlik/medikal politika riski fail-closed kaydedildi: **PASS**
- Gelecek L3/L4 genişlemesi gösterildi, full ağaç finalize edilmedi: **PASS**
- Runtime/Figma/backend değişikliği: **NONE**

`SHOES_L2_STATE: PROPOSED FOR OWNER REVIEW`

`SHOES_L2_COUNT: 8`

`MAX_FUTURE_DEPTH: 4`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`SHOES_READY_FOR_OWNER_REVIEW: YES`
