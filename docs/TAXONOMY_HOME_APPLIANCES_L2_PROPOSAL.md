# Beyaz Eşya & Ev Aletleri L2 Taksonomi Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW**

- Canonical L1: `Beyaz Eşya & Ev Aletleri`
- Önerilen L2 sayısı: **10**
- Bu belge yalnız L2 önerisidir; owner-final veya runtime implementasyonu değildir.
- L3/L4 örnekleri tam alt ağaç oluşturmaz.

## 2. Scope

Bu alan, ev işini doğrudan yapan elektrikli/enerjili bitmiş cihazları ve bu cihazlara özgü kullanıcı tarafından değiştirilebilir aksesuar, filtre ve sarfları kapsar. Büyük–küçük cihaz ayrımından çok müşteri işi esas alınır: saklama, yıkama, pişirme, temizlik, iklim, sıcak su, tekstil ve kişisel bakım.

“Akıllı” veya bağlantılı olmak ürünü otomatik olarak Elektronik yapmaz. Ürünün birincil işi ev işi ise bu L1'de kalır.

## 3. Sources reviewed

| Kaynak | Kullanılan sinyal | Sınırlama |
|---|---|---|
| [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | `Household Appliances` altında iklimlendirme, temizlik, çamaşır ve su ısıtma; `Kitchen Appliances` altında pişirme/hazırlama ayrımları | Kamu sürümü 2021-09-21; EsnaftaVar L1 yapısında iki bölüm birlikte ele alınır |
| [Google Merchant Center kategori rehberi](https://support.google.com/merchants/answer/6324436?hl=tr) | En spesifik ürün kategorisi ve ürün kimliği yaklaşımı | Gezinme ağacı değildir |
| [n11 Beyaz Eşya](https://www.n11.com/beyaz-esya) | Buzdolabı, çamaşır/bulaşık/kurutma, derin dondurucu, iklim, su sebili, pişirme ve ankastre yerel dili | Marketplace ayrımı kampanya ve merchandising etkisi taşır |
| [Avrupa Komisyonu ürün güvenliği](https://commission.europa.eu/topics/business-and-industry/product-safety_en) | Elektrikli tüketici ürünlerinde genel güvenlik ve geri çağırma bağlamı | Türkiye için doğrudan kategori veya mevzuat listesi değildir |

Kaynak adları birebir kopyalanmamış; yerel perakende dili, cihazın yaptığı iş ve mevcut EsnaftaVar L1 sınırları esas alınmıştır.

## 4. Recommended L2 count

**10 L2** önerilir. Büyük cihazları tek bir `Beyaz Eşya`, küçük cihazları tek bir `Küçük Ev Aletleri` düğümünde toplamak müşteri niyetini aşırı geniş bırakır. Buna karşılık her cihazı L2 yapmak gereksiz parçalanma yaratır.

## 5. Exact L2 list

1. Soğutma & Gıda Saklama Cihazları
2. Çamaşır & Bulaşık Bakım Cihazları
3. Büyük Pişirme Cihazları
4. Küçük Mutfak Aletleri
5. Temizlik Cihazları
6. İklimlendirme & Hava Kalitesi
7. Su Isıtma & Sıcak Su Cihazları
8. Ütü & Tekstil Bakım Cihazları
9. Elektrikli Kişisel Bakım Cihazları
10. Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri

## 6. Granularity rationale

- Soğutma, yıkama ve büyük pişirme cihazları farklı kurulum, teslimat ve satış sonrası ihtiyaçlara sahiptir.
- Küçük mutfak aletleri aynı tezgâh/yiyecek hazırlama niyetinde sağlıklı L3'lere genişleyebilir.
- Temizlik ile iklim/hava kalitesi birbirinden ayrı müşteri görevleridir.
- Su ısıtma, sabit tesisat sınırı nedeniyle ayrıca görünür tutulur.
- Elektrikli kişisel bakım cihazları kozmetik sarfından ve medikal cihazdan ayrılır.
- Kullanıcı tarafından değiştirilebilen filtre/sarf, cihaz listelerini bozmadan tek yardımcı L2'de bulunur.

## 7. Inclusions

### 1. Soğutma & Gıda Saklama Cihazları

Buzdolabı, derin dondurucu, şarap soğutucu ve elektrikli soğutma dolabı.

### 2. Çamaşır & Bulaşık Bakım Cihazları

Çamaşır makinesi, kurutma makinesi, bulaşık makinesi ve yıkama-kurutma birleşik cihazları.

### 3. Büyük Pişirme Cihazları

Fırın, ocak, davlumbaz, aspiratör, ankastre set ve bağımsız büyük pişirici.

### 4. Küçük Mutfak Aletleri

Kahve makinesi, kettle, blender, mikser, tost makinesi, airfryer, ekmek yapma ve benzeri tezgâh üstü elektrikli cihazlar.

### 5. Temizlik Cihazları

Elektrikli süpürge, robot süpürge, buharlı temizleyici, halı yıkama ve zemin bakım cihazları.

### 6. İklimlendirme & Hava Kalitesi

Klima, vantilatör, elektrikli ısıtıcı, nemlendirici/nem alıcı, hava temizleyici ve ev tipi fan.

### 7. Su Isıtma & Sıcak Su Cihazları

Şofben, termosifon ve bitmiş ev tipi sıcak su cihazı. Tesisat parçası dahil değildir.

### 8. Ütü & Tekstil Bakım Cihazları

Ütü, buharlı düzleştirici, kumaş tüy temizleme ve ev tipi tekstil bakım cihazları.

### 9. Elektrikli Kişisel Bakım Cihazları

Saç kurutma/şekillendirme, tıraş, epilasyon ve kozmetik amaçlı elektrikli bakım cihazları; medikal iddiası olmayan ürünler.

### 10. Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri

Süpürge torbası, cihaz filtresi, kullanıcı değişimli aparat, makine kireç önleyici ve belirli cihaza bağlı tüketim ürünü.

## 8. Exclusions

- Tencere, tava, tabak ve elektriksiz mutfak gereci → `Züccaciye & Mutfak`.
- Mobilya, pasif ev eşyası ve dekor → `Ev & Yaşam`.
- Akıllı ampul, akıllı priz, bağlı kilit ve güvenlik kamerası → `Elektronik > Akıllı Ev & Güvenlik`.
- Genel kablo, adaptör, pil ve powerbank → `Elektronik > Güç, Şarj & Bağlantı`.
- Elektronik kart, röle, sensör ve devre elemanı → `Elektronik > Elektronik Bileşenler`.
- Tesisat borusu, vana ve montaj malzemesi → `Hırdavat & Yapı Market`.
- Kozmetik, şampuan ve bakım sıvısı → `Kozmetik & Kişisel Bakım`.
- Teşhis/tedavi amacı baskın cihaz → `Sağlık & Medikal`.
- Kurulum, tamir, bakım veya kuaför hizmeti → ürün taksonomisi dışında.

## 9. Cross-domain boundaries

| Sınır | Canonical yönlendirme kuralı |
|---|---|
| Ev Aletleri vs Elektronik | Ev işini yapan bitmiş cihaz burada; genel bağlantı/akıllı ev/görüntü-ses ürünü Elektronik'te. “Akıllı” tek başına yönlendirme kuralı değildir. |
| Ev Aletleri vs Ev & Yaşam | Enerjili ev işi cihazı burada; pasif eşya, dekor ve ev tekstili Ev & Yaşam'da. |
| Ev Aletleri vs Züccaciye & Mutfak | Elektrikli/enerjili yiyecek hazırlama cihazı burada; elektriksiz pişirme ve servis gereci Züccaciye'de. |
| Ev Aletleri vs Hırdavat & Yapı Market | Bitmiş tüketici cihazı burada; boru, vana, kablo tesisatı ve montaj donanımı Hırdavat'ta. |
| Ev Aletleri vs Kozmetik | Elektrikli bakım cihazı burada; sürülen/tüketilen bakım ürünü Kozmetik'te. |
| Ev Aletleri vs Sağlık & Medikal | Günlük bakım cihazı burada; tanı, tedavi, rehabilitasyon veya tıbbi iddia baskınsa Sağlık & Medikal. |

## 10. Category vs facet

Aşağıdakiler L2 değil facet/attribute olmalıdır:

- Marka ve model.
- Ankastre/solo/tezgâh üstü kurulum tipi.
- Enerji sınıfı, kapasite, hacim ve ölçü.
- Renk ve yüzey malzemesi.
- Güç, voltaj, program sayısı ve ses seviyesi.
- Wi‑Fi/uygulama/akıllı ev uyumluluğu.
- Filtre türü, torbalı/torbasız yapı.
- Garanti, servis ağı ve kurulum gereksinimi.

## 11. Search synonyms

| Canonical terim | Arama eş anlamlıları / halk dili |
|---|---|
| Soğutma & Gıda Saklama | buzdolabı, derin dondurucu, freezer, mini buzdolabı |
| Çamaşır & Bulaşık Bakım | çamaşır makinesi, kurutma, bulaşık makinesi, washer dryer |
| Büyük Pişirme | fırın, ocak, ankastre, davlumbaz, aspiratör |
| Küçük Mutfak Aletleri | kettle, blender, mikser, airfryer, kahve makinesi |
| Temizlik Cihazları | süpürge, robot süpürge, dikey süpürge, buharlı temizleyici |
| İklimlendirme & Hava Kalitesi | klima, vantilatör, ısıtıcı, hava temizleyici, nem makinesi |
| Su Isıtma & Sıcak Su | şofben, termosifon, ani su ısıtıcı |
| Ütü & Tekstil Bakım | ütü, buhar kazanlı ütü, steamer, tüy temizleyici |
| Elektrikli Kişisel Bakım | saç kurutma, düzleştirici, tıraş makinesi, epilatör |

## 12. Policy notes

- Standart tüketici cihazları: `NORMAL`; zorunlu güvenlik, enerji ve uygunluk bilgilerinin doğruluğu ayrıca sağlanmalıdır.
- Gazlı, yüksek güçlü veya sabit tesisata bağlanan cihazlarda kurulum ve yetkili servis uyarıları gerekir.
- Medikal/terapötik iddialı kişisel bakım cihazı: `REGULATED` veya `LEGAL_REVIEW_REQUIRED`.
- Ozon/iyonizasyon, sterilizasyon ve “hastalık yok eder” gibi sağlık iddiaları fail-closed incelenmelidir.
- Yedek batarya, basınçlı kartuş veya kimyasal sarf taşıma güvenliği gerektirebilir.
- Ürün ilanı içinde servis/kurulum satışı ayrı ürün gibi modellenmemelidir.

## 13. Ambiguous products

| Ürün | Önerilen yer | Gerekçe / owner konusu |
|---|---|---|
| Robot süpürge | Temizlik Cihazları | Bağlantılı olması Elektronik'e taşımaz; birincil işi temizliktir. |
| Akıllı klima | İklimlendirme & Hava Kalitesi | Akıllı bağlantı facet'tir. |
| Kahve makinesi | Küçük Mutfak Aletleri | Ev işi/yiyecek hazırlama cihazıdır. |
| Şofben/termosifon | Su Isıtma & Sıcak Su Cihazları | Bitmiş cihaz burada; tesisat parçası Hırdavat'ta. Sabit kurulum policy gerektirir. |
| Elektrikli diş fırçası | Elektrikli Kişisel Bakım Cihazları | Günlük bakım; tıbbi iddia yoksa burada. |
| Masaj cihazı | Owner kararı gerekli | Rahatlama amaçlı kişisel bakım ile medikal/fitness cihazı sınırı iddiaya bağlıdır. |
| Airfryer kâğıdı | Ev Aleti Aksesuar/Sarf veya Züccaciye | Belirli cihaza özgüyse burada; genel pişirme kâğıdı Züccaciye/sarf alanında. |
| İç elektronik kontrol kartı | Elektronik Bileşenler / Hırdavat | Son kullanıcı aksesuarı değil, onarım parçasıdır; burada önerilmez. |

## 14. Future L3/L4 examples

- `Soğutma & Gıda Saklama Cihazları → Buzdolapları → Kombi Tipi Buzdolapları`
- `Küçük Mutfak Aletleri → Kahve Hazırlama → Espresso Makineleri`
- `Temizlik Cihazları → Elektrikli Süpürgeler → Robot Süpürgeler`
- `İklimlendirme & Hava Kalitesi → Hava Temizleme → Hava Temizleyiciler`
- `Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri → Filtreler → Süpürge Filtreleri`

Örnekler final L3/L4 listesi değildir; maksimum gelecek derinlik L4'tür.

## 15. Open owner decisions

1. Sabit tesisata bağlanan şofben/termosifonun ürün sahipliği bu L1'de mi kalmalı, Hırdavat ile hangi eşik kullanılmalı?
2. Masaj ve rahatlama cihazlarında Ev Aletleri, Spor ve Sağlık sınırını hangi iddia/ürün biçimi belirlemeli?
3. Enstrümantal “kişisel bakım” kapsamı elektrikli diş bakımını içerirken oral medikal cihaz sınırı nasıl uygulanmalı?
4. Kullanıcı değişimli cihaz aksesuarı ile profesyonel onarım parçası arasındaki operasyonel alanlar neler olmalı?
5. Büyük ve küçük cihaz ayrımı müşteri navigasyonunda facet olarak ayrıca gösterilmeli mi?

## 16. Validation summary

- Canonical L1 adı değişmedi: **PASS**
- L2 sayısı 10, duplicate yok: **PASS**
- Robot süpürge, klima ve kahve makinesi bu alanda tutuldu: **PASS**
- Akıllı özellik kategori yapılmadı: **PASS**
- Elektronik, Ev, Züccaciye, Hırdavat, Kozmetik ve Sağlık sınırları yazıldı: **PASS**
- Servis/kurulum ürün taksonomisi dışında bırakıldı: **PASS**
- Regülasyon ve güvenlik riskleri fail-closed: **PASS**
- Full L3/L4 finalize edilmedi: **PASS**
- Runtime/Figma/backend değişikliği: **NONE**

`HOME_APPLIANCES_L2_STATE: PROPOSED FOR OWNER REVIEW`

`HOME_APPLIANCES_L2_COUNT: 10`

`MAX_FUTURE_DEPTH: 4`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`HOME_APPLIANCES_READY_FOR_OWNER_REVIEW: YES`
