# ASTRA W52A — POCO X7 PRO INSTALL / OFFLINE LAUNCH RESULT

2026-09-06 Türkiye / 2026-09-05 UTC. Exact frozen RC, yetkili POCO X7 Pro'ya
veriler korunarak kuruldu. Offline ilk açılışın kilitsiz takip gözlemi ve tek
force-stop/relaunch kontrolü PASS; Product Owner fiziksel ekranı onayladı.
Temel yerel gezinme doğrulanamadı; phase 10'un "only where possible" sınırı
altında bu sınırlama açıkça kaydedildi. Gezinmeye PASS verilmedi.
Production erişimi, rebuild, uninstall, veri temizleme ve store upload yok.

## Artifact — değişmeyen exact kimlik

- Kaynak APK:
  `<LOCAL_RELEASES>/w51e/1.0.0+1-main-6a1cf14/EsnaftaVar-1.0.0+1-w51e-main-6a1cf14-production.apk`
- SHA-256:
  `c5d8835832c4d7c050e7da85b4074813a5a99f15ecdd01c00a715693adde037b`
- Boyut **89.348.517 byte**; package **com.esnaftavar.app**;
  versionName **1.0.0**, versionCode **1**.
- Cihaza dokunmadan hash, AAPT package/version ve bağımsız APK signature kontrolü
  PASS. Tek signer; certificate SHA-256:
  `3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B`.
- APK kaynak commit'i **6a1cf14639124bf709c6a988b9e8290ac7757c60**.
  W52A hiçbir APK üretmedi, değiştirmedi, resign/repack etmedi veya başka APK
  kullanmadı. Signing/config dosyaları yeniden açılmadı; bu görevde gerekli değildi.

## Device

| Kontrol | Sonuç |
|---|---|
| ADB | Tek yetkili fiziksel cihaz; PASS |
| Market name | POCO X7 Pro; gerçek cihaz property eşleşmesi |
| Model / manufacturer / brand | 2412DPC0AG / Xiaomi / POCO |
| Android / SDK | **Android 16 / SDK 36** |
| Emulator | NO |
| Tam seri / SSID / IP / MAC / özel kullanıcı içeriği kaydı | NO |

Her cihaz eylemi öncesi tek yetkili hedef ve POCO kimliği tekrar kontrol edildi;
tahmin edilen veya başka cihaz hedeflenmedi. Tam seri yalnız ADB seçimi için
bellekte kullanıldı; tool çıktısına, dosyaya veya bu rapora alınmadı.

## Install — veri koruyan replace

- Önceki package **installed YES**, sürüm **1.0.0 (1)**.
- Önceki base APK geçici repo-dışı alanda read-only incelendi; imzası ve
  sertifikası beklenen upload pin'iyle eşleşti. Yeni sürüm/downgrade veya
  signature conflict yoktu; uninstall etrafından dolaşılmadı.
- Kurulum yöntemi mevcut package üzerine **safe replace (`adb install -r`)**.
  Frozen dosya hash'i işlemden hemen önce tekrar eşleşti.
- **INSTALL SUCCESS**, 22:00:00.097 → 22:00:03.939 UTC; **3,844 saniye**.
  Kurulum uygulamayı açmadı. Öncesinde hedef process çalışmıyordu.
- Hemen sonraki package okuması **com.esnaftavar.app / 1.0.0 (1)**; PASS.
- `DEVICE_DATA_CLEARED: NO`; `APP_UNINSTALLED: NO`; downgrade `-d`: NO.
  Hesap, izin veya cihaz/app yapılandırması değiştirilmedi.

## Offline gate

İlk bağlantı okumasında mobil veri etkin ve aktif default network vardı. Launch
durduruldu; cihazın ağ ayarı agent tarafından değiştirilmedi. Product Owner
uçak modunu açıp Wi-Fi'yi kapattığını açıkça bildirdi ve devam yetkisini verdi.

Kurulum sonrası, her launch öncesi ve gözlem boyunca kontroller:

- Airplane mode **ON**.
- Wi-Fi **OFF**.
- Aktif default network **NONE**.
- Mobile-data tercih biti açık kalmasına rağmen uçak modu nedeniyle etkin
  internet bağlantısı yok; bu tercih agent tarafından değiştirilmedi.
