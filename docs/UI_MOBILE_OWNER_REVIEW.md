# Customer UI — Mobil Owner Hızlı Karar Paketi

Bu belge Wave 27'deki aynı 15 kök kararı sadeleştirir. `ÖNERİLEN` alanı tavsiyedir;
seçilmiş cevap veya Product Owner final kararı değildir.

## UI-R01 — Marka Renk Rolleri

SORU: Ana aksiyon rengi teal/yeşil mi, terracotta mı olmalı?

ÖNERİLEN: A

NEDEN:

- Wave 27 yönüyle uyumlu.
- Home'daki petrol yaklaşımını korur.
- Terracotta sıcak vurgu olarak kalır.

A: Teal/yeşil primary, terracotta accent olur; mevcut Figma token rolleri hizalanır.

B: Terracotta primary, teal accent kalır; Wave 14 görsel yönü korunur.

C: İki rol de yeniden çalışılır; rollout yeni palette kadar bekler.

ETKİLEDİĞİ: Tüm ekranlar; tokenlar, butonlar, navigasyon, durum renkleri

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: HIGH

CEVAP FORMATI: `UI-R01=A`

---

## UI-R02 — Pilot Dark Mode

SORU: Pilot dark mode olmadan, tutarlı light mode ile çıkabilir mi?

ÖNERİLEN: A

NEDEN:

- Pilot kapsamını küçültür.
- Eski dark tema karışmasını önler.
- Dark mode ayrı kalite dalgası olabilir.

A: Pilot açıkça light-only olur; dark mode sonraki dalgaya bırakılır.

B: Light ve dark birlikte tamamlanır; süre ve test kapsamı büyür.

C: Sistem modu eski dark görsellerle kalır; final UI tutarlılığı bozulur.

ETKİLEDİĞİ: Tüm ekranlar; ThemeData, tokenlar, golden ve fiziksel kabul

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: HIGH

CEVAP FORMATI: `UI-R02=A`

---

## UI-R03 — Kritik Keşif Ekranları

SORU: Home, listeleme ve ürün/satıcı yönü C1 kontrolleriyle onaylanabilir mi?

ÖNERİLEN: A

NEDEN:

- Yerel ticaret modeline uyuyor.
- Ana vitrin akışını açıyor.
- Baştan tasarım gecikmesini önlüyor.

A: Mevcut yön C1 düzeltmeleri doğrulanarak kullanılır.

B: Yalnız belirtilen alanlarda sınırlı revizyon yapılır.

C: Kritik ekran yönü yeniden tasarlanır; rollout belirgin biçimde uzar.

ETKİLEDİĞİ: Home, Category/Product Listing, Product Details, Seller Comparison

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: HIGH

CEVAP FORMATI: `UI-R03=A`

---

## UI-R04 — Shop Details Ana Aksiyonu

SORU: Shop Details ekranında hangi aksiyon en güçlü görünmeli?

ÖNERİLEN: A

NEDEN:

- Fiziksel mağaza etkileşimini öne çıkarır.
- Online sipariş beklentisi üretmez.
- Yerel keşfi gerçek ziyarete bağlar.

A: Yol tarifi/fiziksel ziyaret primary, ürünler içerik, chat secondary olur.

B: Mağaza ürünleri primary olur; fiziksel ziyaret daha geri planda kalır.

C: Chat primary olur; mağaza ziyareti ve ürün keşfi ikinci plana düşer.

