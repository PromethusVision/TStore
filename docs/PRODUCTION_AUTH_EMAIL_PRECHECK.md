# Production Auth / SMTP Read-Only Acceptance Precheck

**Görev:** Wave 10 Phase F2

**Kaynak taban:** `origin/main@9206d598291a6ed546149436725afff6e0dc40ae`

**Production:** `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb`

**İnceleme türü:** Authenticated management read-only; Production write ve gerçek
e-posta gönderimi yapılmadı.

Bu belge canlı e-posta kabulünün yerine geçmez. Yalnız Production Auth/SMTP
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
| Site URL | `http://localhost:3000` | Release için blocker |
| Legacy mobile callback | `io.supabase.tstore://login-callback/` | Allowlist'te mevcut |
| Final mobile callback | `com.esnaftavar.app://login-callback/` | Allowlist'te mevcut |
| HTTPS web recovery URL | Yok | Web recovery için blocker |
| Redirect allowlist toplamı | 2 exact URL | Yukarıdaki iki mobile callback |

Final app identifier remote allowlist'te yer alıyor, ancak mevcut Flutter kodu hâlâ
legacy callback sözleşmesini kullanıyor. Agent 1 için ayrılmış
`agent1/w10-final-auth-callback-cutover` branch'i inceleme anında kaynak tabanla aynı
committeydi ve cutover diff/commit'i yoktu. Phase F callback entegrasyonu tamamlanmış
kabul edilmemelidir.

Mevcut `origin/main` Auth istemcisinin redirect davranışı:

- signup explicit `emailRedirectTo` göndermiyor; hosted ConfirmationURL, Site URL
  fallback'ına bağımlı;
- confirmation resend explicit redirect göndermiyor ve aynı fallback'a bağımlı;
- mobile password recovery explicit legacy callback ve
  `auth_action=password_recovery` kullanıyor; allowlist ile uyumlu;
- web password recovery mevcut web originini explicit redirect olarak gönderiyor;
  allowlist'te bir HTTPS web URL olmadığı için localhost Site URL fallback riski var;
- aktif magic-link/OTP login akışı yok;
- client tarafında aktif email-change çağrı yüzeyi bulunmadı; gelecekte aktive
  edilirse redirect sözleşmesi ayrıca denetlenmelidir.

Sonuç: `http://localhost:3000` değiştirilmeden ve callback/client cutover atomik
biçimde entegre edilmeden gerçek signup/resend/recovery e-posta kabulü başlatılmaz.

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

Bu plan yalnız callback entegrasyonu ve remote URL cutover'ı tamamlandıktan, Resend
link tracking davranışı doğrulandıktan ve ayrı bir write yetkili change window
açıldıktan sonra uygulanır.

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

Yanlış project ref, sender/domain uyuşmazlığı, localhost dönüşü, tracking kaynaklı link
rewrite, secret/PII logu, role escalation, cross-user erişim veya temizlenemeyen residual
görülürse test hemen durdurulur ve release kapısı açılmaz.

## Precheck decision

`PRODUCTION_SMTP_PRECHECK: FAIL`

Custom SMTP ON ve görünür host/port/name wiring'i doğrulandı. Buna rağmen exact masked
sender/username ile Resend dashboard verified/link-tracking durumu bağımsız
doğrulanamadığı için tam SMTP precheck PASS verilmedi.

`EMAIL_TEMPLATE_PRECHECK: PASS`

`READY_FOR_LIVE_EMAIL_ACCEPTANCE_AFTER_INTEGRATION: NO`

Canlı kabul öncesi zorunlu açıklar:

- localhost Site URL yerine owner-onaylı canonical HTTPS Site URL;
- final callback/client cutover entegrasyonu ve HTTPS web recovery allowlist'i;
- Resend link tracking ile masked sender/provider durumunun bağımsız doğrulanması;
- write yetkili ayrı canlı kabul penceresi ve disposable inbox.

`INTEGRATION_REQUIRED`
