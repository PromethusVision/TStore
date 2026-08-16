# Production Pre-Migration Baseline

**Evidence tarihi:** 2026-08-16

**Remote snapshot zamanı:** `2026-08-16 17:41:47.032246 UTC`

**Branch / önceki Phase A commit:**
`agent1/w10-production-readonly-verification` /
`8fb77f7f4c8eff1e62be476a52c3110bb0228c3c`

**Production:** `EsnaftaVar Production` /
`mefhfvrgkwciubeajjeb` /
`https://mefhfvrgkwciubeajjeb.supabase.co` /
`Central EU (Frankfurt)`

Bu belge Wave 10 Phase B/C sırasında alınan, credential içermeyen pre-migration
evidence snapshot'ıdır. Production'da migration, DML, DDL, Auth/SMTP, Storage,
Realtime veya başka bir remote write yapılmadı.

`PRODUCTION_TOPOLOGY: F — FRESH/EMPTY`

`BACKUP_ROLLBACK_PLAN_READY: NO`

`DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT`

`READY_FOR_PRODUCTION_MIGRATION_APPLY: NO`

## Native backup, PITR ve restore capability

Authenticated Dashboard'da exact Production projesi için gözlenen gerçek plan
durumu:

| Capability | Read-only sonuç | Karar |
| --- | --- | --- |
| Plan | Free | Dashboard project/backup state |
| Scheduled database backup | Yok | Dashboard: `Free Plan does not include project backups` |
| PITR | Yok | Pro Plan add-on; bu projede aktif değil |
| Restore to new project | Kullanılamıyor | Pro Plan ve physical backups gerektiriyor |
| Restorable native point | Yok | Restore zamanı/point'i kaydedilemedi |
| Native restore drill | Yapılamadı | Desteklenen source backup yok |

Schema/data logical dump üretilmedi. Yerel makinede Supabase CLI, `pg_dump`/`psql`
ve Docker bulunmuyor; remote database credential istenmedi veya okunmadı. Fresh
baseline için bunun yerine exact catalog/count snapshot'ı alındı. Bu snapshot boşluğu
kanıtlar fakat restorable database backup'ın yerine geçmez.

## Credential-free pre-migration snapshot

Salt-okunur `SELECT` inventory sonucu:

| Nesne / veri | Count veya durum |
| --- | --- |
| Migration ledger relation | Yok (`NULL`) |
| Public relations | 0 |
| Public tables | 0 |
| Public views/materialized views | 0 |
| Public indexes | 0 |
| Public table triggers | 0 |
| Public policies | 0 |
| Public functions | Yalnız platform `rls_auto_enable()` |
| Storage buckets | 0 |
| Storage objects | 0 |
| Storage bucket/object policies | 0 |
| Realtime publication members | 0 |
| Auth users | 0 |
| Auth identities | 0 |
| Auth sessions | 0 |

Installed platform extensions: `pg_stat_statements`, `pgcrypto`, `plpgsql`,
`supabase_vault`, `uuid-ossp`.

Automatic RLS event trigger `ensure_rls` enabled durumdadır ve
`rls_auto_enable()` function'ına bağlıdır. Bu sorgular SQL Editor'da kaydedilmedi;
sonuçtan sonra geçici query metni discard edildi.

## Fresh-project conflict precheck

İkinci salt-okunur precheck aşağıdaki managed prerequisite ve çakışma durumunu
doğruladı:

| Kontrol | Sonuç |
| --- | --- |
| Canonical 23 table-name conflict | 0 |
| Existing non-internal `auth.users` trigger | 0 |
| `auth.users` managed table | Var |
| `storage.buckets` managed table | Var |
| `storage.objects` managed table | Var |
| `supabase_realtime` managed publication | Var |
| `pgcrypto` extension | Var |

Canonical migration'larda `pgcrypto` kurulumu `IF NOT EXISTS` kullanır. Existing
`on_auth_user_created` trigger yoktur; 0001'in fail-safe trigger preflight'ı mevcut
custom trigger'a çarpmaz. Public'teki tek platform function'ı `rls_auto_enable()`
canonical function adlarıyla çakışmaz. Storage bucket/policy ve Realtime membership
çakışması yoktur.

## Write-freeze değerlendirmesi

