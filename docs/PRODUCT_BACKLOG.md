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
- 2026-08-16 Wave 7 teknik ilerleme: Android/iOS Auth callback kaydı, PKCE recovery fix, enumeration-safe signup ve Android release internet izni entegre edildi; Production readiness audit ve smoke checklist eklendi. Auth hedefli 186/186, release-readiness 67/67, tam 1113/1113 test, analyzer ve sentetik `--no-tree-shake-icons` compile contract PASS; fiziksel QR, SMTP/e-posta ve Production release gate'leri BLOCKED/açık kaldı.
- 2026-08-16 Wave 8 teknik ilerleme: `iconsax_flutter 1.0.1` ve sınırlı repo-local compatibility katmanı ile standart Web release build ek workaround olmadan PASS; işlevsiz sosyal login UI release blocker'ı kapandı. Production Supabase cutover planı ile GO/NO-GO checklist'i hazırlandı. Hedefli 56/56, cutover belge/hash 20/20 ve tam 1116/1116 test (4 gated live skip) geçti; Production/Development remote yazması yapılmadı.
- 2026-08-16 Wave 9 teknik ilerleme: Production read-only discovery protokolü, mobile signing fail-safe/secret hygiene ve Production config/Auth redirect preflight entegre edildi. Migration manifesti CRLF kaynaklı platform bağımlılığından canonical Git/LF sözleşmesine geçirildi ve 9/9 PASS; Development apply sonrası tracked SQL mutation yok. Exact Production identity, final mobile identifier/signing ve bütün gerçek Production/SMTP/QR kabul kapıları açık kaldı.
- 2026-08-16 Wave 10 pre-migration ilerlemesi: Canonical Production kimliği ve fresh/empty baseline doğrulandı; migration ledger, public application table, Auth user, Storage bucket/object ve Realtime application membership sayıları sıfır. Canonical hash ve local clean-room replay 9/9 PASS; pre-migration baseline/current-state belgeleri entegre edildi. Free plan backup/PITR/restorable point sağlamadığından rollback/RPO/RTO, linked CLI dry-run, migration apply/postflight, SMTP/e-posta, fiziksel QR, final identifier/signing ve Production smoke açık kaldı.
- 2026-08-16 Wave 10 D0 ilerlemesi: Exact Production ref'inde linked CLI dry-run yalnız canonical `0001→0009` pending sırasını gösterdi; remote state değişmedi ve write `0`. Owner, yalnız boş ilk bootstrap için no-backup riskini ve gerektiğinde empty-project recreation yolunu kabul etti. Apply ayrı görev/zero-state recheck ile hazırdır; migration uygulanmadı ve bu istisna gerçek veri sonrası değişikliklere taşınmaz.
- 2026-08-16 Wave 10 D1 ilerlemesi: Owner'ın boş ilk bootstrap istisnası altında canonical Production migration `0001→0009` uygulandı. Ledger 9/9; 23/23 tablo/RLS, 52/52 policy, 28/28 app function, 25/25 trigger, 15/15 kritik RPC ve exact Storage/Realtime metadata postflight PASS; Auth/business data `0`. Final app identifier `com.esnaftavar.app` owner tarafından kesinleştirildi, ancak platform wiring Phase E'ye bırakıldı.
- 2026-08-16 Wave 10 Phase E ilerlemesi: Gerçek client-safe Production config ile
  anonymous read-only empty-state bağlantısı ve transient standart Web release build
  PASS. Final Android/iOS kimliği `com.esnaftavar.app` olarak wired; Development
  `com.esnaftavar.app.dev`. Callback bilinçli olarak korunup Phase F atomik cutover'a,
  mobil signing ve signed artifact'lar release sahibine açık bırakıldı. Remote write,
  migration apply, Auth/Storage config veya fixture işlemi yapılmadı.
- 2026-08-18 Wave 10 Phase F final ilerlemesi: Final callback code/remote Site URL
  wiring, Custom SMTP/Resend, gerçek inbox delivery, server-side confirmation ve
  customer role/profile acceptance PASS. Dashboard `10 users (estimated)` göstergesi
  authoritative SQL `auth.users = 0` ile açıklandı. Tek owner-authorized disposable
  fixture cleanup sonrası Auth/profile/consent, linked business ve Storage residual
  exact `0`; Production zero-auth baseline restore PASS. Actual mobile callback app
  opening, full recovery lifecycle, legacy callback removal, deliverability tuning,
  signing, fiziksel QR ve broader Production smoke açık kaldı.
- 2026-08-18 Wave 11 Phase A ilerlemesi: Repo-dışı gerçek Android upload key ile
  `com.esnaftavar.app` / `EsnaftaVar` / `1.0.0+1` signed Production APK ve AAB
  üretildi; APK/AAB signature, hash, final callback, legacy callback absence,
  non-debuggable ve secret scan kanıtları PASS. Keystore, populated `key.properties`
  ve binary artifact'lar tracked değildir. Owner birincil keystore yedeğini ve parola
  yöneticisi kaydını tamamladı; fiziksel Android kabulü, Play Console/Play App
  Signing, iOS signing, callback/recovery lifecycle ve commercial GO açık kaldı.
- 2026-08-19 Wave 11 Phase B2 ilerlemesi: Fiziksel cihazda bildirilen açık yüzey
  input görünürlüğü, e-posta confirmation callback sonrası waiting-state/navigation
  ve Android location runtime permission/settings-resume akışları kodda düzeltildi.
  Hedefli 118/118, tam Flutter suite 1177 PASS (5 opt-in live skip) ve analyzer PASS.
  Fiziksel input, confirmation success/app opening ve location acquisition retest'i;
  mobile recovery, fiziksel iki-cihaz QR ve broader Production smoke açık kalır.
- 2026-08-19 Wave 11 Phase B2R ilerlemesi: POCO X7 Pro / Android 16 üzerinde signed
  Production APK uninstall/clear-data olmadan upgrade edildi ve startup PASS oldu.
  Home search typed value/hint/cursor fiziksel görünürlüğü ile runtime location izin
  dialog'u, grant ve gerçek location acquisition PASS. Login yüzeyi ve Settings-return
  negatif turu çalıştırılmadı. Confirmation success UI/app opening için yeni Auth/
  e-posta fixture oluşturulmadığından BLOCKED; mobile recovery OPEN/BLOCKED kaldı.
  Integration ilgili B2 sözleşme matrisini 118/118 PASS ile yeniden doğruladı.
- 2026-08-20 Wave 11 Phase B3A ilerlemesi: Önceki disposable fiziksel-test customer'ı
  fresh authoritative gate ve owner yetkisiyle canonical self-delete yolundan
  temizlendi. Saved-location cascade ile silindi; ek targeted/admin/manual SQL delete
  yok. Auth user/identity/session/profile/consent/saved-location, diğer user-linked
  business ve Storage post-state exact `0`; Production zero-test baseline restore PASS.
  Confirmation callback app-opening/UI ve full recovery kabulü henüz açık kalır.
- 2026-08-22 Wave 11 B3R ilerlemesi: POCO X7 Pro'da confirmation ve recovery
  e-postaları, final callback app-opening, server confirmation, authenticated customer
  session/profile/role ve recovery update UI PASS. Confirmation başarı mesajı fiziksel
  olarak görünmedi. Password update HTTP `200` dönmesine rağmen yeni credential iki
  fresh login'de `invalid_credentials` aldı. Owner-authorized exact Auth Admin cleanup
  sonrası Auth/business/Storage residual exact `0`; legacy callback korunur.
