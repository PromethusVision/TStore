# Wave 44A — 60-Day Customer UI Acceleration Plan

Durum: **W48 MILESTONE REVISION — PLANNING ONLY, 2026-09-05**
Base: `origin/main@c0462dbaf3955a7a064f05c214e2517092629e3b`

Aşağıdaki **1–10. bölümler tarihsel W44A, Bölüm 11 tarihsel W45D planlamasıdır**. Güncel milestone ve sahiplik Bölüm 13'tedir: **8 kalan birim / 67 nominal h**, tamamı W49. Bölüm 12'nin üç senaryosu ve dış kapı payları korunur; kalan iş sayıları tarihseldir. Eski saat/gün modeli güncel ölçülmüş forecast değildir.

## 1. Yönetici özeti — tarihsel W44A

Customer UI'nin kalan işi 34 route-reachable tam ekrandan 30'u, 24 aktif modal
yüzeyden 22'si ve üç shared-state ailesinden ikisidir: **54 dönüşüm birimi**.
Home, Category/Recursive Browse, Product Listing, Product Details ve Seller
Comparison **DONE / MAIN** durumundadır. Seller Comparison route'a bağlı olmasa
da UI işi yeniden açılmayacaktır.

Kalan tam ekranların hiçbiri saf, erişilebilir `OLD_UI` değildir; 30'u yeni renk,
tipografi veya component dilini kısmen kullanır fakat Product Owner-approved Final
UI closeout almamıştır. Bu, işin bir yeniden yazım değil, yoğun bir tutarlılık,
composition ve regression programı olduğunu gösterir.

Önerilen işletim modeli:

- Bir Design/UI Owner sekiz Tier A yüzeyi için sıralı ve küçük `390 px` karar
  paketleri üretir.
- İki implementation agent, birbirine dosya olarak değmeyen discovery/commerce ve
  account/transaction paketlerini yürütür.
- Integration Agent shared foundation, navigation ve birleşik regression'ın tek
  sahibidir.
- Tier B/C işlerinde Figma varsayılan olarak kullanılmaz; yalnız dokuz hedefli
  light-reference birimi vardır.

Bu model agent-saatini azaltmaz; koordinasyon yüzünden yükseltir. Beklenen takvim
süresini yaklaşık **%30** azaltarak 60 takvim günlük hedefi daha savunulabilir hale
getirir.

## 2. Kalan iş ve efor modeli

Inventory satırlarındaki saatler mevcut business/auth/navigation davranışını
koruyan UI closeout, hedefli widget/golden ve dar regression içindir. Full suite,
merge incelemesi ve owner-gate bekleme payı ayrıca eklendi.

### Tek UI Agent + Integration Agent

| Katman | Birim | LOW | EXPECTED | HIGH | Açıklama |
|---|---:|---:|---:|---:|---|
| Tier A | 8 | 78 h | 103 h | 140 h | Prototype, owner gate, responsive/state closeout |
| Tier B | 18 | 78 h | 104 h | 145 h | Direct Final UI implementation ve regression |
| Tier C | 28 | 31 h | 43 h | 60 h | Batch conversion; iki shared-state ailesi dahil |
| Cross-cutting integration | — | 24 h | 30 h | 44 h | Full test, analyzer, golden review, merge/rework |
| **Toplam** | **54** | **211 h** | **280 h** | **389 h** | Agent-hour |

Altı üretken agent-saat/gün varsayımıyla saf çalışma süresi yaklaşık
**35 / 47 / 65 iş günü**dür. Owner yanıtı, CI ve hafta sonları eklendiğinde
expected senaryo yaklaşık 60 takvim günü sınırındadır; high senaryo aşar.

Bu aralık stopwatch ölçümü değildir. Gözlenen W39–W43 sürecindeki major screen
başına prototype → owner approval → R2 closeout → integration modeli, dosya
büyüklüğü, state sayısı ve mevcut test yoğunluğundan türetilmiştir. Her ekrana
sabit iki saat varsayılmamıştır.

### Hızlandırılmış model

| Ölçü | LOW | EXPECTED | HIGH |
|---|---:|---:|---:|
| Toplam agent-hour | 236 h | 315 h | 435 h |
| Tahmini kritik-yol süresi | 25 iş günü | 33 iş günü | 46 iş günü |
| Tek-agent kritik-yoluna göre azalma | %29 | %30 | %29 |
| Yaklaşık takvim süresi | 35 gün | 46 gün | 64 gün |

