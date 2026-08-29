# Wave 34C — Customer App Canonical Taxonomy V1 Impact

**Durum:** `AUDIT COMPLETE — TAXONOMY RUNTIME NOT ACTIVATED`

**Base:** `origin/main@6415f09c8b84d3ef1c72d642c1908c433b534994`

Bu denetim owner-final Canonical Product Taxonomy V1 tasarımı ile mevcut Customer
App kodunu karşılaştırır. Canonical tasarım 24 L1, variable-depth L1–L4 ve ürünü
tam olarak bir aktif/atanabilir primary leaf'e bağlama sözleşmesidir. Mevcut
`categories` runtime verisi, stable opaque node ID'leri ve migration bridge'i bu
görevde değiştirilmemiştir.

## Sınıflandırma

- `NO_CHANGE`: Kimlik sınırı taxonomy'den bağımsız; regression kanıtı yeterlidir.
- `SAFE_PRE_MIGRATION`: Geriye uyumlu hazırlanabilir, fakat bu audit görevinde kodlanmadı.
- `MUST_CHANGE_WITH_MIGRATION`: Yeni schema/data ile aynı kontrollü release içinde gerekir.
- `UI_KIT_PHASE`: Doğruluk değişikliğinden sonra görsel kabul/polish işidir.
- `DEFER`: Aktif V1 müşteri akışında yoktur veya ayrı ürün/altyapı kararı ister.

## Kod yolu envanteri

