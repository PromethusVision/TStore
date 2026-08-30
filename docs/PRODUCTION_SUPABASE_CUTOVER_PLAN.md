# Production Supabase Cutover Plan

**Plan tarihi:** 2026-08-16

**Kaynak taban:** `origin/main@609a037664f8c001951ba00193e6112989399a9b`

**Kapsam:** EsnaftaVar Production Supabase keşfi, migration preflight, kontrollü
uygulama, postflight ve müşteri smoke sıralaması

**Wave 10 doğrulanmış Production:** `EsnaftaVar Production` /
`mefhfvrgkwciubeajjeb` / `Central EU (Frankfurt)`

**Wave 10 Production erişimi:** Read-only inventory/preflight/postflight **YES**;
remote write yalnız canonical `0001→0009` initial bootstrap apply **YES**

## Durum ve kesin sınır

`PRODUCTION_CUTOVER_PLAN_READY: YES`

`PRODUCTION_CUTOVER_AUTHORIZED: D1 CANONICAL APPLY ONLY — COMPLETED`

`PHASE_A_READ_ONLY_INVENTORY: PASS`

`PHASE_B_BACKUP_ROLLBACK: PASS — OWNER-ACCEPTED EMPTY-FIRST-BOOTSTRAP EXCEPTION`

`PHASE_C_DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT + LINKED CLI DRY-RUN`

`PHASE_D0_LINKED_CLI_DRY_RUN: PASS`

`PHASE_D1_CANONICAL_MIGRATION_APPLY: PASS`

`PHASE_E_METADATA_SECURITY_POSTFLIGHT: PASS`

`PHASE_D0_PRODUCTION_STATE_UNCHANGED: YES`

`PHASE_D1_PRODUCTION_STATE: CANONICAL SCHEMA / ZERO BUSINESS DATA`

`FIRST_BOOTSTRAP_NO_BACKUP_RISK_ACCEPTED: YES`

`PRODUCTION_SCHEMA_READY: YES`

`READY_FOR_PRODUCTION_MIGRATION_APPLY: COMPLETED`

