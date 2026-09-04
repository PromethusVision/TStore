# Astra Execution Protocol

Durum: **W44B — CALIBRATION PROTOCOL V1**
Başlangıç: **2026-09-05 (Europe/Istanbul)**
Model: **GPT-6 Astra**

Bu belge Product Owner'ın W44B görev sözleşmesini Astra çalışma paketleri için
uygulanabilir kurallara dönüştürür. Model performansı hakkında benchmark iddiası
değildir. `AGENTS.md` bu dalgada değiştirilmez; yalnız kalibrasyonla kanıtlanan
kurallar daha sonra ayrı bir görevle oraya taşınabilir. Açık görev kapsamı,
yetki sınırları ve mevcut ürün/güvenlik kararları korunur.

## 1. Korunan W44A başlangıcı

- Integration base: `c0462dbaf3955a7a064f05c214e2517092629e3b`.
- W44A source: `origin/analysis/w44a-customer-ui-inventory-acceleration`.
- İncelenen source HEAD: `6b89d84a80302444c14bf3c985ccdeb6a4ba953f`.
- Envanter: [Customer Surface Inventory](UI_W44_CUSTOMER_SURFACE_INVENTORY.md).
- Tarihsel planlama: [60-Day Acceleration Plan](UI_W44_60_DAY_ACCELERATION_PLAN.md)
  ve [Next 10 Work Packages](UI_W44_NEXT_10_WORK_PACKAGES.md).

| Ölçü | W44A başlangıç değeri |
|---|---:|
| Erişilebilir tam ekran | 34 |
| Aktif modal/sheet/dialog/menu/overlay | 24 |
| Paylaşılan durum ailesi | 3 |
| Final UI V1 tamamlanan ana özellik | 5 |
| Kalan dönüşüm birimi | 54 |
| Tier A | 8 |
| Tier B | 18 |
| Tier C | 28 |
| FIGMA_HEAVY | 8 |
| FIGMA_LIGHT | 9 |
| FIGMA_NOT_REQUIRED | 37 |

Kalan iş: **30 tam ekran + 22 modal + 2 durum ailesi = 54**. Tier ve Figma
dağılımları bu 54 birime aittir. Home, Category/Recursive Browse, Product Listing,
Product Details ve Seller Comparison `DONE / MAIN` olarak korunur. Seller
Comparison route'a bağlı değildir; beş tamamlanmış ana özellik içinde sayılması
34 erişilebilir ekrana bir ekran daha eklemez. Route activation ayrı görevdir.

W44A dosyaları kendi tarihli planlama bağlamıyla korunur. Saat/gün tahminleri,
60 günlük ritim ve olası pilot kesintileri Astra için başarı eşiği, ölçülmüş
benchmark veya otomatik kapsam azaltma yetkisi değildir. Astra'nın oturum,
checkpoint ve test ritmi bu protokole göre yürütülür. Kabul edilen görev
sözleşmesindeki kapsam, salt süre tahmini nedeniyle sessizce küçültülemez.

## 2. Session rule

- **Yeni büyük iş paketi = yeni GPT-6 Astra konuşması.**
- Mevcut bir Sol konuşması, konuşmanın ortasında Astra'ya çevrilmez.
- **Worktree kalıcıdır; konuşma geçicidir.** Konuşma bittiğinde worktree, branch,
  commit ve doğrulama kanıtları görevin devamı için korunur.
- Branch, o worktree'nin/oturumun görevine aittir. Başka aktif görevin branch'i
  sahiplenilmez; kullanıcının branch adı varsa aynen kullanılır.
- Başlangıçta gerçek çalışma dizini, Git kökü/ortak dizini, çalışma ağacı,
  başlangıç HEAD'i, base ve görev branch'i doğrulanır. Yeni konuşma mevcut
  checkpoint'ten devam ediyorsa yalnız kalan kapsamı üstlenir.
- Tamamlanan bir görevden sonra worktree yeniden kullanılacaksa önce temiz durum
  ve yeni göreve ait branch doğrulanır. Konuşmanın yenilenmesi commit geçmişini
  yeniden yazma veya eski worktree'yi silme gerekçesi değildir.

## 3. Autonomy ve large package mode

Çalışma döngüsü: **Inspect → implement → test → fix → checkpoint → continue.**

- Astra görevleri bilinçli olarak büyük tutulur. Başlangıçta tek görev sözleşmesi
  içinde bağımsız alt paketler, bağımlılıklar, dosya sahipliği ve kabul ölçütleri
  belirlenir. Envanter ID'leri kullanılarak kapsamın iki kez sayılması önlenir.
- Sözleşme birden fazla ekran/paket içeriyorsa ilk ekran veya ilk alt paket
  sonunda yapay olarak durulmaz. Kapsam içindeki tüm bağımsız işler tamamlanır.
