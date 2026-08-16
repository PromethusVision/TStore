# Production Go / No-Go Checklist

Bu sayfa release commander tarafından cutover kaydına kopyalanır. Bütün zorunlu
maddeler PASS değilse GO verilemez. Boş, `N/A` veya “sonra doğrulanacak” bir zorunlu
madde PASS sayılmaz.

## Wave 10 Phase B/C/D0/D1 current evidence

Bu tablo release commander'ın imzalı checklist'inin yerine geçmez; 2026-08-16
pre-migration, apply ve metadata postflight evidence durumunu gösterir.

| Pre-apply gate | Current evidence | Durum |
| --- | --- | --- |
| Exact Production project | `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` / ref-host / Frankfurt doğrulandı | PASS |
| Fresh remote inventory | Ledger yok; public application table/user/bucket/object sayıları 0 | PASS |
| Migration artifacts | Canonical Git/LF SHA-256 manifest 9/9 | PASS |
| Existing data / 0009 impact | Historical application row ve Storage object yok; affected count 0 | PASS |
| Native backup / PITR | Free plan scheduled backup/PITR/restorable point yok; owner yalnız boş ilk bootstrap için riski kabul etti | **ACCEPTED EXCEPTION** |
| Recovery / RPO / RTO | Pre-state business data 0; forward-fix yoksa empty-project recreation kabul edildi; süre garantisi yok | **ACCEPTED EXCEPTION** |
| Storage object protection | Pre-migration object count 0; korunacak blob yok | PASS for current empty snapshot |
| Write freeze | Client yayınlanmadı; apply öncesi JIT ledger/table/Auth/Storage zero-state recheck PASS, yalnız canonical write yapıldı | PASS for D1 |
| Local dry comparison | PGlite safe-equivalent replay 0001→0009, final schema/QR/review/Storage PASS | PASS |
| Linked CLI dry-run | CLI 2.114.0 exact Production ref'e bağlı; `--dry-run --skip-vault` yalnız canonical 0001→0009 gösterdi; before/after remote state aynı | PASS |
| Canonical migration apply | Official linked CLI yalnız 0001→0009 uyguladı; final ledger local/remote 9/9 | PASS |
| Schema / RLS / policy | 23/23 table, 23/23 RLS, 52/52 final policy; missing/extra/disabled 0 | PASS |
| RPC / grant security | 28/28 app function, 25/25 trigger, 15/15 kritik signature; broad/unsafe grant-search-path drift 0 | PASS |
| Storage / Realtime | Exact üç bucket + size/MIME/public; no object/policy/deferred bucket; Realtime exact iki member | PASS |
| Auth / business data | Auth user/identity/session 0; 23 application table total row 0; Auth URL/SMTP config değiştirilmedi | PASS for schema phase |

`NATIVE_BACKUP_PITR_AVAILABLE: NO`

`BACKUP_ROLLBACK_PLAN_READY: OWNER EXCEPTION — EMPTY FIRST BOOTSTRAP ONLY`

`DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT + LINKED CLI DRY-RUN`

`PHASE_D0_PRODUCTION_STATE_UNCHANGED: YES`

`FIRST_BOOTSTRAP_NO_BACKUP_RISK_ACCEPTED: YES`

`OWNER_BOOTSTRAP_RISK_EXCEPTION_USED: YES`

`PRODUCTION_CANONICAL_MIGRATION: PASS`

`PRODUCTION_POSTFLIGHT: PASS`

`PRODUCTION_SCHEMA_READY: YES`

`READY_FOR_PRODUCTION_MIGRATION_APPLY: COMPLETED`

