# Trust & Commerce V1 — Slice A teslimi

Taban: `68a47e2b6253517ee9071e0a393e6c831b9a9304`.
Dal: `agent/catalog-listing-media-v1`. Main birleştirmesi Integration Agent'a aittir.
Bu çalışma Production veya Development cloud Supabase'e bağlanmadı; remote
migration, canlı veri yazımı ve provider yapılandırması yapılmadı.

## Kapsam ve ekranlar

- Mevcut Ürünler → katalogdan seçim → mağaza fiyatı/bulunabilirliği akışı korunur.
  Slice A kurulu backend'de arama, aynı canonical yayın kapısına bağlıdır.
  Yalnız eksik RPC eski okuma sözleşmesine döner; yetki/ağ hatası dönmez.
- Katalogda “Ürünü bulamadın mı?” → “Yeni ürün ekle”: ad, isteğe bağlı
  marka/model/varyant/GTIN, açık ve atanabilir canonical kategori, mağazaya özel
  ürün seçimi. Benzer sonuç kullanıcı seçimi gerektirir. Kesin GTIN eşleşmesi
  mevcut ürüne yönlendirir. Barkodla katalog araması aynı eşleşmeyi kullanır.
- Ürün başvurularım: İnceleniyor / Onaylandı / Reddedildi ve karar gerekçesi.
  Onaylanmış mevcut kimlik için mağaza fiyatı ve bulunabilirliği sonradan eklenir.
- Mevcut mağaza ürününü düzenle → Mağaza fotoğraflarını yönet: ekleme,
  ana fotoğraf seçimi, sıralama, mantıksal kaldırma, yarım yüklemeyi tamamlama/temizleme.
- Customer Product Details: satıcı listesinin **aynı** sıralanmış sonucu başlığı
  besler. Fiyat, mesafe, konum, bulunabilirlik, filtre/radius değişimleri ile
  birlikte güncellenir. Yeni filtre kontrolü veya reklam sistemi eklenmedi;
  mevcut listeye uygulanabilen filtre/radius parametreleri ortak sonuca bağlandı.
  Fotoğraf yüklenince “Fotoğraf: {mağaza}” gösterilir. Küçük galeri/galeri sayısı
  gerçekten gösterilen mağazanın fotoğraflarından gelir.

Merchant V1 repository arayüzü korunur; başvuru/medya işlemleri ayrı capability
portu `CatalogMediaRepository` ile aynı composition root'a eklenir. Customer
locator'ındaki tek yeni bağlama `ListingHeroMediaRepository` olur. Ortak push,
auth, Cart V2 ve QR mimarisi değiştirilmez.

## Backend adayı

Yeni dosya: `supabase/migrations/20261013001600_0016_catalog_listing_media.sql`.
0016 engagement proposal'ı migration numarası ayırmaz. 0012/0013/0014/0015,
engagement proposal'ı ve Phase 1'deki 43 tablo prototipi değiştirilmedi.

Altı ek tablo: `catalog_media_config`, `product_identity`,
`product_identifiers`, `product_submissions`, `product_submission_decisions`,
`listing_images`. `products` ve `shop_products` kimlikleri, legacy fiyat/stok/
görsel alanları ve geçmiş işlem kayıtları korunur. Identity backfill mevcut
ürünleri shared olarak işaretler; normalized ad/marka ve normalization_version=1
tutar. Unique kimlikte origin shop zorunludur; başka mağaza listeleyemez.

RPC envanteri:

| RPC | Yetki / işlev |
| --- | --- |
| `merchant_catalog_categories_v1` | Yetkili mağaza; yalnız yayına açık atanabilir yapraklar |
| `merchant_catalog_search_v1` | Yetkili mağaza; yayın kapısı, unique sahipliği ve sayfalama |
| `merchant_catalog_lookup_v1` | Kesin GTIN veya açıkça öneri niteliğinde ad araması |
| `merchant_submit_product_v1` | Mağaza/hesap sunucuda doğrulanır; idempotent pending başvuru |
| `decide_catalog_submission_v1` | Yalnız service_role; varsayılan kapalı operator sınırı |
| `merchant_listing_media_v1` | Sahiplik ve sunucu limitleri ile özel medya envanteri |
| `merchant_prepare_listing_image_v1` | Kilitli/bounded yükleme niyeti; sunucunun ürettiği yol |
| `merchant_change_listing_images_v1` | Publish / primary / reorder / retire; atomik işlem |
| `catalog_listing_media_read_v1` | Yalnız uygun listing ve doğrulanmış yayımlanmış görseller |

