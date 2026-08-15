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
- 2026-08-15 Wave 5 teknik ilerleme: gerçek client-safe Development değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure smoke PASS; Storage contract ve review eligibility/legacy order auditleri entegre edildi. Review için Option A FINAL kaydedildi; uygulama yapılmadı. Hedefli 169/169, tam 1069/1069 test ve analyzer geçti.
- 2026-08-15 Wave 6 teknik ilerleme: FINAL Option A canonical `0009` backend ve RPC-only istemciyle uygulandı; aktif üç public-read Storage bucket ve exact versioned controlled-path istemci çözümlemesi tamamlandı. Development live review lifecycle 3/3, fixture cleanup residual `0`, hedefli 189/189, tam 1106/1106 test ve analyzer PASS oldu.

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

### A5. Ürün Yorumu Uygunluğu — FINAL Option A

- Durum: Ürün kararı **FINAL**; backend/client implementasyonu ve Development canlı doğrulaması tamamlandı.
- Yalnız merchant tarafından doğrulanmış, server-authoritative fiziksel QR alışverişi ve o işlemdeki ilgili ürün satırı review/rating eligibility verir.
- Ürün görüntüleme, sepete ekleme ve yalnız QR oluşturma eligibility vermez.
- Canonical `0009`, verified transaction item üzerinde durable `product_id` ile immutable purchase snapshot/evidence sözleşmesini kurar. Eligibility legacy `orders/order_items` verisini veya client-provided verified flag'i kabul etmez.
- Müşteri/canonical ürün başına bir aktif yorum vardır; duplicate/concurrent submit mevcut satırı değiştirmeden `created: false` döndürür. Owner rating/title/comment alanlarını güncelleyebilir, yorumu silebilir ve durable evidence kaldığı sürece yeniden oluşturabilir; expiry yoktur.
- Korunan legacy yorumlar otomatik backfill edilmez, doğrulanmamış kalır ve verified aggregate'lere katılmaz. UI'daki verified bilgi yalnız server response'undan gelir. Mağaza puanı mevcut doğrulanmış QR akışında server-authoritative çalışmayı sürdürür.

## B. PRODUCT DECISION NEEDED

### B1. Sosyal Login

- Soru: Sosyal login ilk ticari lansmanda gerekli mi?
- Karar verilirse ayrıca hangi sağlayıcıların destekleneceği belirlenmeli.
- Mevcut gerçeklik: Supabase servis metotları var; ekrandaki Google/Facebook düğmeleri işlevsiz.

### B2. Push Notification

- Soru: Push notification ilk ticari lansmanda gerekli mi?
- Mevcut gerçeklik: Supabase tabanlı in-app bildirim sistemi var; FCM/push delivery yok.

### B3. Kupon ve Ödül Business Rules

- Kuponun kim tarafından üretileceği ve finanse edileceği: **TBD**
- Hak kazanma, kullanım, süre, minimum koşul ve kötüye kullanım kuralları: **TBD**
- Ödül Çubuğu tamamlanma ödülünün kupon sistemiyle ilişkisi: **TBD**
- Mevcut müşteri kupon ekranı gerçek backend verisine bağlı değil.

### B4. Reklam Motoru Business Rules

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
- Ürün yorumu Option A backend/client implementasyonu ve normal Auth Development live lifecycle doğrulaması tamamlandı; unverified submit `42501 [REVIEW_NOT_VERIFIED]` ile reddedildi ve create/duplicate/update/delete/recreate aggregate yenilemesi geçti.
- Production-like e-posta doğrulama/SMTP kabulü, Confirm Email'in kapalı olduğu Development live testlerinden ayrı bir release kapısıdır.

### C3. RLS ve Canlı Schema Doğrulaması