Agent-hour artışı branch setup, iki ayrı regression, integration incelemesi ve
muhtemel rework payıdır. İki agente bölmek saatleri üçe bölmez: Tier A owner
gate'leri, aynı dosyadaki All Products/Search, Cart→Purchases→Reviews contract
zinciri ve full Flutter suite kritik yolu sınırlar.

## 3. Figma bütçe modeli

| Sınıf | Birim | Çalışma biçimi |
|---|---:|---|
| FIGMA_HEAVY | 8 | Yalnız bir `390 px` owner-decision composition; runtime states Figma'da çoğaltılmaz |
| FIGMA_LIGHT | 9 | Var olan reference/component bakışı; yeni design system yok |
| FIGMA_NOT_REQUIRED | 37 | Flutter Final UI foundation doğrudan kaynak |

Quota riski **MEDIUM**'dur. Sekiz heavy yüzey art arda yüksek varyant sayısıyla
işlenirse quota ve owner-review kuyruğu kritik olur. Kontrol:

1. Her Tier A yüzey için tek karar frame'i.
2. Loading/empty/error/responsive varyantları Flutter test/golden'da.
3. Tier B/C'de yeni Figma dosyası veya exploratory branch yok.
4. Shop/Product/Section/State primitives tekrar çizilmez.
5. Canonical 24 Category Visual Pack bu 60 günlük core conversion bütçesine
   katılmaz.

## 4. Dependency graph ve integration sırası

```text
Final UI foundation (kilitli shared owner)
├─ Shop Details ──┬─ Nearby
│                 └─ All Products / Search
├─ Cart V2 + QR ─── Purchases ─── Reviews
├─ Auth suite ───── Settings / Profile / Saved Locations / Privacy
├─ Chat detail ──── Conversations / Notifications
└─ Secondary library (Wishlist / Recent / Ratings / Coupons / Help)
```

Gerçek bağımlılıklar:

- Shop Details, Nearby ve Search shop-card/header primitives paylaşabilir.
- All Products ve Search aynı `all_products_view.dart` dosyasındadır; iki agent
  aynı anda değiştiremez.
- Cart V2'nin QR sonucu Purchases'a; verified purchase evidence Reviews'a gider.
  Bu contract sırası korunur.
- Auth listeners, Profile/account deletion ve Settings handoff'ları birlikte
  regression görmelidir.
- Notifications, Purchases ve Chat'e type-based navigation yapar; hedef ekranlar
  stabilize olduktan sonra entegre edilmesi rework azaltır.

## 5. Güvenli paralel çalışma modeli

### Design/UI Owner

- Sadece sekiz Tier A yüzeyinin karar kompozisyonlarını ve shared component
  kullanım kurallarını hazırlar.
- Bir yüzey için Product Owner gate'i kapanmadan aynı yüzeyin structural closeout
  talimatını değiştirmez.
- Shared `core/ui`, theme/tokens, product/shop/card primitives için tek karar
  sahibidir; implementation agent'lar yeni competing design primitive üretmez.

### Implementation Agent 2 — Discovery/Commerce read path

- Paketler: Shop Details, All Products/Search, Nearby/location, Wishlist ve
  product/shop discovery secondary surfaces.
- Başlıca dosya alanları:
  `lib/features/shop/presentation/views/`, ilgili shop widgets ve hedefli tests.
- Cart, purchases, auth, profile veya shared foundation'a dokunmaz.

### Implementation Agent 3 — Account/Transaction/Communication

- Paketler: Auth, Settings/Profile/Saved Locations/Privacy, Cart/QR, Purchases,
  Reviews, Chat/Conversations/Notifications.
- Bu alt paketleri kendi içinde sıralı yürütür; Cart/Purchases/Reviews aynı anda
  değiştirilmez.
- Discovery agent'ın shop/product card dosyalarına dokunmaz.

### Integration Agent

- `NavigationMenu`, global auth/deep-link listeners, shared UI foundation,
  service locator ve ortak test harness'larının tek yazarıdır.
- Her task branch'ini isolated diff + targeted tests ile alır; sonra full Flutter
  suite/analyzer/golden review çalıştırır.
