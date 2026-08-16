# Production Smoke Checklist

Bu liste **Production'a otomatik apply veya write yetkisi vermez**. Wave 10 Agent 1
Phase D1'de açık yetkiyle yalnız canonical `0001→0009` initial bootstrap'ı uyguladı ve
metadata/security postflight'ı PASS tamamladı. Integration migration'ı yeniden
uygulamadı, remote erişim/yazma yapmadı ve hesap oluşturmadı. Gerçek smoke'taki her
write önceden onaylı disposable principal/veriyle sınırlı tutulmalıdır.

## Wave 10 Phase E integrated read-only/client identity evidence

`PRODUCTION_CLIENT_SAFE_KEY_PRESENT: YES`

`PRODUCTION_RUNTIME_CONFIG: PASS`

`PRODUCTION_CLIENT_CONNECTION_READONLY: PASS`

`PRODUCTION_CLIENT_WIRED: YES`

`FINAL_APP_IDENTITY_WIRED: YES`

`FINAL_AUTH_CALLBACK_IMPLEMENTATION: PASS`

`LEGACY_PRODUCTION_ALLOWLIST_REMOVAL_REQUIRED: YES`

`SIGNING_READY: NO`

`READY_FOR_PHASE_F_INTEGRATION: YES`

`COMMERCIAL_RELEASE_READY: NO`

## Wave 10 Phase F2 Production Auth/SMTP read-only precheck

`PRODUCTION_SMTP_PRECHECK: FAIL`

`EMAIL_TEMPLATE_PRECHECK: PASS`

`READY_FOR_LIVE_EMAIL_ACCEPTANCE_AFTER_INTEGRATION: NO`

Authenticated management read-only inceleme exact `EsnaftaVar Production` /
`mefhfvrgkwciubeajjeb` projesinde Email provider, Confirm Email ve Custom SMTP'nin
etkin; SMTP host/port değerlerinin `smtp.resend.com:465` olduğunu doğruladı. Final ve
legacy mobile callback URL'leri allowlist'te birlikte mevcut. Confirm-signup,
reset-password ve change-email hosted şablonları `ConfirmationURL` kullanıyor;
hardcoded localhost/demo/TStore linki bulunmadı.

Bu kanıt canlı teslimat kabulü değildir. Phase F entegrasyonunda Production signup,
resend, recovery ve PKCE akışları final callback'e açık ve environment-isolated olarak
bağlanmıştır; ancak Site URL hâlâ `http://localhost:3000`, HTTPS web recovery
route/allowlist'i yoktur. Resend link-tracking durumu ile dashboard'un geri göstermediği
exact sender/username ayrıca doğrulanmalıdır. Ayrıntılı kanıt ve kontrollü kabul planı
[`PRODUCTION_AUTH_EMAIL_PRECHECK.md`](PRODUCTION_AUTH_EMAIL_PRECHECK.md) içindedir.

E1 gerçek Production URL/ref ve client-safe publishable key ile yalnız anonymous
read-only bağlantı yaptı. Key source/log/belgeye yazılmadı; service-role/server secret
kullanılmadı. Categories/products/shops/banners request'leri başarılı empty state,
Auth client user/session yok ve üç active Storage bucket public URL/not-found contract'ı
PASS oldu. Standard `main_production.dart` Web release build'i gerçek runtime injection
ile icon workaround olmadan PASS; credential taşıyan geçici artifact kaldırıldı.

Bu evidence full smoke veya deploy GO değildir. Auth Site URL/redirect/SMTP, platform
signing, final artifact record ve kullanıcı oluşturan/write smoke maddeleri açık kalır.
Final Android/iOS kimliği ve Production callback
`com.esnaftavar.app://login-callback/` kaynakta wired durumdadır. Development legacy
callback'i ayrı sözleşmede korunur. Production legacy allowlist kaydı yalnız
integration/signed-artifact kabulü sonrasında yetkili owner tarafından kaldırılır.

## 1. Başlatma kapıları

