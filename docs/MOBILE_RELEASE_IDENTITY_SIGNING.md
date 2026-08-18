# Mobile Release Identity and Signing

Bu belge Android ve iOS mağaza release kimliği/imza hazırlığının kaynak
sözleşmesini kaydeder. Gerçek keystore, parola, Apple private key, certificate veya
provisioning profile içermez.

## Final kimlik kararı

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / PLATFORM WIRING COMPLETE`

Product owner EsnaftaVar V1.0 final application identifier'ını
`com.esnaftavar.app` olarak kesinleştirdi. Platform kaynaklarındaki önceki Flutter
demo kimlikleri yalnız bu geçişin tarihsel kaydıdır; runtime/config değeri değildir:

| Platform | Önceki demo değer | Final canonical değer |
| --- | --- | --- |
| Android namespace | `com.example.t_store` | `com.esnaftavar.app` |
| Android production applicationId | `com.example.t_store` | `com.esnaftavar.app` |
| Android development applicationId | `com.example.t_store.dev` | `com.esnaftavar.app.dev` |
| iOS Runner Debug/Profile/Release | `com.example.tStore` | `com.esnaftavar.app` |
| iOS RunnerTests Debug/Profile/Release | `com.example.tStore.RunnerTests` | `com.esnaftavar.app.RunnerTests` |

Android Fastlane package metadata ve MainActivity package/path sözleşmesi aynı final
kimliğe taşındı. Repo-geneli runtime kalıntısı bırakmamak için Linux application ID
ve macOS Runner/RunnerTests bundle ID'leri de aynı canonical kimliğe hizalandı.
Windows executable metadata'sındaki Flutter demo şirket adı temizlendi; bu işlemler
desktop ürün davranışını veya görünen adlarını yeniden tasarlamaz. Dart package ve
desktop binary adı olarak kullanılan `t_store`, application/bundle identifier
değildir ve bu görevde değiştirilmedi.

## Görünen uygulama adı

- Android production: `EsnaftaVar`
- Android development: `EsnaftaVar Dev`
- iOS display/bundle name: `EsnaftaVar`

Mağazadaki nihai liste adı ayrıca App Store Connect ve Play Console sahibi tarafından
doğrulanmalıdır.

## Android durumu

- `namespace` ve production `applicationId`: `com.esnaftavar.app`.
- Development flavor application ID'si: `com.esnaftavar.app.dev`.
- MainActivity kaynak yolu:
  `android/app/src/main/kotlin/com/esnaftavar/app/MainActivity.kt`.
- `compileSdk = 36`, `targetSdk = 36`; minimum SDK Flutter'ın
  `flutter.minSdkVersion` değeriyle yönetilir.
- Main manifest internet, coarse/fine location ve kamera izinlerini korur.
- Production Auth callback `com.esnaftavar.app://login-callback/`, Development
  callback `io.supabase.tstore://login-callback/` olarak flavor manifest
  placeholder'larıyla ayrılır. Production merged manifest legacy scheme içermez.
- Release yapılandırmasında debug signing fallback'i yoktur.
- APK/AAB release packaging; `android/key.properties`, dört gerekli değer veya
  keystore dosyası eksikse secret değerlerini yazdırmadan açık hata ile durur.
- Release compile-only task'ları credential olmadan kaynak/compile doğrulaması için
  kullanılabilir; bu çıktı imzalı mağaza artifact'ı değildir.

`android/key.properties.example` yalnız alan adlarını ve güvenli placeholder'ları
gösterir. Doldurulmuş `key.properties`, `.jks` ve `.keystore` dosyaları ignore edilir.

## iOS durumu

- Runner Debug, Profile ve Release `PRODUCT_BUNDLE_IDENTIFIER` değeri:
  `com.esnaftavar.app`.
- RunnerTests Debug, Profile ve Release bundle identifier değeri:
  `com.esnaftavar.app.RunnerTests`.
- Info.plist bundle identifier'ı build setting'den alır; display name
  `EsnaftaVar` olarak korunur.
- Runner Release configuration `Apple Distribution` ve manual signing kullanır.
- `DEVELOPMENT_TEAM` ve `PROVISIONING_PROFILE_SPECIFIER` kaynakta tanımlı değildir;
  owner materyali sağlanmadan signed archive hazır değildir.
- `ios/Flutter/ReleaseSigning.xcconfig.example` güvenli alan isimlerini gösterir.
  Gerçek `ReleaseSigning.xcconfig` ignore edilir ve Release config tarafından
  opsiyonel okunur.
