# W45A — Tier A görsel prototip paketi

Durum: **PRODUCT OWNER VISUAL BATCH REVIEW — üç prototip hazır, onay bekleniyor**.

## Görev ve sınır

- Astra Calibration Wave 1A; fresh GPT-6 Astra Design Owner oturumu.
- Başlangıç HEAD: `6b89d84a80302444c14bf3c985ccdeb6a4ba953f`.
- Fetch sonrası doğrulanan base: `origin/main@4287972429d9befe4ef2637a565ea6d8a2393a5e`.
  Remote main daha yeni değildi. Başlangıç çalışma ağacı temizdi.
- Branch: `astra-ui/w45a-tier-a-prototype-batch-1`.
- Worktree: `C:/Users/Mustafa/.codex/worktrees/6e1f/TStore_CLEAN`;
  Git ortak dizini yetkili `E:/Esnaftavar/Esnaftavar_chatgpt/TStore_CLEAN/.git`.
- Eşit ağırlıklı kapsam: FS-19 Shop Details, FS-20 Cart V2, FS-18 Nearby.
  Üçü denendi, üçü tamamlandı: **3/3, %100 prototip teslimi**.
  Bu oran Final UI closeout veya kalan 54 dönüşüm biriminin kapanışı değildir.
- Her view için `visualPrototype: false` varsayılanı korunur. Prototipi görmek
  için yalnız ilgili view constructor'ında `visualPrototype: true` gerekir.
  Navigation shell, mevcut caller'lar ve bootstrap bunu etkinleştirmez.
- Sunumlar ayrı Dart `part` dosyalarındadır. Böylece mevcut private eylemler ve
  korumalar tekrar yazılmadan tüketilir; repository/Cubit/domain değişikliği yoktur.
- Görüntüler gerçek Flutter render'larıdır: **390 × 844**, Poppins, light theme.
  İçerik yalnız test fixture'ıdır; marka görselleri mevcut repo asset'leridir.
  Production veya kullanıcı hesabı verisi alınmadı.

## SHOP DETAILS — FS-19

![Shop Details](../test/widget/shop/goldens/w45a_shop_details_390.png)

- Eski büyük profil hero'su ve art arda iletişim kartları yerine kompakt mağaza
  kimliği, puan, açıklama ve ziyaret kartı kullanıldı.
- Adres/çalışma saatleri ile **Yol tarifi al** ana eylemi aynı mint yüzeyde.
  Ara ve Esnafa yaz, bilgi/receiver varsa ikincil outlined eylemlerdir.
- Ürünler ilk 390 px görünümde yer alır; mağazanın listing fiyatı ve gerçek
  availability alanı korunur. Görseli olmayan üründe dürüst fallback vardır.
- `isActive`, çalışma saatine göre açık/kapalı anlamına çevrilmedi. Uydurma
  mesafe, açık mağaza, rezervasyon veya sipariş bilgisi eklenmedi.
- Mevcut koordinat/adres fallback'i, harita URI'si, telefon hedefi, login/pending
  chat ve product navigation/double-tap koruması aynı metotlarda kalır.
- Shared reuse: Scaffold, SectionHeader, StateCard, SurfaceIconButton,
  RoundedImage ve authoritative W39 token/theme.
- Hedefli testler: **19 PASS** (5 yeni prototip testi + 14 mevcut profile testi).
  Görsel üretimi, varsayılan kapalı flag, adres hedefi, product handoff, chat
  receiver ve eksik konumun eylem üretmemesi doğrulandı; mevcut smoke da geçti.
- Owner sorusu: Ziyaret kartı → ikincil iletişim → ürünler hiyerarşisi bu ekranın
  görsel yönü olarak onaylanıyor mu?
- Checkpoint: `8276d8d`, task branch'ine push başarılı.

## CART V2 — FS-20

![Cart V2](../test/widget/shop/goldens/w45a_cart_v2_390.png)

- **Sepet** başlığı ve “Mağazadan almak için hazırladığın ürünler” açıklaması
  fiziksel alışveriş amacını baştan açıklar.
- Mağaza kimliği/adresi tek bağlam kartında; her satırda tekrar edilmez.
  “Sepetin tek bir mağazaya ait” metni mevcut single-shop sözleşmesini gösterir.
