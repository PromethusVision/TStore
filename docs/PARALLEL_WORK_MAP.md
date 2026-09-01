# EsnaftaVar Parallel Work Map

## Kullanım Kuralları

- Her work wave başlamadan önce bu harita kontrol edilir.
- Aynı shared/hot-spot dosyanın iki production agent tarafından eşzamanlı değiştirilmesi varsayılan olarak yasaktır.
- `service_locator.dart`, global navigation, app bootstrap, ortak schema/migration ve benzeri merkezi değişiklikler mümkün olduğunca integration agentına bırakılır.
- Her wave için gerçek agent sayısı, seçilen işlerin dosya ve bağımlılık çakışmalarına göre yeniden belirlenir.
- `3 production agents` sabit kural değildir; aşağıdaki sayı mevcut repo durumuna ait başlangıç snapshot'ıdır.
- Production agent yalnız atanmış task branch/worktree ve dosya sınırında çalışır; başka agentın değişikliklerini commit etmez veya yeniden yazmaz.
- SQL/migration yazan agent sayısı aynı wave içinde varsayılan olarak birdir. Ayrı SQL dosyaları olsa bile ortak schema, tablo ve policy etkisi integration agentı tarafından birlikte değerlendirilir.
- Merkezi koordinasyon dosyaları production agentlar tarafından geniş çapta yeniden yazılmaz.

## Başlangıç Paralellik Snapshot'ı

**SAFE PARALLELISM: 3 production agents**

Bu tahmin `ddbabc0fcd3d8f9ffd5406611e12a85cca297d57` commit'indeki repo durumuna aittir. Chat, müşteri hesabı ve seçilmiş bir discovery veya cart işi izole edilebilir. Dördüncü ve beşinci production agent merkezi DI/navigation, `settings_view`, ortak Shop modelleri veya migration zincirine çarpma riskini belirgin biçimde artırır. Seçilen işler ortak dosyalara dokunuyorsa güvenli sayı 2'ye veya 1'e düşürülür.

## Wave 39B Final UI Rollout Gözlemi

`CANONICAL_TAXONOMY_DEVELOPMENT: DONE`

`FINAL_UI_DESIGN_FOUNDATION: DONE`

`HOME_FINAL_UI_V1_CANDIDATE: INTEGRATED`

`REWARD_BAR_UI: READY`

`REWARD_FIVE_TASK_CYCLE_UI: OWNER_FINAL`

`REWARD_ECONOMICS_BACKEND: DEFERRED`

`FINAL_UI_FOUNDATION_MAIN: PASS`

`HOME_FINAL_UI_V1_MAIN: PASS`

`FIVE_TASK_REWARD_UI_MAIN: PASS`

`REWARD_ENGINE_IMPLEMENTED: NO`

`UI_ROLLOUT_MODEL: SINGLE_UI_AGENT`

`NEXT_UI_STREAM: CATEGORY_RECURSIVE_BROWSE`

- Final UI rollout `ONE UI AGENT + INTEGRATION AGENT` modelidir. Üç paralel UI
  agentı/branch'i hazırlanmaz veya etkinleştirilmez.
- Her major screen tek UI Agent tarafından bir `390 px` prototype olarak hazırlanır;
  Product Owner visual approval sonrasında aynı agent responsive/state/accessibility
  ve regression closeout'u tamamlar, Integration Agent main'e alır.
- `EsnaftaVarColors`, theme, spacing/radii/elevation/icon/touch-target tokenları ile
  Scaffold, SectionHeader, StateCard, SurfaceIconButton ve RewardProgressSlot/Card
  shared hotspot'tur. Aktif screen lane'i gerekli değişikliğin tek sahibidir;
  başka UI lane'i aynı anda bunları değiştirmez.
- Screen-local duplicate component/token/theme kurulmaz. Gerçek shared değişiklik
  açıkça kaydedilir ve Home regresyonuyla doğrulanır.
- Flutter Final UI foundation primary implementation reference'tır. Figma minimal
  ve selective visual reference olarak kullanılır; repeated exploratory reads veya
  paralel Figma/Flutter source-of-truth üretilmez.
- Sıradaki Category/Recursive Browse lane'i implementation ile başlamaz: önce bir
  `390 px` prototype ve Product Owner visual approval gerekir. Backend, taxonomy,
  Reward Engine ve release lanes ayrı authority/owner sınırlarında kalır.

## Wave 38G Real Development Acceptance Gözlemi

`REAL_DEVELOPMENT_CANONICAL_ACCEPTANCE: PASS`

`REAL_24_ROOT_ACCEPTANCE: PASS`

`VARIABLE_DEPTH_BREADCRUMB_SEARCH_ALIAS: PASS`

`PRODUCT_SCOPE_FAIL_CLOSED: PASS`

`PREVIEW_RESTORED_OFF: PASS`

`CANONICAL_TAXONOMY_DEVELOPMENT_DONE: YES`

`READY_FOR_FINAL_UI_KIT_ROLLOUT: YES`

- Preview acceptance tek integration/operatör lane'inde sıralı yürütüldü. Trusted
  setter, exact target JIT, real Flutter acceptance ve mandatory OFF restoration
  başka agentla paylaşılmadı.
- Real Development strict V2 client exact 24 root ve `1563` node tree'de L2/L3/L4
  navigation, server breadcrumb/search, dört alias state'i ve non-assignable exact
  leaf fail-closed davranışını kabul etti. Silent legacy fallback olmadı.
- İlk test-process initialization problemi remote state araştırılmadan önce preview
  OFF'a döndürülerek kapatıldı; yalnız acceptance harness düzeltildi ve ikinci bounded
  tur PASS oldu. Final preview/opt-in/canonical runtime OFF, iki ortamın default'u
  `LEGACY_RUNTIME`dır.
- Canonical taxonomy Development lane'i kapanmıştır. Final UI Kit rollout artık
  taxonomy architecture'a karşı başlayabilir; ancak component/tokens/navigation/
  category-search shared UI hotspot'ları açık owner sınırlarıyla bölünmelidir.
- SQL/migration lane'i, public/pilot activation, policy/professional review,
  Production taxonomy rollout, physical QR ve release gates UI Kit lane'ine
  karıştırılmaz. Production için yeni JIT + owner authority gerekir.

## Wave 38F Strict V2 Client Integration Gözlemi

`STRICT_V2_CLIENT_BINDING: PASS`

`BACKEND_CLIENT_COMPATIBILITY: PASS`

`ADAPTER_UPDATES_REMAINING: 0`

`BACKEND_BLOCKERS_REMAINING: 0`

`PREVIEW_REMOTE_ENABLED: NO`

`CANONICAL_RUNTIME_ACTIVE: NO`

- Agent3 strict V2 client teslimi tek shared-owner integration lane'inde
  çatışmasız entegre edildi. Adapter yedi strict read + capability V2 contract'ını,
  typed DTO/error mapping'i, server-authoritative exact-leaf/product scope'u ve
  explicit alias/search context'ini bağlar.
- Development ve Production default `LEGACY_RUNTIME` kalır. Development opt-in
  default OFF; Production eşdeğer opt-in sunmaz. Explicit canonical seçim yetersiz
  proof/preview-off/zero-root durumunda fail-closed'dur ve sessiz legacy fallback
  yapmaz.
- `service_locator.dart`, Development entrypoint, adapter, shared taxonomy/category/
  product modelleri ve navigation bu turda tek lane tarafından sahiplenildi.
  Production entrypoint statik olarak incelendi ve değişmedi.
- Gerçek preview acceptance W38G'de tek owner/operatör lane'iyle PASS tamamlandı.
  Public/pilot/runtime activation ve Production ayrı authority/lane olarak kapalı
  kalır; Final UI Kit/Figma rollout taxonomy architecture'a karşı başlayabilir.

## Wave 38D Development Strict Backend Contract Apply Gözlemi

`DEVELOPMENT_0011_APPLY: PASS`

`STRICT_V2_DEPLOYED: PASS`

`PREVIEW_REMOTE_ENABLED: NO`

`CANONICAL_RUNTIME_ACTIVE: NO`

- Tek backend/schema/SQL/migration owner lane'i iki JIT, exact candidate/main
  identity ve exact-one-pending linked CLI dry-run sonrasında yalnız corrected
  `0011`i Development'a uyguladı. Production erişimi yoktur.
- Remote ledger exact `11/11`; v1 `7/7`, strict v2 `8/8`, preview config OFF,
  taxonomy `1563` staged/inactive ve assignable/public/pilot `0/0/0` durumundadır.
- Migration lane'i tamamlandı. Sıradaki iki bounded client değişikliği sıralı ve tek
  shared-owner lane'inde yapılmalıdır: yedi strict read'in v2'ye atomik binding'i,
  ardından capability/runtime proof'un strict v2 DTO'ya bağlanması ve read acceptance.
- `service_locator.dart`, Development/Production entrypoint'leri, canonical adapter,
  shared taxonomy/category/product modelleri ve navigation aynı anda farklı agentlar
  tarafından değiştirilmez.
- Legacy runtime default kalır. Preview acceptance, public/pilot activation,
  canonical runtime, final UI Kit/Figma ve Production ayrı authority/lane'dir.

## Wave 38C-R Corrected Strict Backend Contract Entegrasyon Gözlemi (historical pre-apply)

`W38C_FIRST_ATTEMPT: FAIL / NO MERGE / NO REMOTE`

`W38B_R_CORRECTION: PASS`

`W38C_R_INTEGRATION: PASS`

`BACKEND_BLOCKERS_REMAINING: 0`

`DEVELOPMENT_WRITE_AUTHORIZED_AT_THAT_GATE: NO`

- İlk candidate non-assignable structural leaf'i product exact leaf kabul ettiği
  için reddedildi; eski `c4961f36...` SHA superseded'dır. Corrected candidate
  `63552485...` bağımsız negatif/pozitif exact-leaf gate, strict v2 `8/8`, v1
  `7/7`, 29-case matrix ve portable hash reproduction'dan geçti.
- W38D öncesindeki active remote migration zinciri `0001→0010`du. `0011` yalnız local
  staging artifact'ıdır; Development/Production access, apply, preview enablement
  veya runtime activation yapılmadı.
- Sonraki adım paralel değildir: **tek backend/schema/SQL/migration owner**, fresh
  owner authorization ve JIT gate ile exact corrected SHA üzerinde çalışmalıdır.
- `service_locator.dart`, Development/Production entrypoint'leri, adapter ve shared
  taxonomy/category/product modelleri bu apply lane'i sırasında başka agent
  tarafından eşzamanlı değiştirilmez. İki bounded adapter update'i remote postcheck
  sonrasında ayrı ve sıralı lane'de yapılır.
- Canonical runtime, public/pilot activation, final UI Kit/Figma ve Production lane'i
  ayrı authority olmadan açılmaz.

## Wave 38A Canonical Client Adapter Entegrasyon Gözlemi (historical pre-0011)

`CONCRETE_ADAPTER_INTEGRATED: PASS`

`CAPABILITY_PROOF_INTEGRATED: PASS`

`BACKEND_CANONICAL_COMPATIBLE_AT_W38A_GATE: NO`

`ACCEPTANCE_CLASSIFICATION: C — BACKEND CONTRACT CHANGE REQUIRED`

`LEGACY_RUNTIME_DEFAULT: PASS`

`CANONICAL_RUNTIME_ACTIVE: NO`

- Concrete RPC adapter, typed DTO mapping, capability verifier ve environment-specific
  DI, `service_locator.dart` ile iki entrypoint shared hotspot sahipliği integration
  lane'inde birlikte incelenerek entegre edildi. Development ve Production explicit
  legacy default'tur; canonical istek yetersiz proof'ta sessiz fallback yapmaz.
- Deployed endpoint `7/7` varlığı backend uyumluluğu değildir. Published client
  contract version, strict response alanları ve safe staged preview/capability
  response eksikleri current sonucu `BLOCKING_CONTRACT_MISMATCH` yapar.
- Bir sonraki iş tek backend/schema/SQL/migration owner'ına verilmelidir: additive
  strict backend contract migration. Bu sırada `service_locator.dart`, entrypoint'ler,
  shared taxonomy modelleri ve adapter başka agent tarafından eşzamanlı değiştirilmez.
- Backend contract delivery sonrası capability/read acceptance ayrı sıralı gate'tir;
  canonical runtime activation, public/pilot activation ve Production lane'i ayrıca
  yetkilendirilmeden açılmaz.

## Wave 37C Development Staged Bootstrap Entegrasyon Gözlemi

`DEVELOPMENT_STAGED_BOOTSTRAP: PASS`

`EXACT_AUTHORIZED_ARTIFACT_APPLIED: YES`

`PUBLIC_TAXONOMY_ACTIVE: NO`

`CANONICAL_CUSTOMER_MODE_ACTIVE: NO`

`READY_FOR_DEVELOPMENT_BACKEND_CLIENT_CUTOVER: YES`

- Tek backend/schema/SQL/migration owner lane'i iki JIT ve exact-one-pending CLI
  dry-run sonrasında `0010`u yalnız Development'a uyguladı. Production erişimi yoktur.
- Remote ledger artık exact `10/10`; taxonomy `1563` node ile staged/inactive,
  RLS `28/28`, RPC `7/7`, public/pilot/policy leakage `0` durumundadır.
- Migration lane'i tamamlandı. Sıradaki Customer backend adapter/capability/DI
  cutover lane'i sıralı handoff ile yürür; migration, `service_locator.dart`, shared
  taxonomy/category/product modelleri farklı agentlarda eşzamanlı değiştirilmez.
- Public/pilot activation, professional/policy review activation, demo mapping,
  UI Kit/Figma ve Production lane'leri açılmamıştır.

## Wave 37B Ledger Guard Fix / Retry Freeze Entegrasyon Gözlemi (historical pre-apply)

`MIGRATION_HISTORY_GUARD_FIXED: PASS`

`LEDGER_FIX_INTEGRATED: YES`

`EXACT_RETRY_ARTIFACT_FROZEN: YES`

`REMOTE_RETRY_AUTHORIZED: NO`

`READY_FOR_FRESH_DEVELOPMENT_WRITE_AUTHORIZATION: YES`

- İlk Wave 37 turu, ledger `name` semantiğini full repository filename sanan
  compiler guard nedeniyle remote erişimden önce NO-GO oldu. Agent 2'nin explicit
  exact `(version,name)` düzeltmesi conflictsiz entegre edildi.