- Repoda entitlements dosyası veya özel capability kaydı yoktur. Capability ihtiyacı
  App ID/provisioning profile ile birlikte ayrıca doğrulanmalıdır.
- Runner scheme Archive action için `Release` kullanır; location/camera kullanım
  metinleri korunur.
- Ayrı iOS product flavor bulunmadığı için mevcut build configuration sözleşmesi
  kullanılır: Debug mevcut Development callback scheme'ini, Profile/Release final
  Production callback scheme'ini `AUTH_CALLBACK_SCHEME` build setting'i üzerinden
  Info.plist'e verir. Runner/RunnerTests bundle kimlikleri ve manual signing
  sözleşmesi değişmez.

## Auth callback — Phase F intermediate integration

`FINAL_AUTH_CALLBACK_IMPLEMENTATION: PASS`

`PHASE_F_CALLBACK_INTEGRATED: YES`

`LEGACY_PRODUCTION_ALLOWLIST_REMOVAL_REQUIRED: YES`

Final Production istemci callback'i:

`com.esnaftavar.app://login-callback/`

Development'ın çalışan callback'i ayrı sözleşmede korunur:

`io.supabase.tstore://login-callback/`

Flutter signup, resend, recovery ve mevcut OAuth yönlendirmeleri environment-owned
tek callback sözleşmesini kullanır. Supabase Flutter'ın scheme/host ayrımı yapmayan
otomatik PKCE URI algılaması kapalıdır; uygulama yalnız exact environment
scheme/host/root path ve dolu PKCE code doğrulandıktan sonra session exchange yapar.
Yabancı scheme, host, path ve web origin güvenli biçimde yok sayılır.

Product owner bildirimiyle Production redirect allowlist final callback'i zaten
içerir; bu görevde Dashboard/Management API yazması yapılmadı. Legacy Production
allowlist kaydı rollback penceresi için geçici kalır. Kaynak integration tamamlandı;
legacy kayıt gerçek signed-artifact confirmation/recovery kabulünden sonra yetkili
release owner tarafından kaldırılması gereken açık operasyon adımıdır.

## Signing durumu

`ANDROID_SIGNING_READY: YES`

`IOS_SIGNING_READY: NO`

`SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`

`KEYSTORE_PRIMARY_BACKUP: COMPLETED`

`KEYSTORE_SECOND_OFFLINE_BACKUP: RECOMMENDED / OPEN`

`FINAL_APP_IDENTITY_WIRED: YES`

`COMMERCIAL_RELEASE_READY: NO`

- Android upload keystore güvenli repo-dışı kullanıcı dizininde oluşturuldu; upload
  alias'ı doğrulandı ve ilk imzalı Production APK/AAB üretildi. Keystore, parolalar ve
  geçici `key.properties` source control'e alınmadı.
- Product owner signing password kaydını parola yöneticisinde ve `.jks` birincil
  yedeğini repo-dışı bulut depoda tamamladığını bildirdi. Secret değer veya yedek
  bağlantısı bu belgeye yazılmadı; ikinci offline yedek öneri/açık durumdadır.
- Apple Developer Team ID, Distribution certificate/private key ve provisioning
  profile mevcut değildir.
- Signed APK/AAB üretilmiştir; signed IPA üretilmemiştir.
- Android fail-closed release packaging ve iOS Apple Distribution/manual signing
  kaynak sözleşmeleri hazırdır.

## Kalan owner materyali ve kararları

1. Play Console kaydının `com.esnaftavar.app` ile exact eşleşmesi.
2. Apple App ID/App Store Connect kaydının `com.esnaftavar.app` ile exact eşleşmesi.
3. Signed-artifact/live acceptance sonrasında legacy Production Auth allowlist kaydının
   kaldırılması.
4. Play App Signing modeli, upload key sahibi ve rotasyon/recovery sorumlusu.
5. Mevcut Android upload keystore'un ikinci offline yedeği ve CI secret-store
   kurulumu. Birincil repo-dışı yedek ve parola yöneticisi kaydı tamamlanmıştır.
6. Apple Team ID, Distribution certificate/private key ve provisioning profile'ın
   güvenli keychain/CI kaynağı.

Secret materyal source'a, template'e, terminal çıktısına veya CI loguna yazılmaz.

## Güvenli release kurulum sırası

1. Play Console ve Apple Developer/App Store Connect kayıtları
   `com.esnaftavar.app` ile yetkili owner tarafından oluşturulur veya doğrulanır.
2. Android upload key ve Apple Distribution materyali güvenli secret store'a alınır;
   erişim ve rotasyon sahibi belirlenir.