- 2026-08-22 Wave 12 Phase A ilerlemesi: Esenler'in resmi 19 mahallesi için 4 kategori,
  20 ortak ürün, 57 sentetik `[DEMO]` mağaza ve 285 listing içeren deterministic
  UUIDv5 dataset artefaktı tamamlandı. Fiyat, konum, demo marker, exact cleanup ve
  Home featured-discovery sınırı canonical belgede sabittir; featured sponsorlu/
  reklam/paid ranking değildir. Local clean-room ve tüm test kapıları PASS; Production
  veya Development'a seed uygulanmadı. Phase B ayrı güvenlik incelemesi ve açık owner
  yetkisi gerektirir.
- 2026-08-22 Wave 12 Phase B ilerlemesi: Agent 1 read-only Production safety review'i
  fresh katalog `0/0/0/0`, Auth/profile/business `0`, Storage bucket/object `3/0`,
  deterministic collision `0/366`, natural-key collision `0` ve existing demo row `0`
  kanıtladı. Seed controlled single-writer apply için PASS; exact cleanup yalnız
  pre-launch zero-activity durumunda PASS. Owner seed authorization henüz verilmedi ve
  Production seed uygulanmadı. User activity sonrasında blind cleanup yerine olası
  soft-retire/deactivate davranışı ayrı owner kararıdır.
- 2026-08-22 Wave 12 Phase C ilerlemesi: Product-owner'ın exact seed yetkisiyle JIT
  single-writer, zero-baseline, `0/366` collision, artifact integrity ve clean-room
  kapıları PASS sonrasında canonical `esenler_demo_v1.sql` Production'a tek
  transaction olarak uygulandı. Postflight katalog `4/20/57/285`, manifest `366/366`,
  mismatch/unexpected row `0`; Auth/profile/merchant ve Storage object `0` doğruladı.
  Gerçek `anon` RLS rolü 20 featured product, 57 shop, 285 listing, ürün başına 14–15
  seller ve multiple price sonucunu PASS okudu. Cleanup çalıştırılmadı; Development,
  migration/schema/config/Auth/Storage değiştirilmedi. Agent teslimi `fad75a7` no-ff
  merge'i, hedefli `284/284`, tam suite `1210` PASS (`5` opt-in live skip) ve temiz
  analyzer ile final integration olarak kapatıldı; Integration remote işlem yapmadı,
  seed'i tekrarlamadı ve cleanup çalıştırmadı.
- 2026-08-22 Wave 12 Phase D ilerlemesi: Gerçek Production Web release functional
  smoke ve exact-ref read-only live harness Startup/Home, dört kategori, ProductDetails,
  seller/shop, nearby, search, anonymous wishlist/cart/profile login gate, Cart V2 ve
  navigation davranışlarını PASS doğruladı. Functional release blocker bulunmadı.
  Kozmetik spacing/font/color/card/icon/padding bulguları owner kararıyla final UI kit'e
  kadar deferred'dır ve functional backlog değildir. Agent teslimi `42774fe` no-ff
  merge'i, local hedefli `552` PASS (`2` remote live skip), tam suite `1213` PASS (`6`
  live skip) ve temiz analyzer ile final integration olarak kapatıldı. Integration
  remote işlem yapmadı; seed/cleanup veya fixture oluşturmadı.
- 2026-08-23 Wave 13 Phase A ilerlemesi: Agent 2'nin gerçek Android release signing
  kanıtı çatışmasız entegre edildi. Final `com.esnaftavar.app` / `1.0.0 (1)` APK ve
  AAB sabit repo-dışı `C:\Users\Mustafa\EsnaftavarReleases\1.0.0` dizininde korunur;
  exact SHA-256, canonical upload certificate, APK v2/tek signer, AAB `jar verified`,
  final callback ve secret/identity taraması PASS. Integration rebuild, credential
  erişimi veya remote backend işlemi yapmadı; hedefli `50/50`, tam suite `1213` PASS
  (`6` opt-in live skip), analyzer/diff/security temizdir. Android signing/artifact
  release gate kapandı. Korunmuş APK customer/location fiziksel kabulü sonraki Phase
  B'de PASS; final callback/recovery authoritative B6 PASS olarak korunur. İki-cihaz
  QR, Play Console AAB kabulü, ikinci offline keystore yedeği, iOS signing/archive ve
  final commercial GO açık kalır.
- 2026-08-23 Wave 13 Phase B ilerlemesi: Exact korunmuş signed Production APK POCO X7
  Pro / Android 16 (API 36) cihazına rebuild/uninstall/clear-data olmadan normal
  upgrade ile kuruldu. Startup, Production customer Home/kategori/ProductDetails/
  seller/shop/search/nearby/navigation ve physical location izin/acquisition PASS;
  functional blocker `NONE`. Agent customer read dışında Production write, Auth/
  merchant/QR/Storage fixture veya Development işlemi yapmadı. Final Integration
  input'u çatışmasız no-ff merge etti; remote read/write olmadan hedefli `143` PASS
  (`2` gated live skip), tam suite `1213` PASS (`6` gated live skip), analyzer/diff/
  security temizdir. B6 confirmation/recovery PASS olarak korunur. Merchant scanner
  ve iki-cihaz QR ayrı OPEN gate; Play Console, ikinci offline keystore yedeği, iOS
  signing/archive, final UI kit ve commercial GO da açık kalır.

#### Wave 11 B3R/B4 V1.0 Auth Bugs — B5 FIX + B6 PHYSICAL ACCEPTANCE COMPLETE

1. Confirmation callback server/session ve Home navigation'ı tamamlıyor; canonical
   başarı feedback'i destination UI'da kayboluyor veya gösterilmiyor. B4 root cause
   FOUND: mesaj route transition tamamlanmadan geçici Snackbar olarak tüketiliyor ve
   destination-owned durable one-shot success state yok. B5 destination-owned fix ve
   B6 görünür/kalıcı physical success notice PASS; bu bug current flow için kapalıdır.
2. Recovery client'ı `updateUser` exception üretmediğinde response/fresh login
   doğrulaması olmadan final success gösteriyor. B4 false-success root cause FOUND;
   B5 authoritative-success guard/stateful regression ve B6 same-credential fresh
   login + same-user identity physical acceptance PASS; false-success bug'ı kapalıdır.
3. B3R'deki gerçek Production password persistence davranışının server-side kök nedeni
   NOT_FOUND. Password-specific audit event retention dışında ve DB audit yazımı
   kapalı olduğundan `PASSWORD_UPDATE_AUDIT_EVENT_PRESENT: UNKNOWN`. B6 current B5
   recovery flow'u fiziksel PASS yaptı; tarihsel B3R nedeni kanıtsız biçimde yeniden
   sınıflandırılmaz ve `NOT_FOUND` kalır.

Canonical recovery final success kriteri: valid recovery session/provenance → başarılı
ve expected-user ile tutarlı update response → controlled recovery-session cleanup →
aynı yeni password ile fresh normal login → expected user identity equality. Yalnız
HTTP `200` / no-exception final success değildir.

