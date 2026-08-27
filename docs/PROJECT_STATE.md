# EsnaftaVar Project State

## Snapshot Bilgisi

- Son güncelleme: 2026-08-27
- Son doğrulanan teslim: Wave 15 Phase A Canonical Taxonomy Architecture + final
  24 Product L1 owner lock entegrasyonu.
- Integration branch/base: `integration/wave-15-phase-a-taxonomy` /
  `origin/main@7992dee8fb6512c53a94e8a094ab2b729a49bc3a`.
- Input/merge:
  `origin/agent3/w15-canonical-taxonomy-architecture-l1@5bb2fdba30ed1c00801f061c008373471884a42f`
  / `430bc3aeb51c6d465a4ad63ee9b162d664705fb0` (`--no-ff`, conflict yok).
- Entegrasyon durumu: **WAVE 15 PHASE A FINAL INTEGRATION PASS / TAXONOMY
  ARCHITECTURE CANONICAL / 24 PRODUCT L1 OWNER FINAL / RUNTIME NOT STARTED**.
- Canonical Phase A source-of-truth
  `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md`; exact owner-approved L1 adı ve
  sırası `24/24`, duplicate `0` ve yeniden isimlendirme olmadan kilitlidir.
- Product Taxonomy ("bu ürün nedir?"), Merchant/Sector Taxonomy ("bu işletme
  nedir?") ve Facet/Attribute (brand, color, size, capacity, material,
  compatibility) ayrımı **FINAL**'dir. Her canonical product exactly one primary
  canonical leaf'e bağlanır; tree variable-depth `L1 → L2 → L3 → optional
  L4`, max depth `4` ve leaf `L2/L3/L4` olabilir.
- Stable identity future contract'ı current V1 source slug'larını korur; display
  rename identity'yi değiştirmez, future opaque ID + permanent alias/redirect,
  stable-ID product FK/analytics ve identity-safe rename mapping gerekir. Combined
  `Oyuncak, Hobi & Müzik` → `Oyuncak & Hobi` + `Müzik & Enstrüman` successor
  mapping'i ayrı controlled runtime task'tır.
- Current `docs/data/esnaftavar_category_taxonomy_v1_final.json` bu turda Git blob-level
  değiştirilmedi: korunmuş full-tree baseline `23/91/505/32`, `651` node ve
  SHA-256 `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08`
  olarak kalır. Bu baseline 24-L1 owner lock ile reconcile edilmiş veya runtime'a
  deploy edilmiş sayılmaz.
- Demo mapping conceptual `4/4` PASS: Elektronik → Elektronik, Kırtasiye →
  Kırtasiye & Ofis, Gıda → Gıda & İçecek, Ayakkabı → Ayakkabı. Production
  demo dataset'i değişmedi.
- Merchant/Sector future scope'unda `Berber, Kuaför & Güzellik Salonu` ile
  `Erkek Berberi`, `Kadın Kuaförü`, `Güzellik Salonu` **CONFIRMED**;
  `Unisex Kuaför` **ABSENT / DO NOT ADD**. Booking, rezervasyon ve hizmet fiyat
  modeli TBD kalır. `Market` ve `Pet Shop` product L1 değildir.
- Figma/runtime uyumluluğu data-driven, max-4 ve variable-depth'tir;
  CategoryCard/CategoryRow ile category/product listing ve search/filter mimarisi
  hazırdır. Bu integration Figma, Flutter, DB/schema/migration, canonical JSON,
  demo data veya remote backend değişikliği yapmadı.
- Phase B, ayrı taxonomy-design turunda önce Elektronik, sonra Bilgisayar & Tablet
  L2/L3/L4 metodolojisiyle başlar. Runtime schema/ID bridge/reconciliation,
  Production/demo migration ve deploy ayrı yetki gerektirir.
- Bir önceki doğrulanan teslim Wave 14 Phase B3 Canonical Component Layer V1 final
  entegrasyonudur.
- Integration branch/base: `integration/wave-14-b3-component-layer` /
  `origin/main@911e326609fed85e3d6b55be6d27d75a91ce2176`.
- Input/merge:
  `origin/agent-ui/w14-canonical-component-layer-v1@c9ce40c74b974fb91f1101d95e36718930c71b6c`
  / `a16ef712a85ba84dcdf38a970aee440675ce2596` (`--no-ff`, conflict yok).
- Entegrasyon durumu: **WAVE 14 PHASE B3 FINAL INTEGRATION PASS / CANONICAL
  COMPONENT LAYER V1 INTEGRATED / SOURCE K'PASA UNCHANGED / RUNTIME CODE NO**.
- Canonical source-of-truth `docs/ESNAFTAVAR_COMPONENT_LIBRARY_V1.md`; Figma
  `EsnaftaVar — Components V1` page `52790:2`, canonical board `52790:3`
  (`2520 × 5036`) üzerinde `14` public family, `11` component set ve `79`
  canonical component node taşır.
- Button, TextField, actual five-target BottomNav, dynamic/availability-aware
  CategoryCard/CategoryRow, Grid/List + image-fallback ProductCard,
  SellerPriceRow, MerchantCard, ShopRatingSummary, server-authoritative
  VerifiedPurchaseBadge, single-store Cart V2 ve StatusChip sözleşmeleri
  canonical V1 olarak korunur.
- Component root Auto Layout `79/79`, canonical token binding, Poppins-only,
  duplicate public/full component name `0`, legacy `#FF8523` `0`, `44 px` altı
  interactive target `0` ve Turkish overflow/clipping `0` PASS'tir. Primary/white
  `5.37:1`, accent/white `6.33:1` korunur.
- Protected K'pasa Cover/UI/Components/Styles fingerprint'leri input kanıtında
  değişmemiştir; source screen/component/instance/style mutation `0` ve
  Integration Figma write `0`'dır.
- `Sponsored` yalnız future visual disclosure state'idir; advertising engine veya
  paid ranking implementasyonu değildir. Verified state istemciden üretilemez;
  server-authoritative kalır. Category componentleri Wave 15 canonical taxonomy'yi
  dinamik tüketmeye hazırdır ve hierarchy hard-code etmez.
- Bu entegrasyon docs/coordination ile sınırlıdır. Flutter runtime, backend,
  Production ve Development değişmedi. Product-owner visual review, critical
  screen pilot, taxonomy UI implementation ve full Flutter token/component migration
  açık kalır.
- Bir önceki doğrulanan teslim Wave 14 Phase B2 Design Tokens V1 final
  entegrasyonudur.
- Integration branch/base: `integration/wave-14-design-tokens-v1-final` /
  `origin/main@63d86a6df168b35e77c151dae0c620704f654e29`.
- Input/merge:
  `origin/agent-ui/w14-design-tokens-v1-proposal@bf31c4ae9703e4c3c9819557ee7976944e37ba18`
  / `f20718d1d9d170ef43c30e73f9acbb6dde52e736` (`--no-ff`, conflict yok).
- Entegrasyon durumu: **WAVE 14 PHASE B2 FINAL INTEGRATION PASS / DESIGN TOKENS
  V1.0.0 FINAL + CANONICAL / SOURCE K'PASA UNCHANGED / RUNTIME MIGRATION NO**.
- Product-owner final görsel dili **Mahalle Terracotta**; primary `#B54732`, accent
  `#1F6B5D`, yalnız Poppins typography, spacing `4/8/12/16/20/24/32/40/48`, radius
  `8/12/16/999`, touch target `44 px` minimum ve `48 px` preferred olarak sabittir.
- Canonical foundation `EsnaftaVar / Color` içinde `38`, `EsnaftaVar / Dimension`
  içinde `15` variable; `12` `EsnaftaVar/type/*` style ve `shadow/xs`, `shadow/sm`,
  `shadow/md` effect style'larını taşır. Manifest toplam `68` final token içerir;
  duplicate name `0`, intentional alias `12`, broken alias/cycle `0` doğrulandı.
- Primary/white `5.37:1`, accent/white `6.33:1`; primary, accent ve dört state
  strong/soft çiftinin tamamı normal metin AA eşiğini geçer. Touch standardı ürün
  kuralı olarak korunur ve anlam yalnız renkle taşınmaz.
- Input Figma kanıtında yalnız izole EsnaftaVar token foundation + proposal binding'i
  oluşturulmuştur. K'pasa source screen, component, instance ve mevcut style
  değişikliği `0`; dört protected page fingerprint'i değişmemiştir. Integration Figma
  write yapmadı.
- Bu entegrasyon docs/data ve coordination ile sınırlıdır. Flutter runtime,
  Production ve Development değişmedi. Canonical EsnaftaVar component layer,
  ProductCard/SellerPriceRow/Navbar/TextField redesign, critical screen pilot,
  taxonomy UI implementation ve full Flutter UI migration açık kalır.
- Bir önceki canonical product kararı Wave 15 Category Taxonomy V1.0.0 final
  entegrasyonudur.
- Integration branch/base: `integration/wave-15-category-taxonomy-v1-final` /
  `origin/main@a3cc0971175f5401b1cf0cbe5b914e42d5dc0088`.
- Input/merge:
  `origin/agent-taxonomy/w15-category-taxonomy-research@9a68bc9a7e43441daf971f09d5784cf4a9fc8e4e`
  / `eedfc60f79c0136759e5383da0c628f5e48f8285` (`--no-ff`, conflict yok).
- Entegrasyon durumu: **WAVE 15 CATEGORY TAXONOMY V1 FINAL INTEGRATION PASS /
  CATEGORY TAXONOMY V1.0.0 FINAL + CANONICAL / RUNTIME DEPLOYED NO**.
- Canonical JSON exact `L1/L2/L3/L4 = 23/91/505/32`, toplam `651` node,
  `525` leaf, `524` aktif atanabilir leaf ve tek `inactive_review` / non-assignable
  `hediyelik-obje` taşır. Owner kararları `24/24` uygulanmış; duplicate slug/sibling,
  cycle, orphan ve invalid filter/risk reference sayıları `0`, max depth `4` olarak
  bağımsız doğrulanmıştır.
- Canonical Git/LF JSON SHA-256
  `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08`.
  Stable immutable slug, PATCH/MINOR/MAJOR versioning, deprecation/replacement ve
  alias governance sözleşmeleri `v1.0.0` baseline olarak finaldir.
- Her canonical ürün tam bir primary aktif atanabilir leaf'e bağlanır; marka,
  varyant, attribute/filter, alias, offer ve shop type taxonomy değildir. Riskli
  yayın fail-closed; ikinci el/yenilenmiş V1'de deferred ve gelecekte `condition`
  attribute'u; shop-type ayrı merchant-domain çalışmasıdır.
- Home projection canonical ağaç değildir: availability-gated sekiz organik kısayol
  ve bütün 23 L1'i açan Tüm Kategoriler kararı korunur; sponsorlu yerleşim canonical
  veya organik sıralamayı değiştirmez.
- Bu entegrasyon yalnız docs/data ve coordination değişikliğidir. Flutter runtime,
  Figma, migration, seed, Production ve Development değişmedi. DB taxonomy schema/
  migration, Production seed/migration, search/index, filter-family implementation,
  sekiz-leaf attribute pilotu, Figma category/search/filter uyarlaması ve ayrı
  shop-type taxonomy açık kalır.
- Bir önceki dokümantasyon baseline'ı Wave 14 K'pasa design-system audit'idir;
  Figma redesign bu Wave 15 entegrasyonunda başlatılmadı.
- Bir önceki release baseline'ı Wave 13 Phase B korunmuş signed Production APK
  fiziksel Android customer acceptance final entegrasyonudur.
- Integration branch/base: `integration/wave-13-phase-b-physical-android` /
  `origin/main@22c78c65a1fc479d81da7c88c9f27531b345e522`.
- Input/merge:
  `origin/agent1/w13-physical-android-apk-acceptance@920b95e0b4b39bd783177974b41e6fd5baa8ba4c`
  / `6c15e0224ee08e6bda17b1eb9a2f5a2d2445753d` (`--no-ff`, conflict yok).
- Entegrasyon durumu: **WAVE 13 PHASE B FINAL INTEGRATION PASS / PHYSICAL ANDROID
  RELEASE ACCEPTANCE PASS / FUNCTIONAL ANDROID BLOCKERS NONE**.
- Korunmuş exact SHA-256 APK yeniden build edilmeden POCO X7 Pro / Android 16
  (API 36) cihazına aynı signer doğrulaması sonrası uninstall/clear-data olmadan
  normal reinstall edildi. Hash, v2/tek signer, package `com.esnaftavar.app`, label
  `EsnaftaVar`, version `1.0.0 (1)` ve non-debuggable contract PASS.
