# W52H-R — Production backup / real restore proof

**Gerçek Production yedeği alındı ve çevrimdışı doğrulandı. Restore proof henüz yok; karar NO-GO.**

Product Owner manuel pg_dump işleminin tamamlandığını bildirdi. Agent gerçek
arşivi okuyup SHA-256, kaynak/araç sürümü, veri sayımları ve mevcut baseline ile
ilişkileri doğruladı. SQL çalıştırılmadı; restore yapılmadı. Kalan engel, izole
**PostgreSQL 17.6** ortamının henüz hazır olmamasıdır. Owner bu test için Docker
Desktop/WSL2 ve gerekli Supabase PG17.6 paketlerinin indirilip kurulmasını açıkça
yetkilendirdi. Önceki credential-file incelemesi kapatıldı ve kapsam dışıdır.
Tekrar parola veya aynı yedekleme işlemi istenmiyor.

## 1. Kaynak ve branch

- Branch: astra-release/w52h-r-production-backup-restore-proof.
- W52H source HEAD: 0c0161e36cd7489f9ea8fac1c03f4abc5d988895.
- Başlangıçta doğrulanan authoritative main: 8f87b7e5034427389047f076f03658b5cb2dbc98.
- Production: mefhfvrgkwciubeajjeb; Development'a erişim yok.
- Son canlı aggregate baseline: 2026-09-16T01:08:24.030103+00:00, Dashboard
  üzerinden REPEATABLE READ READ ONLY transaction: PG17.6, 4/20/285/57, ledger 9.
- Manuel komut Production metadata'sını açıkça seçti. Parola yalnız owner'ın
  terminalindeki gizli girişte kullanıldı; agent bağlantı kurmadı.
- Bu devam adımında Production'a hiçbir sorgu veya değişiklik gönderilmedi.

## 2. Gerçek backup artifact

Dosya repo dışında:

    C:\Users\Mustafa\EsnaftavarBackups\w52h-r\EsnaftaVar-Production-W52H-R-full.dump

| Alan | Gerçek gözlem |
|---|---|
| Format | PostgreSQL CUSTOM, gzip, dump format 1.16-0 |
| Kaynak PostgreSQL | **17.6** — arşiv başlığından |
| Backup aracı | **pg_dump 17.11** — arşiv başlığından |
| Tamamlanma zaman dayanağı | LastWriteTimeUtc: **2026-09-16T21:18:01.0568527Z** |
| Arşiv oluşturma başlığı | 2026-09-17 00:17:39; başlık timezone kodlamıyor |
| Boyut | **537274 bayt** |
| TOC kayıt sayısı | **965** |
| SHA-256 | 83029c3871ce1689851b08beb2690be202d7d22d79bcdbdda3b5eadd46c64b10 |
| Çevrimdışı okuyucu | pg_restore 17.11 |

Hash incelemenin başında ve sonunda aynı kaldı. Orijinal dump değiştirilmedi,
repo içine kopyalanmadı. Raw SQL bellekte render edildi; satırlar ekrana/loga
yazdırılmadı veya ek bir SQL dosyasına kaydedilmedi.

## 3. Çevrimdışı arşiv doğrulaması — restore sonucu değildir

[Tekrarlanabilir denetleyici](../tool/production_taxonomy/inspect_backup.mjs),
pg_restore --list ve pg_restore --file=- kullanır; bağlantı argümanı yoktur.
Dump'ın tümü hatasız belleğe açıldı ve tamamlanma işareti doğrulandı.
İlgili COPY blokları parse edilerek yalnız aşağıdaki anonim metadata üretildi.

| Kontrol | Arşivde ölçülen değer | Sonuç |
|---|---:|---|
| categories | 4 | Kaynak baseline ile eşleşti |
| products | 20 | Kaynak baseline ile eşleşti |
| shop_products/listings | 285 | Kaynak baseline ile eşleşti |
| shops | 57 | Kaynak baseline ile eşleşti |
| migration ledger | 9 | Beklenen version/name ve boş olmayan statements |
| Ürün-kategori referansları | 20/20 | W52H baseline ile birebir eşleşti |
| İlan ilişki fingerprint | 3cdc33b78d268e2e92509371e0250c0c | W52H MD5 ile eşleşti |
| Orphan products / listings | 0 / 0 | Arşiv satır ilişkileri kontrolü |
| Temel tablolarda duplicate ID | 0 | Arşiv satır kontrolü |
| Public function envanteri | 29 | W52H ad envanteri birebir eşleşti |
| Public policy / FK / index | 52 / 33 / 50 | Arşiv TOC gözlemi |
| Dört temel tabloda RLS enable | 4/4 | SQL tanımları mevcut |

