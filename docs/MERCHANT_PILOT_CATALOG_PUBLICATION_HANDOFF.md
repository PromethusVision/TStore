# J7 — Kontrollü katalog yayını ve eski fiyat uyumu

Başlangıç: `origin/main@465d88422025dda652bef1e1341cb1632c391630` (J6 entegre).
Görev dalı: `agent/merchant-pilot-catalog-publication`.
Durum: yerel uygulama ve prova; **uzak kurulum/yayın yapılmadı**.

## Kullanıcıya etkisi

Yeni ürünün kimliği, barkodu ve kategorisi kontrollü olarak onaylanabilir. Esnaf
sonrasında mevcut ekrandan ürünü kendi dükkânına ekler ve kendi fiyatını belirler.
Onay işlemi satış kaydı açmaz, fiyat/indirim/stok uydurmaz. Barkod çakışması,
başka esnafa ait özel ürün veya geçersiz yetki bütün paketi geri alır.

Veritabanındaki zorunlu eski fiyat alanı korunur. Yeni ürünlerdeki `0`, açıkça
işaretlenmiş teknik yer tutucudur; uygulama bunu ücretsiz ürün diye göstermez.
Satıcı fiyatı bulunmayan eski kart alanında “Esnaf fiyatını gör” yazılır. Etiketli
ürüne merkezî indirim de gösterilmez. Önceden bulunan etiketsiz ürünlerin fiyat,
stok ve ekran davranışı değiştirilmez. Ekran düzenleri ve gezinme korunur.

## Test projesi için ayrıca onay bekleyen somut kapsam

Hedef yalnız **EsnaftaVar Development — `tnipyxnvhgelwdpykyez`**.
Bu görevde bu projeye okuma veya yazma erişimi yapılmadı. Son bilinen C/E kurulum
kaydı başlangıç girdisidir; güncel uzak durum iddiası değildir.

1. **Altyapı kurulumu:** bir özel yayın kayıt tablosu, üç istemcilere kapalı
   yardımcı işlev, iki koruma tetikleyicisi ve bir kurulum kaydı (`20261018003300`,
   `0033_pilot_catalog_publication`). Mevcut ürünler/fiyatlar, hesaplar, kategoriler,
   bildirimler, Storage ve A/C/E ayarları değiştirilmez. Genel onay anahtarı kapalı
   kalır. Tek işlem başarısız olursa tüm kurulum geri alınır. Önce Integration PASS,
   ayrı Product Owner onayı, doğru hedef ve taze başlangıç kontrolü gerekir.
2. **Gerçek ürün yayını:** henüz hazır değildir. Gerçek fiziksel ürün başvuruları,
   seçilmiş kimlik/marka/barkodlar, uygun kategoriler ve hesaplar belli olunca,
   uyumlu iki uygulama sürümü incelenip **tam satır listesiyle yeni onay** alınır.
   Altyapı onayı bu ikinci işleme izin vermez. Hizmet/randevu ürünleri eklenmez.

Kaynak: `supabase/proposals/pilot_catalog_publication_v1.sql`. Otomatik migration
dizinine eklenmedi; `db push` kullanılmaz, geçmiş migration dosyaları değişmez.
Kurulum yalnız kaynak ve başlangıç doğrulaması bulunan `schema.review.sql`
üzerinden ayrı yetkiyle ele alınır. İnceleme belirteci izin ya da hedef kimliği
kanıtı değildir; araç bu belirteci kendisi ayarlamaz ve uzak bağlantı kurmaz.

## Sözleşme ve güvenlik sınırları

- `products` UUID'si ve zorunlu eski sütunlar korunur. Yeni kimlikte
  `attributes._catalog_price_contract=listing_only_v1`, `price=0`,
  `sale_price=NULL`, `stock=0`. Tetikleyici etiketin kaldırılmasını ve bu alanların
  satış fiyatı/stok gibi kullanılmasını reddeder. Bu bir minimum satış fiyatı kuralı
  değildir; mevcut `shop_products.price` sözleşmesi aynen sürer.