- Önerilen integration order:
  1. Auth essentials ve foundation-only batch
  2. Shop Details
  3. All Products/Search
  4. Nearby/location
  5. Cart V2/QR
  6. Purchases/Ratings
  7. Reviews
  8. Chat/Conversations
  9. Notifications/account hub
  10. Secondary batch

### Paylaşılan çakışma riskleri

| Alan | Risk | Kural |
|---|---|---|
| `all_products_view.dart` | HIGH | Search ve catalog tek package/agent |
| `product_sellers_section.dart` | HIGH | Seller Comparison done; modification yalnız ayrı regression gate ile |
| Cart/Purchases/Reviews contracts | HIGH | Sıralı integration; business semantics değişmez |
| `navigation_menu.dart` / cubit | HIGH | Integration Agent only |
| Auth listeners/deep links | HIGH | Auth package + Integration Agent review |
| `core/ui` tokens/components | HIGH | Design Owner kararı, Integration Agent write ownership |
| Product/shop cards | MEDIUM | Önce Shop Details primitive contract, sonra Search/Nearby reuse |
| Full Flutter suite/goldens | MEDIUM | Tek birleşik integration kuyruğu |

Üç-agent paralelliği aynı feature/file ailesinde güvenli değildir. Özellikle
All Products/Search, Cart/Purchases/Reviews ve Settings/Profile/Saved Locations
aynı anda farklı agent'lara bölünmemelidir.

## 6. 60 günlük commercialization kritik yolu

### Pilot öncesi mutlaka tamamlanmalı

- Tier A: All Products, Search, Nearby, Shop Details, Cart V2, Purchases, Product
  Reviews ve Chat detail.
- Cart QR sheet, review editor, saved-location editor ve location permission
  modal ailesi.
- Login, Signup, email confirmation ve password-recovery zincirinin tutarlı Final
  UI closeout'u.
- Wishlist, Settings/Profile, Saved Locations ve Privacy/Permissions.
- Notifications ile Purchases/Chat hedeflerinin bozulmamış navigation'ı.
- Launch/onboarding, loading/error/empty, auth gate ve client-safe error feedback.
- Responsive `320/390/430 px`, `%130` text scale, keyboard, long content ve
  accessibility regression.
- Customer UI'den bağımsız release/signing/production gates ayrıca kapanmalı;
  UI bitişi Production rollout demek değildir.

### Kapalı pilotta functional-but-not-perfect kalabilir

- Customer Coupons: gerçek coupon engine yokken truthful empty/info state.
- Recently Viewed history visual polish.
- Customer Ratings history polish; rating creation/contract bozulmamalı.
- Help & Support secondary composition polish; erişilebilir iletişim yolları
  korunmalı.
- Legal belge kartlarının kozmetik polish'i; okunabilirlik ve içerik değişmez.
- Canonical 24 Category Visual Pack.

### Pilot sonrası ertelenebilir

- Ads yüzeyleri.
- Reward economics/redemption UI; mevcut Home reward slot'u runtime default OFF.
- Gamification/advanced reputation UI.
- Full Merchant feature set; yalnız ayrı tanımlanan Merchant pilot minimum scope.
- İleri artwork ve mikro animasyon polish'i.

## 7. Commercial pilot UI cut line

**Final UI zorunlu:** müşterinin ilk girişi, login/signup/recovery, Home'dan ürün ve
esnafa gidiş, Search, Nearby, Shop Details, Product Details, seller context, Cart
V2/QR hazırlığı, verified purchase history, Reviews, Wishlist, Profile/Privacy,
Saved Locations, Notifications ve aktif Chat akışı.

**Functional-but-not-perfect kabul edilebilir:** coupons, recent history, rating
history ve help/legal secondary composition. Bunlar crash, görünmez CTA, bozuk
navigation, okunamayan metin veya yanlış veri içeremez; yalnız kozmetik closeout
pilot sonrasına kalabilir.

Seller Comparison, Home, Category, Product Listing ve Product Details yeniden
açılmaz. Category Visual Pack'in ertelenmesi kategori navigation veya product
discoverability'yi bloke etmez.

## 8. Risk register

