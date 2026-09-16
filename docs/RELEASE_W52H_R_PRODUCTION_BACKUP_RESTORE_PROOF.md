# W52H-R — Production backup / real restore proof

**NO-GO — gerçek Production yedeği alınamadı; restore kanıtı oluşmadı.**
`MANUAL_OWNER_ACTION_REQUIRED: YES`.

Production Dashboard erişimi var. Scheduled backups ekranı, mevcut Free planın
proje yedeği içermediğini gösteriyor; indirilebilir backup bulunmuyor. Resmî
Direct / Session pooler bağlantı ekranları mevcut DB parolası için placeholder
gösteriyor. Kontrol edilen yetkili yerel kaynaklarda bu parola bulunmadı.
Görevin “If required credentials are unavailable: STOP this phase safely”
koşulu uygulandı. Parola tahmini, parola sıfırlama, yeni rol oluşturma veya
Dashboard sorgularından özel bir dump mekanizması üretme yapılmadı.

## 1. Kaynak ve yapılan salt okunur kontroller

- Branch: `astra-release/w52h-r-production-backup-restore-proof`.
- W52H source HEAD: `0c0161e36cd7489f9ea8fac1c03f4abc5d988895`.
- Fetch sonrası origin/main: `8f87b7e5034427389047f076f03658b5cb2dbc98`.
- Başlangıç çalışma ağacı temizdi. Branch doğrulanmış W52H commit'inden oluşturuldu.
- Production proje kimliği: `mefhfvrgkwciubeajjeb`.
- Yeni baseline sorgusu: **2026-09-16 01:08:24.030103 UTC**; Dashboard SQL Editor'da
  `BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY`, yalnız aggregate
  `SELECT`, ardından `COMMIT`. Snippet kaydedilmedi; uygulama verisi değiştirilmedi.

| Production gözlemi | Değer |
|---|---:|
| PostgreSQL | 17.6 |
| categories | 4 |
| products | 20 |
| shop_products/listings | 285 |
| shops | 57 |
| migration ledger kayıt sayısı | 9 |
| orphan products / listings | 0 / 0 |

Bunlar **Production kaynak sayımlarıdır**, restore edilmiş hedef sayımları değildir.
W52H'deki ledger sürümleri, 20 referans ve schema/RPC/RLS parmak izleri geçmiş
kanıt olarak korunur; W52H-R sorgusu bunların tamamını yeniden çıkarmadı.

## 2. Gerçek backup yolu araştırması

| Yol | Bu çalışmada gözlenen sonuç |
|---|---|
| Supabase Dashboard / Scheduled backups | Oturum açık, doğru Production proje; Free plan için indirilebilir backup yok. |
| Resmî logical export | CLI / pg_dump yolu belgelenmiş; bu projeye ait authenticated DB bağlantısı kurulamadı. |
| Direct ve Session pooler bağlantısı | Projeye ait bağlantı parametreleri görüldü; mevcut DB parolası gerekiyor. Parola reset kontrolüne dokunulmadı. |
| Süreç environment | PG / DATABASE_URL / DB_ / SUPABASE adlarıyla DB bağlantı credential'ı bulunmadı; değerler yazdırılmadı. |
| Standart libpq dosyaları | İlk kontrolde dosyalar yoktu. Owner yolun görünmediğini bildirince korumalı klasör ve parolasız pgpass şablonu oluşturuldu; credential sağlanmış sayılmadı. |
| Bilinen Production client config | Yalnız client URL, public client key, project ref ve auth callback alanları; DB parola alanı yok. Değerler rapora alınmadı. |
| Yerel proje config | Worktree'de gerçek DB config yok; ana checkout `.env` yalnız client URL/anon key içeriyor, Production binding değil ve bağlantı için kullanılmadı. |
| Yerel araçlar | pg_dump, pg_restore, psql, Supabase CLI, Docker ve Podman PATH üzerinde bulunmadı. Standart Docker/PG17 konumları yok; WSL sorgusu alt sistemin yüklü olmadığını bildirdi. PG17.6 çalıştırılmadı. |
| Kullanılabilir connector | Hazır Supabase / PostgreSQL backup connector bulunmadı. |

Parolanın kullanıcının diğer güvenli depolarında hiç bulunmadığı iddia edilmiyor;
yalnız kontrol edilen kaynaklarda kullanılabilir DB credential'ı olmadığı saptandı.
İlk config okumasındaki sandbox erişim sınırı, yetkili salt okunur kontrolle
çözüldü. Açık kalan engel onay mekanizması değil, mevcut DB parolasının eksikliği.

