# Production Current State Inventory

**Inventory tarihi:** 2026-08-16 — Phase E1 read-only client verification güncel

**Kaynak branch/base:** `agent1/w10-production-client-wiring` /
`origin/main@eda5759ff2b19ea02cb38db2d50d5df69f887685`

**Yetki sınırı:** Phase D1'deki yetkili canonical `0001→0009` initial bootstrap sonrası
Phase E1 yalnız gerçek publishable key ile anonymous read-only client bağlantısı ve
yerel release build kanıtıdır. Phase E1'de remote write, fixture, Auth/SMTP config,
Storage object veya migration işlemi yapılmadı.

`PRODUCTION_PROJECT_IDENTIFIED: YES`

`PRODUCTION_INVENTORY_READY: YES`

`PRODUCTION_TOPOLOGY: CANONICAL 0001→0009 — ZERO BUSINESS DATA`

`MIGRATION_ARTIFACT_INTEGRITY: PASS`

`PRODUCTION_CANONICAL_MIGRATION: PASS`

`PRODUCTION_POSTFLIGHT: PASS`

`PRODUCTION_SCHEMA_READY: YES`

`PRODUCTION_CLIENT_CONFIGURATION_COMPLETE: NO`

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / PLATFORM WIRING PENDING`

`PHASE_E1_PRODUCTION_CLIENT_WIRING: PASS`

`PRODUCTION_CLIENT_SAFE_KEY_PRESENT: YES`

`PRODUCTION_RUNTIME_CONFIG: PASS`

`PRODUCTION_CLIENT_CONNECTION_READONLY: PASS`

`READY_FOR_PHASE_E_INTEGRATION: YES`

## Phase E1 authoritative client connection state

Authenticated Supabase CLI exact Production ref'inde bir client-safe publishable key
bulunduğunu doğruladı. `--reveal` kullanılmadı; değer yalnız süreç belleğinde normal
anonymous Flutter/Supabase client'a verildi ve source/log/belgeye yazılmadı.
Service-role, `sb_secret_*` veya server credential kullanılmadı.

| Phase E1 client kontrolü | Production sonucu |
| --- | --- |
| Entrypoint/environment | `lib/main_production.dart` / `production`; Development fallback yok |
| Runtime URL/ref | Exact `https://mefhfvrgkwciubeajjeb.supabase.co`; ref-host PASS |
| Auth initialization | Anonymous client initialized; current user/session yok |
| `categories` | Request success; empty list |
| `products` | Request success; empty list |
| `shops` | Request success; empty list |
| `banners` | Request success; empty list |
| Storage client read | Üç active bucket listesi client-visible empty; canonical public URL contract PASS |
| Storage object probe | Üç controlled non-existent path güvenli not-found; upload/mutation yok |
| Standard Web release build | Gerçek URL/publishable key, Production target, icon workaround yok; PASS |

Phase D1 catalog sayımı Storage object `0` olduğunu authoritative metadata ile
doğrulamıştı; E1 normal client sonucu bu zero-state ve no-client-list policy contract'ı
ile uyumludur. Production'da Auth user, business row veya Storage object oluşturulmadı.
Geçici build artifact'ı credential kalıntısı bırakmamak için doğrulama sonrasında
kaldırıldı.

Bu sonuç yalnız real runtime wiring/read-only connection gate'ini kapatır. Remote Site
URL hâlâ localhost, redirect allowlist boş ve custom SMTP disabled olduğundan Auth
acceptance; ayrıca platform signing ve controlled full Production smoke açık kalır.
`PRODUCTION_CLIENT_CONFIGURATION_COMPLETE: NO` bu daha geniş release anlamında
korunur.

## Phase D1 authoritative schema state

Product owner'ın yalnız boş ilk bootstrap için verdiği açık risk istisnası kullanıldı.
Apply öncesi `2026-08-16 18:56:34 UTC` JIT snapshot'ında migration ledger relation
`NULL`; public application table, Auth user/identity/session, Storage bucket/object/
policy ve Realtime member sayıları `0` idi. CLI `2.114.0`, authenticated project list
ve linked ref ile exact `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` /
`eu-central-1` hedefini doğruladı; Development `tnipyxnvhgelwdpykyez` dışlandı.

