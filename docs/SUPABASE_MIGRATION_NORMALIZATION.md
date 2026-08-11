# Canonical Supabase Migration Normalization

Bu belge EsnaftaVar'ın fresh bir Development Supabase projesi için tek resmi
şema zincirini tanımlar. Kanonik kaynak `supabase/migrations/` dizinidir.
Repo kökündeki eski `supabase_schema.sql`, `supabase_migration_*.sql`, seed ve
verification dosyaları silinmemiştir; yalnız tarihsel kaynak/referanstır ve yeni
bir veritabanına sırayla uygulanacak migration zinciri değildir.

## Kanonik sıra

| Sıra | Dosya | Sorumluluk | Eklenen public tablo |
|---|---|---|---:|
| 0001 | `20260812000100_0001_core_auth_catalog.sql` | Managed auth bağı, profil/rol/consent, katalog, adres/lokasyon, wishlist, legacy review-order bağı, banner, chat ve notification temeli | 14 |
| 0002 | `20260812000200_0002_shops.sql` | Shop/listing modeli, merchant/admin gate ve owner RLS | 2 |
| 0003 | `20260812000300_0003_carts_v2.sql` | Aktif Cart V2 modeli | 2 |
| 0004 | `20260812000400_0004_qr_verified_purchases.sql` | Immutable QR snapshot, race-safe create/verify/confirm RPC'leri ve kalıcı satın alma kanıtı | 4 |
| 0005 | `20260812000500_0005_verified_shop_ratings.sql` | Verified transaction başına tek shop puanı ve aggregate | 1 |
| 0006 | `20260812000600_0006_chat_notifications_account.sql` | Conversation RPC'leri, trusted notification trigger'ları ve müşteri hesap silme RPC'si | 0 |
| 0007 | `20260812000700_0007_storage_realtime.sql` | Kesinleşmiş Realtime publication üyeliği ve Storage karar sınırı | 0 |

Tam zincirin beklenen public tablo sayısı **23**'tür.

## Fresh bootstrap sözleşmesi

- Zincir fresh bir Supabase projesine artan dosya adı sırasıyla uygulanır.
- `auth.users`, `storage.buckets` ve `supabase_realtime` Supabase tarafından
  yönetilen bağımlılıklardır; migration bunları oluşturmaz veya resetlemez.
- Her migration transaction, timeout ve dependency preflight içerir.
- Dosyalar bilinmeyen mevcut nesneleri `DROP` ederek uyarlamaya çalışmaz. Bu
  nedenle zincir, dağınık eski SQL'lerin daha önce uygulandığı bir veritabanına
  doğrudan basılmamalıdır. Böyle bir ortam ayrı reconciliation/audit ister.
- Signup kurulumu mevcut `auth.users.on_auth_user_created` trigger'ını
  körlemesine düşürmez. Aynı canonical fonksiyona bağlıysa korunur; farklı bir
  fonksiyona bağlıysa migration açıklayıcı hata ile durur.
- `supabase_schema.sql` destructive reset içerdiği için artık bootstrap girdisi
  değildir.

Supabase CLI yapılandırılmış, disposable bir local stack mevcutsa kanonik
zincirin gerçek PostgreSQL doğrulama kapısı `supabase db reset` ile yapılabilir.
Fresh remote Development bootstrap ise yalnız yetkili integration/release
çalışmasında, hedef proje kimliği ikinci kez doğrulandıktan sonra
`supabase db push` ile yapılmalıdır. Bu normalization çalışması local veya
remote veritabanına migration uygulamaz.

## Normalleştirilen tekrarlar

- Bütün `updated_at` tabloları tek `public.set_updated_at()` fonksiyonunu ve
  tablo başına tek trigger'ı kullanır.
- `chat_messages` content uzunluğu tek isimli constraint'tir.
- Signup için yalnız final role + legal-consent davranışı vardır.
- QR create/confirm RPC'leri yalnız release-hardening'deki lock sırası ve taze
  clock davranışıyla kurulur; geçici/zayıf sürüm yoktur.
