# Production Current State Inventory

**Inventory tarihi:** 2026-08-16

**Kaynak branch/base:** `agent1/w9-production-readonly-inventory` /
`origin/main@b793aeab5174733d329df7743d86e73b0c68eced`

**Yetki sınırı:** Yalnız read-only project discovery. Production SQL, migration,
schema, RLS, Auth, Storage, Realtime veya veri yazması yapılmadı.

`PRODUCTION_PROJECT_IDENTIFIED: NO`

`PRODUCTION_INVENTORY_READY: NO`

`PRODUCTION_PROJECT_IDENTIFICATION_REQUIRED`

## Yönetici özeti

Kimliği doğrulanmış Supabase Dashboard oturumunda tek organizasyon altında iki proje
görüldü. Bunlardan yalnız `EsnaftaVar Development` açıkça tanımlıdır. Diğer proje,
hesap e-posta adresinden türetilmiş varsayılan bir ada sahiptir ve hiçbir Dashboard
etiketi, repo kaydı, release kaydı veya Production configuration contract değeri onu
`EsnaftaVar Production` olarak doğrulamamaktadır.

Belirsiz projeyi Production kabul etmek tahmin olacağından o projede project detail,
Management API, database catalog, migration ledger, Auth, Storage veya Realtime
envanter sorgusu çalıştırılmadı. Bu belgedeki uzak durum alanları bu nedenle bilinçli
olarak `UNKNOWN` veya `NOT RUN` durumundadır.

## Project discovery

| Gözlem | Read-only sonuç | Karar |
| --- | --- | --- |
| Organizasyon | `Musaki bilisim`; Dashboard proje listesi iki proje gösterdi | Yalnız project-list discovery |
| Development | Ad `EsnaftaVar Development`; ref `tnipyxnvhgelwdpykyez`; AWS `eu-central-1` | **Production değildir; kesin olarak dışlandı** |
| Diğer erişilebilir proje | Dashboard adı hesap e-posta adresinden türetilmiş varsayılan proje adı; ref `ieebtdvvinqfatbhkyqi`; AWS `eu-west-1` | Production olduğuna dair açık kanıt yok; aday üzerinde envanter yapılmadı |
| Production adı | Bilinmiyor | `UNKNOWN` |
| Production ref | Bilinmiyor | `UNKNOWN` |
| Production URL | Bilinmiyor; ref'ten URL türetilmedi | `UNKNOWN` |

Hesap e-posta adresi credential değildir ancak gereksiz kişisel veri olduğu için
varsayılan proje adının e-posta bölümü bu committed belgede redakte edilmiştir. Project
ref secret değildir ve adayın neden ayırt edilemediğini göstermek için kaydedilmiştir.

### Bağımsız yerel kanıt kontrolü

- Tracked repo içinde `ieebtdvvinqfatbhkyqi` ref'i bulunmuyor.
- Tracked Production configuration değerleri gerçek endpoint/key içermez;
  `.env.example` yalnız placeholder contract taşır.
- Mevcut readiness ve cutover belgeleri gerçek Production ref/name/URL'nin bilinmediğini
  söylüyor.
- Supabase CLI `2.114.0` kullanılabilir; ancak CLI için access token kurulmamıştır.
  Yeni token oluşturulmadı. Discovery mevcut, kimliği doğrulanmış Dashboard oturumuyla
  sınırlı tutuldu.

## Production remote inventory

Production project kesin tanımlanmadığı için aşağıdaki kontrollerin hiçbiri belirsiz
aday üzerinde çalıştırılmadı.

