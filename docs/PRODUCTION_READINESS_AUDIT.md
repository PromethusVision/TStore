# Production Readiness Audit

**Audit tarihi:** 2026-08-16

**Kaynak:** Wave 10 D1 integration; base
`origin/main@609a037664f8c001951ba00193e6112989399a9b`

**Kapsam:** Customer uygulaması için Production smoke öncesi kaynak, yapılandırma,
migration ve operasyon kapıları

**Wave 10 evidence erişimi:** Agent 1 Phase A/B/C/D0 salt-okunur **YES**; Phase D1
canonical `0001→0009` apply **YES**. Bu integration sırasında remote erişim/yazma
**YOK** ve migration yeniden uygulanmadı.

## Sonuç

`PRODUCTION_SMOKE_READY: NO`

`PRODUCTION_SCHEMA_READY: YES`

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / PLATFORM WIRING PENDING`

`READY_FOR_PHASE_E_PRODUCTION_CLIENT_WIRING: YES`

Uygulamanın Development kanıtları ve yerel sözleşmeleri güçlüdür. Wave 10 D1'de exact
Production hedefinde canonical migration ve metadata/security postflight tamamlandı;
ancak client-safe key release kanalında sağlanmadı, Auth Site URL/redirect/SMTP hâlâ
fresh default durumunda ve platform identifier/signing wiring yapılmadı. Final app
identifier `com.esnaftavar.app` olarak karara bağlandı. Aşağıdaki kalan BLOCKER
maddeleri kapanmadan gerçek Production smoke başlatılmamalı ve dummy değerle alınan
build bir smoke PASS olarak yorumlanmamalıdır.

Bu belge mevcut repo gerçekliğini raporlar. Yeni altyapı önerileri ayrıca
`recommended` olarak işaretlenmiştir.

## Release gate özeti

| Alan | Sınıf | Kanıt / kapanış koşulu |
| --- | --- | --- |
| Development / Production namespace ayrımı | PASS | `main_development.dart` yalnız `SUPABASE_DEVELOPMENT_*`, `main_production.dart` yalnız `SUPABASE_PRODUCTION_*` değerlerini okur; karşı ortam fallback'i yoktur. |
| Client credential doğrulaması | PASS | HTTPS zorunluluğu, placeholder reddi, publishable/legacy anon kabulü ve `sb_secret_`/`service_role` reddi testlidir; hata metni değer sızdırmaz. |
| Production config preflight / entrypoint | PASS | Yalnız `lib/main_production.dart`, exact ref-host, client-safe key ve canonical Auth redirect manifesti kabul edilir. Development ref, placeholder/local/malformed değer, server credential ve sentetik fixture'ın release modunda kullanımı fail-closed reddedilir. |
| Standart Web release build / icon tree-shaking | PASS | Sorunlu `iconsax 0.0.8` kaldırıldı; `iconsax_flutter 1.0.1` ve yalnız kullanılan glyph'leri açan repo-local compatibility katmanı devrede. Sentetik client-safe config ile standart build ek icon workaround'u olmadan PASS oldu. |
| Mobil ağ, konum, kamera ve Auth callback kaydı | PASS | Android main manifest ve iOS plist sözleşmesi bu wave'de tamamlandı ve statik testle korundu. |
| Canonical migration kaynak zinciri | PASS | Resmi fresh-bootstrap kaynağı sıralı `0001`–`0009` dosyalarıdır; sıralama, RLS ve güvenlik sözleşmeleri repo testleriyle korunur. |
| Migration artifact manifesti | PASS | Wave 9 kök neden analizi eski hashlerin Windows CRLF checkout'una bağlı olduğunu doğruladı. Git/LF canonical SHA-256 manifesti ve tekrar çalıştırılabilir araç 9/9 PASS; Development apply kanıtından sonra tracked SQL mutation yok. |
| Development backend kanıtı | PASS | Proje durumuna göre 0001–0009, 23/23 RLS, QR/Auth/Realtime ve review lifecycle Development'ta doğrulanmıştır. Bu kanıt Production'a taşınmış sayılmaz. |
| Exact Production project identity | PASS | `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` / ref-host / Frankfurt iki authenticated Dashboard görünümünde doğrulandı. `EsnaftaVar Development` (`tnipyxnvhgelwdpykyez`) ayrı projedir ve Production değildir. |
| Production URL ve client-safe key | BLOCKER | URL `https://mefhfvrgkwciubeajjeb.supabase.co` doğrulandı ve publishable key alanının varlığı görüldü; key değeri okunmadı/kopyalanmadı. Gerçek client-safe değer yalnız güvenli CI/release secret kanalından verilmelidir. |
| Production migration envanteri | PASS — CANONICAL 9/9 | Final ledger exact 0001→0009; 23 public tablo, 23/23 RLS, 52/52 policy, 28/28 app function, 25/25 trigger, 15/15 kritik RPC ve zero business data doğrulandı. |
| Linked Production CLI dry-run | PASS | Exact `mefhfvrgkwciubeajjeb` ref'inde yalnız canonical `0001→0009` pending; before/after remote state aynı, write `0`. |
| First empty bootstrap backup/recovery | OWNER-ACCEPTED EXCEPTION | Native backup/PITR yok. Owner yalnız boş ilk bootstrap için no-backup riskini ve güvenli forward-fix yoksa empty-project recreation yolunu kabul etti; gerçek veri sonrası geçersizdir. |
| Production migration apply | PASS / COMPLETED | JIT zero-state ve final linked dry-run sonrasında official CLI yalnız canonical 0001→0009'u uyguladı; integration yeniden apply yapmadı. |
| Production Auth / SMTP / redirects | BLOCKER | Production-like email confirmation, SMTP teslimi, password recovery ve mobile/web redirect allowlist kabulü henüz yapılmamıştır. |
| Android dağıtım kimliği ve imzası | BLOCKER — DECISION FINAL / WIRING PENDING | Final identifier `com.esnaftavar.app`; repo platform değeri henüz değiştirilmedi. Gerçek upload keystore/alias/parola ve signed artifact yoktur. |
| iOS dağıtım kimliği ve imzası | BLOCKER — DECISION FINAL / WIRING PENDING | Final identifier `com.esnaftavar.app`; repo platform değeri henüz değiştirilmedi. Team ID, certificate/profile ve macOS signed archive yoktur. |
| Sosyal login release UI | PASS | Çalışmayan Google/Facebook düğmeleri ve anlamsız ayırıcı aktif Login/Signup UI'dan kaldırıldı. E-posta/parola, kayıt ve recovery korunur; OAuth/provider altyapısı gelecekteki optional özellik için yerinde kalır. |
| Fiziksel iki cihaz QR kabulü | BLOCKER | Kamera izni, müşteri QR, merchant okutma/onay ve müşteri tamamlanması iki gerçek cihazda henüz kabul edilmemiştir. |
| Production RLS / RPC / Storage / Realtime | PASS — METADATA/SECURITY POSTFLIGHT | 23/23 RLS, final policy/grant/search-path, critical RPC/trigger, exact üç bucket ve exact iki Realtime member doğrulandı. Disposable-principal davranış testi controlled smoke'ta açık kalır. |
| Kritik customer akışları | NEEDS PRODUCTION VERIFICATION | Kaynak ve yerel test kapsamı vardır; gerçek Production sonuçları `PRODUCTION_SMOKE_CHECKLIST.md` ile kaydedilmelidir. |
| `brand-logos`, `avatars`, `review-images` | DEFERRED / NON-BLOCKING | Wave 6 kararı gereği provision edilmez ve release gate değildir. |
| Legacy order final drop | DEFERRED / NON-BLOCKING | Aktif müşteri akışına bağlı değildir; final veri/kod kaldırma ayrı yetkili iştir. |
| Push notification | DEFERRED / NON-BLOCKING | In-app notification vardır; FCM/push yoktur. İlk sürüm şartıysa ayrıca ürün kararı gerekir. |
| Analytics / crash reporting | DEFERRED / NON-BLOCKING | Repoda bulunmamıştır. Release gözlemlenebilirliği için eklenmesi `recommended`dır; mevcut özellik gibi sunulmaz. |
| Web PWA adı/renk/metadata temizliği | DEFERRED / NON-BLOCKING | Manifest/index hâlâ generic `t_store` ve placeholder metadata içerir. Doğrudan browser smoke'u engellemez; installable PWA release hedefiyse blocker'a yükseltilmelidir. |

