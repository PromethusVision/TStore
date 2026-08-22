# Esenler Demo Dataset — `esenler_demo_v1`

Bu paket yalnız müşteri uygulamasındaki katalog, keşif, arama, yakınlık ve aynı ürünü
satan esnafların fiyat/mesafe karşılaştırmasını doğrulamak için hazırlanmış sentetik
veridir. Kayıtların hiçbiri gerçek bir işletmeyi temsil etmez. Bu Phase A çalışması
Production veya Development ortamına uygulanmamıştır.

## Sabit veri sözleşmesi

| Varlık | Sayı | Kural |
| --- | ---: | --- |
| Mahalle | 19 | Esenler Belediyesi 2026 sırası |
| Kategori | 4 | Kırtasiye, Elektronik, Gıda, Ayakkabı |
| Ortak canonical ürün | 20 | Her kategoride 5 ürün |
| Demo esnaf | 57 | Her mahallede 3 farklı kategori |
| `shop_products` vitrini | 285 | Her esnafta tam 5 ürün |

Her mahallede eksik kategori, sıfır tabanlı resmi sıra indeksinin `index mod 4`
değeriyle döner: `0 Kırtasiye`, `1 Elektronik`, `2 Gıda`, `3 Ayakkabı`. Böylece
mağaza dağılımı Kırtasiye 14, Elektronik 14, Gıda 14 ve Ayakkabı 15 olur.

Resmi mahalle sırası:

1. 15 Temmuz
2. Atışalanı
3. Birlik
4. Çifte Havuzlar
5. Davutpaşa
6. Fatih
7. Fevzi Çakmak
8. Kazım Karabekir
9. Kemer
10. Menderes
11. Mimar Sinan
12. Namık Kemal
13. Nine Hatun
14. Oruçreis
15. Tuna
16. Turgut Reis
17. Yavuz Selim
18. Şehitler
19. Yeşil Vadi