| FILE | CURRENT ASSUMPTION | CANONICAL V1 IMPACT | CHANGE_REQUIRED | RISK | TEST_REQUIRED |
|---|---|---|---|---|---|
| `lib/features/shop/domain/entities/category_entity.dart` | `id/name/parentId`; `isParent` aslında yalnız `parentId == null` yani root demektir. | Root, branch, leaf ve assignable aynı kavram değildir; path/depth/version/lifecycle yoktur. `copyWith` parent'ı `null` yapamaz. | `MUST_CHANGE_WITH_MIGRATION`: explicit `isRoot`, `isLeaf`, `isAssignable`, canonical stable ID, depth/path veya ancestor contract; nullable copy sentinel. | HIGH | L1–L4 parse/equality/copy; root ≠ parent; leaf ≠ assignable. |
| `lib/features/shop/data/models/category_model.dart` | Mevcut kolonları parse eder, bilinmeyen alanları yok sayar. | Additive schema crash üretmeyebilir ama client doğru gezinme/assignability kararı veremez. | `MUST_CHANGE_WITH_MIGRATION`: migration'ın exact response contract'ını parse et; eksik/bozuk depth/path için fail-closed. | HIGH | Tüm depth'ler, inactive/retired, malformed parent/path, media. |
| `lib/features/shop/domain/repositories/category_repository.dart` | All/root/one-hop children metotları vardır; ancestor/descendant/path yoktur. | Variable-depth browse için node, children, path ve descendant product scope gerekir. | `SAFE_PRE_MIGRATION` interface tasarımı; backend çağrısı migration ile. All-tree eager API Home için kullanılmamalı. | HIGH | Root order, child order, empty leaf, path, inactive node, error. |
| `lib/features/shop/data/repositories/category_repository_impl.dart` | `getCategories()` bütün aktif satırları; root/children ayrı sorguları yalnız one-hop okur. Sıralama yalnız `sort_order`. `getCategoryById` active filtresizdir. | Full tree açılırsa Home/search tüm node'ları çekebilir; eşit sort'ta sıra deterministik değildir; retired node normal node gibi dönebilir. | `MUST_CHANGE_WITH_MIGRATION`: projection-specific query/RPC, stable tie-break, lifecycle/visibility semantics, version-aware response. | CRITICAL | Büyük ağaç, 24 root, child isolation, deterministic order, retired redirect/not-found, RLS. |
| `lib/features/shop/domain/usecases/get_categories_usecase.dart` | Her çağrıda flat all-active list döndürür. | Home ile search aynı ağır/genel kontrata bağlı kalır. | `MUST_CHANGE_WITH_MIGRATION`: root discovery ve taxonomy search/browse use-case'lerini ayır. | HIGH | Doğru repository metodu ve failure propagation. |
| `lib/features/shop/presentation/cubit/categories_cubit.dart` | Tek flat liste state'i yükler. | Home için yalnız 24 root/projection gerekir; child state/path taşımaz. | `MUST_CHANGE_WITH_MIGRATION`: root/projection state; browse için ayrı node/path state yönetimi. | HIGH | Loading/empty/error/retry ve stale response. |
| `lib/features/shop/domain/entities/product_entity.dart` | Bir zorunlu `categoryId`, opsiyonel tek `categoryName`; joined adlar `Equatable.props` içinde değildir. | Exactly-one leaf ile şekil uyumludur; fakat ID final stable leaf olmalı ve breadcrumb tek addan üretilemez. Joined ad değişimi equality ile fark edilmez. | FK backfill `MUST_CHANGE_WITH_MIGRATION`; joined path/equality düzeltmesi `SAFE_PRE_MIGRATION`. Product ID değişmemeli. | HIGH | Leaf-only ID, category path refresh, equality, missing relation. |
| `lib/features/shop/data/models/product_model.dart` | `category_id` non-null string; join `categories(name)`. | Final leaf FK parse edilebilir, fakat lifecycle/path/version görünmez. | `MUST_CHANGE_WITH_MIGRATION`: approved response view/relations; category missing/retired davranışı. | HIGH | Leaf join, retired alias, null/malformed relation, media unchanged. |
| `lib/features/shop/data/repositories/product_repository_impl.dart` | Kategori filtresi `eq(category_id, selectedId)`; join yalnız `categories(name)`. | Leaf için exact sorgu doğru; L1/L2/L3 branch browse alt leaf ürünlerini döndürmez. | `MUST_CHANGE_WITH_MIGRATION`: explicit `EXACT_LEAF` ve `DESCENDANTS` scope; server-side bounded query/RPC, active/assignable guards. | CRITICAL | Branch roll-up, leaf exact, sibling leakage yok, pagination/order, inactive leaf. |
| `lib/features/shop/domain/usecases/get_products_usecase.dart` ve `presentation/cubit/products_cubit.dart` | Parametre yalnız `categoryId`; scope semantiği yok. | Caller leaf mi branch mi olduğunu ifade edemez. | `MUST_CHANGE_WITH_MIGRATION`: typed category scope ve cursor/page contract. | HIGH | Param forwarding, refresh/paging, stale category response. |
| `lib/features/shop/presentation/widgets/home_categories.dart` | `getCategories()` sonucunun tamamını yatay listeler; her karta doğrudan product-list destination verir. Eski demo ad/icon eşlemesi vardır. | Canonical runtime'da bütün aktif L2–L4 node'lar Home'a sızabilir. Root karta dokunma child browse açmalıdır. 24 final L1 adının çoğu 52 px/tek satırda kesilir. | Veri/doğruluk `MUST_CHANGE_WITH_MIGRATION`; layout `UI_KIT_PHASE`. Eski label remap canonical adı override etmemeli. | CRITICAL | Yalnız 24 L1/projection, order, duplicate tap, long labels, 320–430 px, text scale. |
| `lib/features/shop/presentation/views/home_view.dart` | Search ve Home category selection aynı `SubCategoryView` exact-ID yoluna gider. | Branch sonucu child browse yerine boş ürün ekranı açar. | `MUST_CHANGE_WITH_MIGRATION`: node-aware destination; category path/state geçir. | CRITICAL | Home card/search category → doğru next depth/leaf list. |
| `lib/features/shop/presentation/views/sub_category_view.dart` | Adına rağmen child kategori çizmez; seçili ID ile exact ürün ister; breadcrumb yok; listeyi 20 ürünle sınırlar. | L1–L3 non-leaf ekranları yanlış empty state verir; L2/L3/L4 leaf değişkenliğini ayıramaz. | `MUST_CHANGE_WITH_MIGRATION`: generic taxonomy browse destination; children varsa çocuklar, assignable leaf ise exact products, branch product roll-up kararı açık; path/back state. | CRITICAL | L2/L3/L4 leaf/branch matrisi, paging, empty/error, back path, retired node. |
| `lib/features/shop/presentation/helpers/customer_category_presentation_helper.dart` | Eski İngilizce/demo adları Türkçeleştirir; name/description içinde locale-agnostic lowercase arar. | Final canonical labels source-of-truth olmalı; aliases/synonyms/path ve Türkçe `I/İ/ı/i` araması yoktur. | `MUST_CHANGE_WITH_MIGRATION`: server/index sözleşmesi veya canonical search DTO; display label'ı stable identity yapma. | HIGH | Canonical ad, alias, breadcrumb, Turkish folding, duplicate leaf adları. |
| `lib/features/shop/presentation/cubit/customer_search_cubit.dart` | Bütün kategorileri memory'de cache'leyip local arar; ilk kategori sonucunun exact ID ürünlerini merge eder. | Büyük tree client'a taşınır; yalnız ilk eşleşme ve exact branch ID eksik/yanlı sonuç üretir; cache taxonomy version bilmez. | `MUST_CHANGE_WITH_MIGRATION`: bounded server taxonomy search; result node/path/type; descendant-aware product result; version invalidation. | CRITICAL | 24 L1 + deep leaf, aliases, same-name leaf, no-result, cache version, race/dedup. |
| `lib/features/shop/presentation/widgets/home_search_bar.dart` | Öneride tek category name ve “Kategori”; selection exact ID. | Aynı adlı leaf'ler ayırt edilemez; branch/leaf sonucu farklı destination ister. | `MUST_CHANGE_WITH_MIGRATION`; iki satırlı path görseli `UI_KIT_PHASE`. | HIGH | Long title/path ellipsis, selection type, keyboard/tap, stale search. |
| `lib/features/shop/presentation/views/all_products_view.dart` | Category sonuçları `ActionChip` ile tek ad; aynı exact-ID destination. Ürün filtresi category tree değildir. | Long/adı tekrar eden node'lar belirsiz; branch roll-up yok. | `MUST_CHANGE_WITH_MIGRATION`: node-aware result; minimum breadcrumb/context. Facet UI ayrı task. | HIGH | Wrap at small width/text scale, result identity, branch/leaf navigation. |
| `lib/features/shop/presentation/widgets/product_metadata.dart` ve `views/product_details_view.dart` | Product Details kategori göstermez; stok ve marka gösterir. | Product davranışı değişmez; final breadcrumb isteniyorsa path DTO gerekir. | `NO_CHANGE` for function; breadcrumb `SAFE_PRE_MIGRATION` after contract / polish `UI_KIT_PHASE`. | MEDIUM | Product details stays functional; optional path wraps and retired ancestor handling. |
| Product cards: `home_products_section.dart`, `sub_category_view.dart`, `all_products_view.dart`, `wishlist_view.dart`, `recently_viewed_products_view.dart` | Marka yoksa tek `categoryName` secondary text kullanır; tek satır ellipsis. | Leaf adı gösterilebilir ama branch context yok; duplicate leaf adı belirsiz olabilir. | Functional identity `NO_CHANGE`; display-path decision `UI_KIT_PHASE`. | MEDIUM | Long leaf, null relation, brand precedence, no overflow. |
| `lib/features/shop/data/repositories/shop_repository_impl.dart` ve `shop_product_model.dart` | Listingler product relation üzerinden `categories(name)` alır; shop entity runtime'da product category taşımaz. | Seller comparison/shop product davranışı product/listing IDs korunursa doğrudan değişmez; nested ProductModel join contract etkilenir. | `NO_CHANGE` logic; relation projection `MUST_CHANGE_WITH_MIGRATION` if product DTO changes. | MEDIUM | Seller/listing remains visible after leaf FK migration; no category leakage. |
| `lib/features/shop/presentation/widgets/product_sellers_section.dart` ve `views/shop_profile_view.dart` | Product/shop/listing identity ile çalışır. | Taxonomy navigation değildir. | `NO_CHANGE`; regression only. | LOW | Seller comparison, shop opening, price/availability unchanged. |
| `lib/features/wishlist/**` | Wishlist `product_id` saklar; joined ProductModel kategori adı taşır. | Product ID sabitse favori ilişkisi korunur. | `NO_CHANGE`; relation projection regression. | MEDIUM | Existing favorite survives category backfill; retired category does not orphan product. |
| `lib/features/cart/**` | Cart V2 `shop_product_id`; QR doğrulama cart/listing/product status kullanır. | Category ID authoritative QR/purchase identity değildir. | `NO_CHANGE`; migration sırasında product relation okunabilir kalmalı. | HIGH regression impact, LOW direct coupling | Cart totals, QR, verification and product availability unchanged. |
| `lib/features/reviews/**` | Reviews `product_id`; shop rating `shop_id`. | Review eligibility/identity taxonomy'den bağımsızdır. | `NO_CHANGE`; regression only. | MEDIUM | Review create/read/eligibility after product category backfill. |
| `docs/CUSTOMER_APP_DEEP_LINK_MATRIX.md` ve `lib/core/supabase/supabase_service.dart` | Yalnız environment-specific Auth callback aktif; category/product/shop content link sistemi yok. | Mevcut deep linkte kategori riski yok. Future category link stable node ID + alias/redirect ister. | `DEFER`; Auth callback'e taxonomy route ekleme. | LOW now / HIGH future | Auth callback unchanged; future cold/warm category redirect contract. |
| `lib/core/supabase/public_media_source_resolver.dart` ve `category_model.dart` | Category image controlled path `catalog/<categoryId>/...`; legacy HTTPS read uyumluluğu. | Stable category ID değişirse controlled object ownership path'i de açık mapping ister; URL UI'da üretilmemeli. | `MUST_CHANGE_WITH_MIGRATION` only if IDs/path owners change; resolver boundary `NO_CHANGE`. | HIGH | Old HTTPS, old/new object path transition, invalid input fallback, no cross-node path. |
| `shared_preferences_recent_product_searches_storage.dart` | Yalnız query string saklar. | Stored category ID yoktur; rename sonrası eski sorgu yalnız yeni index sonucu verir. | `NO_CHANGE`; Turkish/alias search regression. | LOW | Query history survives; no identity linkage. |
| `shared_preferences_recently_viewed_products_storage.dart`, pending chat, wishlist/cart persistence | Product/listing/customer IDs saklanır; category ID persist edilmez. | Stable product/listing IDs korunursa cache invalidation gerekmez. | `NO_CHANGE`; client-wide category-ID storage eklenirse taxonomy-version namespacing gerekir. | LOW | Existing IDs survive, no category cache found. |
| `tool/demo_seed/esenler_demo_v1.json` ve generator | 4 root-like deterministic demo category UUID; 20 product doğrudan bu ID'lere bağlı. Shop distribution da aynı category kavramına göre doğrulanır. | Demo UUID stable taxonomy ID değildir; products final leaf'e gitmeli. Product taxonomy ile merchant/sector taxonomy ayrımı korunmalı. | `MUST_CHANGE_WITH_MIGRATION`, ayrı seed/data task. Bu görevde veri değişmedi. | CRITICAL | 4/4 conceptual bridge, 20/20 leaf mapping, 285 listing propagation; product/shop categories eşitliği kaldırılmalı veya yeniden tanımlanmalı. |
| `test/unit/demo_seed/esenler_demo_v1_contract_test.dart` ve `test/live/production_demo_functional_smoke_test.dart` | `parent_id == null`, 4 flat category ve shop/product category equality bekler. | Canonical runtime sonrası yanlış sözleşmeyi PASS sayabilir veya doğru veriyi fail eder. | `MUST_CHANGE_WITH_MIGRATION`; live test sadece yetkili environment'da. | CRITICAL | Final stable IDs/counts, leaf assignment, sector separation, no orphan. |
| Category/search/widget/model/media tests | Eski flat `category-1`, Market/English demo fixtures ve exact query kanıtlar. | Mevcut güvenlik/state testleri değerli fakat L1–L4 doğruluğunu kanıtlamaz. | Variable-depth fixture/test factory `SAFE_PRE_MIGRATION`; backend assertions migration ile. | HIGH | Ayrıntılı matrix ayrı regression belgesinde. |
| `lib/features/shop/presentation/views/store_view.dart` ve `core/common/widgets/category_tab.dart` | Sabit `TTexts.categories`, görsel asset/dummy product ve sentetik `category-$index` kullanır. Aktif bottom navigation'da referansı bulunmadı. | Canonical runtime'a bağlanırsa yanlış ikinci taxonomy yüzeyi olur. | `DEFER`: dormant tut veya ayrı removal/activation audit'i; runtime'a bağlama. | MEDIUM | Navigation reachability; canonical source dışında kategori üretilmediği guard. |
| Analytics runtime | Customer taxonomy event emitter/SDK bulunmadı; demo test analytics row üretmediğini doğrular. | Rename/move/split sürekliliği gelecekte stable node ID + taxonomy version/path snapshot ister. | `DEFER`; analytics engine kurma. | MEDIUM future | Event payload privacy/version/alias continuity when implemented. |

