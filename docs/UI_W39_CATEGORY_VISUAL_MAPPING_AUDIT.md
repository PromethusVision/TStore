# W39A-R3.1 — Canonical 24 Category Visual Mapping Audit

Tarih: 2026-09-01

Branch: `ui/w39a-final-ui-foundation-home`

Kapsam: Home kategori görsellerinin semantik doğruluğu; Home kompozisyonu ve taksonomi değişikliği yoktur.

## Sonuç

Kanonik kaynak `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md` ve uygulama
sözleşmesindeki 24 L1 köktür. Aşağıdaki tablo düzeltme sonrası kullanıcıya sunulan
güncel eşlemeyi gösterir. Her kategori tam bir kez yer alır; 24 eşlemenin tamamı
adıyla çözülür ve liste indeksinden bağımsızdır.

| CATEGORY | CURRENT_ASSET | CURRENT_VISUAL_MEANING | SEMANTIC_MATCH | ACTION |
|---|---|---|---|---|
| Gıda & İçecek | `material:restaurant_rounded` | Çatal-bıçak; yiyecek ve içecek | PASS | Kanonik ada açık eşleme kilitlendi. |
| Giyim & Moda | `material:checkroom_rounded` | Askıdaki giysi; giyim ve moda | PASS | Hamburger/sıra fallback'i kaldırıldı; askı simgesi atandı. |
| Ayakkabı | `material:roller_skating_rounded` | Belirgin ayakkabı/patenli ayakkabı silüeti | PASS | Ekmek/koltuk sıra fallback'i kaldırıldı; ayakkabı silüeti atandı. |
| Çanta & Aksesuar | `material:business_center_rounded` | Taşınabilir çanta ve aksesuar | PASS | Et/hamburger sıra fallback'i kaldırıldı; çanta simgesi atandı. |
| Elektronik | `material:devices_rounded` | Telefon ve elektronik ekranlar | PASS | Spa sıra fallback'i kaldırıldı; cihaz simgesi atandı. |
| Bilgisayar & Tablet | `material:computer_rounded` | Bilgisayar ekranı | PASS | Koltuk sıra fallback'i kaldırıldı; bilgisayar simgesi atandı. |
| Beyaz Eşya & Ev Aletleri | `material:kitchen_rounded` | Buzdolabı/elektrikli ev aleti | PASS | Sepet sıra fallback'i kaldırıldı; beyaz eşya simgesi atandı. |
| Ev & Yaşam | `material:chair_rounded` | Koltuk ve ev yaşam alanı | PASS | Önceki doğru görsel açık kanonik eşlemeye taşındı. |
| Züccaciye & Mutfak | `material:flatware_rounded` | Çatal, bıçak ve mutfak gereci | PASS | Ekmek sıra fallback'i kaldırıldı; mutfak gereci simgesi atandı. |
| Yapı, Hırdavat & Tesisat | `material:handyman_rounded` | Çekiç ve anahtar/el aletleri | PASS | Hamburger sıra fallback'i kaldırıldı; hırdavat simgesi atandı. |
| Otomotiv & Motosiklet | `material:directions_car_rounded` | Otomobil/motorlu araç | PASS | Spa sıra fallback'i kaldırıldı; araç simgesi atandı. |
| Kozmetik & Kişisel Bakım | `material:spa_rounded` | Bakım ve kozmetik yaprağı | PASS | Tam kanonik ad için koltuk fallback'i kaldırıldı; bakım simgesi atandı. |
| Anne & Bebek | `material:child_friendly_rounded` | Bebek arabası | PASS | Sepet sıra fallback'i kaldırıldı; bebek arabası atandı. |
| Oyuncak & Hobi | `material:toys_rounded` | Oyuncak/oyun nesnesi | PASS | Yaprak sıra fallback'i kaldırıldı; oyuncak simgesi atandı. |
| Müzik & Enstrüman | `material:piano_rounded` | Piyano tuşları/enstrüman | PASS | Ekmek sıra fallback'i kaldırıldı; piyano simgesi atandı. |
| Spor & Outdoor | `material:fitness_center_rounded` | Dambıl/spor ekipmanı | PASS | Hamburger sıra fallback'i kaldırıldı; spor simgesi atandı. |
| Kitap | `material:menu_book_rounded` | Açık kitap | PASS | Spa sıra fallback'i kaldırıldı; kitap simgesi atandı. |
| Kırtasiye & Ofis | `material:edit_note_rounded` | Kalem ve not satırları | PASS | Koltuk sıra fallback'i kaldırıldı; yazım/not simgesi atandı. |
| Evcil Hayvan Ürünleri | `material:pets_rounded` | Pati/evcil hayvan | PASS | Sepet sıra fallback'i kaldırıldı; pati simgesi atandı. |
| Gözlük & Optik | `material:visibility_rounded` | Göz, görüş ve optik | PASS | Yaprak sıra fallback'i kaldırıldı; optik/görüş simgesi atandı. |
| Saat & Takı | `material:watch_rounded` | Kol saati/takı aksesuarı | PASS | Ekmek sıra fallback'i kaldırıldı; saat simgesi atandı. |
| Sağlık & Medikal | `material:medical_services_rounded` | İlk yardım çantası/medikal ürün | PASS | Hamburger sıra fallback'i kaldırıldı; medikal simge atandı. |
| Çiçek & Bahçe | `material:local_florist_rounded` | Çiçek, bitki ve bahçe | PASS | Anlamı belirsiz spa simgesi kaldırıldı; çiçek simgesi atandı. |
| Hediyelik & Parti | `material:redeem_rounded` | Kurdeleli hediye kutusu | PASS | Koltuk sıra fallback'i kaldırıldı; hediye simgesi atandı. |