GTIN 8/12/13/14 basamaklı, rakamlardan oluşan ve kontrol basamağı geçerli
değerlerden 14 basamağa normalize edilir; tümü sıfır değeri reddedilir. Tekil
identifier anahtarı, GTIN transaction kilidi ve başvuru idempotency anahtarı
tekrarlı istekleri sınırlar. Benzerlik otomatik birleştirme yapmaz.

**Yeni canonical ürün materialization'ı kapalıdır.** Sahte merkezi fiyat
oluşturulmaz. Karar seam'i yalnız zaten meşru biçimde oluşturulmuş, category/
identity eşleşmesi doğrulanan ürünün kimliğini bağlayabilir; bu seam dahi
`decisions_enabled=false` ile kapalı gelir. Admin slice; yeni ürün oluşturma için
legacy NOT NULL price uyumluluk sözleşmesini, kimlik bakımı ve operatör yetkisini
tamamlamadan bu kapıyı açmamalıdır. Multiple private adaylar canonical ürün
oluşturmaz; ortak GTIN yalnız tek canonical kimliğe bağlanabilir.

## Storage ve güvenlik

Mevcut `product-images` public bucket ve legacy kaynak çözümleyici korunur.
Taslak/kaldırılmış dosyaların public URL ile açılmasını önlemek için aynı
kontrollü yol geleneğini kullanan **özel** `listing-media` bucket eklenir:
`shops/{shop_id}/{listing_id}/vYYYYMMDDHHMMSS/{image_uuid}.{extension}`.
Public bucket indirmelerinin RLS'den farklı davranması ve private bucket
kuralları [Supabase Storage sözleşmesinde](https://supabase.com/docs/guides/storage/buckets/fundamentals)
açıklanır.

Sunucunun konservatif varsayılanı listing başına 6 aktif/yarım fotoğraf,
dosya başına 8 MiB ve JPEG/PNG/WebP'dir. Flutter sayıyı RPC'den alır. Storage
izin ön kontrolü, henüz kesin boyutu olmayan metadata'yı kabul edebilir;
publish ve public okuma ise tamamlanmış dosyanın MIME/boyut eşleşmesini şart
koşar. Bu ayrım [Storage uploader kaynak akışı](https://github.com/supabase/storage/blob/master/src/storage/uploader.ts)
ile doğrulandı ve ephemeral testte iki probe biçimi de sınandı.

Tüm yeni yazmalar authenticated merchant ve tam mağaza/listing sahipliğini
sunucuda kontrol eder. Yeni listing ve medya yayını canonical yayın kapısından
geçer. Yeni tablolar için client INSERT/UPDATE/DELETE verilmez; kararlar append
only'dir. SECURITY DEFINER fonksiyonları sabit search_path ve açık revoke/grant
kullanır. Başka shop, client approval forgery, unsafe MIME/yol ve object overwrite
reddedilir. Pending/rejected başvurular ve pending/retired fotoğraflar private kalır.
Listing'in shop/product bağları değiştirilemez; mevcut fiyat, açıklama,
bulunabilirlik ve pasife alma/güncelleme davranışı korunur.

Yükleme niyeti listing satırıyla kilitlenir. Birden çok published primary'yi
partial unique index engeller. Primary switch tek transaction'dır. Sıralama
tam ve benzersiz ID listesiyle yapılır; sort_order/id sırası sabittir. Retire
dosyayı silmez. İlk kez yayımlanmamış/başarısız upload legacy fotoğrafı gizlemez;
bir kez yeni medya sözleşmesine geçmiş listing, tüm görseller kaldırılınca eski
legacy görselleri geri getirmez. Fiziksel purge/retention politikası ayrı iştir.

## Dynamic hero

Eski karşılaştırıcı kuralları `SellerRanking` içine taşındı; eşitliklerde giriş
sırası korunur. organicRank=displayRank; sponsor/ad eklemesi yoktur. Hero ayrıca
sıralama yapmaz. Birinci listing'in primary fotoğrafı → aynı listing'in diğer
geçerli fotoğrafları → sonraki görünen listing → mevcut placeholder zinciri
kullanılır. Dosya imzalama ve resim decode hataları da bu zinciri izler.

Metadata ve imzalama istekleri bounded batch kullanır. Signed URL saklanmaz/
loglanmaz; ömrü 300 saniyedir. Daha önce verilmiş URL/cihaz görüntü önbelleği
anında geri alınamaz; fresh okumalar retired/invalid görseli dışlar. Eski response,
eski location sonucu veya eski görüntü callback'i yeni seçimi ezemez.

## Doğrulama ve tekrar çalıştırma

- Hedefli Merchant/hero/satıcı kontrolleri: 102 PASS.
- Migration sözleşmesi + Product Details golden kontrolleri: 41 PASS.
- Tüm Flutter testleri: 2316 PASS, mevcut 6 skip.
- `flutter analyze --no-pub`: sıfır sorun.
- Ephemeral PostgreSQL 18.3 / PGlite 0.5.5: 26 güvenlik/davranış kontrolü PASS.
  0001..0011 gerçekten çalıştırılır; Production category dalında 0012'nin
  değişmemiş yayın/qualification fonksiyonları sentetik tablolarla kullanılır.
  Production snapshot'ı veya publication executor çalıştırılmaz.
- Concurrent RPC çağrıları ve unique/lock davranışı test edilir. PGlite tek engine
  olarak komutları sıraya alır; bağımsız gerçek PostgreSQL session yük/stress
  kabulü veya gerçek Supabase Storage HTTP E2E başarısı iddia edilmez.
- Eski golden referansları değişmez; yeni Product Details referansları
  `test/widget/shop/goldens/slice_a_*` altında tutulur ve görsel olarak incelendi.

Reproducible yerel kontroller:

```text
flutter test --no-pub test/unit/merchant test/unit/shop/listing_hero_test.dart test/widget/merchant test/widget/shop/listing_product_hero_test.dart test/widget/shop/product_sellers_section_test.dart
flutter analyze --no-pub
flutter test --no-pub
npm install --ignore-scripts --no-audit --no-fund --prefix .buildlog/catalog-sql @electric-sql/pglite@0.5.5
node tool/catalog_media/schema.test.mjs .buildlog/catalog-sql/node_modules/@electric-sql/pglite
```

Customer `development` / `main_development.dart` ve Merchant
`merchantDevelopment` / `main_merchant_development.dart` debug APK derlemeleri
yerel loopback adresi ve gerçek credential olmayan test değeriyle yapılır.
İki derleme de PASS; package kimlikleri sırasıyla `com.esnaftavar.app.dev` ve
`com.esnaftavar.app.merchant.dev` olarak APK metadata'sından doğrulandı.
Customer derlemesinde mevcut Windows Kotlin incremental-cache fallback çıktısı
görüldü; build başarıyla tamamlandı. Global Gradle ayarı değiştirilmedi.
Bu paketler compile doğrulamasıdır; test değeri gerçek backend'e giriş sağlamaz.
Yerel tam Supabase ortamında çalıştırmak için o ortamın açık client anahtarı
gereklidir. Release signing/publishing veya Production anahtarı kullanılmaz.

Sonraki kabul: gerçek cihazda galeri seçimi ve tam yerel Supabase Storage
upload/publish/read akışı. Remote apply, Admin aktivasyonu ve main merge ayrı
yetki/görevlerdir. İki cihazlı fiziksel QR kabulü, reviews/ratings/badges,
reward/trust/ads ve Firebase/APNs aktivasyonu Slice A kapsamında değildir.
