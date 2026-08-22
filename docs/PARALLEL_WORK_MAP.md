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

`READY_FOR_DEMO_DATASET_PHASE_B: NO — SEPARATE PRODUCTION SAFETY REVIEW + EXPLICIT OWNER AUTHORIZATION REQUIRED`

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
