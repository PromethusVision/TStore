# W52H — Production canonical taxonomy migration readiness

**Karar: NO-GO — `READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: NO`.**
Adapter adayı ve iki temiz yerel prova başarılıdır. Ancak **bu Production
projesinden alınmış tam yedeğin izole hedefe geri yüklenmesi kanıtlanmadı**.
Yerel sentetik restore, bu eksik kanıtın yerine geçmez. Production'a yalnız
salt okunur sorgular gönderildi; Development'a erişilmedi. Client build yoktur.

| Bağımsız kapı | Sonuç | Kanıt / sınır |
|---|---|---|
| BACKUP_CAPTURE_READY | PARTIAL | Dashboard ve SQL okuması doğrulandı; tam logical dump alınmadı. |
| RESTORE_PATH_READY | PARTIAL | İzole restore prosedürü tanımlı; bu projenin dump'ı ile doğrulanmadı. |
| RESTORE_PROOF | PARTIAL | İki yerel sentetik backup/restore PASS; Production restore kanıtı yok. |
| ADAPTER_MIGRATION_READY | PASS — LOCAL CANDIDATE | Exact artifact yerel PostgreSQL motorunda çalıştı; uzak uygulama koruması kapalı tutulur. |
| LOCAL_REHEARSAL_READY | PASS | Aynı candidate ile iki bağımsız, temiz veritabanı. |
| OLD_W52C_COMPATIBILITY_READY | PASS — QUERY CONTRACT | APK hash + kaynak sorgular + anon/authenticated SQL sonuç eşitliği. Fiziksel APK/HTTP testi değildir. |
| ROLLBACK_READY | PASS — LOCAL | Kapıyı kapatma, staged duruma dönüş ve eski istemcinin devamı doğrulandı. |
| CANONICAL_ACTIVATION_PLAN_READY | PASS — PLAN/LOCAL | Ayrı aktivasyon; mevcut policy/review koşulları korunuyor. |

## 1. Doğrulanmış Production başlangıcı

- Proje: `mefhfvrgkwciubeajjeb`; runtime `LEGACY_RUNTIME`.
- Kaynak main: `8f87b7e5034427389047f076f03658b5cb2dbc98`; fetch sonrası aynı HEAD.
- Branch: `astra-release/w52h-production-taxonomy-migration-readiness`.
- Dashboard SQL kanıtı: **2026-09-16 00:25:30 UTC**. Sayımlar yönetici SQL
  bağlamındaki salt okunur sorgudan gelir; yalnız RLS görünür satır sayımı değildir.
- Kategoriler **4**, kök **4**, çocuk **0**; ürünler **20**, listing **285**, mağaza **57**.
- Kökler: Kırtasiye, Elektronik, Gıda, Ayakkabı. Hepsi aktif; UUID'ler W52G kanıtıyla aynı.
- Yetim ürün **0**, yetim listing **0**. 20 ürünün mevcut kategori referanslarının
  parmak izi W52G-R paketindeki referanslarla birebir eşleşti.
- Dört ilgili tabloda RLS açık; ürün/kategori aktiflik ve shop/listing görünürlük
  politikaları incelendi. Listing → product `RESTRICT`, listing → shop `CASCADE`,
  product → legacy category `SET NULL` ilişkileri doğrulandı.
- Production ledger gerçek sürümleri: `20260812000100` … `20260812000700`,
  `20260814000800`, `20260815000900`. **0010/0011 yok**.
- Public RPC envanterinde 29 uygulama fonksiyonu görüldü; taxonomy RPC yok.
  Sorgular fonksiyonları çağırmadı; yalnız metadata okudu.

[Preflight manifest](data/w52h_production_preflight_manifest.json), mevcut
ledger, sayımlar, 20 referans, RPC isimleri, RLS ve schema/policy/RPC/listing
parmak izlerini içerir. Hash'ler tutarlılık kanıtıdır, tam backup değildir.

## 2. Bu projenin backup ve recovery durumu