### A2. QR Fiziksel Doğrulama Kabulünün Tamamlanması

- Durum: Kod hardening, Development PostgreSQL uygulaması ve gerçek backend concurrent confirm doğrulaması tamamlandı; iki kamera-capable cihaz bulunmadığı için `PHYSICAL_TWO_DEVICE_ACCEPTANCE: BLOCKED`.
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

### A6. Canonical Category Taxonomy — 24 L1 + Elektronik/Bilgisayar L2 OWNER FINAL / RUNTIME RECONCILIATION OPEN

- Durum: Wave 15 Phase A taxonomy architecture ve exact 24 Product L1 adı/sırası
  **FINAL / CANONICAL / PRODUCT OWNER LOCKED**; runtime, veritabanı, Production ve
  demo migration başlatılmadı.
- Phase A canonical source-of-truth:
  `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md`.
- Exact L1 sırası: Gıda & İçecek; Giyim & Moda; Ayakkabı; Çanta & Aksesuar;
  Elektronik; Bilgisayar & Tablet; Beyaz Eşya & Ev Aletleri; Ev & Yaşam; Zücaciye &
  Mutfak; Yapı, Hırdavat & Tesisat; Otomotiv & Motosiklet; Kozmetik & Kişisel
  Bakım; Anne & Bebek; Oyuncak & Hobi; Müzik & Enstrüman; Spor & Outdoor; Kitap;
  Kırtasiye & Ofis; Evcil Hayvan Ürünleri; Gözlük & Optik; Saat & Takı; Sağlık &
  Medikal; Çiçek & Bahçe; Hediyelik & Parti. Count `24`, duplicate `0`; sıra
  değiştirilemez.
- Architecture finaldir: variable-depth `L1 → L2 → L3 → optional L4`, max
  depth `4`, leaf `L2/L3/L4` olabilir ve her canonical product exactly one primary
  assignable leaf kullanır.
- Product Taxonomy, Merchant/Sector Taxonomy ve Facet/Attribute sistemi ayrıdır.
  Brand, color, size, shoe size, capacity, material ve compatibility category
  değildir. Sponsored/Featured/Popular/Nearby de category değildir.
- `Market` ve `Pet Shop` Product L1 değildir; product adları `Gıda & İçecek` ve
  `Evcil Hayvan Ürünleri`'dir. Merchant/Sector scope'unda `Berber, Kuaför &
  Güzellik Salonu` ile `Erkek Berberi`, `Kadın Kuaförü`, `Güzellik Salonu`
  confirmed; `Unisex Kuaför` eklenmez. Booking/rezervasyon/hizmet fiyatı TBD'dir.
- Stable identity future contract'ı current V1 source slug'larını korur; display
  rename identity değiştirmez. Future opaque ID, permanent alias/redirect,
  stable-ID product FK/analytics ve identity-safe rename mapping zorunludur.
  Oyuncak/Hobi/Müzik split successor mapping'i ayrı controlled runtime task'tır.
- Önceki full-tree V1.0.0 artefaktları
  `docs/ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md` ve
  `docs/data/esnaftavar_category_taxonomy_v1_final.json` bu entegrasyonda değişmeden
  korundu. Mevcut `23/91/505/32`, `651` node baseline 24-L1 owner lock ile henüz
  reconcile edilmedi ve runtime source olarak deploy edilmedi.
- Demo conceptual mapping `4/4` PASS: Elektronik → Elektronik, Kırtasiye →
  Kırtasiye & Ofis, Gıda → Gıda & İçecek, Ayakkabı → Ayakkabı. Production
  demo data değiştirilmedi.
- Wave 15 Phase B1+B2 owner-final L2 spine'ları canonical olarak kilitlendi:
  - Elektronik (`9`): Telefon & Aksesuarları; TV & Görüntü Sistemleri; Ses &
    Kulaklık; Fotoğraf & Kamera; Oyun Konsolu & Aksesuarları; Giyilebilir Teknoloji;
    Akıllı Ev & Güvenlik; Güç, Şarj & Bağlantı; Elektronik Bileşenler.
  - Bilgisayar & Tablet (`11`): Dizüstü Bilgisayar; Masaüstü Bilgisayar; Tablet;
    E-Kitap Okuyucu; Monitör; Bilgisayar Bileşenleri; Veri Depolama; Klavye, Mouse &
    Çevre Birimleri; Bilgisayar Aksesuarları; Yazıcı, Tarayıcı & Sarf Malzemeleri;
    Ağ & İnternet Ürünleri.
- Cross-domain sınırı finaldir: PC-specific/computer-primary ürün Bilgisayar & Tablet;
  general consumer electronics Elektronik altında kalır. Arduino/ESP Elektronik
  Bileşenler, Raspberry Pi/SBC Bilgisayar Bileşenleri; webcam, dock/USB hub ve
  PC-first gaming peripheral Bilgisayar & Tablet; console-first ürün Oyun Konsolu &
  Aksesuarları altındadır. Generic audio ile generic güç/şarj/bağlantı Elektronik;
  telefon-model-specific aksesuar Telefon & Aksesuarları kapsamındadır.
- Toner/kartuş/3D printer/filament Yazıcı, Tarayıcı & Sarf Malzemeleri kapsamındadır.
  Rack/server ve POS owner kararı TBD/unassigned kalır. Brand, color, capacity,
  compatibility gibi facets category ağacına taşınmaz.
- L3/L4 tasarımı henüz başlamadı. JSON/runtime, DB/schema/migration, Flutter/Figma
  ve Production/Development durumu bu entegrasyonda değişmedi.
- Açık implementation işleri:
  - current 23-L1 full tree ile 24-L1 lock için rename/split successor reconciliation,
  - current source slug → stable opaque ID bridge ve backward-compatible adapter,
  - DB taxonomy schema ve tek-sahipli migration tasarımı/uygulaması,
  - ayrı yetkili Production taxonomy seed/migration ve postflight,
  - search/index, category/product read-path ve typed facet-profile entegrasyonu,
  - Design Tokens/Component Library V1'e bağlı Figma category/search/filter UI,
  - ayrı full Merchant/Sector taxonomy ve hizmet capability owner kararları.

`WAVE_15_TAXONOMY_INTEGRATION: PASS`

`CATEGORY_TAXONOMY_V1_CANONICAL: YES`

`TAXONOMY_DEPLOYED_TO_RUNTIME: NO`

`READY_FOR_TAXONOMY_IMPLEMENTATION_DESIGN: YES`

`WAVE_15_PHASE_A_INTEGRATION: PASS`

`CANONICAL_L1_LOCK: PASS`

`CANONICAL_L1_COUNT: 24`

`PRODUCT_MERCHANT_FACET_SEPARATION: PASS`

`CURRENT_FULL_TREE_JSON_RECONCILED_TO_24_L1: NO`

`RUNTIME_TAXONOMY_IMPLEMENTED: NO`

`READY_FOR_TAXONOMY_PHASE_B: COMPLETED`

`WAVE_15_B1_B2_INTEGRATION: PASS`

`ELECTRONICS_L2_CANONICAL: PASS`

`ELECTRONICS_L2_COUNT: 9`

`COMPUTER_TABLET_L2_CANONICAL: PASS`

