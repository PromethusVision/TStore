# Powerbank — ilk ürünün kategori hazırlığı

22 Ekim 2026. Yerel hazırlık onaylandı ve tamamlandı. **Hosted uygulama onaylı
değil ve çalıştırılmadı.** Main entegrasyonu Integration Agent'a aittir.

## Somut sonraki onay kapsamı

Entegrasyon PASS sonrasında yalnız Development `tnipyxnvhgelwdpykyez` için:

1. `Elektronik → Güç, Şarj & Bağlantı → Powerbank` yoluna bir L3 yaprak eklenir.
   Yeni kimlik `e704d61e-72ca-4609-ba79-e431c780881d`, kayıt anahtarı
   `CANONICAL-001564`, slug `powerbank-001564`. NORMAL/not_required politikası.
2. Yalnız Elektronik ve Güç, Şarj & Bağlantı üst başlıkları açılır; ikisi de
   ürüne atanamaz kalır. Ürüne atanabilen tek açık kategori Powerbank olur.
3. Ürün yayını, mağaza fiyatı/stok, marka kaydı, hesap/rol, özellik açma,
   şema/izin ve Production değişikliği bu önerinin dışındadır.

Son salt okunur Development gözlemi: 1.563 kategori, 0 aktif kategori, 0 ürün,
0 mağaza ürünü, 0 alt düğüm/kimlik çakışması; şema parmak izi
`d9607df877e9115eb811d984e561b4e7`. Hesap kimliği ve iletişim bilgisi sorgulanmadı.
Yerel inceleme paketi `.buildlog/pilot-powerbank-review/development-powerbank-20261022/`.
Plan özeti `d03197c781a8faa0d03ab16d138da0d2707b2350125a93aaa2f97967bcfe766a`.
Bu kimlik insan onayı veya sunucu kimliği kanıtı değildir.

Korumalar: işlem öncesi tam kategori/katalog/şema eşleşmesi; sabit kimlikler ve
ebeveyn ilişkisi; satır sayıları; işlem kilitleri ve zaman aşımı; tek transaction;
işlem sonrası ilgisiz kayıtların ve şemanın değişmediğinin kontrolü. Uygulamadan
önce resmi panelde projenin gerçek kimliği doğrulanmalı ve gözlem yenilenmelidir.
Yerel fixture için üretilen SQL hosted sunucuda kullanılmaz.

## Yerel doğrulama ve kapsamı

Yeni kanıt `docs/data/merchant_pilot_powerbank_acceptance.json`; ayrı kaynak ve
manifest parmak izlerine bağlıdır. Eski J7/J9/J16 kanıtları byte düzeyinde korundu.
J16'nın güncel kaynak reddi atlatılmadı. Bu belge tüm UI'ı veya fiziksel kabulü
yeniden yeterli ilan etmez. Kanıtta 14 PostgreSQL grubu ve iki aşamada 7 gerçek
Flutter repository kontrolü vardır. Yeni politika/kanıt birim paketi 10 testtir.
Bitişik katalog/yayın/entegrasyon sözleşmeleriyle toplam **80 PASS / 0 FAIL /
0 SKIP**. Analyzer **PASS**, 0 sorun. Tam Flutter regresyonu yeniden koşulmadı;
runtime değişmedi ve bu sonuç tam uygulama ya da fiziksel QR kabulü değildir.

Yerel provada yalnız sentetik `example.invalid` hesapları/ürünü kullanılır.
Gerçek satın alma veya ödül oluşturulmaz; business capability bayrakları kapalıdır.
Kategori hataları, başka kayıt değişimi, şema/yetki kayması, eksik onay belirteci,
eşzamanlı yazıcı, işlem sonundaki hata, tekrar çalıştırma ve geri çekme denendi.
Öneri yayınlanmadan katalogda görünmez. Yayın sonrasında Merchant fiyatı 990 TL,
Customer okuması 990 TL; eski genel ürün fiyatı 0 olarak kalır. Stok ve sahiplik
kontrolleri mevcut repository'lerle doğrulandı. Runtime veya geçmiş migration
değişmedi; dolayısıyla teslim edilen APK'ların üzerine yeni derleme yazılmadı.

## Tekrar üretim

Mevcut `tool/merchant_acceptance` yerel servis kurulumunu ve sabit dependency
lockfile'ını kullan. `local.mjs prepare` ile yalnız yeni görev fixture'ı oluştur;
`local.mjs start <run-directory>` ile loopback servislerini başlat. Var olan
veritabanını sıfırlama veya başka görevin ağını/volume'ünü silme. Docker varsayılan
alt ağ havuzu doluysa mevcut rotaları inceleyerek yalnız bu run'ın beklenen adına
ayrı boş alt ağ ayır; başka ağı kaldırma.

```text
node tool/merchant_acceptance/pilot_powerbank.mjs <run-directory> <flutter-root>
node --test tool/merchant_acceptance/pilot_powerbank.test.mjs
flutter analyze --no-pub
node tool/merchant_acceptance/local.mjs stop <run-directory>
```

Runner hosted adres kabul etmez. Sonuç run dizinine yazılır; gizli geçici istemci
dosyası finally içinde kaldırılır. Başarılı kanıt incelendikten sonra yukarıdaki
ayrı Powerbank kanıt yoluna taşınır; eski kanıtlara yazılmaz. `source_commit`
provanın başlangıç commit'idir; gerçek son kaynaklar `sources` alanıyla bağlanır.
Metin kaynaklarının satır sonları Git/Windows taşınabilirliği için LF'ye normalize
edilir; veritabanı şema fingerprint'i normalize edilmez.

Çevrimdışı hazırlayıcı:

```text
node tool/merchant_acceptance/prepare_powerbank_pilot.mjs observe <new-name>
node tool/merchant_acceptance/prepare_powerbank_pilot.mjs activate <new-name>
node tool/merchant_acceptance/prepare_powerbank_pilot.mjs deactivate <new-name>
```

Aktivasyon/geri çekme girişi `.buildlog/pilot-powerbank-input/<new-name>.json`
içinde yalnız `observation.readonly.sql` sonucudur. Hazırlayıcı güncel kaynak
kanıtını kontrol eder, yeni ve boş çıktı dizini ister, uzaktan işlem yapmaz.
SQL'de onay belirtecini otomatik ayarlamaz. Kanıt/gözlem değişirse yeniden incele.

Geri çekme **ayrı onay ve taze gözlem** ister; yeni UUID tutulur, üç düğüm
pasife alınır, kayıt silinmez. Ürün/listing oluşmuşsa otomatik geri çekme reddedilir.
Geri çekilen yaprağı yeniden açmak bu ilk kurulum planının kapsamı değildir.

## Telefon adımı

Sunucu kategori onayı/uygulaması ardından kullanıcı uygulamada bu yolu seçerek
barkodsuz Baseus EnerFill FM11 10.000 mAh önerisini gönderir. Kontrollü katalog
yayını somut bekleyen kayıt üzerinden ayrıca onaylanır; ardından kullanıcı kendi
mağazasına 990 TL fiyatla ekler. Fotoğraf, konum/Customer görünürlüğü ve iki cihaz
QR kabulü hâlâ açık fiziksel adımlardır. Pilotun hazır olduğu iddia edilmez.