## Environment ve entrypoint sözleşmesi

- Development ve Production girişleri farklı Dart define adları kullanır; ortak/fallback
  anahtar yoktur.
- `.env` uygulama asset'i değildir. `.env.example` yalnız dört client-safe değişken
  adını belgeler.
- Production URL HTTPS olmalı; loopback ve insecure HTTP reddedilir.
- İstemci yalnız Supabase publishable key veya legacy `anon` JWT alabilir. Secret,
  service-role, database parolası ve signing secret uygulamaya veya build loguna
  konmamalıdır.
- CI komutu değerleri kaynak dosyaya yazmadan `--dart-define` veya güvenli eşdeğeriyle
  sağlamalı; komut/log maskeleme politikası release sahibince doğrulanmalıdır.
- Mobile Auth dönüş URI'si `io.supabase.tstore://login-callback/`, web password
  recovery dönüşü ise dağıtılan origin üzerindeki `/` adresidir. Supabase Auth redirect
  allowlist bu exact değerlerle eşleştirilmelidir.
- Allowed origins/CORS listesine yalnız gerçek HTTPS production originleri eklenmeli;
  Development origin veya wildcard Production'a taşınmamalıdır.

Bu audit'te Production URL bilinse de client-safe key release kanalında bulunmadığı
için build yalnız canonical
[`tool/production_compile_contract.json`](../tool/production_compile_contract.json)
sentetik fixture'ıyla compile contract doğrular. Fixture exact altı alanlı release
manifest shape'ini taşır, yalnız `--mode=contract` preflight'ında kabul edilir ve
release modunda fail-closed reddedilir. Uygulama bu değerlerle backend'e bağlanmaz;
sonuç **gerçek startup/Auth/smoke PASS değildir**.