`COMPUTER_TABLET_L2_COUNT: 11`

`CROSS_DOMAIN_BOUNDARY: PASS`

`L3_L4_STATE: NOT_STARTED`

`READY_FOR_L3_L4_DESIGN: YES`

### A7. EsnaftaVar Design Tokens V1.0.0 — FINAL / CANONICAL COMPONENT LAYER V1 FINAL

- Durum: Design Tokens V1 **FINAL / CANONICAL**; Flutter runtime ve mevcut K'pasa
  component/screen sistemi henüz migrate edilmedi.
- Canonical source-of-truth:
  `docs/ESNAFTAVAR_DESIGN_TOKENS_V1_FINAL.md` ve
  `docs/data/esnaftavar_design_tokens_v1.json`.
- Final görsel dil **Mahalle Terracotta**: primary `#B54732`, accent `#1F6B5D`,
  yalnız Poppins; spacing `4/8/12/16/20/24/32/40/48`, radius `8/12/16/999`, touch
  target `44 px` minimum ve `48 px` preferred.
- Figma canonical foundation: `EsnaftaVar / Color` `38` variable,
  `EsnaftaVar / Dimension` `15` variable, `12` canonical `EsnaftaVar/type/*` style
  ve `shadow/xs`, `shadow/sm`, `shadow/md`. Manifest toplam `68` final token içerir.
- Primary/white `5.37:1`, accent/white `6.33:1`; approved primary/accent/state
  strong/soft çiftlerinin tamamı PASS. State ve commerce anlamı yalnız renkle
  taşınmaz; label/icon kuralı korunur.
- Source safety finaldir: existing K'pasa screen, component, instance ve styles
  değiştirilmedi. İzole EsnaftaVar token foundation ve canonical component layer
  oluşturuldu; screen redesign ve Flutter migration başlamış sayılmaz.
- Canonical Component Layer V1 tamamlandı: `14` public family, `11` component set,
  `79` component node; source-of-truth `docs/ESNAFTAVAR_COMPONENT_LIBRARY_V1.md`.
  Actual five-target BottomNav, dynamic/availability-aware category family'leri,
  ProductCard, SellerPriceRow, MerchantCard, verified/rating, single-store Cart V2 ve
  StatusChip sözleşmeleri canonical'dır.
- `Verified` server-authoritative kalır. `Sponsored` yalnız future visual disclosure
  state'idir; advertising engine, paid ranking veya sponsored placement davranışı
  implement edilmiş sayılmaz.
- Component root Auto Layout `79/79`, canonical token binding, Poppins-only, duplicate
  name `0`, legacy `#FF8523` `0`, `44 px` altı interactive target `0` ve Turkish
  overflow/clipping `0` PASS. K'pasa source fingerprint'leri ve source screen,
  component, instance, style içeriği değişmemiştir.
- Açık implementation/acceptance işleri:
  - product-owner visual review ve gerçek Türkçe içerik/accessibility state'leriyle
    tek-akışlı critical screen pilot,
  - Wave 15 canonical taxonomy'ye bağlı category/search/filter UI uyarlaması,
  - component-level kabul sonrası full Flutter token/UI migration.

`WAVE_14_PHASE_B2_INTEGRATION: PASS`

`DESIGN_TOKENS_V1_CANONICAL: YES`

`SOURCE_KPASA_UNCHANGED: YES`

`READY_FOR_CANONICAL_COMPONENT_LAYER: YES`

`WAVE_14_PHASE_B3_INTEGRATION: PASS`

`CANONICAL_COMPONENT_LAYER_V1: PASS`

`SOURCE_KPASA_UNCHANGED: YES`

`RUNTIME_CODE_CHANGED: NO`

`READY_FOR_CRITICAL_SCREEN_PILOT: YES`

## B. PRODUCT DECISION NEEDED

### B1. Sosyal Login — OPTIONAL / NON-BLOCKING

- Soru: Sosyal login ilk ticari lansmanda gerekli mi?
- Karar verilirse ayrıca hangi sağlayıcıların destekleneceği belirlenmeli.
- Mevcut gerçeklik: Supabase servis/repository abstraction'ı korunuyor; Google/Facebook düğmeleri ve ayırıcı aktif Login/Signup UI'dan kaldırıldı.
- Release durumu: İşlevsiz sosyal UI blocker'ı **CLOSED**. OAuth sağlayıcılarının gelecekte açılması ayrı optional ürün işidir; ilk release'i tek başına bloke etmez.

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
- Durum: **BLOCKED** — entegrasyon ortamında iki fiziksel kamera-capable cihaz yoktur; otomatik QR/backend testleri bu kabulün yerine geçmez.
- Müşteri ve merchant için iki ayrı gerçek hesap kullanılmalı.
- Kamera, izin, QR üretme, okutma, onay, polling ve tamamlanma birlikte doğrulanmalı.
- Canlı veri silinmemeli; güvenli ve geri alınabilir test verisi kullanılmalı.

### C2. Backend Integration Test Eksikleri

- Wave 4 tamamlanan Development doğrulamaları: Auth signup/session, otomatik profil/legal consent, own/cross-user/anon RLS, saved locations/addresses/wishlist, merchant/admin escalation reddi; QR create/confirm/negative state'ler/immutable snapshot/gerçek concurrency; Chat ve Notifications Realtime delivery/isolation/reconnect/dedup/lifecycle.
- Fiziksel kamera ve iki cihaz QR kabulü C1 altında açık kalır.
- Ürün yorumu Option A backend/client implementasyonu ve normal Auth Development live lifecycle doğrulaması tamamlandı; unverified submit `42501 [REVIEW_NOT_VERIFIED]` ile reddedildi ve create/duplicate/update/delete/recreate aggregate yenilemesi geçti.
- Production Phase F gerçek SMTP delivery, server-side signup confirmation ve final
  callback email contract'ı PASS'tir. Confirm Email'in kapalı olduğu Development live
  testleri bu kanıtın yerine geçmez ve Phase F Production sonucu Development'a
  genellenmez.
