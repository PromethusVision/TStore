# Bilgisayar Bileşenleri L3/L4 Taksonomi Önerisi

**Durum:** PROPOSED FOR OWNER REVIEW
**Araştırma ve öneri tarihi:** 2026-08-27
**Kapsam:** Yalnız taksonomi, facet ve uyumluluk sözleşmesi; runtime uygulaması değildir.

## 1. Scope

Bu belge aşağıdaki owner-final yolu değiştirmeden, yalnız bu yolun altındaki L3/L4 omurgasını önerir:

```text
Bilgisayar & Tablet (L1)
└── Bilgisayar Bileşenleri (L2)
```

Amaç; fiziksel perakendede anlaşılır, aynı ürünü birden fazla dala kopyalamayan ve ileride uyumluluk kontrollerine veri sağlayabilen bir ürün ağacı kurmaktır. Öneri:

- 9 L3,
- yalnız iki L3 altında gerekçelendirilmiş 7 L4,
- 14 atanabilir leaf,
- ürün türünden ayrılmış facet profilleri,
- kavramsal ve sürümlenebilir uyumluluk ilişkileri,
- kontrollü arama eş anlamlıları

içerir.

Bu belge L1/L2 adlarını, sırasını veya owner-final sınırlarını yeniden açmaz. Stable ID, veritabanı, migration, runtime taxonomy JSON, Flutter, Figma, filtre UI'ı ve parça seçici/öneri motoru bu belgenin kapsamı dışındadır.

### Tasarım ilkeleri

- Her ürün yalnız bir birincil atanabilir leaf'e gider.
- Mümkün olan en spesifik leaf kullanılır; leaf olmayan L3'e ürün atanmaz.
- Marka, model, kapasite, hız, nesil, ölçü, soket ve bağlantı standardı kategori değil facet'tir.
- Ürünün ana işlevi kategori yolunu belirler; fiziksel biçim veya pazarlama etiketi tek başına belirlemez.
- Eksik uyumluluk verisi “uyumlu” sayılmaz; sonuç `unknown` kalır.
- Maksimum derinlik L4'tür.

## 2. Sources

Kaynaklar 2026-08-27 tarihinde yeniden erişilerek incelendi. Platformlar birebir kopyalanmadı; yerel müşteri dili, owner-final L2 sınırları ve tek-leaf ilkesi birlikte değerlendirildi.

