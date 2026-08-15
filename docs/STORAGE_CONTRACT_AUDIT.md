# EsnaftaVar Storage Product + Security Contract Audit

## Amaç ve sınır

Bu doküman, `bd3b2cff244b922e6e9626d4634f5f39f85db76c` tabanındaki istemci ve
canonical migration kodundan çıkarılabilen Storage gereksinimlerini kaydeder.
Bir Storage implementation veya policy tasarımı değildir.

- Supabase'e bağlanılmadı ve remote durum değiştirilmedi.
- Bucket, Storage policy, migration veya SQL oluşturulmadı.
- Production'a erişilmedi.
- `CONFIRMED`, doğrudan mevcut kod veya canonical şemayla doğrulanan bilgidir.
- `OWNER DECISION REQUIRED`, implementation öncesinde ürün sahibinin
  kesinleştirmesi gereken bilgidir.

## Integration consistency note — 2026-08-15

Wave 5 final integration sırasında merged repoda bu auditin açık Storage owner
kararlarını kapatan daha yeni bir `FINAL` karar belgesi bulunmamıştır. Bu nedenle
belgedeki `CONFIRMED` bulgular source-of-truth olarak korunur;
`OWNER DECISION REQUIRED` maddeleri ise sessizce kesinleştirilmez ve bir sonraki
Storage implementation wave'inden önce kapanması gereken ürün kararları olarak
açık kalır. Bu audit bucket/policy implementation yetkisi vermez.

## Yönetici özeti

`SupabaseConfig` altı beklenen bucket adını tanımlar. Buna karşılık kaynak
taramasında bu adlardan yalnız `avatars`, doğrudan bir Supabase Storage API
çağrısına verilir. Bu avatar repository metotlarının aktif UI/use-case
çağırıcısı yoktur.

Ürün, kategori ve banner görsellerinin müşteri okuma yolları aktiftir. Ancak bu
yollar DB'de saklanan nihai metin URL'lerini doğrudan render eder; URL'nin bu
beklenen Supabase bucket'larından geldiğini doğrulamaz. Bu nedenle hiçbir
bucket için uçtan uca `ACTIVE` Storage bağlantısı doğrulanamamıştır.

Canonical migration zinciri özellikle bucket ve `storage.objects` policy'si
oluşturmaz. Mevcut istemci ayrıca signed URL üretmez, image picker kullanmaz,
görsel sıkıştırmaz/yeniden boyutlandırmaz ve yükleme öncesi MIME veya dosya
boyutu kontrolü yapmaz.

`pubspec.yaml` `image_picker` dependency'sini taşır; buna rağmen `lib/` ve
`test/` altında paketi import eden veya picker çağıran kod bulunmamıştır.

## Kaynak envanteri

### Bucket sabitleri

`lib/core/supabase/supabase_config.dart` içinde aşağıdaki altı sabit birebir
tutarlıdır:

- `product-images`
- `category-images`
- `brand-logos`
- `banner-images`
- `avatars`
- `review-images`

`supabase/migrations/20260812000700_0007_storage_realtime.sql` ve mevcut
canonical contract testi de aynı altı adı taşır. Avatar repository'si ise
merkezi `avatarsBucket` sabitini kullanmak yerine aynı değeri üç yerde
hardcode eder.

### Ortak Storage helper'ı

`lib/core/supabase/supabase_service.dart` dinamik bucket, dinamik path ve ham
byte kabul eden generic `uploadFile`, `getPublicUrl` ve `deleteFile` metotları
içerir. Feature kodunda bunları çağıran yer bulunmamıştır. Helper:

- path sahipliğini doğrulamaz,
- MIME parametresini opsiyonel bırakır,
- boyut kontrolü yapmaz,
- upload sonrası public URL döndürür.

Bu dormant helper herhangi bir rol için Storage yazma yetkisi kanıtı değildir.

## Bucket durum matrisi

