# Customer App Final UI Rollout Plan

## Güncel durum — Astra Wave 2B, 2026-09-05

- **Account Hub, Profile, Privacy, Saved Locations ve Help: DONE / MAIN.**
  Mevcut Profile Edit, hesap silme, konum ekleme ve konum silme yüzeyleriyle
  **5 ekran + 4 aktif sheet/dialog = 9/9 birim** tamamlandı.
- Auth/Startup iş mantığı, guard/session akışları ve KVKK/Terms anlamı korunur.
  Saved Locations → Nearby varsayılan konum dönüşü gerçek ekran testleriyle
  doğrulandı. Konum düzenleme veya çıkış onayı icat edilmedi.
- Home, onaylı Category/Recursive Browse, Listing, Details, Seller Comparison,
  Search, Shop, Cart ve Nearby Final UI korunur; W40A yeniden açılmadı.
- Güncel [envanter](UI_W46_POST_ACCOUNT_HUB_INVENTORY.md):
  **26 kalan birim = 9 ekran + 15 modal + 2 durum ailesi**;
  Tier A/B/C **3/8/15**, Figma Heavy/Light/None **3/4/19**;
  tarihsel kalan kapsam **117 nominal h**.
- **Figma 0**; backend, auth config, taxonomy ve ortak primitive değişmedi.
  Development yazımı ve Production erişimi yok. AGENTS.md/protokol değişmedi.
- Birleşik kapı: **1841 PASS / 0 FAIL / 6 mevcut koşullu skip**, analyzer temiz;
  Account **GREEN**. [Teslim kanıtı](ASTRA_WAVE2B_ACCOUNT_HUB_INTEGRATION_RESULT.md).
- [Agent 2 Wave 3 adayı](ASTRA_WAVE3_SCOPE_RECOMMENDATION.md):
  Wishlist + Recently Viewed/iki eylemi + Notifications + truthful Coupons,
  **24 nominal h / 6 birim**; hazırlanmış öneri, uygulama başlatılmadı.
  **70–100 h önerilmez**: Design Owner/Agent 3 rezervasyonu sonrası toplam
  50 h kalır; ilgisiz veya tamamlanmış işlerle kapsam şişirilmez.
- Design Owner Batch 2 **Purchases, Reviews, Chat** ve bağımlı Agent 3 kapsamı
  korunur; yaklaşık üç Tier A prototype ve Product Owner yön onayı gerekir.
  Notifications yalnız mevcut hedef API'lerini tüketir. Shared dosyalarda tek
  yazar kuralı korunur; kalan location/Cart/QR modalları ayrı sahiplik ister.
- [60 günlük plan](UI_W44_60_DAY_ACCELERATION_PLAN.md) Bölüm 12 üç senaryoyu,
  owner/integration/rework, Merchant minimumu, fiziksel QR, signing, legal/support
  ve ayrı yetkili Production kapılarını korur. UI testleri pilot kabulü değildir.
- Astra rol konuşmaları persistent; her yeni görev güncel main'e sabitlenir.
  Aşağıdaki önceki dalga kayıtları tarihsel bağlamlarında korunmuştur.


## Tarihsel durum — Astra Wave 2A, 2026-09-05

- **Shop Details Final UI: DONE / MAIN. Cart V2 Final UI: DONE / MAIN.
  Nearby / Location Final UI: DONE / MAIN.**
- Cart QR CTA tam olarak **QR kod oluştur**. Single-shop fiziksel alışveriş
  hazırlığı, mevcut QR güvenliği/iş akışı ve konum gizlilik mimarisi korunur.
- Wave 1 All Products/Search ve Auth/Startup main davranışı korunur. Üç onaylı
  Tier A sunum gerçek constructor/tab/caller yollarında varsayılan olarak açılır.
- Güncel [envanter](UI_W45A_POST_TIER_A_INTEGRATION_INVENTORY.md):
  **35 kalan birim = 14 ekran + 19 modal + 2 shared-state**;
  Tier A/B/C **3/15/17**, Figma Heavy/Light/None **3/6/26**.
  Değişmeyen konum/Cart/QR modalları yalnız davranış testiyle DONE sayılmaz.
- Astra rol konuşmaları **persistent by default**; her yeni görevde fetch ve
  güncel origin/main + görev sözleşmesine yeniden sabitleme zorunludur.
  [Protokol](ASTRA_EXECUTION_PROTOCOL.md) güncellendi; AGENTS.md değişmedi.