Smoke başlamadan önce tamamı işaretlenmelidir:

- [ ] `PRODUCTION_READINESS_AUDIT.md` içindeki BLOCKER'lar kapatıldı.
- [x] Canonical Production kimliği Wave 10'da `EsnaftaVar Production` /
      `mefhfvrgkwciubeajjeb` / exact HTTPS ref-host / Frankfurt olarak doğrulandı;
      Development `tnipyxnvhgelwdpykyez` Production değildir.
- [ ] Smoke change window'unda Production project ref ve HTTPS URL iki kişi/iki
      bağımsız kaynakla yeniden doğrulandı.
- [ ] Artifact, `main_production.dart` ile güvenli CI secret injection kullanılarak
      üretildi; commit, version/build number ve artifact hash kaydedildi.
- [ ] Artifact standart release komutuyla ve ek icon workaround'u olmadan üretildi;
      Wave 8'in sentetik config ile standart build kanıtı PASS, gerçek artifact hash'i kayıtlı.
- [ ] Artifact/service-role, DB password, JWT secret veya signing secret içermiyor.
- [x] 0001–0009 apply/postflight ledger ve schema diff'i PASS; backup/restore kanıtı
      veya yalnız boş ilk bootstrap için kayıtlı owner exception geçerli.
- [x] Canonical Git/LF migration manifesti
      `node tool/verify_migration_artifact_manifest.mjs` ile 9/9 PASS.
- [x] Production schema/RLS/RPC/Storage/Realtime metadata/security postflight PASS.
- [x] Phase E1 gerçek Production runtime config ve anonymous read-only empty-state
      bağlantısı PASS; Production write/Auth account/Storage mutation yok.
- [x] Android/iOS final application/bundle identity `com.esnaftavar.app` ve Android
      Development `.dev` varyantı kaynak sözleşmesine bağlandı.
- [x] Final Production callback istemci/platform/preflight kaynak wiring'i tamamlandı.
- [ ] Final callback integration ve signed-artifact confirmation/recovery kabulü
      tamamlandı; ardından legacy Production allowlist kaydı kaldırıldı.
- [x] Phase F2 read-only Auth/SMTP/template precheck tamamlandı; Production write,
      kullanıcı veya e-posta gönderimi yapılmadı.
- [ ] Localhost Site URL kaldırıldı; final HTTPS Site URL/fallback kararı, web recovery
      route/allowlist'i ve Resend link-tracking doğrulaması birlikte PASS.
- [ ] Production Auth Site URL/redirect/custom SMTP ve gerçek inbox acceptance PASS.
- [ ] Android/iOS kullanılıyorsa gerçek application/bundle id ve release signing PASS.
- [ ] Web kullanılıyorsa HTTPS origin, allowed origins ve Auth redirect allowlist PASS.
- [ ] Production owner iki bağımsız disposable müşteri principal'ı ve gerekiyorsa ayrı
      merchant principal'ı onaylı güvenli yöntemle hazırladı.
- [ ] Test verisi prefix'i, TTL/cleanup sahibi ve gerçek müşteri verisine dokunmama
      kuralı kayıtlı.
- [ ] Log/monitor erişimi, stop kriteri ve incident sorumlusu hazır.

**Kanıt başlığı**

- Production project ref (değer loga secret olarak yazılmamalı):
- Commit / artifact hash:
- Platform / sürüm:
- Tarih-saat / tester:
- Test principal referansları (parola/token yazılmaz):
- Cleanup sahibi:

## 2. Salt-okunur başlangıç kontrolleri

| # | Kontrol | Beklenen sonuç | Sonuç / kanıt |
| --- | --- | --- | --- |
| R1 | Production migration ledger | Exact 0001–0009 sırası ve beklenen checksum/dosya eşleşmesi | |
| R2 | Public schema / RLS | Canonical 23 tablo, 23/23 RLS; beklenmeyen açık tablo yok | |
| R3 | RPC / grant / trigger | Exact signature, revoke/grant, search path ve trigger contract'ı | |
| R4 | Storage inventory | Yalnız aktif üç bucket zorunlu; deferred bucket'lar beklenmez | |
| R5 | Realtime publication | `chat_messages` ve `notifications` üyedir; beklenmeyen tablo yok | |
| R6 | Auth config | Email/SMTP, redirect URL, allowed origin ve rate-limit ayarları onaylı | |