- Fiziksel startup/foreground/process, gerçek Production Home, kategori,
  ProductDetails, multiple seller/price, shop, `Defter` araması, Yakındakiler ve back
  stack PASS. Konum runtime permission yeniden istendi; izin sonrası `57 mağaza`
  yakınlığa göre sıralandı, crash/error görülmedi.
- Camera permission manifestte mevcut; scanner yalnız merchant-owned aktif shop
  ekranından erişilebilir. Demo shop owner'ları `NULL`, merchant principal yok ve
  görev Auth/merchant fixture yazmasını yasakladığından scanner Auth bypass edilmeden
  açılmadı. Bu functional blocker değil, ayrı merchant/two-device acceptance sınırı.
- Agent fiziksel turunda yalnız customer read yüzeyleri için Production reads `YES`;
  Production writes/Auth/business/Storage fixture, Development erişimi ve rebuild
  `NO`. Agent hedefli test `87` PASS (`2` gated live skip). Final Integration remote
  read/write yapmadan hedefli matrisi `143` PASS (`2` gated live skip), tam suite'i
  `1213` PASS (`6` gated live skip) ve analyzer'ı temiz yeniden doğruladı.
- Bir önceki entegre baseline: Wave 13 Phase A Android gerçek release signing kanıtı
  ve korunmuş Production signed APK/AAB final entegrasyonu.
- Integration branch/base: `integration/wave-13-phase-a-android-signing` /
  `origin/main@305dd74d4e94c77a1144955eadd856c3f760bb45`.
- Input/merge:
  `origin/agent2/w13-android-real-release-signing@d966f55f2793c08eb05d9527b8c11d8c5b18b5f2`
  / `52f1e98946938f9f656fc5f6a4bac80c98e90bf1` (`--no-ff`, conflict yok).
- Önceki entegrasyon durumu: **WAVE 13 PHASE A FINAL INTEGRATION PASS / SIGNED ANDROID
  ARTIFACTS PRESERVED / ANDROID SIGNING RELEASE GATE PASS**.
- Mevcut repo-dışı owner upload keystore yeniden kullanıldı; yeni key üretilmedi.
  `com.esnaftavar.app`, `1.0.0 (1)`, final callback ve canonical upload certificate
  fingerprint'i resmi artifact araçlarıyla PASS. Korunmuş APK
  `C:\Users\Mustafa\EsnaftavarReleases\1.0.0\EsnaftaVar-1.0.0-production.apk`,
  SHA-256
  `47650AB049F8212DB05EEFE382689B8EB3321C1799AAE8C797C125D63CA534DA`; AAB SHA-256
  `0621845CF387CB8C6CE69E04A0F991DF8EB95DC864DAD2EA0D8B0E6FD9DE54F9` ve yolu
  `C:\Users\Mustafa\EsnaftavarReleases\1.0.0\EsnaftaVar-1.0.0-production.aab`.
- Production structural preflight ve client-safe runtime injection PASS. Artifact ve
  Git scan'leri Development URL/package/callback aktivasyonu, server/private key,
  service-role JWT, signing parolası veya tracked signing materyali bulmadı.
  Entegrasyon Production/Development remote read/write, Auth, SMTP, migration ve
  Storage işlemi yapmadı; artifact'ları yeniden üretmedi ve signing credential'a
  erişmedi.
- Korunmuş binary'ler üzerinde APK v2/tek signer ve AAB `jar verified`, exact package,
  version, callback, certificate fingerprint ve secret/identity taraması yeniden PASS.
  Hedefli matris `50/50`, tam Flutter suite `1213` PASS (`6` opt-in live skip),
  analyzer PASS. Phase A sonrasında açık olan fiziksel APK install/startup/customer
  smoke ve location kabulü Phase B'de PASS; confirmation/recovery authoritative B6
  PASS durumu korunur. Fiziksel merchant scanner/iki-cihaz QR, Play Console AAB
  kabulü, ikinci offline keystore yedeği, iOS signing/archive ve final commercial GO
  açık kalır.
- Bir önceki entegre baseline: Wave 12 Phase D Production demo functional smoke final
  integration.
- Integration branch/base: `integration/wave-12-phase-d-functional-smoke` /
  `origin/main@609e55572faa10b9608cc8eda16c6c8061180261`.
- Input/merge:
  `origin/agent1/w12-production-demo-functional-smoke@8c869e53ab1fc71ed5bd564cafa6907cf0ca59b0`
  / `42774fee3cc5a6667ea4e2f9f41172c4d854a7d8` (`--no-ff`, conflict yok).
- Entegrasyon durumu: **WAVE 12 PHASE D FINAL INTEGRATION PASS / FUNCTIONAL
  RELEASE BLOCKERS NONE**
- Gerçek `main_production.dart` Web release runtime'ı canonical `EsnaftaVar
  Production` / `mefhfvrgkwciubeajjeb` ref'inde yalnız read-only çalıştı. Startup,
  Home, dört kategori, ProductDetails, seller comparison, shop, search, nearby ve
  anonymous wishlist/cart/profile login gate akışları PASS; dead-end, wrong route,
  crash, wrong/eksik veri veya unusable layout görülmedi.
- Exact-ref fail-closed live harness gerçek anonymous Production read contract'ında
  `4/20/57/285`, her kategoride `5` ürün, ürün başına `14–15` seller, `20/20`
  multiple price, mağaza başına `5` listing ve `57` valid/unique coordinate
  doğruladı. Development'a erişilmedi; Production/Auth/business/Storage write veya
  fixture oluşturulmadı.
- Runtime functional bug/release blocker bulunmadı. Phase C öncesinden kalan stale
  empty-catalog harness beklentisi current demo baseline'ına güncellendi ve kapsamlı
  müşteri read harness'ı eklendi. Renk/font/spacing/kart/ikon/padding ve genel görsel
  redesign product-owner kararıyla final UI kit'e ertelendi. Hedefli matris `564/564`,
  Production live harness `4/4`, tam Flutter suite `1213` PASS (`6` explicit opt-in
  live skip) ve analyzer sıfır bulguyla Agent turunda tamamlandı. Integration remote
  define vermeden harness safety gate'leri dahil hedefli matrisi `552` PASS (`2`
  Production live skip), tam suite'i `1213` PASS (`6` explicit live skip) ve analyzer'ı
  sıfır bulguyla yeniden doğruladı; Production/Development remote erişimi yapmadı.
- BLOCKED/açık kontroller: `owner_user_id = NULL` demo shop'lar için merchant
  ownership/QR/verified purchase intentional unavailable; fiziksel iki-cihaz QR,
  Play Console/Play App Signing, iOS archive/signing ve final commercial GO ayrıca
  açıktır.

`WAVE_13_PHASE_A_INTEGRATION: PASS`

`SIGNED_ANDROID_ARTIFACTS_PRESERVED: YES`

`ANDROID_SIGNING_RELEASE_GATE: PASS`

`READY_FOR_PHYSICAL_ANDROID_ACCEPTANCE: COMPLETED — WAVE 13 PHASE B`

`WAVE_13_PHASE_B_INTEGRATION: PASS`

`PHYSICAL_ANDROID_RELEASE_ACCEPTANCE: PASS`

`PHYSICAL_LOCATION_ACCEPTANCE: PASS`

`PHYSICAL_TWO_DEVICE_QR_ACCEPTANCE: OPEN`

`FUNCTIONAL_ANDROID_BLOCKERS: NONE`

`WAVE_14_PHASE_B2_INTEGRATION: PASS`

`DESIGN_TOKENS_V1_CANONICAL: YES`

`SOURCE_KPASA_UNCHANGED: YES`

`READY_FOR_CANONICAL_COMPONENT_LAYER: YES`

`WAVE_14_PHASE_B3_INTEGRATION: PASS`

`CANONICAL_COMPONENT_LAYER_V1: PASS`

`SOURCE_KPASA_UNCHANGED: YES`

`RUNTIME_CODE_CHANGED: NO`

`READY_FOR_CRITICAL_SCREEN_PILOT: YES`

`WAVE_15_PHASE_A_INTEGRATION: PASS`

`CANONICAL_L1_LOCK: PASS`

`CANONICAL_L1_COUNT: 24`

`PRODUCT_MERCHANT_FACET_SEPARATION: PASS`

`CURRENT_FULL_TREE_JSON_RECONCILED_TO_24_L1: NO`

`RUNTIME_TAXONOMY_IMPLEMENTED: NO`

`READY_FOR_TAXONOMY_PHASE_B: YES`

`WAVE_15_TAXONOMY_INTEGRATION: PASS`

`CATEGORY_TAXONOMY_V1_CANONICAL: YES`

`TAXONOMY_DEPLOYED_TO_RUNTIME: NO`

`READY_FOR_TAXONOMY_IMPLEMENTATION_DESIGN: YES`

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / ANDROID-IOS WIRING COMPLETE`

`PRODUCTION_CLIENT_WIRED: YES`

`FINAL_APP_IDENTITY_WIRED: YES`

`FINAL_AUTH_CALLBACK_IMPLEMENTATION: PASS`

`PHASE_F_CALLBACK_INTEGRATED: YES`

`SMTP_CONFIGURATION_PRESENT: YES`

`PRODUCTION_SITE_URL_FINAL_CALLBACK: PASS`

`PHASE_F3_PREWRITE_GATE: PASS — HISTORICAL ZERO BASELINE BEFORE B3R`

`AUTH_USER_BASELINE_EXPLAINED: YES`

`REAL_SMTP_DELIVERY: PASS`

`SERVER_SIDE_EMAIL_CONFIRMATION: PASS`

`FINAL_CALLBACK_EMAIL_CONTRACT: PASS`

`FINAL_CALLBACK_APP_OPENING: PASS`

`PRODUCTION_PASSWORD_RECOVERY: PASS — B6 SAME-CREDENTIAL FRESH LOGIN + NORMAL LOGIN`

`AUTHORIZED_TEST_USER_CLEANUP: PASS — F3D/B3A/B3R/B6`

`PRODUCTION_ZERO_AUTH_BASELINE_RESTORED: YES — B6 CANONICAL SELF-DELETE EXACT ZERO`

`TEST_FIXTURE_CLEANUP: PASS — B6 CANONICAL delete_current_customer_account`

`PRODUCTION_ZERO_TEST_RESIDUAL: YES`

`PRODUCTION_EMAIL_INFRASTRUCTURE: READY`

`F2_PRODUCTION_SMTP_PRECHECK: FAIL — HISTORICAL PRE-LIVE CHECK`

`EMAIL_TEMPLATE_PRECHECK: PASS`

`PHASE_F_LIVE_EMAIL_ACCEPTANCE: PASS — B6 FINAL PHYSICAL ACCEPTANCE`

`MOBILE_AUTH_CALLBACK_ACCEPTANCE: PASS`

`PASSWORD_RECOVERY_MOBILE_ACCEPTANCE: PASS — B6`

`LEGACY_PRODUCTION_CALLBACK_REMOVAL: COMPLETED`

`EMAIL_DELIVERABILITY_TUNING: MONITOR — B6 CONFIRMATION/RECOVERY INBOX; HISTORICAL SPAM`

`CONFIRMATION_SUCCESS_UI_PHYSICAL: PASS — B6`

`RECOVERY_FRESH_LOGIN_PHYSICAL: PASS — B6`

`FINAL_PRODUCTION_CALLBACK_ONLY: YES`

`AUTH_CONFIG_POSTFLIGHT: PASS`

`WAVE_11_PHASE_B7_INTEGRATION: PASS`

`PRODUCTION_AUTH_CALLBACK_CUTOVER: COMPLETE`

`READY_FOR_ESENLER_DEMO_DATASET: COMPLETED — PHASE A ARTIFACT READY`

`WAVE_12_PHASE_A_INTEGRATION: PASS`

`DEMO_DATASET_ARTIFACT: READY`

`PRODUCTION_DEMO_SEED_APPLIED: YES — 4/20/57/285`

`READY_FOR_DEMO_DATASET_PHASE_B: COMPLETED — SAFETY REVIEW INTEGRATED`

`WAVE_12_PHASE_B_INTEGRATION: PASS`

`DEMO_SEED_SAFETY_REVIEW_INTEGRATED: YES`

`READY_FOR_OWNER_DEMO_SEED_AUTHORIZATION: COMPLETED — PHASE C`

`OWNER_DEMO_SEED_AUTHORIZATION: GRANTED_AND_CONSUMED_FOR_EXACT_SEED`

`PRODUCTION_DEMO_CUSTOMER_READ: PASS — ANON RLS ROLE`

`PRODUCTION_DEMO_CLEANUP_RUN: NO`

`WAVE_12_PHASE_C_INTEGRATION: PASS`

`PRODUCTION_DEMO_DATASET_LIVE: YES`

`PRODUCTION_DEMO_SEED_REAPPLIED: NO`

`READY_FOR_PRODUCTION_DEMO_VISUAL_SMOKE: YES`