`PRODUCTION_CLIENT_CONFIGURATION_COMPLETE: NO`

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / PLATFORM WIRING PENDING`

`READY_FOR_PHASE_E_PRODUCTION_CLIENT_WIRING: YES`

Wave 10 Phase A, Production kimliğini iki Dashboard görünümüyle doğruladı ve remote
topology'yi **F — Fresh/empty** olarak sınıflandırdı. Phase B/C, Free plan'da native
backup/PITR/restore point bulunmadığını; local clean-room 0001→0009 replay'in ise PASS
olduğunu doğruladı. Phase D0, Supabase CLI `2.114.0` ile exact Production ref'e linked
non-writing dry-run yaptı; yalnız canonical 0001→0009 pending görüldü ve before/after
remote snapshot değişmedi. Product owner, yalnız tamamen boş ilk `0001→0009`
bootstrap için Free-plan no-backup riskini ve güvenli forward-fix mümkün olmazsa boş
projenin yeniden oluşturulmasını kabul etti. Phase D1'de JIT zero-state tekrar PASS
oldu ve official linked CLI exact 0001→0009 zincirini uyguladı. Ledger/schema/RLS/
policy/grant/RPC/Storage/Realtime/Auth/data metadata postflight PASS; business data
halen sıfırdır. Production Auth/client/signing/smoke gate'leri açık olduğundan ticari
release hazır değildir. Ayrıntılı güncel snapshot:
[Production Pre-Migration Baseline](PRODUCTION_PRE_MIGRATION_BASELINE.md).

Bu plan şu belgelerin devamıdır:

- [Project State](PROJECT_STATE.md)
- [Production Readiness Audit](PRODUCTION_READINESS_AUDIT.md)
- [Production Smoke Checklist](PRODUCTION_SMOKE_CHECKLIST.md)
- [Production Go/No-Go Checklist](PRODUCTION_GO_NO_GO_CHECKLIST.md)

## Önce topology kararı

Production discovery tamamlanınca yalnız aşağıdaki üç yoldan biri seçilir:

| Yol | Kanıt | İzin verilen ilerleme |
| --- | --- | --- |
| F — Fresh/empty | Production public schema boş, migration ledger boş ve ortam henüz müşteri trafiği almıyor | Exact canonical 0001→0009 zinciri uygulanabilir. |
| C — Canonical prefix | Remote ledger, schema ve nesne tanımları 0001’den kesintisiz bir canonical prefix'e birebir eşleşiyor | Yalnız ledger'da eksik kalan canonical tail uygulanabilir. |
| L — Legacy/drifted | Ledger yok/uyuşmuyor, canonical isimli nesneler farklı, eski/verili schema veya beklenmeyen policy/grant var | **STOP.** 0001 ya da `--include-all` kör uygulanmaz. Ayrı reconciliation migration'ı veya fresh-project + kontrollü data move kararı gerekir. |

`migration repair`, yalnız schema'nın ilgili canonical migration ile gerçekten aynı
olduğu bağımsız kanıtlandıktan ve ayrıca change approval verildikten sonra ledger'ı
düzeltmek için kullanılabilir. SQL uygulamaz; yine de Production write'tır ve bu plan
çalışmasının yetkisinde değildir.

## Canonical artifact manifesti

Cutover runner, aşağıdaki SHA-256 değerlerini migration'ların **Git'te saklanan UTF-8
ve LF satır sonlu içerik byte'ları** üzerinden doğrulamalı; fark varsa durmalıdır.
Çalışma ağacı `core.autocrlf` nedeniyle CRLF içerebilir ve raw checkout byte hash'i
release artifact kimliği değildir. Platformdan bağımsız kontrol:

```text
node tool/verify_migration_artifact_manifest.mjs
```

Araç checkout satır sonlarını LF'ye normalize eder, mevcut tam on dosyayı ve
manifest üyeliğini doğrular. `0010` bu zincirde yalnız Development staged
bootstrap artefaktıdır; Production apply yetkisi veya Production ledger durumu
değildir. İstenirse aynı değer doğrudan tracked blob üzerinden
`git cat-file blob <release-commit>:supabase/migrations/<file>` çıktısının SHA-256'ı
alınarak bağımsız doğrulanabilir. Supabase migration ledger timestamp tutar, dosya
checksum'u kanıtlamaz; schema/function/policy karşılaştırması ayrıca zorunludur.

| Migration | SHA-256 |
| --- | --- |
| `20260812000100_0001_core_auth_catalog.sql` | `783991b4942f3be5cdfa41b3a62285f421383b051812d46d0acfc09f9cecef33` |
| `20260812000200_0002_shops.sql` | `acab9a5831a1eee600140310e0033375de3f0757df6e869160d9bed8ebb4ce15` |
| `20260812000300_0003_carts_v2.sql` | `6408d429842eae9a0948b082fdc517c5616b76348afeb9b6ce648ff670cd4e5b` |
| `20260812000400_0004_qr_verified_purchases.sql` | `93ace2a8ef8783755f4286a0c6cf7d342e436e5c1953f71820baf8ee39e84e67` |
| `20260812000500_0005_verified_shop_ratings.sql` | `29d721a1326623ea06d960791e3972bc874d4fc182acacd69390a8f498252c85` |
| `20260812000600_0006_chat_notifications_account.sql` | `29703c4331187a9d37e1a1caa3346aa5508974e53110814d51fc23065dcb36cb` |
| `20260812000700_0007_storage_realtime.sql` | `b035c05dcfc16836595b195888f208e51fbbd58d32c5f0fc25493aeed2cc702d` |
| `20260814000800_0008_fix_profile_role_guard.sql` | `e5422f3b43c50421c35e15956d163934f676039a76f2e76f9804d801380c4170` |
| `20260815000900_0009_verified_product_reviews_storage.sql` | `47df35090bbcfacd305b6a79fecdac88929d67edc4aaa6932f10ae21f45795fa` |
| `20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql` | `40fade490cde5f31b5c649ada301852b2abb40c0979a4f2e45bcd735b4f876b8` |

### Wave 9 hash investigation sonucu

`MIGRATION_ARTIFACT_INTEGRITY: PASS`

Wave 8 manifesti Windows CRLF checkout byte'larından üretilmişti. Bu nedenle aynı
SQL'in tracked Git blob'u ile 0/9 eşleşiyor, manifestin üretildiği Windows çalışma
ağacında ise 9/9 eşleşiyordu. Fark SQL semantiği veya migration drift'i değil,
platforma bağlı satır sonu dönüşümüydü. Wave 9 manifesti canonical Git/LF byte
sözleşmesine geçirildi ve bağımsız doğrulama aracıyla 9/9 PASS oldu.

Git içerik geçmişi ve Development uygulama kanıtı birlikte incelendi:

| Migration | Son içerik commit'i | Development apply kanıtından sonra tracked mutation | Değerlendirme |
| --- | --- | --- | --- |
| 0001–0003, 0005, 0007 | `71b01086da2e22e77c6c062875808aad16b6feac` / 0001 grant hardening `1ba10ed79a5d2743c56fd694641a9f476b434784` | NO | Apply öncesi canonical içerik |
| 0004, 0006 | `372f5160b1b7da7a948fa75caf5dabefaa5e4a8d` | NO | Apply öncesi intentional PostgreSQL isim çakışması düzeltmeleri |
| 0008 | `f681821d9deb77248c1bd3c3cb930ea08dd49f5a` | NO | Development apply/postflight öncesi role-guard hotfix |
| 0009 | `203ac8164c51b4c5bfe6c95f0952858502208eaa` | NO | Development apply öncesi intentional Storage path/client contract hizalaması |

Development kanıt commit'leri sırasıyla 0001–0007 için `1b062fa3`, 0008 için
`c8260114`, 0009 için `b71bb01c` sonrasındadır; bu apply kayıtlarından sonra ilgili
SQL dosyalarında başka tracked content commit'i yoktur. Sonuç **CASE A**'dır:
canonical SQL sonradan mutate edilmemiş, eski manifest platforma bağlı/stale kalmıştır.
Bu Git kronolojisi Development ledger'ının tutmadığı remote byte checksum'unun yerine
geçmez; Production cutover'da remote schema/function/policy karşılaştırması yine
zorunludur.

## Migration inventory

Her dosya kendi `BEGIN`/`COMMIT` transaction'ına, 5 saniyelik lock timeout'a ve
60–120 saniyelik statement timeout'a sahiptir. Bir dosya içindeki hata o dosyayı geri
alır; daha önce commit olmuş dosyaları geri almaz.

| Migration | Ne oluşturuyor/değiştiriyor | Dependency | Data impact | Destructive risk | Rollback / mitigation | Postflight validation |
| --- | --- | --- | --- | --- | --- | --- |
| 0001 | 14 core tablo; profile/signup/legal consent, catalog, legacy order, review, banner, chat, notification RLS/grant/function/trigger'ları | Managed `auth.users`; fresh/empty public schema | Existing data update yok; signup trigger commit sonrası yeni Auth kullanıcılarında profile/consent oluşturur | **Yüksek existing-schema riski:** `CREATE TABLE`, unique/FK/check, schema CREATE revoke ve mevcut `on_auth_user_created` trigger çakışması | Fresh dışında uygulama. Hata transaction rollback; commit sonrası restore veya onaylı forward reconciliation | 14 tablo, RLS/policy/grant; exact signup trigger/function; disposable signup yalnız Auth phase'inde |
| 0002 | `shops`, `shop_products`; merchant role-gated policies, indexes, update triggers | 0001 profiles/products ve `set_updated_at()` | Existing data update yok | Aynı isimli legacy tablolar; owner başına tek shop unique index; FK/check farklılığı | Route L ise STOP; clone üzerinde data shape/duplicate analizi | İki tablo/RLS; anon active-read; customer merchant escalation reddi; owner CRUD grantleri |
| 0003 | `carts`, `cart_items_v2`; tek aktif sepet ve tek-mağaza RLS sözleşmesi | 0002 shops/shop_products, Auth, update helper | Existing data update yok | Aynı kullanıcıda birden çok aktif sepet veya farklı legacy cart shape'i reconciliation'ı engeller | Fresh/prefix dışında uygulama; duplicate ve FK uygunluğu dry comparison'da çözülür | İki tablo/RLS; unique active cart; own CRUD ve cross-user negatifleri |
| 0004 | Dört QR/verified purchase tablosu, `pgcrypto`, immutable snapshot/RPC/trigger/lock sözleşmesi | 0001–0003, managed `extensions`, update helper | Yeni verified proof yalnız RPC çalışınca oluşur; migration mevcut satır update etmez | Existing QR nesne/signature çakışması; unique active QR; lock timeout; extension/schema eksikliği | Clone parse/apply ve concurrency test; hata tek dosyada rollback | Dört tablo/RLS; RPC signatures/grants; active/expired/duplicate/wrong-shop/concurrency testleri |
| 0005 | `shop_ratings`, aggregate trigger'ları ve verified rating RPC'si | Shops, verified transactions ve shop aggregate kolonları | Migration anında aggregate update yok; sonraki rating DML shop rating/count değiştirir | Transaction başına tek rating unique; farklı legacy rating modeli | Existing rating verisi varsa ayrı mapping/reconciliation; kör merge yok | Table/RLS/grants; verified-only submit, duplicate ve aggregate doğruluğu |
| 0006 | Chat summary RPC'leri, notification trigger'ları/grant daraltması, customer account delete RPC'si | Profiles, legacy orders, shops, chat, notifications, verified transactions | Migration anında row update yok; commit sonrası chat/purchase INSERT notification üretir; delete RPC çağrılırsa legacy order + Auth user siler | Authenticated notification INSERT grant'i varsa preflight bilinçli olarak FAIL; mevcut aynı trigger/index/function çakışması | Beklenmeyen direct INSERT grant'ini ad hoc değil reconciliation ile çöz; delete RPC smoke yalnız disposable hesapta | Summary/unread; trigger delivery ve recipient isolation; direct notification INSERT denial; account-delete contract |
| 0007 | `chat_messages` ve `notifications` tablolarını `supabase_realtime` publication'a idempotent ekler; bucket/policy oluşturmaz | İki tablo, managed `storage.buckets`, managed publication | Row update yok; commit sonrası Realtime event yayını başlar | Publication yoksa FAIL; beklenmeyen publication üyeliği/traffic etkisi | Publication değişikliği gerekiyorsa onaylı forward migration; CLI diff tek başına yeterli değildir | Exact iki publication membership; chat/notification delivery, isolation, reconnect/dedup |
| 0008 | Profile role guard function'ını güvenli `auth.role()` davranışıyla replace eder | Profiles, mevcut guard function ve exact trigger | Row update yok | Trigger yok/farklı function'a bağlıysa preflight FAIL; existing custom role semantics | Trigger/function drift'i önce belgeleyip reconciliation; ledger repair ile gizleme yok | Normal profile update; merchant/admin client escalation `42501`; function ACL/search path |
| 0009 | QR/verified item `product_id`; immutable guards; QR RPC replace; verified review evidence/RPC-only mutation; product aggregate recalc; üç public Storage bucket upsert ve path trigger | 0001–0008, managed buckets/objects, storage.objects RLS ve canonical QR/review functions | **Yüksek:** geçmiş review verified flag'leri false yapılır; bütün product rating/count canonical evidence'a göre güncellenir; bucket config upsert edilir | Historical evidence backfill yok; ratings sıfırlanabilir; bucket public/limit/MIME değişir; eski object policies ve invalid object adları kalabilir; 120s timeout/locks | Production-data clone'da impact ölçümü, write freeze, restorable backup. Commit sonrası basit down yok; restore veya onaylı forward fix | Nullable historical/new non-null evidence; RPC-only review; aggregate recompute; exact bucket settings; no client Storage policy; path trigger; invalid/legacy object inventory |

Canonical zincir kaynakta 23 public tablo ve 23/23 RLS üretir. `0001` toplam 55
`CREATE POLICY` içeren zincirin parçasıdır; `0009` üç direct review mutation policy'sini
düşürdüğü için canonical final public policy seti kaynak hesabıyla **52**'dir. Wave 7
belgelerindeki 55 sayısı önceki Development postflight'ının tarihsel kanıtıdır ve
post-0009 Production PASS sayacı olarak kullanılmamalıdır.

## 0009 Production özel değerlendirmesi

### Durable `product_id`

- `qr_session_items.product_id` ve `verified_transaction_items.product_id` nullable
  eklenir.
- Mevcut historical satırlar present-day catalog join ile backfill edilmez; NULL kalır.
- 0009 sonrası QR oluşturma RPC'si server-derived product UUID'yi snapshot'a yazar;
  confirm RPC'si aynı UUID'yi verified item'a taşır.
- Trigger'lar yeni satırda NULL'ı ve snapshot mutation'ını reddeder.
- Preflight'ta historical NULL sayıları ayrı kaydedilmeli; bunlar verified review
  eligibility sayılmamalıdır.

### Verified review ve aggregate etkisi

- `reviews.verified_transaction_item_id` nullable ve `ON DELETE RESTRICT` eklenir.
- Mevcut review'lara evidence backfill yapılmaz. `verified_transaction_item_id IS NULL`
  olan her satırın `is_verified_purchase` değeri false yapılır.
- Üç direct review mutation policy'si kaldırılır ve authenticated INSERT/UPDATE/DELETE
  grant'leri geri alınır; mutation yalnız frozen RPC'lerden geçer.
- `products.rating` ve `reviews_count`, yalnız non-null verified evidence taşıyan
  review'lardan yeniden hesaplanır. Canonical pre-0009 satırlarda bu evidence olmadığı
  için mevcut aggregate'lerin sıfıra düşme ihtimali gerçek ve ölçülmesi gereken bir
  business/data etkisidir.
- Review toplamı, verified flag toplamı, product aggregate delta'sı ve affected product
  sayısı clone üzerinde raporlanıp ürün sahibi/veri sahibi tarafından imzalanmadan
  apply edilmez.

### Storage bucket/policy etkisi

- `product-images` public, 8 MiB; `category-images` public, 2 MiB;
  `banner-images` public, 5 MiB olarak JPEG/PNG/WebP allowlist ile upsert edilir.
- Aynı ID'li bucket varsa `public`, size ve MIME alanları overwrite edilir. Bu nedenle
  mevcut private bucket'ın public olması mümkündür ve önceden açıkça onaylanmalıdır.
- Migration `storage.objects` için client policy oluşturmaz veya eski policy silmez.
  Production'daki beklenmeyen SELECT/INSERT/UPDATE/DELETE policy'leri kendiliğinden
  kapanmaz; herhangi biri varsa STOP/reconciliation gerekir.
- Path trigger yalnız sonraki INSERT veya bucket/name UPDATE'lerinde çalışır. Existing
  object adlarını taramaz, taşımaz veya silmez. Nonconforming existing path envanteri
  migration öncesi alınmalıdır.
- Supabase database backup'ları Storage API object blob'larını içermez; yalnız database
  metadata'sı yeterli değildir. Object backup/retention kanıtı ayrıca gerekir.

## Production read-only discovery araç sınırı

| Araç / işlem | Remote etkisi | Bu planda kullanım |
| --- | --- | --- |
| Management API `GET /v1/projects/{ref}` | Read-only | Ref, name, region/status kanıtı; response redacted saklanır |
| Management API `GET /v1/projects/{ref}/config/auth` | Read-only | Auth/email/redirect/provider config envanteri; secret alanlar loglanmaz |
| Management API `GET /v1/projects/{ref}/database/backups` | Read-only | Available backup/restore point, PITR flag'i ve retention kanıtı; yalnız `database:read` / `backups_read` yetkisi |
| PostgreSQL `BEGIN ... READ ONLY` içindeki `SELECT` | Enforced read-only transaction | Schema, RLS, policy, function, grant, trigger, row count ve data impact |
| `supabase migration list --linked` | Read-only remote | Local timestamp ile remote ledger karşılaştırması |
| `supabase db push --linked --dry-run` | Read-only dry plan | Uygulanacak dosya listesini gösterir; gerçek push değildir |
| `supabase db diff --linked --schema public,extensions` | Remote read, local shadow | Yardımcı schema diff; publication ve bucket farklarını yakalayamayabilir |
| `supabase db dump --linked` | Remote read, local artifact write | Backup yardımcısı; default dump data, custom roles, auth/storage managed schema ve Storage blob'ları kapsamaz |
| Dashboard yalnız görüntüleme | Save yapılmadıkça read-only kullanım | Project/Auth/backup kanıtı; mümkünse read-only yetkili hesap |

Phase A/C sırasında **kullanılmayacak** komut/işlemler:

- `supabase db push` dry-run olmadan;
- `supabase migration up/down/repair`;
- `supabase db reset --linked` veya remote DB URL ile reset;
- `supabase db pull` (remote history update prompt'u doğurabilir);
- SQL Editor/Table Editor DDL/DML;
- Management API `POST`, `PATCH`, `PUT`, `DELETE`;
- Dashboard'da Save/Restore/Create/Enable/Disable işlemi.

## Exact read-only SQL inventory pack

Bu sorgular yalnız exact project ref iki bağımsız kanıtla doğrulandıktan sonra, yeterli
catalog görünürlüğü olan bağlantıda çalıştırılır. Bağlantı secret'ı komut satırına,
shell history'ye veya rapora yazılmaz. Bütün SQL paketi şu transaction sınırında tutulur:

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL statement_timeout = '60s';
SET LOCAL lock_timeout = '5s';

-- Aşağıdaki SELECT sorguları.

ROLLBACK;
```