App schema/data, PK/FK, indeks, fonksiyonlar, RLS/policy ve migration ledger
arşivde mevcut. auth, storage, realtime, supabase_migrations, vault dahil platform
şemaları da alınmış. Public view sayısı 0; bu bir dışlama filtresi değildir.
Tam ürün satırları için bağımsız canlı fingerprint önceki baseline'da yok.
Fonksiyon body/policy expression/schema fingerprint eşitliği ve DB tarafından
FK enforcement henüz doğrulanmadı. Parse edilmiş ilişkiler DB restore kontrolü
olarak gösterilmez.

[Makine arşiv kanıtı](data/w52h_r_backup_archive_inspection.json)
ARCHIVE_INSPECTION_ONLY_NOT_RESTORE_PROOF sınırını açıkça taşır.

## 4. İzole restore ortamı engeli ve hazırlanmış devam planı

- Mevcut portable native PostgreSQL motoru **17.11**; istenen **17.6** değil.
- Kurulum öncesi kontrol edilen PATH, standart kurulum, Downloads ve EsnaftavarTools
  konumlarında PG17.6 veya Docker/Podman bulunmadı; WSL alt sistemi yüklü değildi.
- Arşiv extension'ları: pg_stat_statements, pgcrypto, supabase_vault, uuid-ossp.
- pg_dump cluster rol tanımlarını içermez. Hedefte platform/custom rol tanımları,
  privilege özellikleri ve extension bağımlılıkları eksiksiz karşılanmadan restore
  PASS verilemez. Bunları atlamak veya boş stub ile değiştirmek kabul edilmez.
- Owner önceki indirme yasağına yalnız bu izole test ortamı için açık istisna verdi.
  Resmî Docker bağlantısından **4.91.0.239619** kurulum dosyası indirildi;
  Authenticode **Valid**, yayıncı **Docker Inc** olarak doğrulandı.
- Kurulum dosyası repo dışında EsnaftavarTools/w52h-r-runtime dizinindedir.
  Boyut 628014512 bayt, SHA-256
  ac405b09942701770d581b173747fc1024cf0e6047cbe60f13d1df85437311ac.
- Windows 11 Pro build 26200, yaklaşık 16 GB RAM, 61 GB boş alan ve açık firmware
  sanallaştırması doğrulandı. WSL kurulumu dağıtım yüklemeden Windows yönetici
  onayıyla başlatılmak istendi; Windows **“İşlem kullanıcı tarafından iptal edildi”**
  sonucu döndürdü. WSL başlamadı. Bu, otomatik araç izin incelemesinin reddi değildir.
- Docker **kullanıcı hesabına kuruldu**, installer exit **0**; tamamlanma UTC
  **2026-09-16T21:46:51.9660678Z**. Uygulama sürümü **4.91.0.239619**, CLI
  **29.8.0, build 88096ef** doğrudan kurulu dosyalardan doğrulandı.
  Kurulum konumu: C:\Users\Mustafa\AppData\Local\Programs\DockerDesktop.
- Son kontrolde VirtualMachinePlatform ve WSL bileşenleri hâlâ kapalı;
  hypervisor çalışmıyor. Docker engine veya PostgreSQL sunucusu başlatılmadı.
  Agent bilgisayarı yeniden başlatmadı; PostgreSQL klasörü taşınmadı.