Snapshot anında business state fiilen quiescent'tir: Auth user, uygulama tablosu ve
Storage object yoktur; Production client artifact'i henüz yayınlanmamıştır. Bu nedenle
mevcut durumda korunacak müşteri write'ı veya migration sırasında yarışacak uygulama
row'u yoktur.

Buna rağmen database-level enforced freeze aktif değildir. Auth signup ayarı enabled
durumdadır ve repo maintenance/ingress freeze mekanizması sağlamaz. Phase D öncesi
release commander şunları zorunlu olarak sağlamalıdır:

1. Production client config/artifact'i erişime açmamak;
2. change window ve incident/rollback owner'larını atamak;
3. apply'dan hemen önce Auth user, public table/row ve Storage object count'larını
   yeniden alıp sıfır olduklarını doğrulamak;
4. count değişmişse **STOP** edip Phase A–C'yi yeniden çalıştırmak.

Bu task Auth config değiştirmedi. Quiescent snapshot, tek başına operasyonel freeze
onayı veya imzalı change window değildir.

## Restore ve partial-failure stratejisi

Mevcut Free plan için gerçek native restore yolu yoktur. Güvenli failure davranışı:

1. Hata aynı migration transaction'ındaysa o dosya rollback olur; apply durdurulur.
2. Önceki migration'lar commit olduysa freeze korunur ve ledger/schema yalnız
   read-only yeniden envanterlenir. Otomatik `DROP`, `down`, `repair` veya remote reset
   yapılmaz.
3. Exact Production ref korunacaksa tek düşük-riskli yol onaylı forward-fix veya
   reconciliation'dır; native point restore seçeneği yoktur.
4. Proje hâlâ tamamen boşsa alternatif, owner onayıyla başarısız hedefi terk edip yeni
   fresh Production projesi oluşturmaktır. Bu seçenek ref/URL/key değiştirir ve Auth,
   client config ile release kayıtlarının yeniden kurulmasını gerektirir; bu task'ta
   uygulanmadı veya yetkilendirilmedi.
5. Production'da veri oluştuğu anda Free-plan recreate yaklaşımı veri restore'u
   değildir ve kabul edilemez.

Pre-migration business-data RPO teorik olarak sıfır row'dur; ancak kabul edilmiş
RPO/RTO, restore/incident owner, restorable point ve gerçek restore drill yoktur.
Bu nedenle `BACKUP_ROLLBACK_PLAN_READY: NO` ve apply kapısı kapalıdır.

## Exact 0001–0009 apply order

| Sıra | Migration | Dependency | Fresh baseline conflict | Beklenen ana sonuç |
| ---: | --- | --- | --- | --- |
| 1 | `20260812000100_0001_core_auth_catalog.sql` | Managed `auth.users`; empty public | Yok; Auth custom trigger 0 | 14 core table, profile/consent/catalog/RLS/grant/trigger baseline |
| 2 | `20260812000200_0002_shops.sql` | 0001 profiles/products | Yok | `shops`, `shop_products`, merchant ownership/RLS |
| 3 | `20260812000300_0003_carts_v2.sql` | 0002 shops/listings | Yok | `carts`, `cart_items_v2`, single-shop cart contract |
| 4 | `20260812000400_0004_qr_verified_purchases.sql` | 0001–0003, managed extensions | `pgcrypto` already installed; `IF NOT EXISTS` safe | QR/verified tables ve race-safe RPC baseline |
| 5 | `20260812000500_0005_verified_shop_ratings.sql` | Shops + verified transactions | Yok | Verified rating table/RPC/aggregate |
| 6 | `20260812000600_0006_chat_notifications_account.sql` | Profiles/chat/notifications/orders | Yok | Chat summary, trusted notifications, account-delete RPC |
| 7 | `20260812000700_0007_storage_realtime.sql` | Managed publication + chat/notification tables | Publication var, member 0 | Yalnız chat/notification Realtime membership |
| 8 | `20260814000800_0008_fix_profile_role_guard.sql` | 0001 profile role guard | Canonical predecessor clean-room'da mevcut | Fail-closed customer role guard |
| 9 | `20260815000900_0009_verified_product_reviews_storage.sql` | 0001–0008 + managed Storage | Bucket/object/policy 0 | Durable product proof, verified reviews, aggregates, üç frozen bucket |

Her dosya kendi transaction'ında çalışır. Exact sıra dışında tail/tekil migration
uygulanmamalı; seed, legacy root SQL veya `--include-all` eklenmemelidir.

