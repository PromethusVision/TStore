# Production Auth / SMTP Read-Only Acceptance Precheck

**Görev:** Wave 10 Phase F2 read-only precheck + Phase F intermediate integration +
Phase F3 live acceptance pre-write gate

**Kaynak taban:** Phase F3 `origin/main@b24f761881730159035a619822bf753b84ead6c3`;
callback cutover `44a83c5`, Auth/SMTP precheck `0881e5b`

**Production:** `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb`

**İnceleme türü:** Authenticated management read-only; Production write ve gerçek
e-posta gönderimi yapılmadı.

Bu belge canlı e-posta kabulünün yerine geçmez. Phase F3 canlı kabul denemesi,
Production'a herhangi bir yazma yapılmadan pre-write safety gate'te durmuştur. Belge
Production Auth/SMTP
yapılandırmasının, hosted e-posta şablonlarının ve mevcut Flutter Auth istemcisinin
canlı kabul öncesi sözleşmesini kaydeder. Bu çalışma sırasında Auth ayarı, kullanıcı,
e-posta, SQL, Storage veya başka bir Production verisi oluşturulmadı/değiştirilmedi.

## Project identity and provider state

Authenticated Supabase project inventory, exact Production projesini
`EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` olarak doğruladı. Development ref'i
`tnipyxnvhgelwdpykyez` Production değildir.

| Alan | Salt-okunur bulgu |
| --- | --- |
| Email provider | Enabled |
| New user signup | Enabled |
| Confirm email | Enabled; signup sonrası confirmation required |
| Phone provider | Disabled |
| Anonymous sign-in | Disabled |
| Manual identity linking | Disabled |
| Google / Apple / Facebook | Disabled |
| Diğer social/custom providers | Disabled |

Social-login görünür release UI'sı daha önce kaldırılmıştır; bu precheck provider
kurulumu veya remote provider değişikliği yapmadı.

## Phase F3 pre-write safety gate

2026-08-17 authenticated Dashboard salt-okunur tekrar kontrolü:

| Gate | Güncel bulgu | Sonuç |
| --- | --- | --- |
| Production identity | `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` | PASS |
| Development exclusion | `tnipyxnvhgelwdpykyez` farklı projedir | PASS |
| Custom SMTP | Enabled | PASS |
| Confirm email | Enabled | PASS |
| Site URL | `com.esnaftavar.app://login-callback/` | PASS |
| Redirect allowlist | Legacy ve final callback; toplam 2 exact URL | PASS |
| Auth user baseline | Refresh sonrasında `10 users (estimated)` | **FAIL / DRIFT** |

Phase F3 görevinde beklenen pre-write başlangıcı `0` Auth user idi. Görülen 10 hesabın
kimliği veya sahipliği incelenmedi; hiçbir hesaba dokunma yetkisi varsayılmadı. Bu
nedenle disposable inbox istenmeden ve normal-client signup/resend/recovery çağrısı
yapılmadan test durduruldu. Production write ve e-posta gönderimi `0` kaldı.

## Custom SMTP and domain evidence

Supabase dashboard'ında Custom SMTP **ON** durumundadır. Salt-okunur görünür alanlar:

- Sender name: `EsnaftaVar`
- SMTP host: `smtp.resend.com`
- SMTP port: `465`
- Aynı kullanıcı için minimum e-posta aralığı: `60` saniye
- Sender address ve SMTP username: dashboard mevcut değeri geri göstermedi/blank
- SMTP password: özellikle incelenmedi, okunmadı veya loglanmadı

Owner beyanı sender address'in `noreply@auth.esnaftavar.com`, SMTP username'in
`resend` ve Resend domain'inin verified/sending-enabled olduğu yönündedir. Bu iki
masked SMTP alanı ile Resend dashboard durumu bağımsız yönetim ekranı kanıtıyla
doğrulanamadı.

Public DNS, secret olmayan şu mail-domain sözleşmesini destekliyor:

- `send.auth.esnaftavar.com` için Amazon SES feedback MX kaydı mevcut;
- aynı hostname için SPF kaydı mevcut;
- `resend._domainkey.auth.esnaftavar.com` için public DKIM kaydı mevcut;
- `_dmarc.auth.esnaftavar.com` için bu kontrolde TXT kaydı bulunamadı.

Public DKIM değeri kayda alınmadı. DNS bulguları provider wiring'i destekler, fakat
tek başına Resend dashboard verification veya gerçek teslimat kanıtı değildir.
Resend hesabı bu oturumda authenticated değildi; bu nedenle link tracking durumu
**NOT OBSERVABLE**. Auth linklerinin provider tarafından yeniden yazılmadığı canlı
kabul öncesinde doğrulanmalıdır.

## URL and callback contract