- Kompakt ürün görseli/adı, birim fiyat, satır toplamı, adet ve kaldırma eylemi.
  Mevcut quantity/confirmation/pending guards ve güncellenmiş fiyat kontrolü
  aynen kullanılır. Kullanılamayan ürün, mevcut recovery kartına gider.
- Ürün tutarı mevcut `CartV2Loaded.totalAmount` üzerinden hesaplanır. Yerel
  fiyat yazımı `tr_TR` kullanır. Checkout/payment/order/shipping eylemi eklenmedi.
- Var olan **Mağazada göster** eylemi ikincil outlined QR eylemi olarak,
  “Mağazaya gittiğinde” bağlamında korunur. QR sheet ve Purchases handoff değişmez.
- Gerçek Cart runtime'ında Shop Details/ziyaret navigation'ı yoktur; bu görev
  yeni bir mağaza hedefi icat etmez. Mağaza bilgisi mevcut ilk listing'den gelir.
- Shared reuse: SectionHeader, SurfaceIconButton, RoundedImage, mevcut
  quantity/unavailable widgets ve W39 token/theme; dependency değişikliği yok.
- Hedefli testler: **27 PASS** (6 yeni prototip testi + 21 mevcut Cart testi).
  Görsel, default-off, exact quantity/remove hedefi, remove/clear confirmation,
  tekrar mutation koruması ve refresh → doğru cart ID ile mevcut QR sheet geçti.
- Owner sorusu: Tek mağaza bağlamı ve ikincil QR yerleşimi fiziksel alışveriş
  hazırlığını yeterince açık anlatıyor mu?
- Checkpoint: `39a8653`, task branch'ine push başarılı.

## NEARBY / LOCATION — FS-18

![Nearby / Location](../test/widget/shop/goldens/w45a_nearby_location_390.png)

- Final Home'un hafif konum satırı, mint işareti ve kompakt esnaf keşfi dili
  kullanıldı. Harita veya yeni arama/filter capability'si eklenmedi.
- Kayıtlı konum adı ve yakınlık sıralama bağlamı üstte; daha yoğun üç mağaza
  kartı adres, puan, açıklama ve **Mağazayı gör** eylemlerini birlikte sunar.
- Mesafe yalnız ready state'in mevcut mesafe map'inden ve
  `CustomerProximityHelper.formatDistance` üzerinden gösterilir. Eksik/negatif/
  geçersiz değerlerden mesafe üretilmez. Fixture mesafeleri sentetik koordinatlar
  üzerinde mevcut hesaplayıcıyla türetilir; gerçek cihaz ölçümü değildir.
- Nearby'nin doğrudan ürün listesi yoktur: keşif Shop Details → ürün detayı
  üzerinden ilerler. Mevcut cart auth gate, shop guard, refresh ve navigation korunur.
- Kayıtlı konum seçimi yalnız mevcut saved-ready koşulunda aktiftir. Seçimden
  dönüşte aynı Cubit yeniden yüklenir. Device-ready durumda selector veya yeniden
  GPS alma davranışı icat edilmez.
- İncelenen bitişik yüzeyler: Nearby consent (MD-19), idle/requesting/ready,
  denied/denied-forever/service-disabled/timeout/unavailable, ayar dönüşü;
  Saved Locations (FS-24), add/current-location/save/delete (MD-08/09), Home
  location bar ve LocationHelper/helper dialogs (MD-01–04). Bunlar yeniden
  tasarlanmadı; bu gate'in tek temsilî görüntüsü Nearby saved-ready durumudur.
- Mevcut konum servisi bir defalık istek/cache ve saved preference tüketir.
  İzin/consent veya kalıcı izleme davranışı değişmedi; startup'ta yeni GPS isteği yok.
- Shared reuse: SectionHeader, SurfaceIconButton ve W39 token/theme;
  ekranın mevcut storefront fallback görseli küçültülerek tüketildi.
- Hedefli testler: **61 PASS** (7 yeni prototype + mevcut Nearby view/Cubit).
  Konum seçimi dönüşü, explicit consent, permission-denied keşfi,
  service-disabled ayar hedefi, shop/cart hedefleri ve bilinmeyen mesafe geçti.
- Owner sorusu: Home ile uyumlu bu konum satırı ve üç mağazalık yoğunluk,
  Yakınındakiler ana kompozisyonu olarak onaylanıyor mu?
- Checkpoint: bu raporu içeren `feat(ui): add opt-in Nearby discovery prototype`
  commit'i; kesin SHA görev sonuç raporunda belirtilir.