| Bucket | Status | Readers | Writers | Ownership | Current path model |
|---|---|---|---|---|---|
| `product-images` | `PARTIAL` — görsel okuma aktif, bucket bağlantısı yok | `CONFIRMED`: anon ve authenticated discovery okuyucuları nihai URL'leri render eder | `CONFIRMED`: mevcut client uploader yok | `OWNER DECISION REQUIRED`: global `products` ile merchant-owned `shop_products` aynı medya alanına işaret edebilir | `CONFIRMED`: bucket path üretilmiyor; `products.thumbnail`, `products.images[]`, `shop_products.images[]` opaque metin taşır |
| `category-images` | `PARTIAL` — kategori görseli aktif, bucket bağlantısı yok | `CONFIRMED`: anon ve authenticated müşteri keşfi | `CONFIRMED`: mevcut client uploader yok | `CONFIRMED`: `categories` tablosunda kullanıcı/shop owner alanı yok; mevcut model global katalog içeriğidir | `CONFIRMED`: path üretilmiyor; `categories.image_url` nihai URL taşır |
| `brand-logos` | `FUTURE/SKELETON` | `CONFIRMED`: repository çağrılırsa anon/authenticated okuyabilir; aktif UI çağrısı yok | `CONFIRMED`: uploader yok | `CONFIRMED`: `brands` tablosunda owner alanı yok | `CONFIRMED`: path üretilmiyor; `brands.logo_url` opaque metin taşır |
| `banner-images` | `PARTIAL` — ana sayfa banner okuması aktif, bucket bağlantısı yok | `CONFIRMED`: anon ve authenticated ana sayfa okuyucuları | `CONFIRMED`: mevcut client uploader yok | `CONFIRMED`: `banners` tablosunda owner alanı yok | `CONFIRMED`: path üretilmiyor; `banners.image_url` nihai URL taşır |
| `avatars` | `PARTIAL` — repository upload/delete var, aktif caller/render yok | `CONFIRMED`: kendi profil verisini alan authenticated kullanıcı URL'yi modele yükler; aktif UI URL'yi render etmez | `CONFIRMED`: yalnız çağrılırsa authenticated current user repository akışı | `CONFIRMED`: filename current auth user ID'sini içerir; policy ile korunmuş object ownership mevcut değildir | `CONFIRMED`: bucket root'unda `avatar_<userId>.<client-extension>` |
| `review-images` | `FUTURE/SKELETON` | `CONFIRMED`: review satırları anon/authenticated okunur; mevcut UI `images` alanını render etmez | `CONFIRMED`: Storage uploader yok; repository yalnız kendisine verilen string listesini review satırına yazar | `CONFIRMED`: review row owner'ı `reviews.user_id`; object-path ilişkisi yok | `CONFIRMED`: path üretilmiyor; `reviews.images[]` opaque metin taşır |

`authenticated` Supabase rolü customer, merchant ve admin profil rollerinin
tamamını kapsar. Global katalog tablolarının mevcut canonical izinleri bu profil
rollerinden hiçbirine client-side create/update/delete hakkı vermez. Repoda
ayrı bir admin medya uploader'ı bulunmamıştır.

## Product decision matrix

| Bucket | Active? | Reader | Writer | Owner | Public/Private decision needed? | MIME decision | Size decision | Delete decision |
|---|---|---|---|---|---|---|---|---|
| `product-images` | `PARTIAL` — `CONFIRMED` aktif direct-URL read; bucket kaynağı doğrulanmıyor | `CONFIRMED`: anon + authenticated | `CONFIRMED`: none | `OWNER DECISION REQUIRED`: global product mı, shop listing mi? | `OWNER DECISION REQUIRED`: mevcut guest akışı public/direct URL ister; private seçim signed-URL client değişikliği gerektirir | `OWNER DECISION REQUIRED`; exact format allowlist yok | `OWNER DECISION REQUIRED`; limit yok | `OWNER DECISION REQUIRED`; mevcut client delete yok |
| `category-images` | `PARTIAL` | `CONFIRMED`: anon + authenticated | `CONFIRMED`: none | `CONFIRMED`: per-user owner yok; global katalog | `OWNER DECISION REQUIRED`: mevcut client yalnız direct URL destekler | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED`; client delete yok |
| `brand-logos` | `FUTURE/SKELETON` | `CONFIRMED`: dormant repository anon + authenticated read yapabilir | `CONFIRMED`: none | `CONFIRMED`: per-user owner yok; global katalog | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` |
| `banner-images` | `PARTIAL` | `CONFIRMED`: anon + authenticated | `CONFIRMED`: none | `CONFIRMED`: per-user owner yok; global içerik | `OWNER DECISION REQUIRED`: mevcut client yalnız direct URL destekler | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED`; client delete yok |
| `avatars` | `PARTIAL` | `CONFIRMED`: repository public URL üretir; aktif görsel reader yok | `CONFIRMED`: dormant authenticated self-upload | `CONFIRMED`: current auth user; mevcut filename user ID içerir | `OWNER DECISION REQUIRED`: repository public varsayar, avatar privacy kararı verilmemiştir | `OWNER DECISION REQUIRED`; `.jpg/.png` delete listesi MIME sözleşmesi değildir | `OWNER DECISION REQUIRED`; limit yok | `OWNER DECISION REQUIRED`: replace, explicit delete ve account-delete cleanup birlikte belirlenmeli |
| `review-images` | `FUTURE/SKELETON` | `CONFIRMED`: review data public-readable, fakat görseller render edilmez | `CONFIRMED`: uploader yok | `CONFIRMED`: row owner `reviews.user_id`; object owner/path yok | `OWNER DECISION REQUIRED`: public review görünürlüğü medya görünürlüğünü otomatik belirlemez | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED`: review/account silme davranışı tanımsız |