Herhangi bir remote drift, yanlış project ref veya restore edilemeyen backup görülürse
smoke durdurulur; düzeltme bu checklist içinde doğaçlanmaz.

## 3. Customer akış matrisi

Her satır için PASS/FAIL, zaman damgası, cihaz/tarayıcı ve mümkünse kişisel veri
içermeyen ekran/log kanıtı eklenir.

| Akış | Uygulama adımı | Beklenen sonuç | Sonuç / kanıt |
| --- | --- | --- | --- |
| App startup | Production artifact'ı temiz kurulum/oturumla aç | Splash tamamlanır; yanlış environment/fallback, config exception veya secret görünmez | |
| Guest Home/discovery | Oturum açmadan Home'u aç, yenile ve listeyi kaydır | Public katalog açılır; loading/empty/error durumu kontrollüdür | |
| Categories | Kategori listesi ve bir kategori detayı aç | Doğru ürünler ve kategori görseli gelir; çapraz/bozuk veri crash üretmez | |
| Search | Var olan, olmayan ve özel karakterli sorgu dene | Sonuç/empty state doğru; duplicate ve beklenmeyen private veri yok | |
| ProductDetails | Guest olarak ürün detayına gir | Ürün, fiyat ve satıcılar doğru; legacy HTTPS/canonical product image güvenli görüntülenir | |
| Sellers | Aynı ürünün satıcılarını ve mağaza detayını aç | Yalnız aktif/görünür satıcılar, konum/mesafe izin akışı ve fallback doğru | |
| Login/signup | Disposable User A ile signup/email confirmation/login/logout yap | SMTP/link/session/profile/legal consent çalışır; yanlış veya kullanılmış link reddedilir | |
| Password recovery | Web ve/veya mobile recovery linkini aç | Allowlist'teki origin/scheme uygulamaya döner; token bir kez kullanılır, loga sızmaz | |
| CartV2 | User A bir shop-product ekler, miktar değiştirir/siler; başka mağaza eklemeyi dener | Tek-mağaza kuralı, stok/fiyat revalidation ve duplicate tap koruması çalışır; legacy checkout açılmaz | |
| Favorites | User A ekler/çıkarır; User B ile izolasyonu kontrol et | Own CRUD çalışır; B, A'nın favorisini okuyamaz/değiştiremez | |
| Chat | A ve B aynı conversation'da mesajlaşır; üçüncü conversation ile izolasyonu dene | Real event bir kez gelir; RLS, unread/summary, unsubscribe/reconnect/dedup doğru | |
| Notifications | Canonical ürün trigger'ı ile A için bildirim üret; B'yi gözle | Yalnız A alır; direct authenticated INSERT reddedilir; unread/mark-read/reconnect/dedup doğru | |
| QR create | User A'nın CartV2 verisiyle QR oluştur | Server-authoritative kısa ömürlü session ve immutable item snapshot oluşur | |
| QR physical confirm | Ayrı gerçek merchant cihazında okut/onayla | Doğru mağaza onaylar; yanlış mağaza, expired/cancelled/used token ve double confirm reddedilir | |
| Verified purchase | User A cihazında polling/tamamlanma ve geçmişi aç | İşlem bir kez tamamlanır; doğru ürün snapshot'ları görünür; legacy order akışı açılmaz | |
| Shop rating | Doğrulanmış işlem sonrası mağaza puanı oluştur/güncelle | Eligibility server-derived; yetkisiz, başka kullanıcı ve duplicate davranışı kontrollü | |
| Product review | Yalnız doğrulanmış transaction item ürünü için create/read/update/delete/recreate yap | RPC-only eligibility, server-derived verified flag, idempotent duplicate ve aggregate tutarlılığı çalışır | |
| Profile | Profil görüntüle/düzenle; adres/konum izin reddi ve kabulünü dene | Own data çalışır; cross-user RLS reddeder; izin reddi kontrollü fallback verir | |
| Account deletion | Ayrı disposable hesapta uyarıyı kabul edip sil | Auth/profile ilişkili veri canonical sözleşmeye göre temizlenir; tekrar login olmaz; başka principal etkilenmez | |
| Storage images | Product/category/banner için controlled path ve legacy HTTPS örneği aç; malformed kaynak dene | Public GET çalışır; doğru ortam URL'si kullanılır; malformed/unsupported kaynak fallback verir; list/write/update/delete yoktur | |