## Automatic RLS interaction

Remote `ensure_rls` trigger yeni `public` tablolar CREATE edildiğinde RLS'i enable eder.
Canonical zincir aynı 23 tabloda açık `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
ifadelerini daha sonra çalıştırır. PostgreSQL'de ikinci enable aynı boolean state'i
yeniden set eder; duplicate object oluşturmaz. Policy creation, RLS'in daha önce
enable edilmiş olmasından etkilenmez.

Static contract 23 canonical tablonun her birinde exact bir explicit enable bulunduğunu
ve migration'ların `ensure_rls`/`rls_auto_enable` platform nesnelerini create/drop/
replace etmediğini doğrular. Zararlı double-state veya name conflict bulunmadı.

## Data API / grants interaction

Production Data API enabled; exposed schemas `public` ve `graphql_public`;
`Automatically expose new tables` **OFF**. Bu ayar yeni tablolara platformun otomatik
anon/auth grant vermesini engeller. Canonical migration'lar önce explicit revoke
baseline uygular, sonra yalnız tasarlanmış table/column/function grant'lerini verir.
`public` exposed schema olduğu için seçili client erişimi bu explicit grants üzerinden
PostgREST'e açılır; RLS/policy katmanı row erişimini ayrıca sınırlar.

Contract testleri broad table grant, direct authenticated notification INSERT,
direct review mutation ve client Storage list/mutation grant/policy bırakılmadığını
doğruladı. Interaction anlaşılmış ve least-privilege contract ile uyumludur.

## 0009 fresh-project dry impact

Historical `qr_session_items`, `verified_transaction_items`, `reviews`, product
aggregate, bucket veya object yoktur. Bu nedenle:

- durable `product_id` historical NULL count = 0;
- legacy/claimed verified review count = 0;
- aggregate reset etkilenen product count = 0;
- overwritten existing bucket config = 0;
- existing invalid/legacy Storage path = 0.

0009 fresh baseline için data-impact bakımından düşük risklidir. Üç active public
bucket yalnız JPEG/PNG/WebP allowlist ile `product-images` 8 MiB,
`category-images` 2 MiB ve `banner-images` 5 MiB olarak oluşur. Client Storage policy
oluşturulmaz.

## Local clean-room replay

Repo'nun mevcut `tool/sql_contract/validate_canonical_migrations.mjs` harness'i,
repo dışında geçici dizine kurulan `@electric-sql/pglite 0.5.5` ile çalıştırıldı.
Repo dependency veya migration dosyası değiştirilmedi.

Sonuç:

- migrations: 9/9 PASS;
- final public tables: 23;
- active buckets: `banner-images`, `category-images`, `product-images`;
- verified review RPC surface: 5/5;
- durable QR → verified transaction `product_id`: PASS;
- review lifecycle/idempotency/cross-user denial/aggregate: PASS;
- Storage path guards ve no client Storage policy: PASS;
- legacy review verified-aggregate isolation: PASS;
- partial migration failure: yok.

PGlite harness managed `auth`, `storage`, `pgcrypto` ve Realtime prerequisites için
repo içindeki kontrollü Supabase-compatible stub'ları kullanır; gerçek Supabase
control plane değildir. Buna ek olarak canonical/QR/review-Storage contract testleri
PASS olmuştur.

Linked Supabase CLI `db push --dry-run` çalıştırılmadı: yerel Supabase CLI/database
credential yoktur ve secret istenmedi. Phase D yetkilendirmesinden hemen önce exact
branch/commit üzerinde linked dry-run'ın yalnız beklenen dokuz pending migration'ı
göstermesi hâlâ zorunludur.

## Gate kararı

`MIGRATION_ARTIFACT_INTEGRITY: PASS — 9/9`

`DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT`

`BACKUP_ROLLBACK_PLAN_READY: NO`

`READY_FOR_PRODUCTION_MIGRATION_APPLY: NO`

No-go nedeni migration conflict'i değildir. Blocker; Free plan'da restorable native
point/PITR bulunmaması, accepted RPO/RTO ve restore/incident owner'larının atanmaması,
restore drill olmaması ve enforced change-window freeze'in henüz kanıtlanmamasıdır.
Bu koşullar kapanmadan Phase D migration apply yapılmamalıdır.