## Bucket bazında ayrıntılı kontrat

### `product-images`

- **Okuma — CONFIRMED:** Home, tüm ürünler, alt kategori, ürün detay,
  wishlist, yakın zamanda görüntülenenler, cart ve shop profile ürün
  görsellerini okur. Canonical `products` ve aktif `shop_products` satırları
  anon ile authenticated rollere açıktır.
- **Yükleme/update/delete — CONFIRMED:** Uygulamada product image Storage
  uploader, replace veya delete çağrısı yoktur. Merchant ürün/stok yönetimi de
  aktif ürün önceliği değildir.
- **Ownership — OWNER DECISION REQUIRED:** `products` global ve ownerless;
  `shop_products` ise `shops.owner_user_id` üzerinden merchant-owned'dır. Tek
  bucket içinde bu iki semantiğin nasıl ayrılacağı koddan çıkmaz.
- **Dosya türü — OWNER DECISION REQUIRED:** Test fixture'larında `.jpg`
  örnekleri görülür; runtime kodu exact MIME/extension allowlist tanımlamaz.
  Widget'lar HTTP(S) üzerinden decode edilebilir görsel bekler, bazı product
  widget'ları asset path fallback'ini de destekler.
- **Boyut/picker/işleme — CONFIRMED:** Boyut kontrolü, picker, compression veya
  resize yoktur.
- **Persist/URL — CONFIRMED:** Storage path değil nihai/opaque string,
  `products.thumbnail`, `products.images[]` ve `shop_products.images[]`
  kolonlarında tutulur. Signed URL üretilmez.

### `category-images`

- **Okuma — CONFIRMED:** Home category alanı `categories.image_url` değerini
  `CachedNetworkImage` ile gösterir. Kategoriler anon ve authenticated
  okunabilir.
- **Yükleme/update/delete — CONFIRMED:** Client tarafında hiçbiri yoktur.
- **Ownership — CONFIRMED:** Kategori satırında kullanıcı veya shop owner alanı
  yoktur; mevcut kontrat global katalog kaydıdır.
- **Dosya türü — OWNER DECISION REQUIRED:** Testlerde `.png` görülür; format
  kontrolü yoktur ve bu bir production allowlist değildir.
- **Boyut/picker/işleme — CONFIRMED:** Yoktur.
- **Persist/URL — CONFIRMED:** `categories.image_url` doğrudan render edilen
  nihai URL'dir. Storage path veya signed URL akışı yoktur.

### `brand-logos`

- **Okuma — FUTURE/SKELETON:** Brand model/repository/cubit `logo_url` taşır ve
  repository anon/authenticated-readable `brands` tablosunu sorgulayabilir.
  `BrandsCubit.getBrands()` çağrısı ve logo render eden aktif UI bulunmamıştır;
  product sorguları yalnız brand adını join eder.
- **Yükleme/update/delete — CONFIRMED:** Client tarafında yoktur.
- **Ownership — CONFIRMED:** Brand satırında owner alanı yoktur.
- **Dosya türü/boyut/picker/işleme — OWNER DECISION REQUIRED:** Kontrat yoktur.
- **Persist/URL — CONFIRMED:** Yalnız `brands.logo_url` opaque metni vardır;
  bucket path ve signed URL yoktur.

### `banner-images`

- **Okuma — CONFIRMED:** Ana sayfa aktif/tarih-aralığı geçerli banner'ların
  `image_url` değerini doğrudan render eder; DB okuması anon/authenticated'dır.