ETKİLEDİĞİ: Shop Details; merchant header, CTA grubu, ürün listesi

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R04=A`

---

## UI-R05 — Cart V2 Anlatımı

SORU: Cart V2 müşteriye hangi ürün anlamıyla sunulmalı?

ÖNERİLEN: A

NEDEN:

- Tek mağaza kuralını açıklar.
- Sepeti fiziksel alışveriş hazırlığı olarak tutar.
- Checkout/ödeme beklentisini önler.

A: Tek mağazalı fiziksel alışveriş hazırlığı, tahmini toplam ve QR eğitimi gösterilir.

B: Genel sepet görünümü kullanılır; yerel ürün farkı daha az anlaşılır.

C: Checkout benzeri ilerleme kullanılır; canonical ürün modeliyle çelişir.

ETKİLEDİĞİ: Cart V2; CartItem, toplam, mağaza çakışması, QR sheet

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: HIGH

CEVAP FORMATI: `UI-R05=A`

---

## UI-R06 — Guest AuthGuard

SORU: Korunan aksiyon isteyen misafire giriş gereksinimi nasıl anlatılmalı?

ÖNERİLEN: A

NEDEN:

- Giriş nedenini açıklar.
- Vazgeçme ve devam etme davranışını korur.
- Özellik başına yeni auth akışı üretmez.

A: Kısa bağlamsal açıklama gösterilir, sonra mevcut login açılır.

B: Açıklama olmadan login'e yönlendirilir; müşteri bağlamı kaybedebilir.

C: Her özellik ayrı auth sunumu kullanır; deneyim ve bakım parçalanır.

ETKİLEDİĞİ: BottomNav, wishlist, cart, chat, review, location ve login

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R06=A`

---

## UI-R07 — Kart Yoğunluğu

SORU: 390 px ekranda ürün ve kategori kartları ne kadar yoğun olmalı?

ÖNERİLEN: A

NEDEN:

- Uzun Türkçe içeriği taşır.
- Fiyatla birlikte yerel bulunabilirliği gösterir.
- Taramayı hızlandırırken bilgiyi korur.

A: Dengeli iki satır içerik, esnaf sayısı ve bulunabilirlik gösterilir.

B: Çok kompakt fiyat-first kartlar kullanılır; yerel bağlam azalır.

C: Geniş editorial kartlar kullanılır; ekranda daha az ürün görünür.

ETKİLEDİĞİ: Home, listing, wishlist, recent; ProductCard, CategoryCard/Row

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: HIGH

CEVAP FORMATI: `UI-R07=A`

---

## UI-R08 — Eksik Görsel ve İkonlar

SORU: Eksik ürün görselleri ve ikonlar hangi görsel dili kullanmalı?

ÖNERİLEN: A

NEDEN:

- Mevcut bağımlılıklarla uygulanabilir.
- Ürün fotoğraflarını gölgede bırakmaz.
- Tutarlı ve düşük risklidir.

A: Sade warm-neutral fallback ve tek Iconsax-led ikon sistemi kullanılır.

B: İllüstratif fallback ve karışık ikonlar kullanılır; kapsam büyür.

C: Yalnız metin fallback kullanılır; taranabilirlik ve polish azalır.

ETKİLEDİĞİ: Product/category/banner/shop media; MediaFrame, icon actions

PILOT ETKİSİ: MEDIUM

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R08=A`

---

## UI-R09 — Hareket Seviyesi

SORU: Pilot UI ne kadar animasyonlu olmalı?

ÖNERİLEN: A

NEDEN:

- Durum değişimini anlaşılır kılar.
- Erişilebilirlik ve performansı korur.
- Gösterişli animasyon kapsamını önler.

A: Kısıtlı işlevsel geçişler ve reduced-motion desteği kullanılır.

B: Kart/hero animasyonları eklenir; süre ve hata yüzeyi büyür.

C: Hareket neredeyse tamamen kaldırılır; polish daha sade kalır.

ETKİLEDİĞİ: Navigation, loading/state, cards, dialogs ve sheets

PILOT ETKİSİ: LOW

IMPLEMENTATION ETKİSİ: LOW

CEVAP FORMATI: `UI-R09=A`

---

## UI-R10 — Türkçe Müşteri Dili

SORU: Uygulamanın müşteriye konuşma tonu nasıl olmalı?

ÖNERİLEN: A

NEDEN:

- Mahalle ticareti kimliğini destekler.
- Developer/generic marketplace metnini azaltır.
- Hata ve ilk kullanım mesajlarını sadeleştirir.

A: Sıcak, kısa ve anlaşılır mahalle ticareti Türkçesi kullanılır.

B: Daha resmi kurumsal Türkçe kullanılır; sıcaklık azalır.

C: Promosyon ağırlıklı marketplace dili kullanılır; ürün ayrışması zayıflar.

ETKİLEDİĞİ: Home, auth, loading/empty/error, Cart, review ve support metinleri

PILOT ETKİSİ: MEDIUM

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R10=A`