- ProductModel etiketi mevcut JSON/önbellek yollarında taşır. Etiketi tanımayan
  eski istemciler güvenli kabul edilmez. İlk yayından önce uyumlu Customer/Merchant
  sürüm çifti şarttır; derleme başarısı mağaza dağıtımı veya cihaz kabulü değildir.
- Yeni yardımcı işlev SECURITY INVOKER'dır; PUBLIC/anon/authenticated/service_role
  çağrı yetkileri kapalıdır. Özel kayıt tablosunda RLS ve tam istemci yetki iptali
  vardır. Genel `decide_catalog_submission_v1`/`decisions_enabled` yolu açılmaz.
- Operatör, mevcut `product_submissions` satırlarını seçer. Mevcut kimliği kullanma
  veya yeni kimlik yaratma ve marka UUID'si açık seçimdir. Tam GTIN normalizasyonu,
  aynı kimlikte marka/model/varyant/kategori/tip ve özel ürünün sahibi korunur.
  Benzer isim veya barkodsuz eşleşme otomatik birleşim izni vermez.
- Şema/katalog/taksonomi ve seçilmiş başvuru/yetki durumu işlem içinde tekrar
  kontrol edilir. Seçilmiş Auth satırları da kilitlenir. Tekrarlı paket durumu
  kayıt üzerinden salt okunur sorgulanır; onay yanıtı kaybolunca yeni ürün açılmaz.
- Kayıtlar ve kararlar birlikte oluşur; paket satış listesi, medya veya hesap
  oluşturmaz. Satıcı fiyatları ve geçmiş satın alma tutarları merkezî sıfırdan
  bağımsızdır. SQL metnindeki özel tırnak/dolar işaretleri veri olarak kalır.
- Production canonical tabloları varsa aday kurulmaz/çalışmaz. Üretimdeki
  0012–0015 atama/yayın akışının yerine geçmez. Üretim için yeni inceleme gerekir.
- İşlem sonrası geri dönüş otomatik silme değildir. Yayını/dağıtımı durdur,
  salt okunur kayıtla sonucu doğrula; gerekiyorsa ilgili kimliği pasife alma gibi
  ayrı bir ileri düzeltme öner. Ürün/başvuru/karar/satın alma geçmişini silme.

## Yerel doğrulama

`docs/data/merchant_pilot_publication_acceptance.json` kaynak parmak izlerini ve
izole servis kanıtını taşır. Örnek hesaplar ve ürünler yalnız yerel provaya aittir.

- **29 PostgreSQL/gerçek yerel servis grubu PASS**, ayrıca **18 gerçek Flutter
  repository kontrol noktası PASS**. Kurulum geri alma/tekrar, yetki sapması,
  Auth yarışı, barkod/marka/benzerlik, tüm paket geri alma, özel ürün sahipliği,
  salt okunur sonuç kurtarma, eski ürünün fiyatını koruma ve fiyat/medya/satın alma
  yolu doğrulandı. Fiziksel iki cihazlı QR kabulü yapılmış sayılmaz.
- **2.970 Flutter testi PASS / 0 FAIL / mevcut 6 SKIP**. Bunun içinde yeni 9 DTO
  ve widget kontrolü: dört fiyat yüzeyi, liste fiyatı/hata etiketi önceliği,
  bilinmeyen etiketin güvenli davranışı, dar ekran/büyük yazı ve gezinme.
- `flutter analyze --no-pub`: **PASS**, sorun yok.
- **88 Node hazırlık/güvenlik testi PASS / 0 FAIL** (önceki 70 + yeni 18).
  Son raporlama düzeltmesinden sonra yeni 18 test tekrar PASS.
- **Customer `development` debug APK PASS**, **Merchant `merchantDevelopment`
  debug APK PASS**. Gizli yapılandırma eklenmedi. Customer derlemesinde Windows
  C:/E: Kotlin artımlı önbellek uyarısı oluştu; derleme başarıyla tamamlandı ve
  dosya üretildi. Paketler pilot dağıtım veya cihaz kabulü kanıtı değildir.