Final `db push --linked --dry-run --skip-vault` yalnız canonical `0001→0009` sırasını
gösterdi. Ardından resmi linked `db push --linked --skip-vault --yes` aynı dokuz
migration'ı tek CLI oturumunda sırasıyla uyguladı. Seed, roles, `--include-all`,
migration repair veya manuel SQL kullanılmadı.

| Phase D1 final kontrol | Production sonucu |
| --- | --- |
| Migration ledger | Exact 9 local/remote version: `20260812000100` → `20260815000900` |
| Public application tables | 23/23; eksik canonical tablo 0 |
| RLS | 23/23 enabled; disabled 0 |
| Public policies | Exact final set 52/52; eksik/extra 0 |
| Public app functions | 28/28 canonical isim; eksik 0 |
| Canonical triggers | 25/25; eksik 0 |
| Critical RPC signatures | 15/15; QR, rating/review, account/chat/notification eksik 0 |
| Policy/grant security | Broad anon write, notification INSERT, direct review mutation ve unexpected RPC execute 0 |
| SECURITY DEFINER | Unsafe/missing fixed `search_path` 0 |
| Active Storage buckets | Exact `product-images`, `category-images`, `banner-images` |
| Bucket contract | Public; 8/2/5 MiB; exact JPEG/PNG/WebP; mismatch 0 |
| Deferred buckets | `avatars`, `review-images`, `brand-logos` count 0 |
| Storage objects / policies | 0 / 0 |
| Realtime | Yalnız `public.chat_messages`, `public.notifications`; eksik/extra 0 |
| Auth users / identities / sessions | 0 / 0 / 0 |
| 23 application table total rows | 0 |

Durable QR/review `product_id` ve evidence kolonları, kritik unique constraint'ler ve
immutable evidence trigger'ları eksiksizdir. Auth URL config
`http://localhost:3000`, redirect listesi boş ve custom SMTP disabled olarak kaldı;
Save işlemi yapılmadı. Bu yüzden canonical schema hazırdır fakat gerçek Production Auth
URL/SMTP, client-safe config, signing ve smoke tamamlanmadan Production client config
ve commercial release hazır değildir.

## Historical Phase A/D0 pre-apply inventory

Aşağıdaki bölümler apply öncesi fresh/empty baseline'ın tarihsel kanıtıdır. Güncel
authoritative state yukarıdaki Phase D1 tablosudur.

Product-owner tarafından bildirilen hedef, kimliği doğrulanmış Supabase Dashboard
oturumunda iki bağımsız görünümle doğrulandı. Organizasyon proje listesi ve Production
project overview/general settings aynı adı, ref'i, URL hostunu ve bölgeyi gösteriyor.
Development ayrı proje olarak görüldü ve sorgu hedefi yapılmadı.

Production migration açısından temizdir: Dashboard `No migrations` gösteriyor ve
`supabase_migrations.schema_migrations` relation'ı yoktur. `public` şemasında uygulama
tablosu, view, index, constraint, table trigger veya policy yoktur. Auth user, identity
ve session sayıları sıfırdır; Storage bucket/object yoktur; Realtime publication'ında
uygulama tablosu yoktur. Bu kanıtlar cutover planındaki **F — Fresh/empty** yolunu
destekler.

Canonical 0001–0009 zinciri bu fresh hedef için uygun forward migration yoludur.
Bu sonuç migration apply yetkisi değildir: gerçek apply öncesinde cutover planındaki
Phase B backup/restore/freeze ve Phase C dry comparison kapıları ayrıca geçmelidir.

## Authenticated project identity

| Alan | Doğrulanmış değer | Kanıt |
| --- | --- | --- |
| Organizasyon | `Musaki bilisim` | Authenticated Dashboard project list |
| Project name | `EsnaftaVar Production` | Project list + overview/general settings |
| Project ref | `mefhfvrgkwciubeajjeb` | Project link + Project ID |
| Project URL | `https://mefhfvrgkwciubeajjeb.supabase.co` | Project overview |
| URL/ref eşleşmesi | Host prefix exact project ref ile aynı | **PASS** |
| Region | `Central EU (Frankfurt)` / `eu-central-1` | Overview + general settings |
| Development exclusion | `EsnaftaVar Development`; ref `tnipyxnvhgelwdpykyez` | Ayrı project card; **Production değildir** |

