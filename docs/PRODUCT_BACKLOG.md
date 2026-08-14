# EsnaftaVar Product Backlog

## Kaynak ve Kullanım Kuralı

Bu dosya henüz tamamlanmamış ürün ve release işlerinin source-of-truth listesidir.

- `PROJECT_STATE.md` mevcut kod gerçeğini, bu dosya ise tamamlanmamış işleri ve ürün kararlarını taşır.
- Koddan doğrulanmayan bir özellik implemented olarak işaretlenmez.
- Ürün sahibinin kesinleştirmediği business rule uydurulmaz; açık noktalar `TBD` olarak tutulur.
- Eski README ve `NEXT_STEPS` belgeleri tek başına gerçek kaynak kabul edilmez; güncel kod ve bu koordinasyon belgeleri esas alınır.
- Mevcut ürün önceliği müşteri uygulamasıdır.
- Merchant tarafındaki mevcut altyapı korunur; merchant ürün/stok yönetimini genişletmek şu aşamada ana geliştirme önceliği değildir.
- Online ödeme, kargo, klasik checkout ve klasik sipariş akışı hedef EsnaftaVar ürün modeli değildir.
- UI Kit ve kapsamlı görsel yeniden tasarım, temel iş motorları olgunlaştıktan sonra ele alınacaktır.
- Automotive/Services ilk paralel geliştirme dalgasının kapsamında değildir.

## A. CONFIRMED PRODUCT WORK

### A1. Mevcut Müşteri Uygulamasının Ticari Hazırlığı

- Durum: Açık
- Öncelik: Mevcut ana ürün önceliği
- Hedef: Çalışan müşteri discovery, sepet, QR, alışveriş geçmişi, chat, profil ve destek akışlarını ticari kullanıma güvenilir hâle getirmek.
- Kapsam ilkeleri:
  - Loading, empty, error ve success davranışlarını korumak.
  - Duplicate-submit/double-navigation korumalarını sürdürmek.
  - Canlı backend/RLS bütünlüğünü ve kritik entegrasyonları doğrulamak.
  - Klasik online ödeme, kargo veya checkout akışı eklememek.
- 2026-08-11 Wave 1 teknik ilerleme: chat Realtime/reconnect/dedup ve async lifecycle hardening, in-app notification Realtime/pagination/session/mutation hardening ve QR/verified purchase client + RPC contract hardening tamamlandı; birleşik analyzer ve tam test suite geçti.
- 2026-08-11 Wave 2 teknik ilerleme: development/production config sözleşmesi ayrıldı, discovery ekranlarındaki 5 lifecycle/race problemi giderildi ve legacy order aktif müşteri navigation'ı ile DI grafiğinden izole edildi; birleşik analyzer ve tam test suite geçti.
- 2026-08-12 Wave 3 teknik ilerleme: 7 dosyalı canonical Supabase migration zinciri ve 23 tabloluk fresh bootstrap sözleşmesi hazırlandı, banner okuma yolu sertleştirildi, kalan 9 async-context ihlali temizlendi ve global lint etkinleştirildi; birleşik analyzer ve tam test suite geçti. Remote Supabase'e migration uygulanmadı.
- 2026-08-15 Wave 4 teknik ilerleme: Development üzerinde Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime live doğrulamaları geçti; `0008` profile role guard 42883 regresyonunu giderdi; bildirim stream'i geçici kanal hatalarında açık kalacak şekilde düzeltildi. Final entegrasyon hedefli/tam test ve analyzer kapılarını geçti.

### A2. QR Fiziksel Doğrulama Kabulünün Tamamlanması

- Durum: Kod hardening, Development PostgreSQL uygulaması ve gerçek backend concurrent confirm doğrulaması tamamlandı; fiziksel iki cihaz kabulü açık
- Hedef: Müşteri QR oluşturma → merchant QR okutma → merchant onayı → müşteride tamamlanma akışını gerçek hesaplar ve iki fiziksel cihazla doğrulamak.
- Kabul kapsamında kamera izni, yanlış mağaza, süresi dolmuş/iptal edilmiş/kullanılmış QR ve bağlantı gecikmesi davranışları bulunur.

### A3. Reklam Motoru

- Durum: Planlanan gerçek ürün modülü; implementation bulunmuyor
- Bilinen: Mevcut banner gösterimi tam reklam motoru değildir.
- Business rules: **TBD**
- Açık konular: campaign modeli, sponsorlu yerleşimler, hedefleme, bütçe/faturalama, ölçüm, merchant erişimi ve müşteri şeffaflığı.
- Bu ayrıntılar ürün kararı verilmeden uygulanmış varsayılmaz.

### A4. Ödül Çubuğu / Gamification