`PRODUCTION_DEMO_FUNCTIONAL_SMOKE: PASS — WEB RELEASE + ANON LIVE HARNESS`

`FUNCTIONAL_RELEASE_BLOCKERS_FOUND: NO`

`COSMETIC_UI_POLISH_DEFERRED: YES — UNTIL FINAL UI KIT`

`READY_FOR_WAVE_12_PHASE_D_INTEGRATION: COMPLETED`

`WAVE_12_PHASE_D_INTEGRATION: PASS`

`FUNCTIONAL_RELEASE_BLOCKERS: NONE`

`COSMETIC_UI_POLISH: DEFERRED`

`READY_FOR_NEXT_RELEASE_GATE: YES`

`LEGACY_PRODUCTION_ALLOWLIST_REMOVAL_REQUIRED: NO`

`ANDROID_SIGNING_READY: YES`

`IOS_SIGNING_READY: NO`

`SIGNED_PRODUCTION_APK: PASS`

`SIGNED_PRODUCTION_AAB: PASS`

`SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`

`KEYSTORE_PRIMARY_BACKUP: COMPLETED`

`KEYSTORE_SECOND_OFFLINE_BACKUP: RECOMMENDED / OPEN`

`READY_FOR_PHYSICAL_ANDROID_ACCEPTANCE: COMPLETED — WAVE 13 PHASE B`

`ANDROID_PHYSICAL_ACCEPTANCE: PASS — SIGNED APK CUSTOMER RELEASE SMOKE`

`PHYSICAL_SIGNED_APK_INSTALL: PASS`

`PHYSICAL_PRODUCTION_STARTUP: PASS`

`PHYSICAL_PRODUCTION_CUSTOMER_SMOKE: PASS`

`CAMERA_SCANNER_SURFACE: NOT RUN — MERCHANT PRINCIPAL REQUIRED`

`FUNCTIONAL_BLOCKERS_FOUND: NO`

`COSMETIC_UI_POLISH: DEFERRED`

`READY_FOR_ANDROID_PHYSICAL_INTEGRATION: COMPLETED — FINAL INTEGRATION PASS`

`WAVE_11_B2_AUTOMATED_REGRESSION: PASS`

`INPUT_VISIBILITY_BUG: FIXED`

`EMAIL_CONFIRMATION_UI_CODE_FIX: PASS — B6 PHYSICAL SUCCESS FEEDBACK PASS`

`LOCATION_PERMISSION_BUG: FIXED`

`ANDROID_SIGNED_APK_INSTALL_UPGRADE: PASS`

`ANDROID_STARTUP_PHYSICAL_ACCEPTANCE: PASS`

`INPUT_PHYSICAL_ACCEPTANCE: PASS — HOME SEARCH VALUE/HINT/CURSOR`

`LOCATION_PHYSICAL_ACCEPTANCE: PASS`

`CONFIRMATION_UI_PHYSICAL_ACCEPTANCE: PASS — B6 DESTINATION NOTICE VISIBLE`

`SETTINGS_RETURN_NEGATIVE_PHYSICAL_ACCEPTANCE: OPEN`

`PHYSICAL_DEVICE_REGRESSION: PASS — B6 CONFIRMATION + RECOVERY`

`PHYSICAL_CONFIRMATION_CALLBACK: PASS`

`WAVE_11_B3R_EVIDENCE_INTEGRATION: PASS`

`CONFIRMATION_SUCCESS_UI: PASS — B6 PHYSICAL`

`V1_0_AUTH_BUG_CONFIRMATION_SUCCESS_FEEDBACK: CLOSED — B5 CODE + B6 PHYSICAL PASS`

`PRODUCTION_AUTH_ROLE_SECURITY: PASS — CUSTOMER REMAINED CUSTOMER`

`WAVE_11_B3R_MOBILE_AUTH_ACCEPTANCE: BLOCKED — HISTORICAL B3R RESULT`

`V1_0_AUTH_BUG_RECOVERY_CREDENTIAL_PERSISTENCE: CLOSED FOR CURRENT B5/B6 FLOW`

`AUTHORIZED_B3R_FIXTURE_CLEANUP: PASS`

`READY_FOR_RECOVERY_BUG_INVESTIGATION: YES`

`READY_FOR_AUTH_RECOVERY_ROOT_CAUSE_ANALYSIS: COMPLETED — B4`

`CONFIRMATION_UI_ROOT_CAUSE: FOUND`

`RECOVERY_FALSE_SUCCESS_ROOT_CAUSE: FOUND`

`RECOVERY_PASSWORD_ROOT_CAUSE: NOT_FOUND`

`PASSWORD_UPDATE_AUDIT_EVENT_PRESENT: UNKNOWN`

`V1_0_AUTH_BUG_RECOVERY_FALSE_SUCCESS_GUARD: CLOSED IN B5 CODE`

`V1_0_AUTH_RETEST_PASSWORD_PERSISTENCE_BEHAVIOR: PASS — B6`

`READY_FOR_AUTH_FIX_IMPLEMENTATION: COMPLETED — B5 INTEGRATED`

`AUTH_CONFIRMATION_RECOVERY_FIX: PASS — INTEGRATED`

`WAVE_11_PHASE_B5_INTEGRATION: PASS`

`CONFIRMATION_SUCCESS_FEEDBACK_CODE_FIX: PASS`

`RECOVERY_FALSE_SUCCESS_GUARD: PASS`

`RECOVERY_FRESH_LOGIN_VERIFICATION: PASS`

`AUTH_REGRESSION: PASS`

`WAVE_11_PHASE_B6_INTEGRATION: PASS`

`PHYSICAL_MOBILE_AUTH_ACCEPTANCE: PASS`

`PRODUCTION_PASSWORD_RECOVERY_ACCEPTANCE: PASS`

`PHYSICAL_AUTH_RETEST_REQUIRED: NO — B6 PASS`

`READY_FOR_FINAL_PHYSICAL_AUTH_RETEST: COMPLETED — B6 PASS`

`WAVE_11_PHASE_B4_INTEGRATION: PASS`

`READY_FOR_MOBILE_AUTH_LIVE_ACCEPTANCE: COMPLETED — B6 PASS`

`WAVE_11_B3A_AUTHORIZED_FIXTURE_CLEANUP: PASS`

`B3A_CANONICAL_SELF_DELETE_ACCEPTANCE: PASS`

`SAVED_LOCATION_RESIDUAL: ZERO`

`PRODUCTION_ZERO_TEST_BASELINE: RESTORED — B6 CANONICAL SELF-DELETE`

`READY_TO_RESTART_B3_MOBILE_AUTH: COMPLETED — B6 PASS`

`COMMERCIAL_RELEASE_READY: NO`

Canonical recovery final success yalnız şu sırayla gösterilir: valid recovery
session/provenance; başarılı ve expected-user ile tutarlı password update response;
kontrollü recovery-session cleanup; aynı yeni password ile fresh normal login; fresh
login user identity'sinin expected user ile eşleşmesi. Yalnız HTTP `200` veya
no-exception final success değildir.

Bu dosya mevcut kod durumunun source-of-truth özetidir. Gelecek ürün fikirleri burada implemented gibi gösterilmez. Kod gerçeği ile ürün backlog'u ayrıdır; tamamlanmamış ürün işleri için `PRODUCT_BACKLOG.md` kullanılır.

## Mimari Özet

- Flutter/Dart istemcisi ve Supabase backend kullanılıyor.
- State yönetimi BLoC/Cubit, bağımlılık yönetimi GetIt ile yapılıyor.
- Feature'lar genel olarak `data/domain/presentation` katmanlarına ve repository/use-case yaklaşımına ayrılmış.
- Hata sonuçlarında çoğunlukla `dartz Either`, state karşılaştırmalarında `Equatable` kullanılıyor.
- Navigation, merkezi bir router paketi yerine `MaterialApp`, global navigator key ve doğrudan `Navigator/MaterialPageRoute` çağrılarıyla yürütülüyor.
- Beş ana müşteri sekmesi: Ana Sayfa, Yakındakiler, Sepet, Favoriler ve Profil.
- Auth, tablo CRUD, Storage ve Realtime için ortak `SupabaseService`; feature repository'lerinde doğrudan Supabase sorguları ve güvenli RPC çağrıları bulunuyor.
- Fresh Supabase bootstrap için resmi kaynak, `supabase/migrations/` altındaki sıralı `0001`–`0009` canonical zinciridir; kökteki eski schema/migration dosyaları yalnız tarihsel referanstır.
- Son aramalar, son görüntülenen ürünler ve bekleyen ürün sohbeti için SharedPreferences; konum için Geolocator kullanılıyor.
- Ortak tasarım altyapısı `TAppTheme`, widget theme dosyaları ve `customer_home_v1_tokens.dart` üzerinden ilerliyor. Eski ve yeni tasarım sabitleri birlikte bulunuyor.
- `main_development.dart` ve `main_production.dart` ayrı Dart-define ad alanlarını seçiyor; eksik, placeholder, güvensiz veya server-only config güvenli biçimde startup'ta reddediliyor ve ortamlar arasında fallback yapılmıyor.
- Wave 9 Production preflight yalnız exact `main_production.dart`, ref-host uyumu,
  client-safe key ve canonical Auth redirect kararlarını kabul eder; sentetik
  compile-contract release config olarak kullanılamaz.
- Wave 10'da canonical Production `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` /
  `https://mefhfvrgkwciubeajjeb.supabase.co` / Frankfurt olarak doğrulandı.
  Production canonical `0001→0009` schema/RLS/RPC/Storage contract'ına bootstrap
  edilmiştir ve business data halen sıfırdır. Development `tnipyxnvhgelwdpykyez`
  ayrı projedir ve Production değildir.
- Wave 10 Phase E1'de gerçek client-safe Production runtime config ile anonymous
  categories/products/shops/banners empty-state bağlantısı ve transient standart Web
  release build PASS; publishable key source, belge veya loga yazılmadı.
- Product owner final Android/iOS application/bundle identifier'ını
  `com.esnaftavar.app` olarak kesinleştirdi. Phase E2'de Android namespace,
  applicationId, MainActivity/Fastlane ve iOS Runner/RunnerTests build
  configuration'ları bu kimliğe bağlandı. Phase F1'de Production istemci/platform
  callback'i `com.esnaftavar.app://login-callback/` değerine taşındı; Development
  mevcut `io.supabase.tstore://login-callback/` sözleşmesini ayrı tutar. Phase F
  intermediate integration bu kaynak cutover'ını Auth/SMTP read-only precheck ile
  birleştirdi. Production Custom SMTP açıktır ve görünür host/port/name wiring'i
  mevcuttur; Site URL exact final mobile callback'tir. F3B gerçek SMTP teslimatı,
  server-side confirmation ve final callback email URL contract'ını doğruladı. F3D
  exact disposable fixture'ı temizledi ve Auth/business/Storage zero baseline'ını
  yeniden kurdu. Wave 11'de repo-dışı upload key ile ilk signed Android Production
  APK/AAB üretildi; exact Production application ID, version, manifest, callback,
  signature, hash ve artifact secret scan PASS. B2R'de fiziksel install/upgrade,
  startup, Home input görünürlüğü ve runtime location acquisition PASS oldu. Signed
  Production mobil uygulamada confirmation callback app opening PASS oldu. B3R
  authorized cleanup Auth/business/Storage zero baseline'ını tekrar kurdu; full
  recovery PKCE, confirmation success feedback, Resend link-tracking ve kabul
  sonrasındaki legacy allowlist removal B7'de tamamlandı.
- Feature flag, remote config, analytics/event tracking veya crash reporting altyapısı bulunamadı.

## Modül Durumları

`COMPLETE`, bu snapshot'ta görülen prototip kapsamındaki yapısal kod bütünlüğünü belirtir; canlı kabul veya bu snapshot sırasında testlerin geçtiği anlamına gelmez.

