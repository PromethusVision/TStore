# Product Review Eligibility ve Legacy Order Dependency Audit

## Kapsam ve sonuç özeti

Bu audit `bd3b2cff244b922e6e9626d4634f5f39f85db76c` canonical baseline'ında
yapılmıştır. Ürün davranışı, veritabanı şeması, migration zinciri ve legacy
dosyalar değiştirilmemiştir.

En önemli bulgu şudur: mevcut legacy satın alma sorgusu ürün yorumu göndermeyi
engelleyen bir eligibility kapısı değildir. `ReviewRepositoryImpl.addReview`,
oturum ve aynı ürün için mükerrer yorum kontrolünden sonra yorumu her durumda
eklemeye çalışır. Legacy `delivered orders/order_items` sorgusunun sonucu yalnız
`reviews.is_verified_purchase` alanına yazılır. Sorgu hata verirse sonuç `false`
olur ve yorum ekleme devam eder.

Dolayısıyla `orders/order_items` bugün "yorum yazma yetkisi" için değil,
doğrulanmış satın alma etiketi üretmeye çalışan, istemci taraflı ve güvenilirliği
sınırlı bir kontrol için kullanılmaktadır. Tablolar ayrıca müşteri hesabı silme
RPC'sinde doğrudan referanslandığı için yalnız review bağı nedeniyle tutulmuyor.

## A. Product review

### Aktif kaynak ve çağrı zinciri

- Repository: `ReviewRepositoryImpl`.
- Gönderme zinciri: `AddReviewUsecase` -> `ReviewsCubit.addReview` ->
  `ReviewRepositoryImpl.addReview`.
- DI: repository, use-case ve Cubit aktif `service_locator.dart` içinde kayıtlıdır.
- Görüntüleme: ürün detayından `ProductReviewsView` açılır ve yorumları okur.
- Mevcut `ProductReviewsView` salt okunurdur. Repo genelinde üretim kodundan
  `ReviewsCubit.addReview` çağıran bir form, buton veya başka submit UI bulunmadı.
  Gönderme zinciri DI üzerinden oluşturulabilir olsa da mevcut müşteri
  navigation'ında onu başlatan UI yoktur.

### Gerçek gönderme kuralları

`addReview` şu kontrolleri yapar:

1. Oturum yoksa işlemi reddeder.
2. Aynı `user_id + product_id` için yorum varsa işlemi reddeder.
3. `_checkVerifiedPurchase(productId)` sonucunu alır.
4. Sonuç `true` veya `false` olsa da yorumu ekler; sonucu yalnız
   `is_verified_purchase` alanına yazar.

DB sözleşmesi de satın alma kanıtını zorunlu kılmaz. `reviews_insert_own`
politikası yalnız `user_id = auth.uid()` şartını denetler. `reviews` tablosunda
`user_id + product_id` unique, rating için `1..5` sınırı vardır; satın alma,
shop veya order ilişkisi zorunluluğu yoktur.

### Legacy sorgunun kesin biçimi

`ReviewRepositoryImpl._checkVerifiedPurchase`:

- `order_items.product_id = istenen product_id`,
- inner join ile `orders.user_id = aktif kullanıcı`,
- `orders.status = 'delivered'`,
- en az bir satır

şartlarını arar.

Shop ilişkisi aranmaz. Review kaydında `order_id` tutulmaz ve çağıran koddan
`order_id` istenmez. Bununla birlikte sorgunun join yapabilmesi için
`order_items.order_id -> orders.id` ilişkisi gerekir.

### Güven sınırı

Mevcut `is_verified_purchase` işareti server-attested değildir:

- istemci review INSERT payload'ında bu boolean alanı doğrudan gönderir;
- review RLS politikası alanın doğruluğunu kontrol etmez;
- authenticated role legacy `orders/order_items` için INSERT yetkisine sahiptir;
- legacy order INSERT politikası kullanıcı sahipliğini kontrol eder, ancak
  `status = delivered` değerinin güvenilir bir merchant/server geçişinden
  geldiğini kanıtlamaz.