- **Yükleme/update/delete — CONFIRMED:** Client uploader veya mutation yoktur.
- **Ownership — CONFIRMED:** Banner satırında owner alanı yoktur.
- **Dosya türü — OWNER DECISION REQUIRED:** Testlerde `.png` örnekleri vardır;
  runtime allowlist yoktur.
- **Boyut/picker/işleme — CONFIRMED:** Yoktur.
- **Persist/URL — CONFIRMED:** `banners.image_url` nihai URL taşır; signed URL
  yoktur. Geçersiz/bozuk URL için UI fallback gösterir.

### `avatars`

- **Okuma — PARTIAL:** `profiles.avatar_url`, auth/review/chat modellerine
  alınabilir; ancak mevcut profil, review ve chat UI'ları bu URL'yi render
  etmez. Profil ekranı paketlenmiş asset kullanır.
- **Yükleme — PARTIAL:** `ProfileRepositoryImpl.uploadAvatar`, current user ID
  ile filename üretir, dosyanın tamamını belleğe alır ve `upsert: true` ile
  yükler. Bu metoda bağlı use-case/Cubit/UI/picker yoktur.
- **Update/replace — CONFIRMED:** Aynı extension kullanılırsa upsert replace
  eder. Extension değişirse önceki object temizlenmez.
- **Delete — PARTIAL:** DB URL önce null yapılır; sonra yalnız `.jpg` ve `.png`
  adları silinmeye çalışılır ve Storage hatası yutulur. Upload ise arbitrary
  extension kabul ettiğinden cleanup tam değildir.
- **Ownership/path — CONFIRMED:** Repository root seviyesinde
  `avatar_<currentUserId>.<extension>` üretir. Klasör temelli owner namespace'i
  ve Storage policy yoktur.
- **Dosya türü — OWNER DECISION REQUIRED:** Upload MIME kontrolü ve
  `contentType` vermez. `.jpg/.png` delete listesi allowed MIME kararı sayılamaz.
- **Boyut/picker/işleme — CONFIRMED:** Boyut kontrolü, picker, compression ve
  resize yoktur; bütün dosya `readAsBytes()` ile belleğe alınır.
- **Persist/URL — CONFIRMED:** `getPublicUrl()` sonucu `profiles.avatar_url`
  kolonuna yazılır. Storage path persist edilmez ve signed URL yoktur.
- **Hesap silme — CONFIRMED:** Customer account delete RPC'si auth/profile
  satırlarını siler fakat Storage object temizlemez; avatar object orphan
  kalabilir.

### `review-images`

- **Okuma — FUTURE/SKELETON:** Review repository/model `reviews.images[]`
  alanını taşır; aktif product reviews UI görselleri render etmez.
- **Yükleme — CONFIRMED:** Storage uploader/picker yoktur. Add/update review
  katmanı dışarıdan verilen string listesini doğrulamadan DB'ye aktarabilir.
- **Update/delete — CONFIRMED:** Review satırı kullanıcı ID'siyle update/delete
  edilir; buna bağlı Storage object cleanup yoktur.
- **Ownership — CONFIRMED/PARTIAL:** DB review owner'ı `reviews.user_id` ile
  kesindir. String URL ile object arasında doğrulanabilir path ilişkisi yoktur.
- **Dosya türü — OWNER DECISION REQUIRED:** Unit fixture'larında `.jpg`
  stringleri vardır; MIME sözleşmesi yoktur.
- **Boyut/picker/işleme — CONFIRMED:** Yoktur.
- **Persist/URL — CONFIRMED:** `reviews.images[]` opaque string listesi taşır;
  public URL, signed URL veya Storage path ayrımı uygulanmaz.

## Security threat review