- Tek backend/schema/SQL/migration owner kuralı sürer. Aktif zincir `0001→0009`
  ve `9/9`; `0010` eklenmedi. Yeni `40fade...` candidate yalnız local staging'de
  frozen'dır ve remote apply yetkisi değildir.
- Frozen category payload/UUID değişmedi. Yeni normalized/artifact/candidate
  kimlikleri `f73d6c...` / `840ab0...` / `40fade...`; LF/CRLF portability ve exact
  local replay/failure/ledger/parser/Flutter contract kapıları PASS.
- Bir sonraki adım paralel production işi değildir. Fresh owner Development-write
  authorization, ayrı authorized read-only JIT snapshot, single-writer/write-freeze
  ve operator/rollback/postcheck gate'leri sıralı kapanmalıdır.
- Customer runtime/DI, `service_locator.dart`, shared taxonomy/category/product
  modelleri, Flutter/Figma ve Production lane'i bu integration'da değişmedi ve
  remote retry/activation ile eşzamanlı farklı owner'a verilmez.

## Wave 36 Exact Taxonomy Final Pre-Apply Entegrasyon Gözlemi (historical)

`FROZEN_BOOTSTRAP_PACKAGE: PASS`

`EXACT_MIGRATION_REHEARSAL: PASS`

`CUSTOMER_CANONICAL_WIRING: PASS`

`LEGACY_RUNTIME_DEFAULT: PASS`

`READY_FOR_JIT_DEVELOPMENT_PRECHECK: YES`

`READY_FOR_DEVELOPMENT_WRITE_DECISION: YES`

`DEVELOPMENT_WRITE_AUTHORIZED: NO`

`READY_FOR_REMOTE_APPLY_NOW: NO`

`CANONICAL_RUNTIME_ACTIVE: NO`

- Source A/B/C A → B → C sırasıyla conflictsiz entegre edildi. Exact package
  `d9c45a1` / `095849...` altında frozen; altı payload ve `1563` UUID değişmedi.
- Migration compiler/JIT/rehearsal tooling lane'i **tek backend/schema/SQL/migration
  owner** sorumluluğundadır. Remote mode yoktur; active migration zinciri değişmedi.
- Bir sonraki yetkili adım yalnız JIT read-only Development precheck'tir. Exact ref,
  `0/0/0/0`, ledger/schema drift, single-writer freeze, package/artifact lineage ve
  operator rollback readiness kapanmadan write lane'i başlamaz.
- Customer canonical adapter/DI activation ayrı ve sıralı handoff gerektirir.
  `service_locator.dart`, global navigation, shared taxonomy/category/product models
  ile repository wiring'i backend apply lane'iyle farklı agentlarca eşzamanlı
  değiştirilmez. Current default `LEGACY_RUNTIME` kalır.
- Professional/policy gate'ler staged inactive existence'ı engellemez; assignability,
  public/pilot activation için fail-closed kalır. Final UI Kit/Figma rollout ancak
  Development taxonomy + client acceptance sonrasında başlar.
- Production lane'i kapalıdır; empty-Development recreation riskini owner henüz
  kabul etmemiştir ve bu risk hiçbir koşulda Production'a genellenmez.

## Wave 35 Taxonomy Development Cutover Readiness Entegrasyon Gözlemi (historical)

`LIVE_DEVELOPMENT_PREFLIGHT: PASS`

`LOCAL_MIGRATION_REHEARSAL: PASS`

`CUSTOMER_VARIABLE_DEPTH_PREP: PASS`

`CLEAN_ROOM_LIVE_PARITY: PASS`

`CLIENT_CONTRACT_LIVE_PARITY: PASS`

`READY_FOR_LOCAL_IMPLEMENTATION_PREPARATION: YES`

`READY_FOR_DEVELOPMENT_WRITE_AUTHORIZATION: NO`

`READY_FOR_REMOTE_APPLY_NOW: NO`

`TAXONOMY_RUNTIME_ACTIVE: NO`

- Üç source normal `--no-ff` ile conflictsiz entegre edildi. Development Healthy ve
  bütün 23 application tablosu boş; current UUID/product/split/manual workload `0`.
  PGlite + SQLite rehearsal forward/rollback/idempotency/failure gatesini kapattı;
  Customer saf domain prep'i current backend/runtime davranışını değiştirmedi.
- Sıradaki yerel implementation/artefact hazırlığı **tek backend/schema/SQL/migration
  owner** altında yürütülmelidir. Aynı owner reviewed 1,563-entry UUIDv4 allocation
  ledger, active migration, staged import, RLS/RPC contract, pre/postflight ve
  rollback artefaktlarını yönetir.
- Customer cutover lane'i yalnız backend response/capability contract'ı freeze
  edildikten sonra başlar. `service_locator.dart`, global navigation, shared
  category/product model ve repository wiring'i backend migration lane'iyle aynı
  anda farklı agentlarca değiştirilmez; planlı handoff veya sıralı ownership gerekir.
- Manual product reclassification, split queue ve 24 legacy disposition mevcut
  Development'ta zero-row oldukları için additive schema/staged inactive importu
  bloklamaz. 18 anchor assignability ile policy/professional review activation ve
  public visibility için fail-closed kalır.
- Free Development planında native backup/PITR yoktur ve restore kanıtlanmamıştır.
  18 anchor state'i, exact active artefact rehearsal, rollback/recreation acceptance,
  versioned RLS-safe backend contract, JIT zero-row/drift/single-writer gate ve ayrı
  owner authorization kapanmadan Development write yetkisi verilmez. Production
  lane'i açılmamıştır.
- UI Kit/Figma/demo, taxonomy activation ve Production bu wave'in dışında kalır.
  Client seam'i hazırdır fakat runtime'a wired değildir.

## Wave 34 Taxonomy Runtime Readiness Entegrasyon Gözlemi

`FULL_CANONICAL_MANIFEST: PASS — PLANNING ONLY`

`MIGRATION_ENGINEERING_PLAN: PASS`

`CUSTOMER_APP_IMPACT_PLAN: PASS`

`REMOTE_DEVELOPMENT_MIGRATION: NOT READY / NOT AUTHORIZED`

`RUNTIME_IMPLEMENTATION: NO`

- Üç source docs-only ve dosya düzeyinde ayrık olduğu için sıralı normal `--no-ff`
  merge edildi. Full planning manifest `1563` node / `1245` leaf, legacy `651/651`
  ve successor `1000/1000` bütünlüğünü sağlar; production UUID içermez.
- Bir sonraki taxonomy runtime wave'inde **tek backend/schema/migration owner**
  bulunmalıdır. Bu owner stable-ID ledger, additive schema, RLS/RPC, import,
  product mapping, demo dependency ve rollback artefaktlarını birlikte yönetir.
- Customer App compatibility ayrı bir client owner'a verilebilir; fakat backend'in
  versioned root/children/path/lifecycle/assignability ve exact/descendant contract'ı
  freeze edilmeden shared category/product models üzerinde çalışmaya başlanmaz.
- `service_locator.dart`, global navigation, category/product shared modelleri ve
  migration chain eşzamanlı birden fazla agent tarafından değiştirilmez. UI Kit
  lane'i correctness/runtime client support kanıtlanana kadar bekler.
- Electronics/Computer graph coverage tamamdır; detaylandırılmamış `18` L2'nin
  runtime leaf/assignability/activation freeze'i açık olduğundan manifest değerleri
  remote activation authority değildir.
- `210` split / `591` successor edge product-level classification işi ile `24`
  (`5 manual + 19 policy`) legacy queue ayrıdır. Actual product workload yalnız
  authorized read-only Development inventory sonrası kesinleşir.
- Güvenli sonraki iki lane sıralıdır: (1) read-only Development preflight,
  (2) disposable local clean-room candidate/rehearsal. Local rehearsal remote apply
  yetkisi vermez; Development apply ve Production her zaman ayrı change window'dur.

## Wave 33 Canonical Product Taxonomy V1 Entegrasyon Gözlemi

`PRODUCT_TAXONOMY_DESIGN_COMPLETE: YES`

`PRODUCT_TAXONOMY_OWNER_FINAL: YES`

`STRUCTURAL_OWNER_DECISIONS: 0`

`PROFESSIONAL_REVIEW_GATES: OPEN`

`RUNTIME_IMPLEMENTATION: NO`

- Wave 32'nin üç ayrık full-tree design batch'i ile Wave 33 semantic audit,
  structural validator ve legacy bridge simulation teslimleri istenen sırada altı
  normal `--no-ff` merge ile conflict olmadan entegre edildi. Kaynak ve integration
  değişiklikleri yalnız `docs/` kapsamındadır.
- Canonical architecture toplam `24` L1'dir. Mevcut Elektronik/Bilgisayar & Tablet
  anchor'ları değişmeden korunmuş, kalan `22` detaylı L1 için owner-final resolved
  tasarım `224` L2 / `1078` L3 / `185` L4 / `1199` leaf / `1487` row olarak
  kilitlenmiştir. Stable ID veya runtime node üretilmemiştir.
- Bir sonraki stable-ID/runtime işi **tek taxonomy/schema/migration owner'ına**
  verilmelidir. Aynı wave'de ikinci SQL/migration yazarı çalıştırılmaz; migration
  zinciri, taxonomy ID registry, shared category/product modelleri, demo mapping ve
  rollback planı tek sahipte tutulur.
- `service_locator.dart`, global navigation ve shared modeller runtime taxonomy ile
  aynı anda başka agent tarafından değiştirilmemelidir. Customer taxonomy UI ve
  merchant catalog işleri, ID/read-path sözleşmesi main'e entegre edilmeden başlamaz.
- Legacy `UNRESOLVED 24` mapping boşluğu canonical ağacı yeniden açmaz; stable-ID
  planından önce sıralı ve exact successor review ile kapatılır. Blind fuzzy mapping,
  runtime alias/redirect veya node retirement bu docs-only wave'in yetkisi değildir.
- `840` professional-review leaf ayrı hukuk/regulatory/domain sahiplerine bölünebilir;
  fakat bu incelemeler canonical taxonomy dosyasını paralel biçimde yeniden yazmaz.
  Policy kararları tek coordination owner üzerinden reconcile edilir.
- Development önce yalnız read-only inventory ile ele alınır. Development apply ve
  Production migration ayrı açık yetki, tek SQL sahibi ve integration postflight ister.

## Wave 31 Master Owner Decisions Entegrasyon Gözlemi

`MASTER_OWNER_ROOTS: 24 FINAL / 0 OPEN / 3 PROVISIONAL / 4 DEFERRED`

`SOURCE_RECORD_RECONCILIATION: 204/204 PASS`

`CUSTOMER_UI_OWNER_DIRECTION_GATE: RESOLVED`

`PROFESSIONAL_REVIEW: OPEN WHERE ROUTED`

`RUNTIME_IMPLEMENTATION: NO`

- Agent 2'nin `4dbba80` final docs-only karar teslimi current
  `origin/main@fca935f` tabanına `3738a8b` ile tek `--no-ff` ve çatışmasız merge
  olarak entegre edildi. Kaynak scope yalnız `17` decision-support belgesidir.
- `OM-R08`, `OM-R25`, `OM-R26` seçenek seçilmeden `PROVISIONAL`; `OM-R27`–
  `OM-R30` seçenek seçilmeden `DEFERRED` kaldı. Public reputation/badges, Ads ve
  Rewards bu wave'de implementation lane'i değildir.
- `OM-R06=B` taxonomy runtime stratejisini, `OM-R07=B` catalog identity yönünü
  sabitler; ikisi de ID üretimi, runtime/schema/migration, demo cleanup veya remote
  ortam yetkisi vermez. Gelecek taxonomy/catalog runtime işi tek migration/schema
  owner'ı ve shared-model sıralı sahipliğiyle ayrıca planlanmalıdır.
- `OM-R11=B` minimum-safe pilot Merchant App yönüdür; full Merchant App kapsamı
  değildir. Merchant runtime ve customer UI implementation ayrı yetkili wave'lerde
  yürütülmeli; global navigation, design system, shared models ve DI hotspot'ları
  eşzamanlı sahiplenilmemelidir.
- Lawyer, KVKK, regulatory ve accountant/tax rotaları ürün kararıyla kapanmadı.
  Physical/exact-artifact, runtime/evidence ve Production launch gate'leri açıktır.

## Wave 16 Customer App Closeout Entegrasyon Gözlemi

`CUSTOMER_APP_CORE_FUNCTIONAL_AUDIT: PASS`

`P0: 0`

`SAFE_RUNTIME_REMEDIATIONS: 3 INTEGRATED`

`ANALYZER: PASS`

`FULL_TESTS: 1226 PASS / 0 FAIL / 6 EXPLICIT LIVE SKIPS`

`CUSTOMER_CORE_FUNCTIONALLY_COMPLETE: YES`

`FEATURE_FREEZE: CONDITIONAL`

`COMMERCIALIZATION: CONDITIONAL`

- Agent 1'in `1f1812c` customer commercialization closeout teslimi current
  `origin/main@f092cf8` tabanına `f9f9a2c` ile tek `--no-ff` ve çatışmasız merge
  olarak entegre edildi. Kaynak scope `84` audit/closeout doc, `10` runtime ve `7`
  test dosyasıdır; integration yalnız iki mevcut test dosyasında retry/unlock
  regression kanıtını güçlendirdi ve üç merkezi coordination belgesini hizaladı.
- `CUST-REL-001`, `CUST-AUTH-001` ve `CUST-CART-001` safe remediation'ları PASS:
  release diagnostics hassas içerik taşımaz, duplicate in-flight signup tek use-case
  çağrısıyla sınırlıdır ve Cart V2 replace işlemi ortak exclusive mutation guard'ını
  kullanır. Debug diagnostics, auth retry, mutation unlock ve single-store conflict
  davranışları korunur.
- Hedefli paket `48/48`, tam suite `1226` PASS / `0` FAIL / `6` aynı gerekçeli live
  skip ve analyzer `0` bulgu ile PASS. Test/skip zayıflatması yapılmadı.