- Policy, grant, constraint ve trigger'lar final haliyle bir kez tanımlanır.
- Notification istemcisine `SELECT`, `UPDATE`, `DELETE` verilir; doğrudan
  `INSERT` verilmez. Kayıtlar yalnız trusted trigger fonksiyonlarından oluşur.

## Kapsam kararları

- `orders` ve `order_items`, mevcut ürün yorumu eligibility sorgusu nedeniyle
  legacy sözleşme olarak korunur. Cart V2 veya QR akışı bu tablolara bağlanmaz.
- Eski `cart_items` tablosunun aktif repository kullanımı yoktur ve Cart V2 ile
  değiştirilmiştir; kanonik zincire alınmamıştır.
- Eski `coupons` tablosunun aktif Supabase repository kullanımı yoktur;
  kanonik zincire alınmamıştır.
- Product review eligibility bu görevde QR verified purchases'a taşınmamıştır.
- Kalıcı `verified_transactions`, item snapshot'ları ve `shop_ratings` auth/shop
  silinmesinden etkilenmemek için mutable tablolara FK taşımaz.

## SECURITY DEFINER standardı

Her `SECURITY DEFINER` fonksiyonu sabit bir `search_path` tanımlar ve doğrudan
client execute gerektirmeyen trigger/helper fonksiyonlarının execute hakkı
`PUBLIC`, `anon` ve `authenticated` rollerinden geri alınır. Client RPC'lerinde
önce `auth.uid()` ve rol/sahiplik doğrulanır. QR RPC'lerinde cart/session/catalog
lock sırası final concurrency modelini korur.

## Storage blocker

İstemci şu bucket adlarını bekler:

- `product-images`
- `category-images`
- `brand-logos`
- `banner-images`
- `avatars`
- `review-images`

Mevcut ürün sözleşmesi bucket'ların public/private görünürlüğünü, yazabilecek
rolleri, object path sahiplik formatını, MIME/size limitlerini ve silme
kurallarını tüm bucket'lar için tanımlamaz. Özellikle avatar kodunun
`getPublicUrl()` kullanması tek başına bütün Storage güvenlik modelini seçmek
için yeterli değildir. Bu nedenle 0007 bucket veya `storage.objects` policy'si
oluşturmaz. Ürün sahibi bu kararları verdiğinde ayrı bir takip migration'ı
gereklidir; geniş permissive policy kabul edilmez.

## Realtime kararı

Burada blocker yoktur. Chat repository `chat_messages.stream()` kullanır;
notification repository de `notifications` için INSERT/UPDATE postgres-change
aboneliği kurar. 0007 bu iki tabloyu, zaten üye değillerse, Supabase'in managed
`supabase_realtime` publication'ına ekler. Başka tablo publication'a eklenmez.

## Seed durumu

Seed, şema migration'larından ayrıdır. Ayrıntılı sıra ve blokajlar
`supabase/seed/README.md` içindedir. Repo otomatik çalışan bir
`supabase/seed.sql` sağlamaz; mevcut non-idempotent örnek veri dosyaları kanonik
bootstrap'ın parçası gibi gösterilmez.

## Integration validation gate

Repo statik sözleşme testleri SQL sırasını, 23 tabloyu, RLS/grant/revoke
kurallarını, destructive token yokluğunu, managed `auth.users` davranışını ve
`SECURITY DEFINER` search path'lerini kontrol eder. Merge sonrasında kalan gate:

1. Disposable local Supabase veya doğrulanmış fresh Development projesinde tüm
   zinciri gerçek PostgreSQL parser/engine ile uygulamak.
2. Postflight object/table/policy/function/grant envanterini beklenen sözleşmeyle
   karşılaştırmak.
3. Storage ürün kararlarını alıp ayrı, least-privilege migration hazırlamak.

Production bu bootstrap/reconciliation akışının hedefi değildir.
