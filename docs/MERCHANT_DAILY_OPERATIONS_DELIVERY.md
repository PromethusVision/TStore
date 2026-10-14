# Merchant V1 — günlük işletim paneli

Product Owner onayı: 2026-10-14, günlük işletim paneli önerisine “uygulamaya geç”.
Taban: `ea842b7b` (Slice A birleştirilmiş `origin/main`).
Görev dalı: `agent/merchant-daily-operations`.

## Ürün kapsamı ve karar kaydı

Canonical §4.1 ve implementation slices A follow-through bölümü bu onayı kaydeder.
Mevcut Merchant görsel yönü, beş sekme, Customer arayüzü ve ticari kararlar korunur.
Sıradaki yeni temel modül B'dir; bu teslim B–J uygulaması veya aktivasyonu değildir.

- Özetten doğrudan katalog ürünü ekleme; mevcut ürün/fiyat, QR ve profil erişimi.
- Gerçek toplam/var/yok/pasif ürün sayıları. Sayıların ürün çeşidi olduğu, adet
  stoku tutulmadığı açıklanır. Ciro, kâr veya reklam getirisi üretilmez.
- İnceleniyor/onaylandı/reddedildi başvuru toplamları ve mevcut başvuru ekranı.
  Bunlar okunmamış karar sayısı veya tamamlanacak iş sayısı değildir. Onaylı ürün
  ayrıca mağazaya eklenir; yeni ürün materialization ve operator onayı kapalı kalır.
- Yarım kalan fotoğraflar ürüne göre gruplanır; ilk üç ürün özetten açılır. Tüm
  kurtarma listesi 20 ürünlük sayfalarla gelir. Mevcut fotoğraf ekranı yüklemeyi
  tamamlama veya mantıksal kaldırma yapar; dönüşte liste ve özet yenilenir.
- Başvurular artık ilk 100 kayıtla kesilmez; aynı sahiplik ve kararlı sıralamayla
  sonraki 100 kayıt istenebilir. Yinelenen satırlar kimliğe göre birleştirilir.
- Son üç uygun bildirim ve bildirim merkezi tek `NotificationsCubit` kullanır.
  Aynı repository/Realtime, hesap/rol filtreleri ve okundu durumu korunur.
- Özet/ürün sekmesine dönüş, düzenleme ve uygulamaya dönüşte yeni okuma yapılır.
  Eski yanıt yeni okumayı ezmez; hesap çıkışı özel ekranları kaldırır. Yüklenemeyen
  bölüm sıfır sayı gibi sunulmaz; temel ürün işlemleri erişilebilir kalır.
- Önceki kaydın başarı mesajı yeni düzenleme ekranının düğmelerini örtmez.

## Mimari ve deployment sınırı

`MerchantOperationsRepository` yalnız işlem özetini okuyan ayrı capability'dir.
MerchantServices ve yalnız Merchant development composition root'a bağlanır.
Eski MerchantRepository, Customer bootstrap, global DI/theme/navigation,
pubspec/lockfile, eski migration'lar ve notification proposal'ı değişmez.

Yeni migration: `20261014001700_0017_merchant_daily_operations.sql`.
Yeni tablo, veri backfill'i, Storage politikası veya yazma yetkisi içermez.
Önkoşul Slice A 0016'dır. Tek RPC:

```text
merchant_operations_read_v1(p_shop_id uuid, p_offset int=0, p_limit int=20)
```

Server mevcut `_catalog_own_shop_v1` ile authenticated rol, aktif mağaza ve exact
owner kontrolünü her okumada yapar. NULL yetki sonucu da reddedilir. Sabit
search_path ve açık revoke/grant; yalnız authenticated execution. Anon, yabancı
mağaza, customer rolü, askıya alınmış mağaza ve service-role çağrısı reddedilir.

Başvuru toplamları tüm kayıtlar üzerinden tek SQL snapshot'ında hesaplanır.
Pending fotoğraflar listing bazında gruplanır, en eski yükleme/UUID sırasıyla
sayfalanır; limit 1–50 arasıdır. Yalnız listing ID, ürün adı ve pending fotoğraf
sayısı döner. Storage yolu, müşteri bilgisi ve inceleme notu summary'ye taşınmaz.
Pasif listing'in pending yüklemesi sahibi tarafından temizlenebilir.

RPC henüz kurulu değilse ek özet bölümü bunu açıkça bildirir; ürün özeti mevcut
sözleşmeyle çalışır. Yetki/ağ hatası sıfır veya başarılı fallback sayılmaz.
Rollback için önceki Merchant istemcisi kullanılabilir; ek read-only fonksiyon
eski istemciyi etkilemez. Fonksiyon kaldırma/revoke işlemi ancak ayrıca onaylı
deployment planında ele alınır. Generic remote db push çalıştırılmadı.