`PRODUCTION_CLIENT_CONFIGURATION_COMPLETE: NO`

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / PLATFORM WIRING PENDING`

`READY_FOR_PHASE_E_PRODUCTION_CLIENT_WIRING: YES`

Owner istisnası yalnız tamamen boş ilk canonical bootstrap için kullanıldı ve gelecekte
tekrarlanamaz. Canonical schema gate'i kapanmıştır. Site URL/redirect/SMTP, gerçek
Production client-safe config, final signing, controlled smoke ve fiziksel QR hâlâ
mandatory release gate'leridir; bu nedenle commercial GO verilmez.

## Cutover kimliği

- Tarih / change window:
- Release commander:
- Migration operator:
- Independent DB reviewer:
- Auth/SMTP owner:
- Client artifact owner:
- Smoke lead:
- Incident/rollback owner:
- Production project ref (secret değildir, yine de doğru kayıt kanalında):
- Production project name:
- Commit / release tag:
- Artifact hash:
- Backup/restore point:

## Mandatory gates

| Gate | PASS evidence | Sonuç |
| --- | --- | --- |
| Exact Production project | Management API/Dashboard ref+name ile endpoint host iki bağımsız kaynakta eşleşiyor | [ ] PASS [ ] NO-GO |
| Migration artifacts | Exact 0001–0009 sıra ve canonical Git/LF SHA-256 manifesti platformdan bağımsız araçla 9/9 eşleşiyor | [ ] PASS [ ] NO-GO |
| Remote migration inventory | Ledger ve actual schema birlikte envanterlendi; F/C/L topology kararı kayıtlı | [ ] PASS [ ] NO-GO |
| Existing data impact | Row counts, legacy order/review ve 0009 aggregate/bucket delta raporu onaylı | [ ] PASS [ ] NO-GO |
| Backup / accepted exception | Restorable backup/point ve restore drill var; yalnız Wave 10 empty-first-bootstrap için kayıtlı owner exception alternatif olabilir | [ ] PASS [ ] NO-GO |
| Storage object protection | Database backup dışında object blob inventory/backup/retention kanıtı var | [ ] PASS [ ] NO-GO |
| Freeze / window | Write freeze uygulanabilir ve aktif; incident iletişim zinciri hazır | [ ] PASS [ ] NO-GO |
| Dry comparison | Production-data clone veya güvenli eşdeğerde apply/postflight PASS; dry-run yalnız expected migrations gösteriyor | [ ] PASS [ ] NO-GO |
| Migration apply | Approved canonical migrations success; partial apply/error/timeout yok; ledger final state doğru | [ ] PASS [ ] NO-GO |
| Tables / RLS | Canonical 23 tablo ve 23/23 RLS; cross-user/anon negatifleri PASS | [ ] PASS [ ] NO-GO |
| Policies / grants | Final expected public policy seti, table/column/function grants ve SECURITY DEFINER search path'leri exact | [ ] PASS [ ] NO-GO |
| RPC / triggers | Auth, Cart/QR, chat/notification, rating/review ve account-delete signatures/behavior PASS | [ ] PASS [ ] NO-GO |
| Realtime | Exact chat/notification publication; delivery, recipient isolation, reconnect/dedup PASS | [ ] PASS [ ] NO-GO |
| Storage | Üç active bucket exact public/size/MIME; no client list/mutation policy; path/fallback tests PASS | [ ] PASS [ ] NO-GO |
| Auth / email | Production email confirmation, custom SMTP/inbox, resend/expiry/recovery ve redirects PASS | [ ] PASS [ ] NO-GO |
| Client config | Real Production client-safe URL/key; no secret/fallback/Development endpoint; artifact/signing PASS | [ ] PASS [ ] NO-GO |
| Mobile identity / signing | Final Android package/namespace ve iOS bundle id onaylı; upload/Distribution signing, signer/team/profile ve macOS archive kanıtı PASS | [ ] PASS [ ] NO-GO |
| Controlled smoke | Full Production Smoke Checklist, fiziksel QR dahil PASS; cleanup residual kabul edilen değer | [ ] PASS [ ] NO-GO |
| Rollback readiness | Restore/forward-fix/recreate owner, stop criteria ve observation window hazır | [ ] PASS [ ] NO-GO |

## Automatic NO-GO conditions

Aşağıdakilerden biri varsa karar doğrudan NO-GO'dur:

- Production project ref/name/host eşleşmiyor veya tek kaynaktan tahmin ediliyor.
- `ieebtdvvinqfatbhkyqi` veya başka bir proje canonical sahiplik kanıtı olmadan
  Production varsayılıyor.
- Restorable backup, Storage object koruması veya kabul edilmiş recovery/RPO/RTO yok;
  yalnız Wave 10 empty-first-bootstrap için belgelenmiş dar owner exception geçerlidir.
- Migration ledger ile schema farklı; 0001 existing schema'ya çarpacak; hash farklı.
- Partial apply, SQL/lock/statement timeout veya açıklanamayan data delta var.
- Herhangi bir public tabloda RLS kapalı; cross-user/anon private data erişimi var.
- Beklenmeyen policy/grant, SECURITY DEFINER search path veya RPC signature farkı var.
- Direct authenticated notification INSERT ya da client Storage list/mutation mümkün.
- Bucket görünürlüğü/limit/MIME/path veya Realtime publication exact değil.
- Auth confirmation/SMTP/redirect/recovery gerçek inbox acceptance geçmedi.
- Client dummy/wrong environment key kullanıyor veya server secret içeriyor.
- Kritik smoke, fiziksel iki-cihaz QR veya cleanup başarısız.
- Rollback owner ya da uygulanabilir write freeze yok.

## Deferred, tek başına NO-GO olmayanlar

Yalnız ürün kararları değişmediyse şu kalemler tek başına release'i durdurmaz:

- `brand-logos`, `avatars`, `review-images`;
- legacy order final drop;
- push notification;
- analytics/crash reporting;
- installable PWA metadata temizliği.

Deferred bir kalem kritik müşteri akışında gerçek hata/güvenlik açığı üretirse yeniden
BLOCKER olarak sınıflandırılır.

## Final decision

- [ ] **GO** — Bütün mandatory gate'ler PASS; blocker yok.
- [ ] **NO-GO** — En az bir mandatory gate PASS değil.

Karar gerekçesi:

Open incident / owner / ETA:

Rollback observation end time:

Release commander imza/zaman:

Independent reviewer imza/zaman:
