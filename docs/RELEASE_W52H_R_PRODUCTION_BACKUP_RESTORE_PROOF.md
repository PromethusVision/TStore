# W52H-R — Production backup / real restore proof

**PASS — 9/9 bağımsız kapı geçti.** Gerçek Production yedeği, iki ayrı boş
PostgreSQL **17.6** veritabanına geri yüklendi. İlk gerçek kopyada exact W52H
migration, aktivasyon, eski W52C SQL/HTTP sözleşmeleri ve rollback doğrulandı.
**READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: YES.**
Bu sonuç Production'a yazma yetkisi değildir; Production'a yazılmadı.

## Kaynak, yedek ve izolasyon

- Branch: `astra-release/w52h-r-production-backup-restore-proof`.
- W52H source: `0c0161e36cd7489f9ea8fac1c03f4abc5d988895`.
- Başlangıç authoritative main: `8f87b7e5034427389047f076f03658b5cb2dbc98`.
- Production: `mefhfvrgkwciubeajjeb`; Development'a erişilmedi.
- Owner mevcut parolayı kendi terminaline girerek tam CUSTOM dump aldı.
- Bu devam adımında Production Dashboard üzerinden yalnız `READ ONLY`
  transaction içinde katalog metadata'sı ve anonim parmak izleri okundu.
  Parola veya kişisel satır değerleri sorgulanmadı.
- Credential-file incelemesi kapalı ve kapsam dışı kaldı.

Orijinal backup repo dışında korunuyor:

    C:\Users\Mustafa\EsnaftavarBackups\w52h-r\EsnaftaVar-Production-W52H-R-full.dump

| Backup alanı | Doğrulanan değer |
|---|---|
| Kaynak / araç | PostgreSQL 17.6 / pg_dump 17.11 |
| Format | CUSTOM, gzip, format 1.16-0 |
| Tamamlanma zamanı | LastWriteTimeUtc 2026-09-16T21:18:01.0568527Z |
| Boyut | 537274 bayt |
| SHA-256 | 83029c3871ce1689851b08beb2690be202d7d22d79bcdbdda3b5eadd46c64b10 |
| Arşiv başlığı / restore listesi | 965 TOC kaydı / 958 listelenen giriş |

Orijinal hash tüm testlerden sonra aynı. Dump veya kişisel veriler git'e alınmadı.

Owner indirme/kurulum yetkisini açıkça verdi. Docker Desktop 4.91.0.239619,
Docker Engine 29.8.0 ve WSL2 2.7.14.0 doğrulandı. Owner'ın yeniden başlatması
sonrasında VirtualMachinePlatform ve hypervisor çalıştı; WSL1 kurulması gerekmedi.

| Test ortamı | Kanıt |
|---|---|
| Motor | Çalışan sunucuda `server_version = 17.6` |
| Resmî imaj | `supabase/postgres:17.6.1.136` |
| İmaj digest | `sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00` |
| Ağ / port | `--network none`, yayımlanan port yok; PostgreSQL TCP dinlemesi kapalı |
| Erişim | Yalnız container içi Unix socket; Production bağlantı bilgisi/parolası kullanılmadı |
| Yedek bağlantısı | Tek bind mount, read-only |
| İlk / ikinci hedef | `w52hr_first` / `w52hr_second`, ikisi de template0'dan boş oluşturuldu |
| Test sonrası | PostgREST durduruldu, geçici yerel JWT ayarı silindi; DB container durduruldu |

## Tam restore ve kaynak eşitliği

pg_dump cluster rol tanımlarını taşımaz. Bu eksik, Production'dan salt okunur
alınan **16 rolün özellikleri, 22 üyelik ve ilgili oturum ayarları** ile kapatıldı.
Yerel rol parolaları kopyalanmadı. Kaynak uzantı sürümleri hedefte eşleşti:
pg_stat_statements 1.11, pgcrypto 1.3, plpgsql 1.0, supabase_vault 0.3.1,
uuid-ossp 1.1. Supautils yüklenip kaynak privileged-role davranışı doğrulandı.