| Ayar | Salt-okunur Production değeri | Sonuç |
| --- | --- | --- |
| Site URL | `com.esnaftavar.app://login-callback/` | Phase F3 mobile gate için PASS |
| Legacy mobile callback | `io.supabase.tstore://login-callback/` | Allowlist'te mevcut |
| Final mobile callback | `com.esnaftavar.app://login-callback/` | Allowlist'te mevcut |
| HTTPS web recovery URL | Yok | Ayrı Web acceptance için açık |
| Redirect allowlist toplamı | 2 exact URL | Yukarıdaki iki mobile callback |

Phase F intermediate integration sonrasında Flutter Auth istemcisinin redirect
davranışı:

- Production signup ve confirmation resend explicit final
  `com.esnaftavar.app://login-callback/` `emailRedirectTo` gönderir;
- Production mobile password recovery aynı final callback'i ve
  `auth_action=password_recovery` kullanır;
- Development signup/resend/recovery yalnız mevcut
  `io.supabase.tstore://login-callback/` callback'ini kullanır; Production callback'ine
  fallback yoktur;
- web signup/resend mevcut app originini, web recovery aynı originin
  `/?auth_action=password_recovery` adresini explicit gönderir; remote allowlist'te
  owner-onaylı HTTPS web URL bulunmadığı için ayrı web canlı kabulü başlatılamaz;
- broad otomatik callback algılama kapalıdır; PKCE exchange yalnız seçili environment'ın
  exact scheme/host/root path ve dolu `code` değerinden sonra yapılır;
- aktif magic-link/OTP login akışı yok;
- client tarafında aktif email-change çağrı yüzeyi bulunmadı; gelecekte aktive
  edilirse redirect sözleşmesi ayrıca denetlenmelidir.

Sonuç: kaynak callback/client cutover'ı entegredir ve remote Site URL exact final mobile
callback'e geçirilmiştir. Phase F3 gerçek signup/resend/recovery e-posta kabulü ise
beklenmeyen 10-user Auth baseline drift'i nedeniyle herhangi bir write öncesinde
başlatılmamıştır. Web kabulü için ayrı HTTPS route/allowlist kararı açık kalır.

## Hosted email template audit

| Hosted template | Link üretimi | Localhost/demo/TStore hardcode | Sonuç |
| --- | --- | --- | --- |
| Confirm signup | `{{ .ConfirmationURL }}` | Yok | PASS |
| Reset password | `{{ .ConfirmationURL }}` | Yok | PASS |
| Change email | `{{ .ConfirmationURL }}` | Yok | PASS; aktif client akışı değil |
| Magic link | Aktif ürün akışında kullanılmıyor | Uygulanamaz | Kapsam dışı |

İncelenen üç şablonda direct `SiteURL`, `RedirectTo` veya `TokenHash` ile kurulmuş
özel link bulunmadı. Şablonlar yapısal olarak Supabase'in ConfirmationURL üretimini
koruyor ve hardcoded localhost/example/demo/TStore referansı taşımıyor. Metinler
generic/default görünüyor; EsnaftaVar branding içermemesi link güvenliği blocker'ı
değil, fakat ticari içerik kabulünde ürün sahibi tarafından ayrıca gözden geçirilebilir.

## Rate-limit evidence

- SMTP aynı kullanıcı minimum gönderim aralığı: `60 seconds`
- Signup/signin OTP limiti: `30 / 5 minutes`
- Verify limiti: `30 / 5 minutes`
- Token refresh limiti: `150 / 5 minutes`
- Email sent hourly değeri: dashboard'da blank/unobservable; değer uydurulmadı
- IP forwarding: Off

Canlı kabul senaryoları aynı kullanıcıya ardışık e-postalar arasında en az 60 saniye
bırakmalı ve bilinmeyen hourly limitte kontrollü tek hesap/az sayıda e-posta kullanmalı.

## Production live email acceptance plan

Bu plan yalnız beklenmeyen Auth user baseline'ı product owner tarafından
sınıflandırıldıktan, Resend link tracking davranışı doğrulandıktan ve ayrı bir write
yetkili change window açıldıktan sonra uygulanır. Mobile remote URL cutover'ı tamamdır.

### Güvenli hazırlık

1. Exact project name/ref iki bağımsız kaynaktan tekrar doğrulanır.
2. Canonical HTTPS Site URL, web recovery URL ve final mobile callback; Flutter
   artifact, hosted allowlist ve release manifestinde atomik olarak doğrulanır.
3. Resend domain status ve sender address yönetim ekranından doğrulanır. Link tracking
   Auth ConfirmationURL'lerini rewrite etmeyecek şekilde kapalı/uyumlu olmalıdır.
4. Tek disposable inbox runtime'da sağlanır; adres, parola, token ve link repo/CI
   loglarına yazılmaz. Test başlangıç zamanı ve redacted fixture kimliği kaydedilir.
5. Aynı kullanıcıdaki e-posta aksiyonları arasında en az 60 saniye beklenir.