3. Android CI, `key.properties` dosyasını geçici workspace'te üretir ve keystore'u
   güvenli konuma getirir; iş bitiminde ikisini de temizler.
4. iOS CI, certificate/private key'i geçici keychain'e ve provisioning profile'ı
   standart dizine kurar; build settings'i secure runtime mekanizmasıyla sağlar.
5. Entegre final callback'in signed-artifact confirmation/recovery kabulü tamamlanır;
   ardından legacy Production allowlist kaydı kaldırılır.
6. Signed AAB ve IPA üretilir; signer/team/profile kimliği secret göstermeden
   doğrulanır. Artifact hash, commit ve build number kaydedilir.

## Store release preflight

- [x] Owner final identifier kararı: `com.esnaftavar.app`.
- [x] Android namespace/applicationId ve MainActivity kaynak yolu final kimliğe bağlı.
- [x] iOS Runner/RunnerTests tüm build configuration kimlikleri final değere bağlı.
- [x] Kaynak platform dosyalarında eski `com.example` runtime kimliği kalmadı.
- [x] Android release debug key fallback'i yok; eksik credential fail-closed.
- [x] Keystore, private key, provisioning profile ve parolalar tracked değil.
- [ ] Play Console package kaydı exact eşleşiyor.
- [ ] Apple App ID, provisioning profile ve App Store Connect exact eşleşiyor.
- [x] Android upload signer doğrulandı ve signed AAB üretildi.
- [x] Keystore birincil repo-dışı yedeği ve parola yöneticisi kaydı tamamlandı.
- [ ] İkinci offline keystore yedeği ve kalıcı CI secret-store/provenance tamamlandı.
- [ ] iOS doğru Team/profile ile signed archive üretti.
- [x] Production callback istemci/platform/preflight wiring'i final scheme'e taşındı.
- [x] Final callback kaynak integration'ı tamamlandı.
- [ ] Final callback signed-artifact canlı kabulü tamamlandı.
- [ ] Legacy Production redirect allowlist kaydı kaldırıldı.
- [ ] Signed artifact üzerinde signup confirmation ve recovery callback PASS.
- [x] İlk Android version/build number ve artifact hash'i kaydedildi; kalıcı CI
      provenance kurulumu ayrıca açıktır.

Android signing tamamlanmış olsa da iOS signing, physical-device acceptance ve Phase F
callback/recovery maddeleri tamamlanmadan `COMMERCIAL_RELEASE_READY: YES` raporlanmaz.

## Wave 11 Phase A — ilk imzalı Android Production artifact'leri

`ANDROID_SIGNING_READY: YES`

`SIGNED_PRODUCTION_APK: PASS`

`SIGNED_PRODUCTION_AAB: PASS`

`SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`

`KEYSTORE_PRIMARY_BACKUP: COMPLETED`

`ANDROID_PHYSICAL_ACCEPTANCE: OPEN`

`READY_FOR_PHYSICAL_ANDROID_ACCEPTANCE: YES`

- Build kaynağı: `origin/main@460c81e3bd8d24dcfea180da8d7c29637918b1af`,
  branch `agent1/w11-android-production-signing`.
- Production application ID/label: `com.esnaftavar.app` / `EsnaftaVar`.
- Version: `versionName 1.0.0`, `versionCode 1`.
- Upload key: repo dışında kalıcı `.jks`, alias `esnaftavar-upload`, RSA 4096.
  Signer certificate SHA-256 fingerprint:
  `3b83d98ab8d32e0f3b9930fa837636e0e9e13219784ffca39cef8cae82a6669b`;
  SHA-1 fingerprint: `3ed8d3c5ff1e9e6eb2d1b5742234b6c9d6e092f3`.
- APK: `build/app/outputs/flutter-apk/app-production-release.apk`, 122,640,821
  byte, SHA-256
  `E1A3E801FD648AE4665E9E2B6D5D88BF15350A3B75A388C94AC5B43701A88C25`.
  `apksigner` sonucu PASS; tek signer ve APK Signature Scheme v2 doğrulandı.
- AAB: `build/app/outputs/bundle/productionRelease/app-production-release.aab`,
  99,288,532 byte, SHA-256
  `0F34958E3F739E887C34E70E627FB75082EC4AE601D89346F1CC1B695E7B88CB`.
  JAR signature doğrulaması PASS. Upload certificate'ın self-signed olması Android
  upload key sözleşmesinin beklenen özelliğidir.
- Standard Production release build `main_production.dart`, production flavor ve
  client-safe gerçek Production runtime injection ile ek icon workaround'u olmadan
  PASS. Supabase ref/URL exact `mefhfvrgkwciubeajjeb`; Development endpoint'i
  artifact'e runtime backend olarak girmedi.