[Supabase backup belgesi](https://supabase.com/docs/guides/platform/backups)
Free projeler için logical export önerir. Dashboard oturumu veya public client
key, DB bağlantı parolasının yerine geçmez.
[Resmî backup/restore akışı](https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore)
schema/data/roles yanında migration history ve özel auth/storage değişikliklerinin
ayrıca korunmasını gerektirebilir. Bu belgeyi okumak gerçek backup/restore kanıtı değildir.

## 3. Gereken minimum Product Owner adımı

**Production'ın mevcut DB parolasını yalnız bu bilgisayardaki korumalı libpq parola
dosyasına yerleştirin; sonra yalnız “yerelde hazır” deyin.** Parola veya tam bağlantı
URI'sini sohbete, repoya, dokümana ya da komut satırına göndermeyin.

Dosya: `C:\Users\Mustafa\AppData\Roaming\postgresql\pgpass.conf`.
Klasör ve parolasız şablon bu görevde oluşturuldu; yeni klasörün ACL'si yalnız
mevcut Windows hesabı ve SYSTEM'e erişim verecek şekilde sınırlandı. Var olan
dosya ezilmedi. Dosyayı Not Defteri ile açıp son satırdaki
`REPLACE_LOCALLY_WITH_EXISTING_PASSWORD` alanını yalnız yerelde değiştirin.
Dosya adını `pgpass.conf` olarak koruyun; `.txt` eklemeyin. Şablondaki alanlar:

| Alan | Değer |
|---|---|
| host | `aws-0-eu-central-1.pooler.supabase.com` |
| port | `5432` |
| database | `postgres` |
| user | `postgres.mefhfvrgkwciubeajjeb` |
| password | Mevcut Production DB parolası — yalnız yerel dosyada |

Bu parametreler Production Connect → Direct → Session pooler ekranından okundu.
Dosyanın erişimini kendi Windows hesabınızla sınırlayın. Parolada `:` veya `\`
varsa her birinin önüne `\` ekleyerek kaçırın. Windows dosya konumu ve kaçış
kuralları [PostgreSQL 17 libpq belgesinde](https://www.postgresql.org/docs/17/libpq-pgpass.html)
tanımlıdır. Varsa başka kayıtları silmeyin; wildcard kullanmayın.

**Mevcut parola bilinmiyorsa** mevcut yetkili parola sahibinden temin edilmesi gerekir.
W52H-R kapsamında parola sıfırlanmaz, Production ayarı değiştirilmez ve plan yükseltilmez.
Bu adım yeni Production yazma izni vermez; yalnız önceden yetkilendirilmiş read-only
backup bağlantısını mümkün kılar. Araçların kurulumu ve izole hedefin hazırlanması,
erişim sağlandığında agent tarafından sürdürülecek rutin teknik iştir.

## 4. Çalıştırılmayan aşamalar ve kanıt sınırı

| İstenen aşama | Durum |
|---|---|
| Gerçek Production logical backup | NOT_RUN — authenticated DB bağlantısı yok |
| Backup byte size / timestamp / SHA-256 | NOT_AVAILABLE — artifact oluşturulmadı |
| İzole PostgreSQL 17.6 hedefi | NOT_CREATED — backup erişimi sağlanmadan restore çalışması başlatılmadı |
| Gerçek dump restore ve baseline karşılaştırma | NOT_RUN_BLOCKED |
| W52H adapter'ın gerçek kopyaya uygulanması | NOT_RUN_BLOCKED |
| Altı eski W52C SQL/HTTP contract akışı | NOT_RUN_BLOCKED |
| Canonical aktivasyon: 14 görünür / 6 gated | NOT_RUN_BLOCKED — yalnız W52H'den gelen beklenen değer |
| Gerçek kopyada rollback ve süre ölçümü | NOT_RUN_BLOCKED |
| İkinci boş PG17.6 DB'ye temiz restore | NOT_RUN_BLOCKED |
| Fiziksel cihaz post-migration | NOT_RUN |

W52H'nin PG18.3/PGlite sentetik provası tekrar çalıştırılmadı ve gerçek Production
restore kanıtı olarak kullanılmadı. Restore edilmemiş hedef için 20/285/1563/20 veya
orphan=0 sonucu uydurulmadı; makine kanıtında ölçülmeyen alanlar `null` tutulur.

## 5. Bağımsız kabul kapıları

Aşağıdaki **FAIL**, gereken kanıtın bulunmadığını belirtir. Çalıştırılmış bir
restore veya migration sırasında hata gözlendiği anlamına gelmez; execution
durumu ayrıca `NOT_RUN_BLOCKED` olarak kayıtlıdır.

| Kapı | Kabul | Execution |
|---|---|---|
| PRODUCTION_BACKUP_CAPTURE | FAIL | NOT_RUN_BLOCKED |
| PRODUCTION_BACKUP_HASHED | FAIL | NOT_RUN_BLOCKED |
| PG_VERSION_MATCH | FAIL | TARGET_NOT_CREATED |
| REAL_PRODUCTION_COPY_RESTORED | FAIL | NOT_RUN_BLOCKED |
| RESTORED_BASELINE_MATCH | FAIL | NOT_RUN_BLOCKED |
| ADAPTER_REHEARSAL_ON_REAL_COPY | FAIL | NOT_RUN_BLOCKED |
| OLD_W52C_CONTRACT_ON_REAL_COPY | FAIL | NOT_RUN_BLOCKED |
| ROLLBACK_ON_REAL_COPY | FAIL | NOT_RUN_BLOCKED |
| SECOND_CLEAN_RESTORE | FAIL | NOT_RUN_BLOCKED |

`BACKUP_CAPTURE_CAPABILITY: PARTIAL`, `RESTORE_CAPABILITY: PARTIAL`;
`RESTORE_PROOF: FAIL` — W52H-R'nin gerçek Production kopyası şartı karşılanmadı.
`READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: NO`.

Erişim sağlanınca original backup repo dışında korunacak; kaynak versiyonu,
tool/version, UTC, boyut ve SHA-256 kaydedilecek. Restore hedefi tam **17.6** ve
Production'a yazma ağ yolu olmayan izole ortam olacak. App schema/data, PK/FK,
index/view/function/RLS, roller ve migration state tamlığı kontrol edilmeden
restore PASS verilmeyecek. Restore için gereken extension veya platform bağımlılığı
çıkarılarak gizlenmeyecek; izole hedefte karşılanacak veya açık blocker sayılacak.
Orijinal artifact ikinci boş hedefe de geri yüklenmeden final proof PASS olmayacak.

## 6. Kapsam, kalite ve handoff

- W52H adapter ve 20/20 owner mapping paketi değiştirilmedi.
- Sadece iki W52H-R kanıt dosyası ve W52H belgesinde devam notu değişti.
- Raw Production satırı, dump, credential veya PII Git'e alınmadı.
- Source baseline read-only kontrolü, metadata tutarlılığı, diff ve secret/PII
  kontrolleri yapıldı. Gerçek restore/migration/rollback testleri **NOT_RUN_BLOCKED**.
- Flutter test/analyzer: **NOT_REQUIRED — DOCS_ONLY**. Figma: **NOT_REQUIRED / 0 calls**.
- Phase 1 araştırması tamamlandı fakat erişim kriteri bloke; phase 2–10 çalıştırılmadı.
  Phase 11 kanıt paketi, phase 12 NO-GO sınıflandırması tamamlandı. Backup/proof
  ana hedefinin tamamlanma oranı **0/9 kabul kapısı**; plan tamamlanması başarı sayılmaz.
- Calibration: **YELLOW — credential blocker**. Scope drift / gözlenen regression:
  yok. Sonraki paket: **SAME_SIZE**, bu aynı W52H-R kapsamına erişim sağlanınca devam.
- Main merge / force push yok. Başka görev dosyası ve ortak runtime değişikliği yok.

[Makine kanıtı](data/w52h_r_backup_restore_validation.json) gerçek gözlemleri,
boş artifact alanlarını, bağımsız FAIL kapılarını ve tek owner adımını saklar.

## TASK_RESULT — credential handoff checkpoint

Bu checkpoint görevin tamamlandığını iddia etmez. FAIL alanlarının execution
durumu `NOT_RUN_BLOCKED`; `NOT_MEASURED` alanları gerçek kopya olmadığından boş.
Turn başlangıcı ayrı saat ölçümüyle kaydedilmediği için toplam elapsed süre
`NOT_OBSERVABLE`; yeni Production baseline gözleminin kesin UTC zamanı yukarıdadır.

```text
PRODUCTION_SOURCE_PG: 17.6
RESTORE_TARGET_PG: NOT_CREATED
BACKUP_CAPTURE_CAPABILITY: PARTIAL
BACKUP_ARTIFACT_CREATED: NO
BACKUP_SHA256_RECORDED: NO
RESTORE_CAPABILITY: PARTIAL
REAL_PRODUCTION_COPY_RESTORED: NO
RESTORED_BASELINE: categories=NOT_MEASURED products=NOT_MEASURED listings=NOT_MEASURED shops=NOT_MEASURED
RESTORED_BASELINE_MATCH: FAIL
ADAPTER_MIGRATION_ON_RESTORED_COPY: FAIL
PRODUCTS_AFTER: NOT_MEASURED
LISTINGS_AFTER: NOT_MEASURED
CANONICAL_NODES: NOT_MEASURED
OWNER_MAPPINGS: NOT_MEASURED_ON_REAL_COPY
ORPHANS: NOT_MEASURED_ON_REAL_COPY
OLD_W52C_SQL_HTTP_CONTRACT_COMPATIBILITY: FAIL
OLD_W52C_PHYSICAL_DEVICE_POST_MIGRATION: NOT_RUN
ROLLBACK_ON_RESTORED_COPY: FAIL
SECOND_CLEAN_RESTORE: FAIL
RESTORE_PROOF: FAIL
PRODUCTION_WRITE_PERFORMED: NO
DEVELOPMENT_ACCESSED: NO
MANUAL_OWNER_ACTION_REQUIRED: YES
READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: NO
```
