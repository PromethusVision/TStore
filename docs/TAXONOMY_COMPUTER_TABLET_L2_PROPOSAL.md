# EsnaftaVar — Bilgisayar & Tablet L2 Proposal

**Wave:** 15 / Phase B2

**Belge tarihi:** 27 Ağustos 2026

**Karar durumu:** **CONFIRMED — PRODUCT OWNER FINAL**

**Owner approval:** 27 Ağustos 2026 / Wave 15 Phase B2A — **FINAL**

**Canonical L1:** **Bilgisayar & Tablet — CONFIRMED / PRODUCT OWNER FINAL**

**Kapsam:** Yalnız L2 bilgi mimarisi. L3/L4 örnekleri gelecek tasarıma yön verir;
canonical node, stable ID, JSON, migration, seed veya runtime üretmez.

## 1. Scope

Bu öneri, EsnaftaVar müşterisinin yakındaki fiziksel mağazada bilgisayar, tablet ve
doğrudan bunlara bağlı ürünleri bulacağı kalıcı L2 omurgasını tanımlar. Tasarım şu
canonical kuralları uygular:

- L1 adı ve kapsamı **Bilgisayar & Tablet** olarak değişmeden kalır.
- Her ürün ileride tam olarak bir primary assignable leaf'e bağlanır; ikinci bir
  canonical kategoriye fiziksel olarak kopyalanmaz.
- L2, müşteri açısından anlamlı major department'tır. Bütün dallar L3/L4'e zorlanmaz;
  L2 doğal olarak leaf olabilir.
- Marka, kapasite, teknik özellik, hedef kullanım ve “gaming” etiketi category değil
  facet/attribute veya discovery sinyalidir.
- Türkiye müşteri dili ve mahalle bilgisayarcısı/kırtasiyesi discoverability'si,
  global pazar yeri ağacını birebir kopyalamaktan önceliklidir.
- Bu çalışma mevcut `docs/data/esnaftavar_category_taxonomy_v1_final.json` ağacını
  reconcile etmez ve hiçbir runtime/remote yüzeyi değiştirmez.

## 2. Sources

Araştırma 27 Ağustos 2026 tarihinde kamuya açık kaynaklardan yeniden doğrulandı.
Platform adları kanıt/karşılaştırma kaynağıdır; EsnaftaVar taxonomy'sinin sahibi
değildir.