| Risk | Olasılık | Etki | Kontrol |
|---|---|---|---|
| Owner gate kuyruğu Tier A'yı seri hale getirir | MEDIUM | HIGH | Haftada en çok iki kısa karar paketi; tek frame |
| Shared component drift | MEDIUM | HIGH | Tek shared owner + Integration Agent |
| UI işi business semantics'i yanlışlıkla değiştirir | LOW/MEDIUM | HIGH | Contract tests; data/RPC/cubit değişikliğini scope dışı tut |
| Full suite ve golden runtime kritik yolu uzatır | HIGH | MEDIUM | Targeted test önce; birleşik suite integration kuyruğunda |
| İki agent aynı dosyada çalışır | MEDIUM | HIGH | Package/file allowlist ve integration order |
| Figma quota tüketimi | MEDIUM | MEDIUM | 8 heavy + 9 light tavanı; states Flutter'da |
| Auth/privacy polish ertelenir | LOW | HIGH | Pilot cut line'da zorunlu |
| “Order/payment” veya reward semantiği UI'ye sızar | LOW | HIGH | Purchases/Cart truthful copy regression |
| 60 gün içinde high-case rework | MEDIUM | HIGH | İlk iki haftada Shop/Search/Auth leverage paketleri |

## 9. Önerilen 60 günlük ritim

| Dönem | Design/UI Owner | Agent 2 | Agent 3 | Integration |
|---|---|---|---|---|
| Gün 1–10 | Shop + Search gate | Shop Details | Auth essentials | Foundation/auth merge |
| Gün 11–20 | Nearby + Cart gate | All Products/Search | Account hub | Shop/Search merge |
| Gün 21–30 | Purchases + Reviews gate | Nearby/location | Cart/QR | Nearby/Cart merge |
| Gün 31–40 | Chat gate | Secondary discovery | Purchases/Reviews | Transaction merge |
| Gün 41–50 | Delta decisions only | Wishlist/secondary | Chat/Notifications | Communication/account merge |
| Gün 51–60 | No new design | Defect closeout | Defect closeout | Full regression, release handoff |

Gün 51'den sonra yeni composition açılmaması 60 günlük cut line'ın ana korumasıdır.
High-case 64 takvim güne yaklaşır; Gün 30'da kalan Tier A sayısı ikiden fazlaysa
secondary polish otomatik olarak post-pilot'a kaydırılmalıdır.

## 10. Tavsiye

60 günlük hedef için **1 Design/UI Owner + 2 non-overlapping implementation agent
+ 1 Integration Agent** modeli önerilir. Bu öneri, üç agent'ın aynı screen'i
parçalaması değildir. Unit of ownership dosya/feature package olmalı; shared
foundation yalnız integration hattında değişmelidir. Product Owner'dan yalnız
sekiz Tier A karar yüzeyi için görsel gate istenir; geri kalan 46 birim established
Flutter language ile kapanır.

Bu plan Customer UI bitişini Merchant pilot minimum, release gates ve Production
rollout'tan ayrı tutar. Ads, Reward economics, Gamification ve advanced Reputation
60 günlük Customer UI prerequisites değildir.

## 11. Historical W45D revision — superseded by Section 12

Revision date: **2026-09-05**, Day 0 of the scenarios below. This is a planning
update, not new implementation/release authority or a promised launch date.
Historical numbers above remain available for comparison. The active baseline
is [W45 actual surface inventory](UI_W45_POST_CALIBRATION_SURFACE_INVENTORY.md):
**34 reachable screens; 23 active modals; 38 remaining units (17 + 19 + 2)**;
Tier A/B/C **6/15/17**, Figma HEAVY/LIGHT/NONE **6/6/26**. Nominal remaining direct
size is **203 h**, excluding integration, owner waiting and commercial gates.

### What the measured packages change

Discovery closed 17 nominal h in 26m01s to its tested checkpoint; Auth/Startup
closed 30 nominal h in ~28 minutes total. Both completed GREEN and their combined
integration passed 1637 tests, zero failures, with six pre-existing gated skips
and a clean analyzer. These are two local presentation-heavy packages with
substantial foundation reuse. Their results show that W44 nominal estimates
materially overstated observed Astra completion time for that work.

No minutes-per-screen multiplier is applied to the remaining inventory. The
remaining work contains permission/QR/purchase/review/chat interactions, active
owner closeout, shared integration and potentially hard functional defects.
A single frozen screen, signed release, hardware journey or backend incident may
consume more calendar time than either measured package. Nominal hours are now
used to compose coherent **40–60 h scope contracts**, not six productive hours
per day as a measured throughput conversion. Design stays at **three decisions**.

