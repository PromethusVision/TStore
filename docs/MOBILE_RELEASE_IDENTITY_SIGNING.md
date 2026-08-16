# Mobile Release Identity and Signing

Bu belge Android ve iOS mağaza release kimliği/imza hazırlığının kaynak
sözleşmesini kaydeder. Gerçek keystore, parola, Apple private key, certificate veya
provisioning profile içermez.

## Karar durumu

`FINAL_APP_IDENTIFIER_DECISION_REQUIRED`

Repoda EsnaftaVar için product-owner tarafından kesinleştirilmiş Android package
name veya iOS bundle identifier bulunamadı. Mevcut değerler Flutter örnek/demo
kimliğidir ve canonical kabul edilmez:

| Platform | Mevcut değer | Durum |
| --- | --- | --- |
| Android namespace | `com.example.t_store` | Geçici/demo |
| Android production applicationId | `com.example.t_store` | Geçici/demo |
| Android development applicationId | `com.example.t_store.dev` | Geçici/demo |
| iOS Runner bundle identifier | `com.example.tStore` | Geçici/demo |
| iOS RunnerTests bundle identifier | `com.example.tStore.RunnerTests` | Geçici/demo |

Bu değerler owner kararı olmadan değiştirilmez. Android package name ve iOS bundle
identifier kalıcı mağaza kimlikleridir; mağaza kaydı, universal/app links, push,
credential ve gelecekteki OAuth sözleşmeleri bu karara bağlanacaktır.

## Görünen uygulama adı

Kaynakta ürün adı `EsnaftaVar` olarak açık ve tutarlıdır. Bu nedenle identifier
kararından bağımsız olarak mağaza artifact'larında görünen adlar şu hale getirildi:

- Android production: `EsnaftaVar`
- Android development: `EsnaftaVar Dev`
- iOS display/bundle name: `EsnaftaVar`

Mağazadaki nihai liste adı ayrıca App Store Connect ve Play Console sahibi
tarafından doğrulanmalıdır.

## Android durumu

- `compileSdk = 36`, `targetSdk = 36`.
- Minimum SDK, repo tarafından sabit sayı yerine Flutter'ın
  `flutter.minSdkVersion` değeriyle yönetilir.
- Makineye özel `org.gradle.java.home` sabiti kaldırılmıştır; yerel/CI ortamı geçerli
  JDK 17 konumunu Flutter toolchain veya güvenli runtime ayarıyla sağlamalıdır.
- Main manifest internet, coarse/fine location ve kamera izinlerini taşır.
- Auth callback `io.supabase.tstore://login-callback/` için browsable VIEW intent'i
  main manifestte kayıtlıdır.
- `production` ve `.dev` suffix'li `development` flavor'ları vardır.
- Eski release yapılandırmasındaki `signingConfigs.debug` fallback'i kaldırıldı.
- APK/AAB release packaging; `android/key.properties`, dört gerekli değer veya
  keystore dosyası eksikse secret değerlerini yazdırmadan açık hata ile durur.
- Release compile-only task'ları credential olmadan statik/compile doğrulaması için
  kullanılabilir; bu çıktı imzalı mağaza artifact'ı değildir.

`android/key.properties.example` yalnız alan adlarını ve güvenli placeholder'ları
gösterir. Doldurulmuş `key.properties`, `.jks` ve `.keystore` dosyaları ignore edilir.

## iOS durumu

- Runner Release configuration, development certificate yerine
  `Apple Distribution` ve manual signing kullanacak şekilde hazırlanmıştır.
- `DEVELOPMENT_TEAM` ve `PROVISIONING_PROFILE_SPECIFIER` kaynakta tanımlı değildir;
  owner tarafından sağlanmadığı sürece signed archive hazır değildir.
- `ios/Flutter/ReleaseSigning.xcconfig.example` güvenli alan isimlerini gösterir.
  Gerçek `ReleaseSigning.xcconfig` ignore edilir ve Release config tarafından
  opsiyonel olarak okunur; CI aynı değerleri güvenli build settings ile de verebilir.
- Repoda entitlements dosyası veya özel capability kaydı yoktur. Capability ihtiyacı
  çıkarsa App ID/provisioning profile ile birlikte ayrıca doğrulanmalıdır.
- Runner scheme Archive action için `Release` kullanır.
- Location/camera kullanım metinleri ve `io.supabase.tstore` URL scheme'i Info.plist
  içinde kayıtlıdır.

## Auth callback tutarlılığı

Android ve iOS bugün aynı callback'i kullanır:

`io.supabase.tstore://login-callback/`