### Project/database ve migration ledger

```sql
SELECT current_database(), current_user, version();

SELECT column_name, data_type, ordinal_position
FROM information_schema.columns
WHERE table_schema = 'supabase_migrations'
  AND table_name = 'schema_migrations'
ORDER BY ordinal_position;

SELECT *
FROM supabase_migrations.schema_migrations
ORDER BY version;
```

Ledger tablosu yoksa ikinci sorgu çalıştırılmaz; sonuç Route F veya L kararına girer.
Migration listesi yalnız timestamp eşleşmesini kanıtlar, SQL içeriğini kanıtlamaz.

### Tables, columns, constraints, indexes ve RLS

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT table_name, ordinal_position, column_name, data_type,
       udt_name, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

SELECT relation.relname AS table_name,
       relation.relrowsecurity AS rls_enabled,
       relation.relforcerowsecurity AS rls_forced
FROM pg_catalog.pg_class AS relation
JOIN pg_catalog.pg_namespace AS namespace
  ON namespace.oid = relation.relnamespace
WHERE namespace.nspname = 'public'
  AND relation.relkind IN ('r', 'p')
ORDER BY relation.relname;

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
ORDER BY table_name, constraint_name;

SELECT schemaname, tablename, indexname, indexdef
FROM pg_catalog.pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