| Kaynak | Gözlenen yapı / dil | EsnaftaVar'a alınan ders | Sınırlama |
|---|---|---|---|
| [Google Product Taxonomy — public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center category contract](https://support.google.com/merchants/answer/6324436?hl=en) | `Computers` altında desktop, laptop, tablet ve e-reader; ayrı computer accessories/components/input/storage; ayrıca networking, print/scan ve computer monitor dalları var. Google tek kategori, ana fonksiyon ve mümkün olan en spesifik eşleşmeyi ister. | Cihaz form faktörü, bileşen, depolama, aktif çevre birimi, ağ ve baskı farklı şema aileleridir. Ana fonksiyon sınır kuralıdır. | Public dosyanın erişimi güncel olsa da header sürümü `2021-09-21`'dir; global/endüstriyel uzun kuyruk Türkiye launch ağacı olarak kopyalanmadı. |
| [Trendyol Bilgisayar & Tablet](https://www.trendyol.com/bilgisayar-tablet-x-c103660), [Bilgisayar Bileşenleri](https://www.trendyol.com/bilgisayar-bilesenleri-x-c103662), [kategori ağacı](https://developers.trendyol.com/docs/trendyol-kategori-listesi-getcategorytree) ve [kategori özellikleri V2](https://developers.trendyol.com/docs/kategori-%C3%B6zellik-listesi-v2) | Güncel müşteri metni masaüstü, dizüstü ve tableti ayırıyor; kasa/PSU/anakart/CPU/GPU/storage'ı bileşen, monitör/klavye/mouse'u çevre birimi olarak anlatıyor. Gaming bilgisayar aynı cihaz formunda kalıyor. API yalnız leaf assignment ve category-attribute ayrımını uyguluyor. | Türkçe cihaz adları, gaming'in facet/use-case olması ve category ile attribute'un ayrılması destekleniyor. | Canlı merchandising linkleri ve arama landing'leri canonical hierarchy sayılmadı; haftalık değişebilen marketplace ağacı wholesale alınmadı. |
| [Hepsiburada 2026 tablet/laptop karşılaştırması](https://www.hepsiburada.com/hayatburada/tablet-mi-laptop-mu-hangisi-sizin-icin-daha-uygun/), [bilgisayar türleri](https://www.hepsiburada.com/hayatburada/7-bilgisayar-cesidi-ve-ozellikleri/) ve [Katalog API rehberi](https://developers.hepsiburada.com/tr/companies/hepsiburada?guide=katalog-onemli-bilgiler&product=katalog-urun-entegrasyonu&view=guide) | Laptop, tablet, masaüstü/mini ve gaming kullanım dili ayrışıyor; tablet için klavye, kalem, kılıf ve USB-C hub gibi aksesuar beklentisi görülüyor. Katalog sözleşmesi leaf/active/available ve category-specific data modelini ayırıyor. | Cihaz formu ile aksesuarı ayırmak ve gaming'i cihazın yerini değiştirmeyen bir nitelik saymak müşteri beklentisiyle uyumlu. | Public rehber tam ve sabit L2 listesini göstermediği için Hepsiburada'dan eksiksiz ağaç sonucu çıkarılmadı. |
| [n11 Bilgisayar landing](https://www.n11.com/bilgisayar?iw=pc), [Bilgisayar Bileşenleri](https://www.n11.com/bilgisayar/bilgisayar-bilesenleri), [Çevre Birimleri](https://www.n11.com/bilgisayar/cevre-birimleri), [Yazıcı, Tarayıcı ve Aksesuarları](https://www.n11.com/bilgisayar/yazici-tarayici-ve-aksesuarlari) ve [kategori API sözleşmesi](https://developer.n11.com/documentation/n11-marketplace-entegrasyonu/kategori-agaci-listeleme/) | Müşteri yüzeyi laptop, desktop, tablet, component, peripheral, accessory, printer/scanner, network, storage ve e-reader ailelerini açıkça kullanıyor. Printer altında toner/kartuş; peripheral altında monitor, keyboard/mouse, webcam ve PC headset örnekleri var. Konsol/video oyun ayrıca Elektronik altında gösteriliyor. | Türkiye arama dili ve fiziksel mağaza rafı için önerilen L2 breadth'i doğruluyor; printer sarfı ve PC-specific peripheral sınırını görünür kılıyor. | `Ofis Elektroniği`, yazılım ve sunucu gibi marketplace genişliği launch L2'sine otomatik alınmadı. Ürünler tek tek ana fonksiyonla değerlendirildi. |
| Repo canonical kararları: `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md` ve mevcut V1 history | Product/Merchant/Facet ayrımı, max-4 variable depth, exactly-one primary leaf, stable identity ve **Bilgisayar & Tablet** L1 sınırı kilitlidir. | Yeni L2 proposal bu architecture'a uyar; eski dört-L2 full tree yalnız karşılaştırma girdisidir. | 23-L1 eski full-tree JSON, owner-approved 24-L1 lock ile henüz reconcile edilmemiştir; bu belge onu değiştirmez. |

Kaynak bütünlüğü sonucu: Platformlar ortak fonksiyon ailelerini destekliyor; fakat
hiçbir platformun node ID'si, sırası veya eksiksiz ağacı EsnaftaVar'a kopyalanmadı.
Google public snapshot tarihi ayrıca açıkça kaydedildi.

## 3. Boundary with Electronics

Canonical üst sınır: **ana cihaz fonksiyonu**. Bağlantılı, USB'li veya “akıllı” olmak
tek başına ürünü Bilgisayar & Tablet'e taşımaz.

| Bilgisayar & Tablet içinde | Elektronik içinde | Sınır kuralı |
|---|---|---|
| Dizüstü/masaüstü bilgisayar, tablet, e-kitap okuyucu | Telefon, akıllı saat/giyilebilir, TV, genel ses/görüntü cihazı, kamera | Ürünün primary cihaz kimliği kullanılır; uyumlu olduğu başka cihaz ikinci category üretmez. |
| Webcam | Güvenlik/IP kamera, aksiyon/dijital kamera, bebek kamerası | PC'ye canlı görüntü girdisi veren webcam burada; bağımsız kayıt/güvenlik/camera cihazı Elektronik'te. |
| PC-primary USB/kablolu iletişim veya gaming headset | Genel Bluetooth/TWS/hi-fi kulaklık, hoparlör, standalone mikrofon | Açık PC-primary uyumluluk ve bilgisayar giriş/çıkış rolü gerekir. Belirgin PC primacy yoksa ana ses işlevi nedeniyle Elektronik. |
| USB hub, bilgisayar dock istasyonu, PC-specific adapter | Genel AV switch/splitter, TV cihazı, power bank ve genel şarj ürünü | Bilgisayar port/iş akışını çoğaltan ürün aksesuar; genel audio/video veya power ürünü Elektronik. |
| PC-primary gamepad/joystick | PlayStation, Xbox, Nintendo konsolu ve console-first kontrolcü/oyun | Gaming kendi başına category değildir. Primary platform/uyumluluk belirler; console-first ürün Elektronik'tedir. |
| Bilgisayar monitörü | TV, projektör ve genel digital signage | Monitor bilgisayar görüntü çıkışıdır; tuner/TV veya projection primary ise Elektronik. |
| Raspberry Pi ve diğer single-board computer (SBC) | Arduino, ESP ve generic elektronik development board | İşletim sistemi çalıştıran genel amaçlı SBC, Bilgisayar Bileşenleri; microcontroller/development board, Elektronik → Elektronik Bileşenler. |

**Gaming canonical rule — PRODUCT OWNER FINAL:** Gaming laptop, gaming PC, gaming monitor ve gaming
keyboard/mouse kendi fonksiyonel L2'sinde kalır. `gaming`, `oyuncu`, RGB, yenileme hızı
ve benzeri nitelikler facet/search sinyalidir. PlayStation/Xbox/Nintendo konsolları,
console-first controller'lar ve fiziksel konsol oyunları **Elektronik → Oyun Konsolu
& Aksesuarları** tarafında kalır. PC-primary gaming headset **Klavye, Mouse & Çevre
Birimleri** altında veya gelecek L3 contract'ındaki PC peripheral child'ında kalır.
Böylece aynı gaming ürünü ikinci bir L2 altında çoğaltılmaz.

## 4. Boundary with Kırtasiye & Ofis

Önerilen temel ayrım:

- **Dijital veriyi üreten/yakalayan baskı cihazı → Bilgisayar & Tablet.** Yazıcı,
  çok fonksiyonlu yazıcı, tarayıcı, 3D yazıcı, barkod/fiş yazıcısı bu taraftadır.
- **Kâğıt ve genel ofis tüketimi → Kırtasiye & Ofis.** Fotokopi kâğıdı, etiket,
  termal rulo, defter, dosyalama, laminasyon poşeti ve genel kırtasiye sarfı burada
  değildir.
- **Baskı dışı ofis cihazı → Kırtasiye & Ofis.** Hesap makinesi, evrak imha makinesi,
  laminasyon cihazı ve ciltleme makinesi computer peripheral sayılmaz.

### Toner/kartuş ve 3D baskı — PRODUCT OWNER FINAL

Toner, kartuş, mürekkep dolumu, drum, yazıcı şeridi ve
device-specific printhead; model/teknoloji uyumluluğu baskı cihazıyla birlikte arandığı
için **Bilgisayar & Tablet → Yazıcı, Tarayıcı & Sarf Malzemeleri** altında kalmalıdır.
Kâğıt/etiket/rulo ise Kırtasiye & Ofis'te kalır.

3D printer ve 3D filament de aynı L2 altında kalır. Gelecek L3 ayrımı yapılabilir;
yeni L2 oluşturulmaz. Genel paper/notebook/office consumable her durumda **Kırtasiye
& Ofis**'tedir. Aynı sarf iki L1'e atanamaz.

## 5. Candidate L2 comparison

| Candidate | Final sonuç | Gerekçe / challenge sonucu |
|---|---|---|
| Dizüstü Bilgisayar | **KEEP** | Güçlü Türkçe arama niyeti, taşınabilir form ve ayrı facet profili. Gaming/iş/öğrenci alt category değil facet'tir. |
| Masaüstü Bilgisayar | **KEEP** | Hazır sistem, all-in-one, mini PC ve barebone için kalıcı cihaz omurgası. Gaming ayrı L2 yapılmaz. |
| Tablet | **KEEP** | Dokunmatik mobil bilgisayar formu ve aksesuar/attribute sözleşmesi laptop'tan ayrıdır. |
| E-Kitap Okuyucu | **ADD** | Google ve n11 ayrı müşteri kavramı olarak destekliyor; tablet değildir ve ekran/format facet profili farklıdır. Düşük hacimde L2 leaf olabilir. |
| Monitör | **KEEP / PROMOTE** | Çok güçlü bağımsız arama niyeti ve özgün panel/refresh/port facetleri; generic peripheral altında saklanmamalı. |
| Bilgisayar Bileşenleri | **KEEP** | CPU/GPU/motherboard/RAM/PSU/case/cooling gelecek L3/L4'te açılır; bunları L2'ye parçalamak inflation yaratır. |
| Depolama | **KEEP, adı `Veri Depolama`** | Internal/external SSD/HDD, flash, memory card, optical ve NAS'ın ortak ana işlevi veri saklamadır. Internal disk Bileşenler'de ikinci kez yer almaz. |
| Bilgisayar Aksesuarları | **KEEP WITH NARROW BOUNDARY** | Hub/dock/stand/cooling/privacy/PC-specific adapter gibi destek ürünleri. Aktif input/output peripheral ve taşıma çantası burada değildir. |
| Klavye, Mouse & Çevre Birimleri | **KEEP** | Klavye/mouse müşteri anchor'ı; graphics tablet, webcam ve açık PC-primary headset/controller gibi aktif giriş/çıkış ürünlerini kapsar. Monitor ve printer ayrı L2'dir. |
| Yazıcı, Tarayıcı & Sarf | **KEEP — OWNER FINAL** | Cihazlar, device-specific toner/kartuş ve 3D filament burada; genel paper/office sarf excluded. |
| Ağ & İnternet Ürünleri | **KEEP** | Modem/router/mesh/AP/switch/network adapter ayrı compatibility/topology facet ailesidir. Consumer smart-home ve telecom cihazlarına genişlemez. |
| Sunucu & Kurumsal Sistemler | **DEFER / NOT L2 NOW** | Local B2C launch discoverability'si belirsiz; rack/server/UPS kurumsal şema ve policy gerektirir. Ölçülmüş merchant/catalog talebiyle ayrıca açılabilir. |
| Oyun & Yazılım | **REJECT AS L2** | Gaming attribute/use-case'tir; console Elektronik'tedir. Digital-only yazılım canonical V1 excluded baseline ile çelişir. |
| Ofis Elektroniği | **REJECT AS L2** | Ürün işlevi yerine geniş satış kanalı sepeti yaratır; baskı cihazı burada, diğer office devices Kırtasiye & Ofis'te sınıflanır. |

## 6. Recommended L2

**Durum: CONFIRMED — PRODUCT OWNER FINAL.** Final L2 sayısı **11**'dir; ad ve sıra
aşağıdaki biçimde kilitlidir.

| # | Recommended L2 | Display-route candidate (identity değildir) | Ana customer intent |
|---:|---|---|---|
| 1 | Dizüstü Bilgisayar | `dizustu-bilgisayar` | Laptop/notebook cihazı bulmak |
| 2 | Masaüstü Bilgisayar | `masaustu-bilgisayar` | Hazır/masaüstü bilgisayar sistemi bulmak |
| 3 | Tablet | `tablet` | Tablet bilgisayar bulmak |
| 4 | E-Kitap Okuyucu | `e-kitap-okuyucu` | Okuma odaklı fiziksel cihaz bulmak |
| 5 | Monitör | `monitor` | Bilgisayar ekranı bulmak |
| 6 | Bilgisayar Bileşenleri | `bilgisayar-bilesenleri` | Sistem kurmak/yükseltmek için core parça bulmak |
| 7 | Veri Depolama | `veri-depolama` | Veriyi saklama/yedekleme donanımı bulmak |
| 8 | Klavye, Mouse & Çevre Birimleri | `klavye-mouse-cevre-birimleri` | Bilgisayara aktif input/output/interaction ürünü bağlamak |
| 9 | Bilgisayar Aksesuarları | `bilgisayar-aksesuarlari` | Bilgisayarı bağlayan, destekleyen veya koruyan ikincil ürün bulmak |
| 10 | Yazıcı, Tarayıcı & Sarf Malzemeleri | `yazici-tarayici-sarf` | Baskı/tarama cihazı ve uyumlu device-specific sarf bulmak |
| 11 | Ağ & İnternet Ürünleri | `ag-internet-urunleri` | Yerel internet/ağ bağlantısı kurmak veya genişletmek |

Normalized duplicate L2 adı: **0**. Marka-as-category: **0**. Attribute-as-category:
**0**. Sıra commercial ranking değildir; cihaz → görüntü → internal hardware →
supporting hardware akışı için deterministic canonical sıradır.

## 7. Per-L2 definitions

| L2 | Tanım ve dahil olan ana ürünler | Kesin dışarıda / başka ownership |
|---|---|---|
| Dizüstü Bilgisayar | Ekran, klavye ve bataryası tek taşınabilir bilgisayar gövdesinde olan laptop/notebook ve convertible laptop. | Tablet; laptop stand/cooling/accessory; gaming/use/OS/RAM capacity facetleri. |
| Masaüstü Bilgisayar | Hazır masaüstü sistem, all-in-one, mini PC, workstation ve barebone bilgisayar. | Boş kasa ve individual parts Bileşenler; monitor ayrı; server launch kapsamı owner decision. |
| Tablet | Dokunmatik ekranlı tablet bilgisayar; detachable keyboard aksesuar olduğunda cihaz yine Tablet'tir. | Grafik tablet bir input peripheral; e-reader ayrı; telefon Elektronik. |
| E-Kitap Okuyucu | Ana fonksiyonu elektronik metin/kitap okumak olan e-reader cihazı. | Digital e-book/service; tablet; device case/stand Bilgisayar Aksesuarları. |
| Monitör | Bilgisayar görüntü çıkışı için tasarlanan standart, gaming, professional veya portable monitor. | TV/projector/digital signage Elektronik; refresh rate ve panel technology facet. |
| Bilgisayar Bileşenleri | Bilgisayar sisteminin core compute/memory/power/enclosure/cooling parçaları ile Raspberry Pi ve genel amaçlı SBC ürünleri. | Persistent storage Veri Depolama; external peripheral; Arduino/ESP/generic electronic development board Elektronik → Elektronik Bileşenler. |
| Veri Depolama | Internal/external persistent storage, flash media, optical storage ve network storage. | RAM Bileşenler; cloud/digital storage service excluded; boş disk enclosure aksesuar olabilir. |
| Klavye, Mouse & Çevre Birimleri | Bilgisayarla aktif user input/output/communication kuran peripheral: keyboard, mouse, graphics tablet, webcam ve açık PC-primary headset/controller. | Monitor ve printer ayrı; general audio/camera Elektronik; hub/dock pasif destek olduğu için Aksesuarlar. |
| Bilgisayar Aksesuarları | Bilgisayarı/tableti destekleyen, bağlayan, koruyan veya ergonomisini artıran ikincil ürün: USB hub, dock, PC-specific adapter, stand, cooling pad, privacy filter, tablet stylus. | Laptop/tablet taşıma çantası Çanta & Aksesuar; active peripheral ayrı; general AV/power Electronics. |
| Yazıcı, Tarayıcı & Sarf Malzemeleri | 2D/3D/label/receipt printer, multi-function printer, scanner, device-specific consumables ve 3D filament. | Paper, label roll, notebook ve general office supply Kırtasiye & Ofis; projector Elektronik. |
| Ağ & İnternet Ürünleri | Modem, router, mesh, access point, repeater, switch, network adapter, network cable ve network-security appliance. | Smart-home hub/camera Elektronik; mobile phone/telephony Elektronik; USB hub Bilgisayar Aksesuarları. |

## 8. Inclusion/exclusion examples

| Ürün | Primary L2 / L1 önerisi | Neden |
|---|---|---|
| Gaming laptop | Dizüstü Bilgisayar | Gaming use-case/facet; cihaz formu laptop. |
| Gaming masaüstü hazır sistem | Masaüstü Bilgisayar | Gaming category ownership üretmez. |
| Gaming monitor | Monitör | Refresh rate/response/sync facet; ana ürün monitor. |
| Gaming keyboard/mouse | Klavye, Mouse & Çevre Birimleri | Aktif PC input peripheral. |
| PlayStation/Xbox/Nintendo console | Elektronik | Console, bilgisayar form faktörü değildir. |
| Console-primary controller | Elektronik | Ana platform console; PC compatibility ikincil olabilir. |
| PC-only joystick/gamepad | Klavye, Mouse & Çevre Birimleri | PC-primary input device. |
| Webcam | Klavye, Mouse & Çevre Birimleri | PC video-input peripheral. |
| IP security camera | Elektronik | Bağımsız camera/security cihazı. |
| USB PC headset | Klavye, Mouse & Çevre Birimleri | Açık PC-primary communication/output peripheral. |
| Bluetooth/TWS kulaklık | Elektronik | Genel audio ürünü; PC compatibility category değiştirmez. |
| USB hub / docking station | Bilgisayar Aksesuarları | PC port/iş akışı destek ürünü. |
| Ethernet network switch | Ağ & İnternet Ürünleri | Network topology cihazı; USB hub ile aynı işlevde değildir. |
| Internal SSD veya HDD | Veri Depolama | Persistent storage ana işlevi; Bileşenler'de tekrarlanmaz. |
| RAM | Bilgisayar Bileşenleri | Volatile system memory; storage medium değildir. |
| USB flash bellek / hafıza kartı | Veri Depolama | Ana işlev taşınabilir persistent storage; camera compatibility facet olabilir. |
| NAS | Veri Depolama | Network bağlantısı olsa da ana işlev storage. |
| Laptop çantası | Çanta & Aksesuar | Ana işlev taşıma/çanta; device compatibility facet/alias. |
| Laptop standı / cooling pad | Bilgisayar Aksesuarları | Bilgisayar ergonomisi/soğutma desteği. |
| Grafik tablet | Klavye, Mouse & Çevre Birimleri | Tablet bilgisayar değil, çizim input device. |
| E-kitap okuyucu | E-Kitap Okuyucu | Okuma cihazı; digital book içeriği değildir. |
| Lazer yazıcı / scanner | Yazıcı, Tarayıcı & Sarf Malzemeleri | Dijital baskı/tarama cihazı. |
| Toner / kartuş | Yazıcı, Tarayıcı & Sarf Malzemeleri — **FINAL** | Device-model compatibility baskın. |
| 3D printer / 3D filament | Yazıcı, Tarayıcı & Sarf Malzemeleri — **FINAL** | Cihaz ve device-specific print sarfı aynı L2; gelecek L3 ayrımı mümkündür. |
| Fotokopi kâğıdı / termal rulo | Kırtasiye & Ofis | Genel paper/office consumable; printer device part değildir. |
| Standalone mikrofon / PC hoparlörü | Elektronik | Canonical ana işlev audio capture/output; PC bağlantısı tek başına peripheral ownership üretmez. |
| Raspberry Pi / genel amaçlı SBC | Bilgisayar Bileşenleri | İşletim sistemi çalıştırabilen general-purpose single-board computer. |
| Arduino / ESP / generic development board | Elektronik → Elektronik Bileşenler | Ana işlev microcontroller/electronics development; consumer computer değildir. |
| Workstation | Masaüstü Bilgisayar | Masaüstü bilgisayar formu; profesyonel kullanım facet/attribute olabilir. |
| Rack server / enterprise-heavy ürün | Future L3/L4 policy/boundary review | Ayrı L2 yok; assignability ve kapsam daha sonra kararlaştırılır. |
| Bank/payment POS terminal | **TBD — merchant-equipment/policy review** | Consumer taxonomy'ye sessizce atanamaz ve bu fazda L2 oluşturmaz. |

## 9. Future L3/L4 examples

Aşağıdakiler **örnek expansion point**'tir; final tree, eksiksiz child listesi veya
assignable node kararı değildir. L2'nin leaf kalabildiği unutulmamalıdır.

| L2 | Olası gelecek L3/L4 örnekleri | Guard |
|---|---|---|
| Dizüstü Bilgisayar | Ölçülmüş şema farkı varsa convertible/2-in-1 veya mobile workstation | Gaming, OS, CPU, RAM ve ekran boyutu facet kalır. |
| Masaüstü Bilgisayar | Hazır sistem; all-in-one; mini PC; barebone | Gaming facet; server otomatik child değildir. |
| Tablet | Belirgin form/schema farkı kanıtlanırsa standard tablet; detachable/2-in-1 tablet | OS, ekran boyutu, hedef yaş ve cellular support facet. |
| E-Kitap Okuyucu | Gerekirse reader device leaf; başka child zorunlu değil | Marka veya ekran boyutuna göre node yok. |
| Monitör | Gerekirse standard/portable/professional form family | Gaming/refresh/panel/resolution facet. |
| Bilgisayar Bileşenleri | İşlemci; ekran kartı; anakart; RAM; güç kaynağı; kasa; soğutma; expansion card; SBC | CPU/GPU brand/model/socket/clock category yapılmaz; Arduino/ESP Elektronik'te kalır. |
| Veri Depolama | Dahili SSD/HDD; harici depolama; USB flash & memory card; optical drive; NAS | Capacity/interface/form factor facet; internal disk Bileşenler'e kopyalanmaz. |
| Klavye, Mouse & Çevre Birimleri | Klavye; mouse/trackball; graphics tablet; webcam; PC-primary headset; PC-primary controller | Gaming ve connection type facet. |
| Bilgisayar Aksesuarları | Hub & dock; stand & cooling pad; adapter & PC cable; stylus; screen/privacy protection | Active peripheral veya taşıma bag'i bu dala alınmaz. |
| Yazıcı, Tarayıcı & Sarf Malzemeleri | Yazıcı & multifunction; scanner; 3D printer; cartridge/toner/ink/ribbon/printhead; 3D filament | Paper/label/roll/notebook Kırtasiye & Ofis'te kalır. |
| Ağ & İnternet Ürünleri | Modem & router; mesh/AP/repeater; switch; network adapter; network cable; firewall appliance | Smart-home/telephony/camera ürünlerine genişlemez. |

## 10. Facet hints

Bu alanlar category değil, gelecekte typed attribute profile girdileridir.

| Kapsam | Önerilen facet hints |
|---|---|
| Dizüstü/Masaüstü/Tablet | CPU family/model, RAM capacity/type, storage capacity/type, GPU model, operating system, screen size, resolution, form factor, weight, battery, touch, cellular support |
| E-Kitap Okuyucu | screen size, display technology, lighting, storage capacity, supported formats, water resistance, connectivity |
| Monitör | screen size, resolution, refresh rate, response time, panel type, aspect ratio, curvature, HDR, sync support, ports |
| Bilgisayar Bileşenleri | component type, socket/chipset, memory type/capacity/speed, GPU chipset/VRAM, wattage/efficiency, case form factor, cooler compatibility |
| Veri Depolama | capacity, drive type, internal/external, interface, form factor, read/write speed, RPM, flash class, NAS bay count |
| Klavye/Mouse/Peripheral | device type, connection, keyboard layout/language, switch type, sensor/DPI, handedness, headset channels, webcam resolution/frame rate, platform compatibility |
| Bilgisayar Aksesuarları | accessory type, compatible device/model, port/input/output, power delivery, material, dimensions, mount type |
| Yazıcı/Tarayıcı/Sarf | device type, print technology, color/mono, duplex, multifunction, paper size, print speed, scan resolution, connectivity, cartridge/toner compatibility, yield |
| Ağ & İnternet | device type, Wi-Fi generation, frequency band, speed, port count/speed, PoE, mesh support, cellular standard, security capability |

Özellikle **RAM capacity, SSD capacity, CPU brand/family, GPU model, screen size,
refresh rate, operating system ve keyboard layout** L2 değildir. `Gaming`, `öğrenci`,
`iş`, `ofis`, `creator`, renk, fiyat, stok, mağaza uzaklığı ve marka da category
değildir.

## 11. Synonym hints

Synonym/alias yalnız discovery içindir; canonical ownership veya yeni node üretmez.
Marka adı synonym yapılmaz.

| Canonical L2 | Controlled synonym/search hints |
|---|---|
| Dizüstü Bilgisayar | laptop, notebook, taşınabilir bilgisayar |
| Masaüstü Bilgisayar | desktop, masaüstü PC, hazır sistem, kasa bilgisayar |
| Tablet | tablet bilgisayar, pad cihaz |
| E-Kitap Okuyucu | e-reader, elektronik kitap okuyucu, dijital kitap okuyucu |
| Monitör | bilgisayar ekranı, PC ekranı, monitor |
| Bilgisayar Bileşenleri | bilgisayar parçası, PC donanımı, sistem bileşeni |
| Veri Depolama | depolama birimi, veri saklama, disk, hard disk, flash bellek, yedekleme cihazı |
| Klavye, Mouse & Çevre Birimleri | keyboard, fare, giriş aygıtı, bilgisayar çevre birimi, PC peripheral |
| Bilgisayar Aksesuarları | PC aksesuarı, laptop aksesuarı, tablet aksesuarı, USB çoğaltıcı, dock, docking station |
| Yazıcı, Tarayıcı & Sarf Malzemeleri | printer, scanner, baskı cihazı, kartuş, toner |
| Ağ & İnternet Ürünleri | network ürünü, modem, router, yönlendirici, mesh, access point, Wi-Fi genişletici |

`Kasa bilgisayar` search hint'i hazır masaüstü sistemi ifade eder; tek başına boş
`bilgisayar kasası` Bileşenler'e gider. Benzer çok-anlamlı alias'larda exact product
title ve attribute context ile disambiguation gerekir.

## 12. Final owner decisions and remaining TBDs

### Confirmed — Product Owner Final

1. Exact 11 L2 adı ve sırası Section 6'daki haliyle finaldir.
2. Toner/kartuş ve diğer device-specific printer consumable, **Yazıcı, Tarayıcı &
   Sarf Malzemeleri** altındadır; general paper/notebook/office consumable **Kırtasiye
   & Ofis**'tedir.
3. 3D printer ve 3D filament aynı baskı L2'sindedir; yeni L2 yoktur.
4. Gaming cihaz/peripheral, kendi primary functional L2'sinde kalır. Console ve
   console-first controller **Elektronik → Oyun Konsolu & Aksesuarları** altındadır.
5. Webcam Bilgisayar & Tablet kapsamındadır; docking station/USB hub **Bilgisayar
   Aksesuarları** altındadır.
6. Raspberry Pi/genel amaçlı SBC **Bilgisayar Bileşenleri**; Arduino/ESP/generic
   electronics development board **Elektronik → Elektronik Bileşenler** altındadır.
7. Workstation **Masaüstü Bilgisayar** altındadır. Enterprise/server için yeni L2
   oluşturulmaz.

### Remaining TBD / deferred

- Rack server ve enterprise-heavy ürünlerin gelecek L3/L4 assignability, policy ve
  exact boundary'si ayrıca review edilecektir.
- Bank/payment POS terminal consumer taxonomy'ye sessizce atanmaz; merchant-equipment
  veya policy review tamamlanana kadar **TBD** kalır ve L2 oluşturmaz.
- Full L3/L4 tree, stable identity bridge ve eski dört-L2 tree için move/rename/
  successor mapping ayrı controlled taxonomy/integration işidir.

Tek taxonomy owner; final L2 kararını mevcut tree ile reconcile etmeli ve gerçek
L3/L4 ağacını controlled biçimde tasarlamalıdır. Bu owner-final belge tek başına
JSON/runtime'a uygulanmaz.

### Finalization acceptance checklist

- Canonical L1 **Bilgisayar & Tablet** değişmedi: **PASS**
- Final L2: **11**; exact name/order: **PASS**; duplicate L2: **0**
- Electronics leakage guard: **PASS**
- Gaming boundary: **PASS**
- Printer / Kırtasiye & Ofis boundary: **PASS — toner/kartuş resolved**
- 3D printer / filament boundary: **PASS — resolved**
- Raspberry Pi / Arduino separation: **PASS — resolved**
- POS: **TBD — intentionally unassigned**
- Brand-as-category: **0**
- Attribute-as-category: **0**
- Components micro-L2 inflation: **0**
- Future L3/L4 expansion feasibility: **PASS**
- Current taxonomy JSON/runtime/remote mutation: **NONE**

`COMPUTER_TABLET_L2_ARCHITECTURE: PASS`

`COMPUTER_TABLET_L2_OWNER_APPROVAL: FINAL`

`COMPUTER_TABLET_L2_COUNT: 11`

`ELECTRONICS_COMPUTER_BOUNDARY: PASS`

`READY_FOR_B2_INTEGRATION: YES`

`READY_FOR_L3_L4: NO`

`INTEGRATION_REQUIRED`