### Current workstream sequence

1. W45A-R2 is already active on its own branch. New checkpoint 4ae9d6d reports
   Shop/Cart/Nearby direction approval and continuing closeout; it is not merged
   by W45D. Finish its separate acceptance/integration before claiming those
   three main surfaces complete. Never create duplicate Shop/Cart/Nearby tasks.
2. Proposed Wave 2 Agent 2: **Account Hub 44 nominal h / 9 units**. It uses
   integrated Auth, no per-screen Tier B/C owner gate. Shared location helper
   APIs stay frozen; Nearby and Account do not write them concurrently.
3. Design Batch 2: at most **Purchases, Reviews, Chat** representative prototypes.
   Resolve owner decisions in a bounded batch; no Figma states/variant expansion.
4. Proposed Wave 2 Agent 3: **Purchases/Shop Ratings -> Product Reviews 45 nominal
   h / 6 units**, sequentially in one branch after separately accepted Cart/QR
   and the corresponding visual directions. No Cart or Shop owner files edited.
5. Subsequent composition groups consume the remaining Messaging/Notifications,
   Wishlist/secondary and shared-state work with another inventory refresh.
   Integration owns common feedback/navigation primitives. These are candidates,
   not started packages; scope/size is revisited after the two larger gates.

The full proposed file ownership, checkpoints, test/Figma cadence and criteria
for 70–100 h escalation or reduction are in
[Wave 2 scope recommendation](ASTRA_WAVE2_SCOPE_RECOMMENDATION.md).

### Scenarios — calendar windows from this revision

The following ranges are **planning assumptions**, not statistically calibrated
Astra forecasts. UI-ready includes local combined regression and accepted visual
composition; pilot-ready additionally requires every external release gate.
UI and commercial work overlap, so row endpoints must not be added together.

| Scenario | Customer UI acceptance window | Conditional commercial pilot window | Explicit assumptions |
|---|---|---|---|
| CONSERVATIVE | **Day 20–30** | **Day 55–75** | PO decisions take 3–5 days per batch; two meaningful rework/integration cycles; a hard functional defect; Merchant minimum, device or signing work delays acceptance. The 60-day pilot is at risk. |
| EXPECTED | **Day 12–20** | **Day 35–55** | PO batch decisions within 1–2 working days; current R2 completes under a separate gate; two isolated implementation lanes; at least one rework reserve per wave; Merchant minimum and release prerequisites proceed in parallel under separate owners. |
| AGGRESSIVE | **Day 6–12** | **Day 21–35** | Existing and next visual directions settle promptly; no major business defect; shared APIs remain stable; daily bounded integration capacity; Merchant minimum, devices, signing and commercial owners are already available. |

These windows deliberately leave multi-day integration, owner and functional
rework buffers despite fast Wave 1 coding. The remaining 203 nominal h does not
convert directly into any row. The old 64-day high case and the conservative
75-day pilot tail remain visible; faster UI alone does not prove a 60-day launch.

### Critical path and reserved acceptance windows

| Gate / work | Expected sequencing and allowance | Exit evidence / limiting owner |
|---|---|---|
| Product Owner visual decisions | Early Day 0–7; batches of at most 3, responses assumed 1–2 working days | Recorded Shop/Cart/Nearby R2 direction and Purchases/Reviews/Chat decisions; prototype-ready is insufficient |
| Integration, conflicts and regression | Across Day 1–20; reserve 1–2 days per combined wave for review/rework even when tools are faster | Shared single-writer plan, semantic merge review, no unexplained test loss, full suite/analyzer/golden acceptance |
| Hard functional bugs | Rolling Day 5–30; expected reserve 5–10 calendar days, potentially longer in conservative case | Reproduction and contract evidence; security/session/QR eligibility correctness before cosmetics; explicit functional task if UI scope is exceeded |
| Merchant App pilot minimum | Parallel separately owned work; target definition by Day 7 and acceptance by Day 20–35 | Minimum merchant receive/verify flow agreed, implemented and tested; current readiness is **not established by W45D** |
| Physical QR acceptance | After customer + merchant builds; reserve Day 20–35 with 3–5 device/merchant test days | Real camera/device journey, session expiry, repeated scan/retry and correct verified purchase; local widgets do not substitute |
| Release and signing | Prepare in parallel; reserve Day 25–40 and 3–7 working days for platform issues | Reproducible signed candidate, platform permission/config acceptance, distribution/review evidence; access and readiness unverified here |
| Legal and support | Separate owner, target closure Day 25–40; reserve 3–7 days | Owner-approved legal/support readiness and operational contact paths; existing legal UI readability is not legal approval |
| Production cutover | Only after all gates; conditional Day 35–55; reserve 2–5 controlled days | Explicitly authorized release/cutover plan, deployment/rollback checks and operational acceptance; no Production operation in this task |