- Son diff/secret taraması PASS; geçmiş migration, dependency, routing, bootstrap,
  global config ve Production dosyaları değişmedi. Ortak değişiklikler ProductEntity
  ve dört fiyat yüzeyidir; canonical/slices belgeleri ve aday şema ayrıca incelenmeli.

Başlangıç şeması MD5: `78f248b24aa67f7befcc7ccdb9ec97bd`.
Yerelde kurulmuş aday şema MD5: `590f31a8d4e3485d6b23434e17bd9d40`.
Bu değerler izin değildir; hedef ve taze gözlem kontrolünün yerine geçmez.

Kurulum planı SHA-256:
`8282368cb50babbb726545dd4603aca146e25bfabe047f0ec62bc05d6ce46e5c`.
Öneri kaynak SHA-256 (LF):
`f3f2ed01ee2222c6835bfc296a41eb090972372cd3d30e2837c5e0cd8dded182`.
Yerel kanıt 53 kaynak dosyasını bağlar; eski kanıt dosyaları değiştirilmedi.

## Yeniden üretme ve sonraki hazırlık

```text
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run>
node tool/merchant_acceptance/pilot_publication.mjs <same-run> <Flutter-SDK-directory>
node tool/merchant_acceptance/local.mjs stop <same-run>
node --test tool/merchant_acceptance/*.test.mjs
node tool/merchant_acceptance/prepare_pilot_publication.mjs <new-review-name>
node tool/merchant_acceptance/prepare_pilot_publication_cohort.mjs <new-cohort-review-name>
```

Yerel runner yalnız 127.0.0.1 üzerinde yeni görev etiketli servisleri kabul eder.
A/C/E kaynakları bu **yeni yerel** provayı kurmak için kullanılır; uzakta tekrarlanmaz.
Eski deneme verileri silinmez. Hazırlama araçlarında bağlantı/uygula seçeneği yoktur.

Varsayılan yayın dosyası `.buildlog/pilot-publication-review/<name>` altında şema
inceleme adayı, kurulum sonrası salt okunur doğrulama, boş başvuru formu ve gözlem
sorgusu üretir. Gerçek ürün satırları yokken yayın SQL'i üretilmez. Dolu özel girdi
`.buildlog/pilot-publication-input/<name>.json` ve aynı adlı `.observation.json`
dosyasıdır; CLI yalnız düz isim alır. Özel gerçek kimlikleri Git'e koyma.

Kurulum öncesi J6 kategori/hesap aracı kullanılmaya devam eder. Kurulum sonrasında
`prepare_pilot_publication_cohort.mjs` yalnız kanıtlanmış yeni şemaya uyarlanmış J6
kontrollerini kullanır. Özel girdiler `.buildlog/pilot-publication-cohort-input`
altında `<name>.json`, `<name>.observation.json`, `<name>.taxonomy.json` olarak
tutulur. Eksik kimlikler rol değişikliği üretmez; kategoriler ve roller ayrı onay
gerektirir. Eski kanıtı veya başlangıç kontrollerini elle değiştirme.

Araç sınırları: en çok 100 başvuru, gözlemde 500 ürün/500 marka. Bunlar güvenli
inceleme sınırlarıdır, ürünün ticari kapasite sınırı değildir. Daha büyük katalog
ayrı gözlem paketi gerektirir. Mevcut J6 ilk kategori açılışı sınırları korunur.

Son yerel inceleme klasörleri:
`.buildlog/pilot-publication-review/esenler-catalog-publication-final` ve
`.buildlog/pilot-publication-cohort-review/esenler-post-publication-cohort-final`.
Seçilmiş gerçek içerik bulunmadığından ilkinde yayın SQL'i, ikincisinde kategori
veya rol değiştirme SQL'i yoktur. İzin verilmeden hiçbir dosya uzakta çalıştırılmaz.

Integration yalnız dalı inceler/birleştirir; test sunucusuna kurulumu veya gerçek
ürün yayınını yapmaz. Gerçek esnaf seçimi, e-posta/cihaz bağlantıları, bildirim
sağlayıcısı, fiziksel QR, imzalı dağıtım ve pilot açılışı ayrı kabul kapılarıdır.