## Düzeltme öncesi bulgular

Önceki kod yalnız altı özel/tekrarlanan simge kullanıyor, tanınmayan kategori için
`index % 6` ile görsel seçiyordu. Tam kanonik sıranın gerçek render incelemesinde:

- doğru eşleme: 2 (`Gıda & İçecek`, `Ev & Yaşam`),
- açık semantik hata: 21,
- belirsiz eşleme: 1 (`Çiçek & Bahçe` için `spa_rounded`),
- özellikle görünür Home setinde `Giyim` hamburger, `Elektronik` spa ve `Ayakkabı`
  koltuk görseline kayıyordu.

Tüm 21 hata ve 1 belirsizlik, kategori adını açık semantik kayda bağlayan katalogla
düzeltildi. Mevcut 24 kaydın her biri benzersiz `assetLabel` ve Material icon
codepoint kullanır. İlgisiz kategoriler arasında yinelenen asset yoktur. `Gıda &
İçecek` ile `Züccaciye & Mutfak` görselleri aynı asset değildir; ilki yiyecek
bağlamlı çatal-bıçak, ikincisi üçlü mutfak gereci glyph'idir. Yakın anlam sınırı
etiket ve farklı glyph ile ayrılır.

## Görsel kanıt

- 24/24 temas sayfası:
  `test/widget/shop/goldens/w39a_r31_canonical_24_category_contact_sheet.png`
- Düzeltilmiş canlı Home, 390 px:
  `test/widget/shop/goldens/w39a_r31_home_category_mapping_390.png`

Temas sayfası test kopyası bir çizim üretmez; Home'un kullandığı aynı
`HomeCategoryVisual` bileşenini 24 gerçek katalog kaydıyla render eder. Görsel
incelemede bütün adlar okunur, kesilme/taşma yoktur ve `Giyim & Moda` askıdaki
giysi olarak görünür.

## Sayım ve sözleşme kontrolleri

| Kontrol | Sonuç |
|---|---:|
| Beklenen kanonik kök | 24 |
| Görsel eşleme | 24 |
| Duplicate kategori eşleme | 0 |
| Eksik kategori | 0 |
| İlgisiz duplicate asset | 0 |
| Yanlış görsel | 0 |
| Belirsiz görsel | 0 |

`w39a_category_visual_mapping_golden_test.dart` şu sözleşmeleri otomatik doğrular:

- 24 kanonik kök → 24 dolu ve benzersiz görsel eşleme,
- kanonik ad ve sıranın birebir korunması,
- liste ters çevrilse ve root ID'leri değişse dahi aynı adın aynı görsele gitmesi,
- kanonik köklerde nötr `category_rounded` fallback'ine düşülmemesi,
- `Giyim & Moda` → `checkroom_rounded`.

## Geçici ve final sanat yönü

Semantik eşleme şimdi doğrudur. Bu düzeltme, tutarlı Material rounded glyph'lerini
geçici ama kullanılabilir görsel aile olarak kabul eder. Nihai premium illüstrasyon
kalitesi ayrı `CANONICAL 24 CATEGORY VISUAL PACK` çalışmasında üretilebilir ve aynı
semantik katalog korunarak asset'ler değiştirilebilir. Bu gelecek sanat çalışması
W39A UI foundation'ı bloke etmez.

Home sırası, yatay carousel yapısı, spacing, token, tipografi, ürün alanları ve
navigation kompozisyonu değiştirilmemiştir. Taksonomi ID/ad/sırası değişmemiştir.