Bu nedenle mevcut etiket gerçek bir fraud-resistant purchase eligibility kanıtı
olarak kabul edilmemelidir. Mevcut yorumların etiket anlamının nasıl ele
alınacağı ayrıca ürün/veri kararı gerektirir.

## B. Shop rating

Shop rating akışı product review'dan tamamen ayrıdır ve legacy order kullanmaz.

- İstemci `ShopRatingRepositoryImpl.submitVerifiedShopRating` üzerinden
  `submit_verified_shop_rating(p_qr_session_id, p_rating)` RPC'sini çağırır.
- RPC, `verified_transactions.source_qr_session_id` ve
  `customer_user_id = auth.uid()` ile doğrulanmış işlemi bulur.
- `shop_id` ve `verified_transaction_id` server tarafında doğrulanmış işlemden
  alınır.
- `shop_ratings.verified_transaction_id` unique olduğu için aynı doğrulanmış
  alışveriş yalnız bir kez puanlanabilir.
- Authenticated istemci `shop_ratings` tablosuna doğrudan yazamaz; yalnız SELECT
  grant'i vardır. INSERT, `SECURITY DEFINER` RPC içinden yapılır.
- QR tamamlanma paneli ve doğrulanmış alışveriş geçmişi aktif puanlama giriş
  noktalarıdır.

Sonuç: shop rating QR ile doğrulanmış alışverişe bağlıdır; `orders`,
`order_items` veya legacy `order_id` bağı yoktur.

## C. Legacy order reachability

### Navigation

- Ana müşteri navigation'ı: Home, Nearby, Cart V2, Wishlist ve Settings.
- Cart V2, QR session ve verified purchase geçmişine gider; checkout/order
  üretmez.
- Ürün detayı, shop profili ve discovery alanları legacy order ekranını açmaz.
- `LegacyOrdersView` başka bir `lib/**` dosyası tarafından import edilmez.
- `test/architecture/legacy_order_isolation_test.dart` bu sınırı zaten korur.

Bu audit için yeni navigation guard gerekli görülmemiştir; mevcut test hem ana
navigation/Cart V2/discovery bağlantılarını hem de dış legacy import'larını
denetler.

### DI ve Dart kodu

Wave 2 sonrasında `service_locator.dart` içinde aşağıdakilerin import veya kaydı
yoktur:

- `OrderRepository` / `OrderRepositoryImpl`,
- order use-case'leri,
- `OrdersCubit`.

Legacy order sınıfları yalnız kendi `lib/features/orders/**` modülünde ve legacy
unit testlerinde birbirine bağlıdır. Aktif uygulama grafiğinden erişilemezler;
ancak gelecekte bir dosya açıkça import edip elle oluşturursa tekrar erişilebilir
hale gelebilirler. Mevcut architecture testi bu dış import'u engeller.

Review repository legacy order Dart paketini import etmez; DB tablo sabitleri
üzerinden doğrudan `order_items -> orders` sorgusu yapar. Bu, legacy kod
modülünden bağımsız fakat legacy DB sözleşmesine bağlı ayrı bir kenardır.

## D. DB dependency haritası

`orders/order_items` yalnız review etiketi için kullanılmıyor:

1. `ReviewRepositoryImpl._checkVerifiedPurchase`, `is_verified_purchase`
   etiketini belirlemek için iki tabloyu okur.
2. `delete_current_customer_account` RPC'si, `orders.user_id` foreign key'i
   cascade olmadığı için auth kullanıcısını silmeden önce
   `DELETE FROM public.orders WHERE user_id = auth.uid()` çalıştırır.
   `order_items` bu silmede `ON DELETE CASCADE` ile temizlenir.
3. Canonical bootstrap migration'ları tablo, index, RLS, grant ve account-delete
   fonksiyon sözleşmelerini içerir. Migration 0006 preflight'ı `orders`
   tablosunun varlığını ayrıca bekler.
4. İzole legacy repository/use-case/Cubit kodu, yeniden elle bağlanırsa bu
   tabloları okuyup yazabilir; mevcut runtime grafiğinde böyle bir bağlantı yoktur.

Sonuç: review yönü değiştirilse bile account deletion fonksiyonu değiştirilmeden
tablolar kaldırılamaz. Canonical migration ve contract testleri de planlı bir
geçişte birlikte ele alınmalıdır.

