# Development Merchant e-posta ve parola kurtarma kabulü

Tarih: **18 Ekim 2026** (Europe/Istanbul). Sonuç: **tek test hesabıyla Merchant
kurtarma yolu PASS; tam pilot açılışı OPEN**. Canonical §4.15 / J11 takip kaydı.

## Yetki ve uygulanan kapsam

J11 Integration sonucu PASS ve `origin/main@f13791e426ae1eef7a5aa6f1ce14fff703be8084`
sonrasında Product Owner ayrı ayrı şu işlemleri onayladı:

- Mevcut Resend hesabının yalnız Development `tnipyxnvhgelwdpykyez` projesine
  bağlanması; yeni e-posta hizmeti veya sağlayıcı hesabı açılmaması.
- Development'a özel, yalnız `auth.esnaftavar.com` alan adı için gönderim yetkili
  anahtar hazırlanması. Oluşturma/kopyalama/gizli alan girişi/kaydı kullanıcı
  resmi Resend ve Supabase ekranlarında yaptı. Ajan anahtar değerini okumadı.
- SMTP açılırken Supabase'in otomatik uyguladığı **30 e-posta/saat** sınırı.
- Kontrolündeki posta kutusuyla tek, e-postası onaylı test hesabı oluşturulması.
  Parolayı kullanıcı resmi Supabase ekranında girdi. Esnaf rolü, dükkân veya
  ürün hazırlığı bu onaya dahil değildi ve yapılmadı.
- Android'de e-posta teslimatı ve parola kurtarma denemesi. Yeni parola kullanıcı
  tarafından telefondaki uygulamada belirlendi; sohbete veya dosyaya alınmadı.

Uygulanan SMTP: `smtp.resend.com`, port `465`, kullanıcı `resend`, gönderen adı
`EsnaftaVar`, gönderen adresi `noreply@auth.esnaftavar.com`. Custom SMTP ON ve gizli
parolanın saklandığı sayfa yenilenerek doğrulandı. Saatlik 30 ve mevcut kullanıcı
başına 60 saniye aralığı okundu. Yeni anahtarın yalnız gönderim yetkisi ve alan adı
sınırı Resend metadata ekranından doğrulandı; Production anahtarı değiştirilmedi.

Confirm email OFF; mevcut dört callback, `http://localhost:3000` fallback, Auth
hooks, e-posta şablonları ve ortak DNS/TLS/takip ayarları değiştirilmedi. Kayıt
doğrulama e-postasının gönderimi bu testte sınanmadı. Production Supabase erişimi,
Production yazması, migration uygulaması, anahtar rotasyonu veya yeni esnaf yetkisi yok.

## Android adayı ve teknik kanıt

Temiz, entegre edilmiş kaynak: `7e6037d66b1818666f0e94f87c9405f5bfbcf104`.
Uygulama/Android/varlık/bağımlılık/paketleme kaynakları entegrasyon commit'i
`f13791e4` ile aynı olduğu kontrol edildi; uygulama kodu değiştirilmedi.

| Alan | Değer |
|---|---|
| Üretim amacı | Gerçek Development cihaz adayı; sentetik derleme provası değil |
| Mod / platform | Debug / Android ARM64; dağıtım/release kabulü değil |
| Merchant paket kimliği | `com.esnaftavar.app.merchant.pilot` |
| Telefonda görünen ad | EsnaftaVar Esnaf Pilot |
| Sürüm | `1.0.0 (5)` |
| APK boyutu | 143002799 bayt |
| APK SHA-256 | `6c38046b102c0f40a99b4cb66f3ecb96a981fd91ae873634eb3e1d91ee99668a` |
| Kaynak özeti | `9bb49af6b52fa76ec071d47eee9073f061cc7f3a5c0672458ecd37ad330f3cae` |
| Hedefli uyumluluk testleri | 135 PASS / 0 FAIL / 0 SKIP |
| APK ve kaynak incelemesi | Her iki adayda PASS; yalnız Merchant cihaz kabulü bildirildi |

Mevcut `tool/pilot_device` araçlarıyla aynı kaynaktan Customer ve Merchant adayları
hazırlandı. Gerçek, herkese açık **Supabase istemci anahtarı** kullanıldı; bu bir
Resend gönderim veya sunucu/service-role anahtarı değildir. Girdi ve geçici
yapılandırmalar derleme sonrasında kaldırıldı; anahtar değerleri Git'e alınmadı.
Development Auth settings salt okunur istemci isteği HTTP 200 verdi. Bu istek
oturum açmadı veya e-posta göndermedi.

Paket kanıtları ignored `.buildlog/pilot-device/development-mail-20261018/`
altındadır. Kullanıcıya verilen İndirilenler kopyasının SHA-256'sı da doğrulandı.
Cihazdaki kurulumun bayt özeti bağımsız olarak okunmadı; kurulum ve telefon akışı
Product Owner'ın sağlanan APK üzerinden yaptığı deneme beyanıdır.

## Kabul gözlemleri ve sınırı

| Kontrol | Sonuç / kanıt kaynağı |
|---|---|
| SMTP ayarlarının kalıcılığı ve sınırlar | PASS — ajan resmi Development UI'ından yeniden okudu |
| Gerçek kurtarma iletisinin teslimi | PASS — Resend'de Development anahtarı filtresi altında **Delivered**; alıcı test posta kutusuyla eşleşti |
| Android kurulumu ve Şifremi unuttum isteği | PASS — Product Owner bildirimi |
| Posta kutusuna ulaşma ve bağlantıdan parola yenileme | PASS — Product Owner bildirimi |
| Yenileme sonrası giriş/rol kapısı | PASS — Product Owner beklenen esnaf-yetkisi-yok ekranına ulaştığını bildirdi |

Esnaf yetkisi uyarısı bu hesap için beklenen davranıştır; kaldırılması için rol
verilmedi. Sağlayıcı kaydı teslimatı destekler; telefon ekranının veya yeni
parolanın ajan tarafından bağımsız doğrulanması anlamına gelmez. Eski parola ile
giriş, bağlantı tekrarı, yanlış cihaz ve süreç kapanması gibi olumsuz fiziksel
senaryolar bu bildirimden PASS çıkarılarak kapatılmaz.

Ajan yalnız gönderim listesindeki metadata'yı okudu; e-posta gövdesi, kurtarma
bağlantısı veya token açılmadı. Sağlayıcı ekran görüntüsü özel alanda tutuldu;
SHA-256: `258c23fae9c12bfff6c3c657e4a75c56f19c8b488d685f1001a64d2aa48d153f`.
Gerçek alıcı adresi, Auth kullanıcı kimliği, parola, anahtar, token, e-posta/cihaz
görüntüleri veya sağlayıcı mesaj kimliği Git'e eklenmez.

## Açık kalan işler ve Integration sınırı

Customer/registration e-postası, diğer fiziksel hata senaryoları, gerçek esnaf ve
dükkân hazırlığı, katalog/ürün seçimi, sahiplik kabulü, iki cihazlı QR, Firebase/APNs,
imzalı dağıtım ve nihai pilot açılışı ayrı kalır. Yeni hosted işlem, esnaf rolü veya
dükkân ataması bu kayıttan yetki kazanmaz; somut kapsamla ayrıca onay gerekir.

Bu takip değişikliği yalnız dokümantasyondur. Flutter/analyzer veya veritabanı
paketi yeniden çalıştırılmış gibi raporlanmaz. Integration Agent yalnız belge
dalını inceler/birleştirir; SMTP kurulumu, hesap açılışı veya e-posta gönderimini
tekrarlamaz. Main merge bu Merchant Agent tarafından yapılmaz.