The longest unresolved owner/merchant/hardware/release dependency sets the pilot
window. Production access, Development writes, signing changes, merchant work and
legal decisions are not implicitly authorized by this plan. Their current status
is unknown unless a separate owner supplies evidence; these are reserved windows,
not claims of completed or already scheduled work.

### Recalibration and decision points

- After both 44/45-hour packages and their combined integration, measure actual
  completion, elapsed bounds, corrective work, shared collisions, owner queue and
  test retention. Do not scale to 70–100 solely from fast checkpoints.
- Day 7: reconcile the R2 gate, Design Batch 2 and Merchant minimum definition.
  If either prerequisite is missing, retain it explicitly on the critical path.
- Day 14: review whether the expected UI window remains supported; one major
  functional or owner correction moves planning toward conservative until fixed.
- Day 30: if transaction/QR acceptance or signed candidate prerequisites lack an
  owner and evidence, do not label the pilot ready. Only previously allowed
  cosmetic secondary work can be deferred through the existing pilot cut line;
  never drop auth, eligibility, hardware or truthful-data acceptance.
- Day 45–60: keep time for release defects and commercial gates, not new
  composition/artwork. Confirm the pilot date against actual gate evidence.

No Owner gate, production cutover or new package is scheduled automatically by
this document. Historical package ownership/order in Sections 4–5/9–10 is
superseded for the proposed next wave by the non-overlapping 44/45-hour pairing.

## 12. Wave 2B revision — Account Hub integrated, remaining ownership refreshed

Revision: **2026-09-05**, same scenario Day 0 as Section 11.
Sections 1–11 preserve their historical assumptions and measurement boundaries.
This section supersedes their current-work ordering and remaining counts; it
does not grant implementation, Development, Production or release authority.

### Actual merged progress and calibration

Shop Details, Cart V2 and Nearby have now passed their separate Wave 2A main
integration. Account Hub, Profile, Saved Locations, Privacy, Help and four active
account/location sheets/dialogs pass Wave 2B. Approved Category and the other
earlier Final surfaces remain closed; no duplicated conversion work is planned.

The [current inventory](UI_W46_POST_ACCOUNT_HUB_INVENTORY.md) has **26 remaining
units = 9 screens + 15 modals + 2 shared-state families**, Tier **3/8/15** and
Figma HEAVY/LIGHT/NONE **3/4/19**. Remaining W44 nominal scope is **117 h**.
Global location prompts, Cart confirmations/QR and shared state families remain
open despite their behavior being covered by tests.

There are now three independent implementation GREEN packages: Discovery
**17 nominal h**, Auth/Startup **30 nominal h**, Account Hub **44 nominal h**.
Source Account timing is actually reported: **01:58:05 UTC to approximately
02:44 UTC, about 46 minutes through the full test gate**, with final report/push
later. Its 9/9 result, 30 files, 73 new tests, 12 visual proofs and six checkpoints
are recorded in [calibration](ASTRA_CALIBRATION_LOG.md). Integration timing is a
separate acceptance cost, never a fourth independent implementation benchmark.

These local presentation-heavy results support autonomous coherent packages with
targeted checkpoints. They do not measure Merchant readiness, hardware acceptance,
legal approval, release signing, production reliability or minutes per remaining
screen. Neither 117 h nor the 20–30 minute early observations is converted
linearly into a calendar forecast. No arbitrary time limit defines success.

### Next workstream composition