### Mevcut regression kapsamı

- `legacy_order_isolation_test.dart`, aktif navigation/Cart V2/discovery/DI
  sınırını korur.
- Review Cubit ve product-review widget testleri okuma, pagination ve submit
  state zincirini mock use-case ile sınar.
- Shop-rating Cubit, QR bottom sheet ve purchase-history widget testleri
  doğrulanmış transaction kimliğinin puanlama zincirine aktarılmasını sınar.
- Canonical migration contract testi legacy ve verified tabloların baseline
  sözleşmesini denetler.

Doğrudan `ReviewRepositoryImpl` için unit veya gerçek backend integration testi
bulunmadı. Bu nedenle legacy sorgunun `false` fallback'i, `is_verified_purchase`
payload'ı ve DB policy güven sınırı bugün otomatik regression kanıtına sahip
değildir. Ürün kararı verilmeden mevcut zayıf sözleşmeyi kalıcılaştıran yeni bir
davranış testi eklenmemiştir.

## E. Verified purchase capability

### Mevcut yeterli alanlar

`verified_transactions`:

- `id`: kalıcı transaction identity,
- `source_qr_session_id`: tekil QR kaynak kimliği,
- `customer_user_id`: müşteri sahipliği snapshot'ı,
- `shop_id` ve `shop_name`: mağaza kimliği/adı snapshot'ı,
- `confirmed_by_user_id`: doğrulayan merchant kullanıcısı,
- `confirmed_at`: doğrulama zamanı,
- item count ve toplam tutar.

`verified_transaction_items`:

- `verified_transaction_id`: parent transaction ilişkisi,
- `shop_product_id`: satın alma anındaki listing kimliği snapshot'ı,
- ürün adı, miktar, birim fiyat ve satır toplamı snapshot'ları,
- transaction + shop product tekilliği.

Tablolar client için read-only'dir. Kayıtlar QR confirmation RPC'si tarafından
üretilir; mutable kullanıcı, shop, QR veya catalog tablolarına foreign key ile
bağlı değildir. Bu yapı sahiplik, shop, zaman ve işlem kanıtı için yeterlidir.

### Ürün yorumu için eksik alan

`verified_transaction_items` immutable bir catalog `product_id` snapshot'ı
taşımaz. `shop_product_id`, mevcut `shop_products` satırına join edilirse bugün
`product_id` bulunabilir; fakat verified item alanı bilinçli olarak FK değildir
ve listing daha sonra silinebilir veya değişebilir. Bu join kalıcı ürün kanıtı
sayılmaz.

QR-only product review eligibility için en azından satın alma anındaki
`product_id` kimliğinin durable item snapshot'ında bulunması gerekir. Eski
verified kayıtların nasıl ele alınacağı da karardır: listing hâlâ varsa backfill,
kanıt yoksa ineligible/manuel değerlendirme veya yalnız yeni işlemler gibi bir
politika seçilmelidir. Bu audit migration tasarlamaz.

## Product options

### Option A - Yalnız QR ile doğrulanmış alışveriş

- Fraud resistance: En güçlü seçenek. Eligibility ve verified etiketi
  server-authoritative verified transaction/item kanıtından türetilebilir.
- UX: QR doğrulaması yapılan fiziksel alışverişler için net ve ürün modeliyle
  tutarlı; QR kullanılmamış geçmiş alışverişleri dışarıda bırakır. Review giriş
  noktası purchase history veya uygun product detail durumunda gösterilebilir.
- Backend complexity: Orta. Durable `product_id` snapshot'ı, server-side
  eligibility/submit sözleşmesi, geçmiş veri politikası ve entegrasyon testleri
  gerekir.
- Legacy dependency: Review tarafında kaldırılabilir. Account deletion bağı
  ayrıca çözülmelidir.
- Migration impact: Önce additive snapshot/contract, sonra uygulama geçişi;
  legacy drop ancak ayrı ve daha sonraki bir aşamadır.

### Option B - Legacy order veya verified purchase