- `OWNER_DECISION_REQUIRED: RECENT_SEARCH_HISTORY` ve
  `OWNER_DECISION_REQUIRED: PRE_LOGIN_CHAT_DRAFT` açık bırakıldı. Nearby'de guest
  runtime/anonymous Production smoke ile beklenen authenticated personalization
  yönü çelişkili olduğundan `OWNER_DECISION_REQUIRED: NEARBY_GUEST_POLICY`
  korundu; integration karar vermedi ve mevcut davranışı değiştirmedi.
- Taxonomy runtime, final UI kit, Ads, gamification/reward, Merchant App, schema/
  migration, remote Production/Development veya release artifact değişikliği yoktur.
  Bu alanlar aynı wave'e sessizce taşınmaz; taxonomy/shared model ve UI hot-spot
  sahiplikleri mevcut tek-owner/sıralı çalışma kuralını korur.
- Owner micro-policy kararları, taxonomy runtime, final UI kit, fiziksel QR, final
  artifact/device/store acceptance ve Production manual go/no-go açık gate'tir.
  Customer core completion bu gate'leri kapatmaz ve commercial GO değildir.

## Wave 1 Entegrasyon Gözlemi

- 2026-08-11 Wave 1'de LANE B chat, LANE C in-app notifications ve LANE D QR/purchases işleri üç production agent ile yürütüldü.
- Gerçek değişen dosya kümeleri ayrık kaldı; `service_locator.dart`, navigation, app bootstrap, ortak modeller ve canonical schema dosyalarında çakışma olmadı. Üç branch çatışmasız entegre edildi.
- Yalnız LANE D yeni bir additive QR RPC hardening migration dosyası ekledi. Dosya statik olarak güvenli ve mevcut RPC imzalarıyla geriye uyumlu bulundu; gerçek PostgreSQL/test Supabase uygulama doğrulaması hâlâ açık gate'tir.
- Bu gözlem yalnız aynı derecede izole iş paketlerinde `3 production agents` kullanımını destekler; genel güvenli paralellik sayısını artırmaz ve shared/hot-spot kapsamlarında 2 veya 1 agente düşme kuralını değiştirmez.

## Wave 2 Entegrasyon Gözlemi

- 2026-08-11 Wave 2'de environment separation, discovery async hardening ve legacy order isolation işleri üç ayrı kalıcı worktree/branch üzerinde aynı `origin/main` tabanından yürütüldü ve çatışmasız entegre edildi.
- Shared `pubspec.yaml` değişikliği yalnız environment agentında kaldı. Legacy DI wiring temizliği production branch'lerine dağıtılmayıp planlandığı gibi integration agentı tarafından `service_locator.dart` içinde yapıldı.
- Discovery agentının eski main tabanında test bootstrap'ı için kullandığı secretsız geçici `.env` placeholder'ı commit edilmedi; environment branch'inin `.env` asset kaydını kaldırması birleşik durumda bu worktree bağımlılığını ortadan kaldırdı.
- Bu sonuç kalıcı ayrık worktree modelinin shared alan sahipliği önceden belirlendiğinde çalıştığını doğrular; güvenli agent sayısını otomatik artırmaz ve hot-spot kapsamlarında 2 veya 1 agente düşme kuralını değiştirmez.

## Wave 3 Entegrasyon Gözlemi

- 2026-08-12 Wave 3'te canonical Supabase migration normalization, promotion banner read-path hardening ve kalan async-context lint temizliği aynı `origin/main` tabanından üç kalıcı task branch'inde yürütüldü ve sıralı `--no-ff` merge'lerle çatışmasız entegre edildi.
- Ortak SQL/migration alanının tek sahibi Agent 1 olarak kaldı; banner ve async-context dosya kümeleri migration zinciriyle çakışmadı. Integration agentı canonical chat/notification mutation grantlerini aktif istemcinin yalnız `is_read` güncellemesiyle sınırlandırdı ve contract testlerini güçlendirdi.
- Eski audit modelindeki 25 tablo ile canonical 23 tablo arasındaki fark `cart_items` ve `coupons` olarak kapatıldı. İki tablo da aktif repository sorgularında kullanılmıyor; aktif sepet `carts/cart_items_v2`, kupon ekranı ise backend bağlantısı olmayan skeleton durumunda. `orders/order_items` ürün yorumu bağı nedeniyle korunuyor.
- Global `use_build_context_synchronously` ignore'u kaldırıldı. Canonical contract, banner, async-context, chat, notifications, cart/QR/purchases ve discovery/navigation hedefli matrisleri ile tam Flutter suite ve analyzer temiz geçti.
- Bu dalga, migration zinciri gibi tek shared SQL sahibine ayrılmış bir alanın iki izole istemci işiyle birlikte güvenle yürütülebileceğini gösterir; gerçek Supabase uygulaması, Storage policy kararları veya başka bir ortak schema yazarı olan wave'lerde güvenli paralellik ayrıca yeniden değerlendirilir.

## Wave 3.1 Hotfix ve Development Bootstrap Gözlemi

- 2026-08-12 Wave 3.1'de yalnız `0004` ve `0006` içindeki PostgreSQL özel identifier çakışmaları düzeltildi; `0001`–`0003`, SECURITY DEFINER/RLS/grant davranışı ve diğer canonical DDL değişmedi. Regression koruması canonical contract testine eklendi.
- Hotfix `integration/wave-3-1-qr-hotfix` branch'inde çatışmasız `--no-ff` merge edildi, hedefli 17/17 test ve analyzer sonrasında `origin/main`e normal fast-forward push edildi.
- Development Supabase canonical bootstrap tamamlandı: 23 public tablo, 7 sıralı migration, 23/23 RLS, 55 policy, canonical anon/auth grant matrisi ve 19 app fonksiyonu remote audit ile doğrulandı. `chat_messages` ve `notifications` Realtime publication üyesidir.
- Seed, test kullanıcısı, demo mağaza/ürün ve Storage bucket/policy oluşturulmadı. Altı Storage bucket'ının ürün-policy kararları ile gerçek backend davranış integration testleri açık blocker/gate olarak kalır.
- Shared migration alanındaki statik sözleşme testleri gerçek PostgreSQL parser kapısının yerini tutmaz; gelecekteki canonical SQL değişiklikleri tek SQL sahibi, integration review ve Development parse/apply doğrulamasını birlikte gerektirir.

## Wave 4.1 Development Profile Role Guard Gözlemi

- 2026-08-14 tarihinde canonical `0008_fix_profile_role_guard` yalnız EsnaftaVar Development projesine uygulandı; sıralı migration sayısı 8'e çıktı ve 23 public tablo ile mevcut RLS/policy durumu değişmedi.
- Normal authenticated profile update smoke geçti; `merchant` ve `admin` escalation denemeleri `42501` ile reddedildi, final rol `customer` kaldı ve PostgreSQL `42883` görülmedi. Disposable müşteri `delete_current_customer_account` RPC'siyle temizlendi.
- Bu minimal smoke sonrasında Agent 1 tam Wave 4 Auth/RLS canlı harness'ini başarıyla yeniden çalıştırdı; normal profil güncellemesi, ownership/RLS isolation ve rol escalation reddi birlikte doğrulandı.

## Wave 4 Final Entegrasyon Gözlemi

- 2026-08-15 Wave 4'te Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime live doğrulama dalları belirtilen sırayla `--no-ff` ve çatışmasız birleştirildi; üç agent merge commit'i korundu.
- Agent 1 live Auth/Profile/RLS, Agent 2 live QR/verified purchase ve gerçek concurrent confirm, Agent 3 live Chat/Notifications Realtime sonuçları **PASS** olarak kaydedildi. Development test verisi güvenli, scoped cleanup yollarıyla temizlendi.
- Wave 4 dalları canonical `0001`–`0008` migration zincirini, RLS/policy'leri, Auth config'i veya Storage'ı değiştirmedi. MCP read-only postflight 23 public tablo, 8 migration ve 23/23 RLS durumunu doğruladı; Production'a dokunulmadı.
- Agent 3'ün tek production-code değişikliği, bildirim Realtime stream'inin geçici `channelError`/`timedOut` durumlarında kapanmasını önler; yalnız terminal `closed` stream'i kapatır. Hedefli testte tekrar subscription üretmeden ve dispose davranışını değiştirmeden doğrulandı.
- Birleşik hedefli matris 998/998 (4 gated live skip), tam Flutter suite 1069/1069 (3 gated live skip) ve analyzer temiz geçti. Integration ortamında client-safe Development değerleri bulunmadığı için üç live harness yeniden çalıştırılmadı; bağımsız agent PASS sonuçları geçerlidir.
- Wave 4 kapanışında açık olan kapılar: fiziksel iki cihaz QR kabulü; altı Storage bucket'ının ürün-policy kararları ve sonraki implementasyonu; gerçek Development Dart-define build/smoke; ürün yorumu eligibility kararı; bu karardan sonra eventual legacy `orders/order_items` kaldırma değerlendirmesi; production-like e-posta doğrulama/SMTP kabulü. Development smoke ve eligibility kararının sonraki durumu aşağıdaki Wave 5 gözleminde kayıtlıdır.

## Wave 5 Final Entegrasyon Gözlemi

- 2026-08-15 Wave 5'te Agent 1 Development istemci smoke işini kod veya commit üretmeden **PASS** tamamladı; branch'i `origin/main` ile aynı kaldığı için sahte/no-op merge yapılmadı.
- Agent 2'nin yalnız `docs/STORAGE_CONTRACT_AUDIT.md` ekleyen branch'i, ardından Agent 3'ün review eligibility/legacy order doküman branch'i zorunlu sırayla `--no-ff` ve çatışmasız birleştirildi. Migration, schema, Storage bucket/policy veya uygulama kodu değişmedi.
- Ürün yorumu için Option A **FINAL**: yalnız merchant tarafından doğrulanmış, server-authoritative fiziksel QR alışverişi ve ilgili ürün satırı eligibility verir; ürün görüntüleme, sepete ekleme veya yalnız QR oluşturma vermez. Audit mevcut kodun bu kararı henüz uygulamadığını doğruladı.
- Storage auditi mevcut bucket referanslarını ve kullanım sözleşmelerini kaydetti. Repoda daha yeni FINAL owner kararı bulunmadığından görünürlük, yazan roller, object path sahipliği, MIME/size, silme ve retention başlıkları gerçek `OWNER DECISION REQUIRED` olarak açık tutuldu; hiçbir backend yazması yapılmadı.
- Birleşik review/QR/shop rating/Storage contract/legacy architecture hedefli matrisi 169/169, tam Flutter suite 1069/1069 (3 güvenlik-gated live skip) ve analyzer temiz geçti. Agent 1'in Development web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure smoke sonucu ayrıca PASS'tir.
- Açık kapılar: Option A server-authoritative eligibility implementasyonu; tarihsel veri/backfill ve doğrulanmış alışveriş etiketi kararı; Storage owner kararları ve least-privilege implementasyonu; fiziksel iki cihaz QR kabulü; Production smoke ve production-like e-posta/SMTP kabulü. Legacy `orders/order_items` bu bağımlılıklar ve hesap silme referansları çözülmeden kaldırılamaz.

## Wave 6 Final Entegrasyon Gözlemi

- Agent 1 backend/migration, Agent 2 review client ve Agent 3 Storage client dalları belirtilen sırayla `--no-ff` ve çatışmasız birleştirildi. SQL/migration sahipliği yalnız Agent 1'de, `service_locator.dart` sahipliği yalnız Agent 2'de ve ortak medya modelleri yalnız Agent 3'te kaldı.
- Canonical `0009_verified_product_reviews_storage` Development'ta exact remote migration kaydıyla doğrulandı ve entegrasyon sırasında yeniden uygulanmadı. Production erişimi veya yazması yapılmadı.
- Frozen review RPC isimleri/parametreleri/JSON/error sözleşmesi backend ile Agent 2 istemcisinde birebir eşleşti. Review mutasyonları RPC-only, verified durumu server-derived ve evidence immutable kaldı; normal Auth client canlı create/duplicate/update/delete/recreate ve unverified rejection akışı 3/3 geçti.
- Agent 3 controlled-path resolver'ı backend sözleşmesindeki tam segment sayısı, `v<14 digit>` sürüm klasörü, lowercase safe filename ve JPEG/PNG/WebP allowlist'iyle hizalandı. Legacy HTTPS okuma uyumluluğu korundu; yeni client Storage write/update/delete eklenmedi.
- Yalnız izole Wave 6 Development fixture'ları temizlendi; review, verified transaction/item, listing, shop, product ve üç Auth test hesabında residual `0` doğrulandı.
- Hedefli matris 189/189, tam Flutter suite 1106/1106 (opt-in live testler normal koşuda skip), ayrı Development live review harness'i 3/3 ve analyzer PASS oldu. Açık release kapıları: fiziksel iki-cihaz QR kabulü, Production smoke, production-like e-posta/SMTP kabulü, deferred `brand-logos`/`avatars`/`review-images` ve ayrı yetkili legacy order final drop.

## Wave 7 Final Entegrasyon Gözlemi

- Agent 1 fiziksel iki-cihaz QR kabulü için kod/diff üretmedi; branch'i Wave 6 main ile aynı kaldığından merge edilmedi. İki kamera-capable fiziksel cihaz bulunmadığı için `PHYSICAL_TWO_DEVICE_ACCEPTANCE: BLOCKED` korunur; otomatik testler bu gate'i kapatmaz.
- Agent 2 Auth hardening, ardından Agent 3 Production readiness audit branch'i `--no-ff` ile entegre edildi. Android manifestteki örtüşme; INTERNET, coarse/fine location, camera ve tek Auth callback kaydını koruyacak şekilde çözüldü. iOS otomatik birleşimindeki çift `CFBundleURLTypes` semantik olarak tekilleştirildi; location/camera açıklamaları korundu.
- PKCE recovery callback, Android/iOS `io.supabase.tstore://login-callback/` kaydı, enumeration-safe signup, Android release internet izni ve Development/Production config izolasyonu birleşik durumda doğrulandı. Secret/service-role eklenmedi ve legacy auth hattı geri gelmedi.
- Agent 3'ün `PRODUCTION_READINESS_AUDIT.md` ve `PRODUCTION_SMOKE_CHECKLIST.md` çıktıları entegre edildi. Gerçek Production config/migration/backup/smoke, Auth/SMTP, signing/app identity, sosyal login kararı, fiziksel QR ve Iconsax default release build sorunu açık gate olarak korundu.
- Hedefli Auth/platform/config matrisi 186/186, release-readiness sözleşme matrisi 67/67, tam Flutter suite 1113/1113 (4 opt-in Development live skip), analyzer, XML/diff/security taraması PASS oldu. Sentetik client-safe değerlerle `main_production.dart` compile contract'ı `--no-tree-shake-icons` ile geçti; bu Production smoke değildir. Remote backend/config yazması yapılmadı.