### Policies, grants, functions/RPC ve triggers

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd,
       qual, with_check
FROM pg_catalog.pg_policies
WHERE schemaname IN ('public', 'storage')
ORDER BY schemaname, tablename, policyname;

SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema IN ('public', 'storage')
  AND grantee IN ('anon', 'authenticated')
ORDER BY table_schema, table_name, grantee, privilege_type;

SELECT grantee, table_schema, table_name, column_name, privilege_type
FROM information_schema.role_column_grants
WHERE table_schema = 'public'
  AND grantee IN ('anon', 'authenticated')
ORDER BY table_name, grantee, column_name, privilege_type;

SELECT namespace.nspname AS function_schema,
       procedure.proname AS function_name,
       pg_catalog.pg_get_function_identity_arguments(procedure.oid) AS arguments,
       procedure.prosecdef AS security_definer,
       procedure.provolatile AS volatility,
       procedure.proacl AS acl,
       pg_catalog.pg_get_functiondef(procedure.oid) AS definition
FROM pg_catalog.pg_proc AS procedure
JOIN pg_catalog.pg_namespace AS namespace
  ON namespace.oid = procedure.pronamespace
WHERE namespace.nspname = 'public'
ORDER BY procedure.proname, arguments;

SELECT namespace.nspname AS table_schema,
       relation.relname AS table_name,
       trigger_row.tgname AS trigger_name,
       pg_catalog.pg_get_triggerdef(trigger_row.oid, true) AS definition