- İlk launch, tekrar launch ve final identity kontrolü **OFFLINE PASS**.

Production Supabase/Auth/Storage/Realtime sorgusu, remote smoke veya online
journey yapılmadı. İnternet gerektiren davranışlara PASS verilmedi. Ağ ayarları
geri açılmadı; çevrimdışı durumu Product Owner sağladı.

## Launch / crash / ANR / relaunch

Launcher Activity, package manager MAIN/LAUNCHER çözümlemesiyle alındı:
`com.esnaftavar.app/.MainActivity`. Activity adı tahmin edilmedi.

| Gözlem | Sonuç |
|---|---|
| İlk `am start -W` | Status ok; exact launcher; 22:02:55.263 UTC |
| İlk gözlem | **47,156 saniye**; tek process yaşadı; fatal/native crash, ANR veya restart yok |
| İlk foreground kanıtı | **INCONCLUSIVE**: örneklerde foreground doğrulanmadı; sonraki tanıda cihaz uyku/kilit durumundaydı |
| Owner müdahalesi | Ekranı kilitsiz/açık tutarak devam edeceğini onayladı; agent kilit veya ekran ayarını değiştirmedi |
| Kilitsiz ilk-açılış takip gözlemi | **16,265 saniye / 3 örnek**; her örnekte aynı tek process, target foreground, ekran açık/kilitsiz; PASS |
| Takipte ilave ADB launch | NO; zaten çalışan uygulama gözlendi |
| Force-stop | Yalnız **com.esnaftavar.app**, bir kez; veri temizlenmedi |
| Tek relaunch | Status ok, COLD; TotalTime **468 ms**, WaitTime **473 ms** |
| Relaunch gözlemi | **29,297 saniye / 4 örnek**, 22:10:07.569 → 22:10:36.863 UTC |
| Relaunch foreground/process | Her örnekte target foreground ve aynı tek process; PASS |
| Fatal exception / AndroidRuntime crash / ANR / native crash | İki launch ve takip penceresinde gözlenmedi |
| Process death/restart loop | Gözlenmedi; phase 9'daki yetkili force-stop ayrı tutuldu |
| Missing Production config / non-network unhandled exception | Gözlenmedi |

İlk foreground sonucuna sonradan geçmişe dönük PASS yazılmadı. İlk pencere
kanıtı korundu; kilitsiz takip ve başarılı cold relaunch ayrı kaydedildi.
Bu ayrım gerçek process çökmesi ile ekranın kilitlenmesini birbirine karıştırmaz.

Her gözlem yeni cihaz zaman damgasından başlayan, hedef package/PID ile süzülen
sınırlı logcat penceresi kullandı. App data veya global log buffer temizlenmedi.
Ham loglar yalnız bellekte kaldı; safe durum/classification kaydedildi.
Bu bounded smoke uzun süreli dayanıklılık veya backend doğruluğu iddiası değildir.

## Physical visual ve basic offline navigation

**PRODUCT_OWNER_VISUAL_CONFIRMATION: PASS.** Owner, fiziksel ekranda EsnaftaVar
ekranının göründüğünü; kalıcı beyaz/siyah ekran, crash dialog veya belirgin
yerleşim bozukluğu bulunmadığını açıkça onayladı. Bu sonuç yalnız process
survival'dan çıkarılmadı. Screenshot alınmadı veya commit edilmedi.

Yerel UI otomasyon ağacında güvenle tanımlanabilen gezinme/geri dönüş çifti
bulunmadı; koordinat tahminiyle dokunulmadı. Ham UI XML'i veya kişisel ekran
içeriği kaydedilmedi. **BASIC_OFFLINE_NAVIGATION: NOT_VERIFIED**.
Owner'dan çevrimdışı bir yerel sayfayı açıp geri dönme sonucu istendi; auth,
alışveriş veya backend-dependent yolculuk istenmedi. Rapor kapanışında manuel
gezinme yanıtı alınmadı; fiziksel ekran onayı gezinme kanıtı yerine kullanılmadı.
Phase 10 yalnız mümkün olduğunda istendiğinden bu sınırlama, tamamlanan
install/launch kapılarından ayrı tutuldu. Gezinme veya backend kabulü iddia edilmez.

