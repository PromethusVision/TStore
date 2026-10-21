# Merchant — birleşik pilot yerel kabulü (J16)

Durum: **LOCAL PASS — Integration Agent incelemesi bekleniyor. Pilot açılışı değildir.**

- Görev dalı: `agent/merchant-pilot-current-acceptance`
- Başlangıç main: `50f750f2e18debab64e38315f8a66ba097b6b87b`
- Canonical §4.18 ve implementation slice J16.

## Sorun ve çözüm

J12'nin eski kaynakla sınırlı kabulü, sonraki oturum düzeltmelerini kapsamaz.
Eski yolun güncel repository farklarını reddetmesi doğru davranıştır ve korunur.
Ayrı J16 profili, J9 kanıtını ve kurulu şemayı sabitleyerek altı entegre istemci
farkını kabul eder. Yedinci dar fark yalnız tarihsel test fixture düzeltmesidir.
Diğer bağlı sunucu/hazırlık kaynakları değişmemiştir. Eski kayıtlar yeniden yazılmadı.

Başlangıçtaki 142 Node testinde 128 PASS / 14 FAIL vardı. Bu 14 hata, eski olumlu
kanıt testlerinin güncel kaynakları kopyalamasından kaynaklanıyordu. Dört test
fixture'ı kendi immutable Git kaynaklarından, kayıtlı hash'ler doğrulanarak kurulur.
Hiçbir assertion zayıflatılmadı veya atlanmadı. Güncel kaynakla eski J12 yolunun
reddedildiği bağımsız testte ve gerçek CLI çağrısında tekrar doğrulandı.

## Gerçek yerel doğrulama

İki ayrı yeni fixture, gerçek Auth JWT'leri, PostgreSQL, PostgREST ve Storage kullandı.
Kurulu profil şeması aynen `d9607df877e9115eb811d984e561b4e7` olarak doğrulandı.

- Repository: orijinal **18/18** akış + **6/6** bağımsız veritabanı kontrolü.
- Ekran: orijinal 15 kontrol + gerçek Auth ile **3 yeni oturum kontrolü**, toplam
  **18/18** + **6/6** bağımsız veritabanı kontrolü.
- Token yenilemesi fiyat taslağını korur; aynı hesapta yeni oturum taslağı kapatır;
  yeni oturum eski taslak yerine sunucudaki 234,56 TL fiyatı yeniden yükler.
- Kaybolan iki PATCH yanıtı, tek yazma sayısı ve sunucudaki sonuçla doğrulanır.
- İki kayıt aynı **710 kaynak** manifestine bağlıdır; farklı fixture ve nonce şarttır.
  Kaynak özeti: `dc66cc7d667b107c9a9ca26314b4ad0dc3fa041e8c2b9c07f3418bb34ff3b529`.

Kayıtlar imzalı attestation değildir; yeniden üretilebilir yerel kapsam/freshness
kontrolüdür. Galeri yerel PNG sağlar, preferences bellek adaptörüdür. Gerçek fotoğraf
izinleri, disk kalıcılığı, push sağlayıcısı, e-posta veya fiziksel cihaz kabulü sayılmaz.
Repository provası bir sentetik legacy QR satın alması içerir; gerçek satın alma kanıtı
ve fiziksel iki cihaz kabulü olarak kullanılmaz.

## Yerel hazırlık

Yeni giriş noktası: `prepare_integrated_pilot.mjs`. Eski J7/J9/J12 girişleri korunur.
Kategori/hesap ve katalog yayını için iki boş çıktı gerçek komutlarla üretildi:
`.buildlog/pilot-integrated-review/integrated-empty-cohort` ve
`.buildlog/pilot-integrated-review/integrated-empty-publication`.
İkisi de `INCOMPLETE_NO_MUTATION`; yazma SQL'i, hesap oluşturma veya apply izni yoktur.
Tam inceleme girdileri, mevcut SQL'i byte-for-byte kullanır. Sahiplik, kategori,
şema/durum, fiyat, atomiklik ve işlem-token kontrolleri değişmez.

## Tekrar doğrulama

Önce servisler kapalıyken `node --test tool/merchant_acceptance/*.test.mjs` çalıştırın
(HTTP güvenlik testi aynı yerel portu kullanır). Her gerçek servis provası için
`local.mjs prepare` ile yeni fixture ve `local.mjs start <dizin>` kullanın.
`pilot_integrated.mjs <dizin> <Flutter-SDK> repositories` ve mod argümanı olmadan
`pilot_integrated.mjs <başka-dizin> <Flutter-SDK>` iki ayrı fixture gerektirir.
Her birini `local.mjs stop <dizin>` ile kapatın. Mevcut kanıt çıktıları üzerine
çalıştırma reddedilir; bağımsız tekrar için yalnız inceleme worktree'sinde mevcut
iki J16 kaydını özel kanıt klasörüne taşıyın, yeniden koşun ve sonuçları karşılaştırın.
Tarihsel kayıtları/hash'leri değiştirmeyin; dolu fixture'ı sıfırlamayın.

## Teslim kontrolleri

- Node **162 PASS / 0 FAIL / 0 SKIP**; 20 yeni güvenlik/kanıt testi.
- Tam Flutter **3604 PASS / 0 FAIL / aynı 6 koşullu SKIP**.
- `flutter analyze --no-pub`: PASS, sıfır sorun.
- Runtime/dependency/SQL değişmedi; yeni APK derlenmedi. Teslim edilmiş gerçek
  Customer/Merchant APK çifti ve son üç derleme provası SHA-256 ile değişmemiş doğrulandı.
- Göreve ait iki servis kapalı; volume'ler korundu; yalnız bu görevin iki boş ağı kaldırıldı.
  Geçici test kimlik dosyaları temizlendi. Önceki görev verilerine dokunulmadı.
- `git diff --check`, kapsam ve eklenen satır/yeni dosya secret/PII taraması PASS.
- Main merge/push yapılmadı. Integration Agent aynı kaynak manifestini ve eski
  kaynak yolunun reddini doğrulamalı; birleştirilen runtime değişirse J16 kanıtı eskir.

## Açık kapılar

1. Gerçek pilot esnaflar, ürünler ve kategori/hesap/yayın için ayrı yetkili hazırlık.
2. Uygun cihaz paketiyle gerçek telefon/iki cihaz QR ve gerekli sağlayıcı kabulleri.
3. Dağıtım, destek/geri dönüş planı ve Product Owner pilot açılış kararı.

Production ve hosted Development erişimi/yazması: **NONE**. Uzak migration ve
sağlayıcı gönderimi: **NONE**. Bu paket mevcut ürün kurallarını veya özellik
bayraklarını değiştirmez; Customer V1 düzenleri korunur.