- Durum: Planlanan gerçek ürün modülü; implementation bulunmuyor
- Bilinen ana model:
  - Kullanıcıya 5 işletmeden alışveriş görevi verilir.
  - İlerleme yalnız doğrulanmış fiziksel alışverişlerle gerçekleşir.
  - Görev zinciri tamamlandığında ödül/alışveriş kuponu kazanılır.
- Ayrıntılı business rules: **TBD**
- TBD alanları: işletme seçimi, tekrar eden işletme kuralı, süre, ilerleme sıfırlama, ödül değeri, kupon geçerliliği, kötüye kullanım önleme ve kampanya finansmanı.
- TBD alanları ürün sahibi tarafından kesinleştirilmeden uygulama davranışı uydurulmaz.

## B. PRODUCT DECISION NEEDED

### B1. Sosyal Login

- Soru: Sosyal login ilk ticari lansmanda gerekli mi?
- Karar verilirse ayrıca hangi sağlayıcıların destekleneceği belirlenmeli.
- Mevcut gerçeklik: Supabase servis metotları var; ekrandaki Google/Facebook düğmeleri işlevsiz.

### B2. Push Notification

- Soru: Push notification ilk ticari lansmanda gerekli mi?
- Mevcut gerçeklik: Supabase tabanlı in-app bildirim sistemi var; FCM/push delivery yok.

### B3. Ürün Yorumu Uygunluğu

- Soru: Ürün yorumları yalnız QR ile doğrulanmış fiziksel ürün alışverişinden sonra mı açılmalı?
- Mevcut gerçeklik: Ürün yorumu eski `delivered orders/order_items`, mağaza puanı yeni QR-doğrulanmış alışveriş modelini kullanıyor.

### B4. Kupon ve Ödül Business Rules

- Kuponun kim tarafından üretileceği ve finanse edileceği: **TBD**
- Hak kazanma, kullanım, süre, minimum koşul ve kötüye kullanım kuralları: **TBD**
- Ödül Çubuğu tamamlanma ödülünün kupon sistemiyle ilişkisi: **TBD**
- Mevcut müşteri kupon ekranı gerçek backend verisine bağlı değil.

### B5. Reklam Motoru Business Rules

- Sponsorlu içerik türleri ve gösterim alanları: **TBD**
- Merchant campaign oluşturma ve onay süreci: **TBD**
- Fiyatlandırma/faturalama modeli: **TBD**
- Hedefleme, sıralama, raporlama ve müşteri şeffaflığı: **TBD**

## C. TECHNICAL / RELEASE WORK

### C1. Gerçek İki Cihaz QR Kabul Testi

- Öncelik: Kritik release doğrulaması
- Müşteri ve merchant için iki ayrı gerçek hesap kullanılmalı.
- Kamera, izin, QR üretme, okutma, onay, polling ve tamamlanma birlikte doğrulanmalı.
- Canlı veri silinmemeli; güvenli ve geri alınabilir test verisi kullanılmalı.

### C2. Backend Integration Test Eksikleri

- Wave 4 tamamlanan Development doğrulamaları: Auth signup/session, otomatik profil/legal consent, own/cross-user/anon RLS, saved locations/addresses/wishlist, merchant/admin escalation reddi; QR create/confirm/negative state'ler/immutable snapshot/gerçek concurrency; Chat ve Notifications Realtime delivery/isolation/reconnect/dedup/lifecycle.
- Fiziksel kamera ve iki cihaz QR kabulü C1 altında açık kalır.
- Ürün yorumu eligibility kararı ve bunun legacy `orders/order_items` bağı C4/B3 altında açıktır; karar verilmeden rating/review modeli genişletilmez.
- Production-like e-posta doğrulama/SMTP kabulü, Confirm Email'in kapalı olduğu Development live testlerinden ayrı bir release kapısıdır.

### C3. RLS ve Canlı Schema Doğrulaması

- Fresh bootstrap için resmi kaynak `supabase/migrations/` altındaki `0001`–`0008` canonical zinciridir; kökteki eski schema ve migration dosyaları tarihsel referans olarak kalır.
- Eski audit modelindeki 25 tablo ile canonical 23 tablo farkı kapatıldı: aktif repository kullanımı olmayan legacy `cart_items` ve backend'e bağlanmamış `coupons` canonical zincire alınmadı. `orders/order_items`, ürün yorumu kararı verilene kadar korundu.
- Canonical `0001`–`0008` zinciri doğrulanmış Development Supabase'e uygulandı; 23 public tablo, 23/23 RLS, 55 policy, grant/trigger/RPC ve `SECURITY DEFINER` envanteri audit edildi.
- Canonical QR RPC'leri gerçek Development PostgreSQL üzerinde state geçişi ve concurrent confirm ile doğrulandı; Production'a migration uygulanmadı ve Wave 4 final entegrasyonu remote yazma yapmadı.
- `product-images`, `category-images`, `brand-logos`, `banner-images`, `avatars` ve `review-images` için visibility/write/ownership/MIME/size/delete ürün kararlarını alıp ayrı least-privilege migration hazırlamak.
- Production üzerinde destructive işlem kullanıcı onayı olmadan yapılmaz.