- Merged manifest/package incelemesi internet, camera, coarse/fine location
  izinlerini; final `com.esnaftavar.app://login-callback/` callback'ini ve legacy
  callback'in bulunmadığını doğruladı. Release artifact `debuggable` değildir.
- APK/AAB scan'i signing parolası, private key, service-role/server-only credential
  veya Development URL bulmadı. Client-safe publishable key build contract'ı gereği
  artifact içinde bulunur; repo, belge veya loga yazılmadı.
- Geçici `android/key.properties` ve repo-dışı runtime JSON build sonrasında silindi.
  Kalıcı keystore repo dışında bırakıldı ve Git tarafından izlenmiyor. Owner birincil
  yedeği ve parola yöneticisi kaydını tamamladı; parola, yedek bağlantısı ve secret
  materyal belgelenmedi. İkinci offline yedek öneri/açık olarak kalır.
- Bağlı Android cihazı bulunmadığı için install/startup, gerçek callback opening ve
  fiziksel smoke çalıştırılmadı. Bu durum imzalı artifact üretimini geçersiz kılmaz;
  fiziksel Android acceptance gate'i açık kalır.
- Production yönetim ekranından yalnız client-safe publishable key salt-okunur
  alındı. Production veri isteği/yazması, Auth işlemi, migration veya config değişimi
  yapılmadı; Development'a dokunulmadı.

## Wave 11 Phase A final integration doğrulaması

- Agent 1 evidence commit'i exact base üzerinden `--no-ff` ve çatışmasız entegre
  edildi; integration signed artifact'ı yeniden üretmedi.
- Android identity/signing, callback/deep-link, Production preflight ve ilgili Auth
  hedefli matrisi: **62/62 PASS**.
- Tam Flutter suite: **1154 PASS**, **5 opt-in live skip**.
- `flutter analyze --no-pub`, `git diff --check`, conflict-marker, private-key/secret
  ve tracked `.jks`/`.keystore`/`key.properties`/APK/AAB scan'leri: **PASS**.
- Integration Production/Development remote erişimi veya write, e-posta, Auth config
  ya da migration işlemi yapmadı.

## Wave 10 Phase E2 doğrulama sınırı

- Platform identity/signing/Auth callback hedefli matrisi: **35/35 PASS**.
- Tam Flutter suite: **1138/1138 PASS**; 4 açık opt-in isteyen Development live test
  normal koşuda skip.
- `assembleDevelopmentDebug`: **PASS**; final development application ID ile debug
  APK üretildi.
- `compileFlutterBuildProductionRelease`: **PASS**; yalnız compile contract, signed
  artifact değildir.
- `assembleProductionRelease`: signing materyali olmadığı için beklenen açık hatayla
  **FAIL-CLOSED PASS**; debug signing fallback oluşmadı ve signed artifact üretilmedi.
- Android manifest, iOS Info.plist/shared scheme ve iOS Runner/RunnerTests 3+3 build
  configuration kimlikleri statik/XML olarak **PASS**.
- Windows ortamında iOS compile/archive çalıştırılmadı; signed IPA acceptance değildir.
- `flutter analyze --no-pub`: **PASS**.

## Wave 10 Phase E final integration doğrulaması

- Config/Auth/platform/harness hedefli matris: **61 PASS**, Production live test
  explicit opt-in verilmediği için **1 güvenli skip**.
- Birleşik tam Flutter suite: **1142 PASS**, **5 opt-in live skip**.
- Gerçek client-safe Production runtime injection ile standart Web release build:
  **PASS**; server credential değeri artifact'a girmedi, geçici config/artifact silindi.
- Android Development debug APK: **PASS**; Production release compile-only:
  **PASS**; Production release packaging eksik signing materyalinde beklenen açık
  mesajla **FAIL-CLOSED PASS**, production APK/AAB üretilmedi.
- `flutter analyze --no-pub`: **PASS**. iOS doğrulaması Windows'ta statik sözleşme
  kapsamındadır; signed archive/IPA kabulü değildir.

## Wave 10 Phase F intermediate integration doğrulaması

- Auth callback/PKCE/signup-resend-recovery/platform/preflight hedefli matrisi:
  **118/118 PASS**.
- Birleşik tam Flutter suite: **1154 PASS**, **5 opt-in live skip**.
- `flutter analyze --no-pub`: **PASS**.
- Android Production/Development ve iOS Profile/Release/Debug callback ayrımı statik
  contract testlerinde PASS; signed artifact veya canlı callback acceptance değildir.