## Wave 8 Final Entegrasyon Gözlemi

- Agent 1 release dependency/compatibility ve import alanını, Agent 2 yalnız aktif Login/Signup sosyal UI temizliğini, Agent 3 yalnız Production cutover/GO-NO-GO belgelerini sahiplendi. Üç dal zorunlu sırayla `--no-ff` ve çatışmasız birleştirildi.
- Shared `pubspec.yaml`/lockfile yalnız Agent 1'de kaldı. SQL/migration, `service_locator.dart`, shared model veya app bootstrap değişmedi; Agent 1 ve Agent 2'nin Auth dosyalarındaki ayrık değişiklikleri semantik olarak birlikte doğrulandı.
- Eski `iconsax 0.0.8` ve `IconData(0x0)` yüzeyi kaldırıldı. `iconsax_flutter 1.0.1` yalnız repo-local sınırlı compatibility katmanı üzerinden kullanılıyor; standart Web release build ek icon workaround'u olmadan PASS.
- Aktif Login/Signup UI'da işlevsiz sosyal düğme/ayırıcı kalmadı; e-posta/parola, kayıt, recovery ve Wave 7 PKCE/deep-link hardening'i korundu. OAuth/provider abstraction gelecekteki optional özellik için silinmedi.
- Production cutover planı 0001–0009 artifact/hash envanteri, read-only discovery, backup/restore, apply, RLS/RPC/Storage postflight, Auth/email, client config, smoke ve GO/NO-GO kapılarını tahmini Production PASS iddiası olmadan tanımlar. Entegrasyonda yakalanan `0001` hash uyuşmazlığı canonical dosya değeriyle düzeltildi.
- Hedefli 56/56, cutover belge/hash 20/20 ve tam Flutter suite 1116/1116 (4 opt-in Development live skip) PASS. Fiziksel iki-cihaz QR, production-like email, gerçek Production ref/config, migration inventory/apply, backup/restore, postflight/smoke ve mobil signing/app identity kapıları açık; remote backend/config yazması yapılmadı.

## Wave 9 Final Entegrasyon Gözlemi

- Agent 1 Production read-only discovery, Agent 2 mobile identity/signing ve Agent 3
  Production config preflight dalları zorunlu sırayla `--no-ff`, çatışmasız entegre
  edildi. SQL/migration, `service_locator.dart` ve shared model değiştirilmedi.
- `EsnaftaVar Development` (`tnipyxnvhgelwdpykyez`) Production olarak kesin dışlandı;
  `ieebtdvvinqfatbhkyqi` canonical sahiplik kanıtı olmadığı için Production sayılmadı,
  envanterlenmedi ve hiç yazılmadı. `PRODUCTION_PROJECT_IDENTIFICATION_REQUIRED`
  açık kaldı.
- Migration 0/9 farkının kök nedeni Windows CRLF checkout hash'iydi. Git geçmişi,
  Development apply kanıtları ve tracked blob'lar karşılaştırıldı; apply sonrası SQL
  mutation yok. Manifest canonical Git/LF sözleşmesine taşındı ve tekrar çalıştırılabilir
  araçla 9/9 PASS.
- Mobile release debug signing fallback'i kaldırıldı; Android packaging eksik
  credential'da fail-closed, iOS Release manual Apple Distribution contract'ında.
  `com.example.t_store`, `com.example.tStore` ve callback owner kararı olmadan
  değiştirilmedi; signed artifact üretilmedi.
- Production config preflight Development ref, eksik/placeholder/local/malformed
  config, ref-host farkı, server credential, yanlış target ve Auth redirect farkını
  fail-closed reddeder. Hedefli 62/62, tam 1136/1136 (4 gated live skip), analyzer,
  Web/Android compile contract ve Android development debug build PASS; backend remote
  write yapılmadı.

## Wave 10 Pre-Migration Entegrasyon Gözlemi

- Agent 1'in `origin/agent1/w10-production-readonly-verification` branch'indeki Phase A
  `8fb77f7` ve Phase B/C final `bfafef4` commit'leri, final HEAD üzerinden tek
  `--no-ff` merge ile çatışmasız entegre edildi. Değişiklik yalnız dört Production
  pre-migration belgesindeydi; SQL/migration, uygulama kodu, `service_locator.dart`
  veya shared model değişmedi.
- Canonical Production `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` / Frankfurt
  olarak doğrulandı; Development `tnipyxnvhgelwdpykyez` Production değildir. Fresh
  baseline'da migration ledger yok; public application table, Auth user, Storage
  bucket/object ve Realtime application membership sayıları sıfırdır.
- Tamamlanan kapılar: Production identity ve fresh baseline doğrulaması, canonical
  migration integrity 9/9, clean-room replay 9/9 ve pre-migration baseline/current
  state dokümantasyonu. Integration canonical migration contract testi 18/18 PASS.
- Açık kapılar: linked CLI Production dry-run; accepted rollback/RPO/RTO, restore ve
  incident owner/drill; Production canonical migration apply ve postflight; SMTP/email;
  fiziksel iki-cihaz QR; final app identifiers/signing ve Production smoke.
- Free plan scheduled backup/PITR/restorable point sağlamadığından
  `BACKUP_ROLLBACK_PLAN_READY: NO`; local safe-equivalent dry comparison PASS olsa da
  `READY_FOR_PRODUCTION_MIGRATION_APPLY: NO`. Integration sırasında Production veya
  Development remote erişimi/yazması ve migration apply yapılmadı.

## Wave 10 D0 Linked Dry-Run Entegrasyon Gözlemi

- Agent 1'in `676ef3e` linked CLI dry-run commit'i tek `--no-ff` merge ile çatışmasız
  entegre edildi. Değişiklik yalnız üç Production pre-migration belgesindeydi;
  SQL/migration, uygulama kodu, `service_locator.dart` ve shared model değişmedi.
- Exact Production `mefhfvrgkwciubeajjeb` üzerinde CLI dry-run yalnız canonical
  `0001→0009` pending sırasını gösterdi. Before/after remote state aynı, remote write
  `0`, migration apply `NO`; Development hedeflenmedi.
- Product owner yalnız tamamen boş ilk Production bootstrap'ı için native backup/PITR
  olmadan ilerleme riskini ve güvenli forward-fix yoksa empty-project recreation
  yolunu kabul etti. Bu istisna gerçek kullanıcı/veri sonrası değişikliklere otomatik
  yetki veya emsal değildir.
- `READY_FOR_PRODUCTION_MIGRATION_APPLY: YES` yalnız ayrı apply görevi/change window'u,
  exact ref/hash ve just-in-time zero-state recheck şartıyla geçerlidir. Postflight,
  SMTP/email, fiziksel QR, app identifiers/signing ve Production smoke açık kalır.

## Wave 10 D1 Production Migration Entegrasyon Gözlemi

- Agent 1'in `8e7517c` D1 migration apply/postflight kanıt commit'i tek `--no-ff`
  merge ile çatışmasız entegre edildi. Değişiklik yalnız beş Production durum
  belgesindeydi; migration SQL'i, uygulama kodu, `service_locator.dart`, shared model
  ve platform identifier dosyaları değişmedi.
- Agent kanıtında exact Production `mefhfvrgkwciubeajjeb` üzerinde canonical
  `0001→0009` ledger 9/9 ve metadata/security postflight PASS'tir: 23/23 tablo/RLS,
  52/52 policy, 28/28 app function, 25/25 trigger, 15/15 kritik RPC, exact Storage ve
  Realtime sözleşmesi; Auth ve business data `0`.
- Bu integration migration'ı yeniden uygulamadı ve Production/Development remote
  read/write yapmadı. Auth config, Storage object, fixture ve test user oluşturulmadı.
- Product owner final application/bundle identifier'ını `com.esnaftavar.app` olarak
  kesinleştirdi. Platform wiring sonraki Phase E'nin tek sahibinde kalmalıdır; mobil
  identifier/signing dosyaları başka agentlarla eşzamanlı değiştirilmemelidir.
- Phase E Production client wiring başlayabilir. Auth Site URL/redirect/SMTP, gerçek
  client-safe config, signing, controlled Production smoke ve fiziksel iki-cihaz QR
  commercial release kapıları olarak açık kalır.

## Wave 10 Phase E Final Entegrasyon Gözlemi

- Agent 1'in Production client wiring teslimi ve Agent 2'nin final mobile identity
  teslimi bu sırayla `--no-ff` ve çatışmasız entegre edildi. SQL/migration,
  `service_locator.dart`, shared model veya Supabase remote config değişmedi.
- Agent 1 kanıtında exact Production URL/ref ve değeri açığa çıkarılmayan client-safe
  publishable key ile anonymous read-only categories/products/shops/banners
  empty-state bağlantısı ve transient standart Web release build PASS'tir. Remote
  write, Auth user, business fixture veya Storage mutation `0` kaldı.
- Agent 2 final `com.esnaftavar.app` Android namespace/applicationId/MainActivity ve
  iOS Runner/RunnerTests kimliklerini bağladı; Development ID
  `com.esnaftavar.app.dev` oldu. Android signing fail-closed, iOS manual Apple
  Distribution sözleşmesi korunur; signing materyali ve signed artifact yoktur.
- Phase E anında callback `io.supabase.tstore://login-callback/` olarak kalmış ve
  final callback cutover, Site URL, web recovery ile SMTP/e-posta Phase F'e açık iş
  olarak devredilmişti.
- Birleşik config/Auth/platform/harness hedefli matris 61 PASS + 1 güvenli live skip,
  tam Flutter suite 1142 PASS + 5 opt-in live skip ve analyzer temizdir. Gerçek
  Production Web build, Android Development debug ve Production compile-only PASS;
  Production release packaging signing yokluğunda fail-closed kaldı.
- Açık commercial release kapıları: Auth Site URL/redirect allowlist/final callback,
  SMTP/e-posta, Android signing, Apple Team/certificate/profile, fiziksel iki-cihaz QR,
  controlled Production write smoke, fixture tabanlı Storage negative listing kabulü,
  signed AAB/APK/IPA ve commercial GO.

## Wave 10 Phase F Intermediate Entegrasyon Gözlemi

- Agent 1'in final Auth callback cutover teslimi (`44a83c5`) ve Agent 2'nin Production
  Auth/SMTP read-only precheck teslimi (`0881e5b`) zorunlu sırayla `--no-ff`
  entegre edildi. Tek conflict `PRODUCTION_SMOKE_CHECKLIST.md` içindeydi; callback'in
  artık kaynakta entegre olduğu güncel gerçek ile `PRODUCTION_SMTP_PRECHECK: FAIL`
  sonucu birlikte korunarak çözüldü.
- Callback/hot-spot kodunun tek sahibi Agent 1 olarak kaldı: `SupabaseService`, yeni
  merkezi callback contract'ı, `pubspec.yaml`/lockfile ve Android/iOS callback
  configuration. Agent 2 yalnız read-only remote kanıt ve release belgelerini
  değiştirdi. SQL/migration, `service_locator.dart`, shared model veya backend
  schema değişmedi.
- Production `com.esnaftavar.app://login-callback/`; Development
  `io.supabase.tstore://login-callback/` kullanır. Signup, resend ve recovery explicit
  environment redirect'i gönderir; broad otomatik URI algılama kapalı ve PKCE yalnız
  exact environment callback'inden sonra exchange edilir. Android Production/Dev ve
  iOS Profile/Release/Debug ayrımı aynı sözleşmeye bağlıdır.
- Read-only Production kanıtında Custom SMTP açıktır (`smtp.resend.com:465`, sender
  name `EsnaftaVar`), Confirm Email açıktır ve üç email template precheck'i PASS'tir.
  Site URL hâlâ localhost, HTTPS web recovery yok ve gerçek inbox kabulü yapılmadığı
  için live email readiness NO ve SMTP precheck FAIL kalır.
- Integration Production/Development remote read veya write, Auth config write,
  e-posta gönderimi, Auth user/fixture, Storage mutation ya da migration apply yapmadı.
- Birleşik Auth callback/PKCE/signup-resend-recovery/platform/preflight hedefli matrisi
  118/118, tam Flutter suite 1154 PASS (5 opt-in live skip), sentetik Production
  config contract preflight, analyzer, docs/diff ve security/secret scan PASS'tir.
- Açık Auth kapıları: final HTTPS Site URL/fallback kararı; web recovery route ve
  allowlist; real inbox confirmation/resend/password-recovery; sender/link-tracking
  final verification; kabul sonrasında legacy Production callback allowlist removal.
  Android/iOS signing, fiziksel iki-cihaz QR ve kontrollü Production smoke ayrıca
  açık commercial release kapılarıdır.

## Wave 10 Phase F Final Entegrasyon Gözlemi

- Agent 1'in F3/F3A/F3B/F3D canlı email acceptance ve cleanup evidence final HEAD'i
  (`8a23c23`) exact `b24f761` tabanından tek `--no-ff` merge ile çatışmasız entegre
  edildi. Input ve integration değişiklikleri yalnız canonical release/coordination
  belgeleridir; uygulama kodu, SQL/migration, `service_locator.dart`, shared model,
  dependency veya platform config değişmedi.
- F3 Dashboard `10 users (estimated)` sinyali F3A authoritative SQL ile
  `auth.users = 0` olarak çözüldü; estimated metric gerçek Auth row count değildir ve
  D1 zero baseline ile çelişmez.
- F3B Custom SMTP/Resend üzerinden gerçek inbox delivery, server-side confirmation,
  final callback email URL contract'ı ve default customer profile/role davranışını
  PASS doğruladı. Confirmation e-postasının Spam'e düşmesi Auth failure değil,
  `EMAIL_DELIVERABILITY_TUNING` açık release follow-up'ıdır.
- F3D yalnız owner-authorized disposable fixture'ı trusted Auth Admin yöntemiyle
  temizledi. Post-delete Auth user/identity/session/profile/consent, linked business
  ve Storage residual count'ları exact `0`; Production zero-auth baseline restore
  PASS'tir. Başka user/data değişmedi.