| Modül | Durum | Koddan doğrulanan durum |
|---|---|---|
| Authentication / login / signup | PARTIAL | E-posta/parola, kayıt, doğrulama, parola kurtarma, session listener ve legal consent var. Wave 10 Phase F'te Production final callback'i environment-specific merkezi sözleşmeyle entegre edildi; signup/resend/recovery explicit redirect kullanır ve PKCE yalnız exact scheme/host/path sonrası işlenir. Development callback'i korunur. Wave 11 B5 destination-owned confirmation notice ve authoritative recovery success guard'ını tamamladı. B6'da POCO X7 Pro / Android 16 üzerinde confirmation callback, görünür/kalıcı başarı feedback'i, recovery callback/update UI, aynı credential ile fresh normal login, same-user identity ve customer role güvenliği fiziksel PASS oldu. B6 canonical self-delete sonrası Auth/profile/consent/business/Storage residual exact sıfırdır. B7'de legacy Production allowlist kaydı kaldırıldı ve yalnız final Production callback korundu; Development callback'i kendi ortamında değişmedi. Tarihsel B3R persistence nedeni `NOT_FOUND` kalır; broader smoke açıktır. Wave 8'de işlevsiz sosyal giriş düğmeleri/ayırıcı aktif UI'dan kaldırıldı; provider abstraction gelecekteki optional özellik için korundu. Merchant kayıt akışı açık değil. |
| Ana sayfa | COMPLETE | Supabase ürünleri, kategoriler, banner'lar, yakındaki mağazalar, konum, arama ve temel state'ler bağlı; banner sıralama/tarih/bozuk veri/stale response/fallback ile async session ve duplicate navigation korumaları var. |
| Arama | COMPLETE | Ürün/kategori/mağaza birleşik araması, istek yarışı ve stale history snapshot koruması, cache, kısmi hata ve son aramalar var. |
| Kategoriler | COMPLETE | Repository, Cubit/use-case, kategori/alt kategori ekranları, satıcı fiyatları ve testler var. |
| Yakındakiler / location | COMPLETE | GPS, cihaz servis kontrolü, runtime izin isteği, kalıcı ret/app settings, location settings, ayar dönüşünde lifecycle refresh, last-known fallback, kayıtlı/manuel konum, mesafe sıralaması, hata/fallback, dispose sonrası async completion ve duplicate dialog/navigation korumaları var. |
| Mağaza profili | PARTIAL | Müşteri mağaza profili ve mesaj başlatma var; merchant ürün/stok yönetimi yok. |
| Ürün listeleme | COMPLETE | Liste, kategori, arama, sıralama, gerçek satıcı fiyatları, fallback ve state'ler var. |
| Ürün detay | COMPLETE | Satıcılar, stok/fiyat, favori, sepet, ürün bağlantılı chat ve yorum ekranı bağlı. |
| Sepet V2 | PARTIAL | Tek-mağaza sepeti, miktar/silme, fiyat-stok kontrolü, işlem kilitleri ve QR üretimi var; fiziksel uçtan uca kabul tamamlanmadı. |
| Favoriler | COMPLETE | Supabase repository, Cubit, guest-login devam akışı, kart entegrasyonu ve testler var. |
| Profil / hesap | COMPLETE | Profil düzenleme, avatar, hesap silme, kayıtlı konumlar, yardım/gizlilik ve testler var. |
| Doğrulanmış alışveriş geçmişi | COMPLETE | `verified_transactions` snapshot verileri, repository, Cubit, detay ekranı ve testler var. |
| Mesajlaşma / chat | COMPLETE | Ürün bağlantılı mesaj, konuşma listesi, pagination, Realtime lifecycle/reconnect/dedup, unread ve delivery/read state'leri var; Development üzerinde chat event delivery, RLS isolation, reconnect, dedup, unsubscribe ve summary RPC canlı doğrulandı. |
| QR / mağaza içi doğrulama | PARTIAL | Müşteri QR, merchant scanner, polling, tek kullanımlı onay, immutable snapshot revalidation, stale/duplicate/timeout korumaları ve güvenli RPC/RLS var; Development canlı testinde create/confirm, negative state'ler ve gerçek concurrent confirm geçti. Fiziksel iki cihaz kabulü bekliyor. |
| Bildirimler | PARTIAL | Supabase içi liste, pagination/refresh yarış koruması, session izolasyonu, Realtime lifecycle/dedup ve güvenli okundu/silme işlemleri var; Development canlı event/recipient isolation/mark-read doğrulandı. Geçici `channelError`/`timedOut` artık stream'i sonlandırmıyor; yalnız terminal `closed` kapatıyor. Push notification yok. |
| Puanlama / yorum | COMPLETE | FINAL Option A backend ve istemcide uygulandı: ürün yorumu yalnız merchant tarafından doğrulanmış server-authoritative QR işlemindeki durable ürün satırıyla açılır. Eligibility/read/create/idempotent duplicate/update/delete/recreate akışı RPC-only çalışır; verified bilgisi server-derived ve evidence immutable'dır. Development normal Auth canlı lifecycle testi geçti; legacy yorumlar korunur ancak verified aggregate'lere katılmaz. QR-doğrulanmış mağaza puanı da korunur. |
| Merchant altyapısı | PARTIAL | Rol kapısı, merchant login, mağaza oluşturma/düzenleme ve QR scanner var; merchant ürün/stok/fiyat/istatistik yönetimi yok. |
| Reklam / sponsored / campaign | SKELETON | Supabase banner gösterimi ve promotion bildirim tipi var; reklam/campaign motoru yok. |
| Kuponlar | SKELETON | Müşteri ekranı statik boş state gösteriyor; repository/Cubit/backend bağlantısı yok. |
| Ödül Çubuğu / gamification | NOT FOUND | Uygulama kodunda reward/task/badge domain'i bulunmuyor. |
| Analytics / event ölçümü | NOT FOUND | Event tracking veya analytics entegrasyonu bulunmuyor. |
| Permissions / privacy | PARTIAL | Legal belgeler/consent, hesap silme, konum izin durumu ve notification permission SQL'i var; merkezi preference/consent modeli yok. |
| Supabase / RLS | COMPLETE | Development ve Production projelerinde canonical `0001`–`0009` zinciri kayıtlıdır. Production D1 metadata postflight 23 public tablo, 23/23 RLS, final 52 policy, canonical grant/RPC/trigger seti ve exact üç active Storage bucket'ı doğruladı; Auth/business data sıfırdır. Development'ta `0008` role guard ile Wave 4 Auth/Profile/RLS, Realtime ve QR; `0009` review lifecycle normal Auth istemcileriyle canlı doğrulandı. |
| Automotive / Services | NOT FOUND | Yalnız generic `vehicle` ve `motorcycle` kategori metni/asset'i var; özel domain veya servis akışı yok. |
| Legacy order / checkout | SKELETON | Order repository/Cubit, testler ve shipping/payment alanları repoda duruyor; aktif müşteri navigation'ına ve GetIt DI grafiğine bağlı değil, hedef ürün akışı değil. |

## Önemli Teknik Borçlar

- Ürün yorumu için FINAL Option A uygulandı: yalnız merchant tarafından doğrulanmış server-authoritative fiziksel QR alışverişi ve ilgili durable ürün satırı eligibility verir; aktif yol legacy `orders/order_items` verisini kanıt kabul etmez. Korunan legacy yorumlar doğrulanmamış kalır ve verified aggregate'lere katılmaz.
- İşlevsiz sosyal giriş düğmeleri aktif Login/Signup UI'dan kaldırıldı; gelecekte OAuth açılması optional ürün/backlog işidir ve mevcut release'i bloke etmez.
- Kupon ekranı gerçek veriye bağlı değil.
- Merchant ürün/stok/fiyat yönetimi bulunmuyor; mevcut merchant altyapısı yalnız mağaza profili ve QR doğrulama seviyesinde.
- Legacy order/shipping/payment kodu hedef ürün modelinin dışında ve aktif DI grafiğinden çıkarılmış olduğu halde repoda tutuluyor.
- Development/production config sözleşmesi ayrıldı; Agent 1 gerçek client-safe Development değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure sözleşmelerini PASS olarak doğruladı. Production smoke ayrı release gate olarak açık.
- Iconsax release build blocker'ı kapandı: `iconsax 0.0.8` kaldırıldı, `iconsax_flutter 1.0.1` repo-local sınırlı compatibility katmanıyla kullanılıyor ve standart Web release build ek icon workaround'u olmadan PASS.
- `use_build_context_synchronously` global ignore'u kaldırıldı; Wave 3 birleşik durumda lint repo genelinde etkin ve analyzer temiz.
- Wave 6'da aktif `product-images`, `category-images` ve `banner-images` sözleşmesi kapatıldı: public object read, trusted operations write, exact versioned controlled path, bucket-side MIME/size limiti ve en az yedi günlük orphan retention uygulanır; Flutter istemcisine Storage mutation veya server credential verilmez. `brand-logos`, `avatars` ve `review-images` deferred kalır.
- Feature flag, analytics/event ve crash reporting altyapısı yok.
- Bazı merkezi view dosyaları çok büyük: `all_products_view.dart`, `cart_v2_view.dart`, `nearby_view.dart`, `chat_view.dart` ve `conversations_view.dart`.

## Kritik Integration Eksikleri

- QR müşteri → merchant scanner → onay → müşteri tamamlanma akışı iki gerçek cihazla kabul edilmedi.
- Wave 4 Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime Development integration testleri tamamlandı; fiziksel cihaz ve sonraki implementation gerektiren kapılar aşağıda açık tutuluyor.
- Ürün yorumu Option A server-authoritative doğrulanmış QR alışverişi/durable ürün satırı üzerinden backend ve istemcide uygulandı; frozen RPC sözleşmesiyle canlı Development lifecycle testi geçti.
- Development Supabase schema/RLS/RPC nesne sözleşmesi repo dosyalarından bağımsız remote audit ile doğrulandı; `0008` sonrası tam Wave 4 Auth/Profile/RLS canlı harness'i geçti.
- Gerçek client-safe Development değerleriyle web release build ve istemci smoke PASS; Production smoke yapılmadı.
- Production kimliği exact ref/name/URL/region ile doğrulandı. D1 öncesi fresh baseline ve zero-state JIT PASS; canonical 0001→0009 apply ve metadata/security postflight tamamlandı.
- Production current schema state: ledger 9/9, 23 public tablo, 23/23 RLS, final 52 policy, 28 app function, 25 trigger ve exact üç active bucket. Phase F3A exact SQL Auth user/identity/session `0/0/0`, profiles/consents `0/0` ve bütün user-linked business relations `0` doğruladı. F3 Dashboard `10 users (estimated)` göstergesi actual relation count değildi; D1 zero baseline geçerlidir. F3B tek disposable customer ile live email/server confirmation acceptance yaptı. F3D'de trusted Auth Admin cleanup sonrası Auth user/identity/session/profile/consent, business residual ve Storage object tekrar exact `0/0/0/0/0/0/0` doğrulandı. Owner'ın empty-first-bootstrap no-backup istisnası kullanıldı ve gelecekteki migration'lara emsal değildir.
- Canonical `0001`–`0009` zinciri Development Supabase'e uygulandı; remote migration kaydı `20260815000900 0009_verified_product_reviews_storage` olarak doğrulandı ve entegrasyonda yeniden uygulanmadı.
- Aktif üç Storage bucket ve least-privilege read sözleşmesi `0009` ile uygulandı; client write/update/delete/list kapalıdır. `brand-logos`, `avatars` ve `review-images` bilinçli olarak provision edilmedi.
- Merchant ürün yönetimi müşteri keşif ve ShopProduct modeliyle bütünleşmiş değil.

## Test Durumu