### Release build sonucu

- Target: Web release, `lib/main_production.dart`.
- Gerçek Production URL/key: artifact build'de kullanılmadı; key süreç ortamında
  mevcut değildi.
- Dependency: `iconsax_flutter 1.0.1`; repo-local `iconsax_compat.dart` yalnız kullanılan
  icon yüzeyini açar ve sıfır/geçersiz codepoint içermez.
- Standart icon tree-shaking: **PASS**; `--no-tree-shake-icons` kullanılmadı.
- Standard Web release compile/config contract: **PASS** (`build/web`),
  `--no-tree-shake-icons` kullanılmadı.
- Android `compileFlutterBuildProductionRelease`: **PASS**; signed artifact değildir.
- Android development debug APK: **PASS**.
- Android release packaging: signing materyali olmadığı için beklenen açık hata ile
  **FAIL-SAFE PASS**; debug key fallback'i yoktur.
- Sonuç: Varsayılan release build blocker'ı kapanmıştır. Dummy config ile üretilen
  artifact yine de dağıtılamaz ve startup/Auth/Production smoke kanıtı değildir.

## Canonical migration preflight

| Sıra | Dosya | Ana bağımlılık / risk |
| --- | --- | --- |
| 0001 | `20260812000100_0001_core_auth_catalog.sql` | Managed `auth.users` üzerinde fresh bootstrap; core auth/catalog ve korunan legacy tablolar. Mevcut/unknown schema'ya kör uygulanmaz. |
| 0002 | `20260812000200_0002_shops.sql` | 0001 profile/product ve timestamp helper; shops/shop-products. |
| 0003 | `20260812000300_0003_carts_v2.sql` | Auth, shops ve shop-products; Cart V2. |
| 0004 | `20260812000400_0004_qr_verified_purchases.sql` | 0001–0003, managed `extensions`; QR ve verified purchase RPC'leri. |
| 0005 | `20260812000500_0005_verified_shop_ratings.sql` | Shops ve verified transactions; doğrulanmış mağaza puanı. |
| 0006 | `20260812000600_0006_chat_notifications_account.sql` | Profiles/orders/shops/chat/notifications/verified transactions; summary RPC, trigger ve account deletion. |
| 0007 | `20260812000700_0007_storage_realtime.sql` | Chat/notifications ve managed `supabase_realtime` publication; Realtime üyeliği. |
| 0008 | `20260814000800_0008_fix_profile_role_guard.sql` | Profile role guard function/trigger düzeltmesi. |
| 0009 | `20260815000900_0009_verified_product_reviews_storage.sql` | 0001–0008, managed Storage tabloları/RLS; verified review RPC'leri ve aktif üç bucket. Mevcut review/product aggregate verisini canonical evidence'a göre günceller. |