- Actual final mobile app callback opening ve full password-recovery mobile lifecycle
  BLOCKED kalır. Legacy Production callback allowlist kaydı actual app opening PASS
  olmadan kaldırılmaz. Signing, fiziksel iki-cihaz QR, broader Production smoke ve
  signed AAB/APK/IPA ayrıca açıktır.
- Final integration Production/Development remote erişimi veya write, Auth config
  change, e-posta gönderimi, user create/delete ya da migration apply yapmadı.
- Callback/PKCE/signup-recovery/account-deletion/profile/canonical RLS hedefli yerel
  matris 151/151, docs consistency, diff ve secret/PII scan PASS. Yalnız doküman
  merge'i olduğu için full suite/analyzer yeniden çalıştırılmadı; Development live
  harness'i çağrılmadı.

## Wave 11 Phase A Final Entegrasyon Gözlemi

`ANDROID_SIGNING_READY: YES`

`SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`

`KEYSTORE_PRIMARY_BACKUP: COMPLETED`

`COMMERCIAL_RELEASE_READY: NO`

- Agent 1'in `b56b9fe` Android signing/artifact evidence commit'i exact
  `460c81e` tabanından tek `--no-ff` merge ile çatışmasız entegre edildi. Input
  değişikliği yalnız üç release/coordination belgesindeydi; Gradle/platform/Auth
  kodu, dependency, SQL/migration, `service_locator.dart` ve shared model değişmedi.
- Agent kanıtında repo-dışı RSA-4096 upload key ve `esnaftavar-upload` alias'ıyla
  `com.esnaftavar.app` / `EsnaftaVar` / `1.0.0+1` Production APK ve AAB imzalandı.
  APK/AAB signature, artifact hash, final callback, no-legacy-callback ve
  non-debuggable sözleşmeleri PASS'tir.
- Integration `git status` ve `git ls-files` ile `.jks`, `.keystore`, populated
  `key.properties`, APK/AAB, private key, signing password, geçici Production config
  veya gerçek publishable key'in tracked olmadığını doğruladı. Binary artifact
  yeniden üretilmedi veya Git'e eklenmedi.
- Product owner birincil repo-dışı keystore yedeği ve parola yöneticisi kaydını
  tamamladı; secret değer ve yedek bağlantısı belgelenmedi. İkinci offline yedek ve
  kalıcı CI signing provenance öneri/açık durumdadır.
- Android signing hazırdır; fiziksel install/startup, actual mobile callback opening,
  full recovery, Play Console/Play App Signing, legacy callback removal, iOS signing,
  fiziksel iki-cihaz QR, broader Production smoke ve commercial GO açık kalır.
- Final integration Production/Development remote erişimi veya write, e-posta, Auth
  config ya da migration işlemi yapmadı. Mobil signing/release dosyaları sonraki
  wave'lerde aynı anda yalnız tek atanmış agent tarafından değiştirilmelidir.
- Integration hedefli identity/signing/callback/preflight/Auth matrisi 62/62, tam
  Flutter suite 1154 PASS (5 opt-in live skip) ve analyzer PASS'tir. Diff,
  secret/private-key ve tracked signing/binary artifact scan'leri temizdir.

## Wave 11 Phase B2 Final Entegrasyon Gözlemi

`INPUT_VISIBILITY_CODE_FIX: PASS`

`EMAIL_CONFIRMATION_UI_CODE_FIX: PASS`

`LOCATION_PERMISSION_CODE_FIX: PASS`

`READY_FOR_PHYSICAL_B2_RETEST: YES`

`PHYSICAL_DEVICE_REGRESSION: BLOCKED`

- Agent 2'nin `fa074a8` input/Auth confirmation/location bugfix commit'i exact
  `8f0adeb` tabanından tek `--no-ff` merge ile çatışmasız entegre edildi.
- Açık müşteri input yüzeyleri koyu sistem temasından bağımsız okunabilir değer,
  hint/label/error, cursor ve selection renkleri taşır; parola maskelemesi korunur.
- Exact environment confirmation callback'i Auth/profile durumunu yeniler, session
  sonucuna göre customer shell veya Login'e tek yönlendirme yapar ve exact başarı
  mesajını gösterir. Malformed/duplicate callback, PKCE ve Production/Development
  izolasyon sözleşmeleri korunur.
- Konum akışı servis kontrolü, runtime izin isteği, kalıcı ret için App Settings,
  servis kapalıyken location settings, resume refresh ve güvenli last-known fallback
  sırasını uygular; doğrudan permission bypass veya tekrar istek döngüsü yoktur.
- Integration hedefli matrisi 118/118, tam Flutter suite 1177 PASS (5 explicit
  opt-in live skip) ve analyzer PASS'tir. Production/Development remote erişimi veya
  write, signup, e-posta, QR, Storage, migration ya da Auth config işlemi yapılmadı.
- Fiziksel input, confirmation success/app opening ve location acquisition retest'i;
  full mobile recovery, fiziksel iki-cihaz QR ve broader Production smoke açık kalır.
  Otomatik PASS fiziksel cihaz sonucunun yerine kullanılmaz.
- `lib/t_store.dart` bu wave'in global listener/navigation hot-spot'udur; input theme
  ve location service/state dosyalarıyla birlikte sonraki paralel işlerde tek sahipli
  tutulmalıdır. SQL/migration, `service_locator.dart` ve shared model değişmedi.

## Wave 11 Phase B2R Fiziksel Kabul Entegrasyon Gözlemi

`INPUT_PHYSICAL_ACCEPTANCE: PASS`

`LOCATION_PHYSICAL_ACCEPTANCE: PASS`

`CONFIRMATION_UI_PHYSICAL_ACCEPTANCE: BLOCKED`

`READY_FOR_MOBILE_AUTH_LIVE_ACCEPTANCE: YES — HISTORICAL B2R GATE`

- Agent 1'in `9d600cf` fiziksel acceptance belge commit'i exact `4d35429`
  tabanından tek `--no-ff` merge ile çatışmasız entegre edildi. Kod, migration,
  fixture, dependency, shared model veya `service_locator.dart` değişmedi.
- POCO X7 Pro / Android 16 üzerinde signed Production APK normal upgrade ile mevcut
  `com.esnaftavar.app` kurulumunun üzerine yüklendi; uninstall, clear-data veya wipe
  yapılmadı. Startup ve çalışan uygulama süreci PASS oldu.
- Home search input'unda typed value, hint ve cursor fiziksel olarak görünür. Login
  yüzeyi açılmadığından parola maskelemesinin fiziksel kabulü iddia edilmez; mevcut
  widget sözleşmesi PASS'tir.
- Android runtime location permission dialog'u, izin grant'i ve gerçek location
  acquisition fiziksel olarak PASS; crash veya generic location error yok. Settings
  return negatif fiziksel turu yapılmadı ve OPEN kalır; otomatik sözleşmesi PASS'tir.
- Yeni signup/e-posta/confirmation oluşturulmadığından confirmation success UI ve
  actual callback app opening fiziksel kabulü BLOCKED; full mobile recovery de OPEN/
  BLOCKED kalır. Mevcut Production test-user inventory/cleanup kontrolü olası canlı
  Auth turunun ayrı preflight'ıdır.
- Production/Development erişimi veya write, Auth user/e-posta değişikliği, QR,
  Storage, migration ya da config işlemi yapılmadı. Fiziksel iki-cihaz QR, broader
  Production smoke, legacy callback removal ve deliverability tuning açıktır.
- Agent B2R kanıtında hedefli 114, tam suite 1177 PASS (5 opt-in live skip) ve analyzer
  PASS'tir. Integration kod değişikliği olmadan ilgili B2 sözleşmelerini 118/118 PASS
  ile yeniden doğruladı; otomatik sonuçlar yapılmayan fiziksel Auth/settings turunu
  kapatmaz.

## Wave 11 Phase B3A Cleanup Entegrasyon Gözlemi

`WAVE_11_B3A_AUTHORIZED_FIXTURE_CLEANUP: PASS`

`B3A_CANONICAL_SELF_DELETE_ACCEPTANCE: PASS`

`PRODUCTION_ZERO_TEST_BASELINE: RESTORED`

`READY_TO_RESTART_B3_MOBILE_AUTH: YES — HISTORICAL B3A GATE`

- Agent 1'in `628118e` cleanup evidence commit'i exact `4c187cf` tabanından tek
  `--no-ff` merge ile çatışmasız entegre edildi. Değişiklik yalnız üç canonical
  belgeydi; kod, migration, fixture, dependency veya shared model değişmedi.
- Fresh Production gate önceki disposable fiziksel-test customer'ı için Auth user/
  identity/profile `1/1/1`, session `2`, customer role `1`, legal consent `2`, saved
  location `1`; merchant/admin, diğer user-linked business ve Storage `0` doğruladı.
- Owner-authorized canonical `delete_current_customer_account` self-delete çalıştı.
  Trusted admin/manual SQL delete veya ek hedefli delete yok; saved-location canonical
  cascade ile temizlendi.
- Authoritative post-state Auth user/identity/session/profile/legal consent/saved
  location, diğer user-linked business ve Storage için exact `0`; Production zero-test
  baseline restore PASS.
- Integration cleanup'ı tekrar çalıştırmadı: Production remote read/write, Auth user/
  email/recovery, config, migration, Storage veya Development işlemi `0` kaldı.
- Agent kanıtındaki hedefli paket 96/96, Integration account deletion/Auth/profile/
  saved-location/canonical migration yeniden doğrulama paketi 63/63 PASS.
- Live physical confirmation callback app-opening, confirmation success UI ve full
  mobile recovery; legacy Production callback removal, deliverability tuning,
  fiziksel iki-cihaz QR ve broader Production smoke açık kalır.

## Wave 11 B3R Evidence + Cleanup Entegrasyon Gözlemi

`WAVE_11_B3R_EVIDENCE_INTEGRATION: PASS`

`PHYSICAL_CONFIRMATION_CALLBACK: PASS`

`CONFIRMATION_SUCCESS_UI: FAIL`

`PHYSICAL_PASSWORD_RECOVERY: FAIL`

`AUTHORIZED_B3R_FIXTURE_CLEANUP: PASS`

`PRODUCTION_ZERO_TEST_BASELINE: RESTORED`

`READY_FOR_AUTH_RECOVERY_ROOT_CAUSE_ANALYSIS: YES`

- Agent 1 final HEAD'i `0f94596`, exact `76acad4` tabanından `59acbec` ile tek
  `--no-ff` ve çatışmasız merge olarak entegre edildi. Branch üç canonical kanıt
  belgesi yanında dört Auth UI dosyasında password opaque-value/keyboard hardening ve
  destination-render sonrası confirmation feedback değişiklikleri ile üç test dosyası
  içerir; SQL/migration, shared model, DI veya dependency değişmedi.
- POCO X7 Pro / Android 16 fiziksel kanıtında confirmation e-postası, final callback
  ile EsnaftaVar'ın açılması, server confirmation, authenticated Home/session ve
  customer role/profile güvenliği PASS. Canonical confirmation success mesajı Home'da
  görünmedi: `V1_0_AUTH_BUG_CONFIRMATION_SUCCESS_FEEDBACK: OPEN`.
- Recovery e-postası, final callback ve update-password UI PASS. HTTP `200` /
  `user_modified` gerçek password-hash değişimi kanıtı sayılmadı; iki fresh login yeni
  credential'ı `invalid_credentials` ile reddetti:
  `V1_0_AUTH_BUG_RECOVERY_CREDENTIAL_PERSISTENCE: OPEN`.
- Fresh cleanup gate exact B3R disposable fixture'ını doğruladı. Session olmadığı için
  canonical self-delete kullanılamadı; owner-authorized trusted Dashboard Auth Admin
  delete sonrası Auth user/identity/session/profile/legal consent, bütün linked
  business ve Storage residual exact `0`. Legacy callback kaldırılmadı.
- Integration canlı kabulü veya cleanup'ı tekrar çalıştırmadı: Production remote
  read/write, Auth user/e-posta/recovery/config, Storage ve Development işlemi `0`.
  İlgili Auth matrisi 67/67, tam suite 1182 PASS (5 explicit opt-in live skip) ve
  analyzer temiz; bu sonuçlar fiziksel iki bug'ı kapatmaz.

## Wave 11 Phase B5 Auth Fix Entegrasyon Gözlemi

`WAVE_11_PHASE_B5_INTEGRATION: PASS`

`CONFIRMATION_SUCCESS_FEEDBACK_CODE_FIX: PASS`

`RECOVERY_FALSE_SUCCESS_GUARD: PASS`

`RECOVERY_FRESH_LOGIN_VERIFICATION: PASS`

`AUTH_REGRESSION: PASS`

`RECOVERY_PASSWORD_ROOT_CAUSE: NOT_FOUND`

`READY_FOR_FINAL_PHYSICAL_AUTH_RETEST: YES`

- Agent 2'nin `793f0dc` teslimi exact `bb3e7e5` tabanından `5461d77` ile tek
  `--no-ff` ve çatışmasız merge olarak entegre edildi.
- Confirmation notice sahipliği destination Home/Login ekranına taşındı; route
  görünür olduktan sonra bir kez render edilir, dismiss edilene kadar kalır ve aynı
  callback sequence'i veya invalid callback ikinci başarı üretmez.
- Recovery repository/use-case/Cubit zinciri valid provenance, expected-user update
  response, local session cleanup, aynı opaque credential ile fresh login ve same-user
  identity doğrulamasının tamamı bitmeden başarı üretmez. False-success, cleanup ve
  identity mismatch regression'ları typed failure olarak doğrulanır.
- Shared/hotspot sahipliği yalnız Agent 2'de kaldı: `lib/t_store.dart`, Auth callback/
  recovery listener'ları, Auth domain repository/use-case/entity ve Auth Cubit. Aynı
  dosyalara paralel ikinci agent değişikliği yoktu. `service_locator.dart`, shared
  uygulama modelleri, SQL/migration, dependency ve platform config değişmedi.
- Integration Production/Development remote read/write, Auth user/e-posta/recovery,
  config, Storage veya migration işlemi yapmadı. Historical Production password
  persistence root cause'u NOT_FOUND kalır; son fiziksel Auth retest'i ayrı yetkili
  görevdir.