FROM pg_catalog.pg_trigger AS trigger_row
JOIN pg_catalog.pg_class AS relation
  ON relation.oid = trigger_row.tgrelid
JOIN pg_catalog.pg_namespace AS namespace
  ON namespace.oid = relation.relnamespace
WHERE NOT trigger_row.tgisinternal
  AND namespace.nspname IN ('auth', 'public', 'storage')
ORDER BY namespace.nspname, relation.relname, trigger_row.tgname;
```

Function definitions ve ACL'ler güvenlik kanıtıdır; rapor yetkili artefact deposunda
tutulur. Response içinde credential/token görülürse yayınlanmaz.

### Storage, Realtime ve managed prerequisites

```sql
SELECT extname, extversion
FROM pg_catalog.pg_extension
ORDER BY extname;

SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
ORDER BY id;

SELECT bucket_id, count(*)::bigint AS object_count,
       coalesce(sum((metadata ->> 'size')::bigint), 0) AS metadata_bytes
FROM storage.objects
GROUP BY bucket_id
ORDER BY bucket_id;

SELECT pubname, puballtables, pubinsert, pubupdate, pubdelete, pubtruncate
FROM pg_catalog.pg_publication
ORDER BY pubname;

SELECT pubname, schemaname, tablename
FROM pg_catalog.pg_publication_tables
WHERE pubname = 'supabase_realtime'
ORDER BY schemaname, tablename;
```

`metadata->>'size'` mevcut satırlarda numeric değilse byte toplamı sorgusu çıkarılır;
object count sorgusu yine çalıştırılır. Storage object içerikleri bu SQL ile okunmaz.

### Exact row count ve legacy/data-impact inventory

Önce table/column envanteri alınır. Sonra yalnız varlığı doğrulanmış tablolar için
aşağıdaki SELECT'ler çalıştırılır:

```sql
SELECT 'profiles' AS table_name, count(*)::bigint AS row_count FROM public.profiles
UNION ALL SELECT 'legal_consents', count(*) FROM public.legal_consents
UNION ALL SELECT 'categories', count(*) FROM public.categories
UNION ALL SELECT 'brands', count(*) FROM public.brands
UNION ALL SELECT 'products', count(*) FROM public.products
UNION ALL SELECT 'addresses', count(*) FROM public.addresses
UNION ALL SELECT 'customer_saved_locations', count(*) FROM public.customer_saved_locations
UNION ALL SELECT 'wishlist', count(*) FROM public.wishlist
UNION ALL SELECT 'orders', count(*) FROM public.orders
UNION ALL SELECT 'order_items', count(*) FROM public.order_items
UNION ALL SELECT 'reviews', count(*) FROM public.reviews
UNION ALL SELECT 'banners', count(*) FROM public.banners
UNION ALL SELECT 'chat_messages', count(*) FROM public.chat_messages
UNION ALL SELECT 'notifications', count(*) FROM public.notifications
UNION ALL SELECT 'shops', count(*) FROM public.shops
UNION ALL SELECT 'shop_products', count(*) FROM public.shop_products
UNION ALL SELECT 'carts', count(*) FROM public.carts
UNION ALL SELECT 'cart_items_v2', count(*) FROM public.cart_items_v2
UNION ALL SELECT 'qr_sessions', count(*) FROM public.qr_sessions
UNION ALL SELECT 'qr_session_items', count(*) FROM public.qr_session_items
UNION ALL SELECT 'verified_transactions', count(*) FROM public.verified_transactions
UNION ALL SELECT 'verified_transaction_items', count(*) FROM public.verified_transaction_items
UNION ALL SELECT 'shop_ratings', count(*) FROM public.shop_ratings
ORDER BY table_name;

SELECT status, payment_status, count(*)::bigint
FROM public.orders
GROUP BY status, payment_status
ORDER BY status, payment_status;

SELECT count(*)::bigint AS order_item_count,
       count(*) FILTER (WHERE product_id IS NULL)::bigint AS null_product_count
FROM public.order_items;