- **Next Design Owner batch: to be selected from refreshed Tier-A inventory**.
  Aday seti FS-30 Purchases, FS-32 Reviews, FS-34 Chat; yaklaşık üç prototype
  büyüklüğü korunur. Görsel yön onayı Product Owner'a aittir.
- Birleşik doğrulama, commit ve teslim kanıtı:
  [Wave 2A integration result](ASTRA_WAVE2A_TIER_A_INTEGRATION_RESULT.md).
  Aşağıdaki önceki dalga kayıtları kendi tarihsel bağlamında korunur.

## Governing rules

- W39A semantic tokens, Poppins type ramp, shared primitives and light theme are the reuse baseline.
- Each wave preserves current domain logic, routes, AuthGuards, Cubits/repositories and canonical taxonomy contracts unless a separate product task explicitly changes them.
- UI migration must not introduce shipping-first, payment-first or classic delivery-commerce semantics. EsnaftaVar remains local discovery, merchant/price comparison, physical visit and single-store Cart V2 preparation.
- No runtime fake data. Fixtures remain isolated to tests/goldens.
- Each screen wave must cover loading, empty, error and success where applicable; 320/390/430 px, Turkish overflow, 44 px touch targets, accessibility semantics, targeted regressions and full analyzer.
- Dark mode is deferred until a product-approved palette and contrast contract exist.

## Operating model — Astra roles and bounded visual batches

The Design Owner owns Tier A visual direction and shared-foundation consistency;
the Integration Agent owns source/main reconciliation, combined regression and
main delivery. Independent implementation packages use their explicitly assigned
branches and file ownership. Do not interpret historical single-screen sequencing
as permission to stop before all independent work in a current package is complete.

1. Design Owner prepares approximately three Tier A prototypes per visual batch.
2. Product Owner reviews and approves each direction; record substantive corrections.
3. Design Owner closes responsive/state/accessibility and behavior coverage for
   the approved batch without structural redesign.
4. Integration reviews current main, reconciles semantics, tests and merges the
   full accepted batch. Shared primitives have one designated owner per wave.
5. Select the next batch from current reachable inventory. Product Owner review
   throughput sets the visual batch size; elapsed time is not a success criterion.

Roles normally continue in persistent Astra conversations. Each new package
fetches origin and re-anchors to current main plus its task contract. See
[execution protocol](ASTRA_EXECUTION_PROTOCOL.md) for justified isolation exceptions.

## Figma budget policy

- Figma use remains minimal, selective and tied to a concrete visual decision.
- Repeated exploratory reads and unnecessary write iterations are avoided.
- The approved K'pasa direction, established Flutter design system, prior audit
  findings and committed golden evidence are reused before requesting new Figma
  work.
- The Flutter Final UI foundation is the primary implementation reference. Figma
  remains a selective visual reference and is not a parallel source of runtime
  behavior.

## Historical sequence — W39–W43

Wave 39B-R semantic visual delta closes the Home root-category mapping gate:
canonical-name resolution is `24/24`, order/root-id independent, and missing,
mismatch, ambiguous or unrelated fallbacks are `0`. The current rounded Material
icons are an owner-accepted temporary V1. A professional `CANONICAL 24 CATEGORY
VISUAL PACK` is deferred polish; it did not block the Category / Recursive Browse
delivery now closed by W40B. Home composition and canonical taxonomy content/runtime
remain unchanged.

Wave 40B closes the second rollout surface. The Product Owner-approved Category /
Recursive Browse V1 is integrated with compact header/breadcrumb, `Alt kategoriler`,
two-column cards, variable-depth L2/L3/L4 navigation, unavailable fail-safe and the
existing leaf-to-Product-Listing taxonomy-scope handoff.

Wave 41B closes the third rollout surface. The Product Owner-approved Product
Listing V1 preserves compact path/summary/sort, balanced two-column cards,
normalized images, product/brand/local-merchant/price hierarchy, seller-count or
single-store context, wishlist independence and existing Product Details handoff.
Only default/newest/rating sorting is exposed; no new filters, pagination or
shipping/payment/checkout semantics exist.

Wave 42B closes the fourth rollout surface. The Product Owner-approved Product
Details V1 preserves compact identity/header, explicit 224 px contain-fit hero,
truthful 0/1/many local-seller and listing-price states, Product Information,
Reviews, wishlist, existing seller-section context and Cart V2 preparation. The
shared image slider remains optional/default-off and retains the 340 px legacy
branch for existing callers. At the W42B checkpoint the next visual gate was Seller
Comparison Final UI at `390 px`; Wave 43B closes that gate below.