### C4. Legacy Order / Shipping / Payment Teknik Borcu

- Legacy order repository/Cubit ve shipping/payment alanları aktif müşteri navigation'ından ve GetIt DI grafiğinden izole edildi.
- Legacy dosyalar, tablolar, veriler ve testler kaldırılmadı; tam kaldırma tamamlanmış sayılmaz.
- Gelecekte kaldırma veya arşivleme, mevcut referanslar ve veri etkisi analiz edildikten sonra ayrı görev olarak ele alınır.
- Ürün yorumu eligibility'sinin legacy `orders/order_items` bağı ayrı ürün kararı olarak açıktır.

### C5. Environment Ayrımı

- Development/production Dart-define ad alanları ayrıldı; sessiz fallback kaldırıldı ve eksik/placeholder/güvensiz/server-only config startup'ta güvenli biçimde reddediliyor.
- `.env` Flutter asset paketinden çıkarıldı; aktif uygulama source taramasında hardcoded Supabase URL/JWT ve çalışma alanında geçici `.env` placeholder bulunmadı.
- Release gate: gerçek client-safe development ve production değerleriyle iki entrypoint için smoke build alınmalı; production backend'e güvenli değer olmadan bağlanılmamalı.

### C6. Lint ve Navigation Lifecycle Borcu

- Discovery ekranlarındaki Wave 2 kapsamlı lifecycle/race düzeltmeleri tamamlandı.
- Wave 3'te `helper_functions.dart`, `location_helper.dart` ve `product_sellers_section.dart` içindeki kalan 9 ihlal lifecycle/dispose ve duplicate-navigation korumalarıyla düzeltildi.
- `use_build_context_synchronously` global ignore'u kaldırıldı; lint repo genelinde etkin ve analyzer temiz.
- Mevcut duplicate-submit/double-navigation korumaları korunmalı.

### C7. Eski Dokümantasyonun Güncellenmesi

- Wave 2'de README, `NEXT_STEPS.md`, `KNOWN_ISSUES.md` ve yeni `docs/LEGACY_ORDER_ISOLATION.md` legacy order sınırını güncel kod gerçeğine göre belgeledi.
- Diğer eski planların güncel kodla çelişen bölümleri ortaya çıktıkça belirlenmeli.
- Bu üç koordinasyon belgesi source-of-truth olarak korunmalı.
- Eski belgeler gerçek kod durumu doğrulanmadan otomatik kopyalanmamalı.

### C8. Test ve Release Sağlığı

- 2026-08-11 Wave 1 birleşik sonucu: `flutter analyze --no-pub` temiz ve tam Flutter test suite başarılı. Hedefli kanıtlar: chat 97/97, notifications 53/53, cart/QR/purchases 138/138, settings/navigation 34/34.
- 2026-08-11 Wave 2 birleşik sonucu: `flutter analyze --no-pub` temiz ve tam Flutter test suite başarılı. Hedefli kanıtlar: environment/config 11/11, discovery/shop 344/344, legacy mimari + unit 22/22, Cart V2/QR 94/94.
- 2026-08-12 Wave 3 birleşik sonucu: `flutter analyze --no-pub` temiz ve 108 dosyalık tam Flutter test suite başarılı. Hedefli kanıtlar: canonical migration 13/13, QR release contract 3/3, banner 22/22, async-context 32/32, chat 97/97, notifications 53/53, cart/QR/purchases 157/157 ve discovery/navigation 412/412.
- 2026-08-15 Wave 4 final sonucu: Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime gated live harness'ları entegre edildi; hedefli 998/998, tam Flutter suite 1069/1069 ve analyzer geçti. Integration live rerun'u client-safe değer bulunmadığı için yapılmadı; bağımsız üç live sonuç PASS.
- Büyük view dosyalarının conflict/testability riskini görev bazında azaltmak; geniş refactor'ı ayrı ve kontrollü yürütmek.
- Release öncesinde working tree, migration durumu ve canlı kabul sonuçlarını birlikte raporlamak.

## Güncelleme Kuralı

- Ürün sahibi karar verdiğinde ilgili madde `PRODUCT DECISION NEEDED` bölümünden onaylı işe taşınır ve karar metni açıkça kaydedilir.
- Kod tamamlandığında madde doğrudan silinmez; doğrulama ve release sonucu kaydedildikten sonra tamamlandı olarak işaretlenir veya geçmiş kaynağına taşınır.
- Production agentlar backlog'u geniş çapta yeniden yazmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
