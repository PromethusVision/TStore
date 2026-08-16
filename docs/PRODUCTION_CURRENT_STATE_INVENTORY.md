# Production Current State Inventory

**Inventory tarihi:** 2026-08-16

**Kaynak branch/base:** `agent1/w10-production-readonly-verification` /
`origin/main@71c7ed6c2429c92ecf6732b7f5845a716a460263`

**Yetki sınırı:** Kimliği doğrulanmış Production projesinde yalnız Dashboard metadata
okuması ve salt-okunur catalog/count sorguları. Migration, DML, DDL, Auth/SMTP,
Storage, Realtime veya başka bir remote yapılandırma yazması yapılmadı.

`PRODUCTION_PROJECT_IDENTIFIED: YES`

`PRODUCTION_INVENTORY_READY: YES`

`PRODUCTION_TOPOLOGY: F — FRESH/EMPTY`

`MIGRATION_ARTIFACT_INTEGRITY: PASS`

## Yönetici özeti

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

## Security and mutation attestation

- Production remote reads: **YES**, yalnız bu belgede tanımlanan authenticated
  metadata, non-secret config ve salt-okunur inventory.
- Production remote writes: **NO**.
- Production modified: **NO**.
- Development touched: **NO**.
- Unknown/legacy project touched: **NO**.
- Migration apply/dry-run/repair/push/pull/dump/reset: **NO**.
- Auth/SMTP, RLS/policy, Storage, Realtime veya schema config değişikliği: **NO**.
- User/fixture/bucket/key/token oluşturma: **NO**.
- Secret/service-role key read/log/commit: **NO**.

## Gate sonucu ve devam

`PRODUCTION_PROJECT_VERIFIED: YES`

`PRODUCTION_FRESH_BASELINE: YES`

`READY_FOR_CANONICAL_MIGRATION: YES`

Buradaki `READY`, topology ve artifact açısından canonical 0001→0009 yoluna uygunluğu
ifade eder. **Migration apply bu görevde yapılmadı ve yetkilendirilmedi.** Sonraki
zorunlu adım cutover planındaki Phase B backup/restore/freeze ve Phase C güvenli dry
comparison'dır. Phase D apply ancak bu kapılar ve ayrı change approval sonrası
yürütülebilir. Production Auth Site URL/redirect/SMTP ile client config ve smoke
kapıları commercial release için ayrıca açıktır.

## Wave 10 Phase B/C pre-migration refresh

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

Ayrıntılı evidence ve restore/failure kararı:
[Production Pre-Migration Baseline](PRODUCTION_PRE_MIGRATION_BASELINE.md).

`BACKUP_ROLLBACK_PLAN_READY: NO`

`DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT`

`READY_FOR_PRODUCTION_MIGRATION_APPLY: NO`

Phase A'daki `READY_FOR_CANONICAL_MIGRATION: YES`, yalnız fresh topology'nin doğru
canonical yolunun 0001→0009 olduğunu belirtir. Free-plan backup/restore, accepted
RPO/RTO, owner, restore drill ve enforced freeze blocker'ları nedeniyle Phase D apply
henüz yetkili veya hazır değildir.