| Alan | Sonuç | Drift sınıfı | Eksik kanıt |
| --- | --- | --- | --- |
| Migration ledger/history | `NOT RUN` | `UNKNOWN` | `supabase_migrations.schema_migrations` ve exact 0001–0009 kayıtları |
| Public tables/columns | `NOT RUN` | `UNKNOWN` | Catalog table/column inventory |
| PK/FK/constraints/indexes | `NOT RUN` | `UNKNOWN` | Catalog constraint ve index inventory |
| Row counts | `NOT RUN` | `UNKNOWN` | Doğrulanmış Production üzerindeki read-only counts |
| RLS/policies | `NOT RUN` | `UNKNOWN` | Table RLS flags ve final policy definitions |
| Functions/RPC/triggers | `NOT RUN` | `UNKNOWN` | Signatures, definitions, search paths, ACL ve triggers |
| Anon/auth grants | `NOT RUN` | `UNKNOWN` | Table, column ve function grants |
| Storage buckets/objects/policies | `NOT RUN` | `UNKNOWN` | Bucket flags/limits/MIME, object counts ve Storage policies |
| Realtime | `NOT RUN` | `UNKNOWN` | Publication ve table membership |
| Auth non-secret config | `NOT RUN` | `UNKNOWN` | Email confirmation, providers, Site URL/redirects ve custom SMTP presence |

Production migration topology'si `F — fresh`, `C — canonical prefix` veya
`L — legacy/drifted` olarak sınıflandırılamaz. Production project kimliği ve catalog
kanıtı olmadan canonical migration'ların hiçbiri `SAFE FORWARD MIGRATION CANDIDATE`
olarak işaretlenmemelidir.

## Canonical 0001–0009 expected state

Bu bölüm yalnız repo kaynak sözleşmesini özetler; Production'ın bu durumda olduğunu
iddia etmez.

| Sürüm | Canonical ana sözleşme | Production durumu |
| --- | --- | --- |
| 0001 | Core Auth/profile/legal consent, catalog, saved data, legacy order/review, chat/notification temel tabloları | `UNKNOWN` |
| 0002 | `shops`, `shop_products` ve merchant role-gated ownership | `UNKNOWN` |
| 0003 | `carts`, `cart_items_v2` ve tek-mağaza Cart V2 | `UNKNOWN` |
| 0004 | QR sessions/items, verified transactions/items ve race-safe RPC'ler | `UNKNOWN` |
| 0005 | Verified shop ratings ve aggregate contract | `UNKNOWN` |
| 0006 | Chat summary, trusted notifications ve customer account deletion | `UNKNOWN` |
| 0007 | `chat_messages` + `notifications` Realtime publication üyeliği | `UNKNOWN` |
| 0008 | Client profile role escalation guard düzeltmesi | `UNKNOWN` |
| 0009 | Durable `product_id`, RPC-only verified reviews ve üç active Storage bucket | `UNKNOWN` |

Canonical final kaynak beklentisi:

- 23 public tablo: `profiles`, `legal_consents`, `categories`, `brands`,
  `products`, `addresses`, `customer_saved_locations`, `wishlist`, `orders`,
  `order_items`, `reviews`, `banners`, `chat_messages`, `notifications`, `shops`,
  `shop_products`, `carts`, `cart_items_v2`, `qr_sessions`, `qr_session_items`,
  `verified_transactions`, `verified_transaction_items`, `shop_ratings`;
- 23/23 public tabloda RLS enabled;
- canonical final public policy sayısı 52;
- Realtime publication üyeleri yalnız `public.chat_messages` ve
  `public.notifications`;
- aktif Storage contract: public-read `product-images` (8 MiB),
  `category-images` (2 MiB), `banner-images` (5 MiB), yalnız JPEG/PNG/WebP;
- client Storage list/write/update/delete policy'si yok;
- `brand-logos`, `avatars` ve `review-images` deferred.

## Local canonical artifact consistency finding

`MIGRATION_ARTIFACT_INTEGRITY: PASS`

Agent 1'in base üzerindeki 0/9 bulgusu Wave 9 integration'da kök neden analiziyle
kapatıldı. Eski cutover manifesti Windows `core.autocrlf` sonrası CRLF checkout
byte'larını kaydetmiş, karşılaştırma ise Git'te saklanan LF blob byte'larıyla yapılmıştı.
SQL semantiği veya Production drift'i bulunmadı. Manifest artık platformdan bağımsız
Git/LF byte sözleşmesini kullanıyor ve
`node tool/verify_migration_artifact_manifest.mjs` ile **9/9 PASS** veriyor.