- PKCE recovery callback, Android/iOS callback registration, enumeration-safe signup
  ve Android internet izni kodda tamamdır. B6'da actual Production mobile app opening,
  destination-owned confirmation feedback ve canonical full recovery/fresh-login/
  same-user lifecycle fiziksel PASS oldu. Resend duplicate/expiry ve deliverability
  izleme broader acceptance kapsamında açıktır; B6 e-postaları Inbox'a ulaştı.

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
- Wave 8 standart Web release build'i sentetik client-safe URL/key ile, ek icon workaround'u olmadan PASS oldu. Bu yalnız compile/config contract kanıtıdır; startup/Auth/Production smoke değildir ve gerçek Production config hâlâ açık gate'tir.

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
- 2026-08-16 Wave 7 final sonucu: Agent 2 Auth hardening ve Agent 3 Production readiness çıktıları entegre edildi; Agent 1 diff olmadığı için merge edilmedi. Auth/platform/config matrisi 186/186, release-readiness matrisi 67/67, tam Flutter suite 1113/1113 (4 gated live skip), analyzer, diff/security ve sentetik Production entrypoint compile contract PASS; gerçek Production/Development remote yazması yapılmadı.
- 2026-08-16 Wave 8 final sonucu: Üç teslim dalı zorunlu sırayla çatışmasız entegre edildi. Iconsax/Auth/callback/config/platform/migration matrisi 56/56, cutover belge/hash kontrolü 20/20, tam Flutter suite 1116/1116 (4 gated live skip) ve standart sentetik Production entrypoint Web release build'i ek icon workaround'u olmadan PASS; gerçek Production/Development remote yazması yapılmadı.
- 2026-08-16 Wave 9 final sonucu: Üç teslim dalı zorunlu sırayla çatışmasız entegre edildi. Migration/config/signing/platform/Auth hedefli matrisi 62/62, migration artifact manifesti 9/9, tam Flutter suite 1136/1136 (4 opt-in Development live skip), analyzer, standart Web ve Android production-release compile-only contract ile Android development debug build PASS. Android release packaging eksik signing materyalinde beklenen fail-closed sonucu verdi; remote backend yazması yapılmadı.
- 2026-08-16 Wave 10 pre-migration sonucu: Agent 1 Phase A + Phase B/C dokümantasyonu çatışmasız entegre edildi. Migration artifact manifesti 9/9 ve canonical migration contract testi 18/18 PASS; Agent clean-room replay kanıtı 9/9 PASS olarak korundu. Kod değişmediğinden full Flutter suite ve analyzer yeniden çalıştırılmadı; integration sırasında remote backend erişimi/yazması veya migration apply yapılmadı.
- 2026-08-16 Wave 10 D0 sonucu: Linked Production CLI dry-run kanıtı çatışmasız entegre edildi; pending sıra exact `0001→0009`, Production before/after state aynı ve remote write `0`. Owner'ın empty-first-bootstrap risk istisnası canonical belgelere kaydedildi. Manifest 9/9, canonical contract 18/18, docs/diff/security PASS; migration uygulanmadı.
- 2026-08-16 Wave 10 D1 sonucu: Production canonical migration apply ve metadata/security postflight kanıtı çatışmasız entegre edildi. Integration migration'ı yeniden uygulamadı ve remote erişim/yazma yapmadı. Manifest 9/9, canonical contract ve belge/güvenlik kontrolleri PASS sonrasında Phase E Production client wiring kapısı açıldı; full Flutter suite kod değişmediği için yeniden çalıştırılmadı.
- 2026-08-16 Wave 10 Phase E sonucu: Agent 1 Production client wiring ve Agent 2
  final mobile identity branch'leri zorunlu sırayla çatışmasız entegre edildi.
  Production client ve final app identity wired; Auth/email callback cutover, signing,
  controlled Production smoke ve commercial GO açık kaldı. Hedefli matris 61 PASS +
  1 güvenli live skip, tam suite 1142 PASS + 5 opt-in live skip, analyzer, gerçek
  Production Web build, Android Development debug ve Production compile-only PASS;
  eksik signing materyalinde release packaging fail-closed PASS.
- 2026-08-17 Wave 10 Phase F intermediate sonucu: Agent 1 final callback cutover ve
  Agent 2 Production Auth/SMTP read-only precheck branch'leri zorunlu sırayla
  entegre edildi. Production callback `com.esnaftavar.app://login-callback/`,
  Development callback `io.supabase.tstore://login-callback/` olarak izole; explicit
  signup/resend/recovery redirect ve exact PKCE filtresi kaynakta tamamlandı. Custom
  SMTP config mevcut ve template precheck PASS; ancak Site URL localhost, web recovery
  HTTPS route/allowlist, canlı inbox acceptance, sender/link-tracking final kanıtı ve
  legacy allowlist removal açık olduğundan SMTP precheck FAIL ve live email readiness
  NO kaldı. Hedefli Auth/platform/preflight matrisi 118/118, tam Flutter suite 1154
  PASS (5 opt-in live skip), sentetik Production config preflight, analyzer,
  docs/diff ve security/secret scan temizdir. Integration remote backend
  erişimi/yazması veya e-posta göndermedi.
- 2026-08-18 Wave 10 Phase F final sonucu: Agent 1 final live email/cleanup evidence
  HEAD'i `--no-ff` ve çatışmasız entegre edildi. Real SMTP delivery, server-side
  confirmation, final callback email URL contract'ı ve customer role/profile PASS;
  exact cleanup sonrası Production Auth/business/Storage test residual `0`. Mobile
  app opening ve full recovery BLOCKED; legacy callback removal ve spam tuning OPEN.
  Callback/PKCE/signup-recovery/account-deletion/profile/canonical RLS hedefli yerel
  matris 151/151, docs/diff ve secret/PII scan PASS; integration remote backend işlemi
  yapmadı.
- 2026-08-18 Wave 11 Phase A sonucu: Agent 1 signed Android artifact evidence
  commit'i `--no-ff` ve çatışmasız entegre edildi. Android identity/signing,
  callback/deep-link, Production preflight ve Auth hedefli matris 62/62; tam Flutter
  suite 1154 PASS (5 opt-in live skip), analyzer, diff, secret/private-key ve tracked
  artifact scan kapıları PASS oldu. Integration binary artifact üretmedi ve
  Production/Development remote erişimi veya write yapmadı.
- 2026-08-19 Wave 11 Phase B2 sonucu: Agent 2 input/Auth confirmation/location
  bugfix commit'i `--no-ff` ve çatışmasız entegre edildi. Üç code-fix PASS ve fiziksel
  B2 retest'e hazırdır; bağlı cihaz kanıtı olmadığından
  `PHYSICAL_DEVICE_REGRESSION: BLOCKED` korunur. Integration remote backend işlemi,
  signup/e-posta, QR, Storage, migration, Auth config veya signing materyali üretmedi.
- 2026-08-19 Wave 11 Phase B2R sonucu: Agent 1 fiziksel acceptance commit'i `--no-ff`
  ve çatışmasız entegre edildi. Signed APK install/upgrade, startup, Home input ve
  gerçek location acquisition fiziksel PASS; confirmation UI ve recovery fiziksel
  kabulü yapılmadığı için BLOCKED/OPEN korundu. Integration backend erişimi/yazması,
  Auth/e-posta, QR, Storage, migration veya config işlemi yapmadı.
- 2026-08-20 Wave 11 Phase B3A sonucu: Agent 1 authorized fixture cleanup kanıtı
  `--no-ff` ve çatışmasız entegre edildi. Canonical self-delete, saved-location
  cascade ve zero Auth/business/Storage residual PASS. Integration cleanup'ı tekrar
  çalıştırmadı; Production remote read/write ve Development erişimi olmadı. B3 mobile
  Auth acceptance zero-test baseline ile yeniden başlatılabilir. Agent hedefli kanıtı
  96/96, Integration yeniden doğrulama paketi 63/63 PASS.
- 2026-08-22 Wave 11 B3R evidence + cleanup sonucu: Agent final HEAD'i `--no-ff` ve
  çatışmasız entegre edildi. Physical confirmation callback, server confirmation,
  customer role/profile ve recovery callback/update UI PASS; success feedback ve yeni
  credential login FAIL. Exact B3R fixture trusted Auth Admin yoluyla temizlendi,
  Production zero-test baseline restore PASS. Integration remote backend işlemi
  yapmadı; Auth matrisi 67/67, tam suite 1182 PASS (5 live skip) ve analyzer PASS.