## Test kanıtı ve final gate

Çalıştırılan komutlar (repo kökünden):

```text
flutter test --no-pub --update-goldens test/widget/shop/w45a_shop_profile_prototype_test.dart test/widget/shop/shop_profile_view_test.dart
flutter test --no-pub --update-goldens test/widget/cart/w45a_cart_prototype_test.dart test/widget/cart/cart_v2_view_test.dart
flutter test --no-pub --update-goldens test/widget/shop/w45a_nearby_prototype_test.dart test/widget/shop/nearby_view_test.dart test/unit/shop/nearby_shops_cubit_test.dart
flutter analyze --no-pub
git diff --check
```

- **107 hedefli test PASS**, üç yeni PNG ayrıca açılıp görsel olarak incelendi.
- Analyzer: **No issues found**, 30,7 saniye. Test başarısızlığı/düzeltmesi yok.
- Diff whitespace kontrolü **PASS**. Eklenen 1.873 metin satırında private key,
  access token, JWT, credential assignment, e-posta, telefon ve kimlik numarası
  örüntüleri **0 bulgu** verdi. Fixture ID/isim/adresleri ayrıca incelendi;
  test amaçlıdır. Bu kontrol özel bir security audit iddiası değildir.
- Kullanıcı sözleşmesi bu görsel gate'te protokolün full-suite varsayımını
  açıkça erteler: **full Flutter suite çalıştırılmadı**. Yeni 320/430, state/golden
  matrix veya dark mode üretilmedi. Mevcut hedefli test dosyaları değiştirilmedi;
  içerdikleri eski responsive/guard kontrolleri aynı smoke içinde geçti.
- Gerçek cihaz GPS/OS, Production, tam regresyon ve owner görsel kabulü bu
  sonuçla doğrulanmış sayılmaz. Görsel onay sonrası closeout ayrı aşamadır.

## PACKAGE METRICS / CALIBRATION

- Ölçüm: **2026-09-05 02:58:58 → 03:16:50 Europe/Istanbul**, **17 dk 52 sn**.
  Gözlem başlangıç doküman okumasından test/analyzer ve ilk secret taramasının
  sonuna kadardır; araç beklemelerini içerir, son docs commit/push süresini içermez.
- Dosyalar: **13** = 3 mevcut view seam'i + 3 yeni presentation part +
  3 prototip test dosyası + 3 PNG + bu rapor. Backend/config/shared-core: **0**.
- Checkpoint'ler: Shop Details, Cart V2, Nearby; normal task-branch push.
  Main merge/push veya force push yapılmadı.
- Figma sınıfı: her üç ana yüzey **FIGMA_HEAVY**. Fiilî erişim: **0 çağrı**,
  `FIGMA_ACCESSED: NO`. Yeni kompozisyonlar için entegre Final Home ve Seller
  Comparison PNG'leri/kodu yeterliydi; eski Figma'ya tekrar okuma veya yazma yok.
- `SHARED_COMPONENT_CHANGE_REQUIRED: NO`; shared component çakışması **NONE**.
  `lib/core/ui`, ortak theme, navigation, model, Cubit, service ve pubspec değişmedi.
- Blocker: **NONE**. İlk sandbox Git/SDK kısıtları normal yetkili tool escalation
  ile çözüldü; Product Owner kararı hiçbir bağımsız prototipi bloke etmedi.
- Calibration: **GREEN** — %100 prototip kapsamı, hedefli testlerde kritik
  regression yok, scope drift yok, substantive owner correction **0**.
  Bu sınıf final release kabulü veya karşılaştırmalı model benchmark'ı değildir.
- Öneri: **SAME_SIZE**, üç Tier A owner-gate prototipi. İlk tek ölçüm kapsam
  artırma iddiası için yeterli değildir; görsel owner geri bildirimi beklenir.
- Bu rapor Integration/Coordinator için calibration giriş kanıtıdır;
  paylaşılan `ASTRA_CALIBRATION_LOG.md` worker tarafından değiştirilmedi.

```text
SHOP_DETAILS_PROTOTYPE_READY: YES
CART_V2_PROTOTYPE_READY: YES
NEARBY_LOCATION_PROTOTYPE_READY: YES
FIGMA_QUOTA_BLOCKER: NO
FULL_REGRESSION_RUN: NO
READY_FOR_PRODUCT_OWNER_VISUAL_BATCH_REVIEW: YES
```