Kaynak: Esenler Belediyesi'nin 13 Ocak 2026 tarihli
[`Esenler'e İki Yeni Mahalle Kazandırıldı`](https://esenler.bel.tr/haberler/genel/esenlere-iki-yeni-mahalle-kazandirildi/)
duyurusu, Şehitler ve Yeşil Vadi ile toplam mahalle sayısının 19 olduğunu ve yukarıdaki
güncel listeyi yayımlar.

## Ürün havuzu ve fiyatlar

| Kategori | Beş ortak ürün | Referans demo fiyatları (TL) |
| --- | --- | --- |
| Kırtasiye | A5 Spiralli Defter; A4 Kareli Defter; Mavi Tükenmez Kalem 5'li; A4 Fotokopi Kağıdı 500 Yaprak; Kalem Kutusu | 89,90; 119,90; 74,90; 249,90; 149,90 |
| Elektronik | USB-C Şarj Adaptörü 20W; USB-C Şarj Kablosu 1 m; Kablosuz Mouse; 10.000 mAh Powerbank; Bluetooth Kulaklık | 499,90; 199,90; 449,90; 999,90; 799,90 |
| Gıda | UHT Süt 1 L; Ayçiçek Yağı 1 L; Makarna 500 g; Pirinç 1 kg; Toz Şeker 1 kg | 44,90; 109,90; 34,90; 89,90; 54,90 |
| Ayakkabı | Erkek Günlük Spor Ayakkabı; Kadın Günlük Spor Ayakkabı; Çocuk Spor Ayakkabı; Günlük Terlik; Su Geçirmez Bot | 1.199,90; 1.199,90; 899,90; 349,90; 1.699,90 |

`products.price` bu sabit referans fiyattır. Her mağaza vitrini fiyatı, yalnız sabit
mahalle/mağaza/ürün indeksinden seçilen `-8%, -5%, -3%, +3%, +5%, +8%, +10%`
varyasyonlarından biriyle kuruş üzerinden hesaplanır. Random sayı ve çalıştırma zamanı
kullanılmaz; aynı girdi her zaman aynı fiyatı üretir. `products.stock = 100` yalnız
mevcut ortak ürün şemasının non-zero demo gereksinimidir; per-shop stock uydurulmaz.

Ürün ve vitrin görselleri boş, thumbnail `NULL`, `brand_id = NULL` durumundadır.
Storage upload'u veya dış/copyrighted görsel URL'si yoktur; istemcinin mevcut güvenli
placeholder davranışı kullanılır. Mevcut Home read yolu `is_featured = true` filtresi
kullandığı için 20 demo ürün de aktif ve featured olarak işaretlenir; bu yalnız
discovery görünürlüğüdür, sponsorlu/reklam anlamına gelmez.

## Sentetik mağaza ve güven modeli

- İsim: `[DEMO] <Mahalle> <Kategori>`; 57 isim de unique.
- Adres: `<Mahalle> Mahallesi, Esenler / İstanbul — Demo Konum`; gerçek kapı/sokak
  adresi yok.
- Açıklama, kaydın test/demonstrasyon verisi ve gerçek işletme olmadığını söyler.
- `owner_user_id = NULL`, telefon `NULL`, puan ve puan sayısı `0`.
- Auth/merchant/customer hesabı oluşturulmaz.
- Order, review, shop rating, QR, verified purchase, chat, notification veya analytics
  satırı oluşturulmaz. Server-authoritative güven modeli bypass edilmez.
- Ürünler `attributes = {"demo": true, "demo_seed": "esenler_demo_v1"}` taşır.
  Mağaza ve listing temizliği bu marker'a tek başına dayanmaz; exact UUID manifesti
  otoritedir.

## Konum kaynağı ve güven seviyesi

Merkez noktaları 22 Ağustos 2026'da OpenStreetMap Nominatim sonuçlarından alındı;
manifest her kaydın OSM türünü, kimliğini, doğrudan bağlantısını ve bounding box'ını
saklar. Veri kaynağı ODbL 1.0 kapsamındaki OpenStreetMap katkılarıdır.

Her merkez çevresinde yaklaşık 60 metre uzaklıktaki üç sabit offset kullanılır:

- kuzey: `latitude + 0.00055`;
- doğu: `longitude + 0.00072`;
- batı: `longitude - 0.00072`.

15 Temmuz'dan Yavuz Selim'e kadar ilk 17 mahallede Nominatim'in döndürdüğü OSM idari
poligonları alındı ve üç noktanın tamamı point-in-polygon kontrolünden geçti. Bu kanıt
manifestte `PASS_ALL_THREE_OFFSETS_INSIDE_OSM_POLYGON_2026-08-22` olarak kayıtlıdır.

Yeni Şehitler ve Yeşil Vadi mahalleleri OSM'de sırasıyla
[`node/13596805903`](https://www.openstreetmap.org/node/13596805903) ve
[`node/13596805904`](https://www.openstreetmap.org/node/13596805904) locality center
noktalarıyla mevcuttur; 22 Ağustos 2026 itibarıyla ayrı güncel idari poligon kanıtı
yoktur. Bu iki mahalle datasetten atılmamış, fakat poligon doğrulaması uydurulmamıştır:
`polygon_validation = UNAVAILABLE_NEW_NEIGHBORHOOD_LOCALITY_POINT` ve tüm dataset için
`LOCATION_CONFIDENCE: NEIGHBORHOOD_CENTER` kullanılır. Phase B öncesi resmi/yeni
poligon kaynağı bulunursa aynı source-of-truth generator içinde ayrıca doğrulanmalıdır.

Konumlar gerçek işletme konumu veya gerçek adres değildir.

## Deterministik üretim ve artefaktlar

Sabit namespace UUID `7a4f4b88-9d89-4a34-a226-5bc9807c7392` ve standard UUIDv5
(SHA-1) kullanılır. Stable name'ler seed adı, entity türü ve ilgili slug/parent UUID
bileşimidir. Generator RFC 4122 referans vektörüyle test edilir.

- [`tool/demo_seed/generate_esenler_demo_v1.dart`](../tool/demo_seed/generate_esenler_demo_v1.dart):
  tek kaynak generator.
- [`tool/demo_seed/esenler_demo_v1.json`](../tool/demo_seed/esenler_demo_v1.json):
  19 merkez, bütün satırlar ve exact cleanup ID manifesti.
- [`supabase/seeds/esenler_demo_v1.sql`](../supabase/seeds/esenler_demo_v1.sql):
  transaction, schema/collision preflight, kontrollü insert ve postflight.
- [`supabase/seeds/esenler_demo_v1_cleanup.sql`](../supabase/seeds/esenler_demo_v1_cleanup.sql):
  exact-ID ve dependency-aware cleanup.
- [`tool/demo_seed/validate_esenler_demo_v1.mjs`](../tool/demo_seed/validate_esenler_demo_v1.mjs):
  canonical 0001–0009 → seed → ikinci seed → read → cleanup clean-room replay.

Üretim:

```powershell
E:\Esnaftavar\src\flutter\flutter\bin\cache\dart-sdk\bin\dart.exe tool\demo_seed\generate_esenler_demo_v1.dart
E:\Esnaftavar\src\flutter\flutter\bin\cache\dart-sdk\bin\dart.exe tool\demo_seed\generate_esenler_demo_v1.dart --check
```

`--check`, tracked JSON ve SQL dosyaları fresh generation ile byte-for-byte aynı değilse
başarısız olur.

## Seed idempotency ve cleanup

Seed önce dört canonical tablonun varlığını ve generator count'larını doğrular. Exact
UUID ile mevcut satır varsa bütün kontrollü alanların aynı olmasını ister. Aynı isim,
aynı `(shop_id, product_id)` çifti, aynı deterministic UUID veya demo kategori/ürününe
beklenmeyen ilişki farklı veri taşıyorsa herhangi bir insert başlamadan exception ile
durur. Uyumlu satırlar için `ON CONFLICT (id) DO NOTHING` kullanılır; `DO UPDATE` veya
blind overwrite yoktur. İkinci aynı seed sayıları değiştirmez.

Cleanup başlamadan 4/20/57/285 exact deterministic ID'nin tamamını ve demo marker'ını
assert eder. Ardından şu beklenmeyen ilişkilerden biri varsa hiçbir satırı silmeden
durur: başka katalog/listing ilişkisi, wishlist, legacy order item, review, Cart V2,
QR session/item, verified transaction/item veya shop rating. Silme sırası
`shop_products → shops → products → categories` şeklindedir ve her `DELETE` yalnız
materialized UUID array'ine dayanır. Eksik satır, değişmiş demo marker'ı veya yeni
ilişki bulunursa manuel broad cleanup yapılmaz; durum ayrı incelenir.

## Yerel clean-room doğrulama

Dedicated PGlite harness, Supabase platform şemaları için repo'nun mevcut local shim
yaklaşımını kullanır. `@electric-sql/pglite 0.5.5` repo dışında geçici bir klasöre
kurulmalı; validator o klasöre kopyalanıp repo kökü current directory iken çalıştırılır.
Bu süreç remote Supabase'e bağlanmaz.

Beklenen sonuç:

1. Canonical migration 0001–0009: 9/9.
2. İlk seed: 4 kategori, 20 ürün, 57 mağaza, 285 listing.
3. İkinci seed: aynı sayılar; duplicate yok.
4. Public read/join: 4/20/57/285.
5. Seller comparison: ürün başına 14–15 satıcı ve birden çok fiyat.
6. Auth/trust tabloları: sıfır.
7. Cleanup: demo satırları 0/0/0/0; canonical public tablo sayısı 23.

## Olası Production Phase B prosedürü — bu görevde uygulanmadı

Production apply ancak ayrı, açık owner yetkili görevde yapılabilir:

1. Exact Production proje adı/ref/URL ve Development dışlama iki bağımsız kaynaktan
   doğrulanır; backup/change-window/STOP sahibi kaydedilir.
2. Canonical 0001–0009 ledger/schema ile categories/products/shops/shop_products ve
   ilgili dependency sayıları salt okunur envanterlenir.
3. JSON/SQL artifact commit hash'i, generator `--check`, contract testi ve clean-room
   sonucu doğrulanır.
4. Seed'in collision preflight'ı transaction içinde çalıştırılır. Her mismatch veya
   beklenmeyen real-data ilişkisi `STOP` sebebidir; SQL değiştirilip zorlanmaz.
5. Apply sonrası exact 4/20/57/285 ID sayısı, anonymous public reads, aynı ürün
   satıcı/fiyat karşılaştırması ve konum girdileri doğrulanır.
6. Cleanup yalnız ayrı yetkiyle exact cleanup artifact üzerinden uygulanır; önce
   dependency preflight ve beklenen count zorunludur.

Known limitation: ürün görselleri yoktur; yeni iki mahallenin ayrı idari poligonu henüz
kanıtlanmamıştır; demo mağazaların merchant sahibi ve yönetim ekranı yoktur. Bunlar
Phase A discovery dataset sözleşmesinin bilinçli sınırlarıdır.
