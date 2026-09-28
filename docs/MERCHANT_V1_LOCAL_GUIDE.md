# Merchant V1 yerel geliştirme ve entegrasyon sınırı

## Sentetik önizleme

Backend, hesap veya ağ bağlantısı gerektirmez. Bütün değişiklikler bellektedir,
uygulama yeniden açılınca sıfırlanır. Üstte yerel önizleme işareti bulunur.

```text
flutter run -d chrome --target lib/main_merchant_preview.dart
flutter run --flavor merchantDevelopment --target lib/main_merchant_preview.dart
```

İkinci komut Android içindir. Paket kimliği
`com.esnaftavar.app.merchant.dev`, görünen adı `EsnaftaVar Esnaf Dev` olur;
Customer kurulumunun yerine geçmez. Merchant release paketlemesi kapalıdır.
Gerçek mağaza, şahıs, fiyat veya alışveriş kanıtı içermeyen örnek kayıtlar kullanılır.
Önizlemede QR akışını görmek için `merchant-v1-preview` test kodunu girin.

## Yerel Supabase adaptörü

`lib/main_merchant_development.dart`, mevcut Customer auth, notification ve QR
repository'leriyle ayrı Merchant composition root kurar. Global locator'ı değiştirmez.
`SUPABASE_DEVELOPMENT_URL` ve `SUPABASE_DEVELOPMENT_ANON_KEY` açıkça sağlanmalıdır.
Host yalnız localhost/127.0.0.1/IPv6 loopback olabilir; cloud Production ve
Development adresleri istemci kurulmadan reddedilir. Bu kısıt canlı uygulama
yetkisini yerel geliştirme yetkisinden ayırır.

Yerel backend'in mevcut shops, products, shop_products, profiles, QR ve
notifications sözleşmelerini sağlaması gerekir. Hesap rolü yerel yetkili test
kurulumundan gelir; uygulama rol veya başka mağaza sahipliği vermez. Bu görev
sunucuda fixture oluşturmaz veya migration çalıştırmaz.

İlk kurulumda onaylı merchant hesabıyla giriş yapılır; mağaza yoksa kurulum açılır.
Ürün ekleme ortak katalog kaydını mağazaya bağlar. Düzenleme yalnız mağaza fiyatı,
açıklaması, bulunabilirliği ve aktifliğini değiştirir. Pasife alma ve yeniden
aktifleştirme aynı listing kimliğini korur.

Backend cevabı alınmadan başarı gösterilmez. Aynı ürün tekrar eklenirse mevcut
kayıt otomatik değiştirilmez. Zaman aşımı/belirsiz yanıt sonrasında listeyi
yenileyerek mevcut durumu kontrol edin; uygulama arka planda tekrar yazmaz.

## Doğrulama

```text
flutter analyze --no-pub
flutter test --no-pub test/unit/merchant test/widget/merchant
flutter test --no-pub
flutter build web --no-pub --target lib/main_merchant_preview.dart --no-web-resources-cdn
flutter build apk --debug --no-pub --flavor merchantDevelopment --target lib/main_merchant_preview.dart
```

Unit testleri mock HTTP üzerinden gerçek Supabase adaptörünün sorgularını,
payload'larını, owner/role sınırlarını ve eski oturum yanıtlarını denetler.
Widget testleri sentetik repository ile ekran akışlarını ve hata durumlarını
doğrular. Golden görseller `test/widget/merchant/goldens/` altındadır. Bunlar gerçek
sunucu rollout'u veya fiziksel kamera kabulünün yerine geçmez.

## Integration Agent'a devredilen kapılar

- Main'e alma: bu task branch'in incelenmesi ve Customer frozen regresyonunun korunması.
- Remote Merchant aktivasyonu: katalog okuma yolu/canonical capability, gerçek
  merchant principal ve server rollout kanıtı. Sadece yerel test başarısı remote
  erişim veya Production write yetkisi sayılmaz.
- Mobile release: final Merchant identity/signing, ayrı callback sözleşmesi,
  parola kurtarma ve hesap yaşam döngüsü. Customer callback'i Merchant'a yönlendirilmez.
- Firebase/APNs ve mevcut push proposal'ı: ayrı yapılandırma ve deployment;
  ikinci bildirim sistemi veya istemci notification INSERT'i yoktur.
- İki cihazlı fiziksel QR, Trust & Engagement: kullanıcı kararı gereği sonraki faz.

Merchant onboarding burada yetkilendirilmiş mağaza sahibinin kurulumu anlamına
gelir. Self-service rol onayı, yeni master ürün yayınlama, adet stoku, hesap silme
ve ileri ticari modüller mevcut backend sözleşmesinin parçasıymış gibi sunulmaz.
Backend önerileri ve tam ekran envanteri `MERCHANT_V1_ARCHITECTURE.md` içindedir.