- 2026-08-22 Wave 11 B4 root-cause sonucu: Agent 2'nin canonical analiz belgesi
  `--no-ff` ve çatışmasız entegre edildi. Confirmation feedback durability ve recovery
  false-success client root cause'ları FOUND; gerçek Production password persistence
  root cause'u NOT_FOUND, audit event UNKNOWN. Beş adımlı authoritative recovery
  success criterion ve yeni regression test boşlukları source-of-truth olarak
  kaydedildi. Yerel Auth unit/widget/integration matrisi 199/199 ve Auth redirect
  wiring contract 4/4 PASS; Integration Production/Development remote erişimi veya
  write yapmadı.
- 2026-08-22 Wave 11 B5 final integration sonucu: Agent 2'nin authoritative
  confirmation/recovery fix'i `--no-ff` ve çatışmasız entegre edildi. Destination-
  owned kalıcı confirmation notice, duplicate/invalid callback güvenliği, recovery
  false-success guard ve aynı opaque credential ile fresh same-user login kanıtı kod
  ve regression düzeyinde PASS. Gerçek Production password persistence root cause'u
  NOT_FOUND kalır; confirmation/recovery son fiziksel kabul turu açıktır. Integration
  Production/Development remote erişimi, Auth user/e-posta veya config işlemi yapmadı.
  Hedefli Auth matrisi 215/215, tam suite 1194/1194 (5 live skip) ve analyzer PASS.
- 2026-08-22 Wave 11 B6 final integration sonucu: Agent 1'in final physical Auth
  evidence commit'i `--no-ff` ve çatışmasız entegre edildi. POCO X7 Pro / Android 16
  üzerinde confirmation callback + destination success notice, canonical five-step
  recovery, aynı credential ile fresh/normal login, same-user identity ve customer
  role güvenliği PASS. Canonical self-delete sonrası Production Auth/business/Storage
  test residual exact `0`; Integration remote backend'e erişmedi/yazmadı. Hedefli
  Auth/account-deletion matrisi 266/266, tam suite 1194/1194 (5 live skip), analyzer,
  diff ve security/PII scan PASS.
- 2026-08-22 Wave 11 B7 final integration sonucu: Agent 1'in owner-authorized legacy
  Production callback removal kanıtı `--no-ff` ve çatışmasız entegre edildi. Remote
  postflight Production allowlist'in yalnız `com.esnaftavar.app://login-callback/`
  içerdiğini; Site URL'nin aynı kaldığını, Custom SMTP'nin Enabled ve Confirm Email'in
  ON olduğunu doğruladı. Development callback'i kendi ortamında izole biçimde korundu.
  Integration remote işlemi tekrarlamadı; hedefli callback/platform/environment/PKCE/
  release-config matrisi 45/45, diff ve security/PII scan PASS.
- 2026-08-22 Wave 12 Phase A final integration sonucu: Agent 3'ün deterministic
  Esenler dataset artefaktı `--no-ff` ve çatışmasız entegre edildi. Generator/manifest,
  fail-closed idempotent seed, dependency-guarded exact-ID cleanup ve canonical veri
  belgesi birlikte doğrulandı. Local PGlite replay'i migration 9/9, iki kez
  `4/20/57/285`, representative read, ürün başına 14–15 seller ve çoklu fiyat,
  57 unique coordinate, cleanup exact sıfır ve 23 canonical public table PASS verdi.
  Dataset contract 16/16, ilgili regresyon paketi 268/268, tam Flutter suite 1210 PASS
  (5 opt-in live skip) ve analyzer temizdir. Remote read/write veya seed apply yoktur.
- 2026-08-22 Wave 12 Phase B final integration sonucu: Agent 1'in canonical Production
  read-only seed safety review belgesi `--no-ff` ve çatışmasız entegre edildi. Seed
  deterministic/transactional/fail-closed ve yalnız dört business tabloya insert eden
  controlled single-writer apply olarak PASS; exact cleanup yalnız pre-launch state
  için PASS sınıflandırıldı. `owner_user_id = NULL` customer discovery/seller compare
  için geçerli, merchant QR/verified transaction için intentional unavailable kaldı.
  Local dataset/migration matrisi 37/37, clean-room replay, tam suite 1210 PASS (5
  opt-in live skip), analyzer, diff ve security scan temizdir. Integration remote
  backend işlemi yapmadı; Production seed owner tarafından henüz yetkilendirilmedi.
- 2026-08-22 Wave 12 Phase C final integration sonucu: Agent 1'in owner-authorized
  exact seed apply ve postflight kanıtı `--no-ff` ve çatışmasız entegre edildi.
  Production demo katalog `4/20/57/285`, manifest `366/366`, marker'lar `20/57/285`,
  owner-null shop `57/57`, Auth/profile/merchant ve Storage object `0` olarak
  authoritative kalır. Anon customer read, Home discovery, ürün başına 14–15 seller
  ve 20/20 multiple price PASS'tir. Generator check, hedefli matris `284/284`, tam
  suite `1210` PASS (`5` opt-in live skip), analyzer, diff ve security scan temizdir.
  Integration remote read/write yapmadı; seed tekrar uygulanmadı ve cleanup
  çalıştırılmadı. Broader fiziksel/mobile demo visual smoke açık kabul adımıdır.
- 2026-08-22 Wave 12 Phase D final integration sonucu: Agent 1'in Production demo
  functional smoke raporu, stale empty-catalog expectation düzeltmesi ve exact-ref /
  opt-in / mutation-free read harness'ı `--no-ff` ve çatışmasız entegre edildi. Agent
  kanıtı hedefli `564/564`, Production harness `4/4`, full suite `1213` PASS ve hiçbir
  functional blocker gösterir. Integration remote define vermeden safety/customer
  matrisini `552` PASS (`2` Production live skip), full suite'i `1213` PASS (`6` live
  skip) ve analyzer'ı temiz doğruladı. Production/Development remote işlem, seed,
  cleanup, Auth/Storage/config/migration veya fixture yoktur. Kozmetik UI final kit'e
  kadar deferred; sonraki release gate hazırdır.
- 2026-08-23 Wave 13 Phase A final integration sonucu: Agent 2'nin `d966f55` Android
  real release signing kanıtı exact `305dd74` tabanına `52f1e98` ile `--no-ff` ve
  çatışmasız entegre edildi. Final Production APK/AAB Git dışında sabit release
  dizininde korundu ve exact hash/signature/certificate/manifest sonuçları yeniden
  PASS doğrulandı. Integration artifact rebuild, signing credential erişimi veya
  Production/Development remote işlem yapmadı. Hedefli `50/50`, tam suite `1213`
  PASS (`6` opt-in live skip), analyzer, diff ve security scan temizdir. Signing/
  artifact kapısı kapalı; fiziksel artifact, Play Console, ikinci offline backup,
  iOS ve final commercial kabul kapıları açıktır.
