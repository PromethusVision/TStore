# Wave 35C — Customer Client Taxonomy Cutover Plan

**Durum:** `LOCAL CLIENT SEAMS PREPARED — DEVELOPMENT CUTOVER NOT READY`

Bu plan, Development schema/read contracts gerçek ve versioned hale geldikten sonra
Wave 35C saf domain katmanının Customer App'e nasıl bağlanacağını tanımlar. Remote
apply veya activation emri değildir.

## Durum sınıfları

- `ALREADY_PREPARED`: Saf, local ve backend-independent kod/test hazır.
- `REQUIRES_BACKEND_CONTRACT`: Exact response/RPC/compatibility shape gelmeden kodlanmaz.
- `REQUIRES_CUTOVER`: Development candidate ile birlikte kontrollü wiring gerekir.
- `UI_KIT_PHASE`: Functional correctness sonrası görsel kabul/polish.

## Connection matrix

| Connection | State | Exact remaining work | Required evidence |
|---|---|---|---|
| Category node/level/kind/lifecycle/assignability | `ALREADY_PREPARED` | Backend DTO adapter'ı bu modele map edecek. | Response field/type/version contract. |
| Root/children/descendants/breadcrumb pure logic | `ALREADY_PREPARED` | Server payload'ı graph snapshot veya bounded path response'a dönüştürülecek. | Duplicate/orphan/level validation; large-tree performance. |
| Navigation decision | `ALREADY_PREPARED` | Generic browse coordinator bu kararı tüketecek. | Container→child, leaf→listing, gated→unavailable tests. |
| Query scope model | `ALREADY_PREPARED` | Repository typed scope'u approved endpoint'e çevirecek. | Exact leaf and descendant sibling-isolation contract. |
| Search result context | `ALREADY_PREPARED` | Server result DTO matched node/path/version bilgisiyle map edilecek. | Turkish/alias/path ranking contract. |
| Legacy fallback | `ALREADY_PREPARED` | Capability unavailable/rollback sırasında current exact-ID route korunacak. | Old schema + new app compatibility suite. |
| Category transport DTO | `REQUIRES_BACKEND_CONTRACT` | Existing `CategoryModel`'e speculative nullable fields eklemek yerine approved response adapter/view oluştur. | Exact nullable/backfill window shape. |
| Root/child repository | `REQUIRES_BACKEND_CONTRACT` | Security-invoker root/children read veya reviewed PostgREST projection. | RLS, lifecycle/policy filtering, deterministic order. |
| Descendant products | `REQUIRES_BACKEND_CONTRACT` | `DESCENDANTS` scope için bounded, paged server query/RPC. | No sibling leakage; active+assignable gates. |
| Alias/successor | `REQUIRES_BACKEND_CONTRACT` | Retired/moved ID resolution tek authoritative response'tan alınır. | No first-successor split fallback. |
| Server-side taxonomy search | `REQUIRES_BACKEND_CONTRACT` | Current full client list/name match yerine bounded category search. | Turkish folding, approved synonyms, privacy, version. |
| Taxonomy capability/version | `REQUIRES_BACKEND_CONTRACT` | App'in legacy/canonical path'i explicit response capability ile seçmesi. | No timeout/error-based mode guessing. |
| Home root projection | `REQUIRES_CUTOVER` | `CategoriesCubit/GetCategoriesUsecase` root-specific read'e geçer; current flat fallback feature/capability guard arkasında kalır. | Exactly 24 owner-final roots; lower-node leakage zero. |
| Recursive browse shell | `REQUIRES_CUTOVER` | `SubCategoryView` exact leaf listing rolünü korurken container için child destination/coordinator eklenir. | L2/L3/L4, back state, error/empty, stale request. |
| Product repository typed category scope | `REQUIRES_CUTOVER` | Current `.eq(category_id, id)` yalnız canonical exact leaf'te; descendants approved endpoint'e gider. | Paging/order/dedup and rollback compatibility. |
| Search Cubit source | `REQUIRES_CUTOVER` | Versioned server results `TaxonomyCategorySearchContext`e map edilir; first-category exact merge kaldırılır. | Partial failure, cache invalidation, race/dedup. |
| Inactive/retired UI state | `REQUIRES_CUTOVER` | Unavailable veya authoritative single redirect; arbitrary root/sibling fallback yok. | Direct stale ID and rollback tests. |
| Category cache | `REQUIRES_CUTOVER` | Canonical cache varsa environment+taxonomy-version namespace; legacy Cubit cache cutover'da bırakılır. | Version change invalidation. |
| Category media | `REQUIRES_CUTOVER` | Stable category ID/object-path mapping approved manifest ile doğrulanır; resolver central kalır. | Legacy HTTPS + old/new controlled path tests. |
| Demo mapping | `REQUIRES_CUTOVER` | Ayrı data task 4 demo root UUID'sini 20 product leaf mappinginden ayırır; 285 listing product relationla korunur. | Product/Merchant taxonomy separation. |
| Breadcrumb visuals | `UI_KIT_PHASE` | 122-char L4 path için compact/collapsible presentation. | 320–430 px, text scale, semantics. |
| Home label/icon layout | `UI_KIT_PHASE` | 24 long L1, canonical media/icon direction. | Visual owner acceptance; tap accessibility. |
| Search result path layout | `UI_KIT_PHASE` | Same-name leaf disambiguation için compact path. | No ambiguous action at mobile widths. |