- Rutin inceleme, uygulama, test, düzeltme, commit ve yetkili task-branch push'u
  için mikro onay istenmez. Yeni iş paketi önerisi tek başına uygulama yetkisi
  değildir; mevcut sözleşme dışındaki 54 birimin tamamı kendiliğinden üstlenilmez.
- Bir alt paket bloke olursa engel, etkilenen ID/dosyalar, bağımlı işler ve gerekli
  karar kaydedilir. Bağımsız alt paketler sürdürülür; bloke iş tamamlandı sayılmaz.
- Kullanıcı kararı için yalnız iş davranışı, güvenlik, veri bütünlüğü, Tier A
  görsel yönü veya uzak sistem yetkisini maddi biçimde etkileyen Product Owner
  kararlarında durulur. Durma etkilenen işle sınırlıdır; bağımsız iş devam eder.
- Teknik hata önce görev kapsamında çözülür. Yetki veya ortam engeli varsa
  olmayan erişim varsayılmaz, doğrulanamayan sonuç başarılı gösterilmez. Tüm kalan
  işler aynı engele bağlıysa kanıt ve gerekli karar ile handoff yapılır.
- Yüzde 90 kalibrasyon eşiği erken bırakma izni değildir. Tamamlanabilir bağımsız
  kapsam kapanmadan yalnız puan almak için çalışma sonlandırılmaz.

## 4. Checkpoints ve integration

- Tutarlı alt paketler ayrı commit edilir. Commit yalnız o göreve ait, incelenmiş
  ve gerekli alt-paket kontrollerinden geçmiş değişiklikleri içerir.
- Her tamamlanmış alt paketin checkpoint'i yetkili task branch'ine push edilir;
  böylece sonraki bir blocker önceki tamamlanmış işi kaybettirmez.
- Checkpoint raporu commit SHA, kapsam, test durumu ve henüz bekleyen final gate'i
  gösterir. Checkpoint, main entegrasyonu veya release kabulü değildir.
- Başarısız kontrol, unresolved conflict veya ayrıştırılamayan başka görev
  değişikliği otomatik commit/push'a dahil edilmez. Güvenli tamamlanan bağımsız
  kapsam ayrı checkpoint ile korunabilir.
- **Force push yapılmaz.** Başka görevin geçmişi veya değişiklikleri yeniden
  yazılmaz, silinmez, resetlenmez.
- **Worker agents never merge main.** Worker yalnız kendi görev branch'ine push
  eder; main'e merge/push yalnız açık integration/release yetkisi olan agente
  aittir. Entegrasyon ajanı remote base'i, birleşik diff'i ve final gate'i doğrular.
- Remote main beklenmedik ilerlediyse kör push yapılmaz; yeni delta ve birleşim
  güvenliği incelenir. Anlamı güvenli biçimde çözülemeyen conflict kaydedilir.

## 5. Test strategy

- Her alt paketten sonra ilgili unit/widget/golden/contract testleri çalışır;
  hata düzeltilir ve etkilenen kontroller tekrar edilir.
- Her küçük değişiklikten sonra bütün Flutter suite çalıştırılmaz.
- Runtime/Flutter paketi için **final package gate'te bir birleşik tam suite**
  çalıştırılır (`flutter test --no-pub`); Flutter/Dart değişiklikleri ayrıca
  `flutter analyze --no-pub` ile doğrulanır. Kritik auth/security/data/shared-UI
  değişikliği daha erken birleşik doğrulama gerektirebilir.
- Tam suite, paketin birleşik son halini kapsar. Sonrasında ilgili kod değişirse
  etkilenen testler ve değişikliğin gerektirdiği final doğrulama yenilenir.
- Testler hız kazanmak için zayıflatılmaz, silinmez veya `skip` eklenmez. Golden
  farkları da yalnız testi geçirmek amacıyla körlemesine kabul edilmez.
- Başarısız veya çalıştırılamayan final suite açıkça raporlanır; `PASS` yazılmaz
  ve main gate'i geçmiş sayılmaz.
- UI doğrulaması kapsamına göre loading/empty/error/success, navigation,
  validation, duplicate-submit, slow/offline, dar ekran, metin ölçeği ve keyboard
  davranışını kapsar. Product Owner'ın Tier A görsel kararı otomatik testle
  verilmiş sayılmaz.
- **Gerçek docs-only görev istisnası:** tüm kaynak commit'leri ve birleşik diff
  yalnız dokümantasyonsa Flutter testleri/analyzer `NOT_REQUIRED — DOCS_ONLY`
  olarak raporlanır. `git diff --check`, secret/PII taraması ve kapsam incelemesi
  yapılır. Çalıştırılmayan Flutter kontrolleri `PASS` diye gösterilmez.