| Risk | Koddan çıkan durum | Etkilenen alan | Sonuç |
|---|---|---|---|
| Başka kullanıcının object'ini overwrite/delete | Avatar repository kendi user ID'sini kullanır; ancak bunu zorlayan Storage policy yoktur ve generic helper arbitrary path kabul eder | Özellikle `avatars`; gelecekte review/product upload | Geniş authenticated policy kabul edilemez; owner namespace server-side doğrulanmalıdır |
| Path spoofing | Avatar dışında path builder yoktur; avatar extension sanitize edilmez | Tümü | Feature'a özel path kontratı olmadan writer açılmamalıdır |
| Shop ownership bypass | Global product ile merchant-owned shop product aynı beklenen bucket'a adaydır | `product-images` | Merchant write açılmadan önce object'in `shop_products.shop_id -> shops.owner_user_id` ilişkisi ve global catalog ayrımı kararlaştırılmalıdır |
| Arbitrary MIME / non-image upload | Avatar upload MIME vermiyor; generic helper MIME'ı opsiyonel alıyor; server limit yok | Tümü | Exact raster allowlist ürün kararı ve server-side enforcement gerektirir |
| Oversized upload / memory baskısı | Avatar bütün dosyayı limitsiz `readAsBytes()` ile belleğe alır | `avatars`; gelecekte tüm uploader'lar | Hem client preflight hem bucket-side size limiti gerekir |
| Public content hosting / enumeration | Aktif görseller direct URL ile okunur; avatar repository public URL üretir. List ihtiyacı yoktur | Read-active bucket'lar ve `avatars` | Public download seçilse bile object listing verilmemeli; tahmin edilebilir adlar ayrıca azaltılmalıdır |
| Predictable path | `avatar_<userId>.jpg/png/...` tahmin edilebilirdir | `avatars` | Public avatar kararı verilirse UUID'nin diğer public row'lardan öğrenilebilmesi dikkate alınmalıdır |
| Orphan object | DB kolonları ile Storage arasında FK/transaction yoktur | Tümü | Row update/delete ve failed DB update için cleanup/compensation stratejisi gerekir |
| Deleted-account object | Account delete Storage'a dokunmaz | `avatars`, gelecekte `review-images` | Retention veya cascade cleanup kararı zorunludur |
| Review ownership | Review row user-owned, object path ownerless'tır | `review-images` | Customer upload açılmadan önce user/review bağlı namespace ve cross-user testleri gerekir |
| Avatar privacy | Mevcut dormant kod public URL varsayar; aktif UI avatar göstermiyor | `avatars` | Public/private ve kimlerin avatarı göreceği ürün kararıdır |
| Arbitrary remote URL | DB media kolonları bucket path yerine opaque URL kabul eder | Ürün/kategori/banner/review/avatar kolonları | Trusted catalog ingestion veya URL doğrulama kararı olmadan bucket policy tek başına güven sağlamaz |

## Confirmed requirements

- Altı bucket adı kod, canonical migration notu ve contract testinde aynıdır.
- Mevcut guest discovery davranışı ürün, kategori ve banner görsellerini giriş
  yapmadan direct URL üzerinden okuyabilmelidir.
- Mevcut client'ta signed URL üretimi yoktur.
- Mevcut client'ta product/category/brand/banner/review Storage uploader'ı
  yoktur; bu rollere write verilmesi mevcut davranışın gereği değildir.
- Merchant ürün yönetimi aktif öncelik değildir; merchant'a şimdiden product
  image write verilmemelidir.
- Global catalog tablolarında client write yetkisi yoktur; katalog medya
  provisioning'i mevcut app rol modelinden çıkarılamaz.
- Avatar repository current authenticated user'ı filename'e dahil eder ve
  public URL persist eder; aktif UI entegrasyonu eksiktir.
- Exact MIME seti, boyut limiti ve retention/delete davranışı hiçbir bucket
  için kesinleşmemiştir.

## Owner decisions required

1. Product/category/banner direct guest read için Supabase bucket public mi
   olacak, yoksa istemci signed URL üretecek şekilde mi değişecek?
2. `product-images`, global katalog ürünlerini ve merchant `shop_products`
   görsellerini birlikte mi taşıyacak; ayrı namespace veya ayrı bucket gerekir
   mi?
3. Global katalog medyasını hangi trusted actor/workflow yükleyecek? Mevcut
   client'ta admin uploader ve catalog write yetkisi yoktur.
4. Her bucket için exact MIME allowlist ve maksimum object boyutu nedir?
5. Avatarlar public mi, private mı; kimlerin avatarını kim görebilir?
6. Avatar upload/edit/delete UI'sı gerçekten ürün kapsamına alınacak mı?
7. Review image upload ve görüntüleme ürün kapsamına alınacak mı; anon review
   okuması görselleri de public yapmalı mı?
8. Replace sırasında eski object, review silindiğinde review object'leri ve
   hesap silindiğinde avatar/review object'leri hemen mi silinecek, süreli mi
   tutulacak?
9. Opaque external media URL'leri desteklenmeye devam edecek mi, yoksa DB
   yalnız controlled Storage path/URL mi taşıyacak?

## Least-privilege recommendations

### Şimdi uygulanabilecek kontrat sonucu

