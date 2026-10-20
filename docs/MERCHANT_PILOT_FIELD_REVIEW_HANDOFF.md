# J14 — Saha kabul raporu güvenilirliği

Başlangıç: `origin/main@7db5afd42693e3bf3d1653781c623ebbf61f025a`, J13 entegre.
Görev dalı: `agent/merchant-pilot-field-review`. Canonical §4.14 / slices J14.

## Düzeltilen sorun

Eski araçta gerçek cihazda kullanılmaması gereken sentetik APK çiftine 12 PASS
yazılabiliyor, Customer ve Merchant için aynı cihaz takma adı kabul ediliyordu.
`pilot_ready=false` korunuyordu; buna rağmen saha başarı sayısı yanıltıcıydı.
Ayrıca komut, FAIL içeren geçerli gözlem dosyasında da genel PASS mesajıyla
başarılı çıkıyordu. İlk açık, önceki gerçek sentetik çift üzerinde yeniden
üretildi; gerçek telefon veya sunucu kullanılmadı.

Artık sentetik çift yalnız boş OPEN formuyla incelenir. Gerçek cihaz adayı
gözlemleri rolüne uygun takma ad, geçerli UTC tarihi ve tam APK eşleşmesi ister.
Geçersiz takvim günleri ve JSON'da tekrar eden alanlar reddedilir.

Paket incelemesi; değişmemiş APK baytları yanında amaç/mod, temiz kaynak beyanı,
kapalı özellikler, katalog sözleşmesi, iki uygulamanın callback/kimlik/sürüm/imzası,
derlenmiş içerik inceleme kaydı ve hedefli test listesinin tutarlılığını denetler.
Dosya yönlendirmesi, eksik/tekrarlanan/kaçan kaynak yolu kabul edilmez.
Yerel hash kontrolü imzalı tasdik değildir; yeniden yazılmış tüm kanıtları veya
gerçek cihazda ne olduğunu bağımsız olarak kanıtlamaz.

FAIL içeren rapor `FIELD_BLOCKED` ve çıkış kodu 2; eksik rapor
`FIELD_INCOMPLETE` ve kod 3 verir. On iki bildirilmiş PASS yalnız
`FIELD_REPORTED_COMPLETE_REQUIRES_OWNER_REVIEW` olur. Kişi bilgisi rapora eklenmez;
rapor, tam giriş dosyasının SHA-256 özetiyle bağlanır ve üzerine yazılamaz.
[Saha yönergesi](MERCHANT_PILOT_FIELD_ACCEPTANCE.md) sonuçların kullanımını açıklar.

## Hazırlığa etkisi

[Katılım rehberi](MERCHANT_PILOT_INTAKE_GUIDE.md), eski kaynakta çalışması gereken
J9 komutu yerine J12'nin `prepare_current_pilot.mjs` yöntemini kullanır.
Bu araç mevcut ekran/repository kanıtlarıyla değişmemiş J9 sözleşmelerini birlikte
kontrol eder. Varsayılan hesap/kategori ve yayın formları eksik kalır; yazma SQL'i,
hesap, rol, ürün veya otomatik onay oluşturulmaz.

Gerçek esnaf ve ürün seçimi hâlâ bekleniyor. Eski kurtarma test hesabına bu
paketle esnaf yetkisi verilmez. Katılımcılar seçildiğinde ayrı somut teklifler
ve iki fiziksel cihaz oturumu hazırlanmalıdır.

## Kanıtların sınırı

Uygulama, Android, varlıklar, bağımlılıklar, veritabanı ve J7–J13 kanıt dosyaları
değişmedi. Yeni inceleme araçları `tool/pilot_device` kaynak listesine dahildir;
bu nedenle eski APK çiftinin güncel kaynak kontrolü beklenen şekilde reddedilir.
Eski J13 native kaydının geniş kaynak özeti de bu araçları içerir: kayıt kendi
sürümünde tarihsel kanıt olarak korunur, yeni sürümde güncelmiş gibi onaylanmaz.
J12 ekran/repository ve güncel katalog hazırlık kanıtlarının kapsamı değişmedi.