SELECT count(*)::bigint AS review_count,
       count(*) FILTER (WHERE is_verified_purchase)::bigint AS claimed_verified,
       count(*) FILTER (WHERE coalesce(array_length(images, 1), 0) > 0)::bigint
         AS reviews_with_images
FROM public.reviews;

SELECT count(*)::bigint AS product_count,
       count(*) FILTER (WHERE rating <> 0 OR reviews_count <> 0)::bigint
         AS products_with_cached_review_summary
FROM public.products;
```

0009 kolonları mevcutsa ayrıca:

```sql
SELECT count(*)::bigint AS qr_item_count,
       count(*) FILTER (WHERE product_id IS NULL)::bigint AS historical_null_product
FROM public.qr_session_items;

SELECT count(*)::bigint AS verified_item_count,
       count(*) FILTER (WHERE product_id IS NULL)::bigint AS historical_null_product
FROM public.verified_transaction_items;

SELECT count(*)::bigint AS review_count,
       count(*) FILTER (WHERE verified_transaction_item_id IS NOT NULL)::bigint
         AS evidence_backed,
       count(*) FILTER (
         WHERE is_verified_purchase
           AND verified_transaction_item_id IS NULL
       )::bigint AS invalid_verified_flag
FROM public.reviews;
```

0009 henüz yoksa son blok çalıştırılmaz. Pre-0009 impact raporu; mevcut review sayısı,
claimed verified sayısı ve cached product summary sayısını en azından içerir.

## Backup ve rollback minimumu

1. Production plan/backup özelliği ve en son restorable point, Dashboard veya
   Management API GET ile doğrulanır. PITR varmış gibi varsayılmaz.
2. Kabul edilen RPO/RTO, backup zamanı, restore sahibi ve incident iletişim zinciri
   change kaydında yazılı olur.
3. Native backup/PITR mevcutsa restore edilebilirliği doğrulanır. Uygun özellik yoksa
   schema ve data için şifreli logical dump alınır; dump kapsamındaki managed-schema,
   data ve role exclusions açıkça kaydedilir.
4. Supabase database backup'ı Storage object blob'larını kapsamadığından üç aktif ve
   varsa legacy bucket için ayrı object inventory/backup/retention kanıtı hazırlanır.
5. Mümkün ve desteklenen planda isolated restore/duplicate project drill yapılır.
   Bu özellik yoksa logical restore, production olmayan onaylı PostgreSQL/Supabase
   hedefinde denenir. Auth, Storage, Realtime ve config'in ayrıca kurulacağı unutulmaz.
6. Backup doğrulanmadan, restore yolu denenmeden veya kabul edilen RPO sağlanmadan
   migration apply yapılmaz.

### Wave 10 dar kapsamlı empty-bootstrap istisnası

Genel backup/restore kuralı korunur. Product owner yalnız fresh/empty Production'ın ilk
canonical `0001→0009` bootstrap'ı için native backup/PITR olmadan ilerleme riskini
kabul etmiştir. Güvenli forward-fix mümkün değilse boş projenin yeniden oluşturulması
kabul edilen recovery yoludur; süre garantisi yoktur. İstisna apply öncesi ledger,
public application table, Auth user ve Storage bucket/object sayılarının tekrar `0`
olmasına bağlıdır. Herhangi bir gerçek veri varsa istisna geçersizdir ve **STOP**.
Gelecekteki veri içeren Production migration'larına otomatik yetki vermez.

### Failure ve partial apply davranışı

- Her migration kendi transaction'ında atomiktir; `db push` boyunca önceki migration
  commit olmuş olabilir. “Push fail” bütün zincirin geri alındığı anlamına gelmez.
- Hata halinde maintenance/write freeze korunur; ledger ve actual schema yalnız
  read-only sorgularla yeniden envanterlenir.
- `migration repair`, `migration down`, remote reset veya manuel DROP otomatik rollback
  değildir ve incident anında doğaçlanmaz.
- Hata dosyanın transaction'ı içindeyse o dosya rollback olur. Önceki commit'ler için
  seçenek yalnız onaylı forward fix/reconciliation veya doğrulanmış backup restore'dur.
- Restore Production downtime yaratabilir; bu süre Supabase proje/veri boyutuna göre
  değişir ve önceden ölçülmeden süre garantisi verilmez.

### Maintenance/freeze kararı

- Route F ve henüz erişime açılmamış proje: client trafiği kapalı tutulur; ayrıca veri
  freeze mekanizması gerekmeyebilir.
- Route C/L ve herhangi bir gerçek trafik: inventory snapshot, backup, apply ve
  postflight boyunca Auth signup, catalog/shop/cart/QR/review/Storage write'ları
  ingress/deployment katmanında durdurulmalıdır.
- Repoda feature flag/maintenance infrastructure bulunmadığından otomatik freeze varmış
  gibi kabul edilmez. Güvenli write freeze sağlanamıyorsa **STOP**.
- Validation window; migration postflight, Auth acceptance ve tam smoke PASS olmadan
  kapatılmaz. Süre release sahibi tarafından veri hacmi ve gözlemlenebilirliğe göre
  önceden tanımlanır.

## Cutover phases

### Phase A — Read-only inventory

**Giriş şartı:** Yetkili read-only erişim; Production ref/name için release kaydı;
credential'ların secret manager üzerinden sağlanması.

**İşlem:** Management API GET + read-only SQL pack + `migration list --linked`; exact
schema/data/Auth/Storage/Realtime envanteri ve redacted evidence bundle.

**PASS:** Project ref/name iki bağımsız kanıtla aynı; topology F/C/L sınıflanmış;
ledger, 23 canonical/legacy tablo farkı, columns/RLS/policy/function/grant/trigger,
row counts ve 0009 impact sayıları eksiksiz.

**STOP:** Ref şüphesi; yetersiz catalog görünürlüğü; ledger/schema uyuşmazlığı
açıklanamıyor; herhangi bir araç write istiyor.

### Phase B — Backup / preflight

**Giriş şartı:** Phase A PASS; veri sahibi ve release/incident sahipleri atanmış.

**İşlem:** Available native backup/PITR envanteri; logical schema+data dump gerekiyorsa
encrypted artifact; Storage object koruma kanıtı; restore drill; RPO/RTO ve freeze.

**PASS:** Restorable backup zamanı ve restore adımı kanıtlı; Storage blobs için ayrı
koruma planı; freeze yöntemi ve change window onaylı.

**STOP:** Backup/PITR varsayımsal; dump kapsamı bilinmiyor; restore denenmemiş; Storage
objects korunmuyor; freeze uygulanamıyor.

**Wave 10 current evidence — PASS WITH OWNER EXCEPTION:** Production Free plan
scheduled backup/PITR/restorable point sağlamaz. Fresh snapshot'ta korunacak
application row/Storage object yoktur. Product owner, yalnız bu ilk empty bootstrap
için no-backup riskini ve forward-fix mümkün değilse empty-project recreation yolunu
kabul etti. Phase D öncesi exact zero-state recheck + imzalı change window zorunludur;
count değişmişse istisna düşer ve işlem durur.

### Phase C — Migration dry comparison

**Giriş şartı:** A+B PASS; exact commit/hash manifesti; Production-data clone veya
eşdeğer güvenli test hedefi.

**İşlem:** `db push --linked --dry-run`; yardımcı `db diff`; clone üzerinde canonical
apply, SQL timing/lock gözlemi, 0009 review/aggregate/bucket impact raporu ve route
kararı. CLI diff'in publication/bucket sınırlaması catalog sorgularıyla tamamlanır.

**PASS:** Route F veya exact C; pending dosya listesi beklenen; clone apply/postflight
geçti; data delta onaylandı; L ise ayrı reconciliation planı onaylandı ve yeniden dry
run edildi.

**STOP:** 0001 existing schema'ya çarpacak; unknown migration; hash mismatch; 0009 data
etkisi onaysız; timeout/lock riski window'a sığmıyor; bucket visibility/policy riski.

**Wave 10 current evidence — LOCAL + LINKED PASS:** Credential-free remote conflict
precheck canonical table/trigger/bucket/policy conflict'i bulmadı. PGlite 0.5.5
safe-equivalent clean-room replay 9/9 migration, final 23 table, üç active bucket ve
QR/review/Storage behavior ile PASS verdi. Supabase CLI `2.114.0`, exact Production
ref `mefhfvrgkwciubeajjeb` üzerinde `db push --linked --dry-run --skip-vault` ile
yalnız canonical 0001→0009 sırasını gösterdi. Duplicate/skip/out-of-order/remote-only
ve unexpected local migration yoktur. Before/after ledger, public/Auth/Storage/
Realtime/canonical RPC sayıları değişmedi. Automatic-RLS aktif; Data API enabled ve
auto-expose OFF'tur. Local link artefaktları secret scan sonrası kaldırıldı. Production
remote write yapılmadı.

`FIRST_BOOTSTRAP_NO_BACKUP_RISK_ACCEPTED: YES`. Linked dry-run ve owner kararıyla
tarihsel D0 apply gate'i açılmış, Phase D1'de JIT recheck sonrası kullanılıp
tamamlanmıştır.

### Phase D — Canonical migration apply

**Giriş şartı:** A–C PASS; backup restore-ready veya yukarıdaki dar kapsamlı empty-first-
bootstrap owner istisnası geçerli; zero-state recheck PASS; freeze/change window aktif;
tek migration operator; GO/NO-GO checklist pre-apply bölümü imzalı.

**İşlem:** Exact branch/commit'te son `migration list` ve `db push --linked --dry-run`
kanıtı alınır. Yetkili operator yalnız onaylanan pending canonical dosyalar için
`supabase db push --linked` çalıştırır. Seed/roles/`--include-all` eklenmez.

**PASS:** Her expected migration success; ledger ve actual schema aynı son canonical
seviyede; error/timeout yok.

**STOP:** Beklenmeyen dosya; project ref değişimi; lock/statement timeout; SQL error;
partial apply; ledger/schema farkı. Freeze korunur ve failure prosedürü uygulanır.

**Wave 10 Phase D1 evidence — PASS:** `2026-08-16 18:56:34 UTC` JIT snapshot'ında
ledger relation yok; public/Auth/Storage/Realtime business state sıfır ve exact
Production ref doğrulandı. Manifest 9/9 ve final linked dry-run exact 0001→0009 idi.
CLI `2.114.0`, `db push --linked --skip-vault --yes` ile yalnız bu dokuz migration'ı
sırasıyla uyguladı. Seed/roles/`--include-all`, manual SQL, repair ve retry yoktur.
Final remote ledger local ile exact 9/9 eşleşir.

### Phase E — RLS/RPC/Storage postflight

**Giriş şartı:** D PASS; migration session logu ve final ledger mevcut.

**İşlem:** Read-only SQL pack tekrar; 23 tablo/23 RLS, final 52 public policy adı,
grants, function definitions/search paths, triggers, Realtime publication, üç bucket
ve Storage policy/path contract karşılaştırması. Production-data clone'da geçmiş olan
negatif/pozitif RLS/RPC matrisi evidence bundle'a bağlanır. Production'da DML gerektiren
davranış testleri bu phase'de başlatılmaz; yetkili disposable principals ile Phase H'de
çalıştırılır.

**PASS:** Exact canonical schema ve grant/policy/function/trigger tanımları; clone
davranış kanıtı güncel; review RPC-only, direct notification INSERT denial ve client
Storage mutation/list yasağı catalog düzeyinde exact; Realtime üyeliği exact.

**STOP:** RLS kapalı tablo; extra/permissive policy; wrong grant/search path; function
signature drift; unexpected publication member; bucket public/limit/MIME veya object
policy farkı.

**Wave 10 Phase E metadata evidence — PASS:** 23/23 public table ve RLS, final 52/52
policy, 28/28 app function, 25/25 canonical trigger ve 15/15 kritik RPC signature
eşleşti. Missing/extra policy, broad anon write, direct notification INSERT, direct
review mutation, unexpected function execute ve unsafe SECURITY DEFINER search path
count'ları sıfırdır. Storage üç exact active bucket'ı public 8/2/5 MiB ve exact
JPEG/PNG/WebP allowlist ile içerir; deferred bucket, Storage object ve Storage policy
yoktur. Realtime yalnız chat/notifications; Auth user/identity/session ve bütün
application row'ları sıfırdır. Fixture/DML behavior testi bu phase'de yapılmadı.

### Phase F — Auth/SMTP

**Giriş şartı:** E PASS; Auth owner ve verified sender/redirect listesi onaylı.

**İşlem:** Bu plan dışındaki yetkili Auth owner Production email confirmation, custom
SMTP, Site URL, mobile/web redirect, provider ve rate-limit ayarlarını uygular; signup,
delivery, confirm, resend, expiry ve recovery inbox acceptance yapar.

**PASS:** Gerçek inbox delivery ve confirmation/recovery; exact redirect; enumeration
ve rate-limit davranışı; secret loglanmıyor.

**STOP:** Default/test SMTP; delivery yok; redirect wildcard/wrong environment;
email-confirm kararı belirsiz; provider key eksik.

### Phase G — Client production config

**Giriş şartı:** E+F PASS; doğru Production URL ve yalnız client-safe publishable/anon
key güvenli CI/release store'da.

**İşlem:** `main_production.dart` artifact; no fallback; secret scan; artifact hash;
Production ref ile endpoint host eşleşmesi. Wave 8'de standart Web release build ek
icon workaround'u olmadan PASS olmuştur; gerçek Production config/signing ile artifact
üretimi bu phase'de yeniden kanıtlanır.

**PASS:** Release artifact gerçek Production client-safe config ile açılır; secret/
service-role yok; Development endpoint yok; signing/app identity ve build gate PASS.

**STOP:** Missing/dummy key; wrong project; secret exposure; default build/signing
blocker; environment fallback.

### Phase H — Controlled production smoke

**Giriş şartı:** A–G PASS; onaylı disposable User A/User B/merchant; prefix, cleanup ve
incident owner; gerçek müşteri verisine dokunmama kuralı.

**İşlem:** `PRODUCTION_SMOKE_CHECKLIST.md` tam matrisi; Auth, guest discovery, CartV2,
chat/notifications, fiziksel iki cihaz QR, verified purchase/rating/review, account
deletion ve Storage. Test write'ları yalnız bu phase'in onaylı kapsamındadır.

**PASS:** Bütün kritik satırlar PASS; RLS isolation/reconnect/dedup; residual cleanup;
secret/PII içermeyen kanıt.

**STOP:** Herhangi bir cross-user erişim, duplicate verified proof, wrong recipient,
Auth/SMTP failure, QR physical failure, Storage policy leak, cleanup residual veya
critical crash.

### Phase I — Release go/no-go

**Giriş şartı:** A–H evidence bundle ve tüm zorunlu sahip imzaları.

**İşlem:** Tek sayfalık Go/No-Go checklist; open incident/deferred ayrımı; rollback
owner; observation window; artifact/migration/smoke evidence linkleri.

**PASS:** Bütün zorunlu gate'ler PASS, blocker yok; yalnız belgelenmiş non-blocking
deferred kalemler açık; release owner açık GO verir.

**STOP:** Exact ref, backup, migration inventory/apply, RLS, RPC, Storage, Auth/email,
client config veya smoke maddelerinden biri PASS değilse otomatik **NO-GO**.

## Evidence bundle ve sorumlular

Cutover kaydı en az şunları içermeli:

- Production project ref/name kanıtı, fakat token/key yok;
- base/commit ve dokuz SHA-256;
- Phase A pre-inventory ve Phase E post-inventory diff'i;
- backup/restore point, RPO/RTO ve Storage object koruma kanıtı;
- dry-run ve gerçek migration output'u;
- 0009 before/after aggregate sayıları;
- RLS/RPC/Storage/Realtime/Auth test sonuçları;
- artifact hash ve redacted config attestation;
- smoke sonucu, residual cleanup ve GO/NO-GO imzaları.

Roller ayrı atanır: release commander, migration operator, database reviewer, Auth/
SMTP owner, client artifact owner, smoke lead ve incident/rollback owner. Tek kişinin
aynı anda apply ve bağımsız postflight onayı vermemesi tercih edilir.

## Resmi araç/backup referansları

- [Supabase Database Backups](https://supabase.com/docs/guides/platform/backups)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli/v0/supabase-migration)
- [Supabase Database Migrations](https://supabase.com/docs/guides/deployment/database-migrations)
- [Supabase Management API](https://supabase.com/docs/reference/api/getting-started)
- [Supabase Production Checklist](https://supabase.com/docs/guides/deployment/going-into-prod)

Önemli resmi sınırlamalar: database backup Storage object blob'larını içermez;
PITR plan/add-on durumuna bağlıdır; `db dump` varsayılanı data/custom role ve managed
auth/storage schema'yı kapsamaz; CLI schema diff publication ve Storage bucket
değişikliklerini kaçırabilir; restore sırasında downtime oluşabilir.
