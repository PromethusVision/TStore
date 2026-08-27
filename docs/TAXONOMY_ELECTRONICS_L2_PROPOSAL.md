# EsnaftaVar Canonical Taxonomy — Elektronik L2 Owner Final

**Wave:** 15 / Phase B1A

**Belge tarihi:** 27 Ağustos 2026

**Product owner onayı:** 27 Ağustos 2026 / Wave 15 Phase B1A

**Canonical L1:** **Elektronik — CONFIRMED / PRODUCT OWNER FINAL**

**Karar durumu:** **CONFIRMED — PRODUCT OWNER FINAL**

**Kapsam:** Yalnız Elektronik L1 altındaki L2 mimarisi. Bu belge L3/L4 ağacını,
runtime şemasını, migration'ı, taxonomy JSON'unu, Flutter/Figma'yı veya remote
ortamları değiştirmez.

> Phase B1'deki sekiz L2 önerisi **SUPERSEDED** durumundadır. Product owner bu
> belgede kayıtlı dokuz L2 adını, sırasını ve sınır kararlarını FINAL olarak
> onaylamıştır. Bu karar mevcut `v1.0.0` full-tree artefaktının replacement'ı,
> runtime implementation'ı veya deploy planı değildir.

## 1. Scope

Bu çalışmanın amacı, owner-final **Elektronik** L1'i altında Türkiye'deki müşteri
diline yakın, yerel telefoncu/elektronikçi ve consumer-facing maker envanterini
bulunabilir kılan, ileride variable-depth L3/L4'e sağlıklı açılabilen owner-final
dokuz L2'yi kaydetmektir.

Canonical Phase A kuralları aynen korunur:

- Her ürün tam olarak bir primary canonical leaf'e atanır.
- Bir ürünün ana işlevi category ownership'i belirler.
- Marka, renk, kapasite, bağlantı standardı ve uyumluluk category değildir.
- Dallar en fazla L4'e iner; her dalı aynı derinliğe zorlama yoktur.
- Elektronik ile **Bilgisayar & Tablet** ayrı L1'lerdir.
- Marketplace browse ağacı, EsnaftaVar'ın canonical taxonomy'si değildir.
- Search alias veya cross-discovery, ikinci primary category üretmez.

### Bu fazın dışında

- Eksiksiz L3/L4 node listesi ve stable ID/slug üretimi
- Current full-tree JSON reconciliation
- Attribute/facet registry implementation'ı
- Merchant sector taxonomy'si
- DB, migration, seed, search index, Flutter veya Figma değişikliği
- Production ya da Development apply

## 2. Sources

Araştırma 27 Ağustos 2026 tarihinde resmi ve kamuya açık kaynaklar üzerinden
yeniden doğrulandı. Proprietary kategori ağaçları kopyalanmadı. Kaynaklar yalnız
department sınırlarını, güncel müşteri dilini, leaf/attribute örüntülerini ve aşırı
fragmentation riskini karşılaştırmak için kullanıldı.

Internal source-of-truth olarak
[`ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md`](ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md)
kullanıldı. Legacy karşılaştırma için
[`ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md`](ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md)
ve `docs/data/esnaftavar_category_taxonomy_v1_final.json` salt okunur incelendi;
bu artefaktların hiçbiri değiştirilmedi.

