# Firebase Development — teslim ve sonraki kurulum kapsamı

24 Ekim 2026. Kaynak: entegre `d8aa9099d7e0ff89146d19821d0f554e50bee422`.
Dal: `agent/merchant-firebase-development`. Main birleşimi Integration Agent'a aittir.
Durum: **yerel uygulama hazır; gerçek telefon teslimatı henüz doğrulanmadı**.

## Tamamlanan ve onay sınırı

Ürün sahibi yalnız Firebase proje oluşturma, koşulları kabul etme ve aşağıdaki iki
Android uygulamasını kaydetme işlemlerini onayladı. Bu işlemler Firebase ekranında
doğrulandı. Analytics ve Gemini seçilmedi; ücretli plan/Production açılmadı.

| Kayıt | Değer |
| --- | --- |
| Proje | `esnaftavar-development` / `1003286439273` |
| Customer Development | `com.esnaftavar.app.dev` |
| Customer uygulama kimliği | `1:1003286439273:android:9c71a17085ffd1ada2c9f8` |
| Merchant Pilot | `com.esnaftavar.app.merchant.pilot` |
| Merchant uygulama kimliği | `1:1003286439273:android:012b10fb018d88e1a2c9f8` |

Yetkili servis hesabı/anahtarı oluşturulmadı. Supabase'te yalnız şema metaverisi
okundu; SQL, worker, webhook, secret, tercih/cihaz kaydı veya gönderim uygulanmadı.
Tarayıcı indirmesi gerçek Android istemci yapılandırma dosyalarını yerelde teslim
etmedi; bu dosyalar elde edilmiş veya gerçek Firebase bağlantısı sınanmış sayılmaz.

## Uygulama ve sunucu

- Mevcut PushCoordinator, cihaz/tercih deposu, bildirim kutusu ve sohbet hedefleri
  kullanılır. İzin açık kullanıcı eylemidir. SDK otomatik kayıt kapalıdır. Çıkış
  sağlayıcı/cihaz temizliği bitmeden tamamlanmaz; belirsiz temizlik yeniden denenir.
- Customer host ve Merchant host bildirime dokunmayı kayıt istemeden izler.
  Kullanıcı, rol, oturum ve bildirim kaydı doğrulanır. İlk ekran çizimi dahil eski
  oturumun bildirimi yeni oturuma taşınamaz. Genel Android bildirim metni korunur.
- FlutterFire core `4.15.2`, messaging `16.7.0` sabittir. Mevcut minSdk23 ve token/
  HTTP v1 sözleşmesi korunur; yeni major SDK/preview AndroidConfigV2 geçişi yoktur.
  Analytics bağımlılığı eklenmedi. Yedi paket eklendi; eski bağımlılıklar yükseltilmedi.
- Bayrak `ESNAFTAVAR_DEVELOPMENT_PUSH_ENABLED` varsayılan OFF. Yalnız doğru Android
  flavor + Development backend + Firebase proje/uygulama kimlikleri kabul edilir.
  `ESNAFTAVAR_FIREBASE_CUSTOMER_CONFIG` ve `ESNAFTAVAR_FIREBASE_MERCHANT_CONFIG`
  ortam değişkenleri checkout dışındaki public `google-services.json` dosyalarına
  işaret eder. Servis anahtarı veya başka projenin dosyası derlemede reddedilir.
- Yeni worker yalnız yetkilendirilmiş, yeni oluşturulmuş chat bildirimi kimliğini
  işler; en fazla on açıkça seçilmiş test hesabı, başlangıç zamanı ve beş dakika
  tazelik sınırı vardır. Payload alıcı/rota/içerik iddiasına güvenmez. Pazarlama,
  geçmiş bildirim taraması ve otomatik tekrar gönderim yoktur. Sağlayıcı kabulü
  telefon ekranında gösterildiği anlamına gelmez.

## Development şema bulgusu ve ayrı öneri

Salt okunur denetimde notifications/auth.sessions vardır; push_devices,
notification_preferences, push_deliveries, push_dispatch_config ve QR session
helper yoktur. Service role notifications tablosunu doğrudan okuyamaz.

`supabase/proposals/development_push_transport_v1.sql` yalnız push parçalarını
değiştirilmemiş 0016/0029 kaynaklarından türetir. 0018'in mevcut canlı Auth oturumu
semantiğini ayrı helper adıyla kullanır. Banner/QR/ödül/kampanya açmaz. Bildirim
metni yerine yalnız id/user_id/type/created_at döndüren service-only RPC ekler;
doğrudan tablo SELECT yetkisini genişletmez. Gate OFF; işlem atomik, beklenmeyen
mevcut transport şemasında/replay'de reddedilir. Otomatik migration zincirine eklenmez.

LF SHA256: `ddbae47566b7bad06ce4e7aacfbba2c3db78697174a92ff56e3436e19c106e7d`.
Renderer: `node` ile `tool/engagement/development_push_sql.mjs`; tarihsel kaynaklar
girdi olarak okunur, yeniden yazılmaz. Hosted uygulama **onay bekliyor**.

## Doğrulama