---

## UI-R11 — Güven ve Gelecek Sinyalleri

SORU: Doğrulanmış alışveriş ve henüz aktif olmayan özellikler nasıl gösterilmeli?

ÖNERİLEN: A

NEDEN:

- Gerçek güven kanıtını görünür tutar.
- Ads/Reward varmış izlenimi oluşturmaz.
- Görsel gürültüyü sınırlar.

A: Verified badge net ama kompakt olur; dormant sinyaller gizlenir.

B: Güven dekorasyonu büyütülür ve gelecek placeholder'ları gösterilir.

C: Tüm güven/future sinyalleri gizlenir; doğrulama değeri görünmez olur.

ETKİLEDİĞİ: Reviews, purchases, product/shop trust, StatusChip ve VerifiedBadge

PILOT ETKİSİ: MEDIUM

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R11=A`

---

## UI-R12 — Pilot Öncesi Erteleme Sınırı

SORU: Kritik ekranlar tamamlandıktan sonra hangi görsel işler bekleyebilir?

ÖNERİLEN: A

NEDEN:

- Ana vitrini yüksek kalitede tutar.
- Kullanılabilir ikincil ekranları korur.
- Sonsuz polish gecikmesini önler.

A: Düşük trafikli dekorasyon ve V3 kozmetik işler pilot sonrasına bırakılır.

B: Tüm ekranlar eşit polish almadan pilot başlamaz; süre uzar.

C: Yalnız kritik ekranlar düzeltilir; ikincil rotalar belirgin biçimde tutarsız kalır.

ETKİLEDİĞİ: Secondary screens, Wave 9/10, defect/deferment ledger

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R12=A`

---

## UI-R13 — Tablet Kapsamı

SORU: Pilot için özel tablet ekranları gerekli mi?

ÖNERİLEN: A

NEDEN:

- Büyük ekranda güvenli kullanım sağlar.
- İkinci tasarım sistemi oluşturmaz.
- Telefon odaklı pilotu geciktirmez.

A: Güvenli max-width/centered davranış yeterli kabul edilir.

B: Özel tablet kompozisyonları hazırlanır; tasarım ve test kapsamı büyür.

C: Telefon düzeni kontrolsüz gerilir; büyük ekran kalitesi düşer.

ETKİLEDİĞİ: Tüm screen shell/grid yapıları ve responsive acceptance

PILOT ETKİSİ: LOW

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R13=A`

---

## UI-R14 — K'pasa ve Merchant Tutarlılığı

SORU: K'pasa referansı ve Customer/Merchant ortaklığı ne kadar ileri gitmeli?

ÖNERİLEN: A

NEDEN:

- Marka temeli ortak kalır.
- Customer daha yüksek polish taşıyabilir.
- Ekranları zorla aynılaştırmaz.

A: Semantic temel paylaşılır, rol bazlı component ve ekranlar ayrışır.

B: Customer ve Merchant neredeyse aynı görünür; operasyonel farklar zayıflar.

C: Sistemler bağımsız tasarlanır; marka ve bakım tutarlılığı azalır.

ETKİLEDİĞİ: Token/primitives, K'pasa mapping, future Merchant alignment

PILOT ETKİSİ: LOW

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R14=A`

---

## UI-R15 — Final Görsel Onay Kanıtı

SORU: UI'nin final kabul edilmesi için hangi kanıt zorunlu olmalı?

ÖNERİLEN: A

NEDEN:

- “Final” durumunu tekrarlanabilir yapar.
- Figma ile gerçek artifact farkını yakalar.
- Responsive ve erişilebilirliği korur.

A: Sabit Figma frame'leri, exact Flutter artifact ve responsive/state/a11y kanıtı gerekir.

B: Yalnız Figma onayı yeterli olur; runtime farkları gözden kaçabilir.

C: Yalnız öznel cihaz incelemesi yapılır; kabul ölçütü tekrarlanamaz.

ETKİLEDİĞİ: Tüm rollout acceptance, golden manifest, release artifact ve visual freeze

PILOT ETKİSİ: HIGH

IMPLEMENTATION ETKİSİ: MEDIUM

CEVAP FORMATI: `UI-R15=A`