- 2026-08-23 Wave 13 Phase B final integration sonucu: Agent 1'in `920b95e` physical
  signed APK acceptance kanıtı exact `22c78c6` tabanına `6c15e02` ile `--no-ff` ve
  çatışmasız entegre edildi. POCO X7 Pro / Android 16 (API 36) üzerinde exact korunmuş
  `com.esnaftavar.app` / `1.0.0 (1)` APK install/startup, customer discovery/search/
  nearby/navigation ve location acceptance PASS; functional blocker yoktur. Agent
  yalnız Production customer reads yaptı; write/fixture/rebuild/Development yoktur.
  Integration remote read/write yapmadan hedefli `143` PASS (`2` gated live skip),
  full suite `1213` PASS (`6` gated live skip), analyzer/diff/security temizdir.
  Camera/scanner çalıştırılmadı ve fail değildir; merchant/two-device QR OPEN kalır.
- Büyük view dosyalarının conflict/testability riskini görev bazında azaltmak; geniş refactor'ı ayrı ve kontrollü yürütmek.
- Release öncesinde working tree, migration durumu ve canlı kabul sonuçlarını birlikte raporlamak.

### C9. Production Release Readiness — BLOCKED

- Canonical operasyon kaynakları: `docs/PRODUCTION_READINESS_AUDIT.md`, `docs/PRODUCTION_SMOKE_CHECKLIST.md`, `docs/PRODUCTION_PRE_MIGRATION_BASELINE.md`, `docs/PRODUCTION_CURRENT_STATE_INVENTORY.md`, `docs/PRODUCTION_SUPABASE_CUTOVER_PLAN.md` ve `docs/PRODUCTION_GO_NO_GO_CHECKLIST.md`.
- Canonical Production `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` / `https://mefhfvrgkwciubeajjeb.supabase.co` / Frankfurt olarak doğrulandı; Development ref'i `tnipyxnvhgelwdpykyez` Production değildir.
- Production canonical `0001→0009` schema durumundadır: ledger 9/9, 23 public tablo, 23/23 RLS, final 52 policy, 28 app function, 25 trigger, exact üç active bucket ve iki Realtime member doğrulandı. Wave 12 Phase C sonrası demo katalog exact `4/20/57/285`; Auth user/profile/merchant ve Storage object sayıları sıfırdır.
- Free plan scheduled backup/PITR/restorable point sağlamaz. Owner'ın yalnız tamamen boş ilk bootstrap için verdiği no-backup/recreate istisnası D1'de kullanıldı; gerçek veri sonrası veya gelecekteki Production migration'ları için yetki ya da emsal değildir.
- Final application/bundle identifier `com.esnaftavar.app` owner kararıyla kapanmış ve
  Android/iOS platform wiring tamamlanmıştır. Android gerçek upload signing, birincil
  keystore yedeği ve Wave 13'te Git dışında kalıcı release dizinine alınan güncel
  signed APK/AAB PASS'tir. Wave 13 signing/artifact gate kapanmıştır; korunmuş güncel
  APK'nın fiziksel install/startup/customer/location kabulü Phase B'de PASS olmuştur.
  Final callback/recovery authoritative B6 PASS durumu korunur ve yeniden açık gate
  değildir.
  B2R önceki signed APK install/upgrade,
  startup, Home input ve location fiziksel kabulü PASS'tir. Confirmation callback
  app opening PASS; historical B3R turunda confirmation success feedback ve recovery
  credential login FAIL. B5 code fix entegre edildi; B6 final fiziksel confirmation
  ve recovery acceptance PASS oldu.
  Settings-return negatif turu, Google Play Console/
  Play App Signing, kalıcı CI provenance, Apple Team/certificate/profile ve signed IPA
  hâlâ açık release kapılarıdır.
- Gerçek client-safe Production config/read-only bağlantı PASS'tir. Production final
  callback code/platform wiring tamamlanmıştır ve Development callback'i izoledir.
  Mobile Site URL exact final callback'e geçirilmiştir; real SMTP delivery,
  server-side confirmation ve actual mobile app opening PASS'tir. Confirmation
  success feedback code bug'ı ve recovery false-success guard B5'te kapanmış; B6
  destination notice, same-credential fresh login ve same-user identity'yi fiziksel
  PASS doğrulamıştır. B7 legacy Production callback'i kaldırmış ve final callback-only
  postflight'ı PASS tamamlamıştır. Deliverability izleme, fiziksel merchant scanner/
  iki-cihaz QR, fixture tabanlı Storage negative listing, Play Console AAB kabulü ve
  iOS release kabulü açık kapılardır.
- Önceki B3 fiziksel-test principal'ı B3A'da canonical self-delete ile temizlendi;
  saved-location dahil Auth/business/Storage residual exact `0`. Sonraki canlı Auth
  turu kendi fresh pre-write inventory ve scoped cleanup planını yeniden uygulamalıdır.
- B3R disposable principal'ı owner-authorized trusted Auth Admin delete ile temizlendi;
  Auth user/identity/session/profile/consent, bütün linked business ve Storage residual
  exact `0`. B4 root-cause ve B5 client fix turu tamamlandı. B6 scoped fixture ile
  final fiziksel kabulü tamamladı ve canonical self-delete sonrası Auth/identity/
  session/profile/consent/business/Storage residual exact `0` oldu. Legacy callback
  B7'de owner-authorized remote config göreviyle kaldırıldı; final callback korundu.
- B4 analizi confirmation durability ve recovery false-success kök nedenlerini buldu;
  B5 destination-owned notice ve canonical fresh-login verification implementasyonunu
  entegre etti; B6 current flow'u fiziksel PASS doğruladı. Actual Production password persistence kök
  nedeni NOT_FOUND ve password-specific audit UNKNOWN kaldığından server davranışı
  hakkında yeni bir neden uydurulmaz.