0001–0009 Git içerik geçmişi, Development apply/postflight kanıt commit'leriyle
karşılaştırıldı. Her migration'ın son intentional içerik değişikliği ilgili apply
kanıtından öncedir; Development'a uygulama kaydından sonra tracked SQL mutation
bulunmadı. Ayrıntılı commit/hakikat tablosu cutover planındadır. Supabase ledger
checksum saklamadığından bu yerel PASS, hâlâ bilinmeyen Production schema ve remote
object karşılaştırmasının yerine geçmez.

## Important domain state

| Domain | Production row count / state | Sınıf |
| --- | --- | --- |
| Profiles/legal consent | `UNKNOWN` | `UNKNOWN` |
| Shops/products/shop_products | `UNKNOWN` | `UNKNOWN` |
| Cart V2 (`carts`, `cart_items_v2`) | `UNKNOWN` | `UNKNOWN` |
| QR sessions/items | `UNKNOWN` | `UNKNOWN` |
| Verified transactions/items | `UNKNOWN` | `UNKNOWN` |
| Reviews/product aggregates | `UNKNOWN` | `UNKNOWN` |
| Chat/notifications | `UNKNOWN` | `UNKNOWN` |
| Shop ratings | `UNKNOWN` | `UNKNOWN` |
| Legacy orders/order_items | `UNKNOWN` | `UNKNOWN` |

## 0009 special check

Production project bilinmediği için 0009 öncesi/sonrası etkilenebilecek satır sayısı
ölçülmedi.

| 0009 kontrolü | Read-only count | Sınıf |
| --- | --- | --- |
| `qr_session_items.product_id` kolon varlığı ve historical NULL | `NOT RUN` | `UNKNOWN` |
| `verified_transaction_items.product_id` kolon varlığı ve historical NULL | `NOT RUN` | `UNKNOWN` |
| Legacy review toplamı / claimed verified | `NOT RUN` | `REQUIRES DATA ANALYSIS` |
| Evidence-backed / evidence'sız review | `NOT RUN` | `REQUIRES DATA ANALYSIS` |
| Cached product aggregate delta | `NOT RUN` | `REQUIRES DATA ANALYSIS` |
| Active/deferred bucket varlığı ve ayarları | `NOT RUN` | `UNKNOWN` |
| Existing Storage object path/policy etkisi | `NOT RUN` | `REQUIRES DATA ANALYSIS` |

0009, verified flag ve product aggregate değerlerini değiştirebildiği ve mevcut bucket
ayarlarını upsert ettiği için Production verisi üzerinde sayı alınmadan
`SAFE FORWARD MIGRATION CANDIDATE` değildir.

## Security and mutation attestation

- Production SQL çalıştırılmadı.
- Migration list/apply/dry-run, repair, push, pull, dump veya reset çalıştırılmadı.
- Management API project-detail/Auth/backup çağrısı yapılmadı.
- Database, Auth, Storage veya Realtime üzerinde INSERT/UPDATE/DELETE/DDL yapılmadı.
- User, fixture, bucket, policy, token veya access key oluşturulmadı.
- Mevcut secret dosyaları okunmadı; credential, token veya key belgeye/loga yazılmadı.
- Remote read yalnız Supabase Dashboard organization/project listesiyle sınırlıdır.
- Belirsiz ikinci projenin iç kaynaklarına erişilmedi.

## Blockers and required continuation

1. Release sahibi exact Production project name, ref ve HTTPS URL'yi onaylı release
   kaydında açıkça tanımlamalı. Belirsiz varsayılan proje Production ise bu eşleştirme
   tahminle değil yazılı sahiplik kanıtıyla yapılmalıdır.
2. Production kimliği doğrulandıktan sonra read-only SQL inventory pack ve non-secret
   Auth/Storage/Realtime discovery yeniden çalıştırılmalıdır.
3. Canonical 0001–0009 manifesti Wave 9'da 9/9 doğrulandı; her release commit'inde
   platformdan bağımsız manifest aracı yeniden çalıştırılmalı ve Production remote
   schema/object karşılaştırması ayrıca yapılmalıdır.

İlk iki madde tamamlanmadan Production inventory gate kapalıdır. Yerel migration
artefact gate'i PASS olsa da bu durum Production migration apply yetkisi vermez.
