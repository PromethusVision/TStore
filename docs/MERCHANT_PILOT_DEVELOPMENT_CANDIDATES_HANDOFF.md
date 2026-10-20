# J15 — Güncel Development Android adayları

Kaynak: temiz, entegre `a0dfbdfdc9e4534a702865b4fdd1cec7e6da7053`.
Görev dalı: `agent/merchant-pilot-device-candidates`.
Kapsam: canonical §4.14; mevcut eşleşen cihaz paketi yönteminin uygulanması.

## Teslim

Customer ve Merchant aynı kaynak, aynı Development projesi ve aynı kapalı
özellik profiliyle yeniden derlendi. Bunlar gerçek test projesine bağlı
**Android ARM64 debug cihaz adaylarıdır**. Sentetik anahtarlı derleme provası
değildir; release imzalı dağıtım veya esnaf kabulü anlamına da gelmez.

| Alan | Customer | Merchant |
|---|---|---|
| Dosya | `customer.apk` | `merchant.apk` |
| Telefonda görünen ad | EsnaftaVar Dev | EsnaftaVar Esnaf Pilot |
| Paket kimliği | `com.esnaftavar.app.dev` | `com.esnaftavar.app.merchant.pilot` |
| Flavor | `development` | `merchantPilot` |
| Sürüm | 1.0.0 (5) | 1.0.0 (5) |
| Boyut | 154790175 bayt | 119415007 bayt |
| SHA-256 | `d4b89751f0c1ae2ce28e28af09ae8eaefdcb4f46a1f2e38b967108cc0fcce0a7` | `d90881a7fc9dea13f113dc594790ca1c59e54319411dbf39fb1d84895ad527d5` |

Ortak debug sertifikası:
`2e938b2733f51283c2c300974ec2aee9409d1799ec423eab1a51512e26e17a95`.
Merchant paket kimliği ve sertifikası, sahibinin daha önce parola kurtarma
denemesi yaptığı J11 takip adayına eşittir. Bu karşılaştırma, telefonda
güncelleme veya oturumun korunmasının sınandığı anlamına gelmez.

Çift kimliği:
`0494b23da3307969c1c76a8634aacfd870de829ae1e59e8c3a22390c663eae6e`.
Kaynak özeti:
`bf4babc17956a5166e3ceb5a363742e395dcd4f3c46481c7314eaeed3a4a8756`.

## Dosyaların yeri ve doğrulama

Görev worktree'sinde asıl çıktı:
`.buildlog/pilot-device/current-development-20261020/`.
İki APK, `pair.json`, `sources.json` ve boş
`field-observation.template.json` birlikte tutulur. Loglar ignored alandadır;
APK veya istemci anahtarı Git'e eklenmez.

Aynı dosyaların kullanıcıya ayrılmış kopyası:
Windows **İndirilenler → EsnaftaVar-Development-a0dfbdfd**.
Bu klasörde ayrıca `ONCE-OKU.txt` ve `dosya-ozetleri.json` bulunur. Teslim kopyası
aynı APK baytları ve kaynak listesiyle yeniden doğrulandı; dışarı yüklenmedi.
Dosya adları manifestle aynı tutulur.

```text
node tool/pilot_device/review_pair.mjs current-development-20261020
```

Beklenen sonuç `PAIR_ARTIFACTS_VERIFIED`. Bu yalnız paket/kaynak bütünlüğüdür.
12 saha senaryosunun tamamı OPEN; dosyaya yapay PASS yazılmadı. Geçmiş J10–J14
kanıtları ve eski APK'lar değiştirilmedi veya yeniden etiketlenmedi.

Makine kaydı:
[Development aday kanıtı](data/merchant_pilot_development_candidates.json).
Bu JSON derleme anını kaydeder; sonradan değişen APK veya kaynak için onay değildir.
Bu teslimin commit'i yalnız dokümantasyon/kanıt ekler; paketlenen kaynak yukarıdaki
entegre commit'tir. Paketleme kaynakları bu belge commit'inde değişmez.