Production URL/ref metadata dışında credential okunmadı. API Keys ekranında
publishable/client-safe key alanının varlığı doğrulandı; key değeri kopyalanmadı,
görüntülenmedi, loglanmadı veya belgeye yazılmadı. Secret/service-role key değerleri
incelenmedi.

## Read-only evidence method

- Identity doğrulaması remote query öncesinde tamamlandı.
- Dashboard project list, overview, general settings, Auth, Data API ve API key metadata
  ekranları yalnız görüntülendi; hiçbir `Save`/mutation işlemi kullanılmadı.
- Database inventory saf `SELECT` catalog sorgularıyla alındı. Sorgular kaydedilmedi;
  SQL Editor'daki geçici metinler sonuç alındıktan sonra `Discard changes` ile kapatıldı.
- `INSERT`, `UPDATE`, `DELETE`, `CREATE`, `ALTER`, `DROP`, migration CLI apply/repair,
  kullanıcı/fixture veya bucket işlemi çalıştırılmadı.

## Migration ledger ve public schema

| Kontrol | Production sonucu | Canonical fark / sınıf |
| --- | --- | --- |
| Dashboard migration history | `No migrations` | F — fresh |
| `supabase_migrations.schema_migrations` | Relation yok (`NULL`) | 0001–0009'un hiçbiri kayıtlı değil |
| Public tables/partitioned tables | 0 | Canonical 23 tablo eksik; `SAFE FORWARD MIGRATION CANDIDATE` |
| Public views/materialized views/foreign tables | 0 | Beklenmeyen user view yok; `MATCH` fresh baseline |
| Public columns/constraints/indexes | 0 / 0 / 0 | Uygulama nesnesi yok |
| Public table triggers | 0 | Uygulama trigger'ı yok |
| Public table policies | 0 | Policy uygulanacak user table yok |
| Public table grants | 0 | Uygulama tablosunda broad grant yok |
| Public functions | Yalnız platform baseline `rls_auto_enable()` | Automatic-RLS mekanizması; canonical app RPC'si değil |

Installed extensions yalnız fresh Supabase platform baseline'ıdır:
`pg_stat_statements`, `pgcrypto`, `plpgsql`, `supabase_vault` ve `uuid-ossp`.
Canonical uygulamaya ait beklenmeyen tablo, view veya RPC bulunmadı.

## RLS, policies, grants ve Data API

Automatic RLS durumu read-only catalog ile gözlemlendi:

- enabled event trigger `ensure_rls`, `CREATE TABLE`, `CREATE TABLE AS` ve
  `SELECT INTO` sonrasında çalışır;
- `public.rls_auto_enable()` `SECURITY DEFINER` ve sabit
  `search_path = pg_catalog` ile yalnız `public` içindeki yeni tablolar için RLS'i
  enable eder;
- mevcut public user table olmadığı için table-level RLS/policy sayısı sıfırdır;
- Data API function exposure `0 of 1`; automatic-RLS hook Data API'ye expose değildir.

`anon`, `authenticated` ve `service_role` rolleri `public`/`storage` şemalarında
`USAGE` sahibidir, `CREATE` sahibi değildir. Bu roller database'e bağlanabilir ve
temporary nesne kullanabilir; database `CREATE` yetkileri yoktur. Uygulama tablosu
olmadığı için anon/auth table veya column grant'i yoktur.

Catalog ACL, platformun automatic-RLS event-trigger function'ı
`rls_auto_enable()` için `PUBLIC` ve `postgres` `EXECUTE` grant'i gösteriyor. Bu
canonical uygulama RPC'si değildir; sabit `pg_catalog` search path kullanır ve Data
API function exposure `0 of 1` olduğu için API'ye expose değildir. Yine de bu platform
baseline grant'i postflight security inventory'de yeniden karşılaştırılmalıdır.

Data API installed ve enabled durumdadır. `graphql_public` ile `public` şemaları
seçilidir; expose edilecek tablo yoktur ve public function exposure sıfırdır.
`Automatically expose new tables` **OFF** durumundadır. Böylece yeni tabloların
Data API rollerine otomatik grant edilmemesi yönündeki güvenli başlangıç ayarıyla
uyumludur. Extra search path `public, extensions`; max rows `1000`.