- Hiçbir client rolüne bucket-wide write/update/delete verilmemelidir.
- `category-images` ve `banner-images` için mevcut davranış yalnız read'dir;
  owner kararından sonra trusted provisioning + anon/auth read dışında izin
  gerekmemektedir.
- `product-images` için merchant write, global product/shop product ownership
  ayrımı yapılana ve merchant ürün yönetimi aktif kapsam olana kadar kapalı
  kalmalıdır.
- `brand-logos` ve `review-images` bucket'ları yalnız gelecek ihtimaline göre
  açılmamalıdır.
- `avatars`, aktif UI ve privacy kararı tamamlanmadan production-ready kabul
  edilmemelidir.
- Generic Storage helper doğrudan feature kontratı yerine kullanılmamalı;
  feature katmanı bucket, path, MIME, boyut ve owner kurallarını sabitlemelidir.

### Karar sonrası önerilen dar modeller

- **Global read-only media:** Public/direct-read kararı onaylanırsa anon ve
  authenticated download korunabilir; list, insert, update ve delete client'a
  verilmez. Provisioning trusted backend/operasyon yoluyla yapılır.
- **Avatar:** Önerilen object namespace'inin ilk segmenti `auth.uid()` olmalı;
  insert/update/delete yalnız aynı namespace için çalışmalı. DB profil ID'si de
  aynı kullanıcı olmalıdır. Public/private kararı bu owner kuralından ayrıdır.
- **Review image:** Feature açılırsa namespace hem authenticated user'ı hem
  review ID'sini taşımalı; review owner'ı `reviews.user_id` üzerinden
  doğrulanmalıdır. Başka kullanıcının review object'ine update/delete kapalı
  olmalıdır.
- **Merchant listing image:** Feature daha sonra açılırsa yetki, object'in
  bağlı olduğu `shop_products.shop_id` üzerinden `shops.owner_user_id` ile
  doğrulanmalıdır. Global `products` nesnelerine aynı izin genişletilmemelidir.
- MIME ve boyut kısıtları yalnız client doğrulamasına bırakılmamalı; bucket
  metadata/policy ve negatif integration testleriyle zorlanmalıdır.

## Sonraki Storage wave'i için implementation planı

1. **Zorunlu ürün kararlarını kapat:** Public/private, trusted writer,
   product-vs-shop ownership, exact MIME, size ve delete/retention kararları.
2. **Read-only aktif medya kontratını seç:** Önce owner semantiği basit olan
   `category-images` ve `banner-images`; sonra global/shop ayrımı çözülen
   `product-images`. DB'de final URL mi Storage path mi tutulacağı sabitlenmeli.
3. **Development-only migration ve contract testleri hazırla:** Tek SQL sahibi;
   bucket görünürlüğü, client write yokluğu, list yokluğu, MIME/size sınırları
   ve tekrar uygulanabilirlik test edilmeli. Production ayrı release gate'tir.
4. **Avatarı ayrı wave olarak ele al:** Privacy kararı, aktif picker/use-case/UI,
   client boyut/type preflight'i, owner namespace, replace cleanup ve account
   delete cleanup birlikte tamamlanmalı.
5. **Review images'i ürün özelliği aktif olunca ele al:** Customer ownership,
   review visibility, görüntüleme UI'sı ve row/object cleanup birlikte test
   edilmeden bucket açılmamalı.
6. **Brand logos'u en sona bırak:** Aktif UI/use-case ihtiyacı oluşmadan bucket
   veya policy oluşturulmamalı.

### Gerekli test matrisi

- Bucket adları ve visibility contract testi.
- Anon/authenticated download davranışı; private seçilirse signed URL süresi ve
  yetkisiz download reddi.
- Read-only bucket'larda anon/authenticated insert/update/delete ve list reddi.
- Owner bucket'larda kendi object'i success; başka user path'i, spoofed path ve
  cross-shop path reddi.
- Yanlış MIME, extension/MIME uyuşmazlığı, executable/non-image ve limit üstü
  object reddi.
- Aynı path replace yarışı ve stale URL/cache davranışı.
- DB update başarısızlığında orphan cleanup; row/review/account delete sonrası
  retention/cleanup davranışı.
- Public URL veya signed URL'nin DB'de seçilen path/URL persistence kontratıyla
  tutarlılığı.

## Implementation readiness

Storage implementation hazır değildir. Read-only active media için dahi
public/private ve trusted provisioning kararları; avatar/review için ayrıca
privacy, ownership, MIME, size ve delete kararları kapatılmalıdır.