- Hedefli Auth matrisi 215/215, tam Flutter suite 1194/1194 (5 explicit opt-in live
  skip), analyzer, diff ve secret/PII kontrolleri PASS.

## Wave 11 Phase B6 Final Physical Auth Entegrasyon Gözlemi

`WAVE_11_PHASE_B6_INTEGRATION: PASS`

`PHYSICAL_MOBILE_AUTH_ACCEPTANCE: PASS`

`PRODUCTION_PASSWORD_RECOVERY_ACCEPTANCE: PASS`

`PRODUCTION_ZERO_TEST_RESIDUAL: YES`

`READY_TO_REMOVE_LEGACY_CALLBACK: YES — SEPARATE AUTHORIZED TASK`

`COMMERCIAL_RELEASE_READY: NO`

- Agent 1'in `af1708c` final physical-evidence teslimi exact `31f4ac1` tabanından
  `d3b9cac` ile tek `--no-ff` ve çatışmasız merge olarak entegre edildi.
- POCO X7 Pro / Android 16 üzerinde confirmation callback + destination-owned kalıcı
  success notice, canonical five-step recovery, aynı yeni credential ile fresh ve
  normal login, same-user identity ve customer role güvenliği fiziksel PASS'tir.
  Tarihsel B3R password persistence root cause'u `NOT_FOUND` kalır.
- B6 disposable fixture canonical `delete_current_customer_account` self-delete ile
  temizlendi; Auth/identity/session/profile/consent, bütün linked business ve Storage
  residual exact `0`. Legacy Production callback remote allowlist'te korunur; ayrı
  yetkili removal görevine hazırdır.
- Agent teslimi yalnız dört Auth/evidence belgesini değiştirdi. Integration iki merkezi
  coordination belgesini güncelledi; uygulama kodu, `service_locator.dart`, shared
  model, SQL/migration, platform config, dependency veya signing materyali değişmedi.
  Bu nedenle shared/hotspot çakışması yoktur.
- Integration Production/Development remote read/write, Auth user/e-posta/recovery,
  config, Storage veya migration işlemi yapmadı. Hedefli Auth/account-deletion matrisi
  266/266, tam Flutter suite 1194/1194 (5 explicit opt-in live skip), analyzer, diff
  ve security/PII kontrolleri PASS.

## Wave 11 Phase B7 Production Callback Cleanup Entegrasyon Gözlemi

`WAVE_11_PHASE_B7_INTEGRATION: PASS`

`FINAL_PRODUCTION_CALLBACK_ONLY: YES`

`PRODUCTION_AUTH_CALLBACK_CUTOVER: COMPLETE`

`B7_HANDOFF_READY_FOR_ESENLER_DEMO_DATASET: YES — SEPARATE AUTHORIZED TASK`

`COMMERCIAL_RELEASE_READY: NO`

- Agent 1'in `11c3ab6` callback-removal kanıtı exact `21f7224` tabanından
  `2e62bb4` ile tek `--no-ff` ve çatışmasız merge olarak entegre edildi.
- Agent 1'in owner-authorized remote adımı yalnız Production allowlist'teki
  `io.supabase.tstore://login-callback/` kaydını kaldırdı. Postflight Site URL ve tek
  allowlist kaydını `com.esnaftavar.app://login-callback/`, Custom SMTP'yi Enabled ve
  Confirm Email'i ON doğruladı; başka Auth config drift yoktur.
- Development remote'a dokunulmadı. Development istemci/platform callback'i aynı
  `io.supabase.tstore://login-callback/` URI'sini kendi environment'ında bilinçli
  olarak korur; Production/Development fallback veya callback karışması yoktur.
- Agent teslimi yalnız dört Production/Auth belgesini değiştirdi. Integration iki
  merkezi coordination belgesini hizaladı; uygulama kodu, `service_locator.dart`,
  shared model, SQL/migration, platform config ve dependency değişmedi. Shared/hotspot
  çakışması yoktur.
- Integration remote change/postflight'ı tekrar çalıştırmadı: Production/Development
  remote read/write, Auth config, user/e-posta, database ve Storage işlemi `0`.
  Callback/platform/environment/PKCE/release-config matrisi 45/45, diff ve
  security/PII kontrolleri PASS.
- Esenler demo dataset ayrı yetkili iş paketine hazırdır. Fiziksel iki-cihaz QR,
  broader Production smoke, Play Console/Play App Signing, iOS signing/archive ve
  final commercial GO açık kalır.

## Wave 12 Phase A Esenler Demo Dataset Entegrasyon Gözlemi

`WAVE_12_PHASE_A_INTEGRATION: PASS`

`DEMO_DATASET_ARTIFACT: READY`

`PRODUCTION_DEMO_SEED_APPLIED: NO`

`PHASE_A_HANDOFF_READY_FOR_DEMO_DATASET_PHASE_B: NO — SEPARATE PRODUCTION SAFETY REVIEW + EXPLICIT OWNER AUTHORIZATION REQUIRED`

- Agent 3'ün `0edb615` dataset tasarımı exact current main `4232a6e` tabanından
  `6394f8f` ile tek `--no-ff` ve çatışmasız merge olarak entegre edildi.
- Phase A artefakt sahipliği yalnız `docs/ESENLER_DEMO_DATASET.md`, `tool/demo_seed/`,
  `supabase/seeds/` ve ilgili contract testindedir. Canonical migration zinciri,
  shared model/repository, `service_locator.dart`, app code ve dependency dosyaları
  değiştirilmedi. Üretilmiş artefaktların platformlar arası byte-equivalence'ı için
  yalnız üç exact JSON/SQL yolu LF olarak sabitlendi.
- Local PGlite temiz-oda replay'i canonical 9 migration, ilk/ikinci seed
  `4/20/57/285`, representative customer reads, seller comparison, 57 unique valid
  coordinate ve exact cleanup sonrası demo row `0` + canonical public table `23`
  sonuçlarını PASS doğruladı. Hedefli matris 268/268, tam suite 1210 PASS (5 opt-in
  live skip) ve analyzer temizdir.
- `is_featured = true` yalnız sentetik Home discovery görünürlüğü içindir; sponsorlu,
  reklam veya paid ranking değildir. Şehitler ve Yeşil Vadi separate-current-polygon
  limitation'ı `NEIGHBORHOOD_CENTER` güven düzeyiyle korunur.
- Production/Development remote read/write, seed veya cleanup apply, Auth/merchant
  hesabı ve migration yapılmadı. Phase B bu entegrasyondan otomatik yetki almaz;
  ayrı Production safety review ve açık owner authorization zorunludur.

## Wave 12 Phase B Production Demo Seed Safety Entegrasyon Gözlemi

`WAVE_12_PHASE_B_INTEGRATION: PASS`

`DEMO_SEED_SAFETY_REVIEW_INTEGRATED: YES`

`PRODUCTION_DEMO_SEED_APPLIED: NO`

`OWNER_DEMO_SEED_AUTHORIZATION: NOT_YET_GRANTED`

`READY_FOR_OWNER_DEMO_SEED_AUTHORIZATION: YES`

- Agent 1'in `0383782` read-only safety review belgesi exact current main `edc0999`
  tabanından `f53e584` ile tek `--no-ff` ve çatışmasız merge olarak entegre edildi.
  Agent evidence canonical Production'da katalog `0/0/0/0`, Auth/profile/business
  ilişkileri `0`, üç canonical bucket/object `3/0`, deterministic ID collision
  `0/366`, natural-key collision `0` ve existing exact demo row `0` gösterir.
- Seed dört business tabloyla sınırlı, deterministic, transactional ve fail-closed;
  controlled single-writer apply için safety PASS'tir. Cleanup yalnız pre-launch
  zero-user/zero-activity state'te exact-ID safety PASS'tir. User activity sonrasında
  blind destructive cleanup pre-authorized değildir; soft-retire/deactivate ayrı
  owner kararı gerektirir.
- `owner_user_id = NULL` intentional customer-demo sınırıdır: discovery, shop detail,
  nearby ve seller comparison çalışır; merchant QR confirmation ve demo shop üzerinden
  verified transaction çalışmaz. Shared model/schema veya runtime wiring değiştirilmedi.
- Featured yalnız demo Home discovery görünürlüğüdür; sponsored, advertising engine
  veya paid ranking değildir. 19 mahalle/57 unique point `NEIGHBORHOOD_CENTER`
  confidence'ı ve Şehitler/Yeşil Vadi polygon limitation'ı değişmedi.
- Local generator + dataset/migration matrisi 37/37, PGlite first/second seed
  `4/20/57/285`, seller 14–15/multiple prices, cleanup `0/0/0/0`, canonical public
  table `23`, tam Flutter suite 1210 PASS (5 opt-in live skip) ve analyzer temizdir.
- Integration Production/Development remote read/write, seed/cleanup, Auth, Storage
  veya config işlemi yapmadı. Safety readiness owner authorization değildir.

## Wave 12 Phase C Production Demo Seed State Entegrasyon Gözlemi

`WAVE_12_PHASE_C_INTEGRATION: PASS`

`PRODUCTION_DEMO_DATASET_LIVE: YES`

`PRODUCTION_DEMO_CUSTOMER_READ: PASS — ANON RLS ROLE`

`PRODUCTION_DEMO_SEED_REAPPLIED: NO`

`PRODUCTION_DEMO_CLEANUP_RUN: NO`

`READY_FOR_PRODUCTION_DEMO_VISUAL_SMOKE: YES`

- Agent 1'in `26defb1` Production seed/postflight kanıtı exact current main `580552f`
  tabanından `fad75a7` ile tek `--no-ff` ve çatışmasız merge olarak entegre edildi.
  Agent turundaki owner-authorized exact seed bir kez uygulanmıştır; Integration turu
  uzak backend'e bağlanmadı, seed'i tekrarlamadı ve cleanup çalıştırmadı.
- Authoritative durum categories/products/shops/shop_products `4/20/57/285`, active
  ve featured products `20/20`, deterministic manifest `366/366`, unexpected row `0`,
  Auth user/profile/merchant ve Storage object `0` olarak korunur. Gerçek `anon` rolü
  aynı katalog sayılarını, ürün başına 14–15 seller ve 20/20 multiple-price sonucunu
  PASS okumuştur.
- `[DEMO]` shop `57/57`, `owner_user_id = NULL` `57/57`, product/listing marker
  `20/20` ve `285/285` kalır. Customer discovery/Home/shop detail/seller comparison
  hazırdır; merchant ownership, demo merchant QR confirmation ve verified purchase
  intentional unavailable'dır.
- Featured yalnız demo Home discovery görünürlüğüdür; sponsored, advertising engine
  veya paid ranking değildir. 19 mahalle, 57 unique valid coordinate,
  `NEIGHBORHOOD_CENTER` confidence ve Şehitler/Yeşil Vadi polygon limitation'ı korundu.
- Generator check, hedefli dataset/Home/seller/canonical matrisi `284/284`, tam Flutter
  suite `1210` PASS (`5` opt-in live skip) ve analyzer temizdir. Shared runtime code,
  model/schema, migration zinciri, `service_locator.dart` ve dependency dosyaları
  değiştirilmedi; bu entegrasyonun shared sahipliği yalnız coordination docs'tur.
- Demo cleanup ayrı açık owner yetkisi olmadan çalıştırılmaz. Gerçek kullanıcı
  aktivitesi sonrası blind destructive cleanup önerilmez; soft-retire/deactivate
  gerekirse ayrı ürün kararıdır. Broader fiziksel/mobile visual smoke açık kalır.

## Wave 12 Phase D Production Demo Functional Smoke Entegrasyon Gözlemi

`WAVE_12_PHASE_D_INTEGRATION: PASS`

`PRODUCTION_DEMO_FUNCTIONAL_SMOKE: PASS`

`FUNCTIONAL_RELEASE_BLOCKERS: NONE`

`COSMETIC_UI_POLISH: DEFERRED`

`READY_FOR_NEXT_RELEASE_GATE: YES`

- Agent 1'in `8c869e5` Production functional smoke, rapor ve read-only harness teslimi
  exact current main `609e555` tabanından `42774fe` ile tek `--no-ff` ve çatışmasız
  merge olarak entegre edildi.
- Agent evidence gerçek Production Web release runtime'ında Startup, Home, kategori,
  ProductDetails, seller/shop, nearby, search, anonymous wishlist/cart/profile gate ve
  navigation akışlarını PASS; functional release blocker'ı `NONE` doğrular. Demo
  katalog `4/20/57/285`, kategori başına `5`, ürün başına `14–15` seller, 20/20 çoklu
  fiyat, mağaza başına `5` listing ve `57` valid/unique coordinate olarak korunur.
- Production harness exact `mefhfvrgkwciubeajjeb` ref'ine ve explicit opt-in'e
  fail-closed kilitlidir. Varsayılan test koşusu remote'a bağlanmaz; harness yalnız
  read yüzeylerini kullanır ve kaynak-seviyesi database/Auth/Storage mutation yasağı
  taşır. Client-safe key hard-code edilmez ve fixture oluşturulmaz.
- Agent Production read-only smoke kanıtı `564/564` hedefli + live `4/4`; Integration
  doğrulaması remote define olmadan `552` PASS (`2` Production live skip), tam suite
  `1213` PASS (`6` live skip) ve temiz analyzer sonucudur. Integration Production veya
  Development remote read/write, seed/cleanup, Auth, Storage, migration ya da config
  işlemi yapmadı.
- Runtime/shared app code, model/schema/migration zinciri, `service_locator.dart` ve
  dependency dosyaları değişmedi. Yeni sahiplik yalnız `test/live` harness'ları ile
  Production smoke/coordination docs'tur.
- `owner_user_id = NULL` merchant ownership/QR/verified purchase sınırı intentional
  unavailable kalır ve regression değildir. Renk/font/spacing/kart/ikon/padding gibi
  kozmetik değerlendirmeler owner kararıyla final UI kit'e kadar deferred'dır; yeni
  functional backlog işi açılmaz.

## Wave 13 Phase A Android Release Signing Entegrasyon Gözlemi

`WAVE_13_PHASE_A_INTEGRATION: PASS`

`SIGNED_ANDROID_ARTIFACTS_PRESERVED: YES`

`ANDROID_SIGNING_RELEASE_GATE: PASS`

`READY_FOR_PHYSICAL_ANDROID_ACCEPTANCE: COMPLETED — WAVE 13 PHASE B`