## Storage ve Realtime

| Alan | Read-only sonuç | Canonical fark / sınıf |
| --- | --- | --- |
| Storage buckets | 0 | 0009'un üç active bucket'ı henüz yok; `SAFE FORWARD MIGRATION CANDIDATE` |
| Storage objects | 0 | Taşınacak/etkilenecek object yok |
| Storage bucket/object policies | 0 | Uygulama Storage policy'si yok |
| `supabase_realtime` publication | Var; INSERT/UPDATE/DELETE/TRUNCATE açık, `all_tables = false` | Platform baseline |
| Realtime table membership | 0 | 0007'nin `chat_messages`/`notifications` üyeliği henüz yok; `SAFE FORWARD MIGRATION CANDIDATE` |

Deferred `brand-logos`, `avatars` ve `review-images` bucket'ları da yoktur. Bu görevde
hiçbir bucket veya policy oluşturulmadı.

## Auth non-secret state

| Auth alanı | Production read-only sonucu |
| --- | --- |
| New user signup | Enabled |
| Email provider | Enabled |
| Confirm email | Enabled |
| Phone/provider login | Disabled |
| Social providers | Dashboard'da listelenen provider'ların tümü disabled |
| Custom OAuth/OIDC providers | 0 |
| Anonymous sign-in | Disabled |
| Manual identity linking | Disabled |
| Site URL | `http://localhost:3000` |
| Redirect allowlist | Boş (`No Redirect URLs`) |
| Custom SMTP | Not configured / disabled |

Site URL ve redirect allowlist fresh default durumundadır ve Production client/Auth
cutover'ı için uygun değildir. Bu, fresh canonical migration yolunu engellemez; ancak
Phase F Auth/SMTP ve Phase G client configuration tamamlanmadan commercial release
GO verilemez. SMTP credential veya başka secret okunmadı.

## Application data state

Public application tablosu bulunmadığından canonical domain'lerin tamamı absent ve
uygulama row count'u sıfırdır.

| Domain | Production state |
| --- | --- |
| Profiles/legal consent | Tablolar yok; 0 application row |
| Shops/products/shop_products | Tablolar yok; 0 application row |
| Cart V2 | Tablolar yok; 0 application row |
| QR sessions/items | Tablolar yok; 0 application row |
| Verified transactions/items | Tablolar yok; 0 application row |
| Reviews/product aggregates | Tablolar yok; 0 application row |
| Chat/notifications | Tablolar yok; 0 application row |
| Shop ratings | Tablo yok; 0 application row |
| Legacy orders/order_items | Tablolar yok; 0 application row |

Ek aggregate doğrulama: `auth.users = 0`, `auth.identities = 0`,
`auth.sessions = 0`, `storage.objects = 0`. Kullanıcı, fixture veya session
oluşturulmadı.

## Canonical 0001–0009 comparison

Local canonical chain'in Git/LF SHA-256 manifesti yeniden çalıştırıldı ve
**9/9 PASS** verdi. Canonical contract testi tam **18/18 PASS** verdi; 23 tablo,
23/23 RLS, revoke baseline, SECURITY DEFINER/search-path/ACL, role guard, QR,
Realtime ve üç frozen Storage bucket sözleşmeleri doğrulandı. Migration SQL'leri
değiştirilmedi.

| Canonical sürüm | Production pre-state | Sınıf |
| --- | --- | --- |
| 0001 | Fresh/empty public schema ve Auth user 0 | `SAFE FORWARD MIGRATION CANDIDATE` |
| 0002–0008 | Önkoşul uygulama nesneleri henüz yok; 0001'den sıralı zincir gerekli | `SAFE FORWARD MIGRATION CANDIDATE` yalnız exact order ile |
| 0009 | Historical data ve Storage object yok; active bucket'lar yok | `SAFE FORWARD MIGRATION CANDIDATE` yalnız exact order ile |

0009 özel impact sayıları sıfırdır: `qr_session_items`,
`verified_transaction_items`, `reviews` ve aggregate hedef tabloları yoktur;
historical nullable/legacy review row yoktur; Storage bucket/object yoktur. Bu sonuç
0009'u tek başına uygulama izni vermez; exact 0001→0009 zinciri gereklidir.