## Doğrulama kanıtı

| Kontrol | Sonuç |
|---|---|
| Hedefli Merchant + media + hero + migration testleri | 103 PASS |
| Tam Flutter paketi | 2330 PASS, mevcut 6 SKIP |
| Analyzer | 0 sorun |
| Yeni read-only RPC ephemeral PostgreSQL kontrolleri | 9 PASS |
| Mevcut Slice A SQL regresyonu | 26 PASS |
| 320/390/430 px, %130 metin; özet + takip alanı | 5 yeni golden, görsel inceleme PASS |
| Merchant development Android debug APK | PASS; paket kimliği ayrıca doğrulandı |

APK: `build/app/outputs/flutter-apk/app-merchantdevelopment-debug.apk`.
Paket: `com.esnaftavar.app.merchant.dev`, sürüm `1.0.0+5`.
SHA-256: `C34A01E1D7B409CB79A780D0C6D734B7A59329205F9358D67893EE7435B008DD`.
Derleme mevcut Windows C:/E: Kotlin incremental cache hatalarından sonra fallback
ile 250,9 saniyede tamamlandı; çıkış kodu 0. Bu debug compile kanıtıdır; release
imzalama, cihaz kurulumu veya çalışan gerçek backend oturumu değildir.

SQL testleri PGlite 0.5.5 / PostgreSQL 18.3 üzerinde sentetik, geçici verilerle
çalışır. Mevcut katalog fixture'ı ortak yardımcıya ayrıldı; 0001–0011 ve 0016'nın
aynı SQL'i kullanılır. Yeni 0017 ayrıca uygulanır. 105 başvuru ve 23 pending listing
ile toplamlar, sayfalama, sahiplik, rol iptali, askıya alma, publish/retire sonrası
özet ve Customer görüntü uygunluğu doğrulanır. Bu test gerçek Supabase gateway
veya Storage hizmeti çalıştırdığı anlamına gelmez.

`merchant_customer_journey_test.dart` gerçek Dart Supabase adaptörlerini durum
tutan sentetik HTTP yanıtlarıyla sınar: katalog → listing ekleme/fiyat değişimi →
fotoğraf upload/publish → yeni istemcilerden yeniden okuma → Customer hero kaynağı
→ retire sonrası placeholder yolu. Yeni istemci kontrolü gerçek cihaz/app process
yeniden başlatma kabulü değildir. Widget testinde de ekran yeniden kurulur ve
kayıtlar repository'den yeniden okunur; cihazda disk/auth kalıcılığı iddia edilmez.

## Açık ortam kabulü

Kurulu Docker Desktop başlatılmaya çalışıldı; Linux engine açılmadı. Yerel logdaki
sebep `sailor-ingest.sock` dosyasına erişilememesi ve başlangıcın durmasıdır.
Normal durdurma komutu da başarısız oldu; takılan yalnız bu görev CLI helper'ı
sonlandırıldı. Factory reset, Docker verisi/ayar silme veya WSL değişikliği yapılmadı.

Bu nedenle gerçek yerel Supabase Storage upload/publish/read ve fiziksel cihaz
galerisi kabulü **OPEN / ORTAM ENGELLİ** durumundadır. Sentetik ve SQL başarısı bu
kapıyı kapatmaz. Ortam düzeldiğinde kalan kabul:

1. İzole yerel Supabase'de onaylı test mağazasıyla ürün/fiyat/bulunabilirlik ve
   fotoğraf yazımı; yeni oturumdan tekrar okuma ve Customer görsel eşleşmesi.
2. Gerçek cihaz galerisinde seçim/iptal, yükleme hatası ve uygulama yeniden açma.

Production/Development cloud erişimi, remote migration apply, gerçek merchant
provision, release signing, Firebase/APNs veya iki cihazlı QR kabulü yapılmadı.
Main merge Integration Agent'a aittir.

## Tekrarlanabilir yerel kontroller

```text
flutter analyze --no-pub
flutter test --no-pub
node tool/catalog_media/schema.test.mjs <local-pglite-package-directory>
node tool/merchant_operations/schema.test.mjs <local-pglite-package-directory>
```

Android development compile, loopback URL ve credential olmayan sentetik değerle
yapılır; bu değerle gerçek backend oturumu açılamaz. Kotlin incremental cache
ayarı gerekiyorsa yalnız derleme işleminin ortamında kapatılır; global Gradle
ve dependency dosyası değiştirilmez.
