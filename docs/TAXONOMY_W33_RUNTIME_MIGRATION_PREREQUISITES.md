# Wave 33 — Runtime Migration Prerequisites

**Durum:** `DESIGN ONLY — MIGRATION NOT AUTHORIZED`

Bu belge Wave 32 full candidate tree owner tarafından bulk-finalize edilse dahi
Development runtime migration'dan önce tamamlanması gereken teknik işleri sıralar.
Buradaki adımlar çalışma emri değildir; migration, DB veya environment değişikliği
yapılmamıştır.

## 1. Giriş kapıları

Runtime planlama başlamadan aşağıdakilerin birlikte sağlanması gerekir:

1. Wave 32 tree için exact, versioned owner-final artefakt ve commit kaydı.
2. 24 `UNRESOLVED` legacy locator için `target / split / retire / out-of-scope`
   kararı; partial suggestion'lar target sayılmaz.
3. 7 `OUT_OF_PRODUCT_TAXONOMY` ve 278 policy-flagged satır için gereken owner,
   legal veya domain-professional gate'lerin tanımı.
4. Candidate tree'de leaf/assignable, parent, ordering, max-depth, duplicate-name,
   cycle/orphan ve policy invariant'larının makineyle doğrulanması.
5. Development'a yönelik ayrı uygulama yetkisi, backup/restore beklentisi ve exact
   environment/project doğrulaması.

Herhangi biri yoksa **STOP**: runtime migration artefaktı hazırlanabilir taslak
seviyesine bile alınmamalıdır.

## 2. Stable identity tasarımı

[`TAXONOMY_W33_STABLE_ID_SUCCESSOR_SIMULATION.csv`](TAXONOMY_W33_STABLE_ID_SUCCESSOR_SIMULATION.csv)
production ID içermez. Finalization sonrasında:

- final node'lara immutable, opaque ID tahsis stratejisi belirlenir;
- mevcut owner-final Elektronik/Bilgisayar ID'leri varsa yeniden üretilmez;
- display name, slug ve path identity olmaktan çıkarılır;
- historical slug/path alias'ları versioned tutulur;
- rename/move aynı stable ID'yi korur;
- merge'de bütün old locator'lar tek successor'a alias olur, tombstone lineage kalır;
- split'te parent locator doğrudan bir ürünü keyfi target'a götürmez; deterministic
  item-classification kuralı veya manual queue gerekir;
- retired/out-of-scope locator'lar yeniden kullanılmaz.

Bu adımlar bitmeden UUID veya başka production stable ID üretmek yasaktır.

## 3. 651 satırlık executable bridge specification

Simulation CSV, implementation contract'a dönüştürülürken her satır için:

- source locator ve source version;
- final stable target ID veya explicit tombstone;
- action ve reversible migration state;
- alias/redirect listesi;
- split için product-level discriminator ve fallback queue;
- merge için dedup/evidence rule;
- policy review sonucu;
- idempotency key ve rerun davranışı;
- before/after validation assertion

zorunlu olmalıdır. `UNRESOLVED`, partial candidate path veya yalnız display name
taşıyan satır executable bridge'e çevrilemez.

## 4. Schema ve dependency inventory

Migration yazılmadan read-only inventory çıkarılır:

- category/taxonomy tabloları, PK/FK ve path/slug uniqueness;
- product, listing, search index, analytics, favorites/cart ve demo referansları;
- views, RPC, triggers, RLS, grants ve seed tooling;
- cached/baked category IDs, enum/string comparisons ve Flutter projections;
- merchant/category intake ile catalog candidate/moderation dependencies;
- rollback'ta old/new identity arasında gereken dual-read veya compatibility view.

Wave 33 bu inventory'yi remote üzerinde çalıştırmaz ve schema varsayımı yapmaz.

## 5. Data profiling ve split/merge planı

Exact Development snapshot üzerinde salt okunur olarak:

- her legacy locator'a bağlı product/listing sayısı;
- unknown/orphan locator;
- 210 split düğüm altında ürün ad/attribute dağılımı;
- 7 merge grubunda duplicate product ihtimali;
- 7 out-of-scope ve 24 unresolved locator altında mevcut veri;
- demo/test/real-data marker'ları

ölçülür. Split classification için title substring'i tek kanıt olamaz; structured
attribute ve manual exception queue gerekir. Hiçbir ürün sessizce first-successor'a
atanmaz.

## 6. Migration artefaktları

Owner-final ve data-profile kapıları geçince ayrı runtime task şunları hazırlar:

1. versioned taxonomy seed/snapshot;
2. stable node, alias ve successor-lineage artefaktı;
3. idempotent bridge staging tablosu veya eşdeğer kontrollü mekanizma;
4. dry-run comparison raporu;
5. transactional/phase-safe apply planı;
6. partial failure resume/rollback planı;
7. old locator compatibility read katmanı;
8. postflight assertions ve exception export'u.

Geçmiş migration değiştirilmez; yeni runtime migration canonical sıra sonunda
eklenir. Exact schema görülmeden dosya numarası veya SQL iddiası yapılmaz.

## 7. Demo geçişi

20 demo product, 57 shop ve 285 listing için
[`TAXONOMY_W33_DEMO_MAPPING_SIMULATION.md`](TAXONOMY_W33_DEMO_MAPPING_SIMULATION.md)
esas alınır. Demo namespace UUID'leri taxonomy stable ID değildir. Ürünler önce
final leaf'e bağlanır, listing'ler product relation üzerinden continuity kazanır;
category başına toplu string replacement yapılmaz.

## 8. Test/dry-run matrisi

Minimum otomatik kanıt:

- 651/651 locator tamlığı ve unique source;
- her target ID final snapshot'ta mevcut;
- zero unresolved executable row;
- split item total before = after + quarantined;
- merge lineage ve alias tamlığı;
- zero orphan product/listing;
- exactly-one primary assignable leaf;
- path/slug alias collision yok;
- rerun no-op/idempotent;
- rollback/downgrade expectation test edilmiş;
- search/category browse ve demo projections tutarlı;
- policy-excluded ürün customer discovery'ye fail-open sızmıyor.

## 9. Development rollout sırası

Bu sıra yalnız future authorized runtime task içindir:

1. Exact Development project/environment verification.
2. Backup/snapshot ve rollback owner'ı.
3. Read-only preflight ve row-count freeze.
4. Final taxonomy/stable identity apply.
5. Alias/successor lineage apply.
6. Product bridge dry-run; exception queue review.
7. Controlled product/listing migration.
8. Search/cache/projection rebuild.
9. RLS/RPC/functional postflight.
10. Demo smoke ve rollback-window gözlemi.

Production ayrı bir cutover'dır; Development başarısı Production authorization
veya migration izni vermez.

## 10. STOP criteria

- Owner-final artefakt veya exact commit belirsiz.
- 24 unresolved'dan biri uygulanacak data altında mevcut.
- Policy review gereken satır customer-visible fail-open davranacak.
- Stable identity alias/successor modeli tamamlanmamış.
- Split discriminator nondeterministic veya silent fallback içeriyor.
- Backup/rollback doğrulanmamış.
- Inventory ile schema/migration varsayımı uyuşmuyor.
- Demo/real/test traffic ayrımı yapılamıyor.

`OWNER_FINAL_TREE_REQUIRED: YES`

`UNRESOLVED_MUST_BE_CLOSED: 24`

`PRODUCTION_STABLE_IDS_GENERATED: NO`

`DEVELOPMENT_MIGRATION_AUTHORIZED: NO`

`RUNTIME_IMPLEMENTATION: NO`