- Agent 2'nin `d966f55` signing kanıtı exact `305dd74` tabanına `52f1e98` ile tek
  `--no-ff` ve çatışmasız merge olarak entegre edildi. Runtime kod, platform kimliği,
  schema/model, migration, `service_locator.dart` veya dependency dosyası değişmedi;
  shared sahiplik yalnız mobile release ve coordination belgelerindedir.
- Final `com.esnaftavar.app` / `1.0.0 (1)` APK ve AAB Git/worktree dışında
  `C:\Users\Mustafa\EsnaftavarReleases\1.0.0` altında korunur. Exact hash, APK v2/
  tek signer, AAB `jar verified`, canonical upload certificate fingerprint'i, final
  callback ve forbidden identity/secret taraması Integration tarafından yeniden PASS
  doğrulandı. Artifact ve keystore Git'e alınmadı.
- Integration artifact rebuild veya signing credential erişimi yapmadı. Production ve
  Development remote read/write, Auth/SMTP, migration, Storage veya config işlemi
  yoktur. Hedefli matris `50/50`, tam suite `1213` PASS (`6` opt-in live skip),
  analyzer/diff/security temizdir.
- Korunmuş APK'nın fiziksel install/startup/customer/location kabulü Wave 13 Phase
  B'de PASS; final callback/recovery authoritative B6 PASS durumundadır. Fiziksel
  merchant scanner/iki-cihaz QR, Play Console AAB kabulü, ikinci offline keystore
  yedeği, iOS signing/archive ve final commercial GO açık kalır. Bu açık işler
  signing/artifact gate PASS sonucunu geri çevirmez.

## Wave 13 Phase B Fiziksel Android Entegrasyon Gözlemi

`WAVE_13_PHASE_B_INTEGRATION: PASS`

`PHYSICAL_ANDROID_RELEASE_ACCEPTANCE: PASS`

`PHYSICAL_LOCATION_ACCEPTANCE: PASS`

`PHYSICAL_TWO_DEVICE_QR_ACCEPTANCE: OPEN`

`FUNCTIONAL_ANDROID_BLOCKERS: NONE`

`READY_FOR_NEXT_RELEASE_GATE: YES`

- Agent 1'in `920b95e` fiziksel kabul kanıtı exact `22c78c6` tabanına `6c15e02` ile
  tek `--no-ff` ve çatışmasız merge olarak entegre edildi. Runtime/platform kodu,
  schema/model, migration, `service_locator.dart`, dependency veya signed binary
  değişmedi; shared sahiplik yalnız release ve coordination belgelerindedir.
- Exact korunmuş `com.esnaftavar.app` / `1.0.0 (1)` APK POCO X7 Pro / Android 16
  (API 36) cihazına uninstall/clear-data olmadan normal upgrade ile kuruldu. Startup,
  Production Home/kategori/ProductDetails/seller/shop/search/nearby/navigation ve
  fiziksel location izin/acquisition PASS; functional blocker yoktur. Kozmetik UI
  final UI kit'e deferred'dır.
- Agent fiziksel turu yalnız customer read yüzeylerini kullandı ve remote write,
  Auth/merchant/QR/Storage fixture, Development erişimi veya rebuild yapmadı. Final
  Integration remote read/write yapmadan hedefli `143` PASS (`2` gated live skip),
  tam suite `1213` PASS (`6` gated live skip), analyzer/diff/security PASS doğruladı.
- Camera/scanner merchant-owned aktif shop principal'ı gerektirdiğinden çalıştırılmadı;
  fail sayılmaz. Merchant scanner ve fiziksel iki-cihaz QR tek ayrı acceptance gate'i
  olarak OPEN kalır. Play Console, ikinci offline keystore yedeği, iOS signing/archive
  ve commercial GO da ayrık release kapılarıdır; B6 Auth confirmation/recovery PASS
  durumu yeniden açılmaz.

## Wave 15 Category Taxonomy V1 Final Entegrasyon Gözlemi

`WAVE_15_TAXONOMY_INTEGRATION: PASS`

`CATEGORY_TAXONOMY_V1_CANONICAL: YES`

`TAXONOMY_DEPLOYED_TO_RUNTIME: NO`

`READY_FOR_TAXONOMY_IMPLEMENTATION_DESIGN: YES`

- Agent Taxonomy'nin research, owner-review, draft/history ve final V1 artefaktları
  exact current main tabanından tek `--no-ff` merge ile çatışmasız entegre edildi.
  Runtime Flutter, shared model/schema, migration, seed, Figma, dependency veya remote
  backend değişikliği yoktur.
- Canonical `v1.0.0` ağaç `23/91/505/32`, toplam `651` node, `525` leaf, `524`
  aktif atanabilir leaf ve tek inactive/non-assignable `hediyelik-obje` taşır.
  Owner kararları `24/24`; canonical Git/LF SHA-256
  `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08` PASS.
- Bir canonical product yalnız bir primary assignable leaf kullanır. Brand, variant,
  attribute/filter, alias, offer ve shop type ayrı domainlerdir. Home'daki sekiz
  availability-gated organik kısayol canonical L1 ağacının yerine geçmez; Tüm
  Kategoriler bütün 23 L1'i açar ve sponsored placement organic/canonical sırayı
  yeniden yazmaz.
- DB taxonomy schema/migration ve Production seed/migration işi aynı wave'de yalnız
  tek SQL/migration sahibine verilmelidir. Migration zinciri, category/product shared
  model ve `service_locator.dart` başka agentlarla eşzamanlı değiştirilmemelidir.
- Search/index ve category read-path entegrasyonu LANE A/shared Shop modelleriyle
  aynı sahipte veya sıralı yürütülmelidir. Sekiz representative leaf attribute pilotu
  önce tasarım/contract çalışmasıdır; 62 filter family topluca implement edilmiş
  sayılmaz.
- Figma category/search/filter uyarlaması canonical JSON ve Design Tokens V1'e bağımlı
  ayrı UI işidir. Shop-type taxonomy product taxonomy'den ayrı future merchant-domain
  işi olarak kalır ve LANE E ile aynı shared modellerde paralel yürütülmez.

## Wave 14 Phase B2 Design Tokens V1 Final Entegrasyon Gözlemi

`WAVE_14_PHASE_B2_INTEGRATION: PASS`

`DESIGN_TOKENS_V1_CANONICAL: YES`

`SOURCE_KPASA_UNCHANGED: YES`

`READY_FOR_CANONICAL_COMPONENT_LAYER: YES`

- Agent UI'nin proposal/history ve final token docs/data artefaktları güncel Wave 15
  main üzerine tek `--no-ff` merge ile çatışmasız entegre edildi. Eski-base farkı
  taxonomy dosyalarını silmedi; Wave 15 canonical taxonomy ve coordination durumu
  korunmuştur.
- Mahalle Terracotta finaldir: primary `#B54732`, accent `#1F6B5D`, Poppins-only,
  dokuz spacing, dört radius ve `44/48 px` touch sözleşmesi. Canonical foundation
  `38` color + `15` dimension variable, `12` type ve `3` shadow style taşır.
- Token manifesti toplam `68` final token, duplicate name `0`, intentional alias `12`,
  broken alias/cycle `0` sonucuyla PASS. Primary/white `5.37:1`, accent/white `6.33:1`
  ve bütün approved strong/soft pair kontrastları PASS'tir.
- Input Figma değişiklikleri yalnız izole EsnaftaVar foundation ve proposal binding
  alanındadır. Existing K'pasa screen/component/instance/style fingerprint'leri
  değişmemiştir; Integration Figma write, runtime veya remote backend işlemi yapmadı.
- Canonical component layer tek UI-system sahibinde ilerlemelidir. İlk sıra Button →
  TextField → Navbar → ProductCard → SellerPriceRow; token manifesti, component source
  ve Flutter mapping aynı anda farklı agentlar tarafından değiştirilmemelidir.
- Critical screen pilot, taxonomy category/search/filter UI ve full Flutter migration
  component-level kabul sonrasında sıralı yürütülür. Wave 15 taxonomy source-of-truth
  korunur; taxonomy UI projection canonical ağaçtan bağımsız ürün kuralı uydurmaz.

## Wave 14 Phase B3 Canonical Component Layer V1 Entegrasyon Gözlemi

`WAVE_14_PHASE_B3_INTEGRATION: PASS`

`CANONICAL_COMPONENT_LAYER_V1: PASS`

`SOURCE_KPASA_UNCHANGED: YES`

`RUNTIME_CODE_CHANGED: NO`

`READY_FOR_CRITICAL_SCREEN_PILOT: YES`

- Agent UI'nin `e4664c5` ve `c9ce40c` commitleri güncel Design Tokens V1 + Wave 15
  taxonomy main tabanından tek `--no-ff` merge ile çatışmasız entegre edildi.
  Runtime Flutter, shared model/schema, migration, dependency ve remote backend
  değişikliği yoktur.
- Figma `EsnaftaVar — Components V1` page `52790:2`, canonical board `52790:3`
  (`2520 × 5036`) üzerinde `14` public family, `11` component set ve `79`
  component node taşır. Canonical source-of-truth
  `docs/ESNAFTAVAR_COMPONENT_LIBRARY_V1.md`'dir.
- Actual five-target BottomNav; dynamic taxonomy + availability-aware CategoryCard/
  CategoryRow; Grid/List + fallback ProductCard; Default/BestPrice/Unavailable
  SellerPriceRow; MerchantCard; server-authoritative verified state; single-store
  Cart V2 ve StatusChip sözleşmeleri korunur.
- `Sponsored` yalnız future visual disclosure state'idir. Advertising engine, paid
  ranking, reward/gamification veya checkout/payment davranışı bu fazda yoktur.
  Canonical taxonomy hierarchy component içine hard-code edilmez.
- Kalite kanıtı: component root Auto Layout `79/79`, canonical token binding,
  Poppins-only, duplicate name `0`, legacy `#FF8523` `0`, sub-44 interactive target
  `0`, Turkish overflow/clipping `0`; primary/white `5.37:1`, accent/white `6.33:1`.
- Protected K'pasa Cover/UI/Components/Styles fingerprint'leri değişmemiş;
  source screen/component/instance/style mutation `0`'dır. Integration Figma write
  yapmadı.
- Sonraki UI işi tek UI-system sahibiyle product-owner visual review ve bir critical
  screen pilotudur. Pilot kabul edilmeden full Flutter token/component migration veya
  screen-wide redesign paralel başlatılmaz. Wave 15 taxonomy UI uyarlaması canonical
  JSON'u dinamik tüketir; shared navigation/theme/widget alanları farklı agentlarca
  aynı anda değiştirilmez.

## Wave 15 Phase A Canonical Taxonomy Architecture + 24 L1 Lock

`WAVE_15_PHASE_A_INTEGRATION: PASS`

`CANONICAL_L1_LOCK: PASS`

`CANONICAL_L1_COUNT: 24`

`PRODUCT_MERCHANT_FACET_SEPARATION: PASS`

`CURRENT_FULL_TREE_JSON_RECONCILED_TO_24_L1: NO`

`RUNTIME_TAXONOMY_IMPLEMENTED: NO`

`READY_FOR_TAXONOMY_PHASE_B: COMPLETED`

- Agent 3'ün `4081781`, `2e50120` ve `5bb2fdb` commitleri current main tabanından
  tek `--no-ff` merge ile çatışmasız entegre edildi. Exact 24 Product L1 adı ve
  sırası Product Owner tarafından FINAL/CANONICAL olarak kilitlidir; integration
  yeniden isimlendirme yapmadı.
- Product Taxonomy, Merchant/Sector Taxonomy ve Facet/Attribute separation finaldir.
  Tree variable-depth `L1 → L2 → L3 → optional L4`, max depth `4`; leaf
  `L2/L3/L4` olabilir ve her canonical product exactly one primary leaf kullanır.
- Current 23-L1 full-tree V1.0.0 JSON ve final belge Git blob-level korunmuştur. Bu
  artefakt 24-L1 owner lock ile reconcile edilmiş sayılmaz; rename/split successor
  mapping ve stable opaque-ID bridge ayrı controlled taxonomy/runtime işidir.
- Demo conceptual mapping `4/4` PASS ve remote demo data değişikliği yoktur.
  Merchant scope'unda Berber/Kuaför/Güzellik ana başlığı ile Erkek Berberi,
  Kadın Kuaförü ve Güzellik Salonu confirmed; Unisex Kuaför eklenmez. Booking,
  rezervasyon ve hizmet fiyatı TBD'dir.
- Phase B tek taxonomy-design lane'inde önce Elektronik, sonra Bilgisayar & Tablet
  L2 metodolojisini kurar. L2/L3/L4 tasarımı, current-tree reconciliation ve
  stable-ID bridge aynı taxonomy owner'ında ya da sıralı yürütülmelidir.
- Runtime implementation ayrı pakettir. DB schema/migration zinciri tek SQL sahibi;
  category/product shared model, search/index ve `service_locator.dart` başka
  agentlarla eşzamanlı değiştirilmez. Production/demo apply için ayrı owner yetkisi
  gerekir.
- Figma/category UI lane'i canonical 24-L1 registry ve Component Library V1'in
  dynamic/max-4/variable-depth contract'ını tüketir; hierarchy, Sponsored,
  Featured, Popular veya Nearby component içinde category olarak hard-code edilmez.
  Bu integration Flutter, Figma, schema/migration, JSON veya remote backend
  değişikliği yapmadı.

## Wave 15 Phase B1+B2 Elektronik + Bilgisayar/Tablet L2 Kilitleri

`WAVE_15_B1_B2_INTEGRATION: PASS`

`ELECTRONICS_L2_CANONICAL: PASS`

`ELECTRONICS_L2_COUNT: 9`

`COMPUTER_TABLET_L2_CANONICAL: PASS`

`COMPUTER_TABLET_L2_COUNT: 11`

`CROSS_DOMAIN_BOUNDARY: PASS`

`L3_L4_STATE: FIRST_PILOTS_COMPLETE`

`RUNTIME_TAXONOMY_IMPLEMENTED: NO`

`READY_FOR_L3_L4_DESIGN: COMPLETED — FIRST TWO PILOTS`