## 4. Negatif güvenlik ve yaşam döngüsü

- [ ] Anonymous kullanıcı private profile/cart/favorite/chat/notification/review mutation
      yapamaz.
- [ ] User B, User A'nın private satırlarını okuyamaz veya değiştiremez.
- [ ] Müşteri merchant/admin rolüne client payload ile yükselemez.
- [ ] Direct notification INSERT ve client Storage write/update/delete/list reddedilir.
- [ ] Disposable fixture ile Storage negative listing denial kabulü doğrulandı;
      Phase E empty-list sonucu bu davranışın kanıtı olarak kullanılmaz.
- [ ] QR token, Auth token, e-posta, parola ve kişisel veri uygulama/edge/CI logunda yoktur.
- [ ] Offline/timeout sonrası retry aynı QR, mesaj, bildirim, rating veya review kaydını
      iki kez oluşturmaz.
- [ ] Logout/login ve Realtime reconnect sonrasında eski kullanıcı kanalı açık kalmaz;
      duplicate subscription/event yoktur.
- [ ] Uygulama yanlış/eksik Production define ile başka ortama fallback yapmadan güvenli
      şekilde durur.

## 5. Storage ve media kabulü

- [ ] `product-images`: `catalog/<product_id>/...` public read.
- [ ] `product-images`: `shops/<shop_id>/<shop_product_id>/...` public read.
- [ ] `category-images`: controlled category path public read.
- [ ] `banner-images`: controlled banner path public read.
- [ ] Existing valid HTTPS media geriye uyumlu okunur.
- [ ] `javascript:`, `data:`, local file, malformed ve unknown bucket/path güvenli fallback.
- [ ] Anonymous object GET çalışırken object listesi ve tüm client mutation'ları reddedilir.
- [ ] `brand-logos`, `avatars`, `review-images` bulunmaması FAIL değildir.

## 6. Stop, rollback ve cleanup

Şunlardan biri görülürse smoke hemen durur:

- yanlış Supabase project ref/origin;
- secret/service-role/DB credential sızıntısı;
- RLS ile başka kullanıcı verisine erişim;
- beklenmeyen migration drift veya veri kaybı;
- duplicate financial/verified purchase kanıtı ya da tekrar kullanılabilir QR;
- hesap silmenin başka kullanıcıya etkisi;
- crash loop veya kontrolsüz hata logu.

Smoke sonunda:

- [ ] Yalnız onaylı test prefix'li chat/notification/cart/QR/rating/review verisi canonical
      cleanup yoluyla temizlendi; gerçek müşteri verisine dokunulmadı.
- [ ] Account-deletion testi dışındaki disposable principal cleanup'ını Auth sahibi yaptı.
- [ ] Residual sayımları kaydedildi; beklenmeyen residual varsa release durduruldu.
- [ ] Log ve ekran kanıtları secret/PII açısından redakte edildi.
- [ ] PASS/FAIL ve açık incidentler release sahibi tarafından imzalandı.

**Final karar**

- [ ] PASS — Production release kapısı açılabilir.
- [ ] FAIL — Release durduruldu; incident/owner/takip işi kayıtlı.