- Fraud resistance: Karışık ve mevcut haliyle zayıf. QR kanıtı güçlü, legacy
  delivered order kanıtı istemci tarafından üretilebilir. İki kaynağın aynı
  "verified" etiketi altında gösterilmesi güven seviyesini belirsizleştirir.
- UX: Eski kullanıcı kapsamı daha geniştir; hangi alışverişin hangi kanıtla
  uygun olduğu anlatılmalıdır.
- Backend complexity: En yüksek seçenek. İki proof kaynağı, dedup, geçmiş veri,
  badge semantiği ve olası legacy hardening birlikte yönetilir.
- Legacy dependency: Devam eder; `orders/order_items` kaldırılamaz.
- Migration impact: Verified item için yine durable `product_id` gerekir;
  legacy kaynak sunset edilmedikçe sonraki drop aşamasına geçilemez.

### Option C - Satın alma doğrulaması olmadan açık yorum

- Fraud resistance: En düşük seçenek. Spam, sahte deneyim ve moderasyon yükü
  artar; yalnız auth + kullanıcı/ürün tekilliği kalır.
- UX: En düşük sürtünme ve en geniş katılım. Mevcut repository davranışı, submit
  UI olmaması dışında, fiilen bu modele yakındır.
- Backend complexity: İlk aşamada düşük; moderation/reporting/rate-limit
  ihtiyaçları toplam karmaşıklığı artırabilir.
- Legacy dependency: Review sorgusundan hemen kaldırılabilir; account deletion
  ve canonical DB bağı yine ayrıca çözülmelidir.
- Migration impact: Düşük/orta. `is_verified_purchase` alanı ve mevcut badge'lerin
  anlamı için veri/ürün kararı gerekir.

## Önerilen teknik yön

EsnaftaVar'ın fiziksel mağaza ve QR ile doğrulanmış alışveriş modeline en doğal
teknik uyum Option A'dır. Aynı doğrulama kaynağını shop rating, purchase history
ve product review için kullanmak tek ve server-authoritative bir ticari kanıt
sınırı oluşturur.

Bu yalnız teknik öneridir. Yorumların QR zorunluluğu, eski alışverişlerin
geçerliliği ve mevcut verified badge'lerin anlamı ürün sahibi kararı gerektirir.

## Verified purchase seçilirse legacy removal path

1. Ürün sahibi Option A/B/C kararını, historical eligibility ve mevcut badge
   politikasını kesinleştirir.
2. Option A için verified item proof'unun immutable `product_id` eksiği additive
   bir sözleşmeyle giderilir; eski verified kayıtların backfill/eligibility
   politikası belirlenir.
3. Review eligibility ve submit, client boolean yerine server-authoritative
   query/RPC/policy ile uygulanır. Product review submit UI ancak bu sözleşmeyle
   birlikte açılır.
4. Repository, use-case/Cubit, RLS/RPC ve backend integration testleri hem
   eligible hem ineligible, duplicate, wrong-user ve stale catalog senaryolarını
   doğrular. Legacy review sorgusu bundan sonra kaldırılır.
5. `delete_current_customer_account` ve migration preflight'ındaki `orders`
   bağı, hesap silme davranışı korunarak kaldırılır/değiştirilir ve hesap silme
   regresyonu doğrulanır.
6. Repo genelinde import/table/function araması temizlenince legacy repository,
   model, entity, use-case, Cubit, view/widget ve yalnız onlara ait testler ayrı
   değişiklikte kaldırılır; architecture guard yeni sınırı korur.
7. Önce legacy write erişimi kapatılır ve saklama/backfill kararı uygulanır.
   `orders/order_items` drop işlemi veri etkisi onaylandıktan sonra ayrı, sonraki
   bir migration olarak değerlendirilir; bu audit drop veya migration yapmaz.
8. Canonical migration contract, account deletion, review/rating, Cart V2/QR,
   tam test suite ve analyzer birlikte doğrulanır.

## Bu görevde değişmeyenler

- Review gönderme veya eligibility davranışı değiştirilmedi.
- Legacy kod ya da tablo silinmedi.
- Migration, schema, RLS, policy veya grant değiştirilmedi.
- Navigation ve DI değiştirilmedi.
- Production veya başka bir remote ortam kullanılmadı.
