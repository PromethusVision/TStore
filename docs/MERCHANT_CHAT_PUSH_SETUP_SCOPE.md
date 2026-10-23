# Telefon mesaj bildirimi — sıradaki Development kurulum kapsamı

Durum: **HAZIRLIK / UYGULANMADI**. Bu belge kurulum veya gönderim onayı değildir.
Production kapsam dışıdır. Esnaf mesaj ekranının çalışması, telefon bildirimlerinin
çalıştığı anlamına gelmez. Kullanıcı mevcut bir Firebase kurulumu hatırlamıyor.

## Mevcut durum

- Customer ve Merchant aynı mesaj kayıtlarını, sohbet özetlerini ve bildirim
  kayıtlarını kullanıyor. Mesaj eklenince mevcut veritabanı tetikleyicisi bildirim
  kaydını oluşturuyor; istemci ikinci bir bildirim kaydı üretmemeli.
- Merchant mesaj girişleri ve doğrulanmış bildirimin mevcut görüşmeyi açması
  `agent/merchant-chat-entry-push` paketindedir; gerçek sağlayıcı gönderimi değildir.
- `UnconfiguredMobilePushProvider` gerçek cihaz tokenı üretmez veya izin istemez.
- `PushCoordinator`, cihaz/tercih sözleşmeleri ve `tool/engagement/push_delivery.mjs`
  vardır. Gerçek FCM mobil adaptörü, sunucu sağlayıcısı ve güvenilir çalışan henüz
  kurulmamıştır. `0016_engagement_foundation` ve `0029_push_dispatch_i0` ayrı
  önerilerdir; bunların Development'ta kurulu olduğu varsayılmaz.

## Somut sonraki paket

1. Ürün sahibinin kontrolündeki Firebase hesabında mevcut proje olup olmadığını
   incele. Varsa yeniden kullan; yoksa yeni proje açılmasını ayrı somut onaya sun.
   İlk hedef yalnız mevcut Android Development kimlikleri:
   `com.esnaftavar.app.dev` ve `com.esnaftavar.app.merchant.pilot`.
   Production/store kimlikleri, iOS/APNs ve ücretli hizmet açılması kapsam dışı.
2. Bu uygulamalara ait gözden geçirilmiş public istemci yapılandırmalarıyla mevcut
   `MobilePushProvider` portuna FCM adaptörü bağla. İzin kullanıcı eylemiyle istenir;
   reddetme, token yenilenmesi, token silme ve oturum değişimi doğrulanır. Sunucu
   anahtarı mobil dosyalara veya Git'e girmez. Oturum/tercih temizliği korunur.
3. Yalnız Development şemasını yetkili salt okunur incelemeyle karşılaştır. Gerekli
   cihaz/tercih/teslimat önerilerini birebir kaynak ve yerel prova kanıtıyla kurulum
   onayına sun. Kör migration push, geçmiş migration değişikliği veya başka paket
   aktivasyonu yapılmaz. Onaydan önce sunucuda kayıt veya ayar değiştirilmez.
4. Mevcut bildirim kimliğini alan, yalnız sunucunun çalıştırabildiği FCM gönderim
   adaptörünü ve görev çalıştırıcısını hazırla. Mevcut atomik claim/begin/finish,
   canlı oturum, hizmet bildirimi tercihi ve tekrar gönderim sınırları korunur.
   Belirsiz teslim otomatik yeniden gönderilmez. Pazarlama kapalı kalır.
   Kimlik bilgileri yalnız onaylı sunucu secret yönetiminde tutulur; sohbetten
   istenmez, yerel kanıt veya loglara yazılmaz.
5. Yalnız mevcut onaylı test hesapları/cihazları için sınırlı gönderim kapsamı iste.
   Android uygulama açık, arka planda ve kapalı durumlarda; izin reddi, çift dokunma,
   çıkış ve hesap değişimiyle dene. Bildirim doğru uygulamayı ve yetkili görüşmeyi
   açmalı. Sağlayıcının kabulü ile telefon ekranında görünmesi ayrı kanıttır.

## Pilot kararı

Bu iş pilot öncesinde yapılmalıdır: esnafın uygulamayı açık tutmadan yeni mesajdan
haberdar olması günlük kullanım için önemlidir. Mevcut canonical karar uyarınca
kilit ekranında mesajın özel içeriği yerine genel bildirim gösterilir. İçerik
önizlemesi istenirse önce gizlilik/tercih kuralı ayrıca karara bağlanır.

Firebase kaynakları (23 Ekim 2026 tarihinde kontrol edildi):
[Flutter kurulumu](https://firebase.google.com/docs/cloud-messaging/flutter/get-started),
[mesaj alma ve bildirime dokunma](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages),
[Android bildirim izni](https://firebase.google.com/docs/cloud-messaging/android/get-started).
Android'de kullanıcı uygulamayı ayarlardan zorla durdurursa yeniden açması gerekir;
izin ve işletim sistemi koşulları nedeniyle mutlak teslim garantisi verilmez.