Eski gerçek APK baytları yalnız tarihsel bütünlük amacıyla kontrol edildi;
güncellik denetimini kapatan kütüphane seçeneği saha komutunda sunulmaz.
Yeni cihaz adayı, Integration sonrası temiz kaynakta mevcut build-pair yöntemiyle
yeniden üretilmelidir. Yeni APK derlemesi, telefon kurulumu veya fiziksel QR
denemesi bu teslimde yapılmış sayılmaz.

## Doğrulama ve Integration sınırı

- **86 Node testi PASS / 0 FAIL / 0 SKIP:** 63 çift paket/saha inceleme testi
  (35 yeni regresyon) ve mevcut 23 native/güncel hazırlık/ekran sözleşmesi testi.
  Güncel komut giriş noktası; eksik, başarısız, tamamı bildirilmiş, bozuk,
  eski ve üzerine yazılmak istenen gözlemlerle sınandı. Test APK baytları
  sentetik dosyalardır; bunlar APK derlemesi veya fiziksel kabul sayılmaz.
- Önceki gerçek ARM64 sentetik çiftin iki APK baytı, manifesti ve kaynak listesi
  tarihsel bütünlük denetiminden geçti. Çift kimliği
  `c7b089126ff9e3f5a5591178d1ebdb3950be9cb919a47d380c202071a4fdcecf`.
  Güncel kaynak kontrolünün reddi ve bu çifte fiziksel PASS yazılmasının reddi
  ayrıca doğrulandı. J13 native güncellik komutu da araç değişimini reddetti;
  bu beklenen tarihsel kaynak farkıdır, yeniden çalışmış native PASS değildir.
- J12'nin 15 ekran kanıtı güncel kaynakla eşleşti. Hesap/kategori ve yayın
  hazırlama komutlarının ikisi de çalıştı; sonuçları `INCOMPLETE_NO_MUTATION`,
  öneri listeleri boş, `remote_authorized=false` ve `distribution_ready=false`.
  Yerel çıktı dizinleri `.buildlog/pilot-current-review/field-review-cohort/`
  ve `field-review-publication/`; yalnız boş şablon ve salt okunur sorgu içerir.
- Üç değişen JavaScript dosyasının sözdizimi denetimi, diff kontrolü ve gizli
  veri/özel iletişim bilgisi taraması PASS. Uygulama/Android/bağımlılık/migration
  ve önceki kanıt dosyalarında değişiklik olmadığı Git karşılaştırmasıyla doğrulandı.
- **Flutter analyzer, Flutter testleri ve Android build yeniden çalıştırılmadı:**
  Dart/Flutter/Android kaynağı veya bağımlılık değişikliği yok. Önceki görevlerin
  2998 test sonucu bu görevde yeniden çalıştırılmış gibi sunulmaz.

Tekrar kontrolü:

```text
node --test tool/pilot_device/contract.test.mjs tool/merchant_acceptance/native_contract.test.mjs tool/merchant_acceptance/pilot_current_contract.test.mjs tool/merchant_acceptance/pilot_ui_contract.test.mjs
node tool/merchant_acceptance/verify_pilot_ui.mjs
node tool/merchant_acceptance/prepare_current_pilot.mjs cohort <yeni-ad>
node tool/merchant_acceptance/prepare_current_pilot.mjs publication <baska-yeni-ad>
```

Windows dosya yönlendirmesi testleri geçici dizinlerde bağlantı oluşturma yetkisi
gerektirir; bu testler atlanmaz. Ayrıntılı yerel test ve yeniden üretim kayıtları
görev çalışma alanının ignored `.buildlog/` dizinindedir.

Ortak inceleme alanları canonical/slices ve çift paketleme araçlarıdır.
Main merge/push yalnız Integration Agent'a aittir. Bu paket hosted Development
ve Production erişimi/yazması, migration uygulama, gönderim sağlayıcısı işlemi
veya dağıtım içermez. Donmuş ürün kararı değişikliği yoktur.