## 6. Figma

| Sınıf | Astra uygulama kuralı |
|---|---|
| FIGMA_HEAVY | İş öncelikle Design Owner'a aittir. Tier A yönü owner kararıyla sabitlenir; implementation mevcut onaylı kompozisyonu tüketir. |
| FIGMA_LIGHT | Yalnız görevle ilgili belirli referans/node/component incelemesi. Exploratory crawling, geniş dosya taraması ve yeni sistem araştırması yapılmaz. |
| FIGMA_NOT_REQUIRED | **Figma erişimi yasaktır.** Figma aracı/bağlantısı açılmaz; entegre Flutter Final UI kullanılır. |

- Karma paketlerde izin yüzey bazındadır. Bir LIGHT/HEAVY yüzey, komşu
  NOT_REQUIRED yüzey için Figma erişim yetkisi oluşturmaz.
- Entegre Flutter Final UI implementation truth'tur. Eski Figma değeriyle
  authoritative Flutter token/component değiştirilmez.
- Loading/empty/error/responsive varyantları için Figma'da keşif veya yeniden
  çizim turu açılmaz; mevcut implementation ve Flutter doğrulamaları kullanılır.
- Rapor, planlanan sınıfı ve gerçekten yapılan Figma işlemlerini ayrı gösterir.
  Gözlenebilen çağrı sayısı ve amaç yazılır; ölçülemeyen sayı `NOT_OBSERVABLE`
  olur. Bu oturumda hiç Figma erişimi yoksa `0` ve `FIGMA_ACCESSED: NO` yazılır.

## 7. Shared UI ve dosya sahipliği

- Mevcut Final UI primitives tüketilir: `EsnaftaVarScaffold`,
  `EsnaftaVarSectionHeader`, `EsnaftaVarStateCard`,
  `EsnaftaVarSurfaceIconButton` ve authoritative theme/tokens.
- Kaynak: [Shared Component Ownership](UI_W39_SHARED_COMPONENT_OWNERSHIP.md).
  Ekran başına ikinci token/theme/component ailesi oluşturulmaz.
- W44 paketlerinde `lib/core/ui/`, ortak theme, global navigation/listener ve
  ortak test altyapısı Integration Agent'ın tek yazarlık hattında koordine edilir.
  Aynı primitive birden fazla branch'te eşzamanlı değiştirilmez.
- Shared değişiklik kaçınılmazsa şu açık kayıt yapılır:

  ```text
  SHARED_COMPONENT_CHANGE_REQUIRED: YES
  EXACT_FILES: <tam repo-relative dosya yolları>
  REASON: <mevcut primitive neden yeterli değil; gereken somut değişiklik>
  CONSUMERS_AND_TESTS: <etkilenen ekranlar ve regression kapsamı>
  OWNER_BRANCH: <tek yazarlık branch'i veya bekleyen integration handoff>
  COLLISIONS: <çakışan görev/dosyalar veya NONE>
  ```

- Kayıt, başka branch'in dosyasını değiştirme yetkisi değildir. Tek yazarlık
  netleşene kadar shared değişiklik bloke edilir; bağımsız ekran işi sürdürülür.
  Aynı ihtiyacı gizleyen ekran-yerel primitive kopyasıyla sahiplik kuralı aşılmaz.
- All Products/Search aynı dosyanın tek paketidir. Cart → Purchases → Reviews ve
  auth/account handoff bağımlılıkları W44A paket planına göre korunur.

## 8. Remote authority

- **Production erişimi, ayrıca açıkça yetkilendirilmedikçe yasaktır.** UI paketi
  production read/write, migration, deployment veya gerçek veri denemesi içermez.
- Development yazmaları hedef ortam ve işlem için açık görev yetkisi gerektirir.
  Mevcut credential veya araç bulunması yetki anlamına gelmez.
- UI paketleri varsayılan olarak lokaldir; mevcut fixture/mock ve yerel test
  kanıtları kullanılır. İlgisiz backend/remote işler göreve eklenmez.
- Yetkili Git fetch/task-branch push ile Development/Production veri erişimi ayrı
  yetkilerdir. Worker checkpoint yetkisi main push veya deploy yetkisi vermez.
- Secret/PII log, doküman veya commit'e yazılmaz; inceleme sonuçları değerleri
  göstermeden raporlanır. Parola gerekiyorsa sohbet içinde istenmez.

## 9. TASK_RESULT metrics

Her Astra `TASK_RESULT`, mevcut proje sonuç raporuna aşağıdaki alanları ekler.
Gözlenemeyen veri tahminle doldurulmaz; `NOT_OBSERVABLE` ve nedeni yazılır.