## Final installed identity / cleanup

22:13:04.691 UTC'de telefondaki gerçek installed `base.apk` repo-dışı geçici
alana geri okundu. **Installed base APK SHA-256 frozen kaynak SHA-256 ile
byte-exact eşleşti**:

```text
c5d8835832c4d7c050e7da85b4074813a5a99f15ecdd01c00a715693adde037b
```

Kurulu package/version **com.esnaftavar.app / 1.0.0 (1)** ve signature/certificate
tekrar doğrulandı. Frozen kaynak dosyanın hash'i de değişmedi. Bu fiziksel
gözlemlerin hangi APK'ya ait olduğu yalnız sürüm adına dayanmaz.

Geçici APK readback dosyaları doğrulanmış geçici dizin sınırında temizlendi.
Ham ADB/device/logcat/UI dump veya screenshot kalıcı dosyaya yazılmadı. Yalnız
redacted `.buildlog/w52a-*` durum kanıtı/helpers ignored alanda kaldı.
Exact RC telefonda kurulu bırakıldı; uninstall ve clear-data yapılmadı.

## Evidence lineage / TASK_RESULT

- Fresh evidence branch **astra-release/w52a-poco-install-launch-smoke**.
- Fetched/current-main evidence base **4f0da8201e2571200e99fa3dfe76387e3a1486ce**;
  APK'nın frozen **6a1cf14** build kaynağıyla karıştırılmadı.
- Worktree `<LOCAL_WORKTREE>`, canonical
  CLEAN repo ile ortak Git. Korunan eski `TStore` dizinine dokunulmadı.
- Runtime/source/config/dependency/test/golden/backend değişikliği **0**;
  yalnız bu safe evidence belgesi teslim kapsamındadır. Rebuild yapılmadı.
- Flutter/analyzer/build suite bu fiziksel-device/docs görevinde yeniden
  çalıştırılmadı. W51E sonucu yeni W52A testiymiş gibi sunulmadı.
- Figma ve sub-agent **0**; screenshot **0**; ortak runtime collision **NONE**.
- Main merge/push yok. Tam seri, credentials, publishable key değeri, kullanıcı
  içeriği veya dış input/artifact Git'e alınmaz. Final evidence SHA/branch/push
  ve temiz-tree sonucu teslim mesajında kaydedilir.

## Remaining gates

- Temel yerel gezinme doğrulanamadı; manuel geri bildirim sonradan eklenebilir.
  W52A'nın tamamlanan install/launch kontrolleri gezinme kabulü sayılmaz.
- Online Production read-only smoke ayrı açık yetki ve kapsam gerektirir;
  W52A bu erişim veya backend kabulü için yetki sağlamaz.
- Physical two-device QR ayrı ikinci cihaz, roller ve uçtan uca kabul kapısıdır;
  W52A tek POCO'da offline install/launch kanıtı sağlar.

## Final flags

```text
EXACT_FROZEN_APK_VERIFIED: PASS
POCO_X7_PRO_TARGET_VERIFIED: PASS
ADB_AUTHORIZED: PASS
APK_INSTALL: PASS
INSTALLED_PACKAGE_VERSION: PASS
DEVICE_DATA_CLEARED: NO
APP_UNINSTALLED: NO
OFFLINE_LAUNCH_GATE: PASS
FIRST_LAUNCH: PASS
RELAUNCH: PASS
CRASH_ANR_GATE: PASS
PRODUCT_OWNER_VISUAL_CONFIRMATION: PASS
PRODUCTION_ACCESSED: NO
REBUILD_PERFORMED: NO
STORE_UPLOAD_PERFORMED: NO
READY_FOR_ONLINE_PRODUCTION_READONLY_SMOKE: YES
READY_FOR_PHYSICAL_TWO_DEVICE_QR_GATE: NO
```

Online readiness YES, bu exact RC'nin POCO'da doğrulanmış kurulum ve offline
launch kanıtıyla ayrı yetkilendirilecek read-only smoke için hazır olduğunu
belirtir. Production erişimi, gezinme kabulü veya iki cihaz QR testi yapılmış
olduğu anlamına gelmez. Bu görevde Production'a erişilmedi.