| Kaynak | Doğrulanan sinyal | EsnaftaVar için kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy — official text](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center category contract](https://support.google.com/merchants/answer/6324436?hl=en) | Google tek category, ana işlev ve mümkün olan en spesifik category yaklaşımını açıkça tanımlar. Official dosyada `Electronics` altında Audio, Communications/Telephony, Video ve Video Game Consoles; ayrıca ayrı top-level `Cameras & Optics` bulunur. | Ana işlev ve tek-primary-category ilkesi güçlü girdidir. Dosyanın header sürümü `2021-09-21` olduğundan modern Türkçe müşteri dili veya 2026 wearable/smart-home kapsamı için güncel kanıt sayılmaz. Google'da Computer, Electronics içinde olsa da EsnaftaVar owner kararıyla ayrı L1'dir. |
| [Trendyol live Elektronik browse](https://www.trendyol.com/elektronik-x-c104024) ve [official category-tree contract](https://developers.trendyol.com/docs/trendyol-kategori-listesi-getcategorytree) | Live sayfada `Cep Telefonu & Aksesuar`, `TV&Görüntü&Ses`, `Giyilebilir Teknoloji`, `Foto & Kamera`, `Elektronik Aksesuar`, `Oyun&Konsollar` ve `Kulaklık` müşteri terimleri görülür. API dokümanı yalnız en alt category'ye ürün girişini ve ağacın güncel alınmasını ister. | Türkçe adlandırma ve department talebi için güçlü girdidir. Aynı browse yüzeyi Bilgisayar&Tablet, Beyaz Eşya, ev aletleri, yazıcı ve dijital ürünleri de kapsar; bu nedenle wholesale kopyalanamaz. |
| [Hepsiburada 2026 ilk yarı alışveriş verisi](https://kurumsal.hepsiburada.com/tr/basin-odasi/hepsiburada-turkiye%E2%80%99nin-dijital-sepetini-acikladi) ve [2025 alışveriş verisi](https://kurumsal.hepsiburada.com/tr/basin-odasi/hepsiburada-turkiye%E2%80%99nin-2025-alisveris-tercihlerini-acikladi) | 2026 verisi Foto & Kamera'yı ayrı büyüyen category olarak, akıllı saati yoğun aranan ürün olarak; teknoloji talebinde telefon, tablet ve Bluetooth kulaklığı açıkça gösterir. 2025 verisi telefon, tablet ve oyun konsolunu ayrı güçlü ürün grupları olarak raporlar. | Türkiye müşteri dili ve talep ayrışmasını doğrular. Kamu sayfası tam ve sabit L2 ağacı sunmadığı için Hepsiburada'dan eksiksiz hierarchy sonucu çıkarılmaz. Tablet yine EsnaftaVar'da ayrı L1'e gider. |
| [n11 live Elektronik browse](https://www.n11.com/elektronik) ve [official category-tree contract](https://developer.n11.com/documentation/n11-marketplace-entegrasyonu/kategori-agaci-listeleme/) | Live nav; Telefon & Aksesuarları, Bilgisayar, Televizyon & Ses Sistemleri, Elektrikli Ev Aletleri, Beyaz Eşya, Fotoğraf & Kamera ve Video Oyun & Konsol sınırlarını gösterir. API sözleşmesi ürünün yalnız leaf ID'ye bağlanmasını tanımlar. | Telefon, TV/ses, fotoğraf ve konsol sınırlarını destekler. Bilgisayar ve ev cihazlarını aynı Elektronik şemsiyesinde taşıması EsnaftaVar L1 kararına aykırıdır. |
| [Amazon Türkiye seller category list](https://satis.amazon.com.tr/satis) | Bilgisayar, Cep Telefonları, Elektronik Ürün Aksesuarları, Elektronik Ürünler ve Fotoğraf Makinesi ayrı satış category'leri olarak listelenir. Elektronik örnekleri TV/ses/GPS; accessory örnekleri ses, video, kamera, telefon ve bilgisayar aksesuarlarını kapsar. | Bilgisayar/telefon/fotoğraf sınırlarının ayrışabildiğini ve generic accessory node'un ne kadar hızla aşırı genişleyebildiğini gösterir. Amazon'un çoklu kategori listeleme modeli EsnaftaVar'ın exactly-one-primary-leaf kuralı değildir. |

### Research synthesis

Kaynakların ortaklaştırdığı bölüm sınırları:

1. Telefon ve telefon aksesuarı Türkiye'de tek güçlü müşteri girişidir.
2. TV/görüntü ile ses sıklıkla birlikte merchandised edilse de kulaklık ve taşınabilir
   ses talebi TV'den bağımsız büyük bir niyettir.
3. Fotoğraf/kamera, Google ve Amazon'da daha üst ayrışsa bile owner-final 24 L1
   içinde Elektronik altında anlamlı bir L2 olmalıdır.
4. Oyun konsolu, PC gaming'den ayrılabilecek platform/uyumluluk sözleşmesine sahiptir.
5. Giyilebilir teknoloji Türkiye müşteri dilinde ayrı ve güncel bir department'tır;
   legacy Telefon dalına gömülmemelidir.
6. Smart-home/security marketplace'lerde tutarsız dağılır; EsnaftaVar'da ancak dar
   bir kontrol/izleme/güvenlik sınırıyla anlamlıdır.
7. Generic accessory ağacı catch-all olmamalı; güç, şarj ve bağlantı işlevleriyle
   sınırlandırılmalıdır.
8. Yerel maker/elektronikçi envanterindeki geliştirme kartı, sensör, modül ve devre
   elemanları ayrı bir consumer-facing `Elektronik Bileşenler` sınırına ihtiyaç
   duyar; Raspberry Pi/SBC gibi bilgisayar platformları bu sınıra girmez.
9. Marketplace'lerin Bilgisayar, Tablet, Beyaz Eşya ve küçük ev aletlerini Elektronik
   şemsiyesinde göstermesi EsnaftaVar için bilinçli olarak reddedilir.

## 3. Boundary with other L1s

### Mandatory L1 boundary rules

| Sınır | Elektronik'te kalır | Diğer L1'e gider | Karar testi |
|---|---|---|---|
| **Elektronik vs Bilgisayar & Tablet** | Telefon, TV/projeksiyon/medya oynatıcı, consumer audio, fotoğraf makinesi, konsol, giyilebilir cihaz, consumer smart-home/security, generic AV/güç bağlantısı; Arduino/ESP, breadboard, sensör/modül ve genel devre elemanları | Bilgisayar, tablet, e-kitap okuyucu, monitör, yazıcı/tarayıcı, webcam, modem/router/ağ, depolama, PC bileşeni, Raspberry Pi/SBC, klavye/mouse, bilgisayar dock/hub ve PC-first gaming peripheral | Ürünün ana işi computing, SBC kullanımı, tablet kullanımı, computer input/output, network veya computer storage ise **Bilgisayar & Tablet**. Maker prototipleme/devre işlevi taşıyan Arduino/ESP sınıfı ise **Elektronik Bileşenler**. Yalnız “akıllı”, USB'li veya Bluetooth'lu olması Elektronik'e taşımaz. |
| **Elektronik vs Beyaz Eşya & Ev Aletleri** | TV, consumer audio/video, home-control hub/sensor ve elektronik güvenlik/izleme | Buzdolabı, çamaşır/bulaşık makinesi, klima, süpürge, kahve makinesi, blender ve diğer büyük/küçük ev cihazı | Ana işlev ev işi, iklimlendirme, temizlik veya gıda hazırlama ise bağlantılı/akıllı olsa da **Beyaz Eşya & Ev Aletleri**. |
| **Elektronik vs Ev & Yaşam** | Elektronik kontrol, iletişim, görüntüleme, ses ve izleme cihazı | Mobilya, ev tekstili, pasif dekorasyon, düzenleme, mekanik ev gereci | Ürünün elektronik sinyal/işlem/kontrol işlevi olmadan temel faydası aynı kalıyorsa **Ev & Yaşam**. “Akıllı” etiketi tek başına ownership üretmez. |
| **Elektronik vs Oyuncak & Hobi** | Gerçek consumer cihaz, oyun konsolu, platforma bağlı fiziksel video oyunu ve gerçek Arduino/ESP/devre bileşeni | Ana işlevi oyun/rol yapma/çocuk eğlencesi olan oyuncak elektronik, basit oyuncak drone veya yönlendirmeli oyun/aktivite kiti | Ürün gerçek cihaz/devre işlevi ve teknik şemasıyla mı, oyun/aktivite amacıyla mı satın alınıyor? İkinci durumda **Oyuncak & Hobi**. Arduino/ESP içermesi tek başına oyuncak ownership'i üretmez. |
| **Elektronik vs Otomotiv & Motosiklet** | Araçtan bağımsız taşınabilir consumer cihaz ve birden çok bağlamda kullanılan generic telefon aksesuarı | Araç fitment'i, sabit montajı veya araç elektrik sistemi gerektiren head unit, dashcam, araç navigasyonu, araç ses sistemi, araç alarmı/trackeri, araç kablo demeti ve vehicle-only charger/mount | Marka-model-yıl/araç tesisatı uyumluluğu ana şema ise **Otomotiv & Motosiklet**. |

### Additional collision guards

| Sınır | Kural |
|---|---|
| **Elektronik vs Saat & Takı** | Akıllı saat/bileklik/ring Elektronik → Giyilebilir Teknoloji; klasik analog/dijital kol saati Saat & Takı. |
| **Elektronik vs Müzik & Enstrüman** | Genel amaçlı kulaklık, mikrofon, speaker ve audio recorder Elektronik; enstrüman, enstrümana özgü pickup/pedal/amfi ve performans aksesuarı Müzik & Enstrüman. |
| **Elektronik vs Sağlık & Medikal** | Genel wellness özellikli smartwatch Elektronik; ana amacı teşhis/ölçüm/tedavi olan regüle medikal cihaz Sağlık & Medikal. Medical claim facet değil policy/evidence gerektirir. |
| **Elektronik vs Yapı, Hırdavat & Tesisat** | Plug-and-play consumer control/monitoring cihazı ile prototipleme/devre amaçlı sensör, röle, breadboard, pasif/aktif eleman Elektronik; sabit elektrik tesisatı, bina prizi/anahtarı, yapı kablosu, mekanik kilit ve montaj donanımı Yapı, Hırdavat & Tesisat. |
| **Elektronik vs Çanta & Aksesuar** | Elektronik cihazın işlevsel parçası Elektronik; ana işlevi taşıma olan telefon/laptop/kamera çantası Çanta & Aksesuar. Cihaz compatibility facet olabilir. |

### Bilgisayar & Tablet leakage gate

Aşağıdaki ürünler **Elektronik L2'lerinin hiçbirine alınmamalıdır**:

- dizüstü/masaüstü bilgisayar, tablet ve e-kitap okuyucu;
- monitör, yazıcı, tarayıcı ve webcam;
- klavye, mouse, grafik tablet, PC game controller/peripheral;
- işlemci, RAM, ekran kartı, anakart, Raspberry Pi/SBC ve diğer computer component;
- HDD/SSD, flash drive, memory card ve computer storage;
- modem, router, switch, access point ve network equipment;
- laptop/tablet dock, computer-specific USB hub ve computer power supply.

Bir generic USB/HDMI kablo birden çok consumer cihaz arasında kullanılabiliyorsa
Elektronik → Güç, Şarj & Bağlantı'ya adaydır. Bir dock/hub bilgisayarın port ve
ekran/input genişletmesiyse Bilgisayar & Tablet'tir. Bu ayrım connector adına göre
değil ana kullanım şemasına göre yapılır.

Arduino/ESP geliştirme kartı, breadboard, sensör/modül, röle, direnç, kondansatör,
diyot, transistör ve entegre **Elektronik → Elektronik Bileşenler** kapsamındadır;
bu owner-final istisna Bilgisayar & Tablet'e ürün sızıntısı değildir. Raspberry Pi
ve diğer SBC'ler ise **Bilgisayar & Tablet → Bilgisayar Bileşenleri** kapsamındadır.

## 4. Candidate L2 comparison

### Department evidence matrix

| Department hipotezi | Google | Trendyol | Hepsiburada | n11 | Amazon TR | Sonuç |
|---|---|---|---|---|---|---|
| Telefon & Aksesuarları | Telephony + mobile accessories | Açık browse adı | Telefon güçlü teknoloji talebi | Açık nav adı | Telefon ve accessory ayrımı | **KEEP / bir L2, içeride ayrışabilir** |
| TV & Görüntü Sistemleri | Video branch | TV&Görüntü&Ses | Televizyon yoğun aranan/büyük hacimli | TV & Ses | TV, electronics | **KEEP / sesi ayır** |
| Ses & Kulaklık | Audio branch | Kulaklık ayrıca görünür | Bluetooth kulaklık güçlü | TV ile birlikte | Audio/electronics | **KEEP / bağımsız L2** |
| Fotoğraf & Kamera | Ayrı top-level Cameras & Optics | Açık browse adı | 2026'da ayrı büyüyen category | Açık nav adı | Ayrı satış category'si | **KEEP / owner-final L1 altında L2** |
| Oyun Konsolu & Aksesuarları | Console + console accessories | Oyun&Konsollar | Konsol güçlü teknoloji grubu | Video Oyun & Konsol | Elektronik/gaming browse | **KEEP / “Gaming” adını daralt** |
| Giyilebilir Teknoloji | Official snapshot modern wearable'ı iyi temsil etmiyor | Açık browse adı | Akıllı saat yoğun aranan | Popüler smart-watch intent | Phone/accessory ile yakın | **KEEP / legacy telefondan ayır** |
| Akıllı Ev & Güvenlik | Security/home automation farklı top-level'lara dağılmış | Tek, açık üst bölüm kanıtı zayıf | Akıllı yaşam sinyali var | Üst nav kanıtı zayıf | Electronics accessory içinde dağılabilir | **KEEP / yalnız dar scope ile** |
| Generic Elektronik Aksesuar | Electronics Accessories çok geniş | Açık browse adı | Accessory talebi var | Dallara dağılmış | Çok geniş accessory category'si | **NARROW → Güç, Şarj & Bağlantı** |
| Elektronik Bileşenler | Circuit boards/components farklı dallarda bulunabilir | Üst browse kanıtı sınırlı | Kamu L2 ağacı kanıtı sınırlı | Üst nav kanıtı sınırlı | Generic electronics/accessory içinde dağılabilir | **OWNER FINAL / yerel maker-elektronikçi sınırı** |
| Bilgisayar / Tablet | Google Electronics içinde | Elektronik browse içinde | Teknoloji talebinde | Elektronik nav içinde | Ayrı sales category | **REJECT — ayrı owner-final L1** |
| Beyaz Eşya / Ev Aletleri | Farklı function branches | Elektronik browse içinde | Ayrı demand/category | Elektronik nav içinde | Ev/Mutfak category'si | **REJECT — ayrı owner-final L1** |

### Architecture alternatives

| Alternatif | L2 sayısı | Artı | Risk | Karar |
|---|---:|---|---|---|
| Legacy full-tree yaklaşımı | 6 | Küçük ve mevcut artefakta yakın | Telefon+wearable, audio+video, camera+security gibi farklı intent/schema'ları birleştirir; generic component catch-all taşır | **REJECT AS CANONICAL PROPOSAL** |
| Marketplace compact mirror | 6–7 | Müşteriye tanıdık üst menü | Bilgisayar, beyaz eşya, dijital ürün ve küçük ev aleti sızıntısı; merchant merchandising'i canonical ownership yapar | **REJECT** |
| Telefon cihazı ve aksesuarını iki ayrı L2 yapmak | 10 | Accessory hacmi görünür | Yerel telefoncu keşfini böler; L3 ile çözülebilecek ayrımı L2'ye taşır | **REJECTED BY OWNER-FINAL BOUNDARY** |
| Her küçük accessory'yi L2 yapmak | 10+ | Marketplace filtre derinliğine benzer | Boş dallar, duplicate ürün, yanlış merchant seçimi, category/facet karışması | **REJECT** |
| Phase B1 dengeli öneri | 8 | Güçlü müşteri intent'leri ayrılır; L1 sınırları temiz | Yerel maker/devre ürünleri için açık ownership üretmez | **SUPERSEDED** |
| **Owner-final dengeli model** | **9** | Güçlü müşteri intent'leri ile consumer-facing maker domain'i ayrılır; L1 sınırları ve gelecekteki L3/L4 açılımı nettir | Full L3/L4, stable identity ve attribute profile kararları sonraki fazdadır | **CONFIRMED — PRODUCT OWNER FINAL** |

## 5. Final Electronics L2

**State: CONFIRMED — PRODUCT OWNER FINAL**

Owner tarafından onaylanan exact sıra ve dokuz L2:

1. **Telefon & Aksesuarları**
2. **TV & Görüntü Sistemleri**
3. **Ses & Kulaklık**
4. **Fotoğraf & Kamera**
5. **Oyun Konsolu & Aksesuarları**
6. **Giyilebilir Teknoloji**
7. **Akıllı Ev & Güvenlik**
8. **Güç, Şarj & Bağlantı**
9. **Elektronik Bileşenler**

Phase B1'deki sekiz L2 önerisi **SUPERSEDED** durumundadır.

### Neden dokuz?

- Telefon cihazı ve aksesuarı aynı local-shop/customer entry'sinde kalır; ileride L3
  ile ayrılır.
- Wearable, telefon altında kaybolmayacak kadar farklı şema ve müşteri niyeti taşır.
- TV/görüntü ve audio, ortak kullanımına rağmen farklı ürün şeması ve arama niyetine
  sahiptir.
- Fotoğraf/kamera ile güvenlik camera'sı aynı “kamera” sözcüğünü paylaşır ama amaç,
  merchant verisi ve customer expectation farklıdır.
- `Gaming` tek başına kullanılmaz; PC gaming sızıntısını önlemek için L2 adı konsola
  bağlanır.
- “Elektronik Aksesuar” catch-all'ı yerine gerçek ortak işlevler olan güç, şarj ve
  bağlantı açıkça adlandırılır.
- Arduino/ESP, sensör/modül ve devre elemanları yerel elektronikçi/maker keşfinde
  görünür olur; Raspberry Pi/SBC ve bilgisayar bileşenleriyle karışmaz.

Local discoverability, taxonomy'yi shop type'a çevirmeden korunur: telefoncu,
elektronikçi, güvenlik sistemleri satıcısı veya fotoğrafçı merchant-sector kimliği
ayrı kalır; mağazanın ürünleri bu dokuz L2 altındaki gerçek product leaf'lerine
bağlanır. Customer browse yalnız yakında aktif offer bulunan L2'leri öne çıkarabilir;
bu availability projection canonical ağacı veya owner-final L2 sırasını değiştirmez.

Bu exact sıra canonical karardır; discovery/ranking puanı değildir. Runtime
`sort_order` implementation'ı ve bölgesel availability projection'ı ayrı görevdir.

## 6. Per-L2 definition

| # | Final L2 | Canonical kapsam | Kısa boundary rule |
|---:|---|---|---|
| 1 | **Telefon & Aksesuarları** | Mobil telefon cihazları ile özellikle telefon formuna/modeline bağlı koruma, montaj, şarj ve replacement aksesuarları | Tablet/e-reader bilgisayara; wearable ayrı L2'ye; vehicle-only fitment otomotive gider. Generic multi-device güç/kablo L2 8'e gider. |
| 2 | **TV & Görüntü Sistemleri** | Televizyon, projector, media/streaming player, uydu/alıcı ve TV/görüntüye özgü aksesuar | Computer monitor Bilgisayar & Tablet; camera L2 4; ses-only ürün L2 3; ev aleti bu L1'e girmez. |
| 3 | **Ses & Kulaklık** | Consumer kulaklık, earbuds, headset, speaker, soundbar/ev ses sistemi, genel mikrofon ve audio player/recorder | Enstrümana özgü performans ürünü Müzik & Enstrüman; vehicle-only audio Otomotiv; yalnız bilgisayara özgü peripheral Bilgisayar & Tablet. |
| 4 | **Fotoğraf & Kamera** | Fotoğraf/video/aksiyon camera, lens ve çekim işlevine özgü optik/lighting/support accessory | Security/baby camera L2 7; webcam Bilgisayar; dashcam Otomotiv; camera bag Çanta & Aksesuar; toy drone Oyuncak & Hobi. |
| 5 | **Oyun Konsolu & Aksesuarları** | Ev/taşınabilir oyun konsolu, console-specific controller/VR/charging accessory ve platforma bağlı fiziksel video oyunu | Gaming PC, monitor, keyboard/mouse ve PC-only peripheral Bilgisayar & Tablet; kutu/masa oyunu Oyuncak & Hobi. `Gaming` pazarlama etiketi category değildir. |
| 6 | **Giyilebilir Teknoloji** | Akıllı saat, akıllı bileklik, smart ring ve insana takılan consumer connected cihaz ile doğrudan aksesuarı | Klasik saat Saat & Takı; medical-purpose monitor Sağlık & Medikal; phone L2 1; yalnız spor ekipmanı olan cihaz ana işleve göre Spor & Outdoor review'ına gider. |
| 7 | **Akıllı Ev & Güvenlik** | Consumer automation hub/controller/sensor; smart bulb, smart plug, connected lock; security camera/recorder, electronic alarm, video doorbell, intercom ve baby monitor | Robot vacuum/klima/kahve makinesi Beyaz Eşya; passive home product Ev & Yaşam; sabit tesisat/mekanik kilit/safe Hırdavat; vehicle alarm/camera Otomotiv. |
| 8 | **Güç, Şarj & Bağlantı** | Birden çok consumer electronics ailesinde kullanılan pil/şarjlı pil, generic powerbank, generic şarj adaptörü, AV/data kablosu, converter ve generic connection accessory | Telefon modeline özgü accessory L2 1'e; camera/console-specific accessory kendi device L2'sine; computer dock/hub/network Bilgisayar; yapı kablosu/priz Hırdavat; vehicle harness/charger Otomotiv. |
| 9 | **Elektronik Bileşenler** | Consumer-facing maker ve yerel elektronikçi domain'indeki Arduino/ESP geliştirme kartı, breadboard/prototipleme ürünü, sensör/modül, röle/anahtarlama, direnç, kondansatör, diyot, transistör, entegre ve component-level konnektör | Raspberry Pi/SBC ve computer component Bilgisayar & Tablet; sabit bina tesisatı Hırdavat; toy/activity kit Oyuncak & Hobi; generic bitmiş kablo/şarj ürünü L2 8'e gider. |

### Catch-all yasağı

L2 8 ve L2 9, “hangi dala koyacağımız bilinmeyen elektronik” depoları değildir.
L2 8 ürünün güç, şarj veya cihazlar arası sinyal/bağlantı işlevine; L2 9 ise
tanımlanmış devre/prototipleme bileşeni ailesine açıkça girmesini gerektirir.
`Diğer Elektronik`, `Elektronik Ürünler`, `Parça` veya `Aksesuar` gibi çıplak
leaf'ler üretilmemelidir.

## 7. Product inclusion/exclusion examples

| Ürün | Primary placement | Gerekçe / exclusion |
|---|---|---|
| Akıllı telefon, tuşlu telefon | Elektronik → Telefon & Aksesuarları | Ana işlev mobil telephony. `5G`, storage ve brand facet'tir. |
| Telefon kılıfı, ekran koruyucu | Elektronik → Telefon & Aksesuarları | Device family'ye özgü compatibility taşır. |
| Tablet, e-kitap okuyucu | **Bilgisayar & Tablet** | Telefon ekran boyutu veya SIM özelliği ownership'i değiştirmez. |
| Akıllı saat / akıllı bileklik | Elektronik → Giyilebilir Teknoloji | Connected wearable şeması; klasik saatten ayrıdır. |
| Klasik quartz/dijital kol saati | **Saat & Takı** | Elektronik display taşıması smart-device yapmaz. |
| TWS earbuds / Bluetooth kulaklık | Elektronik → Ses & Kulaklık | `Bluetooth`, TWS ve connector category değil attribute/search alias'tır. |
| Universal gaming headset | Elektronik → Ses & Kulaklık | Ana işlev audio'dur; “oyuncu” kullanım niyeti category ownership üretmez. |
| TV, projector, TV box, uydu alıcısı | Elektronik → TV & Görüntü Sistemleri | Görüntüleme/media-consumption ana işlevi. |
| Computer monitor | **Bilgisayar & Tablet** | Computer display/peripheral şeması. TV tuner'lı sınır vakası ana marketed function ile review edilir. |
| Fotoğraf makinesi, aksiyon camera, lens | Elektronik → Fotoğraf & Kamera | Görüntü üretme/çekim ana işlevi. |
| Security camera, görüntülü kapı zili, baby monitor | Elektronik → Akıllı Ev & Güvenlik | İzleme/güvenlik/ev kontrolü; fotoğraf üretimi ana amaç değildir. |
| Webcam | **Bilgisayar & Tablet** | Computer input/video-conferencing peripheral. |
| Dashcam / araç head unit / vehicle tracker | **Otomotiv & Motosiklet** | Vehicle-only mount, fitment veya electrical integration. |
| Camera drone | Elektronik → Fotoğraf & Kamera | Ana ürün vaadi gerçek görüntü çekimi ise. |
| Basit oyuncak drone | **Oyuncak & Hobi** | Ana işlev oyun/aktivite; camera eklenmesi tek başına Elektronik yapmaz. |
| Oyun konsolu, console controller, fiziksel console game | Elektronik → Oyun Konsolu & Aksesuarları | Platform/format compatibility ana şemadır. |
| Console-first controller | Elektronik → Oyun Konsolu & Aksesuarları | Birincil platform ve compatibility console'dur. |
| Gaming laptop, PC keyboard/mouse, PC-first controller/peripheral, PC graphics card | **Bilgisayar & Tablet** | “Gaming” category değil kullanım/merchandising sinyalidir; birincil platform PC'dir. |
| Robot süpürge, smart coffee machine, connected klima | **Beyaz Eşya & Ev Aletleri** | Connectivity ana appliance işlevini değiştirmez. |
| Generic powerbank / kablo / multi-device şarj adaptörü | Elektronik → Güç, Şarj & Bağlantı | Device-agnostic güç, şarj veya bağlantı ana işlevi. |
| Phone battery case / phone-specific charging cradle | Elektronik → Telefon & Aksesuarları | Telefon modeline özgü compatibility. |
| HDMI/AUX/generic USB cable | Elektronik → Güç, Şarj & Bağlantı | Generic signal/power link. `USB-C` leaf değil connector facet'tir. |
| Laptop dock / computer-specific USB hub | **Bilgisayar & Tablet** | Computer I/O expansion ana işlevi. |
| Raspberry Pi / diğer SBC | **Bilgisayar & Tablet → Bilgisayar Bileşenleri** | Ana işlev single-board computing platformudur. |
| Kamera çantası | **Çanta & Aksesuar** | Ana işlev taşıma; camera compatibility facet'tir. |
| Arduino/ESP, breadboard, röle, sensör, direnç, kondansatör, diyot, transistör, entegre ve genel elektronik modül | Elektronik → Elektronik Bileşenler | Consumer-facing maker/devre elemanı domain'i. Gerçek toy/activity kit, SBC veya bina tesisatı ürünü bu L2'ye girmez. |
| Smart bulb, smart plug, connected lock | Elektronik → Akıllı Ev & Güvenlik | Owner-final sınır: consumer connected home control/security endpoint'i. |

### Ambiguous-product adjudication order

1. Ürünün kullanıcıya vaat edilen ana işlevini belirle.
2. Merchant'ın doğru veri girişi için gereken teknik şemayı belirle.
3. Device/vehicle/computer compatibility'nin primary mi facet mi olduğunu belirle.
4. Regulated/safety policy sınıfını category'den ayrı değerlendir.
5. İki aday kalırsa duplicate category verme; taxonomy review log'una gönder.

## 8. Future L3/L4 expansion examples

Aşağıdakiler **yalnız yapısal feasibility örneğidir**; eksiksiz veya final L3/L4
listesi değildir, ID/slug/sort-order kararı üretmez.

| L2 | Olası variable-depth örneği | Yapısal not |
|---|---|---|
| Telefon & Aksesuarları | Elektronik → Telefon & Aksesuarları → Telefonlar → Akıllı Telefon | Telefonlar L3 group; gerçek ayrım gerekirse L4. Brand/storage/5G node olmaz. |
| Telefon & Aksesuarları | Elektronik → Telefon & Aksesuarları → Telefon Koruma → Telefon Kılıfı | Compatibility leaf attribute profile'ında çözülür. |
| TV & Görüntü Sistemleri | Elektronik → TV & Görüntü Sistemleri → Medya Oynatıcılar → TV Kutusu | Streaming service/OS category yerine facet olabilir. |
| Ses & Kulaklık | Elektronik → Ses & Kulaklık → Kulaklık → TWS Kulaklık | TWS, gerçekten farklı merchant şeması doğrulanırsa L4 olabilir; aksi halde form-factor facet kalabilir. |
| Fotoğraf & Kamera | Elektronik → Fotoğraf & Kamera → Kameralar → Aksiyon Kamerası | Camera type gerçek ürün tipi; sensor/megapixel facet'tir. |
| Oyun Konsolu & Aksesuarları | Elektronik → Oyun Konsolu & Aksesuarları → Konsollar → Taşınabilir Oyun Konsolu | Brand/platform category node olmaz; compatibility registry'de tutulur. |
| Giyilebilir Teknoloji | Elektronik → Giyilebilir Teknoloji → Akıllı Saat | L3 doğal leaf ise yapay L4 açılmaz. |
| Akıllı Ev & Güvenlik | Elektronik → Akıllı Ev & Güvenlik → Ev Güvenliği → Görüntülü Kapı Zili | Protocol/ecosystem category değil facet'tir. |
| Güç, Şarj & Bağlantı | Elektronik → Güç, Şarj & Bağlantı → Taşınabilir Güç → Powerbank | Capacity, watt ve connector facet'tir. |
| Elektronik Bileşenler | Elektronik → Elektronik Bileşenler → Geliştirme Kartları → Arduino/ESP Kartları | Board family, işlemci, pin ve interface facet olabilir; bu yol Raspberry Pi/SBC'yi kapsamaz. |
| Elektronik Bileşenler | Elektronik → Elektronik Bileşenler → Pasif Devre Elemanları → Direnç | Component family yapısal node olabilir; resistance, tolerance, power ve package facet'tir. |

Dokuz L2 için owner approval tamamlanmıştır. Gelecekteki L3/L4 adayları yalnız örnek
olarak **Geliştirme Kartları**, **Sensör & Modüller**, **Pasif Devre Elemanları**,
**Aktif Devre Elemanları**, **Röle & Anahtarlama**, **Breadboard & Prototipleme**
ve **Konnektör & Elektronik Bağlantı** başlıklarını içerebilir. Bunlar bu görevde
final node, sıra, ID veya leaf değildir. Full L3/L4'e geçmeden önce gerçek yerel
merchant SKU coverage pilotu ve current full-tree stable identity reconciliation
planı tamamlanmalıdır.

## 9. Facet hints

Bu tablo implementation değildir. İleride category-specific typed attribute profile
tasarımına girdi sağlar.

| L2 | Olası facet/attribute aileleri |
|---|---|
| Telefon & Aksesuarları | brand, device type, operating system, storage, RAM, screen size, network generation, SIM form, color, model compatibility, charging power |
| TV & Görüntü Sistemleri | brand, display size, panel/display technology, resolution, refresh rate, tuner, operating system, HDR, mounting standard, connectivity |
| Ses & Kulaklık | form factor, wired/wireless, connector, codec, ANC/ENC, microphone, channel layout, power, battery life, water resistance |
| Fotoğraf & Kamera | camera type, sensor format, lens mount, focal length, resolution, stabilization, optical zoom, video format, accessory compatibility |
| Oyun Konsolu & Aksesuarları | platform compatibility, console generation, game media/region, controller type, connectivity, player count, physical format |
| Giyilebilir Teknoloji | device type, phone/OS compatibility, case size, display, sensor set, GPS/cellular, water resistance, battery life, band compatibility |
| Akıllı Ev & Güvenlik | device type, protocol, ecosystem compatibility, indoor/outdoor, power source, camera resolution, recording/storage mode, detection type, installation |
| Güç, Şarj & Bağlantı | product type, input/output connector, charging protocol, wattage, capacity, voltage/current, cable length, signal standard, battery chemistry, device compatibility |
| Elektronik Bileşenler | component family, board/module family, mounting/package type, resistance/capacitance, voltage/current/power tolerance, pin count, interface/protocol, dimensions, maker compatibility |

### Explicit non-category facets

- **Brand:** Apple, Samsung, Xiaomi ve tüm diğer üretici adları
- **Connectivity:** Bluetooth, Wi-Fi, NFC, Zigbee, Matter, USB-C, HDMI
- **Capacity:** 128 GB, 10.000 mAh ve benzeri değerler
- **Network/technical feature:** 5G, 4K, ANC, PD, HDR
- **Appearance:** siyah, beyaz, materyal, finish
- **Compatibility:** phone model, console platform, lens mount, ecosystem

Bu değerler filter/search/validation alanıdır; L2 değildir.

## 10. Synonym hints

Synonym/alias'lar canonical display name değildir ve bu görevde backend'e
uygulanmaz. Marka adı synonym olarak kaydedilmez.

| Scope | Candidate synonym / alias hints | Not |
|---|---|---|
| Telefon | telefon, cep telefonu, akıllı telefon, smartphone | `5G`, model ve brand facet'tir. |
| Telefon aksesuarı | telefon aksesuarı, mobil aksesuar, telefon kılıfı, ekran koruyucu | Leaf suggestion'a düşük/orta ağırlıkla gider. |
| TV & görüntü | TV, televizyon, görüntü sistemi, projeksiyon, projektör, TV box, medya oynatıcı | `Projektör` hırdavat aydınlatmasıyla yanlış eşleşmeye karşı context ister. |
| Ses & kulaklık | kulaklık, earbuds, TWS, bluetooth kulaklık, hoparlör, speaker, soundbar, ses sistemi | Bluetooth category değildir; search term olabilir. |
| Fotoğraf & kamera | fotoğraf makinesi, kamera, dijital kamera, aynasız kamera, mirrorless, aksiyon kamera | Güvenlik kamerası ayrı L2 context'i taşır. |
| Oyun konsolu | oyun konsolu, konsol, game console, gamepad, oyun kolu, joystick | Platform/brand adları brand/compatibility index'inden gelir. |
| Giyilebilir teknoloji | giyilebilir teknoloji, akıllı saat, smartwatch, smart watch, akıllı bileklik, smart band | Klasik saat sorgusu Saat & Takı'ya gider. |
| Akıllı ev & güvenlik | akıllı ev, ev otomasyonu, güvenlik kamerası, IP kamera, alarm sistemi, görüntülü kapı zili, bebek kamerası | `kamera` tek başına Photo ve Security intent'ini disambiguate etmelidir. |
| Güç/şarj/bağlantı | powerbank, power bank, taşınabilir şarj, şarj aleti, şarj cihazı, adaptör, dönüştürücü, kablo | USB-C/HDMI gibi standardlar facet ve leaf-search token'ı olabilir. |
| Elektronik bileşen | elektronik bileşen, devre elemanı, geliştirme kartı, development board, deney tahtası, breadboard, sensör, sensor, modül, röle, relay, entegre, IC | Raspberry Pi/SBC computer path'ine gider; marka/platform adı category veya synonym değildir. |

Search implementation'ı canonical ad > exact semantic synonym > alias > normalized
token ağırlığını korumalı; typo/fuzzy ve marka sorguları synonym registry'ye
yazılmamalıdır.

## 11. Owner-final decisions and remaining TBDs

### Product owner tarafından FINAL onaylanan sınırlar

- Smart bulb, smart plug ve connected lock → **Akıllı Ev & Güvenlik**.
- Generic powerbank, kablo ve şarj adaptörü → **Güç, Şarj & Bağlantı**.
- Telefon modeline özgü kılıf, ekran koruyucu ve device-specific accessory →
  **Telefon & Aksesuarları**.
- Camera drone → **Fotoğraf & Kamera**; toy drone → **Oyuncak & Hobi**.
- Arduino, ESP, breadboard, röle, sensör, direnç, kondansatör, diyot, transistör,
  entegre ve genel elektronik modüller → **Elektronik Bileşenler**.
- Raspberry Pi ve diğer SBC'ler → **Bilgisayar & Tablet → Bilgisayar Bileşenleri**.
- Console-first controller → **Oyun Konsolu & Aksesuarları**; PC-first gaming
  peripheral → **Bilgisayar & Tablet**.
- General audio/headphone → **Ses & Kulaklık**.
- Fitment veya installation gerektiren vehicle-specific electronics →
  **Otomotiv & Motosiklet**.
- Robot vacuum, klima ve coffee machine → **Beyaz Eşya & Ev Aletleri**.
- Classic watch → **Saat & Takı**; smartwatch → **Giyilebilir Teknoloji**.

### Remaining TBDs

Bu maddeler owner-final L2 kararını değiştirmez ve bu görevde çözülmez:

1. Full L3/L4 adları, sırası, leaf/assignability ve variable-depth kararları.
2. Stable ID/slug üretimi ile current taxonomy JSON reconciliation planı.
3. Per-category typed attribute profile, compatibility ve synonym registry tasarımı.
4. Elektronik bileşenlerde mains voltage, battery ve wireless ürünleri için safety,
   compliance ve evidence kuralları.
5. Gerçek yerel merchant SKU coverage pilotu ve taxonomy governance süreci.
6. Runtime, DB, migration, search, Flutter ve Figma uygulaması için ayrı yetki.

### Final outcome markers

`ELECTRONICS_L1_NAME: UNCHANGED — ELEKTRONİK`

`ELECTRONICS_B1_8_L2_PROPOSAL: SUPERSEDED`

`ELECTRONICS_L2_OWNER_APPROVAL: FINAL`

`ELECTRONICS_L2_STATE: CONFIRMED — PRODUCT OWNER FINAL`

`ELECTRONICS_L2_COUNT: 9`

`ELECTRONICS_COMPUTER_BOUNDARY: PASS`

`ARDUINO_ESP_BOUNDARY: PASS — ELEKTRONİK BİLEŞENLER`

`RASPBERRY_PI_SBC_BOUNDARY: PASS — BİLGİSAYAR & TABLET`

`COMPUTER_TABLET_LEAKAGE_AUDIT: PASS`

`BRAND_AS_CATEGORY: NONE`

`DUPLICATE_L2: NONE`

`VARIABLE_DEPTH_FEASIBILITY: PASS`

`RUNTIME_IMPLEMENTATION: NOT STARTED`

`READY_FOR_B1_INTEGRATION: YES`

`READY_FOR_L3_L4: NO`