## Exact cutover sequence

1. **Backend contract freeze:** exact Development endpoint names, fields, nullability,
   lifecycle/publication gates, taxonomy version ve error semantics kaydedilir.
2. **Compatibility DTO:** legacy `CategoryModel` korunur; canonical response için ayrı
   adapter yazılır ve both-schema contract tests geçer.
3. **Repository capability:** root/children/path/search/descendant sources eklenir;
   capability explicit olmalı, eksik kolon hatasından tahmin edilmemeli.
4. **DI/state:** new repository/use-case/Cubit/coordinator wiring eklenir; rollback
   sırasında legacy source'a güvenli dönüş korunur.
5. **Home:** yalnız canonical capability varsa versioned active L1 projection;
   capability yoksa current flat behavior.
6. **Browse:** `TaxonomyCategoryNavigationDecision` container'da child route,
   assignable leaf'te `SubCategoryView`/exact listing, gated node'da unavailable.
7. **Products:** `TaxonomyProductQueryScopeKind.exactLeaf` current indexed equality;
   `descendants` approved recursive endpoint. Caller scope'u gizli varsaymaz.
8. **Search:** bounded server result → `TaxonomyCategorySearchContext`; current
   client cache ve first-exact shortcut canonical mode'da devreden çıkar.
9. **Lifecycle/redirect:** staged/retired/nonassignable fail-closed; split predecessor
   otomatik first successor'a gönderilmez.
10. **Media/demo:** category object ownership ve 4/20/57/285 demo mapping ayrı
    reviewed artifacts ile doğrulanır; product/listing UUID'leri korunur.
11. **Regression:** Home/browse/search ile Cart V2, QR, wishlist, reviews, seller
    comparison aynı exact artifact üzerinde PASS olur.
12. **Controlled activation:** Development flag/capability canonical'a alınır;
    observation window ve rollback owner'ı hazır olmadan Production düşünülmez.

## Compatibility and rollback rules

- New client must old schema ile çalışmalıdır; old client staged canonical node'ları
  görmemelidir.
- Canonical import sırasında `is_active` compatibility gate korunur.
- Partial backend failure canonical response'u legacy response sanmamalıdır.
- Capability/version response yoksa only current legacy path kullanılır; canonical
  graph kısmen kurulmaz.
- Rollback taxonomy version/cache'i invalidate eder ve current exact category path'e
  döner; product/listing IDs değişmez.
- Canonical node ID ile legacy demo ID sessizce eşitlenmez.

## Development cutover PASS criteria

- 24/24 ordered active root; lower-node Home leakage zero.
- L2/L3/L4 variable leaf/container traversal PASS.
- Exact/descendant results complete, unique, paged and sibling-isolated.
- Staged/retired/policy-gated discovery fail-closed.
- Alias move/rename single redirect; split ambiguity quarantined.
- Taxonomy version cache transition deterministic.
- Long-name functional tests and UI Kit acceptance ayrımı korunmuş.
- Cart V2, QR, wishlist, reviews and seller comparison unchanged.
- Old schema/new app and staged schema/old app compatibility suites PASS.
- No Product/Merchant taxonomy conflation in demo or shop paths.

## STOP criteria

- Endpoint/field/version contract exact değil.
- Root/child/publication RLS proof yok.
- Descendant query client-side full-tree scan gerektiriyor.
- Lifecycle veya assignability nullable/ambiguous halde fail-open.
- Split redirect arbitrary first target seçiyor.
- Product FK, media owner veya demo bridge incomplete.
- Rollback current-runtime fallback ile test edilmedi.
- Taxonomy-independent P0 regression'lardan biri fail.

Bu wave saf client hazırlığını tamamlar; backend contract ve Development cutover
wiring'i olmadığı için gerçek Development taxonomy cutover'a henüz hazır değildir.

`CLIENT_SEAMS_ALREADY_PREPARED: PASS`

`DEVELOPMENT_BACKEND_CONTRACT: REQUIRED`

`DEVELOPMENT_CUTOVER_WIRING: NOT_STARTED`

`READY_FOR_DEVELOPMENT_TAXONOMY_CUTOVER: NO`

`REMOTE_RUNTIME_TOUCHED: NO`