## Cutover için zorunlu client kapıları

1. Backend contract root, child, path, lifecycle, leaf ve assignable alanlarını
   versioned biçimde tanımlamadan client DTO kilitlenmez.
2. Home all-active query'den ayrılır ve yalnız owner-final root/projection okur.
3. Browse destination node türüne göre child veya product davranışını seçer; depth
   numarası leaf varsayımı olarak kullanılmaz.
4. Product queries exact-leaf ile descendant-scope'u açıkça ayırır.
5. Search bütün ağacı client'a çekmez; stable result identity/path döndürür.
6. Product FK backfill, media ownership ve demo bridge aynı migration release
   contract'ıyla doğrulanır; product/listing/shop UUID'leri korunur.
7. Inactive/retired node fail-closed davranışı ve alias redirect server/client
   sınırında tek kez tanımlanır.

## Bu görevde neden test eklenmedi?

Mevcut modelde `depth`, `isLeaf`, `isAssignable`, path veya version alanı yoktur.
Bu alanları testte hayalî bir DTO'ya bağlamak unimplemented backend şemasını fiilen
kilitleyecekti. Bu nedenle production code/test fixture değiştirilmedi; mevcut
davranış ile migration-eşzamanlı test gereksinimleri kanıtlanabilir biçimde
envanterlendi.

`CUSTOMER_TAXONOMY_IMPACT_AUDIT: PASS`

`REMOTE_RUNTIME_TOUCHED: NO`