| Kaynak | İncelenen kanıt | Bu önerideki kullanımı |
|---|---|---|
| [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Ürün başına tek kategori, ana işleve göre seçim ve mümkün olan en spesifik kategori ilkeleri | Tek birincil leaf ve ana işlev kurallarının dış referansı |
| [Google Product Taxonomy — public text file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | Computer Components altında işlemci, güç kaynağı, soğutma, kasa ve I/O kartları; ayrıca storage/input-device dalları | Küresel ürün ailesi karşılaştırması; EsnaftaVar'ın sibling L2 kararlarına uymayan dallar kopyalanmadı |
| [Trendyol — Bilgisayar Bileşenleri](https://www.trendyol.com/bilgisayar-bilesenleri-x-c103662) | Ekran kartı, RAM, kasa, anakart, işlemci, PSU, ses kartı ve soğutma tipleri; ayrıca SSD/HDD/optik sürücü karışması | Türkiye müşteri adları ve soğutma alt türleri; depolama karışması negatif sınır kanıtı |
| [n11 — Bilgisayar Bileşenleri](https://www.n11.com/bilgisayar/bilgisayar-bilesenleri) | RAM, GPU, soğutma, kasa, anakart, CPU, PSU ve ses kartı; ayrıca Arduino, HDD ve optik sürücü karışması | Yerel dil karşılaştırması; Arduino ve depolama sızıntısının neden düzeltilmesi gerektiğine kanıt |
| Hepsiburada — Bilgisayar Bileşenleri | Doğrudan kategori sayfası denendi ancak bu araştırma oturumunda güvenilir, statik ve tam bir kategori ağacı okunamadı | Okunamayan bir ağaçtan kategori sonucu türetilmedi; kaynak bütünlüğü için sınırlama kaydedildi |
| [Raspberry Pi — Products](https://www.raspberrypi.com/products/) | Bilgisayarlar, compute module'ler ve microcontroller ürünleri aynı üretici içinde ayrı işlevlerle tanımlanıyor | Marka yerine ürün işlevine dayalı SBC/microcontroller ayrımı |
| [Arduino — Micro](https://docs.arduino.cc/hardware/micro) ve [Arduino — UNO R3 SMD](https://docs.arduino.cc/hardware/uno-rev3-smd) | Arduino ürünlerinin açıkça microcontroller board olarak tanımlanması | Arduino/ESP sınıfını bilgisayar SBC leaf'inden dışlama |
| [PCI-SIG — PCI Express Base](https://pcisig.com/specification-overview/pci-express-base) | PCIe'nin sistem ve çevre birimleri için sürümlenen bağlantı/uyumluluk mimarisi | Arayüz nesli, lane ve slot bilgisinin kategori değil sürümlü facet/uyumluluk verisi olması |

### Kaynak bütünlüğü notları

- Google'ın güncel olarak servis ettiği public taxonomy dosyasının kendi başlığı `2021-09-21` sürümünü gösterir. Bu nedenle belge onu “2026 taxonomy sürümü” olarak sunmaz; yalnız 2026-08-27 tarihinde erişilebilen karşılaştırma kaynağı olarak kullanır.
- Trendyol ve n11'in depolama ya da microcontroller ürünlerini bileşen altında göstermesi owner-final EsnaftaVar sınırını geçersiz kılmaz. Bu örnekler kopyalanacak model değil, marketplace sızıntısı olarak değerlendirilmiştir.
- Üretici örnekleri marka kategorisi üretmek için değil, SBC ile microcontroller arasındaki işlev farkını doğrulamak için kullanılmıştır.
- PCIe sürümleri kategori dalı değildir. Standart geliştiğinde facet sözlüğü sürümlenir; kategori ağacı yeniden parçalanmaz.

## 3. L3 proposal

### Önerilen L3 listesi

| Sıra | L3 | Leaf mi? | Karar özeti |
|---:|---|:---:|---|
| 1 | İşlemci | Evet | Yüksek ürün hacmi, belirgin müşteri dili ve ayrı socket/core/TDP profili |
| 2 | Ekran Kartı | Evet | Yüksek hacim; VRAM, boyut, güç ve görüntü çıkışı profili ayrışıyor |
| 3 | Anakart | Evet | CPU/RAM/kasa uyumluluğunun merkezi; socket, chipset ve form factor profili var |
| 4 | RAM Bellek | Evet | Yerleşik müşteri terimi; DDR, kapasite, kit ve form factor profili var |
| 5 | Güç Kaynağı | Evet | Watt, verimlilik, modülerlik ve PSU form factor profili ayrışıyor |
| 6 | Bilgisayar Kasası | Evet | Boş PC kasaları; fiziksel clearance ilişkilerinin ana tarafı |
| 7 | Soğutma | Hayır | Birbirinden anlamlı ürün türlerine ayrılan tekil bir ürün ailesi |
| 8 | Genişleme Kartları | Hayır | Düşük/orta hacimli iç kartları mikro L3 şişmesi olmadan toplar |
| 9 | Tek Kart Bilgisayar (SBC) | Evet | Genel amaçlı işletim sistemi çalıştırabilen kart bilgisayar sınıfı; marka bağımsız ad |

**Önerilen L3 sayısı: 9.**

### Başlangıç hipotezlerinin değerlendirilmesi

| Hipotez | Sonuç | Gerekçe |
|---|---|---|
| İşlemci | L3 | Ayrı ürün ailesi ve güçlü facet profili |
| Ekran Kartı | L3 | Ayrı ürün ailesi ve güçlü fiziksel/elektriksel uyumluluk profili |
| Anakart | L3 | Ayrı ürün ailesi ve uyumluluk merkezidir |
| RAM / Bellek | L3, canonical ad `RAM Bellek` | Slash yerine müşteri aramasını karşılayan tek ad + synonyms |
| Güç Kaynağı | L3 | İç PC PSU'ları için ayrı profil |
| Bilgisayar Kasası | L3 | Boş enclosure; hazır masaüstü bilgisayardan ayrılır |
| Soğutma | L3, leaf değil | Dört anlamlı L4 ile çakışmasız atanabilirlik sağlanır |
| Dahili Depolama | Reddedildi | SSD/HDD/optik sürücü dahil tüm depolama sibling `Veri Depolama` L2'sindedir |
| Ses Kartı | L4 | Genişleme kartı kurulum profilini paylaşır; ayrı L3 gerektirecek ölçek kanıtı yok |
| Ağ Kartı | Reddedildi | Dahili PCIe olsa dahi ana işlevi ağdır; sibling `Ağ & İnternet Ürünleri` L2'sindedir |
| Genişleme Kartları | L3, leaf değil | Ses/yakalama/bağlantı-denetleyici kartları için anlamlı üst dal |
| Raspberry Pi / SBC | Marka bağımsız L3 | Canonical ad `Tek Kart Bilgisayar (SBC)`; Raspberry Pi synonym/örnektir |

## 4. L4 where justified

L4 yalnız L3 düzeyi müşteriyi birbirinden farklı ürün tiplerine yönlendirmeye yetmediğinde kullanılır.

### Soğutma L4

| L4 | Gerekçe | Çakışmayı önleyen leaf kuralı |
|---|---|---|
| İşlemci Soğutucu | Socket ve yük/TDP uyumluluğuyla seçilen hava/pasif CPU soğutucuları | Sıvı devreli AIO/custom ürünler hariç |
| Kasa Fanı | Fan ölçüsü, kalınlık, bağlantı ve hava akışıyla seçilen kasa/radyatör fanları | Tam AIO kit ve CPU heatsink hariç |
| Sıvı Soğutma | AIO kitler ile custom-loop pompa, blok, radyatör ve rezervuar ürünleri | Tek başına kasa fanı ve hava tipi CPU cooler hariç |
| Termal Macun & Ped | Isı transferine özel kurulum/sarf ürünleri; Türkiye müşteri aramasında ayrı ürün türü | Genel yapıştırıcı, elektronik lehim sarfı ve temizlik ürünü hariç |

`İşlemci Soğutucu` ile `Sıvı Soğutma` arasında fiziksel ürün çakışmasını önlemek için sıvı kullanan CPU soğutucuları her zaman `Sıvı Soğutma` leaf'ine gider.

### Genişleme Kartları L4

| L4 | Gerekçe | Çakışmayı önleyen leaf kuralı |
|---|---|---|
| Ses Kartı | Dahili ses işleme/giriş-çıkış kartlarının müşteride yerleşik adı | Harici USB ses arayüzleri ve genel ses cihazları hariç |
| Görüntü Yakalama Kartı | Dahili PCIe video capture/stream kartlarının ana işlevi belirgin | Ekran kartı, TV tuner ve harici capture box hariç |
| Bağlantı & Denetleyici Kartları | USB/Thunderbolt/seri port, HBA/RAID/SATA denetleyici, riser ve benzeri iç genişleme kartları | Ağ kartı, GPU, ses kartı ve capture kartı hariç |

**Önerilen L4 sayısı: 7.**

### Neden daha fazla L4 yok?

- CPU, GPU, anakart, RAM, PSU, kasa ve SBC kendi başına net atanabilir ürün türleridir; alt ayrımlar facet'tir.
- `Intel/AMD`, `DDR4/DDR5`, `ATX/mATX`, `500 W/750 W`, `NVIDIA/AMD`, `gaming/workstation` kategori yapılmaz.
- Soğutma ve genişleme kartlarında müşterinin ürün tipi niyeti değiştiği için L4 vardır; yalnız teknik özellik değiştiği yerlerde L4 yoktur.
- Riser, RAID/HBA veya port türlerini ayrı ayrı L4 yapmak ilk sürümde mikro-kategori şişmesi yaratır; `Bağlantı & Denetleyici Kartları` içinde facet ile ayrılır.

## 5. Leaf assignments

### Tam öneri ağacı

```text
Bilgisayar & Tablet (L1)
└── Bilgisayar Bileşenleri (L2)
    ├── İşlemci (L3, leaf)
    ├── Ekran Kartı (L3, leaf)
    ├── Anakart (L3, leaf)
    ├── RAM Bellek (L3, leaf)
    ├── Güç Kaynağı (L3, leaf)
    ├── Bilgisayar Kasası (L3, leaf)
    ├── Soğutma (L3, non-leaf)
    │   ├── İşlemci Soğutucu (L4, leaf)
    │   ├── Kasa Fanı (L4, leaf)
    │   ├── Sıvı Soğutma (L4, leaf)
    │   └── Termal Macun & Ped (L4, leaf)
    ├── Genişleme Kartları (L3, non-leaf)
    │   ├── Ses Kartı (L4, leaf)
    │   ├── Görüntü Yakalama Kartı (L4, leaf)
    │   └── Bağlantı & Denetleyici Kartları (L4, leaf)
    └── Tek Kart Bilgisayar (SBC) (L3, leaf)
```

### Sayısal sözleşme

- L3: 9
- L4: 7
- L3 leaf: 7
- L4 leaf: 7
- Toplam atanabilir leaf: 14
- Leaf olmayan L3: 2 (`Soğutma`, `Genişleme Kartları`)
- Maksimum derinlik: 4
- Tekrarlanan kategori adı: 0

### Paket ve kit ataması

- Bir CPU'nun kutusundan stok soğutucu çıkması ürünü `İşlemci Soğutucu` yapmaz; ana ürün `İşlemci` leaf'inde kalır ve `included_cooler=true` facet/bundle metadata olarak tutulur.
- Kasa + PSU paketinde ana ürün satıcı beyanı ve ticari ana işleve göre seçilir; bileşenler eşdeğer paket ise owner-approved bundle policy gerekir.
- Anakart + CPU + RAM yükseltme setleri yeni bir “set” kategorisi üretmez. Birincil ürün açık değilse yayın öncesi katalog incelemesine gider; rastgele leaf atanmaz.
- SBC başlangıç seti, ana ürün SBC kartıysa `Tek Kart Bilgisayar (SBC)` leaf'inde kalır; kutu içeriği bundle metadata'dır.

## 6. Storage/accessory boundaries

### Depolama — kesin sibling sınırı

Şu ürünler `Bilgisayar Bileşenleri` altında bulunmaz:

- dahili ve harici SSD,
- HDD,
- NVMe/M.2 SSD,
- optik sürücü,
- NAS ve disk array,
- USB bellek ve hafıza kartı,
- disk kutusu/dock/çoğaltıcı gibi owner-final `Veri Depolama` kapsamındaki ürünler.

Canonical yön:

```text
Bilgisayar & Tablet → Veri Depolama → gelecekteki ilgili leaf
```

Bir ürünün anakarta SATA, SAS, M.2 veya PCIe ile bağlanması onu otomatik olarak bileşen kategorisine taşımaz. Ana işlev veri saklamaksa `Veri Depolama` kullanılır.

**Dar istisna:** Veri saklamayan, yalnız bağlantı/denetim sağlayan dahili HBA, RAID, SATA/SAS veya port expansion kartı `Genişleme Kartları → Bağlantı & Denetleyici Kartları` leaf'ine gider. Diskin kendisi ve harici disk kutusu bu istisnaya girmez.

**Depolama duplikasyonu: 0.**

### Aksesuar — kesin sibling sınırı

Şu harici ürünler `Bilgisayar Aksesuarları` L2'sine gider:

- docking station ve USB hub,
- harici çoklayıcı/adaptör ve genel bilgisayar kablosu,
- laptop soğutma standı/padı,
- GPU destek braketi gibi ana işlevi montaj/destek olan aksesuar,
- harici capture box.

Harici disk kutusu ve disk dock'u ise yukarıdaki daha spesifik depolama sınırı nedeniyle `Veri Depolama` L2'sinde kalır; genel aksesuar dalına taşınmaz.

İç PC airflow parçası olan kasa fanı ile dışarıdan kullanılan laptop soğutma pad'i aynı kategori değildir. Fiziksel olarak PC'ye bağlanmak tek başına “bileşen” olmak için yeterli değildir.

### Klavye, mouse ve diğer çevre birimleri

Klavye, mouse, trackball, grafik tablet ve PC-primary headset bu L2'ye girmez:

```text
Bilgisayar & Tablet → Klavye, Mouse & Çevre Birimleri
```

Google taxonomy'nin input devices ve USB hub'ları Computer Components altında gösterebilmesi EsnaftaVar owner-final sibling sınırını değiştirmez.

### Ağ kartı

Dahili PCIe formunda olsa bile Ethernet kartı, Wi-Fi kartı ve ağ adaptörünün ana işlevi ağ bağlantısıdır:

```text
Bilgisayar & Tablet → Ağ & İnternet Ürünleri → gelecekteki ilgili leaf
```

Bu nedenle `Ağ Kartı` bu öneride L3 veya L4 değildir.

## 7. Arduino/SBC boundary

### Tek Kart Bilgisayar (SBC) leaf'ine dahil

- Genel amaçlı bir işletim sistemi çalıştırabilen tek kart bilgisayarlar.
- Raspberry Pi bilgisayar serisi gibi SBC ürünleri.
- Genel amaçlı işlemci, bellek ve OS stack'i sunan compute module'ler; çıplak modül ile development kit ayrımı facet/bundle bilgisidir.
- Marka bağımsız diğer single-board computer ürünleri.

### Bilgisayar Bileşenleri'nden hariç

- Arduino kartları,
- ESP/ESP32/ESP8266 geliştirme kartları,
- Raspberry Pi Pico gibi microcontroller board'lar,
- tek başına mikrodenetleyici yongaları,
- sensör, röle, breadboard ve genel elektronik geliştirme modülleri.

Canonical yön:

```text
Arduino / ESP / microcontroller board
→ Elektronik → Elektronik Bileşenler → gelecekteki ilgili leaf
```

### Karar testi

1. Ürün genel amaçlı bilgisayar işletim sistemi ve uygulama çalıştırma amacıyla mı satılıyor?
2. Yoksa gömülü kontrol, pin/I/O ve firmware tabanlı elektronik geliştirme kartı mı?

İlk cevap baskınsa SBC, ikinci cevap baskınsa Elektronik Bileşenler kullanılır. Marka adı karar vermez: aynı marka hem bilgisayar hem microcontroller ürünü sunabilir.

**Arduino leakage: 0.** `Raspberry Pi` kategori adı değildir; arama synonym'i ve inclusion örneğidir.

## 8. Compatibility architecture

Bu bölüm gelecekteki veri sözleşmesini tarif eder; parça seçici, öneri motoru veya runtime davranışı uygulamaz.

### Kavramsal model

Her leaf kendi facet profilini ilan eder. Uyumluluk değerlendirmesi, ürünler arası serbest metin eşleşmesi yerine normalize edilmiş değerler ve sürümlü kurallar üzerinden yapılır.

Önerilen ilişki türleri:

| İlişki | Anlam | Örnek |
|---|---|---|
| `requires_exact` | Değerlerin aynı kontrollü kimliği kullanması gerekir | CPU socket ↔ anakart socket |
| `supports_one_of` | Sağ taraf, sol taraftaki değerlerden birini destekler | Anakart supported RAM generation ↔ RAM DDR generation |
| `fits_within` | Fiziksel ölçü üst sınırı aşmamalıdır | GPU length ↔ kasa max GPU clearance |
| `supports_form_factor` | Kasa/yuva ilgili standardı desteklemelidir | Anakart form factor ↔ kasa supported motherboard form factors |
| `requires_connector` | Gerekli elektrik/data connector sağlanmalıdır | GPU power connectors ↔ PSU available connectors |
| `minimum_recommended` | Sert elektrik güvenliği garantisi değil, minimum öneri karşılaştırmasıdır | GPU/system recommended PSU wattage ↔ PSU continuous wattage |
| `versioned_interface` | Arayüz standardı sürüm ve lane semantiğiyle değerlendirilir | PCIe card interface ↔ motherboard slot capabilities |
| `conditional` | Ek bir facet birlikte doğrulanmadan kesin sonuç verilmez | ECC/registered RAM ↔ motherboard/CPU memory support |

### Temel uyumluluk ilişkileri

1. **CPU ↔ anakart:** `socket_id` kesin eşleşir; ayrıca chipset/BIOS support listesi sürümlü ve model bazlı ayrı veri gerektirir. Aynı socket tek başına kesin uyumluluk garantisi değildir.
2. **RAM ↔ anakart/CPU:** DDR generation ve DIMM/SO-DIMM biçimi eşleşir; ECC, registered/unbuffered, hız limiti ve maksimum kapasite koşullu kurallardır.
3. **Anakart ↔ kasa:** Anakart form factor, kasanın desteklediği form factor kümesinde bulunur.
4. **GPU ↔ kasa:** Uzunluk, yükseklik ve slot kalınlığı ayrı fiziksel ölçülerle doğrulanır.
5. **CPU cooler ↔ CPU/anakart/kasa:** Socket mounting desteği ile cooler height/radiator clearance ayrı ayrı doğrulanır.
6. **Sıvı soğutma ↔ kasa:** Radiator boyutu tek başına yetmez; montaj konumu, kalınlık ve fan kombinasyonu koşullu veridir.
7. **PSU ↔ kasa:** PSU form factor kasanın desteklediği kümede olmalıdır.
8. **PSU ↔ GPU/sistem:** Connector türü/adedi doğrulanır; watt karşılaştırması advisory kalır ve profesyonel güç hesabının yerine geçmez.
9. **Genişleme kartı ↔ anakart/kasa:** PCIe slot/lane/interface, kart uzunluğu ve low-profile/full-height bracket uyumu değerlendirilir.

### Sonuç durumları

Gelecekteki uyumluluk servisi yalnız şu kontrollü sonuçları üretmelidir:

- `compatible`: gerekli tüm hard constraint'ler doğrulandı,
- `incompatible`: en az bir hard constraint açıkça başarısız,
- `conditional`: ek koşul/BIOS/ölçü/connector kontrolü gerekiyor,
- `unknown`: gerekli veri eksik veya güvenilir değil.

`unknown` hiçbir zaman otomatik `compatible` sonucuna çevrilmemelidir. Satıcı serbest metni, normalize edilmiş teknik alanın yerini tutmaz.

### Sürümleme ilkeleri

- Socket, DDR, PCIe, form factor ve connector değerleri kontrollü sözlük kimlikleriyle saklanır.
- İnsan tarafından görülen etiketler kimliklerden ayrılır; synonym değişikliği uyumluluk anahtarını değiştirmez.
- BIOS/QVL/model-specific destek zamanla değişebildiğinden kaynağı ve `verified_at` bilgisi taşır.
- Kural sürümü kayıt altına alınır; taxonomy node değişikliği uyumluluk kuralını sessizce yeniden yazmaz.

## 9. Facet profiles

Bu alanların hiçbiri kategori alt dalı değildir. Liste, owner onayı sonrası veri sözlüğü çalışmasına girdi sağlar.

### Ortak facet ilkeleri

- `brand`, `manufacturer`, `model`, `condition`, `warranty`, `color` ortak ürün facet/metadata alanlarıdır; kategori değildir.
- Sayısal alanlar metin yerine birimlendirilmiş değer kullanır (`mm`, `W`, `GB`, `MT/s`).
- Kontrollü değerlerde gösterim etiketi ile machine key ayrıdır.
- `gaming`, `workstation`, `server-grade`, `RGB` kategori değil kullanım/özellik facet'idir.

### Leaf bazlı facet profilleri

| Leaf | Zorunlu/öncelikli facet önerileri | İkincil facet önerileri |
|---|---|---|
| İşlemci | socket, model family, generation, core count, thread count, base/boost clock, TDP | integrated graphics, cache, architecture, unlocked, included cooler |
| Ekran Kartı | GPU family/model, VRAM capacity/type, PCIe interface, card length/height/slot width, power connector, recommended PSU | output ports, boost clock, cooling design, workstation/gaming class, ray-tracing support |
| Anakart | CPU socket, chipset, form factor, supported RAM generation/form factor, DIMM count/max capacity | ECC mode, PCIe slots/generation, M.2/SATA count, integrated Wi-Fi/Bluetooth, power connectors, BIOS support reference |
| RAM Bellek | DDR generation, total capacity, module count, per-module capacity, speed, DIMM/SO-DIMM | ECC, registered/unbuffered, latency, voltage, rank, kit status |
| Güç Kaynağı | continuous wattage, efficiency certification/rating, modularity, PSU form factor, connector types/counts | ATX spec revision, fan size/mode, rail information, PFC, dimensions |
| Bilgisayar Kasası | supported motherboard form factors, max GPU length/height, max CPU cooler height, radiator support, PSU form factor | drive bays, fan mounts, dimensions, side-panel material, front I/O, included fans |
| İşlemci Soğutucu | socket compatibility, cooler type, cooler height, supported/declared thermal load, fan size | heat-pipe count, noise, airflow, mounting kit included |
| Kasa Fanı | diameter, thickness, connector, PWM support, speed range | airflow, static pressure, noise, bearing, lighting connector |
| Sıvı Soğutma | AIO/custom-loop type, socket compatibility, radiator size/thickness, fan size/count | pump specs, tube length, block material, refill/serviceability |
| Termal Macun & Ped | material type, quantity/dimensions, declared thermal conductivity, intended component | thickness, electrical conductivity, cure type |
| Ses Kartı | PCIe/interface type, channel configuration, sample rate, bit depth, input/output ports | surround standards, signal-to-noise ratio, low-profile bracket |
| Görüntü Yakalama Kartı | host interface, input/output connector, max capture resolution/rate, pass-through capability | codec support, HDR, latency class, multi-input count, low-profile bracket |
| Bağlantı & Denetleyici Kartları | controller function, host interface/lane, provided ports/protocols, card profile | RAID/HBA mode, boot support, bandwidth, chipset, bracket type |
| Tek Kart Bilgisayar (SBC) | SoC/CPU architecture, RAM, storage interface, GPIO/header, display outputs, network, power input | supported OS, form factor/dimensions, wireless, accelerator, included kit contents |

### Facet olmayan kategori adaylarına örnek

- `DDR5 RAM`, `32 GB RAM`, `6000 MT/s RAM` → `RAM Bellek` leaf + facet
- `AM5 İşlemci`, `16 çekirdek işlemci` → `İşlemci` leaf + facet
- `ATX Anakart`, `Wi-Fi Anakart` → `Anakart` leaf + facet
- `750 W Gold PSU`, `SFX PSU` → `Güç Kaynağı` leaf + facet
- `360 mm AIO` → `Sıvı Soğutma` leaf + facet
- `Gaming GPU`, `workstation GPU` → `Ekran Kartı` leaf + kullanım facet'i

## 10. Enterprise/server boundary

Önceki owner kararı korunur: tam rack server ve enterprise-heavy katalog bu çalışmada finalize edilmez.

### Mevcut leaf'lere facet ile sığabilecek sıradan bileşenler

- Tek başına satılan workstation/server anakartı → `Anakart`; socket, form factor, ECC/RDIMM desteği ve server-grade kullanım facet'leriyle.
- ECC bellek → `RAM Bellek`; ECC, registered/unbuffered ve DIMM form facet'leriyle.
- Workstation GPU → `Ekran Kartı`; GPU class/use facet'iyle.
- Server uyumlu CPU → `İşlemci`; socket, generation, core/TDP facet'leriyle.
- Rackmount biçimli boş chassis → owner kararı verilene kadar otomatik `Bilgisayar Kasası` ataması yapılmaz; standard consumer case ile aynı kabul edilmez.

### Bu L2'ye atanmayacak tam sistemler

- Full rack server,
- blade server sistemi/enclosure,
- enterprise storage appliance,
- network appliance,
- hazır workstation bilgisayarı.

Hazır workstation bir bileşen değildir ve owner-final kurala göre `Masaüstü Bilgisayar` yönüne gider. Full rack server için L1/L2/L3 policy kararı açık kalır. Google taxonomy'de blade enclosure ve rack/mount ürünleri Computer Components altında bulunsa da bu geniş enterprise kararı EsnaftaVar'a sessizce aktarılmaz.

### Güvenli yayın kuralı

Enterprise-heavy veya rack formundaki ürünün mevcut consumer leaf'e uyduğu açık değilse ürün `TBD / catalog policy review` durumunda tutulur. “En yakın kategori” seçilerek yayınlanmaz.

## 11. Synonyms

Synonym'ler arama ve satıcı giriş normalizasyonu içindir; yeni kategori veya ayrı birincil yol oluşturmaz.

| Canonical ad | Kontrollü synonym/search hint | Kaçınılacak kullanım |
|---|---|---|
| İşlemci | CPU, processor, merkezi işlem birimi | Intel/AMD gibi markayı kategori yapmak |
| Ekran Kartı | GPU, grafik kartı, video kartı, graphics card | GPU modelini kategori yapmak |
| Anakart | motherboard, mainboard | chipset veya socket'i alt kategori yapmak |
| RAM Bellek | RAM, bellek, memory, sistem belleği | DDR neslini kategori yapmak |
| Güç Kaynağı | PSU, power supply, power supply unit | watt aralığını kategori yapmak |
| Bilgisayar Kasası | PC kasası, boş kasa, computer case, chassis | hazır masaüstü bilgisayarı kasa olarak atamak |
| Soğutma | PC soğutma, cooling | laptop cooling pad'i iç bileşen olarak atamak |
| İşlemci Soğutucu | CPU cooler, işlemci fanı, hava soğutucu, heatsink | AIO/sıvı ürünü bu leaf'e çoğaltmak |
| Kasa Fanı | case fan, sistem fanı, PC fanı | harici masa fanı/tablet fanı |
| Sıvı Soğutma | liquid cooling, water cooling, AIO, custom loop | “İşlemci Soğutucu” leaf'ine de ikincil atama |
| Termal Macun & Ped | thermal paste, termal ped, thermal pad, termal bileşik | genel yapıştırıcı/izolasyon pedi |
| Genişleme Kartları | expansion card, PCIe kart | ekran/ağ kartını bu üst dala atamak |
| Ses Kartı | sound card, audio card | harici stüdyo audio interface |
| Görüntü Yakalama Kartı | capture card, video capture kartı, yayın kartı | ekran kartı veya TV tuner |
| Bağlantı & Denetleyici Kartları | I/O kartı, port kartı, controller card, RAID kartı, HBA, riser | ağ kartı |
| Tek Kart Bilgisayar (SBC) | single-board computer, single board computer, SBC, kart bilgisayar, Raspberry Pi | Raspberry Pi'ı canonical kategori adı yapmak; Pico/Arduino/ESP'yi sızdırmak |

Synonym eşleşmesi exact leaf atamasını tek başına otomatikleştirmez. Örneğin “Raspberry Pi Pico” metnindeki Raspberry Pi eşleşmesi SBC ataması yaptıramaz; ürün tipinin microcontroller olduğu doğrulanır.

## 12. Inclusion/exclusion examples

| Ürün örneği | Birincil sonuç | Neden / dışlama |
|---|---|---|
| AM5 desktop CPU | `İşlemci` | Socket facet; category değildir |
| Workstation GPU | `Ekran Kartı` | Workstation kullanım facet'i; ayrı kategori değildir |
| Server/workstation motherboard | `Anakart` | Standalone component ise mevcut leaf + enterprise facet |
| ECC RDIMM kit | `RAM Bellek` | ECC/registered facet'leriyle; rack serverı finalize etmez |
| 850 W SFX modular PSU | `Güç Kaynağı` | Watt/form/modularity facet'leriyle |
| Boş ATX gaming kasa | `Bilgisayar Kasası` | Gaming ve ATX facet; hazır PC değildir |
| Hazır gaming desktop | Bu L2 dışında → `Masaüstü Bilgisayar` | Tam bilgisayardır, boş kasa değildir |
| Hava tipi CPU tower cooler | `Soğutma → İşlemci Soğutucu` | Socket/height facet'leriyle |
| 360 mm AIO CPU cooler | `Soğutma → Sıvı Soğutma` | Sıvı ürün için tek leaf; CPU cooler'a kopyalanmaz |
| 120 mm PWM kasa fanı | `Soğutma → Kasa Fanı` | Ölçü/PWM facet'leriyle |
| Termal pad | `Soğutma → Termal Macun & Ped` | Bileşen ısı transfer sarfıdır |
| PCIe internal sound card | `Genişleme Kartları → Ses Kartı` | Dahili genişleme kartıdır |
| PCIe capture card | `Genişleme Kartları → Görüntü Yakalama Kartı` | Dahili yakalama kartıdır |
| PCIe USB port expansion card | `Genişleme Kartları → Bağlantı & Denetleyici Kartları` | İç I/O genişletme işlevidir |
| PCIe RAID/HBA controller, disksiz | `Genişleme Kartları → Bağlantı & Denetleyici Kartları` | Veri saklamaz; bağlantı/denetim sağlar |
| PCIe Wi-Fi/Ethernet card | Bu L2 dışında → `Ağ & İnternet Ürünleri` | Form değil ana ağ işlevi belirleyicidir |
| NVMe SSD | Bu L2 dışında → `Veri Depolama` | Dahili olsa da ana işlev veri saklamadır |
| HDD / optical drive | Bu L2 dışında → `Veri Depolama` | Depolama duplikasyonu engellenir |
| USB hub / docking station | Bu L2 dışında → `Bilgisayar Aksesuarları` | Harici bağlantı aksesuarıdır |
| Laptop cooling pad | Bu L2 dışında → `Bilgisayar Aksesuarları` | İç sistem soğutma bileşeni değildir |
| Klavye / mouse | Bu L2 dışında → `Klavye, Mouse & Çevre Birimleri` | Owner-final sibling sınırı |
| Raspberry Pi 5 kartı | `Tek Kart Bilgisayar (SBC)` | Genel amaçlı kart bilgisayar; marka synonym'dir |
| Raspberry Pi Compute Module | Öneri: `Tek Kart Bilgisayar (SBC)` | Genel amaçlı OS stack'i sunan compute module; owner onayı bekler |
| Raspberry Pi Pico | Bu L2 dışında → `Elektronik → Elektronik Bileşenler` | Microcontroller board'dur |
| Arduino UNO / ESP32 board | Bu L2 dışında → `Elektronik → Elektronik Bileşenler` | Elektronik geliştirme/microcontroller ürünüdür |
| Harici USB capture box | Bu L2 dışında → öneri `Bilgisayar Aksesuarları` | Dahili genişleme kartı değildir; owner onayı bekler |
| TV tuner card | Bu L2 dışında → `Elektronik → TV & Görüntü` policy review | Ana işlev TV yayını alımıdır; exact future leaf açık |
| Full rack server | `TBD / enterprise policy review` | Bu L2 bir tam sistem yolu değildir |
| Rackmount empty server chassis | `TBD / enterprise policy review` | Consumer kasa leaf'ine sessiz atama yapılmaz |

## 13. Open owner decisions

Owner review aşağıdaki kararları vermelidir; bu belge bunları FINAL saymaz:

1. **L3/L4 omurgası:** 9 L3, 7 L4 ve 14 leaf listesi/adları/sırası onaylanmalı mı?
2. **Soğutma ayrımı:** `İşlemci Soğutucu` leaf'inin sıvı ürünleri dışlaması ve tüm AIO/custom-loop ürünlerinin `Sıvı Soğutma` leaf'ine gitmesi onaylanmalı mı?
3. **Termal ürünler:** `Termal Macun & Ped` soğutma altında kalıcı L4 olmalı mı, yoksa gelecekte Bilgisayar Aksesuarları yönüne mi taşınmalı?
4. **Genişleme kartı derinliği:** Ses, görüntü yakalama ve bağlantı/denetleyici kartlarının ayrı L3 yerine L4 olması onaylanmalı mı?
5. **Harici capture/audio:** Harici USB capture box'ın Bilgisayar Aksesuarları, harici profesyonel audio interface'in Elektronik/Müzik policy review yönünde olması onaylanmalı mı?
6. **SBC kapsamı:** Genel amaçlı OS çalıştıran compute module'lerin `Tek Kart Bilgisayar (SBC)` leaf'ine alınması onaylanmalı mı?
7. **Enterprise parça politikası:** Ordinary server motherboard, ECC RAM, server CPU ve workstation GPU'nun mevcut leaf'lerde facet ile yer alması onaylanmalı mı?
8. **Rack enterprise:** Full rack server, blade enclosure ve rackmount empty chassis için ayrı enterprise L1/L2/policy yolu daha sonraki owner çalışmasına bırakılmalı mı?
9. **Kit/bundle policy:** Birincil bileşeni açık olmayan anakart+CPU+RAM setlerinin yayın öncesi manuel review'a gitmesi onaylanmalı mı?

### Proposal acceptance gates

Owner finalization öncesi bu önerinin kendi iç doğrulaması:

- canonical path değişmedi,
- L3 duplicate: 0,
- L4 duplicate: 0,
- depolama duplikasyonu: 0,
- Arduino/ESP leakage: 0,
- marka-as-category: 0,
- compatibility attribute-as-category: 0,
- maksimum derinlik: 4,
- rack/enterprise tam katalog kararı: açık ve sessizce finalize edilmedi,
- runtime implementation: yok.

Bu belge owner kararı gelene kadar **PROPOSED FOR OWNER REVIEW** durumundadır.