- Current `origin/main@d9fefc70099a8e1809611f11d75829e60fecd6ef` üzerine Agent 1
  Electronics branch'i `6ecba73` ve ardından Agent 2 Computer/Tablet branch'i
  `911b553` no-ff merge commitleriyle, çatışmasız ve owner-final sırayı değiştirmeden
  entegre edildi.
- Elektronik owner-final spine exact `9`: Telefon & Aksesuarları; TV & Görüntü
  Sistemleri; Ses & Kulaklık; Fotoğraf & Kamera; Oyun Konsolu & Aksesuarları;
  Giyilebilir Teknoloji; Akıllı Ev & Güvenlik; Güç, Şarj & Bağlantı; Elektronik
  Bileşenler.
- Bilgisayar & Tablet owner-final spine exact `11`: Dizüstü Bilgisayar; Masaüstü
  Bilgisayar; Tablet; E-Kitap Okuyucu; Monitör; Bilgisayar Bileşenleri; Veri
  Depolama; Klavye, Mouse & Çevre Birimleri; Bilgisayar Aksesuarları; Yazıcı,
  Tarayıcı & Sarf Malzemeleri; Ağ & İnternet Ürünleri.
- Cross-domain rule: PC-specific/computer-primary ürün Bilgisayar & Tablet; general
  consumer electronics Elektronik. Arduino/ESP → Elektronik Bileşenler; Raspberry
  Pi/SBC → Bilgisayar Bileşenleri; webcam ve dock/USB hub → Bilgisayar; PC-first
  gaming peripheral → Bilgisayar, console-first → Elektronik/Oyun Konsolu &
  Aksesuarları. Generic audio ve generic güç/şarj/bağlantı Elektronik; telefon-model-
  specific aksesuar Telefon & Aksesuarları kapsamındadır.
- Toner/kartuş/3D printer/filament → Yazıcı, Tarayıcı & Sarf Malzemeleri. Rack/server
  ve POS TBD/unassigned; brand/color/capacity/compatibility gibi facets category
  değildir.
- Sonraki iş tek taxonomy owner'ı altında veya açıkça sıralı biçimde L3/L4 tasarımıdır.
  Aynı anda current-tree reconciliation, stable-ID bridge, shared category/product
  model, search/index, DB migration veya UI taxonomy projection farklı agentlara
  dağıtılmaz. SQL/migration yalnız tek agentta; `service_locator.dart` ve shared
  models aynı anda birden fazla agentta değişmez.
- Bu entegrasyon yalnız dokümantasyon/state bütünleştirmesidir; JSON/full-tree baseline,
  Flutter, Figma, schema/migration, Production ve Development değiştirilmedi.

## Wave 15 Phase C1+C2 First Full L3/L4 Pilots

`WAVE_15_C1_C2_INTEGRATION: PASS`

`FIRST_L34_PILOTS: COMPLETE`

`FIRST_L3_L4_PILOTS: COMPLETE`

`PHONE_ACCESSORIES_L34_CANONICAL: PASS`

`PHONE_ACCESSORIES_L3_COUNT: 9`

`PHONE_ACCESSORIES_L4_COUNT: 7`

`PHONE_ACCESSORIES_LEAF_COUNT: 14`

`COMPUTER_COMPONENTS_L34_CANONICAL: PASS`

`COMPUTER_COMPONENTS_L3_COUNT: 9`

`COMPUTER_COMPONENTS_L4_COUNT: 7`

`COMPUTER_COMPONENTS_LEAF_COUNT: 14`

`L34_DESIGN_METHOD_CANONICAL: PASS`

`STABLE_ID_RUNTIME_RECONCILIATION: NOT_STARTED`

`RUNTIME_TAXONOMY: NOT_STARTED`

`RUNTIME_TAXONOMY_IMPLEMENTED: NO`

`READY_FOR_OVERNIGHT_TAXONOMY_BATCH: YES`

- Current `origin/main@847442e9d5e8b35cf6d83a1c1ea31b625811f38f` üzerine Phone
  Accessories branch'i `34e7813`, ardından Computer Components branch'i `2d32ce3`
  no-ff merge commitleriyle, çatışmasız ve owner-final kararlar değiştirilmeden
  entegre edildi.
- Telefon & Aksesuarları pilotu exact `9` L3, `7` L4 ve `14` leaf; Bilgisayar
  Bileşenleri pilotu exact `9` L3, `7` L4 ve `14` leaf taşır. Her ikisinde max depth
  `4`, duplicate `0` ve exactly-one-primary-leaf sözleşmesi PASS'tir.
- Phone pilotunda generic charging genel Güç, Şarj & Bağlantı domain'ine, phone-
  model-specific charging kendi L3 leaf'ine gider. Physical spare part ürün olabilir;
  repair labor/service ve SIM/telecom service ürün değildir.
- Computer pilotunda storage sibling Veri Depolama; Arduino/ESP Elektronik
  Bileşenler; Raspberry Pi/SBC/Compute Module Tek Kart Bilgisayar (SBC) leaf'indedir.
  Bundle category değildir; compatibility typed relationship/facet'tir. Rack/server
  current consumer taxonomy dışında `TBD` kalır.
- `docs/TAXONOMY_L34_DESIGN_METHOD.md` future taxonomy agentları için canonical
  çalışma yöntemidir. Ayrı domain proposal'ları yalnız dosya kapsamları ayrıkken
  parallel araştırılabilir; owner-final durumunu agent uyduramaz. Non-fatal owner
  blocker'ı `OPEN/TBD` kaydedilir ve diğer bağımsız domaine geçilir. Her completed
  domain scoped checkpoint commit/push üretir.
- Canonical merkezi belgeler, stable-ID/runtime reconciliation, shared category/
  product model, search/index, DB migration ve UI projection tek owner'da veya sıralı
  yürütülür. SQL/migration yalnız tek agentta; `service_locator.dart` ve shared models
  aynı anda birden fazla agentta değişmez.
- Bu integration yalnız docs/canonical kararları değiştirdi; runtime JSON, Flutter,
  Figma, DB/schema/migration, Production ve Development değiştirilmedi.

## Merkezi Sahiplik / Hot-Spot Haritası

| Alan | Neden shared | Varsayılan sahip |
|---|---|---|
| `lib/core/dependency_injection/service_locator.dart` | Bütün feature kayıtlarını birleştirir | Integration agentı |
| `lib/t_store.dart` | Bootstrap, global provider, session ve navigation | Integration agentı |
| Navigation menu/cubit/bottom navigation | Beş ana sekme, guest guard, cart ve unread | Integration agentı veya wave içinde tek atanmış agent |
| `settings_view.dart` | Chat, purchases, coupons, ratings, notifications, profile ve privacy | Wave içinde tek atanmış agent |
| `supabase_tables.dart` | Bütün tablo adları için merkezi sözlük | Integration agentı |
| `supabase_schema.sql` ve migration zinciri | Tablo, RLS, trigger, grant ve RPC bütünlüğü | Wave SQL sahibi + integration agentı |
| Shop repository/model/entity alanları | Discovery, nearby, merchant, cart ve QR bağımlılıkları | Wave içinde tek Shop veri sahibi |
| Theme/token dosyaları | Çok sayıda ekranı etkiler | Integration agentı veya tek UI sistem agentı |
| `pubspec.yaml` / lockfile | Bütün build ve dependency ağacını etkiler | Integration agentı |
| Koordinasyon dokümanları | Merkezi proje ve görev gerçeğini taşır | Analiz/koordinasyon veya integration agentı |

## LANE A — Müşteri Keşfi ve Katalog

- Kapsam: Ana sayfa, arama, kategori, ürün listeleme, ürün detay, satıcı fiyatlarının müşteri sunumu.
- Ana klasörler:
  - `lib/features/shop/presentation/` içindeki müşteri discovery alanları
  - `lib/features/shop/domain/` içindeki product/category read use-case'leri
  - İlgili `test/unit/shop/` ve `test/widget/shop/` dosyaları
- Bağımlılıklar: Product/Category/Shop repository'leri, Wishlist, Saved Locations, theme/token, navigation.
- Hot-spot/shared files: `service_locator.dart`, Shop repository/model/entity, `home_view.dart`, `all_products_view.dart`, `nearby_view.dart`, navigation.
- Paralel çalışamayacağı lane'ler:
  - Shop repository/model değişiyorsa LANE D ve LANE E
  - Global navigation değişiyorsa navigation'a dokunan bütün lane'ler
- SQL/migration sahipliği: Varsayılan olarak SQL değiştirmez. Schema ihtiyacı oluşursa migration önerisi integration agentına devredilir veya wave'in tek SQL sahibi açıkça bu lane olur.
- Parallel safety: **MEDIUM**

## LANE B — Mesajlaşma ve Konuşmalar

- Kapsam: Ürün bağlantılı chat, konuşma listesi, unread, delivery/read state'leri, pagination ve Realtime davranışı.
- Ana klasörler:
  - `lib/features/chat/`
  - `test/unit/chat/`
  - `test/widget/chat/`
- Bağımlılıklar: Profiles, Shops, Supabase Realtime, PendingProductChatStorage, navigation unread badge, settings hub, DI.
- Hot-spot/shared files: `service_locator.dart`, `navigation_menu.dart`, `customer_bottom_navigation.dart`, `settings_view.dart`, `supabase_schema.sql`.
- Paralel çalışamayacağı lane'ler:
  - `settings_view.dart` veya navigation değişikliği gerekiyorsa LANE C
  - Aynı chat SQL/RPC alanına dokunan başka bir lane
- SQL/migration sahipliği: Yalnız açıkça atanmış chat migration dosyalarını hazırlayabilir. Ortak schema güncellemesi ve migration sırası integration agentına aittir.
- Parallel safety: **HIGH**, merkezi wiring dosyaları integration agentına bırakıldığı sürece.

## LANE C — Müşteri Hesabı, Gizlilik ve Bildirimler

- Kapsam: Profil, hesap, kayıtlı konumlar, legal/privacy, in-app bildirimler ve müşteri ayarları.
- Ana klasörler:
  - `lib/features/personalization/`
  - `lib/features/notifications/`
  - Gerektiğinde sınırlı `lib/features/auth/` alanı
  - İlgili personalization/notifications/auth testleri
- Bağımlılıklar: Profiles, auth session, legal consents, saved locations, location permission, notifications, chat unread.
- Hot-spot/shared files: `settings_view.dart`, `service_locator.dart`, auth session listener, navigation badge, profile/notification SQL.
- Paralel çalışamayacağı lane'ler:
  - `settings_view.dart` veya unread navigation değişiyorsa LANE B
  - Merchant auth/role değişiyorsa LANE E
- SQL/migration sahipliği: Profile, consent, saved-location veya notification migration'ı gerekiyorsa wave'in tek SQL sahibi olmalıdır; ortak schema entegrasyonu integration agentına aittir.
- Parallel safety: **MEDIUM**

## LANE D — Sepet, QR, Alışveriş Geçmişi ve Puanlama

- Kapsam: Cart V2, tek-mağaza kuralı, QR session/verification, doğrulanmış alışveriş geçmişi, rating/review model bütünlüğü.
- Ana klasörler:
  - `lib/features/cart/`
  - `lib/features/purchases/`
  - `lib/features/reviews/`
  - `lib/features/shop/presentation/views/cart_v2_view.dart`
  - İlgili cart/purchases/reviews testleri
- Bağımlılıklar: Shops, ShopProducts, auth, merchant scanner, Supabase RPC/RLS ve migration zinciri.
- Hot-spot/shared files: `cart_v2_view.dart`, ShopProduct modelleri, Shop repository, `service_locator.dart`, `supabase_tables.dart`, QR/rating migration'ları.
- Paralel çalışamayacağı lane'ler:
  - LANE E
  - ShopProduct/repository değişiyorsa LANE A
  - Başka SQL/migration yazan lane
- SQL/migration sahipliği: Bu lane SQL gerektiriyorsa wave'in tek SQL sahibi olur. QR/rating migration'ları tek agent tarafından hazırlanır; integration agentı sıralama, schema ve RLS bütünlüğünü doğrular.
- Parallel safety: **MEDIUM**

## LANE E — Merchant Altyapısı

- Kapsam: Mevcut merchant login/role, mağaza profili, QR scanner ve gelecekte açıkça atanırsa merchant ürün/stok yönetimi.
- Ana klasörler:
  - `lib/features/shop/presentation/views/my_shop_*`
  - `lib/features/cart/presentation/views/merchant_qr_scanner_view.dart`
  - İlgili Shop repository/model/entity ve auth role alanları
- Bağımlılıklar: Auth rolleri, Shops, ShopProducts, Cart/QR, DI ve RLS.
- Hot-spot/shared files: Shop repository/model/entity, `service_locator.dart`, login/auth role akışı, shops/shop_products ve QR migration'ları.
- Paralel çalışamayacağı lane'ler:
  - LANE A
  - LANE D
  - Auth role değişiyorsa LANE C
- SQL/migration sahipliği: Merchant/shop migration'ı gerekiyorsa wave'in tek SQL sahibi olur. LANE D ile aynı wave'de SQL geliştirmez.
- Parallel safety: **LOW**
- Güncel ürün önceliği notu: Mevcut merchant altyapısı korunur; merchant ürün/stok genişletmesi şu an ana geliştirme önceliği değildir.

## Wave Öncesi Kontrol Listesi

1. Seçilen iş paketlerinin lane'lerini belirle.
2. Aynı hot-spot/shared dosyayı isteyen işleri aynı wave'den çıkar veya tek agente ver.
3. SQL/migration sahibini en fazla bir production agent olarak belirle.
4. `service_locator.dart`, app bootstrap ve navigation değişikliklerini integration agentına ayır.
5. Mevcut snapshot'ta production agent sayısını gerçek çakışma durumuna göre 1–3 arasında seç; `3` sayısını kalıcı hedef, zorunluluk veya gelecekteki üst sınır kabul etme.
6. Her agent için task branch/worktree, dosya sınırı ve teslim raporu tanımla.
7. Entegrasyon sırasını wave başlamadan belirle.

## Güncelleme Kuralı

- Yeni bir shared dosya, merkezi servis veya migration bağımlılığı ortaya çıkarsa bu harita güncellenir.
- Lane safety seviyesi yalnız kod yapısı veya bağımlılık sınırı değiştiğinde revize edilir.
- Her wave'in gerçek agent sayısı bu snapshot'tan bağımsız yeniden değerlendirilir.
