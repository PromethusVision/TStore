# Production Readiness Audit

**Audit tarihi:** 2026-08-15

**Kaynak:** `origin/main@b71bb01cf5bbacdae2c2ad66c6b70d37bf82b0fb`

**Kapsam:** Customer uygulaması için Production smoke öncesi kaynak, yapılandırma,
migration ve operasyon kapıları

**Production erişimi/yazması:** YOK

## Sonuç

`PRODUCTION_SMOKE_READY: NO`

Uygulamanın Development kanıtları ve yerel sözleşmeleri güçlüdür; ancak bu audit
sırasında gerçek Production client değerleri mevcut değildir, Production migration
durumu bilinmemektedir ve Production'a hiçbir bağlantı kurulmamıştır. Aşağıdaki
BLOCKER maddeleri kapanmadan gerçek Production smoke başlatılmamalı ve dummy değerle
alınan build bir smoke PASS olarak yorumlanmamalıdır.

Bu belge mevcut repo gerçekliğini raporlar. Yeni altyapı önerileri ayrıca
`recommended` olarak işaretlenmiştir.

## Release gate özeti

| Alan | Sınıf | Kanıt / kapanış koşulu |
| --- | --- | --- |
| Development / Production namespace ayrımı | PASS | `main_development.dart` yalnız `SUPABASE_DEVELOPMENT_*`, `main_production.dart` yalnız `SUPABASE_PRODUCTION_*` değerlerini okur; karşı ortam fallback'i yoktur. |
| Client credential doğrulaması | PASS | HTTPS zorunluluğu, placeholder reddi, publishable/legacy anon kabulü ve `sb_secret_`/`service_role` reddi testlidir; hata metni değer sızdırmaz. |
| Production entrypoint kaynak sözleşmesi | PASS | Ayrı entrypoint production ortamını seçer. Client-safe dummy değerlerle Web release derlenebilirliği doğrulandı; bu yalnız compile/config contract kanıtıdır. |
| Varsayılan Web icon tree-shaking | BLOCKER | `iconsax 0.0.8` içinde `IconData(0x0)` bulunduğu için normal release build font subsetting aşamasında durur. `--no-tree-shake-icons` ile compile PASS oldu; release pipeline bu flag'i açıkça sabitlemeli veya dependency ayrı kapsamda giderilmelidir. |
| Mobil ağ, konum, kamera ve Auth callback kaydı | PASS | Android main manifest ve iOS plist sözleşmesi bu wave'de tamamlandı ve statik testle korundu. |
| Canonical migration kaynak zinciri | PASS | Resmi fresh-bootstrap kaynağı sıralı `0001`–`0009` dosyalarıdır; sıralama, RLS ve güvenlik sözleşmeleri repo testleriyle korunur. |
| Development backend kanıtı | PASS | Proje durumuna göre 0001–0009, 23/23 RLS, QR/Auth/Realtime ve review lifecycle Development'ta doğrulanmıştır. Bu kanıt Production'a taşınmış sayılmaz. |
| Production URL ve client-safe key | BLOCKER | Bu audit ortamında `SUPABASE_PRODUCTION_URL` ve `SUPABASE_PRODUCTION_ANON_KEY` yoktur. Değerler yalnız güvenli CI/release secret kanalından verilmelidir. |
| Production migration envanteri | NEEDS PRODUCTION VERIFICATION | Remote erişim kullanılmadı. `supabase_migrations.schema_migrations`, schema, RLS, policy, grant, RPC, trigger, publication ve bucket durumu read-only envanterlenmelidir. |
| Production backup/restore ve migration apply | BLOCKER | Apply öncesi doğrulanmış backup/PITR veya mantıksal dump, restore hedefi ve forward-fix/restore sahibi yoksa migration çalıştırılmamalıdır. |
| Production Auth / SMTP / redirects | BLOCKER | Production-like email confirmation, SMTP teslimi, password recovery ve mobile/web redirect allowlist kabulü henüz yapılmamıştır. |
| Android dağıtım kimliği ve imzası | BLOCKER | `com.example.t_store` hâlâ örnek application id/namespace'tir ve release build debug signing kullanır. Yayın sahibi gerçek id ve release signing'i güvenli keystore/CI ile sağlamalıdır. |
| iOS dağıtım kimliği ve imzası | BLOCKER | `com.example.tStore` ve development signing ayarları gerçek App Store dağıtım sözleşmesi değildir; bundle id/team/certificate yayın sahibi tarafından tamamlanmalıdır. |
| Görünür sosyal login düğmeleri | BLOCKER | Kaynak durumuna göre düğmeler görünür fakat callback'leri boş. İlk sürümde uygulanmalı veya ürün sahibi kararıyla görünmez yapılmalıdır. |
| Fiziksel iki cihaz QR kabulü | BLOCKER | Kamera izni, müşteri QR, merchant okutma/onay ve müşteri tamamlanması iki gerçek cihazda henüz kabul edilmemiştir. |
| Production RLS / RPC / Storage / Realtime davranışı | NEEDS PRODUCTION VERIFICATION | Statik ve Development kanıtı vardır; Production postflight ve smoke matrisi ayrıca çalıştırılmalıdır. |
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

Bu audit'te gerçek Production değerleri bulunmadığı için release build yalnız şu tip
sentetik client-safe değerlerle compile contract doğrular:

```text
SUPABASE_PRODUCTION_URL=https://production-build-contract.example.supabase.co
SUPABASE_PRODUCTION_ANON_KEY=sb_publishable_production_build_contract
```

Bu değerlerle uygulama backend'e bağlanmaz ve sonuç **gerçek startup/Auth/smoke PASS
değildir**.

### Release build sonucu

- Target: Web release, `lib/main_production.dart`.
- Gerçek Production URL/key: kullanılmadı; süreç ortamında ikisi de mevcut değildi.
- Varsayılan icon tree-shaking: **FAIL** — üçüncü taraf `iconsax 0.0.8`
  `call_minus4` sabiti `IconData(0x0)` üretti ve font subset bunu geçersiz Unicode
  codepoint olarak reddetti.
- `--no-tree-shake-icons` ile compile/config contract: **PASS** (`build/web`).
- Sonuç: Entry point derlenebilir, ancak release CI komutu flag'i sabitlemeden veya
  dependency remediation yapılmadan varsayılan build kapısı geçmez. Dummy config ile
  üretilen artifact dağıtılamaz ve smoke kanıtı değildir.

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

### Apply öncesi exact adımlar

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
8. Yetkili migration sahibi onaylı change window'da uygular. Bu audit apply yapmaz.
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

Gerçek smoke ancak bu belgedeki blocker'lar kapandıktan sonra, Production owner'ın
sağladığı client-safe config ve disposable hesaplarla yürütülmelidir.

## Audit validation kanıtı

- Environment/platform/migration/Storage/review/Auth hedefli testleri: **58/58 PASS**.
- Tam Flutter suite: **1108/1108 PASS**, 4 açık opt-in isteyen Development live test
  normal koşuda skip.
- `flutter analyze --no-pub`: **PASS**, issue yok.
- Android manifest ve iOS plist XML parse: **PASS**.
- Değişen dosyalarda gerçek Supabase project URL, JWT-benzeri token, `sb_secret_`
  credential veya database URI taraması: **0 bulgu**.
- `git diff --check`: **PASS**.
- Production remote read/write, migration, Auth/Storage değişikliği ve test hesabı:
  **YOK**.