## Historical Phase A/D0 security and mutation attestation

- Production remote reads: **YES**, yalnız bu belgede tanımlanan authenticated
  metadata, non-secret config ve salt-okunur inventory.
- Production remote writes: **NO**.
- Production modified: **NO**.
- Development touched: **NO**.
- Unknown/legacy project touched: **NO**.
- Linked CLI dry-run: **YES / PASS**, yalnız exact canonical `0001→0009`; before/after
  Production state aynı.
- Migration apply/repair/push/pull/dump/reset: **NO**.
- Auth/SMTP, RLS/policy, Storage, Realtime veya schema config değişikliği: **NO**.
- User/fixture/bucket/key/token oluşturma: **NO**.
- Secret/service-role key read/log/commit: **NO**.

## Historical Phase A/D0 gate sonucu ve devam

`PRODUCTION_PROJECT_VERIFIED: YES`

`PRODUCTION_FRESH_BASELINE: YES`

`READY_FOR_CANONICAL_MIGRATION: YES`

Buradaki `READY`, topology ve artifact açısından canonical 0001→0009 yoluna uygunluğu
ifade eder. Phase D0 linked dry-run ve owner'ın dar kapsamlı empty-first-bootstrap risk
kararı daha sonra tamamlandı. **Migration apply bu görevde yapılmadı ve
yetkilendirilmedi.** Phase D apply ayrı change task/window, exact zero-state recheck ve
operator/incident owner kaydıyla yürütülebilir. Production Auth Site URL/redirect/SMTP
ile client config ve smoke kapıları commercial release için ayrıca açıktır.

## Wave 10 Phase B/C/D0 pre-migration refresh

2026-08-16 `17:41:47 UTC` salt-okunur snapshot'ında fresh baseline değişmemiştir:
Auth user/identity/session, public application table, Storage bucket/object ve
Realtime publication member sayıları sıfır; migration ledger relation'ı yoktur.
Managed `auth.users`, `storage.buckets`, `storage.objects`, `supabase_realtime` ve
`pgcrypto` prerequisites mevcuttur. Canonical 23 table-name conflict ve existing
non-internal `auth.users` trigger sayısı sıfırdır.

Free plan scheduled backup sağlamaz; PITR ve restore-to-new-project aktif değildir.
Credential-free catalog snapshot boşluğu kanıtlar fakat restorable native point
değildir. Local PGlite safe-equivalent replay exact 0001→0009 zincirinde 9/9 PASS ve
final 23 tablo/üç bucket/QR-review-Storage behavior PASS verdi.

Phase D0 linked CLI dry-run exact Production ref'inde yalnız canonical `0001→0009`
pending sırasını gösterdi. Dry-run öncesi/sonrası ledger/public/Auth/Storage/Realtime/
canonical RPC snapshot'ı değişmedi; remote write `0` ve migration apply `NO`.

Product owner, yalnız bu tamamen boş ilk bootstrap için native backup/PITR olmadan
ilerleme riskini ve güvenli forward-fix mümkün değilse empty-project recreation
yolunu kabul etti. Bu dar istisna apply öncesi zero-state recheck'e bağlıdır; gerçek
kullanıcı/veri görülürse düşer ve sonraki Production migration'larına emsal değildir.

Ayrıntılı evidence ve restore/failure kararı:
[Production Pre-Migration Baseline](PRODUCTION_PRE_MIGRATION_BASELINE.md).

`NATIVE_BACKUP_PITR_AVAILABLE: NO`

`BACKUP_ROLLBACK_PLAN_READY: OWNER EXCEPTION — EMPTY FIRST BOOTSTRAP ONLY`

`DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT + LINKED CLI DRY-RUN`

`HISTORICAL_D0_READY_FOR_PRODUCTION_MIGRATION_APPLY: YES — CONSUMED BY D1`

Bu tarihsel `READY`, Phase D1'de exact ref/hash ve just-in-time zero-state recheck ile
kullanıldı. Canonical migration ve metadata postflight artık PASS'tir. Production Auth,
client config, signing ve controlled smoke kapıları ayrıca açıktır.