| Alan | Zorunlu kanıt |
|---|---|
| Start/base | Başlangıç zamanı ve saat dilimi gözlenebiliyorsa; başlangıç HEAD, base SHA, branch/worktree, model/oturum bağlamı |
| Scoped / attempted / completed | Sözleşmedeki alt paketler ve inventory ID'leri; denenen/tamamlanan/bloke kalanlar, kabul kanıtı ve tamamlanma oranı |
| Elapsed wall-clock | Gözlenebilen başlangıç/bitiş ve geçen süre; araç/owner beklemeleri dahil ölçüm sınırı. Agent-hour ile karıştırılmaz. |
| Files changed | Base'e göre dosya sayısı, yolları ve değişen ana alanlar; runtime/config/backend/docs ayrımı |
| Commits/checkpoints | Commit SHA ve alt paket eşlemesi; her checkpoint'in branch/push sonucu |
| Tests | Hedefli test komutları, sonuçlar, başarısızlıklar ve düzeltmeler; analyzer sonucu |
| Full-suite result | Final birleşik revision, komut ve sonuç; docs-only ise gerekçeli NOT_REQUIRED; blokeyse açık durum |
| Figma | Yüzey bazında sınıflandırma, erişim, gözlenebilen çağrı sayısı ve amaç; Design Owner handoff'u ayrı belirtilir |
| Blockers | Somut engel, etkilenen işler, kanıt ve devam edilen bağımsız işler; yoksa NONE |
| Owner decisions required | İş davranışı/security/data/Tier A/remote kararı ve etkisi; yoksa NONE |
| Shared-component collisions | Exact files, görev/branch çakışması, shared-change kaydı ve tek owner; yoksa NONE |
| Calibration | GREEN/YELLOW/RED, gerekçe, kritik regression, scope drift ve substantive owner correction sayısı |
| Next recommended package size | SAME_SIZE / INCREASE_NEXT_SCOPE / REDUCE; önerilen alt paket/birim sayısı ve bağımlılık/çakışma gerekçesi |

Tamamlanma oranının paydası başlangıçta kabul edilen kapsamdır; bloke birimler
paydadan çıkarılmaz. Birim/alt paket ağırlıkları gerekiyorsa iş başlamadan
sözleşmede belirlenir. Yalnız kabul ölçütleri ve gerekli kontrolleri tamamlanan
iş paya dahil edilir. Birim sayısı ile alt paket sayısı ayrı raporlanır.

## 10. Calibration

Her tamamlanan Astra paketi aşağıdaki sınıflardan biriyle değerlendirilir.
Tamamlanamayan çalışma da kapanış raporunda saklanır; başarısız denemeler logdan
çıkarılmaz. Kritik regression, yanlış iş/güvenlik/veri davranışı veya kritik
kullanıcı yolunun bozulması gibi etkileri kapsar.

| Sınıf | Kriter | Sonraki paket önerisi |
|---|---|---|
| GREEN | Kritik regression yok; kapsamın **en az %90'ı** tamam; major scope drift yok; en fazla **bir substantive owner correction** | SAME_SIZE veya INCREASE_NEXT_SCOPE |
| YELLOW | Faydalı tamamlanma var; anlamlı düzeltme, blocker veya merge riski var | SAME_SIZE veya REDUCE |
| RED | Kritik regression, scope drift veya tutarlı biçimde tamamlanamayacak kadar büyük paket | REDUCE |

RED koşulu varsa diğer sonuçlardan önce uygulanır. GREEN bütün koşulları birlikte
gerektirir; meaningful blocker/merge riski varsa yüzde tek başına GREEN vermez.
Substantive owner correction, görsel yönü veya maddi ürün/kapsam kararını yeniden
kurmayı gerektiren düzeltmedir; rutin açıklama veya typo düzeltmesi değildir.

Keyfî süre limitleri başarı kriteri değildir. Süre, gözlenebildiğinde açıklayıcı
ölçümdür. Hız, test zayıflatma veya scope drift'i haklı çıkarmaz. SAME_SIZE,
INCREASE_NEXT_SCOPE ve REDUCE alt paket/birim ve bağımlılık büyüklüğünü ifade eder;
süre kotasını değil.

Sonuçlar [Astra Calibration Log](ASTRA_CALIBRATION_LOG.md) içinde kanıtla tutulur.
Worker sonuç raporunu teslim eder; paylaşılan log kaydını Integration/Coordinator
tek yazarlıkla işler. W44B dokümantasyon kurulumu, Astra UI uygulama benchmark'ı
olarak sayılmaz. İlk gerçek calibration wave sonucu oluşmadan hız/kalite üstünlüğü
veya önerilen kapsam artışı kanıtlanmış ilan edilmez.

`AGENTS_MD_PROMOTION: DEFERRED_UNTIL_CALIBRATION`