### D1'de tamamlanan apply kontrolü ve gelecek migration şablonu

Bu adımlar D1 initial bootstrap'ta owner'ın yalnız boş proje için verdiği dar backup
istisnasıyla tamamlandı. Liste gelecekteki Production migration'larında yeniden
uygulanır; D1 istisnası sonraki değişikliklere taşınmaz.

1. Production project ref/URL, ortam sahibi ve change window yazılı olarak doğrulanır;
   terminal prompt/project adı tek başına kanıt sayılmaz.
2. Read-only olarak `supabase_migrations.schema_migrations` envanteri ve 0001–0009
   checksum/dosya eşleşmesi alınır. Erişim yoksa state için tahminde bulunulmaz.
3. Public tablo/kolon/constraint/index, 23/23 RLS, policy, grant, function signature,
   trigger ve publication envanteri canonical kaynakla diff edilir.
4. `auth.users`, `extensions`, `storage.buckets`, `storage.objects` ve
   `supabase_realtime` managed-service önkoşulları doğrulanır.
5. Fresh ve boş proje kanıtlanmışsa 0001→0009 kesintisiz sırayla uygulanır. Existing
   veya unknown schema'da 0001 kör çalıştırılmaz; drift için ayrı reconciliation planı
   hazırlanır.
6. Apply öncesi backup/PITR veya mantıksal dump alınır; başka projede/restore hedefinde
   geri yükleme adımı denenir ve RTO/RPO sahibi kaydedilir.
7. Özellikle 0009'un legacy review `is_verified_purchase` ve product aggregate
   düzeltmelerinin sayısal etkisi dry-run/read-only sorgularla raporlanır.
8. Yetkili migration sahibi onaylı change window'da uygular. D1'de Agent 1 bu adımı
   tamamladı; integration audit'i migration'ı yeniden uygulamaz.
9. Her dosyanın transaction sonucu ve migration ledger kaydı alınır. Postflight;
   schema, RLS, policy/grant, RPC/trigger, publication ve bucket contract testlerini
   tekrarlar.
10. Dosya içi hata transaction rollback'tir. Commit sonrası geri dönüş down-migration
    varsaymaz; onaylı forward-fix veya doğrulanmış backup restore planı kullanılır.

## Security ve operasyon preflight

| Kontrol | Zorunlu durum |
| --- | --- |
| Backup / rollback | Apply öncesi restore edilebilir yedek, RTO/RPO, karar sahibi ve stop kriteri kayıtlı olmalı. |
| RLS | 23 public tabloda enabled; anonymous/authenticated/merchant/admin çapraz kullanıcı negatif testleri Production postflight'ta geçmeli. |
| RPC | SECURITY DEFINER search path, default EXECUTE revoke ve exact role grant'leri inventory + negatif testle doğrulanmalı. |
| Storage | Yalnız `product-images`, `category-images`, `banner-images`; public object GET çalışmalı, list/write/update/delete client için reddedilmeli; MIME/size/path sözleşmesi doğrulanmalı. |
| Realtime | `chat_messages` ve `notifications` publication üyeliği, doğru recipient izolasyonu, reconnect ve dedup iki principal ile doğrulanmalı. |
| Auth/email | Confirm Email kararı, SMTP sender/domain, rate limit, delivery, expired link, password recovery ve account deletion kabulü tamamlanmalı. |
| Public keys | Yalnız publishable/anon istemciye girer; service role, JWT secret, DB password ve signing key artifact/log içinde bulunmamalı. |
| Redirect/Origins | Mobile exact scheme/host, Production web origin, OAuth sağlayıcı callback'leri ve wildcard olmayan allowed origins doğrulanmalı. |
| Logging | Loglarda token, e-posta, QR tokenı ve kişisel veri bulunmadığı kontrol edilmeli; release log seviyesi ve retention sahibi belirlenmeli. |
| Seed/test data | Canonical migration seed içermez. Production smoke yalnız onaylı disposable hesap/veri prefix'iyle yapılmalı; gerçek müşteri verisi kullanılmamalı ve cleanup kanıtlanmalı. |