- `test/` altında 124 Dart test dosyası; QR, Realtime, Auth/RLS ve Wave 6 ürün yorumu için Development ref'ine kilitli gated live harness'lar bulunuyor.
- Güçlü alanlar: Shop, Auth, Personalization, Chat ve Cart.
- Açık doğrulama alanları: fiziksel cihaz/kamera kabulü, deferred Storage özellikleri, merchant ekranları, kupon backend'i, Production smoke, signed Production mobil callback opening ve full recovery PKCE kabulü.
- Auth/RLS, QR ve Realtime için Development ref'ine kilitli, açık opt-in gerektiren live harness'lar bulunuyor; normal `flutter test` remote istek yapmadan bunları skip ediyor.
- Wave 1 birleşik durumda tam Flutter test suite geçti; `flutter analyze --no-pub` sonucu temizdi. Hedefli sonuçlar: chat 97/97, notifications 53/53, cart/QR/purchases 138/138 ve settings/navigation 34/34.
- Wave 2 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: environment/config 11/11, discovery/shop 344/344, legacy mimari + unit 22/22 ve Cart V2/QR 94/94.
- Wave 3 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: canonical migration 13/13, QR release contract 3/3, banner 22/22, async-context 32/32, chat 97/97, notifications 53/53, cart/QR/purchases 157/157 ve discovery/navigation 412/412.
- Wave 3.1 hotfix ve Development bootstrap öncesi/sonrası canonical migration 14/14, QR concurrency contract 3/3 ve `flutter analyze --no-pub` geçti; gerçek PostgreSQL parse/apply 0004–0007 için başarılı oldu.
- Wave 4.1 Development `0008_fix_profile_role_guard` apply/postflight geçti; normal profile update başarılı, merchant/admin escalation `42501` ile reddedildi, final rol `customer` kaldı ve smoke sırasında `42883` görülmedi.
- Wave 4 final birleşik durumda hedefli matris 998/998 (4 gated live skip), tam Flutter suite 1069/1069 (3 gated live skip) ve `flutter analyze --no-pub` geçti; global `use_build_context_synchronously` etkin ve temiz kaldı.
- Wave 5 final birleşik durumda review/QR/shop rating/Storage contract/legacy architecture hedefli matrisi 169/169, tam Flutter suite 1069/1069 (3 güvenlik-gated live skip) ve `flutter analyze --no-pub` geçti; Agent 1 Development istemci smoke sonucu bağımsız olarak PASS.
- Wave 6 final birleşik durumda review RPC/client, cart/QR/purchases, Storage resolver/model ve canonical migration sözleşmesi hedefli matrisi 189/189; tam Flutter suite 1106/1106 (yaklaşık 4 opt-in live skip) ve `flutter analyze --no-pub` geçti. Ayrı Development live review harness'i 3/3 geçti.
- Wave 7 final birleşik durumda Auth/callback/config/platform/non-live integration hedefli matrisi 186/186, environment/platform/migration/Storage/review/Auth release-readiness matrisi 67/67; tam Flutter suite 1113/1113 (4 opt-in Development live skip) ve `flutter analyze --no-pub` geçti. Dönemin sentetik compile contract'ı workaround ile geçmişti; bu eski build engeli Wave 8'de kapatıldı.
- Wave 8 final birleşik durumda Iconsax/Auth/callback/config/platform/migration hedefli matrisi 56/56, cutover doküman/hash kontrolü 20/20, tam Flutter suite 1116/1116 (4 opt-in Development live skip) ve `flutter analyze --no-pub` geçti. Sentetik client-safe değerlerle `main_production.dart` standart Web release build'i ek icon workaround'u olmadan PASS; Production backend'e bağlanılmadı.
- Wave 9 final birleşik durumda migration/config/signing/platform/Auth hedefli matrisi 62/62, canonical LF migration manifesti 9/9 ve tam Flutter suite 1136/1136 (4 opt-in Development live skip) PASS. Standart Web Production ve Android production-release compile-only contract, Android development debug build ve analyzer PASS; Android release packaging eksik signing materyalinde beklenen fail-closed sonucu verdi.
- Wave 10 pre-migration belge entegrasyonunda canonical Git/LF migration manifesti 9/9 ve canonical migration contract testi 18/18 PASS. Agent teslimindeki local safe-equivalent clean-room replay 9/9 PASS olarak korundu; yalnız doküman değiştiği için full Flutter suite ve analyzer yeniden çalıştırılmadı.
- Wave 10 D0 entegrasyonunda linked CLI dry-run yalnız exact canonical `0001→0009` pending sırasını gösterdi; remote before/after state aynı ve write `0`. Integration canonical migration contract testi 18/18, manifest 9/9, docs/diff/security kontrolleri PASS; yalnız doküman değiştiği için full Flutter suite ve analyzer yeniden çalıştırılmadı.
- Wave 10 D1'de Production canonical `0001→0009` official linked CLI ile uygulandı. Final remote metadata postflight ledger 9/9, table/RLS 23/23, policy 52/52, app function 28/28, trigger 25/25, critical RPC 15/15 ve exact Storage/Realtime contract PASS; Auth ve business data `0`. Local canonical/review-Storage contract matrisi 28/28, QR release contract 3/3, PGlite SQL behavioral replay 9/9 ve migration manifesti 9/9 PASS.
- Wave 10 Phase E2'de final mobile identity/signing/Auth callback hedefli matrisi
  35/35, tam Flutter suite 1138/1138 (4 opt-in Development live skip), Android
  development debug build, production release compile-only contract, eksik signing
  materyalinde release fail-closed kontrolü ve analyzer PASS. iOS 3+3 bundle-ID
  configuration/plist/scheme statik doğrulaması PASS; Windows'ta signed archive
  çalıştırılmadı.
- Wave 10 Phase E final birleşik durumda config/Auth/platform/harness hedefli matrisi
  61 PASS (1 Production live güvenli skip), tam Flutter suite 1142 PASS (5 opt-in
  live skip) ve analyzer temizdir. Gerçek Production Web runtime build, Android
  Development debug ve Production release compile-only PASS; Production packaging
  eksik signing materyalinde beklenen fail-closed sonucu verdi ve artifact üretmedi.
- Wave 10 Phase F1 Agent 1 task branch'inde callback/email/platform hedefli matris
  40/40, tam Flutter suite 1154 PASS (5 explicit opt-in live skip), analyzer temiz,
  Android Development debug APK ve Production release compile-only PASS. Production
  ve Development merged manifest callback/package ayrımı exact doğrulandı; iOS
  Windows ortamında statik doğrulandı, signed archive üretilmedi.
- Wave 10 Phase F intermediate integration'da Auth callback/PKCE/signup-resend-
  recovery/platform/preflight hedefli matrisi 118/118, tam Flutter suite 1154 PASS
  (5 explicit opt-in live skip), sentetik Production config contract preflight,
  analyzer, docs/diff ve security/secret scan PASS geçti. Integration remote backend
  erişimi, e-posta gönderimi veya signed artifact üretmedi.
- Wave 10 Phase F3'te exact Production identity, Custom SMTP, Confirm Email, final
  remote Site URL ve final+legacy callback allowlist salt-okunur PASS oldu. Auth Users
  baseline'ı refresh sonrasında beklenen `0` yerine `10 (estimated)` gösterdiği için
  signup öncesi safety gate FAIL oldu; Production write/e-posta/user/fixture `0` kaldı.
  Callback/Auth/preflight/profile hedefli yerel matris 129 PASS, 1 gated Development
  live test skip; docs/diff ve secret scan PASS oldu.
- Wave 10 Phase F3A `2026-08-17 00:59:49 UTC` exact salt-okunur SQL snapshot'ı
  Auth user/identity/session `0/0/0`, profiles/consents `0/0`, user-linked business
  relation'ları `0` ve ledger 9/9 doğruladı. D1 zero-state current state ile
  tutarlıdır; Dashboard estimated user göstergesi actual count değildir. Production
  write/user/email `0`, Development erişimi `0` kaldı.
- Wave 10 Phase F3B/F3D'de tek disposable customer için gerçek SMTP inbox teslimatı,
  gözlenen sender adı/domain, server-side confirmation ve final callback email URL
  contract'ı PASS oldu. Confirmation e-postası Spam klasörüne düştü. Actual mobile app
  opening ve full recovery PKCE lifecycle BLOCKED kaldı. Fresh F3D gate exact tek
  fixture'ı doğruladı; owner-authorized Supabase Dashboard Auth Admin delete sonrasında
  Auth user/identity/session/profile/consent, bütün linked business residual ve Storage
  object count'ları `0/0/0/0/0/0/0` oldu. Başka user veya Production write yoktu;
  Auth config/schema/migration ve Development değiştirilmedi. Account-deletion,
  Auth/profile ve canonical RLS contract hedefli matrisi 90 PASS; Development live RLS
  harness'i opt-in kapalı olduğu için beklenen 1 skip verdi.
- Wave 10 Phase F final integration'da callback/PKCE/signup-recovery/account-deletion/
  profile/canonical RLS hedefli yerel matris 151/151, docs consistency, diff ve
  secret/PII scan PASS. Kod değişmediği için full Flutter suite ve analyzer formalite
  amacıyla yeniden çalıştırılmadı; Development live harness'i çağrılmadı ve remote
  erişim yapılmadı.
- Wave 11 Phase A'da hedefli signing/callback/config/Auth matrisi 67/67, tam Flutter
  suite 1154 PASS (5 opt-in live skip) ve `flutter analyze --no-pub` PASS. Standard
  Production APK/AAB release build'i gerçek client-safe runtime injection ile ek icon
  workaround'u olmadan PASS; package `com.esnaftavar.app`, version `1.0.0+1`, signer
  certificate ve artifact hash'leri doğrulandı. Secret scan server-only/signing secret
  bulmadı. Bağlı Android cihazı olmadığından fiziksel install/startup çalıştırılmadı.
- Wave 11 Phase A final integration'da identity/signing/callback/preflight/Auth
  hedefli matrisi 62/62, tam Flutter suite 1154 PASS (5 opt-in live skip) ve
  `flutter analyze --no-pub` PASS. Diff, conflict marker, private-key/secret ve
  tracked keystore/key.properties/APK/AAB scan'leri temizdir; remote harness
  çağrılmadı.
- Wave 11 Phase B2 task branch'inde açık yüzeylerdeki müşteri input'ları için koyu
  sistem temasından bağımsız yerel değer/cursor/selection teması; confirmation callback
  sonrası Auth/profile refresh, tekil feedback ve güvenli route replacement; Geolocator
  servis/izin/request/denied-forever/settings-resume/last-known akışı doğrulandı.
  Hedefli matris 88/88, kayıtlı konum regresyonu 13/13, tam Flutter suite 1177 PASS
  (5 opt-in live skip), analyzer ve Development debug Android build PASS. Production ve
  Development remote yazması, Auth user/e-posta oluşturma yoktur. Sonraki B2R turunda
  POCO X7 Pro / Android 16 cihaz algılama, signed Production APK rebuild, data koruyan
  normal upgrade ve startup PASS oldu. Home arama input'unda değer/hint/cursor fiziksel
  görünürlüğü; Android runtime location dialog'u, izin sonrası location access ve
  product-owner'ın konum sonucu/hata yok gözlemi PASS. Login/signup oturum korunarak
  açılmadı; parola maskelemesi otomatik testle PASS. Confirmation UI için yeni Auth/
  e-posta fixture üretilmediğinden fiziksel kabul BLOCKED kaldı.
- Açık `TODO`, `FIXME` veya `UnimplementedError` işareti bulunmadı; boş callback ve statik ekran gibi örtük skeleton'lar mevcut.

## Hot-Spot / Shared Alanlar

- `lib/core/dependency_injection/service_locator.dart`: bütün repository/use-case/Cubit kayıtları.
- `lib/t_store.dart`: bootstrap, global provider'lar, session listener ve navigator key.
- `lib/core/common/widgets/navigation_menu.dart`, navigation Cubit ve bottom navigation: beş sekme, guest guard, cart ve unread badge.
- `lib/features/personalization/presentation/views/settings_view.dart`: chat, purchases, coupons, ratings, notifications, locations, profile ve privacy hub'ı.
- Shop repository/entity/model alanları: discovery, nearby, merchant, cart ve ShopProduct bağımlılıkları.
- `supabase_tables.dart`, `supabase_schema.sql` ve bütün migration SQL'leri.
- `customer_home_v1_tokens.dart`, theme dosyaları, `pubspec.yaml` ve lockfile.
- Büyük Shop/Cart/Chat view dosyaları aynı dosyada paralel çalışma için yüksek conflict riski taşır.

## Canlı Backend ile Kalan Doğrulamalar

- Development canonical bootstrap `0001`–`0009` tamamlandı; `20260815000900 0009_verified_product_reviews_storage` remote migration kaydı ve doğru Development project ref'i doğrulandı. Önceki postflight 23 tablo, 23/23 RLS, 55 policy, canonical grant matrisi ve Realtime üyeliğini doğrulamıştı.
- Production Phase A inventory, D0 linked dry-run, D1 canonical migration apply/metadata postflight, Phase E client wiring ve Phase F final callback integration + Auth/SMTP/template precheck tamamlandı. Exact ref'te ledger 9/9, 23/23 table/RLS ve final policy/RPC/trigger/Storage/Realtime contract doğrulandı. Phase F3B gerçek SMTP teslimatı, server-side confirmation ve final callback email URL contract'ı PASS; F3D cleanup sonrası Auth/business/Storage zero baseline restore PASS. Wave 11 Android upload signing ve ilk signed APK/AAB PASS. B6 physical Android confirmation notice ve authoritative full recovery lifecycle PASS; B6 canonical self-delete sonrasında zero-test residual yeniden sağlandı. B7 legacy Production callback removal PASS ve allowlist artık yalnız final callback'i içerir. Wave 13 Phase B korunmuş signed APK fiziksel customer startup/demo/location smoke'u PASS. Merchant-owned scanner/kamera ve iki-cihaz QR, Play Console/Play App Signing ve iOS signing ayrı gate'lerdir.
- Production-like e-posta doğrulama/SMTP kabulü, Development'taki Confirm Email kapalı live testlerinden ayrı tutulur.
- Development Auth remote config bu entegrasyonda değiştirilmedi: Confirm Email OFF, Custom SMTP OFF, gerçek SMTP credential yok ve Site URL/redirect allowlist production-like değil. Production F3B kanıtı Development'a genellenmez.
- QR doğrulamasının iki gerçek hesap ve iki fiziksel cihazla kamera dahil uçtan uca davranışı.
- Gerçek client-safe Development Dart-define değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure smoke PASS; Production smoke yalnız güvenli Production değerleri sağlandığında ayrıca yapılır.
- Aktif üç public-read Storage bucket uygulandı; `brand-logos`, `avatars` ve `review-images` ürün özelliği ve sözleşmeleri deferred kalır.
- Wave 6 Development review lifecycle fixture'ları tamamen temizlendi; review, verified transaction/item, listing, shop, product ve Auth test hesaplarında residual değer `0` doğrulandı.

