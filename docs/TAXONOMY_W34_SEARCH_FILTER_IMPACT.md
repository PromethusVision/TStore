# Wave 34C — Search and Filter Impact

**Kapsam:** Canonical V1 açıldığında gereken minimum Customer App adaptasyonu.
Wave 15 facet/search mimarisi bu görevde implemente edilmez.

## Current search contract

Customer search üç kaynağı birleştirir: product text search, bütün aktif kategorilerin
client-side name/description eşleşmesi ve shop text match. Kategori listesi Cubit
ömrü boyunca cache'lenir. En fazla altı category gösterilir; yalnız ilk eşleşen
kategorinin ID'si ile exact `products.category_id` sorgulanır.

Bu yapı dört flat demo category için çalışabilir; owner-final L1–L4 ağacında doğru
ve ölçeklenebilir değildir.

## Etki matrisi

| Alan | Mevcut | Canonical V1 minimum | Sınıf | Risk |
|---|---|---|---|---|
| Category source | Bütün aktif satırları indir ve local filtrele. | Bounded server-side taxonomy search/index response. | `MUST_CHANGE_WITH_MIGRATION` | Payload, latency, stale cache. |
| Search identity | Name/localized title/description. | Stable node ID + label + path + node type + taxonomy version. | `MUST_CHANGE_WITH_MIGRATION` | Rename/move report fragmentation. |
| Turkish matching | `toLowerCase()` substring. | Locale-aware normalization (`I/İ/ı/i`), approved aliases/synonyms. | `MUST_CHANGE_WITH_MIGRATION` | Valid category bulunamaz. |
| Ranking | Exact/prefix/contains on display name only. | Server-defined stable ranking; label/path/alias match origin açık. | `MUST_CHANGE_WITH_MIGRATION` | Deep leaf L1'i bastırabilir. |
| Duplicate leaf names | Tek ad gösterimi. | Compact breadcrumb ile disambiguation. | Correctness `MUST_CHANGE_WITH_MIGRATION`; style `UI_KIT_PHASE`. | Yanlış branch seçimi. |
| Product enrichment | Yalnız first category exact ID. | Search service doğrudan product sonuçlarını veya typed descendant scope'u döndürmeli. | `MUST_CHANGE_WITH_MIGRATION` | Non-leaf match boş; ikinci match yok. |
| Category selection | Daima `SubCategoryView`. | Branch → children; assignable leaf → exact products. | `MUST_CHANGE_WITH_MIGRATION` | False empty state. |
| Cache | Cubit-lifetime, versionless full category list. | Versioned bounded response/cache; taxonomy version değişince invalidate. | `MUST_CHANGE_WITH_MIGRATION` | Retired/moved node gösterimi. |
| Recent searches | Query strings only. | Aynen korunabilir; category ID eklenmez. | `NO_CHANGE` | Düşük. |
| Product filters | Sort only; category facet engine yok. | Migration için yalnız selected branch/leaf scope; provisional facet engine ayrı kalır. | `SAFE_PRE_MIGRATION` interface / `DEFER` full facet | Scope creep. |
| Analytics | Aktif taxonomy analytics yok. | Future event stable node ID/version ve match source taşımalı; raw query privacy ayrı karar. | `DEFER` | Privacy/continuity. |

## Minimum response şekli

Bu bir DB schema değildir; client correctness için response semantiğidir:

- `node_id`, `display_name`, `compact_path`, `is_leaf`, `is_assignable`,
  `lifecycle_state`, `taxonomy_version`;
- match origin: canonical label, approved alias veya breadcrumb segment;
- retired sonuç normal selectable category gibi dönmemeli; successor varsa authoritative
  redirect bilgisi taşımalı;
- category result ürün sonucu üretirse exact/descendant scope açık olmalı;
- response bounded ve stable-tie-break sıralı olmalı.

## Filter sınırı

Canonical category seçimi ve facet aynı şey değildir:

- category node ürünün primary sınıfını belirler;
- brand, renk, beden, gender, capacity, fitment ve compatibility facet/attribute'tur;
- current product `attributes` alanının varlığı final facet sözleşmesi anlamına gelmez;
- bu wave filter schema, chip seti, count aggregation veya provisional Wave 15 engine
  implemente etmez.

Minimum migration adaptasyonu: category browse/search caller'ının `EXACT_LEAF` ve
`DESCENDANTS` product scope'larını doğru seçmesi ve filter state reset/restore'unun
stable node ID/version ile davranmasıdır.

## Required tests

1. Final canonical L1 adı ve approved alias eşleşir; eski hardcoded demo adı display
   label'ı override etmez.
2. `Kırtasiye`, `kirtasiye`, `KIRTASİYE` aynı intended result setine ulaşır.
3. Aynı adlı iki leaf path ile ayrılır ve doğru branch açılır.
4. L1/L2 branch sonucu descendants; leaf sonucu exact products getirir.
5. Birinci category sonucuna özel merge davranışı kaldırıldığında diğer sonuçlar
   kaybolmaz.
6. Taxonomy version değişince stale category cache kullanılmaz.
7. Retired node normal selectable sonuç değildir; unknown successor fail-closed olur.
8. Category search partial failure product/shop başarılarını bozmadan açık warning verir.
9. Recent query storage category ID veya taxonomy path persist etmez.
10. Büyük tree search Home/UI thread'inde all-row client filtering yapmaz.

`SEARCH_FILTER_IMPACT: PASS`

`REMOTE_RUNTIME_TOUCHED: NO`