Devam planı: Yerel Linux container runtime hazırlandıktan sonra,
[Supabase'in belgelediği](https://supabase.com/docs/guides/self-hosting/custom-postgres-extensions)
supabase/postgres:17.6.1.136 imajı adaydır; gerçek motor sürümü çalıştırıldığında
17.6 olarak doğrulanmalıdır. Bu imaj indirilmedi veya çalıştırılmadı. Disposable
hedef --network none, sıfır yayımlanan port, yalnız read-only dump mount ve
Production credential'ı olmadan çalışacak. SQL testleri container içinde yapılacak.
HTTP contract gerekiyorsa yalnız dış ağa çıkışı olmayan yerel test ortamı kullanılacak.

[Supabase restore belgesi](https://supabase.com/docs/guides/self-hosting/restore-from-platform)
native pg_dump'ın platform iç nesnelerini de içerdiğini ve restore sırasında
rol/izin uyarlamaları gerektirebileceğini belirtir. Orijinal dump korunacak; kapsam
daraltılarak, extension veya tablo atılarak başarılı restore iddiası üretilmeyecek.

**Owner yetkisi alındı:** Yerel Docker Desktop/WSL2 ve gerekli Supabase PG17.6
paketleri bu izole test kapsamında indirilebilir ve kurulabilir. Windows'un
yönetici onayı ve kurulumun gerektirmesi durumunda yeniden başlatma kullanıcı
etkileşimi gerektirir. Bu yetki Production yazma yetkisi vermez. Tekrar parola ya da
dump gerekmez. Restore kapıları yalnız gerçekten çalıştırıldıktan sonra güncellenir.

**Kalan manuel adım:** Windows Terminal'i **Yönetici olarak çalıştır** seçeneğiyle
açıp aşağıdaki komutu çalıştırın. Windows isterse bilgisayarı yeniden başlatın;
otomatik yeniden başlatma yapılmaz. Kurulum sonucundan sonra aynı görevde devam edilir.

```powershell
wsl --install --no-distribution --web-download
```

Komut [Microsoft'un belgelenmiş WSL kurulumunu](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
kullanır. Docker kurulumu [resmî per-user kurulum yoluyla](https://docs.docker.com/desktop/setup/install/windows-install/)
tamamlandı. Bu adım Production bağlantısı veya veritabanı parolası gerektirmez.

## 5. Bağımsız kapılar

| Kapı | Sonuç | Execution |
|---|---|---|
| PRODUCTION_BACKUP_CAPTURE | PASS | Owner aldı; gerçek arşiv çevrimdışı doğrulandı |
| PRODUCTION_BACKUP_HASHED | PASS | SHA-256 ölçüldü; inceleme boyunca değişmedi |
| PG_VERSION_MATCH | FAIL | TARGET_NOT_CREATED |
| REAL_PRODUCTION_COPY_RESTORED | FAIL | NOT_RUN_BLOCKED |
| RESTORED_BASELINE_MATCH | FAIL | NOT_RUN_BLOCKED |
| ADAPTER_REHEARSAL_ON_REAL_COPY | FAIL | NOT_RUN_BLOCKED |
| OLD_W52C_CONTRACT_ON_REAL_COPY | FAIL | NOT_RUN_BLOCKED |
| ROLLBACK_ON_REAL_COPY | FAIL | NOT_RUN_BLOCKED |
| SECOND_CLEAN_RESTORE | FAIL | NOT_RUN_BLOCKED |

FAIL, gereken kanıtın henüz bulunmadığını belirtir; çalıştırılmış başarısız bir
restore anlamına gelmez. **2/9 kapı PASS**. Owner'ın tüm kapılar PASS şartı nedeniyle
capability/restore-proof genel kararı yükseltilmedi. W52H sentetik prova yeniden
çalıştırılmadı veya gerçek restore kanıtı olarak kullanılmadı.

W52H adapter ve 20/20 owner mapping hash'leri korunur. Migration, canonical
aktivasyon, rollback ve ikinci temiz restore henüz çalıştırılmadı. Gerçek hedefte
1563/24/1245 ve 14 görünür / 6 gated sonuçları ölçülmedi; null kalır.

## 6. Kalite ve TASK_RESULT

- Offline denetleyici Node syntax ve gerçek arşiv kontrolü: PASS.
- Truncated arşiv reddi: PASS; gerçek dump'a dokunulmadı.
- Metadata tutarlılığı, frozen candidate/mapping hash, secret/PII scan ve
  git diff --check: PASS.
- Flutter analyzer/test: NOT_REQUIRED — client kodu değişmedi.
- Docker imza ve kullanıcı kurulumu/sürüm kontrolü: PASS. WSL kurulumu:
  NOT_STARTED_WINDOWS_ELEVATION_CANCELLED; restore doğrulamaları hâlâ NOT_RUN.
- Branch üzerinde normal commit/push; main merge veya force push yok.

    PRODUCTION_SOURCE_PG: 17.6
    RESTORE_TARGET_PG: NOT_CREATED
    BACKUP_CAPTURE_CAPABILITY: PARTIAL
    BACKUP_ARTIFACT_CREATED: YES
    BACKUP_SHA256_RECORDED: YES
    RESTORE_CAPABILITY: PARTIAL
    REAL_PRODUCTION_COPY_RESTORED: NO
    ARCHIVE_COUNTS: categories=4 products=20 listings=285 shops=57
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