- Tam Flutter: **3713 PASS / 0 FAIL / mevcut 6 SKIP**. Yeni atlama yok.
- `flutter analyze --no-pub`: **PASS**, sorun yok.
- Sağlayıcı/worker/dispatcher/SQL renderer: **44 PASS**; gerçek Edge entry smoke:
  **1 PASS**; Deno 2.5.6 `check --no-config`: **PASS**.
- Gerçek yerel PostgreSQL17: **28 grup PASS** (mevcut 27 transport/RLS/yarış grubu
  ve dar metadata RPC); banner korunması, gate OFF ve tekrar kurulum reddi geçti.
- Gradle: dış Firebase konfigürasyonu **9 PASS**, Merchant pilot sınırları
  **37 PASS**. Gerçek anahtar kullanılmadı.
- Customer Development ve Merchant Pilot ARM64 debug: bayrak kapalı çift ve
  bayrak açık/sentetik Firebase kaynaklı çift **PASS**. Paket içi uygulama kimliği,
  Firebase kaynakları, manifest ve imza denetlendi. İlk çiftte ayrıca mevcut
  cihaz uyumluluk testleri **135 PASS**. Bunlar dağıtıma uygun cihaz APK'sı değildir.
- Kanıtlar görev worktree'sinde `.buildlog/firebase-*`,
  `.buildlog/pilot-device/firebase-development-sdk` ve `firebase-enabled-final`.
  Önceden teslim edilen APK'lar ve Downloads dosyaları korunmuştur.

## Sonraki somut onay — henüz uygulanmadı

Integration PASS sonrasında yalnız Development için şu iki adım ayrı yetki ister:

1. Yukarıdaki hash ile sınanmış transport önerisini test Supabase projesine kurmak;
   yeni şema kontrolünden sonra uygulamak, gate'i başlangıçta OFF bırakmak.
2. Firebase projesinde yalnız gönderim için `dev-push-worker` servis hesabı ve
   `cloudmessaging.messages.create` izniyle sınırlı özel rol hazırlamak; bu hesaba
   ait tek anahtarı yalnız test Supabase Edge Secrets'a aktarmak. Genel Firebase
   Admin/Owner/Editor yetkisi verilmez. Anahtar sohbete, Flutter'a, Git'e, build
   loguna veya kanıt dosyasına girmez. Kullanıcı güvenli ekran üzerinden secret
   girişini tamamlar. Yeni ücretli plan/Production yetkisi bu kapsamda değildir.

Ardından worker'ın gerçek ortam bağlantısı ve yalnız mevcut iki test hesabı için
gönderim/trigger kapsamı somutlaştırılıp onaylanır. Bu pakette çalışan bir hosted
webhook bulunduğu iddia edilmez. Secret içeren düz SQL tetikleyicisi veya dump
hazırlanmaz; webhook için yalnız bildirim UUID'si ve server-secret yönetimi gerekir.
Edge dağıtımında gateway JWT kontrolü yerine worker'ın ayrı bearer doğrulaması
kullanılması ayrıca güvenlik kapsamına dahildir; başka fonksiyonun ayarı değişmez.

Minimum fiziksel kabul (sonraki güncel APK'larla):

1. İki yönde uygulama açık/arka planda/normal kapalıyken yeni mesaj bildirimi ve
   dokununca doğru uygulama/görüşme; özel mesaj metni kilit ekranına çıkmamalı.
2. İzin reddi veya hizmet bildirimi kapatıldığında gönderim sınırı ve yeniden açma.
3. Çıkış/hesap değişimi ve yeniden başlatmada token temizliği, güvenli yeniden
   bağlanma ve eski bildirimin özel içeriğe erişememesi.

Provider teslimatı, emekli cihaz kaydı saklama değerlendirmesi ve pilot açılışı
OPEN. Bu teslim gerçek telefon bildirimi kabulü veya pilot açılış onayı değildir.

Kaynaklar: [Firebase Flutter kurulumu](https://firebase.google.com/docs/cloud-messaging/flutter/get-started),
[mesaj alma](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages),
[FCM izinleri](https://docs.cloud.google.com/iam/docs/roles-permissions/firebasecloudmessaging),
[Supabase fonksiyon yetkilendirmesi](https://supabase.com/docs/guides/functions/auth),
[webhook secret sınırı](https://supabase.com/docs/guides/database/webhooks).

## TASK_RESULT

- Görev: Development Firebase kayıtları ve mevcut push altyapısına Android adaptörü.
- Tamamlanan: onaylı iki kayıt; yerel mobil/sunucu bağlantısı; SQL önerisi ve testler.
- Analyzer: PASS. Test/derleme: yukarıdaki kanıtlar PASS.
- Ortak alanlar: app bootstrap, DI/sign-out, PushCoordinator, TStore host,
  Android manifest/Gradle/MainActivity, pubspec/lock ve generated plugin kayıtları.
- Commit/Push: teslim mesajındaki kaynak commit esas alınır; main'e işlem yapılmaz.
- Production: NONE. Hosted DB write/migration/provider send: NONE.
- Açık kapılar: entegrasyon, ayrı test kurulum/anahtar onayı, gerçek istemci
  dosyaları, worker/trigger kurulumu ve üç fiziksel kabul maddesi.