## Son Geliştirme Odağı

- 2026-08-23: **WAVE 13 PHASE B FINAL INTEGRATION PASS / PHYSICAL ANDROID RELEASE ACCEPTANCE PASS / FUNCTIONAL BLOCKERS NONE** — Agent 1'in `920b95e` fiziksel kabul kanıtı exact `22c78c6` tabanına `6c15e02` ile `--no-ff` ve çatışmasız entegre edildi. Exact korunmuş SHA-256 APK yeniden build edilmeden POCO X7 Pro / Android 16 (API 36) fiziksel cihazında doğrulandı; uninstall/clear-data olmadan `adb install -r` Success verdi. Hash, APK v2/tek signer, `com.esnaftavar.app`, `EsnaftaVar`, `1.0.0 (1)`, non-debuggable, foreground process ve crash/config logu PASS. Gerçek Production Home/kategori/ProductDetails/multiple seller-price/shop/`Defter` search/Yakındakiler/navigation ile fiziksel konum izni/acquisition PASS; `57 mağaza` yakınlığa göre sıralandı. Agent turu yalnız customer read yaptı; write/Auth/business/Storage fixture/Development/rebuild `0`. Integration remote read/write yapmadı; hedefli `143` PASS (`2` gated live skip), tam suite `1213` PASS (`6` gated live skip), analyzer/diff/security temizdir. B6 confirmation/recovery PASS durumu korunur. Scanner merchant principal gerektirdiğinden çalıştırılmadı ve fail değildir; merchant/two-device QR ayrı OPEN gate'tir. Kozmetik UI final UI kit'e ertelendi.
- 2026-08-23: **WAVE 13 PHASE A FINAL INTEGRATION PASS / SIGNED ANDROID ARTIFACTS PRESERVED / ANDROID SIGNING RELEASE GATE PASS** — Agent 2'nin `d966f55` gerçek Android release signing kanıtı exact `305dd74` tabanına `52f1e98` ile `--no-ff` ve çatışmasız entegre edildi. Final `com.esnaftavar.app` / `1.0.0 (1)` APK ve AAB repo/Git dışında `C:\Users\Mustafa\EsnaftavarReleases\1.0.0` altında korunur; SHA-256 değerleri sırasıyla `47650AB049F8212DB05EEFE382689B8EB3321C1799AAE8C797C125D63CA534DA` ve `0621845CF387CB8C6CE69E04A0F991DF8EB95DC864DAD2EA0D8B0E6FD9DE54F9` olarak yeniden doğrulandı. APK v2/tek signer ve AAB `jar verified`, canonical upload certificate fingerprint'i, final callback, non-debuggable ve forbidden identity/secret taraması PASS. Integration artifact rebuild, signing credential erişimi veya Production/Development remote işlem yapmadı. Hedefli matris `50/50`, tam suite `1213` PASS (`6` opt-in live skip), analyzer/diff/security temizdir. Phase A sonrasında açık olan fiziksel customer/location acceptance Phase B'de PASS; Auth confirmation/recovery zaten B6 PASS'tir. İki-cihaz QR, Play Console, ikinci offline keystore yedeği, iOS signing/archive ve commercial GO açıktır.
- 2026-08-22: **WAVE 12 PHASE D FINAL INTEGRATION PASS / PRODUCTION DEMO FUNCTIONAL SMOKE PASS** — Agent 1'in `8c869e5` functional smoke/harness teslimi exact `609e555` tabanına `42774fe` ile `--no-ff` ve çatışmasız entegre edildi. Gerçek Production Web release istemcisi ve explicit opt-in anonymous read harness canonical `mefhfvrgkwciubeajjeb` ref'inde Startup/Home, dört kategorinin her birinde beş doğru ürün, ProductDetails, 20/20 üründe 14–15 seller ve multiple price, representative seller→shop→beş listing, exact/generic/category/no-result search, 57-shop nearby, anonymous wishlist/cart/profile login gate ve customer back stack'i PASS doğruladı. Authoritative remote read `4/20/57/285`, 57 null-owner demo shop ve 57 valid/unique coordinate gösterdi; runtime functional bug/release blocker bulunmadı. Stale empty-catalog harness current demo baseline'ına güncellendi ve full manifest/relationship/search/nearby read harness'ı eklendi. Integration remote define veya credential kullanmadı; Production/Development read/write, seed/cleanup, fixture, Auth/Storage/config/migration işlemi yapmadı. Yerel hedefli matris `552` PASS (`2` Production live skip), tam suite `1213` PASS (`6` live skip), analyzer/diff/security temizdir. Kozmetik UI product-owner kararıyla `DEFERRED UNTIL FINAL UI KIT`; merchant/QR/verified purchase null owner nedeniyle intentional unavailable'dır. Sonraki release kapısına hazırdır.
- 2026-08-22: **WAVE 12 PHASE C FINAL INTEGRATION PASS / PRODUCTION DEMO DATASET LIVE** — Agent 1'in `26defb1` Production seed/postflight kanıtı exact `580552f` tabanına `fad75a7` ile `--no-ff` ve çatışmasız entegre edildi. Exact Production ref ve Development dışlama, single-writer, fresh zero business baseline, collision `0/366`, natural-key collision `0`, artifact integrity ve clean-room kapıları PASS sonrasında tracked `esenler_demo_v1.sql` Agent 1 turunda tek transaction olarak bir kez uygulanmıştı. Authoritative postflight categories/products/shops/shop_products `4/20/57/285`, active/featured products `20/20`, active shops `57`, deterministic manifest `366/366`, mismatch ve unexpected row `0` doğruladı. Product marker `20`, `[DEMO]` shop/owner-null `57/57`, listing marker `285`; 57 coordinate valid/unique ve 19 mahallenin her birinde üç shop vardır. Gerçek `anon` RLS rolü aynı katalog sayılarını, ürün başına 14–15 seller ve multiple price sonucunu PASS okudu. Auth user/profile/merchant ve Storage object `0`; demo shops owner-less olduğundan discovery/shop/seller comparison PASS, merchant ownership/QR/verified transaction intentional unavailable'dır. Integration remote read/write yapmadı; seed yeniden uygulanmadı, cleanup çalıştırılmadı ve Development'a dokunulmadı. Generator check, hedefli matris `284/284`, tam suite `1210` PASS (`5` opt-in live skip) ve analyzer temizdir. Broader fiziksel/mobile visual smoke ayrı açık kabul adımıdır.
- 2026-08-22: **WAVE 12 PHASE B INTEGRATION PASS / PRODUCTION DEMO SEED SAFETY REVIEW INTEGRATED / SEED NOT APPLIED** — Agent 1'in `0383782` read-only safety review teslimi exact `edc0999` tabanına `f53e584` ile `--no-ff` ve çatışmasız entegre edildi. Agent evidence canonical Production `mefhfvrgkwciubeajjeb` üzerinde categories/products/shops/shop_products `0/0/0/0`, Auth/profile/business-linked `0`, üç canonical Storage bucket ve object `0`; UUID collision `0/366`, natural-key collision `0` ve exact existing demo row `0` gösterir. Seed yalnız controlled single-writer apply için deterministic, transactional ve fail-closed PASS; cleanup yalnız fresh pre-launch zero-activity state için PASS. `owner_user_id = NULL` customer discovery/shop/seller comparison'ı destekler fakat merchant QR confirmation ve verified transaction üretmez; bu intentional sınır korunur. Local generator ve migration/demo matrisi 37/37, PGlite replay iki kez `4/20/57/285`, cleanup sıfır ve 23 table, tam suite 1210 PASS (5 opt-in live skip), analyzer/diff/security temizdir. Integration remote read/write yapmadı; owner seed authorization henüz verilmedi. User activity sonrasında blind cleanup önerilmez ve gerekirse soft-retire/deactivate ayrı owner kararıdır.
- 2026-08-22: **WAVE 12 PHASE A INTEGRATION PASS / ESENLER DEMO DATASET ARTIFACT READY / REMOTE NOT APPLIED** — Agent 3'ün `0edb615` teslimi exact `4232a6e` tabanına `6394f8f` ile `--no-ff` ve çatışmasız entegre edildi. Fixed namespace UUIDv5/SHA-1 manifest, `[DEMO]` mağaza kimliği, product JSONB marker, deterministic fiyat varyasyonları, 57 unique `NEIGHBORHOOD_CENTER` koordinatı, fail-closed seed ve exact-ID cleanup sözleşmesi doğrulandı. Şehitler ve Yeşil Vadi için ayrı current polygon bulunmaması limitation olarak korundu. Dedicated local PGlite temiz-oda replay'i canonical migration 9/9, iki kez aynı `4/20/57/285`, representative read, seller comparison ve cleanup sonrası `0/0/0/0` + 23 public table PASS verdi. Windows fresh-checkout'ta generator byte-equivalence korunsun diye üç generated artifact LF'e sabitlendi. Dataset contract 16/16, ilgili migration/shop/model/nearby/Home matrisi 268/268, tam suite 1210 PASS (5 opt-in live skip) ve analyzer temizdir. Production/Development remote erişimi, seed/cleanup apply, Auth/merchant hesabı veya migration yapılmadı; Phase B ayrı safety review ve açık owner yetkisi gerektirir.
- 2026-08-22: **WAVE 11 PHASE B7 FINAL INTEGRATION PASS / FINAL PRODUCTION CALLBACK ONLY** — Agent 1'in `11c3ab6` teslimi exact `21f7224` tabanına `2e62bb4` ile `--no-ff` ve çatışmasız entegre edildi. Exact Production `mefhfvrgkwciubeajjeb` fresh pre-write gate'i Site URL `com.esnaftavar.app://login-callback/`, final+legacy iki exact allowlist kaydı, Custom SMTP ON ve Confirm Email ON durumunu doğruladı. Product owner'ın action-time onayıyla Agent 1 Supabase Dashboard URL Configuration üzerinden yalnız `io.supabase.tstore://login-callback/` kaydını kaldırdı. Fresh postflight allowlist'in yalnız final callback'i içerdiğini, Site URL'nin değişmediğini, Custom SMTP ve Confirm Email'in açık kaldığını doğruladı. Development `tnipyxnvhgelwdpykyez` remote'a erişilmedi; Development kaynak callback'i değişmedi. Integration remote sonucu tekrar okumadı/değiştirmedi; user/e-posta, database/schema/migration, Storage veya Auth config işlemi yapmadı. Hedefli callback/platform/environment/PKCE/release-config matrisi 45/45, diff ve security/PII kontrolleri PASS'tir. Esenler demo dataset ayrı yetkili göreve hazırdır; commercial release GO değildir.
- 2026-08-22: **WAVE 11 PHASE B6 FINAL INTEGRATION PASS / PHYSICAL MOBILE AUTH PASS / ZERO TEST RESIDUAL** — Agent 1'in `af1708c` teslimi exact `31f4ac1` tabanına `d3b9cac` ile `--no-ff` ve çatışmasız entegre edildi. POCO X7 Pro / Android 16 üzerindeki final confirmation callback ve destination notice, canonical five-step recovery, aynı yeni credential ile fresh/normal login, same-user identity ve customer role güvenliği PASS olarak korundu. B6 disposable fixture canonical `delete_current_customer_account` ile temizlendi; Auth/identity/session/profile/consent/business/Storage residual exact `0`. Integration remote backend'e erişmedi/yazmadı ve Development'a dokunmadı. Hedefli Auth/account-deletion matrisi 266/266, tam Flutter suite 1194/1194 (5 explicit opt-in live skip), analyzer, diff ve security/PII kontrolleri PASS. Legacy callback remote allowlist'te korunur ve ayrı yetkili removal görevine hazırdır; commercial release hâlâ hazır değildir.
- 2026-08-22: **WAVE 11 PHASE B4 AUTH ROOT-CAUSE INTEGRATION / FIX IMPLEMENTATION READY** — Agent 2'nin `f545ab4` canonical analiz belgesi `0df5c99` ile exact `cd3e141` tabanına `--no-ff` ve çatışmasız entegre edildi. Confirmation feedback root cause FOUND: callback/session/profile/Home yolu çalışıyor; geçici Snackbar route transition tamamlanmadan tüketiliyor ve destination-owned durable one-shot state yok. Recovery false-success root cause FOUND: no-exception `updateUser` response/provenance/fresh login doğrulanmadan final success üretiyor. Actual Production password persistence root cause NOT_FOUND ve password-specific audit UNKNOWN kaldı. Beş adımlı authoritative recovery success criterion ve regression test boşlukları canonicalleştirildi. Yerel Auth matrisi 199/199 ve Auth redirect wiring contract 4/4 PASS; Integration Production/Development remote işlemi yapmadı ve zero-test baseline korundu.
- 2026-08-22: **WAVE 11 PHASE B6 FINAL PHYSICAL AUTH ACCEPTANCE PASS / ZERO TEST RESIDUAL** — Exact zero baseline sonrasında POCO X7 Pro / Android 16 üzerinde yalnız bir disposable Production customer oluşturuldu. Confirmation e-postası Inbox'a doğru sender/domain ile ulaştı; final callback uygulamayı açtı ve kalıcı başarı notice'ı fiziksel olarak görüldü. Tek recovery callback'i update-password UI'ını açtı; B5'in provenance, expected-user update, local cleanup, aynı credential fresh login ve same-identity zinciri tamamlandı. Final başarı UI'ı ve aynı yeni parola ile normal login fiziksel PASS oldu. Rol `customer`, merchant/admin `0` kaldı. Canonical `delete_current_customer_account` self-delete sonrasında Auth/identity/session/profile/consent, bütün user-linked business ve Storage exact sıfıra döndü. Development/Auth config/SMTP/schema/migration değişmedi; legacy callback yalnız ayrı yetkili cleanup görevine hazırdır.
- 2026-08-22: **WAVE 11 PHASE B5 AUTH CONFIRMATION/RECOVERY FINAL INTEGRATION PASS / PHYSICAL RETEST READY** — Agent 2'nin `793f0dc` teslimi `5461d77` ile exact `bb3e7e5` tabanına `--no-ff` ve çatışmasız entegre edildi. Confirmation sonucu Home/Login destination route tamamlandıktan sonra destination-owned, dismiss edilene kadar kalıcı ve sequence-deduped notice olarak gösterilir. Recovery final başarı valid provenance/session + expected-user update response + local session cleanup + aynı opaque credential ile fresh normal login + same-user identity zincirinin tamamına bağlandı. No-exception/HTTP success tek başına başarı değildir; typed terminal failures invalid-link ekranına gider ve kontrollü Auth event'leri navigation/customer-data yarışından izole edilir. Stateful password-store fake false-success, same-password parity, cleanup ve identity mismatch regression'larını doğrular. Hedefli Auth matrisi 215/215, tam suite 1194/1194 (5 explicit opt-in live skip) ve analyzer PASS. Integration Production/Development remote işlem yapmadı; actual Production password persistence nedeni NOT_FOUND kalır ve son fiziksel confirmation/recovery retest'i açıktır.
- 2026-08-22: **WAVE 11 B3R EVIDENCE + CLEANUP INTEGRATION PASS / TWO V1.0 AUTH BUGS OPEN** — Agent 1'in `0f94596` final HEAD'i `59acbec` ile exact `76acad4` tabanına `--no-ff` ve çatışmasız entegre edildi. Physical confirmation final callback, server confirmation, authenticated session/Home ve customer role/profile PASS; confirmation success feedback FAIL. Recovery email/final callback/update UI PASS; HTTP `200` gerçek password-hash değişimi sayılmadı ve yeni credential iki fresh login'de `invalid_credentials` ile reddedildi. Bu iki sonuç explicit V1.0 Auth bug'ı olarak açık. Owner-authorized B3R Auth Admin cleanup sonrası Auth/business/Storage residual exact `0`; legacy callback korundu. Integration Auth matrisi 67/67, tam suite 1182 PASS (5 live skip) ve analyzer PASS; Production/Development remote işlemi yapmadı.
- 2026-08-22: **WAVE 11 PHASE B3R AUTHORIZED FIXTURE CLEANUP PASS / ZERO TEST BASELINE RESTORED** — Fresh authoritative Production gate exact tek masked B3R disposable customer'ı doğruladı: Auth user/identity/session/profile/legal consent `1/1/0/1/2`, customer role `1`, merchant/admin `0`; bütün user-linked business tabloları ve Storage objects `0`. Authenticated session bulunmadığından canonical self-delete kullanılamadı. Product owner'ın exact fixture yetkisi ve ayrı action-time onayıyla Supabase Dashboard Auth Admin delete uygulandı. Post-delete authoritative state Auth user/identity/session/profile/legal consent, bütün business tabloları ve Storage objects için exact `0` oldu. Başka kullanıcı/veri etkilenmedi; yeni signup/recovery/email/login, Auth config, schema, migration, SMTP, Storage veya Development write yapılmadı. B3R recovery final login ve confirmation success feedback açık kalır; cleanup bu iki kabulü PASS yapmaz.
- 2026-08-20: **WAVE 11 PHASE B3R PHYSICAL CONFIRMATION CALLBACK PASS / PASSWORD RECOVERY FINAL LOGIN FAIL / CLEANUP BLOCKED** — POCO X7 Pro / Android 16 üzerinde exact bir disposable Production customer normal signup ile oluşturuldu; waiting UI, Inbox sender/domain, final callback app opening, server confirmation, authenticated Home, profile ve default customer role PASS oldu. Canonical confirmation başarı mesajı Home'da gözlenmedi; route-lifecycle yarışı destination-first mesajlama ile düzeltildi ancak ikinci signup yapılmadığından fiziksel tekrar kabulü BLOCKED kaldı. Tek recovery e-postası final callback ile update-password ekranını açtı; HTTP `200` / `user_modified` gözlendi fakat yeni credential login başarısız olduğu için gerçek parola değişimi kanıtlanmış sayılmaz. Eski credential beklendiği gibi, yeni credential ise beklenmedik biçimde `invalid_credentials` ile reddedildi. Login/signup/recovery parola alanlarında opaque değer korunumu ve klavye rewrite koruması eklendi; buna rağmen patched signed APK'daki yeni login denemeleri de authoritative Auth tarafından reddedildi. Görev sınırı gereği ikinci recovery, admin delete veya yeni kullanıcı oluşturulmadı. Canonical self-delete çalıştırılamadı; exact B3R fixture ve ilişkili profil/consent satırları owner-onaylı sonraki cleanup'a kaldı. Production Auth/config/schema/Storage ve Development değişmedi.
- 2026-08-20: **WAVE 11 PHASE B3A AUTHORIZED PHYSICAL-TEST FIXTURE CLEANUP PASS / ZERO TEST BASELINE RESTORED** — Fresh exact Production gate yalnız masked fiziksel-test customer fixture'ını doğruladı: Auth user/identity/profile `1/1/1`, session `2`, customer role `1`, merchant/admin `0`, legal consent `2`, saved location `1`; diğer user-linked business ve Storage satırları `0`. Product owner'ın exact fixture yetkisiyle uygulamadaki canonical `delete_current_customer_account` self-delete akışı kullanıldı. Authoritative post-delete state Auth user/identity/session/profile/legal consent/saved location, diğer user-linked business ve Storage için tamamen `0` oldu; saved location cascade ile temizlendi ve ek hedefli delete gerekmedi. Yeni signup/e-posta/recovery, Auth config, migration, schema, Storage veya Development işlemi yapılmadı. B3 mobile confirmation/recovery kabulü yeniden başlatılabilir; henüz PASS ilan edilmedi.
- 2026-08-19: **WAVE 11 PHASE B2R PHYSICAL INPUT/LOCATION PASS / CONFIRMATION UI PHYSICAL BLOCKED** — POCO X7 Pro / Android 16 hem ADB hem Flutter ile fiziksel cihaz olarak doğrulandı. Current main'den canonical repo-dışı keystore ve client-safe Production runtime config ile signed APK üretildi; signature, `com.esnaftavar.app`, final callback ve artifact secret scan PASS. Geçici signing/runtime dosyaları silindi, kalıcı keystore korundu. Mevcut uygulamaya uninstall/clear-data olmadan upgrade yapıldı; startup/process ve crash kontrolü PASS. Home arama input'unda değer/hint/cursor görünürlük checklist'i product-owner tarafından PASS edildi. Konum dialog'u açıldı, izin verildi; sistem servisi, permission, location access ve crash-free process ADB'de, başarı sonucu/hata yok durumu product-owner tarafından doğrulandı. Hedefli paket 114 PASS, tam suite 1177 PASS (5 opt-in live skip), analyzer PASS. Yeni signup/e-posta/confirmation veya remote backend write yapılmadı; confirmation UI fiziksel kabulü bu nedenle BLOCKED.
- 2026-08-19: **WAVE 11 PHASE B2 INPUT/AUTH CALLBACK/LOCATION AUTOMATED FIX PASS / PHYSICAL REGRESSION BLOCKED** — Açık müşteri form yüzeylerinde değer/hint/error/cursor/selection görünürlüğü merkezi yerel theme ile sabitlendi. Confirmation callback Auth/profile state'ini yeniden değerlendirir, waiting route'u kapatır, session durumuna göre shell/login hedefini seçer ve tek başarı mesajı gösterir; malformed/duplicate ve environment isolation korunur. Konum akışı cihaz servisi → runtime permission request → current/last-known position sırasına, denied-forever settings aksiyonuna ve resume refresh'e bağlandı. Remote backend yazması, signup veya e-posta yoktur. ADB cihazı olmadığından signed Production rebuild/install ve POCO X7 Pro fiziksel doğrulama yapılmadı.
- 2026-08-18: **WAVE 11 PHASE A FINAL INTEGRATION / ANDROID SIGNING READY / FIRST SIGNED APK+AAB PASS / PHYSICAL ACCEPTANCE OPEN** — Agent 1 `b56b9fe` teslimi `18f7e03` ile `--no-ff` ve çatışmasız entegre edildi. Repo-dışı kalıcı RSA-4096 upload key ve `esnaftavar-upload` alias'ıyla `com.esnaftavar.app` / `EsnaftaVar` / `1.0.0+1` signed Production APK ve AAB üretildi. APK signer v2, AAB signature, package/manifest/final callback, artifact hash ve secret scan PASS; legacy callback ve server-only/signing secret yok. Geçici credential/config dosyaları silindi; keystore, `key.properties` ve APK/AAB Git dışında kaldı. Owner birincil keystore yedeği ile parola yöneticisi kaydını tamamladı; ikinci offline yedek öneri/açık olarak korunur. Fiziksel Android install/startup/callback acceptance, Play Console/Play App Signing, iOS signing ve commercial GO açıktır. Integration Production/Development remote erişimi veya write yapmadı.
- 2026-08-18: **WAVE 10 PHASE F FINAL INTEGRATION / EMAIL INFRASTRUCTURE READY / ZERO TEST RESIDUAL** — Agent 1 final F3/F3A/F3B/F3D evidence HEAD'i `--no-ff` ve çatışmasız entegre edildi. Gerçek inbox teslimatı, server-side confirmation, final callback email contract'ı ve customer role/profile davranışı PASS; authorized disposable fixture cleanup sonrası Auth user/identity/session/profile/consent, linked business ve Storage residual exact `0`. Spam teslimatı Auth failure değildir ve deliverability tuning açık follow-up'tır. Actual mobile app opening, full recovery lifecycle, legacy callback removal, signing ve broader Production smoke açık kalır. Integration remote backend işlemi yapmadı.
- 2026-08-18: **WAVE 10 PHASE F3D AUTHORIZED ADMIN CLEANUP PASS / ZERO AUTH BASELINE RESTORED** — Fresh exact gate yalnız masked F3 disposable customer'ı doğruladı: Auth user/identity/profile `1/1/1`, customer `1`, merchant/admin `0`, legal consent `2`, session `2`, linked business ve Storage `0`. Owner'ın exact-account yetkisiyle Supabase Dashboard Auth Admin delete uygulandı. Authoritative post-delete state Auth user/identity/session/profile/consent/business/Storage `0/0/0/0/0/0/0`; başka user/veri yok. F3D'de email/config/schema/migration/Storage/Development write yapılmadı.
- 2026-08-18: **WAVE 10 PHASE F3B REAL SMTP + SERVER CONFIRMATION PASS / MOBILE LIFECYCLE BLOCKED** — Tek disposable normal-client customer için confirmation e-postası gerçek inbox'a ulaştı (Spam); sender adı/domain beklenen contract ile uyumluydu. Link server-side confirmation'ı tamamladı ve final callback URL contract'ını taşıdı. Windows'ta Production mobile scheme handler bulunmadığı için actual app opening; kullanılmayan recovery linki nedeniyle full mobile PKCE recovery BLOCKED kaldı. Bu durum Auth delivery/confirmation failure değildir.
- 2026-08-17: **WAVE 10 PHASE F3A AUTH BASELINE EXPLAINED / LIVE EMAIL CAN RESUME** — Authoritative salt-okunur SQL `auth.users/identities/sessions = 0/0/0`, profiles/consents ve tüm user-linked business relation'ları `0` doğruladı. D1 zero-state current state ile tutarlı; Dashboard `10 users (estimated)` actual relation count değildi. User inventory boştur, cleanup adayı yoktur. Production/Development write, user mutation veya e-posta gönderimi yapılmadı.
- 2026-08-17: **WAVE 10 PHASE F3 PRE-WRITE GATE BLOCKED / NO PRODUCTION WRITE — F3A İLE ÇÖZÜLDÜ** — Exact Production name/ref, Development exclusion, Custom SMTP, Confirm Email, final Site URL ve final+legacy allowlist salt-okunur PASS oldu. Auth Users ekranı refresh sonrasında beklenen `0` yerine `10 users (estimated)` gösterdiği için güvenli stop uygulandı; disposable signup, inbox gönderimi, resend, recovery veya cleanup başlatılmadı. Sonraki F3A exact SQL bu UI sinyalinin gerçek user count olmadığını doğruladı.
- 2026-08-17: **WAVE 10 PHASE F INTERMEDIATE INTEGRATION / CALLBACK INTEGRATED / LIVE EMAIL NOT READY** — Agent 1 final callback cutover ve Agent 2 Production Auth/SMTP read-only precheck branch'leri zorunlu sırayla `--no-ff` entegre edildi; tek doküman çakışması final callback kaynak gerçeği ile SMTP precheck FAIL sonucunu birlikte koruyacak şekilde çözüldü. Production signup/resend/recovery ve PKCE final callback'e bağlı, Development legacy callback'i izoledir. Custom SMTP ve email template precheck kanıtı mevcut; Site URL localhost, HTTPS web recovery, gerçek inbox kabulü, legacy allowlist removal ve signing açık kaldı. Integration sırasında Production/Development remote erişimi veya write yapılmadı.
- 2026-08-17: **WAVE 10 PHASE F1 FINAL AUTH CALLBACK SOURCE CUTOVER PASS / INTEGRATION REQUIRED** — Production callback `com.esnaftavar.app://login-callback/` istemci, Android production flavor, iOS Profile/Release ve release preflight'ta tek merkezi environment sözleşmesine bağlandı. Development mevcut legacy callback'ini ayrı ve fallback'siz korur. Signup, resend, recovery ve mevcut OAuth redirect'leri explicit; broad Supabase URI detector kapalı ve PKCE exact scheme/host/path/code filtresinden sonra exchange edilir. Remote Production/Development Auth yazması yapılmadı. Integration ve signed-artifact kabulü sonrasında legacy Production allowlist kaydı yetkili owner tarafından kaldırılmalıdır.
- 2026-08-16: **WAVE 10 PHASE E CLIENT + FINAL MOBILE IDENTITY WIRED / PHASE F READY / COMMERCIAL RELEASE NOT READY** — Agent 1 gerçek Production runtime config, anonymous read-only empty-state bağlantısı ve transient Web release build kanıtını; Agent 2 final mobil kimlik ve fail-closed signing sözleşmesini teslim etti. İki branch sırasıyla ve çatışmasız entegre edildi. Production/Development write veya migration apply yapılmadı. Final `com.esnaftavar.app` kimliği wired, callback ve signing kapıları açık kaldı.
- 2026-08-16: **WAVE 10 PHASE E2 FINAL MOBILE IDENTITY WIRED / SIGNING OPEN** —
  Owner-final `com.esnaftavar.app`, Android namespace/applicationId/MainActivity ve
  iOS Runner/RunnerTests Debug/Profile/Release configuration'larına bağlandı.
  Android release fail-closed signing ve iOS Apple Distribution/manual signing
  korundu. `io.supabase.tstore://login-callback/` remote allowlist değiştirilmeden
  legacy sözleşme olarak bırakıldı; final scheme + Production Auth allowlist Phase F
  atomik cutover işidir. Gerçek keystore/Apple signing materyali ve signed artifact
  bulunmadığından commercial release hazır değildir.
