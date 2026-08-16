# Production Go / No-Go Checklist

Bu sayfa release commander tarafından cutover kaydına kopyalanır. Bütün zorunlu
maddeler PASS değilse GO verilemez. Boş, `N/A` veya “sonra doğrulanacak” bir zorunlu
madde PASS sayılmaz.

## Wave 10 Phase B/C current evidence

Bu tablo release commander'ın imzalı checklist'inin yerine geçmez; 2026-08-16
pre-migration evidence durumunu gösterir.

| Pre-apply gate | Current evidence | Durum |
| --- | --- | --- |
| Exact Production project | `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` / ref-host / Frankfurt doğrulandı | PASS |
| Fresh remote inventory | Ledger yok; public application table/user/bucket/object sayıları 0 | PASS |
| Migration artifacts | Canonical Git/LF SHA-256 manifest 9/9 | PASS |
| Existing data / 0009 impact | Historical application row ve Storage object yok; affected count 0 | PASS |
| Native backup / PITR | Free plan scheduled backup yok; PITR yok; restorable point yok | **NO-GO** |
| Restore drill / RPO / RTO | Native restore kullanılamıyor; accepted RPO/RTO ve owner/drill yok | **NO-GO** |
| Storage object protection | Pre-migration object count 0; korunacak blob yok | PASS for current empty snapshot |
| Write freeze | Business state quiescent; Auth signup enabled ve enforced freeze/change window yok | **NO-GO until window** |
| Local dry comparison | PGlite safe-equivalent replay 0001→0009, final schema/QR/review/Storage PASS | PASS |
| Linked CLI dry-run | CLI/database credential istenmedi; remote linked dry-run yapılmadı | PENDING |

`BACKUP_ROLLBACK_PLAN_READY: NO`

`DRY_COMPARISON: PASS — LOCAL SAFE EQUIVALENT`

`READY_FOR_PRODUCTION_MIGRATION_APPLY: NO`

Mevcut **NO-GO**, migration conflict'inden değil Free-plan restore/rollback ve
operational freeze kanıtı eksikliğinden kaynaklanır. Bu koşullar kapanmadan Phase D
başlatılmaz.

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
| Backup | Restorable backup/point, kabul edilen RPO/RTO ve restore drill kanıtı var | [ ] PASS [ ] NO-GO |
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
| Rollback readiness | Restore/forward-fix owner, stop criteria ve observation window hazır | [ ] PASS [ ] NO-GO |

## Automatic NO-GO conditions

Aşağıdakilerden biri varsa karar doğrudan NO-GO'dur:

- Production project ref/name/host eşleşmiyor veya tek kaynaktan tahmin ediliyor.
- `ieebtdvvinqfatbhkyqi` veya başka bir proje canonical sahiplik kanıtı olmadan
  Production varsayılıyor.
- Restorable backup, Storage object koruması veya kabul edilmiş RPO/RTO yok.
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