### Acceptance matrix

1. Bir disposable customer normal signup ile oluşturulur; signup response session
   vermemeli ve confirmation-required UI görünmelidir.
2. Confirmation e-postasının gerçek inbox'a geldiği; From name/domain, hedef kullanıcı
   ve mail authentication header'ları kişisel veri içermeyen kanıtla doğrulanır.
3. Confirmation linkinin doğru environment/final callback'e gittiği, localhost veya
   provider tracking redirect'i kullanmadığı doğrulanır.
4. Link bir kez kullanılır; confirmation ve sonrasında password login/session/profile
   default-customer davranışı PASS olmalıdır.
5. En az 60 saniye sonra resend çalıştırılır; yalnız hedef kullanıcıya teslimat,
   eski/yeni link semantiği ve enumeration-safe UI doğrulanır.
6. Invalid link ve duplicate click reddedilir. Kontrollü süre mümkünse expired link de
   doğrulanır; expiry düşürmek için bu plan dışında remote config değiştirilmez.
7. En az 60 saniye sonra password recovery istenir; doğru email, callback ve PKCE
   recovery ekranı doğrulanır.
8. Yeni parola kaydedilir; eski credential reddedilir, yeni credential login PASS olur
   ve recovery token tekrar kullanılamaz.
9. Test boyunca role escalation olmadığı, profile/RLS izolasyonu ve generic
   enumeration-safe cevapların korunduğu doğrulanır.
10. Canonical account-deletion/cleanup yolu çalıştırılır; Auth user, identity, profile
    ve session residual'ları yetkili management read ile sıfır doğrulanır.
11. Uygulama, Supabase ve CI loglarında e-posta, token, link, parola veya SMTP secret
    bulunmadığı redacted kanıtla kontrol edilir.

### Stop criteria

Yanlış project ref, beklenmeyen Auth user baseline'ı, sender/domain uyuşmazlığı,
localhost dönüşü, tracking kaynaklı link rewrite, secret/PII logu, role escalation,
cross-user erişim veya temizlenemeyen residual görülürse test hemen durdurulur ve
release kapısı açılmaz.

## Precheck decision

`PRODUCTION_SMTP_PRECHECK: FAIL`

Custom SMTP ON ve görünür host/port/name wiring'i doğrulandı. Buna rağmen exact masked
sender/username ile Resend dashboard verified/link-tracking durumu bağımsız
doğrulanamadığı için tam SMTP precheck PASS verilmedi.

`EMAIL_TEMPLATE_PRECHECK: PASS`

`READY_FOR_LIVE_EMAIL_ACCEPTANCE_AFTER_INTEGRATION: NO`

`PHASE_F3_PREWRITE_GATE: FAIL — AUTH BASELINE DRIFT (10 ESTIMATED USERS)`

`PHASE_F_CALLBACK_INTEGRATED: YES`

`SMTP_CONFIGURATION_PRESENT: YES`

Tamamlanan kaynak/config gözlemleri:

- Production final callback code/platform/preflight wiring;
- Development callback isolation ve PKCE exact callback hardening;
- Production Custom SMTP'nin görünür host/port/name düzeyinde mevcut olması;
- Confirm-signup, reset-password ve change-email template precheck'i.

Canlı kabul öncesi zorunlu açıklar:

- görülen 10 Production Auth user'ın owner tarafından sınıflandırılması ve kontrollü
  kabul başlangıç baseline'ının yeniden onaylanması;
- Web release kapsamındaysa HTTPS Site URL/recovery route/allowlist kararı;
- Resend link tracking ile masked sender/provider durumunun bağımsız doğrulanması;
- write yetkili ayrı canlı kabul penceresi ve disposable inbox;
- gerçek inbox confirmation, resend ve password-recovery kabulü;
- signed-artifact kabulünden sonra legacy Production callback allowlist kaydının
  yetkili remote config adımıyla kaldırılması.

`CALLBACK_INTEGRATED — LIVE_ACCEPTANCE_BLOCKED`

Integration doğrulaması: Auth callback/PKCE/signup-resend-recovery/platform/preflight
hedefli matrisi 118/118, tam Flutter suite 1154 PASS (5 opt-in live skip) ve analyzer
PASS. Bu yerel doğrulamalar gerçek e-posta gönderimi veya canlı inbox kabulü değildir.

Phase F3 blocker kaydı sonrasında callback/PKCE/deep-link, signup/resend/recovery,
account deletion, Production preflight, kontrollü Auth flow ve profile hedefli yerel
matris 129 PASS, 1 gated Development live test skip sonucu verdi. `git diff --check`,
doküman marker kontrolü ve yalnız eklenen satırlara uygulanan secret/credential shape
taraması PASS oldu. Dart kodu değişmediği için full suite/analyzer tekrarlanmadı.