- 2026-08-16: **WAVE 10 D1 PRODUCTION CANONICAL MIGRATION PASS / SCHEMA READY** — Product owner'ın yalnız boş ilk bootstrap için verdiği no-backup istisnası kullanıldı. Exact Production identity, JIT zero-state, manifest 9/9 ve final linked dry-run PASS sonrasında official CLI canonical 0001→0009'u sırasıyla uyguladı. Ledger 9/9; table/RLS 23/23; policy 52/52; app function 28/28; trigger 25/25; critical RPC 15/15; Storage/Realtime/grant/search-path ve zero-data postflight PASS. Manual SQL, fixture, Auth config veya Development write yapılmadı. Final app identifier `com.esnaftavar.app` owner tarafından kesinleştirildi; platform wiring bu görevde yapılmadı. Phase E Production client wiring başlayabilir; Site URL/SMTP, signing, controlled smoke ve fiziksel QR açık olduğundan commercial release hazır değildir.
- 2026-08-16: **WAVE 10 D0 INTEGRATION COMPLETE / FIRST EMPTY BOOTSTRAP APPLY READY, NOT APPLIED** — Agent 1 linked Production CLI dry-run commit'i `--no-ff` ve çatışmasız entegre edildi. CLI exact `mefhfvrgkwciubeajjeb` ref'inde yalnız canonical `0001→0009` pending sırasını gösterdi; before/after Production state değişmedi, remote write `0`. Product owner yalnız tamamen boş ilk bootstrap için native backup/PITR olmadan ilerleme riskini ve güvenli forward-fix yoksa empty-project recreation yolunu kabul etti. Bu istisna gerçek veri geldikten sonraki migration'lara emsal değildir. Apply ayrı görev/change window'u ve just-in-time zero-state recheck ister; bu entegrasyonda migration uygulanmadı.
- 2026-08-16: **WAVE 10 PRE-MIGRATION INTEGRATION COMPLETE / MIGRATION APPLY NOT READY** — Agent 1'in Phase A ve Phase B/C belge commit'leri final branch HEAD üzerinden `--no-ff` ve çatışmasız entegre edildi. Canonical Production kimliği ve fresh/empty baseline doğrulandı; migration ledger, public uygulama tablosu, Auth user, Storage bucket/object ve Realtime uygulama üyeliği sıfırdır. Migration manifesti 9/9, clean-room replay 9/9 ve integration canonical contract testi 18/18 PASS. Free plan backup/PITR/restorable point sağlamadığından accepted RPO/RTO, restore/incident owner/drill ve enforced change window açık; linked CLI dry-run PENDING, Production migration apply/postflight yapılmadı. SMTP/e-posta, fiziksel iki-cihaz QR, final app identifiers/signing ve Production smoke da açık kaldı.
- 2026-08-16: **WAVE 9 INTEGRATION COMPLETE / COMMERCIAL RELEASE NOT READY** — Üç agent dalı zorunlu sırayla ve çatışmasız entegre edildi. Production kimliği doğrulanamadığı için Development kesin dışlandı ve belirsiz proje envanterlenmedi. Migration hash farkı Windows CRLF checkout kök nedenine indirildi; Development apply sonrası tracked SQL mutation olmadığı kanıtlandı ve canonical Git/LF manifesti 9/9 PASS oldu. Mobile signing debug fallback'siz fail-closed, Production config/Auth redirect preflight fail-closed durumdadır. Final identifier/signing, exact Production identity/config/inventory/apply/postflight/smoke, SMTP/email ve fiziksel QR açık gate'tir; remote backend yazması yapılmadı.
- 2026-08-16: **WAVE 8 INTEGRATION COMPLETE / COMMERCIAL RELEASE NOT READY** — Agent 1 release/icons fix, Agent 2 sosyal login UI cleanup ve Agent 3 Production Supabase cutover belgeleri zorunlu sırayla, çatışmasız entegre edildi. `iconsax_flutter 1.0.1` + sınırlı repo compatibility katmanı ile standart Web release build ek workaround olmadan PASS; işlevsiz sosyal UI blocker'ı kapandı, e-posta/parola/PKCE/recovery korundu. Cutover planı ile GO/NO-GO checklist'i hazırlandı ve hatalı `0001` manifest hash'i canonical dosyayla hizalandı. Hedefli 56/56, cutover 20/20 ve tam 1116/1116 test (4 gated live skip) geçti; Production/Development remote yazması yapılmadı.
- 2026-08-16: **WAVE 7 INTEGRATION COMPLETE / COMMERCIAL RELEASE NOT READY** — Agent 2 Auth callback/PKCE/enumeration hardening branch'i ve Agent 3 Production readiness audit branch'i sıralı entegre edildi; Agent 1 diff üretmediği için merge edilmedi ve fiziksel iki-cihaz gate'i BLOCKED kaldı. Android manifest conflict'i tüm gerekli izinleri ve tek callback kaydını koruyarak çözüldü; iOS duplicate callback kaydı tekilleştirildi. Auth hedefli 186/186, release-readiness 67/67, tam 1113/1113 test, analyzer, diff/security ve sentetik `--no-tree-shake-icons` compile contract'ı geçti. Production/Development remote config yazması yapılmadı.
- 2026-08-15: **WAVE 6 COMPLETE** — Agent 1 verified review/Storage backend, Agent 2 review client ve Agent 3 Storage client dalları zorunlu sırayla, çatışmasız entegre edildi. RPC sözleşmesi ve exact versioned Storage path'leri hizalandı. Development `0009` kaydı doğrulandı; normal Auth client review lifecycle 3/3 geçti ve yalnız Wave 6 fixture'ları residual `0` ile temizlendi. Hedefli 189/189, tam 1106/1106 test, analyzer, diff ve güvenlik kapıları geçti; Production'a dokunulmadı.
- 2026-08-15: **WAVE 5 COMPLETE** — Agent 1 Development web release build ve istemci smoke sonucunu PASS teslim etti; kod/merge üretmedi. Agent 2 Storage contract auditi ile Agent 3 review eligibility/legacy order auditi sıralı ve çatışmasız entegre edildi. Ürün yorumu için Option A FINAL olarak kanonikleştirildi ancak uygulanmış sayılmadı; Storage owner kararları gerçek `TBD` olarak korundu. Hedefli 169/169, tam 1069/1069 test, analyzer ve güvenlik/diff kapıları geçti.
- 2026-08-15: **WAVE 4 COMPLETE** — Live Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime sonuçları entegre edildi. Development read-only kontrolde 23 tablo, 8 migration ve 23/23 RLS doğrulandı; test verisi temiz. Bildirim stream'i geçici Realtime kanal hatalarında açık kalacak şekilde düzeltildi; birleşik hedefli/tam test ve analyzer kapıları geçti.
- 2026-08-14: Wave 4.1 `0008_fix_profile_role_guard` Development'a uygulandı; normal profil update smoke geçti, merchant/admin escalation reddedildi, PostgreSQL 42883 giderildi ve disposable müşteri güvenli RPC ile temizlendi.
- 2026-08-12: Wave 3.1 PostgreSQL özel identifier hotfix'i `origin/main`e entegre edildi; Development canonical DB bootstrap 23 tablo/7 migration ile tamamlandı, RLS/grant/RPC ve Realtime audit'i geçti, seed ve Storage bucket/policy uygulanmadı.
- 2026-08-12: canonical Supabase migration normalization, 25/23 tablo reconciliation, promotion banner read-path hardening ve kalan 9 async-context ihlalinin temizlenmesi Wave 3 entegrasyonu; analyzer ve tam test suite temiz.
- 2026-08-11: development/production config ayrımı, discovery async lifecycle hardening ve legacy order aktif navigation + DI izolasyonu Wave 2 entegrasyonu; analyzer ve tam test suite temiz.
- 2026-08-11: chat, in-app notifications ve QR/verified purchase release-hardening Wave 1 entegrasyonu; analyzer ve tam test suite temiz.
- 2026-08-10: chat güvenilirliği, delivery/read state'leri, konuşma özetleri ve hata ayrımı.
- 2026-08-09: double-submit, double-navigation ve kritik kullanıcı aksiyonu korumaları.
- 2026-08-08: guest-login sonrası hedef işleme devam etme, auth ve onboarding.
- Önceki yoğun alanlar: müşteri ekranlarının yenilenmesi, arama/satıcı fiyatları, QR güvenliği, alışveriş geçmişi, mağaza puanı, profil ve bildirimler.

## Güncelleme Kuralı

- Bu dosya yalnız kod, test, Git ve doğrulanmış backend gerçeği değiştiğinde güncellenir.
- Üretim agentları geniş kapsamlı yeniden yazma yapmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
- Bir modül ancak UI, state/business logic, backend/repository, hata davranışı ve gerekli test kanıtları birlikte yeterliyse `COMPLETE` işaretlenir.