Production'ın [Scheduled backups ekranında](https://supabase.com/dashboard/project/mefhfvrgkwciubeajjeb/database/backups/scheduled)
**Free Plan'in proje yedeği içermediği** açıkça görüldü.
[PITR ekranı](https://supabase.com/dashboard/project/mefhfvrgkwciubeajjeb/database/backups/pitr)
özelliği Pro eklentisi olarak gösteriyor; bu projede kullanılabilir recovery point yok.
Plan yükseltme, backup açma veya restore başlatma yapılmadı.

| Sınıflandırma | Durum | Gerekçe |
|---|---|---|
| BACKUP_CAPTURE_CAPABILITY | PARTIAL | SQL ve katalog okuma erişimi var. Mevcut yerel Production config yalnız client config; doğrulanmış doğrudan DB backup bağlantısı yok. |
| RESTORE_CAPABILITY | PARTIAL | Manuel logical export/restore yolu tanımlanabilir; uygun izole hedef ve bağlantı henüz doğrulanmadı. |
| RESTORE_PROOF | PARTIAL | Sentetik yerel DB snapshot'ı iki kez yeni DB'ye geri yüklendi. Gerçek Production dump restore edilmedi. |

[Supabase backup belgeleri](https://supabase.com/docs/guides/platform/backups)
Free projeler için ayrıca logical export yolunu belirtir. Bu genel ürün bilgisi,
mevcut proje için alınmış yedek veya test edilmiş restore anlamına gelmez.

### Production'a dokunmadan tamamlanacak gerçek recovery kanıtı

1. Mevcut, yetkili Production DB erişimi güvenli yerel credential mekanizmasıyla
   doğrulanmalı; parola yenilemek veya credential üretmek bu dalganın kapsamında değildir.
2. Yazıcıların kontrollü olarak durdurulduğu aynı snapshot penceresinde,
   [resmî logical backup/restore akışı](https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore)
   ile schema, data, parola içermeyen rol/grant tanımları ve `supabase_migrations`
   geçmişi alınmalı. Auth/Storage özelleştirmeleri ve gerekli extension tanımları
   ayrıca envantere bağlanmalı. Schema dump tek başına data backup sayılmaz.
3. Tam dump özel veriler içerebilir: şifreli ve Git dışındaki kontrollü depoda
   tutulmalı. Repoya yalnız dosya hash'i, kapsam, zaman ve doğrulama sonucu girmeli;
   secret veya gerçek kullanıcı/satıcı satırları girmemeli. Storage nesne içeriği
   DB yedeği değildir; bu migration nesnelere dokunmaz.
4. Production ve mevcut Development dışında, PostgreSQL 17/Supabase özellikleri
   uyumlu **izole recovery hedefi** hazırlanmalı. Bağlantı kimliği iki kez
   doğrulanıp yanlış hedefte restore engellenmeli. Dump bu hedefe restore edilmeli.
5. Geri yüklenen ledger, schema, RLS/grants, RPC tanımları, 4/20/285/57 sayımları,
   20 referans ve bütün listing ilişkileri kaynak snapshot ile karşılaştırılmalı.
   Aynı adapter + eski/yeni contract + rollback bu hedefte tekrar yürütülmeli.
6. Başarı kanıtı ve ayrı Product Owner yazma kararı olmadan Production uygulaması
   yapılmamalı. Production üzerinde yıkıcı restore gösterimi gerekli değildir.

Bu prosedürün **2–5. adımları gerçek Production dump'ı ile henüz tamamlanmadı**.
Tam geri yüklemenin süre/RPO/RTO değerleri ölçülmedi; sayı uydurulmadı.

## 3. Yazmadan hemen önce alınacak snapshot

[Salt okunur preflight SQL](../tool/production_taxonomy/preflight.sql), tek
`REPEATABLE READ READ ONLY` snapshot'ında ledger, kategori kayıtları, ürün
referansları, 285 listing ve 57 shop ilişki kanıtı, sayımlar, RLS/policies,
RPC imzaları/güvenlik/grants, column/constraint/index/trigger fingerprint'leri
ve extension envanteri üretir. Proje kimliği SQL'deki sabit etikete bakılarak
kabul edilmez; bağlanılan proje/pooler ayrıca doğrulanmalıdır.

Manifest, gelecekteki yazmadan **en fazla 15 dakika önce** yeni snapshot ve
yazıcı koordinasyonu ister. Drift varsa otomatik onarım veya sessiz kabul yok;
yeniden inceleme gerekir. Tam dump ve restore kanıtı ayrıca zorunludur.
`decision_safety_gates` karar hazırlığını, `immediately_before_future_write`
ise taze snapshot + açık yazma onayı dahil gerçek uygulama koşullarını ayırır.
Bu W52H snapshot'ı daha sonraki yazma anına kadar geçerli sayılmaz.

## 4. 0010 / 0011 uyumsuzluk analizi

| Artifact / varsayım | Production etkisi | Sınıf |
|---|---|---|
| **0010 dosyasının bütünü** | Boş application varsayımı, Development ledger ve advisory-lock bağlamı. Yerel Production şeklinde `W36_UNEXPECTED_NON_EMPTY_APPLICATION_TARGET` ile durdu. | **MUST_NOT_RUN_DIRECTLY** |
| 0010 ledger guard | İlk 8 migration'ın Development zamanları Production zamanlarından farklıdır. Aynı isim veya adet eşitliği yeterli değildir. | REQUIRES_ADAPTER |
| 0010 ürün/shop/listing toplamı = 0 | Production'da 20 + 57 + 285 vardır. Guard'ı kaldırmak veri uyumluluğu sağlamaz. | REQUIRES_ADAPTER |
| 0010 canonical satırların `public.categories` içine eklenmesi | Staged durumda gizlenebilir; aktivasyonda eski Home kökleri/genel kategori okumaları değişir. Product FK'lerini taşımak eski kategori filtrelerini kırar. | REQUIRES_ADAPTER |
| Dondurulmuş UUID, isim, parent, alias/edge verileri | Kanonik kimlik kaynağı olarak aynen kullanılabilir; hedef namespace ve yayınlama koşulu ayrıca uyarlanır. | SAFE_AS_IS — DATA IDENTITY ONLY |
| 0010 staged/active alanları, hierarchy/parent kontrolleri | Mantık tekrar kullanılabilir; yeni tabloya ve Production preflight'a bağlanmalıdır. | REQUIRES_ADAPTER |
| Eski bootstrap rollback | Boş application bootstrap için tasarlanmış; 20/285/57 bulunan hedefin geri dönüş prosedürü değildir. | MUST_NOT_RUN_DIRECTLY |
| **0011 dosyasının bütünü** | 0010 ledger kaydı ve `public.categories` içinde 1563 canonical satır/ek kolon bekler. Yerel test `W38_MIGRATION_LEDGER_MISMATCH` ile durdu. | **MUST_NOT_RUN_DIRECTLY** |
| 0011 strict DTO / recursion / breadcrumb / alias kontrolleri | Temel mantık yeni tablo, Production contract ismi ve kapalı yayınlama/preview politikasıyla kullanıldı. | REQUIRES_ADAPTER |
| 0011 product scope metadata | Eski client'ın `products.category_id` filtresini veya Production ürün eşlemelerini dönüştürmez. | REQUIRES_ADAPTER |

0010/0011 ve historical migration dosyaları değiştirilmedi. Production ledger'ına
çalıştırılmamış 0010/0011 kayıtları eklenmez. **`db push` ile aradaki migration'ları
körlemesine yürütmek veya history repair ile uygulanmış göstermek yasaktır.**

## 5. Yeni adapter tasarımı ve candidate

[0012 Production adapter candidate](../supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql)
normal migration dizinindeki sonraki güvenli sıra numarasını kullanır.
Deterministik [compiler](../tool/production_taxonomy/compile.mjs), dondurulmuş
kaynak hash'lerini ve W52G-R mapping hash'ini kontrol eder; 0010/0011'i değiştirmez.
[Artifact manifest](../tool/production_taxonomy/artifact_manifest.json) exact SHA-256'yı taşır.

- **Eski yol korunur:** `public.categories` dört kayıt olarak kalır;
  `products.category_id`, ürün satırları, shop/listing kimlikleri ve FK'ler değişmez.
- **Kanonik yol ayrı eklenir:** `public.canonical_categories` içinde 1563 düğüm,
  24 kök, 1245 terminal; tamamı ilk anda staged/inactive/unassignable.
- **Tam ürün eşlemesi:** `product_canonical_assignments` 20 product ID'yi exact
  owner UUID/yoluna bağlar; orijinal legacy UUID'yi ve owner mapping digest'ini saklar.
  Legacy root → canonical root tahmini yoktur. Canonical `category_id` yalnız
  yeni RPC'nin döndürdüğü JSON görünümünde kullanılır; ürün tablosunda yazılmaz.
- **Güvenlik:** yeni tablolar RLS ile kapalıdır; helper EXECUTE yetkileri kapatılır.
  Mapping SELECT yalnız public gate + uygun terminal + aktif ürün altında görünür.
  Product scope RPC `SECURITY INVOKER` ile mevcut ürün RLS'sini korur.
- **Atomiklik:** legacy tablolar için SHARE kilidi ve advisory lock; beklenen
  Production ledger/shape, yetim kontrolü ve final invariant'lar tek transaction.
  İkinci apply açıkça reddedilir; mevcut veri sessizce overwrite edilmez.
- **Açık gate:** `production_taxonomy_config.public_enabled=false`.
  Public preview desteklenmez; yalnız kolon active yapmak görünürlük sağlamaz.
- **Mevcut koşullar korunur:** W52G-R'nin altı policy/professional koşulu ve bütün
  parent zinciri kontrolleri aynı kaynak metadata ile değerlendirilir.

Candidate **default olarak uzak uygulamayı reddeder**; yalnız yerel harness
`esnaftavar.w52h.execution_scope=local-rehearsal` ayarlar. Bu GUC bir sunucu kimliği
veya güvenlik sınırı değildir; yanlışlıkla uygulamayı önleyen açık operatör kapısıdır.
Uzakta ayarlanmamalıdır. Gerçek Production write paketinde backup/restore ve owner
kararı doğrulanmadan bu koruma kaldırılmaz; kaldırılan final artifact ayrıca hash'lenip
test edilir. W52H herhangi bir uzaktan apply komutu sağlamaz veya çalıştırmaz.

Gelecekteki kontrollü executor yalnız onaylı adapter sürümünü ledger'a kaydeder;
0010/0011'i uygulanmış göstermez. Candidate ve yerel harness historical ledger'a
kayıt eklemez; yeni sürümün gerçek uygulama kaydı gelecekteki executor sorumluluğudur.

## 6. W52C eski istemci uyumluluğu

Frozen APK dosyası diskten yeniden hash'lendi:
`EsnaftaVar-1.0.0+1-w52c-main-4f0da82-production.apk`
→ `096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a`.
Release verification ve Git kaynağı `4f0da8201e2571200e99fa3dfe76387e3a1486ce`
ile eşleşir. Production dependency plan legacy varsayılanını kullanır.

| Ekran / akış | Frozen source contract | Yerel kanıt |
|---|---|---|
| Home categories | Aktif legacy kategoriler; parent NULL; sort order | 4 kök, sonuç hash'i değişmedi. |
| Product Listing | Aktif products; legacy `category_id`; categories/brands embed | Dört kategori ve 20 ürün kapsamı korundu. |
| Product Details | Product UUID, `categories(name)`, `brands(name)` | 20 ürünün payload/ilişki sonucu aynı. |
| Seller Comparison | shop_products → products + shops + categories/brands | 20 ürün için 285 listing ilişkisi aynı. |
| Shop Details | Aktif shops + aktif/available listing'ler | 57 mağazada 285 ilişki aynı. |
| Search | Product name/description ILIKE + category/brand bağlamı | Temsilî Kalem arama sonucu aynı. |

| Aşama | OLD_W52C_LEGACY_CLIENT | NEW_CANONICAL_CLIENT |
|---|---|---|
| PRE_MIGRATION | PASS | NOT_APPLICABLE |
| POST_SCHEMA_PRE_ACTIVATION | PASS | NOT_APPLICABLE — gate kapalı; legacy fallback |
| POST_PRODUCT_RECLASSIFICATION | PASS | NOT_APPLICABLE — mapping side table'da staged |
| POST_CANONICAL_ACTIVATION | PASS | PASS — yeni SQL/RPC contract, policy-eligible kapsam |

PASS kapsamı **frozen source'tan çıkarılan SQL/ilişki contract'ıdır**. Anon ve
authenticated rollerde sonucu aynı olan sorgular yürütüldü. PostgREST HTTP embed
serialization, fiziksel APK ekranları, kamera/QR veya yeni client build'i bu
yerel provada çalıştırılmadı. Bunlar sonradan oluşturulacak RC cutover smoke'unun
ayrı kapsamıdır; SQL başarısı cihaz smoke'u diye raporlanmaz.

## 7. İki temiz yerel prova ve invariant'lar

Motor: **PGlite 0.5.5 / PostgreSQL 18.3 WASM**; Production **17.6**.
Yerel fixture, gerçek 0001/0002 catalog/shop DDL ve RLS kurallarını kullanır;
Auth/profiles yardımcıları sentetiktir. 0003–0009'un ilgisiz iş verileri
oluşturulmaz; gerçek Production ledger sürümleri yerel fixture'da temsil edilir.
57 sentetik shop ve her birinde 5 farklı listing vardır. Gerçek kişisel veri yoktur;
20 katalog product UUID'si ve onaylı mapping paketi aynen kullanılır.

Her koşu sıfırdan başlar: baseline → snapshot → candidate'ın aynı SQL baytlarıyla
schema/staged veriler → exact 20 mapping → anon/authenticated uyumluluk → ayrı
aktivasyon simülasyonu → yeni contract → soft rollback → snapshot'tan **yeni DB**
oluşturup geri yükleme. Arada manuel/veri onarımı yoktur. Hata testlerinden sonra
otomatik transaction rollback yapılır. Schema ve mapping kontrol noktaları aynı
candidate transaction'ındaki açık işaretin iki tarafında gözlenir.

| Invariant | Önce | Staged / aktivasyon / rollback |
|---|---:|---:|
| Legacy categories | 4 | 4 |
| Products | 20 | 20 |
| Shop_products/listings | 285 | 285 |
| Shops | 57 | 57 |
| Owner canonical mapping | 0 | 20/20 |
| Canonical nodes / roots / terminals | 0 | 1563 / 24 / 1245 |
| Yetim ürün/listing | 0 | 0 |
| Geçersiz target / duplicate UUID / bozuk parent | 0 | 0 |
| Legacy FK, RLS, grants ve sorgu sonucu değişikliği | 0 | 0 |

Snapshot restore sonrasında yeni canonical tablolar yoktur; **4/20/285/57 ve dokuz
ledger kaydı** geri gelir. Restore edilen eski istemci sorguları, RLS/FK/schema
parmak izleri hem anon hem authenticated bağlamında aynı sonucu verir.

Aktivasyonda **12 public root, 14 public canonical ürün** görüldü. Toplam kanonik
kök sayısı hâlâ **24**; diğer metadata staged/kapalı kalır. Şu altı ürün canonical
public scope'a açılmaz: UHT Süt, Mavi Tükenmez Kalem 5'li, Kalem Kutusu,
Çocuk Spor Ayakkabı, Su Geçirmez Bot, Günlük Terlik. **20 ürünün tamamı eski runtime'da
korunur.** İlk canonical RC için bu policy-eligible kapsam ayrıca owner'a açıkça sunulmalıdır.

Negative checks: uzak/local guard eksikliği, doğrudan 0010/0011, ikinci apply,
container'a product mapping, yanlış contract, preview erişimi, anon/authenticated
doğrudan canonical tablo ve private helper erişimi reddedildi. Tek public gate'in
kapatılması roots/products/search/alias/capability sonuçlarını kapattı. Alias için
powerbank'in exact UUID'si, search için Defterler ve breadcrumb/children/descendants
şekilleri doğrulandı.

[Makine tarafından okunabilir sonuç](data/w52h_production_migration_rehearsal_result.json)
her koşunun exact artifact hash'ini, bütün sayımları, aşamaları ve sorgu/restore
hash'lerini saklar. PGlite snapshot restore bir Production logical restore değildir.

## 8. Aktivasyon sırası ve rollback

| Aşama | İşlem / kapı |
|---|---|
| A | Gerçek backup + izole restore kanıtı; taze preflight; ayrı owner write kararı. |
| B–D | Onaylı additive schema + 1563 staged node + 20 exact side mapping, tek transaction. |
| E | Counts/FK/RLS, eski APK contract ve HTTP smoke; gate hâlâ kapalı. |
| F | Production contract'ını destekleyen yeni RC; feature gate ve legacy fallback kanıtı. |
| G | Ayrı owner aktivasyon kararı; yalnız eligible zincirler, alias'lar ve public gate atomik açılır. |
| H | Legacy retirement daha sonraki ayrı görev. W52C compatibility window bu dalgada kapatılmaz. |

Rollback tetikleri: sayım/ID/ilişki değişikliği, yetim, legacy query veya canonical
RPC başarısızlığı, staged veri sızıntısı, cutover smoke başarısızlığı.

1. Staged transaction başarısızsa tamamı rollback edilir; eski tablolar korunur.
2. Aktivasyon sonrası sorun varsa [soft rollback](../tool/production_taxonomy/rollback.sql)
   mantığı public gate ve preview'ı kapatır; canonical satırları staged/inactive/
   unassignable, alias'ları inactive yapar. **Eski W52C hemen devam eder**.
3. `products.category_id` hiç değiştirilmediği için restore/update edilmez.
   20 mapping ve canonical metadata audit amacıyla kalır; product/listing/shop silinmez.
4. Schema'nın tamamen geri alınması gerekirse önce kanıtlanmış backup izole hedefte
   doğrulanır; Production restore ayrı yetki ve downtime planı gerektirir. W52H'de
   hard recovery yalnız sentetik yerel snapshot üzerinde kanıtlandı.

Yerel aktivasyon ve rollback script'leri `local-rehearsal` guard taşır; Production'a
gönderilmedi. Soft rollback yeni namespace'i bırakır; historical ledger silinmez.

## 9. Gelecek canonical Production client contract

Bu dalgada client kodu değiştirilmedi ve yeni APK üretilmedi. Development-only
canonical dependency binding'i Production'da otomatik açılmamalıdır.

- Önce `production_taxonomy_runtime_v1()` okunur. `public_enabled=false`, eksik RPC
  veya desteklenmeyen contract halinde aynı oturumda **legacy repository** seçilir.
- İstemci sürümü `production-taxonomy-client-v1`, taxonomy `canonical-v1.0.0`, RPC
  `production-taxonomy-rpc-v1` olmalıdır; capability response doğrulanır.
- `production_taxonomy_roots_v1`, `children_v1`, `descendants_v1`, `exact_leaf_v1`,
  `breadcrumb_v1` isimleri Production prefix'iyle çağrılır. Root/children version
  parametreleri zorunludur; `p_preview=false` korunur.
- Alias: `production_taxonomy_resolve_alias_v1` **exact locator** alır; ambiguous
  veya görünmeyen hedefi ilk çocuğa dönüştürmez. Search context RPC mevcut mantıkta
  **exact ad/slug/alias eşleşmesi** yapar; serbest ürün aramasının yerine geçirilmez.
- Product scope: `production_taxonomy_products_v1(p_category_id, p_client_contract_version,
  p_taxonomy_version, p_limit, p_offset)`. Alt ağaçtaki eligible terminal mapping'ler
  kullanılır; product JSON canonical category ve ayrı legacy category alanı içerir.
  Kanonik UUID ile eski `products.category_id` filtresi kullanılmaz.
- Bilinmeyen/gated canonical path için empty/kapalı durum gösterilir. Tek bir
  başarısız kategori sorgusunda sessiz legacy/canonical kimlik karışımı yapılmaz;
  fallback repository seçimi runtime düzeyinde atomiktir.
- Seller/shop ilişkileri product UUID ile aynı kalır. Yeni RC'nin ürün detayında
  canonical breadcrumb/label kullanımı ayrıca uygulanıp HTTP ve cihazda test edilir.

PostgREST çağrılarında parametre adları birebir korunmalıdır. Aşağıdaki taxonomy
RPC'lerinin hepsi `p_client_contract_version` ve `p_taxonomy_version` alır;
capabilities dışında `p_preview=false` da gönderilir.

| Tam RPC adı | Ek parametre |
|---|---|
| `production_taxonomy_capabilities_v1` | Yok |
| `production_taxonomy_roots_v1` | Yok |
| `production_taxonomy_children_v1` | `p_parent_id` |
| `production_taxonomy_descendants_v1` | `p_category_id` |
| `production_taxonomy_exact_leaf_v1` | `p_category_id` |
| `production_taxonomy_breadcrumb_v1` | `p_category_id` |
| `production_taxonomy_resolve_alias_v1` | `p_alias_locator` |
| `production_taxonomy_search_context_v1` | `p_term` |

`production_taxonomy_runtime_v1()` parametre almaz. Product scope RPC preview
almaz; `p_limit` 1–100 (varsayılan 20), `p_offset` en az 0 (varsayılan 0) olmalıdır.

## 10. Tekrarlanabilir kalite ve teslim

```text
node tool/production_taxonomy/compile.mjs
node tool/production_taxonomy/rehearse.mjs --local --pglite-root <PGlite-0.5.5-package>
node tool/production_taxonomy/validate_readiness.mjs
node tool/production_taxonomy/validate_readiness.mjs --require-write-ready
```

Son komut eksik gerçek backup/restore kapıları nedeniyle beklenen **exit 2 / NO-GO**
üretir; bu, yerel migration testinin başarısız olduğu anlamına gelmez. Diğer üç
kontrol PASS olmalıdır. SQL parse/execute, invariant'lar, 11 negative check/koşu,
iki rollback/restore, artifact/mapping/source hash, secret/PII ve `git diff --check`
bu paket için kontrol edilir. Flutter test/analyzer: **NOT_REQUIRED — NO_CLIENT_CHANGES**.

Global eski `verify_migration_artifact_manifest.mjs` tarihsel olarak 10 dosya
bekler; W52H tabanında zaten 11 migration vardır. Bu eski release manifest'i
yeniden yazılmadı; W52H kendi exact candidate manifest'ini doğrular. Olası gelecek
entegrasyon, Production/Development migration seçimini ayrıca açıkça çözmelidir.

```text
PRODUCTION_BASELINE: categories=4 products=20 listings=285 shops=57
OWNER_MAPPING: 20/20
BACKUP_CAPTURE_CAPABILITY: PARTIAL
RESTORE_CAPABILITY: PARTIAL
RESTORE_PROOF: PARTIAL
0010_PRODUCTION_COMPATIBILITY: MUST_NOT_RUN_DIRECTLY
0011_PRODUCTION_COMPATIBILITY: MUST_NOT_RUN_DIRECTLY
PRODUCTION_ADAPTER_MIGRATION_CANDIDATE: supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql
LOCAL_REHEARSAL: PASS
REHEARSAL_RUNS: 2
PRODUCTS_AFTER_REHEARSAL: 20/20
LISTINGS_AFTER_REHEARSAL: 285/285
CANONICAL_NODES: 1563/1563
CANONICAL_ROOTS: 24/24
TERMINAL_LEAVES: 1245/1245
OWNER_MAPPINGS_APPLIED_LOCALLY: 20/20
ORPHANS: 0
OLD_W52C_COMPATIBILITY: PASS
ROLLBACK_REHEARSAL: PASS
CANONICAL_ACTIVATION_PLAN: PASS
PRODUCTION_WRITE_PERFORMED: NO
DEVELOPMENT_ACCESSED: NO
READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: NO
```