## Yapılan kontroller

- **135 Flutter uyumluluk testi PASS / 0 FAIL / 0 SKIP.** Katalog fiyatı, callback
  ayrımı, Merchant kurtarma/oturum yarışları, ekran ve eşleşen yapılandırma.
- **Flutter analyzer PASS**, sorun yok, 43,3 saniye. Tam Flutter paketi yeniden
  çalıştırılmadı; bu görevde uygulama kodu değişmedi.
- İki gerçek APK için kimlik, callback, sürüm, ARM64 içerik, aynı imza,
  backup/cleartext kapalı olması, beklenen izinler, uygulamanın bağlantı yönetimi
  ve Development istemci/katalog işaretinin paket içinde bulunması kontrol edildi.
  Metin taraması tek başına davranış veya tüm gizli bilgilerin yokluğu kanıtı değildir.
- İki bağımsız paket kontrolü: asıl çıktı ve İndirilenler kopyası kaynaklarıyla
  eşleşti. Önceki Merchant adayının kimlik/imza eşleşmesi ayrıca doğrulandı.
- Mevcut resmi Development Connect ekranından yalnız herkese açık istemci
  bilgisi kullanıldı. Aynı projenin `/auth/v1/settings` adresine tek GET HTTP 200
  döndürdü. Oturum, hesap, e-posta veya veri değişikliği oluşturulmadı.
- Geçici istemci girdisi ve derleme yapılandırmaları kaldırıldı. Resend anahtarı,
  service-role, sunucu parolası veya release imza dosyası okunmadı/oluşturulmadı.

Customer derlemesinde Windows sürücüleri arasındaki Kotlin artımlı önbellek
uyarısı görüldü; mevcut derleyici geri dönüş yolu ile derleme ve son APK
incelemesi başarılı oldu. Gradle veya bağımlılık ayarı değiştirilmedi.
Bağımlılık hazırlığının ürettiği yedi masaüstü kayıt dosyasında yalnız satır sonu
farkı olduğu doğrulanıp bu görevin oluşturduğu farklar geri alındı.

## Açık kalan gerçek pilot adımı

Product Owner bu görevde de ilk esnaf ve ürünlerin **henüz belli olmadığını**
bildirdi. Bu bilgiyle hesap/rol/yayın listesi uydurulmadı; eski kurtarma test
hesabına esnaf yetkisi verilmedi.

İlk gerçek esnaf seçilince kendi fiziksel ürünlerinden küçük bir başlangıç
listesi belirlenmeli; mevcut kategori/katalog/hesap kontrolleriyle tam teklif
hazırlanmalı. Ardından onaylanan hesap ve işlemlerle iki fiziksel cihazda
[saha kabulü](MERCHANT_PILOT_FIELD_ACCEPTANCE.md) yürütülür.
Sektör başvurusu geniş kalabilir; hizmet/randevu kapsamı bu teslimle açılmaz.

Bu görevde telefon kurulumu, uygulama güncellemesi, gerçek giriş/kurtarma,
kamera/QR veya yeni e-posta/push denemesi yapılmadı. Debug adayının hazır olması
esnaflara dağıtım ve pilot açılışı değildir; release imzası ve nihai açılış
kararı ayrı kalır.

## Integration sınırı

Yalnız canonical/slices, bu teslim belgesi ve temizlenmiş kanıt kaydı değişir.
Uygulama, Android, bağımlılık, migration, eski kanıt ve merkezi koordinasyon
dosyaları değişmez. Yeni mimari veya FROZEN ürün kararı yoktur.

Integration Agent doküman/kaynak/kanıt eşleşmesini kontrol eder; hosted ayarı,
hesap, rol veya ürün işlemi yapmaz. Main merge/push Merchant Agent tarafından
yapılmadı. Production erişimi **NONE**; Development yazması **NONE**;
migration uygulanması **NO**.