- Fresh bootstrap için resmi kaynak `supabase/migrations/` altındaki `0001`–`0009` canonical zinciridir; kökteki eski schema ve migration dosyaları tarihsel referans olarak kalır.
- Eski audit modelindeki 25 tablo ile canonical 23 tablo farkı kapatıldı: aktif repository kullanımı olmayan legacy `cart_items` ve backend'e bağlanmamış `coupons` canonical zincire alınmadı. `orders/order_items`, kalan hesap silme/referans ve tarihsel veri bağımlılıkları çözülene kadar korunur.
- Canonical `0001`–`0009` zinciri doğrulanmış Development Supabase'e uygulandı; `20260815000900 0009_verified_product_reviews_storage` exact remote migration kaydı doğrulandı. Önceki postflight 23 public tablo, 23/23 RLS, 55 policy ve grant/trigger/RPC envanterini audit etmişti.
- Canonical QR RPC'leri gerçek Development PostgreSQL üzerinde state geçişi ve concurrent confirm ile doğrulandı; Production'a migration uygulanmadı ve Wave 4 final entegrasyonu remote yazma yapmadı.
- `0009`, aktif `product-images`, `category-images` ve `banner-images` bucket'larını public object read, trusted-operations-only write, exact versioned controlled path, MIME/size allowlist ve en az yedi günlük orphan retention sözleşmesiyle provision eder. Client list/write/update/delete policy'si yoktur; Flutter yalnız controlled path/legacy HTTPS okur.
- `brand-logos`, `avatars` ve `review-images` deferred ve provision edilmemiştir; ancak ilgili ürün özelliği aktive edilip owner sözleşmesi kesinleştiğinde ayrı least-privilege iş olarak ele alınır.
- Production üzerinde destructive işlem kullanıcı onayı olmadan yapılmaz.

### C4. Legacy Order / Shipping / Payment Teknik Borcu

- Legacy order repository/Cubit ve shipping/payment alanları aktif müşteri navigation'ından ve GetIt DI grafiğinden izole edildi.
- Legacy dosyalar, tablolar, veriler ve testler kaldırılmadı; tam kaldırma tamamlanmış sayılmaz.
- Option A'nın aktif ürün yorumu yolu artık legacy `orders/order_items` bağı taşımaz; kanıt yalnız verified transaction item durable `product_id` alanından gelir. Korunan legacy yorumlar otomatik yükseltilmez.
- `orders/order_items` hâlen hesap silme, migration sözleşmeleri ve tarihsel veri alanlarında referanslıdır. Gelecekte kaldırma veya arşivleme ancak bu kalan bağımlılıklar ve güvenli migration planı çözüldükten sonra ayrı ve açık yetkili görev olarak ele alınır.

### C5. Environment Ayrımı

- Development/production Dart-define ad alanları ayrıldı; sessiz fallback kaldırıldı ve eksik/placeholder/güvensiz/server-only config startup'ta güvenli biçimde reddediliyor.
- `.env` Flutter asset paketinden çıkarıldı; aktif uygulama source taramasında hardcoded Supabase URL/JWT ve çalışma alanında geçici `.env` placeholder bulunmadı.
- Agent 1 gerçek client-safe Development değerleriyle web release build, Supabase Development startup, Auth/Profile, customer shell, empty backend UX ve config failure sözleşmelerini PASS doğruladı; kod/commit üretmedi.
- Kalan release gate: gerçek client-safe Production değerleriyle ayrı Production smoke; production backend'e güvenli değer olmadan bağlanılmamalı.

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
- 2026-08-15 Wave 5 final sonucu: Agent 1 Development istemci smoke PASS; Agent 2 Storage contract ve Agent 3 review eligibility/legacy order auditleri entegre edildi. Review/QR/shop rating/Storage contract/legacy architecture hedefli matris 169/169, tam Flutter suite 1069/1069 (3 güvenlik-gated live skip) ve `flutter analyze --no-pub` temiz geçti.
- 2026-08-15 Wave 6 final sonucu: üç production dalı zorunlu sırayla çatışmasız entegre edildi. Review RPC/client + cart/QR/purchases + Storage resolver/model + canonical migration hedefli matrisi 189/189, tam Flutter suite 1106/1106, ayrı Development live review harness'i 3/3 ve `flutter analyze --no-pub` geçti; fixture cleanup residual `0`, Production erişimi `NO`.
- Büyük view dosyalarının conflict/testability riskini görev bazında azaltmak; geniş refactor'ı ayrı ve kontrollü yürütmek.
- Release öncesinde working tree, migration durumu ve canlı kabul sonuçlarını birlikte raporlamak.

## Güncelleme Kuralı

- Ürün sahibi karar verdiğinde ilgili madde `PRODUCT DECISION NEEDED` bölümünden onaylı işe taşınır ve karar metni açıkça kaydedilir.
- Kod tamamlandığında madde doğrudan silinmez; doğrulama ve release sonucu kaydedildikten sonra tamamlandı olarak işaretlenir veya geçmiş kaynağına taşınır.
- Production agentlar backlog'u geniş çapta yeniden yazmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
