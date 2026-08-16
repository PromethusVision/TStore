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