### Recommended, mevcutta bulunmayan operasyon altyapısı

- Crash/error monitoring ve release/version korelasyonu.
- Kullanıcı kimliği/PII taşımayan temel startup ve kritik RPC hata metriği.
- CI artifact provenance, hash ve environment attestation.
- Production health dashboard, alarm sahipliği ve incident runbook.

Bunlar repoda bugün varmış gibi kabul edilmemeli; ilk release risk iştahına göre release
sahibi tarafından planlanmalıdır.

## Kritik customer smoke kapsamı

Startup, guest Home/discovery, categories, search, ProductDetails, sellers,
login/signup, CartV2, favorites, chat, notifications, QR, verified purchase, shop
rating, product review, profile/account deletion ve Storage images için operasyonel
adımlar [Production Smoke Checklist](PRODUCTION_SMOKE_CHECKLIST.md) belgesindedir.

Exact inventory, backup, apply, postflight ve GO/NO-GO sırası
[Production Supabase Cutover Plan](PRODUCTION_SUPABASE_CUTOVER_PLAN.md) ile
[Production Go/No-Go Checklist](PRODUCTION_GO_NO_GO_CHECKLIST.md) içinde hazırdır.
Gerçek smoke ancak bu belgedeki kalan blocker'lar kapandıktan sonra, Production
owner'ın sağladığı client-safe config ve disposable hesaplarla yürütülmelidir.

## Audit validation kanıtı

- Wave 10 exact Production identity ve fresh/empty read-only baseline: **PASS**.
- Wave 10 local safe-equivalent clean-room replay ve linked CLI Production dry-run:
  **9/9 PASS**; remote state unchanged, write `0`.
- Empty-first-bootstrap no-backup/recreate owner risk decision: **ACCEPTED**, yalnız bu
  ilk bootstrap için.
- Wave 10 D1 canonical migration apply ve metadata/security postflight: **PASS**;
  ledger 9/9, table/RLS 23/23, policy 52/52, app function 28/28, trigger 25/25,
  critical RPC 15/15, exact Storage/Realtime ve zero business data.
- Wave 10 integration canonical migration contract testi: **18/18 PASS**.
- Wave 9 migration/config/signing/platform/Auth hedefli testleri: **62/62 PASS**.
- Canonical Git/LF 0001–0009 SHA-256 manifest kontrolü: **9/9 PASS**.
- Tam Flutter suite: **1136/1136 PASS**, 4 açık opt-in isteyen Development live test
  normal koşuda skip.
- Standart Web release build, sentetik client-safe compile fixture'ıyla ve ek icon
  workaround'u olmadan: **PASS**.
- Android production-release compile-only ve development debug build: **PASS**;
  release packaging eksik signing materyalinde beklenen fail-closed sonuç.
- `flutter analyze --no-pub`: **PASS**, issue yok.
- Android manifest ve iOS plist XML parse: **PASS**.
- Değişen dosyalarda JWT-benzeri token, `sb_secret_`/gerçek publishable credential,
  private key veya credential içeren database URI taraması: **0 bulgu**. Doğrulanmış
  Production project URL/ref secret değildir ve canonical belgelerde açıkça kayıtlıdır.
- `git diff --check`: **PASS**.
- Wave 10 Agent evidence remote read: **YES**. Agent Phase D1 remote write yalnız
  canonical 0001→0009 bootstrap apply'dır; Auth config, Storage object ve test hesabı
  yazması yoktur. Integration remote erişim/yazma yapmadı ve migration'ı yeniden
  uygulamadı.