- Local migration artifact integrity, safe-equivalent clean-room replay ve linked CLI kontrolleri 9/9 PASS; gerçek apply ve metadata/security postflight D1'de PASS olmuştur.
- `PRODUCTION_CLIENT_WIRED: YES`, `FINAL_APP_IDENTITY_WIRED: YES`,
  `PHASE_F_CALLBACK_INTEGRATED: YES`, `SMTP_CONFIGURATION_PRESENT: YES`,
  `PRODUCTION_EMAIL_INFRASTRUCTURE: READY`, `PRODUCTION_ZERO_TEST_RESIDUAL: YES`,
  `MOBILE_AUTH_CALLBACK_ACCEPTANCE: PASS`,
  `PASSWORD_RECOVERY_MOBILE_ACCEPTANCE: PASS`, `ANDROID_SIGNING_READY: YES`,
  `SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`,
  `WAVE_13_PHASE_A_INTEGRATION: PASS`,
  `SIGNED_ANDROID_ARTIFACTS_PRESERVED: YES`,
  `ANDROID_SIGNING_RELEASE_GATE: PASS`,
  `READY_FOR_PHYSICAL_ANDROID_ACCEPTANCE: COMPLETED — WAVE 13 PHASE B`,
  `WAVE_13_PHASE_B_INTEGRATION: PASS`,
  `PHYSICAL_ANDROID_RELEASE_ACCEPTANCE: PASS`,
  `PHYSICAL_LOCATION_ACCEPTANCE: PASS`,
  `PHYSICAL_TWO_DEVICE_QR_ACCEPTANCE: OPEN`,
  `FUNCTIONAL_ANDROID_BLOCKERS: NONE`,
  `INPUT_VISIBILITY_CODE_FIX: PASS`, `EMAIL_CONFIRMATION_UI_CODE_FIX: PASS`,
  `LOCATION_PERMISSION_CODE_FIX: PASS`, `INPUT_PHYSICAL_ACCEPTANCE: PASS`,
  `LOCATION_PHYSICAL_ACCEPTANCE: PASS`,
  `CONFIRMATION_UI_PHYSICAL_ACCEPTANCE: PASS`,
  `READY_FOR_MOBILE_AUTH_LIVE_ACCEPTANCE: COMPLETED — B6 PASS`,
  `PHYSICAL_DEVICE_REGRESSION: PASS`,
  `WAVE_11_B3A_AUTHORIZED_FIXTURE_CLEANUP: PASS`,
  `B3A_CANONICAL_SELF_DELETE_ACCEPTANCE: PASS`,
  `AUTHORIZED_B3R_FIXTURE_CLEANUP: PASS`,
  `WAVE_11_B3R_EVIDENCE_INTEGRATION: PASS`,
  `PRODUCTION_ZERO_TEST_BASELINE: RESTORED`,
  `V1_0_AUTH_BUG_CONFIRMATION_SUCCESS_FEEDBACK: CLOSED — B5 CODE + B6 PHYSICAL PASS`,
  `V1_0_AUTH_BUG_RECOVERY_CREDENTIAL_PERSISTENCE: CLOSED FOR CURRENT B5/B6 FLOW`,
  `READY_FOR_AUTH_RECOVERY_ROOT_CAUSE_ANALYSIS: COMPLETED — B4`,
  `CONFIRMATION_UI_ROOT_CAUSE: FOUND`,
  `RECOVERY_FALSE_SUCCESS_ROOT_CAUSE: FOUND`,
  `RECOVERY_PASSWORD_ROOT_CAUSE: NOT_FOUND`,
  `PASSWORD_UPDATE_AUDIT_EVENT_PRESENT: UNKNOWN`,
  `V1_0_AUTH_BUG_RECOVERY_FALSE_SUCCESS_GUARD: CLOSED IN B5 CODE`,
  `V1_0_AUTH_RETEST_PASSWORD_PERSISTENCE_BEHAVIOR: PASS — B6`,
  `READY_FOR_AUTH_FIX_IMPLEMENTATION: COMPLETED — B5 INTEGRATED`,
  `WAVE_11_PHASE_B4_INTEGRATION: PASS`,
  `WAVE_11_PHASE_B5_INTEGRATION: PASS`,
  `CONFIRMATION_SUCCESS_FEEDBACK_CODE_FIX: PASS`,
  `RECOVERY_FALSE_SUCCESS_GUARD: PASS`,
  `RECOVERY_FRESH_LOGIN_VERIFICATION: PASS`,
  `AUTH_REGRESSION: PASS`,
  `WAVE_11_PHASE_B6_INTEGRATION: PASS`,
  `PHYSICAL_MOBILE_AUTH_ACCEPTANCE: PASS`,
  `PRODUCTION_PASSWORD_RECOVERY_ACCEPTANCE: PASS`,
  `READY_FOR_FINAL_PHYSICAL_AUTH_RETEST: COMPLETED — B6 PASS`,
  `LEGACY_PRODUCTION_CALLBACK_REMOVAL: COMPLETED — B7`,
  `FINAL_PRODUCTION_CALLBACK_ONLY: YES`,
  `PRODUCTION_AUTH_CALLBACK_CUTOVER: COMPLETE`,
  `WAVE_11_PHASE_B7_INTEGRATION: PASS`,
  `READY_FOR_ESENLER_DEMO_DATASET: COMPLETED — PHASE A ARTIFACT READY`,
  `WAVE_12_PHASE_A_INTEGRATION: PASS`,
  `DEMO_DATASET_ARTIFACT: READY`,
  `PRODUCTION_DEMO_SEED_APPLIED: YES — 4/20/57/285`,
  `READY_FOR_DEMO_DATASET_PHASE_B: COMPLETED — SAFETY REVIEW INTEGRATED`,
  `WAVE_12_PHASE_B_INTEGRATION: PASS`,
  `DEMO_SEED_SAFETY_REVIEW_INTEGRATED: YES`,
  `OWNER_DEMO_SEED_AUTHORIZATION: GRANTED_AND_CONSUMED_FOR_EXACT_SEED`,
  `READY_FOR_OWNER_DEMO_SEED_AUTHORIZATION: COMPLETED — PHASE C`,
  `PRODUCTION_DEMO_CUSTOMER_READ: PASS — ANON RLS ROLE`,
  `PRODUCTION_DEMO_CLEANUP_RUN: NO`,
  `WAVE_12_PHASE_C_INTEGRATION: PASS`,
  `PRODUCTION_DEMO_DATASET_LIVE: YES`,
  `PRODUCTION_DEMO_SEED_REAPPLIED: NO`,
  `READY_FOR_PRODUCTION_DEMO_VISUAL_SMOKE: YES`,
  `WAVE_12_PHASE_D_INTEGRATION: PASS`,
  `PRODUCTION_DEMO_FUNCTIONAL_SMOKE: PASS`,
  `FUNCTIONAL_RELEASE_BLOCKERS: NONE`,
  `COSMETIC_UI_POLISH: DEFERRED`,
  `READY_FOR_NEXT_RELEASE_GATE: YES`,
  `KEYSTORE_PRIMARY_BACKUP: COMPLETED`, `IOS_SIGNING_READY: NO` ve
  `COMMERCIAL_RELEASE_READY: NO` olarak korunur.
- Esenler demo dataset Phase A artefaktı ve Phase B safety review'i ardından owner
  yetkili Phase C Production apply `4/20/57/285` ve anon customer-read postflight ile
  PASS tamamlanmıştır. Cleanup uygulanmamıştır ve ayrı owner yetkisi olmadan çalışmaz;
  user activity sonrası blind cleanup otomatik yetkili değildir. Fiziksel merchant
  scanner/iki-cihaz QR, Play Console/Play App Signing, ikinci offline keystore yedeği,
  iOS signing/archive, final UI kit ve final commercial GO ayrıca açık kalır.
- Deferred `brand-logos`, `avatars`, `review-images` ile legacy order final drop durumları Wave 8'de değiştirilmedi ve bu başlık altında yanlışlıkla blocker'a yükseltilmedi.

### C10. Iconsax Release Build Hardening

- Durum: **COMPLETED / CLOSED**.
- Sorunlu `iconsax 0.0.8` kaldırıldı; `iconsax_flutter 1.0.1` lockfile'da direct dependency olarak sabittir.
- Repo-local `iconsax_compat.dart` yalnız uygulamanın kullandığı icon yüzeyini açar; geçersiz/sıfır codepoint regression testiyle korunur.
- Sentetik client-safe Production config ile standart Web release build ek icon workaround'u olmadan PASS oldu; gerçek Production artifact/config ve smoke C9 altında açık kalır.

## Güncelleme Kuralı

- Ürün sahibi karar verdiğinde ilgili madde `PRODUCT DECISION NEEDED` bölümünden onaylı işe taşınır ve karar metni açıkça kaydedilir.
- Kod tamamlandığında madde doğrudan silinmez; doğrulama ve release sonucu kaydedildikten sonra tamamlandı olarak işaretlenir veya geçmiş kaynağına taşınır.
- Production agentlar backlog'u geniş çapta yeniden yazmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