Bu sözleşme Wave 7 PKCE/recovery hardening'iyle uyumludur ve bu çalışma kapsamında
değiştirilmedi. Scheme mevcut geçici package/bundle identifier'larından teknik olarak
bağımsızdır. Final identifier kararı sonrasında release sahibi:

1. scheme'in korunacağını veya app-owned yeni bir scheme gerekeceğini kararlaştırır;
2. bir değişiklik gerekiyorsa Android manifest, iOS Info.plist, Flutter redirect
   üretimi ve Supabase allowlist'i tek değişiklik setinde günceller;
3. confirmation/recovery linklerini gerçek signed artifact üzerinde test eder.

Agent owner kararı olmadan yeni callback scheme üretmez.

## Gerekli owner kararları ve secret materyali

1. Final Android applicationId/namespace.
2. Final iOS Runner ve test bundle identifier'ları.
3. `io.supabase.tstore` callback scheme'inin final kararı ve Production Auth
   redirect allowlist onayı.
4. Play App Signing modeli, upload key sahibi, rotasyon/recovery sorumlusu.
5. Android upload keystore, alias ve parolaların güvenli secret-store/CI kaynağı.
6. Apple Developer Team ID, Distribution certificate/private key ve uygun
   provisioning profile'ın güvenli keychain/CI kaynağı.
7. App Store Connect / Play Console kayıt sahipliği ve görünen mağaza adının onayı.

Secret materyal source'a, template'e, terminal çıktısına veya CI loguna yazılmaz.

## Güvenli kurulum sırası

1. Owner final Android/iOS identifier kararını yazılı olarak kaydeder.
2. Play Console ve Apple Developer/App Store Connect kayıtları bu exact değerlerle
   yetkili owner tarafından oluşturulur veya doğrulanır.
3. Android upload key ve Apple Distribution materyali güvenli secret store'a alınır;
   erişim ve rotasyon sahibi belirlenir.
4. Android CI, `key.properties` dosyasını geçici workspace'te üretir ve keystore'u
   güvenli konuma getirir. İş bitiminde ikisini de temizler.
5. iOS CI, certificate/private key'i geçici keychain'e ve provisioning profile'ı
   standart dizine kurar; build settings'i secure runtime mekanizmasıyla sağlar.
6. Identifier değişikliğiyle birlikte platform test target'ları, callback/allowlist,
   gerekiyorsa capability/entitlements ve mağaza kayıtları tutarlı güncellenir.
7. Signed AAB ve IPA üretilir; signer/team/profile kimliği secret göstermeden
   doğrulanır. Artifact hash, commit ve build number kaydedilir.
8. Wave 7 confirmation/recovery callback testleri gerçek signed artifact'ta ve
   production-like Auth yapılandırmasında tekrar edilir.

## Store release preflight

- [ ] `FINAL_APP_IDENTIFIER_DECISION_REQUIRED` kapatıldı.
- [ ] Android namespace/applicationId ve Play Console kaydı exact eşleşiyor.
- [ ] iOS bundle identifier, App ID, provisioning profile ve App Store Connect exact
      eşleşiyor.
- [ ] Development suffix/test bundle identifier final ana kimlikten türetildi.
- [ ] Android release artifact debug key ile imzalı değil; upload signer doğrulandı.
- [ ] iOS archive Apple Distribution + doğru Team/profile ile imzalı.
- [ ] Keystore, private key, provisioning profile ve parolalar tracked değil.
- [ ] App label/display name ve store listing adı owner tarafından onaylı.
- [ ] Android/iOS callback kayıtları ve Supabase Production allowlist eşleşiyor.
- [ ] Signed artifact üzerinde signup confirmation ve password recovery callback PASS.
- [ ] Version/build number, artifact hash ve CI provenance kaydedildi.

Bu maddeler tamamlanmadan `SIGNED_RELEASE: PASS`, `MOBILE_RELEASE_IDENTITY_READY: YES`
veya `SIGNING_READY: YES` raporlanmaz.

## Wave 9 doğrulama sınırı

- JDK 17 ile `compileFlutterBuildProductionRelease`: **PASS**. Bu yalnız Android
  production-release compile contract kanıtıdır.
- `assembleProductionRelease`: `android/key.properties` bulunmadığı için beklenen
  açık signing hatasıyla **FAIL-SAFE PASS**; debug signing fallback oluşmadı.
- Signed AAB/APK üretilmedi ve signer acceptance yapılmadı.
- Çalışma ortamı Windows olduğu için iOS compile/archive çalıştırılmadı. Info.plist,
  shared scheme, Xcode project ve xcconfig sözleşmeleri statik/XML testlerle
  doğrulandı; signed IPA acceptance değildir.