| Lane | Current recommendation | Historical nominal size | Gate / collision rule |
|---|---|---:|---|
| Design Owner Batch 2 | Purchases, Reviews, Chat; about three representative Tier A prototypes | 3 owner directions | Product Owner direction recorded before dependent final implementation; no parallel ownership of the same presentation |
| Implementation Agent 2 | Wishlist, Recently Viewed and its clear/item actions, Notifications, truthful Coupons | **24 h / 6 units** | Four existing screens + two actions, Tier B/C, one LIGHT reference class; preserve Auth and destination APIs |
| Dependent Agent 3 / reserved Batch 2 implementation | Purchases/Ratings -> Reviews, plus reserved Conversation List/Chat | **67 h / 8 units** | Earlier 45 h / 6-unit candidate plus Chat's 22 h / 2 units; their visual dependencies remain explicit |
| Later interaction package, owner to be assigned | Global location prompts, Nearby consent, Cart conflicts/confirmations and QR sheet | **22 h / 10 modals** | One writer for helpers/Cart/QR; coordinate Purchases handoff, no concurrent common-file edits |
| Integration | Shared loading/feedback families | **4 h / 2 families** | Separate shared ownership and caller regression; no blanket primitive change from worker branches |

The sets are disjoint and sum to **117 h / 26 units**. Proposed Agent 2 starts
independently of Batch 2 visuals while preserving Notifications' Purchases/Chat
constructor and payload contracts. It does not implement those destinations.
All future execution still requires its own task contract and current-main
re-anchor; this integration only prepares the recommendation.

**70–100 nominal h escalation is not recommended for current Agent 2 inventory.**
Once reserved design/dependent work is excluded, only 50 h remains even before
coherence limits. Do not pad scope with unrelated features or reopened completed
UI. The [Wave 3 recommendation](ASTRA_WAVE3_SCOPE_RECOMMENDATION.md) gives exact
IDs/files, checkpoints, Figma restrictions and acceptance requirements. A smaller
available assignment does not reverse Account's GREEN / SAME_SIZE calibration.

### Preserved calendar scenarios

These are planning assumptions from **Day 0 = 2026-09-05**, not measured forecasts
or launch commitments. UI-ready requires local final integration and visual
acceptance; commercial pilot-ready additionally requires every external gate.
Windows overlap and must not be summed. There is no new evidence here that
shortens the external gates, so their prior allowances are retained.

| Scenario | Customer UI acceptance | Conditional commercial pilot | Assumptions after Account integration |
|---|---|---|---|
| CONSERVATIVE | **Day 20–30** | **Day 55–75** | PO decisions take 3–5 days per Batch 2 decision cycle, two rework/integration rounds, meaningful functional defects or delayed Merchant/device/signing acceptance; 60-day pilot remains at risk |
| EXPECTED | **Day 12–20** | **Day 35–55** | Batch 2 PO responses within 1–2 working days; isolated implementation ownership, per-wave rework reserve, Merchant and release prerequisites staffed in parallel |
| AGGRESSIVE | **Day 6–12** | **Day 21–35** | Prompt remaining visual decisions, no major functional defect, stable shared APIs, bounded daily integration capacity and available Merchant/device/signing/legal owners |

### External critical path remains open

| Gate | Preserved allowance / sequence | Evidence still required |
|---|---|---|
| Product Owner visual gates | Early Day 0–7; about three prototypes per batch | Purchases/Reviews/Chat directions and final acceptance; prior Shop/Cart/Nearby approval is complete |
| Integration and rework | Day 1–20, reserve 1–2 days per combined wave | Semantic collision audit, shared ownership, retained tests/goldens, analyzer and one final combined suite; fast prior tools do not remove reserves |
| Hard functional defects | Day 5–30, reserve 5–10 calendar days | Reproduction and resolution of session/QR/eligibility/data-integrity issues; separate functional authority when outside presentation scope |
| Merchant pilot minimum | Definition by Day 7; acceptance target Day 20–35 | Separately owned receive/verify minimum and test evidence; readiness remains unverified here |
| Physical QR | After customer and merchant builds, Day 20–35 with 3–5 test days | Device camera flow, expiry/repeated scan/retry and correct verified purchase; widget tests do not close this gate |
| Release/signing | Day 25–40, reserve 3–7 working days | Signed reproducible builds, permission/platform configuration and distribution acceptance under separate authority |
| Legal/support | Day 25–40, reserve 3–7 days | Owner-approved legal and support operations; unchanged Privacy copy is not legal approval |
| Production rollout | Conditional Day 35–55, reserve 2–5 controlled days | Explicit separate release authority, operational acceptance and rollback plan; no Production access in this task |