Wave 43B closes the fifth rollout surface. The Product Owner-approved Seller
Comparison V1 preserves truthful 0/1/many offers, real listing price/rating/
distance/availability, deterministic single lowest-price emphasis, Shop Details
handoff and Cart V2 single-shop physical preparation. The final CTA copy is
`Mağazayı gör` / `Sepete ekle`; the old `Listeye ekle` label is absent from this
Final UI path. `ProductSellersSection` remains explicit opt-in/default-off for the
new presentation, so existing Product Details callers are unchanged. Before a
sixth surface is selected, the next gate is UI inventory/acceleration planning;
Shop Details remains the sequence candidate unless Product Owner priorities change.

| Order | Surface | Required foundation reuse | Primary acceptance focus |
| --- | --- | --- | --- |
| 1 | Home — W39A | Completed token/theme/primitives | Discovery hierarchy, location/search, dynamic categories, campaign, products, merchants, Reward slot off by default. |
| 2 | Category / Recursive Browse | Section/state/surface foundations | 24-root and variable-depth taxonomy, breadcrumb/path context, long labels and no frozen demo tree. |
| 3 | Product Listing | Input/chip/card/section/state foundations | Search refinement, filter/sort, availability, density and exact canonical category scope. |
| 4 | Product Details | Surface/card/button/state foundations | Product context, media/fallback, rating summary and physical local-shopping semantics. |
| 5 | Seller Comparison | Merchant/price/section foundations | 14–15 seller scalability, price/distance/availability, best-price state and “Mağazayı Gör”. |
| 6 | Shop Details | Merchant/product/section foundations | Shop identity, address, rating/open state where contracted, directions, products and customer-side reviews. |
| 7 | Cart V2 | Button/state/surface foundations | Single active store, conflict/empty states, quantity/total, physical-purchase intent and QR availability without demo-owner claims. |
| 8 | Search | Input/chip/card/state foundations | Recent/refined search, taxonomy-aware results, products/shops and existing navigation behavior. |
| 9 | Wishlist / Reviews / Profile / Auth | Entire customer foundation | Auth gates, empty/error states, verified reviews, settings, accessible forms and final secondary-state/polish pass. |

## Change-control checkpoints

For every rollout wave:

1. Inventory current component and behavioral contracts before visual changes.
2. Reuse or extend the W39A foundation; do not create a parallel token family.
3. Add a new reusable primitive only when at least two consumers or a clear cross-screen contract justify it.
4. Keep compatibility facades until all consumers migrate, then remove them in a dedicated cleanup diff.
5. Record local visual evidence at 390 px plus narrow/large-text stress.
6. Run screen-specific regression tests, relevant adjacent business-contract tests, full analyzer and the full suite before integration.

## Deferred decisions

- Reward economics/backend/activation.
- Product-approved dark mode.
- Any taxonomy content change; the canonical taxonomy workstream remains authoritative.
- Advertising, sponsorship ranking, gamification and merchant-management behavior.
- Final campaign artwork/content policy beyond the existing runtime banner source.

`W39A_FOUNDATION_COMPLETE: YES`

`UI_ROLLOUT_MODEL: ASTRA_DESIGN_OWNER_BATCH_PLUS_INDEPENDENT_IMPLEMENTATION_AND_INTEGRATION`

`CATEGORY_RECURSIVE_BROWSE_V1_MAIN: YES`

`PRODUCT_LISTING_V1_MAIN: YES`

`PRODUCT_DETAILS_V1_MAIN: YES`

`SELLER_COMPARISON_V1_MAIN: YES`

`NEXT_ROLLOUT_STEP: SELECT_DESIGN_OWNER_BATCH_2_FROM_REFRESHED_TIER_A`

`NEXT_ROLLOUT_SURFACE: TO_BE_SELECTED_FROM_FS_30_FS_32_FS_34`

`NEXT_REQUIRED_VISUAL_GATE: APPROXIMATELY_THREE_TIER_A_PROTOTYPES_THEN_OWNER_APPROVAL`

`W39B_MAIN_INTEGRATED: YES`

`CANONICAL_CATEGORY_SEMANTIC_MAPPING: INTEGRATED_24_OF_24`

`CATEGORY_ART_STATUS: TEMPORARY_V1_OWNER_ACCEPTED`

`CANONICAL_24_CATEGORY_VISUAL_PACK: DEFERRED_POLISH`

`MAIN_INTEGRATION_REQUIRED: NO`
