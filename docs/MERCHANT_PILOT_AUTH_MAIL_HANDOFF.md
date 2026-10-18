# J11 — Gerçek yerel Auth/e-posta provası ve mevcut sağlayıcı incelemesi

Taban: `origin/main@3da793c60b7bcd6526360c8fdbb8314ae1ab5c71` (J10 entegrasyonu).
Dal: `agent/merchant-pilot-auth-mail`. Canonical §4.15 / slices J11.

## Tamamlanan kapsam

Mevcut Merchant kurtarma sınıfları gerçek yerel GoTrue, SMTP yakalama ve PostgREST
ile çalıştırıldı. Resend veya başka bir dış sağlayıcıya test e-postası gönderilmedi.
J9'un mevcut kurulu public şema profili aynen üretildi; hash
`d9607df877e9115eb811d984e561b4e7` değişmedi. Geçmiş migration/kanıt kaynakları
korundu. Katalog boş ve genel onay kapalı kaldı.

Gerçek servis kanıtı, aşağıdaki 16 kontrolü içerir:

1. Türkçe şablon → SMTP kutusu → exact Merchant callback → tek PKCE exchange.
2. Yeni parola kalıcı; eski parola reddedilir, yeni normal oturum aynı esnaf/dükkânı açar.
3. Kullanılmış kurtarma kodu yeni oturum oluşturmaz.
4. Bilinmeyen adres aynı genel mesajı alır; posta kutusuna ileti düşmez.
5. Customer callback Merchant tarafından işlenmez; Customer SDK onu doğrular.
6. Başka cihazı temsil eden boş PKCE deposuyla oturum kurulamaz.
7. Yanlış PKCE doğrulayıcısı gerçek Auth tarafından reddedilir.
8. Yeni istek eski e-postayı geçersiz kılar. Sağlayıcının hata fragment'i kabul
   edilen callback değildir; mevcut bekleme akışı kapalı kalır, token değişimi yapılmaz.
9. Belirsiz/tekrarlı parametreli callback parola güncellemez.
10. Gecikmiş gerçek kurtarma yanıtı yeni hesaba geçişi geri alamaz.
11. Gecikmiş gerçek parola yanıtı başka hesabın oturumunu bozamaz.
12. Sunucuda kaydedilen ama yanıtı kaybolan güncelleme otomatik tekrarlanmaz;
    yeni normal giriş gerçek sonucu doğrular.
13. Kalıcı pending bayrağıyla yeniden oluşturulan controller çalışma alanını kapatır.
14. Customer kurtarması merchant rolü/dükkân yetkisi kazandırmaz.
15. Confirmation açık yerel profilde kayıt doğrulama ister; Türkçe şablon ve
    mevcut Customer confirmation çözücüsü gerçek bağlantıyla çalışır.
16. Merchant callback'ine gelen signup kodu recovery yetkisi gibi kullanılamaz.

Yanıt gecikmesi/kaybı testlerinde gerçek HTTP yanıtı alındıktan sonra istemciye
teslim geciktirilir veya kesilir; sahte Auth yanıtı kullanılmaz. Preference ve PKCE
depocuğu bellektedir. Fiziksel uygulama kapanması, Android link yönlendirmesi ve
gerçek posta sağlayıcısındaki teslimat bu testin kanıtı değildir.

## Araçlar ve tekrar üretim

Mevcut Node, Flutter SDK, Docker ve `tool/merchant_acceptance/node_modules` gerekir.
Yeni uygulama dependency'si yoktur. Resmi Mailpit/BusyBox imajları digest ile
sabitlenmiştir; isim/etiket/ağ/port/privilege/mount denetimi başka konteynerin
yeniden yapılandırılmasını reddeder. Yalnız boş ve sahipliği doğrulanan yerel
Auth konteyneri yeniden oluşturulur. SMTP özel Docker ağında; posta kutusu API'si
yalnız `127.0.0.1:55434`, Auth/API `127.0.0.1:55431`, DB `127.0.0.1:55432`.

```text
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <üretilen-yeni-yerel-dizin>
node tool/merchant_acceptance/auth_mail.mjs <aynı-dizin> <Flutter-SDK>
node tool/merchant_acceptance/local.mjs stop <aynı-dizin>
node --test tool/merchant_acceptance/auth_mail_contract.test.mjs
node tool/merchant_acceptance/auth_mail_contract.mjs
```

Mailpit ve BusyBox digest'leri `auth_mail_local.mjs` içindedir; yoksa resmi registry'den
tam bu digest'ler çekilmelidir. Sabit GoTrue sürümü değişirse yeniden inceleme gerekir.
Başarısız fixture sıfırlanmaz/yeniden kullanılmaz; yeni fixture hazırlanır.
Varsayılan Docker ağ havuzu doluysa yalnız bu görevin sahipliği doğrulanmış boş ağı
temizlenebilir; genel `prune` kullanılmaz. Görev sonunda tüm görev servisleri durduruldu.

Sentetik adresler `.invalid`, parolalar rastgele ve özel ignored fixture içindedir.
Bu dosya runner sonunda silinir; SMTP kutusu/container kaldırılır. Yerel DB verisi
korunur. Hata logları ignored özel alandadır; ham loglar paylaşılmaz. Resend API
anahtarı bu araçların girdisi değildir. Yeni kanıt
`docs/data/merchant_pilot_auth_mail_validation.json` içinde yalnız kaynak özetleri,
servis kimliği ve kontrol adları vardır; gerçek/sentetik credential içermez.

Kanıt, çalışma öncesi/sonrası aynı kaynak özetini ister. Offline doğrulayıcı
kaynak veya şablon değişirse reddeder. Hash bir izin/imza değildir ve insan
onayı, gerçek teslimat ya da güncel uzaktaki durum yerine geçmez.

## Sonuç ve açık kapılar

- 16 gerçek yerel istemci kontrolü PASS; public şema, roller ve kapalı katalog korunuyor.
- 136 mevcut Merchant/Customer Auth unit/widget regresyonu PASS.
- 12 Node sahiplik/callback/şablon güvenlik testi PASS.
- `flutter analyze --no-pub`: PASS, sorun yok.
- Her iki Türkçe HTML adayı yerel tarayıcıda okunurluk/taşma açısından incelendi;
  gerçek Gmail/Outlook mobil e-posta görünümü ve teslimat kabulü yapılmadı.
- Uygulama/Android/dependency/migration değişmedi; APK yeniden üretilmedi. J10
  derleme kanıtı tarihsel olarak korunur; yeni fiziksel dağıtım iddiası yoktur.
- Salt okunur Resend/DNS/Development incelemesi:
  [bulgular ve ayrı onay sınırları](MERCHANT_PILOT_EXISTING_EMAIL_AUDIT.md).

Yeni HTML dosyaları **inceleme adayıdır**, hosted şablon kurulumu değildir. Mevcut
Resend hizmeti korunur; yeni hesap veya servis yok. Production Supabase erişimi,
uzak yazma, migration apply, gerçek hesap/posta, imzalı dağıtım ve fiziksel QR yok.
SMTP/credential binding, confirmation/fallback/template değişikliği ve gerçek
gönderim açık onay bekler. Tam pilot kabulü hâlâ **OPEN**.

Integration Agent yalnız bu dalın yerel kaynak/kanıt/dokümantasyonunu inceler ve
birleştirir; hiçbir hosted SQL, SMTP, DNS, mail/send veya anahtar işlemi yapmaz.
Ortak dosyalar yalnız canonical, implementation slices ve pilot approval packet'tir.