Merchant, device, signing, legal and Production readiness are not established by
Account UI acceptance. The longest unresolved owner/external dependency controls
the pilot date. Ads, Reward economics, Merchant implementation and new backend
work are not silently added to the Customer UI contract.

Re-evaluate Day 7 visual/merchant definitions, Day 14 remaining UI/owner evidence,
Day 30 physical-transaction/signed-candidate readiness and Day 45–60 release
defects against actual gate evidence. Do not cut auth, eligibility, data integrity,
hardware or truthful-data checks to fit a date. After each future integration,
recompute remaining IDs and package ownership before proposing scope growth.

## 13. W48 integrated milestone — only W49 major Customer UI remains

Revision **2026-09-05**. This section supersedes Section 12's remaining counts and
next-work proposals. W48's explicit later assignment covered all unreserved
utility/engagement candidates, not only the earlier 24 h recommendation.

The [accepted ledger](UI_W48_POST_INTEGRATION_INVENTORY.md) now has **8 pending
units = 5 screens + 3 modals + 0 shared-state families**, Tier **3/4/1**, Figma
**3/2/3**, historical nominal **67 h**. Four legacy location windows are confirmed
inactive and not counted complete. W48 closes all 14 actual unreserved units.
There is no further unreserved Agent 2 Customer utility package to inflate.

**ONLY_W49_MAJOR_CUSTOMER_UI_REMAINS: YES.** W49 Post-Purchase, Shop Ratings,
Product Reviews and Messaging owns those eight units and the already recorded
nested QR completion/rating dependency. The user has approved all 12 W3B visual
surfaces; W48 09–12 have now passed runtime reconciliation. W49 remains running,
unmerged and pending real-runtime/combined acceptance. Its later integration may
be the final major Customer V1 UI gate; this document neither waits for nor starts
another W49 task.

The declared W48 shared loader/theme/snackbar changes have passed combined
regression. W49 integration must review its source against this new main and
recheck shared consumers, QR completion/rating and typed Notifications targets.
Prototype approval alone cannot mark those destination implementations done.

W48 worker timing **76m41s through its final full gate** is reported in source;
it is a fourth local implementation GREEN point, not a minutes-per-screen rate.
The conservative/expected/aggressive calendar windows and external buffers in
Section 12 remain planning assumptions. No new evidence here closes Merchant
minimum, physical QR, signing, legal/support or separately authorized Production
rollout. Their longest unresolved dependency still controls commercial readiness.
No linear extrapolation or shortened external gate follows from the UI milestone.

## 14. W49 final UI conversion closeout

Revision **2026-09-05**. This supersedes Section 13's pending W49 status and
remaining Customer conversion proposals. W49 is accepted against current W48 main;
all eight assigned active units and the reserved QR completion/rating dependency
are closed. [Runtime inventory](UI_W49_POST_INTEGRATION_INVENTORY.md):
**0 screens / 0 modals / 0 state families remaining**, Tier and Figma **0/0/0**.

All 56 stable active IDs are Final. The approved C1 refund action's contained
sheet is explicitly disclosed, giving 57 current compositions and 20 modal
compositions; it does not inflate the eight-unit worker denominator.
No new Customer conversion work is opened to satisfy a nominal package size.

**CUSTOMER_V1_FINAL_UI_CONVERSION_COMPLETE: YES.** Full integration
**2024 PASS / 0 FAIL / 6 existing conditional skips**, analyzer clean. W3B 01–08
actual-runtime review and W48 shared/navigation/QR reconciliation passed without
an Integration runtime correction. Worker and Integration are GREEN / SAME_SIZE;
reported worker 44m15s is a bounded observation, not an extrapolated delivery rate.

The earlier Customer UI forecast windows are now historical planning assumptions:
the conversion milestone has actual acceptance evidence. This does not redate or
automatically close the external Merchant, physical-device QR E2E, legal/privacy/
support, signing/store publication or Production gates. Their evidence must be
assessed separately; no pilot launch date or commercial-ready flag is created.
Ready for that separately scoped Customer V1 release-gate assessment: **YES**.
No Production access or remote Development write occurred.