Supabase'in event-trigger sahiplik koruması nedeniyle restore iki bölümde yapıldı:
**951 normal giriş**, ardından **7 event trigger kendi asıl sahipleriyle**.
Standart pg_restore listesindeki **958 girişin tamamı** işlendi; tablo, şema,
veri, ACL veya sahiplik atlanmadı. İki bölümün de çıkış kodu 0.
Bu yöntem postgres rolünü SUPERUSER yapmayı gerektirmedi.

| Kontrol | İlk restore | İkinci temiz restore |
|---|---:|---:|
| Başlangıç kullanıcı tablosu | 0 | 0 |
| categories / products | 4 / 20 | 4 / 20 |
| listings / shops | 285 / 57 | 285 / 57 |
| Migration ledger | 9 | 9 |
| Ürün-kategori referansları | 20/20 | 20/20 |
| Orphan products / listings | 0 / 0 | 0 / 0 |
| Tam satırları yedekle eşleşen TABLE DATA girişleri | 69/69 | 69/69 |
| Public FK, tamamı validated | 33 | 33 |
| Kaynakla eşleşen parmak izleri | 6/6 | 6/6 |
| Event trigger, sahiplik korunarak | 7 | 7 |

69 tablo karşılaştırması auth/storage/realtime dahil yedekteki tüm TABLE DATA
girişlerini kapsar. COPY satırları yalnız bellekte karşılaştırıldı; raporlar
sadece tablo adları, sayılar ve hash içerir.

Altı canlı kaynak parmak izi; tüm ürün satırları, kategori satırları, ledger
satırları, public kolon tanımları, policy'ler ve fonksiyon tanımlarını kapsar.
Kaynak sorgu 2026-09-16T22:38:08.927304Z'de READ ONLY çalıştı. Parmak izi
ayırıcısı açık `chr(10)` olarak tanımlandı; editörün çok satırlı string girintisi
etkisi giderildi. Kaynakla aynı şema çözümlemesi kullanıldı.

## Gerçek kopyada migration, sözleşme ve rollback

Exact candidate değişmedi:

- `supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql`
- LF UTF-8 SHA-256: `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834`
- Owner mapping SHA-256: `f589308535f42936a1ef4c873ea446b00ed4849fb8ef872c4112956b56a28663`

| Kontrol | Gerçek sonuç |
|---|---:|
| Products / listings / shops korundu | 20 / 285 / 57 |
| Canonical nodes / roots / terminal leaves | 1563 / 24 / 1245 |
| Exact owner mapping | 20/20 |
| Orphan / kopuk parent / duplicate UUID | 0 / 0 / 0 |
| Aktivasyonda görünür / kurallarla kapalı | 14 / 6 |
| Rollback süresi | 271 ms |
| Rollback sonrası canonical public gate | Kapalı |
| Rollback sonrası tüm özgün tablo satırları | 69/69 eşit |
| Rollback sonrası özgün public kolon/policy/fonksiyonlar | Kaynak parmak izleriyle eşit |

Eski W52C APK SHA-256'sı ve `4f0da82` kaynak sorguları doğrulandı. Home
categories, Product Listing, Product Details, Seller Comparison, Shop Details
ve Search; `anon` ve `authenticated` rolleriyle **SQL ve gerçek PostgREST HTTP**
üzerinden test edildi. İç içe category/brand/product/shop DTO'ları da kontrol edildi.
HTTP yanıtlarının ve SQL sonuçlarının hash'leri dört aşamada aynı kaldı:
pre-migration, staged migration sonrası, aktivasyon sonrası, rollback sonrası.

HTTP testinde Supabase'in resmî self-hosting yapılandırmasındaki PostgREST 14.17
kullanıldı. Test yalnız ağsız container içindeydi; authenticated isteklerde geçici
bir yerel test JWT'si kullanıldı. Production token/parolası kullanılmadı.
**Fiziksel cihaz/APK çalıştırma: NOT_RUN.** HTTP testi fiziksel cihaz sonucu değildir.

İkinci restore rollback'ten bağımsızdır: yeni boş `w52hr_second` veritabanına
**orijinal Production dump** yeniden yüklendi; aynı 69 tablo ve 6 canlı parmak izi
karşılaştırması tekrar geçti. Sentetik W52H sonuçları gerçek kanıt yerine kullanılmadı.

## Bağımsız kabul kapıları

| Kapı | Sonuç |
|---|---|
| PRODUCTION_BACKUP_CAPTURE | PASS |
| PRODUCTION_BACKUP_HASHED | PASS |
| PG_VERSION_MATCH | PASS |
| REAL_PRODUCTION_COPY_RESTORED | PASS |
| RESTORED_BASELINE_MATCH | PASS |
| ADAPTER_REHEARSAL_ON_REAL_COPY | PASS |
| OLD_W52C_CONTRACT_ON_REAL_COPY | PASS |
| ROLLBACK_ON_REAL_COPY | PASS |
| SECOND_CLEAN_RESTORE | PASS |

## Kanıt ve kalite

- [Ana doğrulama manifesti](data/w52h_r_backup_restore_validation.json)
- [Salt okunur kaynak metadata](data/w52h_r_source_restore_metadata.json)
- [İlk restore](data/w52h_r_first_restore_execution.json) ve [baseline](data/w52h_r_first_restore_baseline.json)
- [Gerçek migration/SQL/HTTP/rollback](data/w52h_r_real_copy_rehearsal.json)
- [Rollback tanım eşitliği](data/w52h_r_rollback_preservation.json)
- [İkinci restore](data/w52h_r_second_restore_execution.json) ve [baseline](data/w52h_r_second_restore_baseline.json)
- [Rol/uyumluluk doğrulaması](data/w52h_r_role_runtime_validation.json)
- Yerel test araçları: `tool/production_taxonomy/*real*.mjs`.
- Node syntax, kaynak/rapor tutarlılığı, frozen hash, secret/PII scan ve `git diff --check`: PASS.
- Flutter analyzer/test: NOT_REQUIRED — client kodu değişmedi.
- Aynı task branch; main merge ve force push yok.

Resmî dayanaklar: [pg_restore](https://www.postgresql.org/docs/17/app-pgrestore.html),
[Supabase restore](https://supabase.com/docs/guides/self-hosting/restore-from-platform),
[Supabase PG17 imajı](https://supabase.com/docs/guides/self-hosting/custom-postgres-extensions),
[Supautils sahiplik kuralları](https://github.com/supabase/supautils),
[Supabase PostgREST paketi](https://raw.githubusercontent.com/supabase/supabase/master/docker/docker-compose.yml).

## TASK_RESULT

```text
PRODUCTION_SOURCE_PG: 17.6
RESTORE_TARGET_PG: 17.6
BACKUP_CAPTURE_CAPABILITY: PASS
BACKUP_ARTIFACT_CREATED: YES
BACKUP_SHA256_RECORDED: YES
RESTORE_CAPABILITY: PASS
REAL_PRODUCTION_COPY_RESTORED: YES
RESTORED_BASELINE: categories=4 products=20 listings=285 shops=57
RESTORED_BASELINE_MATCH: PASS
ADAPTER_MIGRATION_ON_RESTORED_COPY: PASS
PRODUCTS_AFTER: 20/20
LISTINGS_AFTER: 285/285
CANONICAL_NODES: 1563/1563
OWNER_MAPPINGS: 20/20
ORPHANS: 0
OLD_W52C_SQL_HTTP_CONTRACT_COMPATIBILITY: PASS
OLD_W52C_PHYSICAL_DEVICE_POST_MIGRATION: NOT_RUN
ROLLBACK_ON_RESTORED_COPY: PASS
SECOND_CLEAN_RESTORE: PASS
RESTORE_PROOF: PASS
PRODUCTION_WRITE_PERFORMED: NO
DEVELOPMENT_ACCESSED: NO
MANUAL_OWNER_ACTION_REQUIRED: NO
READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: YES
```
